#!/usr/bin/env python

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""
Health probe script for OpenStack service that uses RPC/unix domain socket for
communication. Check's the RPC tcp socket status on the process and send
message to service through rpc call method and expects a reply.

Script returns failure to Kubernetes only when
  a. TCP socket for the RPC communication are not established.
  b. service is not reachable or
  c. service times out sending a reply.

sys.stderr.write() writes to pod's events on failures.

Usage example for Ranger-agent-engine:
# python health-probe.py --config-file /etc/ranger-agent/ranger-agent.conf \
#  --service-queue-name ord-notifier-q

"""

import psutil
import requests
import socket
import sys

from oslo_config import cfg
from oslo_context import context
from oslo_log import log
import oslo_messaging

try:
    from configparser import ConfigParser
except ImportError:
    from ConfigParser import ConfigParser

tcp_established = "ESTABLISHED"


def check_service_status(transport, service_queue_name):
    """Verify service status. Return success if service consumes message"""
    service_error = False
    try:
        target = oslo_messaging.Target(topic=service_queue_name,
                                       server=socket.gethostname())
        client = oslo_messaging.RPCClient(transport, target,
                                          timeout=75,
                                          retry=0)
        cctxt = client.prepare(version='1.0')
        results = cctxt.call(context.RequestContext(),
                             'invoke_health_probe_rpc')

        for value in results.values():
            if value == 'failed':
                sys.stderr.write("Health probe detects problem "
                                 ": %s\n" % results)
                if not cfg.CONF.liveness_probe:
                    service_error = True
                    sys.exit(1)
                break

    except oslo_messaging.exceptions.MessageDeliveryFailure:
        # Log to pod events
        sys.stderr.write("Health probe unable to reach message bus\n")
        sys.exit(0)  # return success
    except oslo_messaging.rpc.client.RemoteError as re:
        message = getattr(re, "message", str(re))
        if ("Endpoint does not support RPC method" in message) or \
                ("Endpoint does not support RPC version" in message):
            sys.exit(0)  # Call reached the service
        else:
            sys.stderr.write("Health probe unable to reach service\n")
            sys.exit(1)  # return failure
    except oslo_messaging.exceptions.MessagingTimeout:
        sys.stderr.write("Health probe timed out. Service is down or "
                         "response timed out\n")
        sys.exit(1)  # return failure
    except Exception as ex:
        message = getattr(ex, "message", str(ex))
        sys.stderr.write("Health probe caught exception sending message to "
                         "service: %s\n" % message)
        sys.exit(0)
    except:
        sys.stderr.write("Health probe caught exception sending message to"
                         " service\n")
        if service_error:
            sys.exit(1)
        else:
            sys.exit(0)


def tcp_socket_status(process, ports):
    """Check the tcp socket status on a process"""
    sock_count = 0
    parentId = 0
    for pr in psutil.pids():
        try:
            p = psutil.Process(pr)
            if p.name() in process:
                if parentId == 0:
                    parentId = p.pid
                else:
                    if p.ppid() == parentId and not cfg.CONF.check_all_pids:
                        continue
                pcon = p.connections()
                for con in pcon:
                    try:
                        rport = con.raddr[1]
                        status = con.status
                    except IndexError:
                        continue
                    if rport in ports and status == tcp_established:
                        sock_count = sock_count + 1
        except psutil.NoSuchProcess:
            continue

    if sock_count == 0:
        return 0
    else:
        return 1


def get_rabbitmq_ports():
    """Get the rabbitmq port from config file"""
    rabbit_ports = set()

    try:
        transport_url = oslo_messaging.TransportURL.parse(cfg.CONF)
        for host in transport_url.hosts:
            rabbit_ports.add(host.port)
    except Exception as ex:
        message = getattr(ex, "message", str(ex))
        sys.stderr.write("Health probe caught exception reading "
                         "RabbitMQ ports: %s" % message)
        sys.exit(0)  # return success

    return rabbit_ports


def test_tcp_socket(service_name):
    """Check tcp socket to rabbitmq is in Established state"""
    r_ports = get_rabbitmq_ports()

    # service_name is the same as process name for ranger-agent app
    proc = cfg.CONF.service_name
    if r_ports and tcp_socket_status(service_name, r_ports) == 0:
        sys.stderr.write("RabbitMQ socket not established\n")
        # Do not kill the pod if RabbitMQ is not reachable/down
        if not cfg.CONF.liveness_probe:
            sys.exit(1)


def test_ranger_agent_api_reachable():
    """Test ranger-agent-api for response"""

    # get ranger-agent-api port
    config = ConfigParser()
    config.read(cfg.CONF.config_file)
    port = config.get('api', 'port')

    url = "http://localhost:{}/v1/ord/health_check".format(port)
    try:
        response = requests.get(url, timeout=30)
        if response.status_code != 200:
            sys.exit(1)
    except requests.exceptions.ConnectionError as ce:
        message = getattr(ce, "message", str(ce))
        sys.stderr.write("Health probe ConnectionError Exp: %s\n" % message)
        sys.exit(1)
    except requests.exceptions.ReadTimeout as to:
        message = getattr(to, "message", str(to))
        sys.stderr.write("Health probe ReadTimeout Exp: %s\n" % message)
        sys.exit(1)
    except Exception as ex:
        message = getattr(ex, "message", str(ex))
        sys.stderr.write("Health probe caught Unknown Exp: %s\n" % message)
        sys.exit(1)


def test_rpc_liveness(rabbit_group, service_queue_name):
    """Test if service can consume message from queue"""
    try:
        transport = oslo_messaging.get_transport(cfg.CONF)
    except Exception as ex:
        message = getattr(ex, "message", str(ex))
        sys.stderr.write("Message bus driver load error: %s" % message)
        sys.exit(0)  # return success

    if not cfg.CONF.transport_url or \
            not service_queue_name:
        sys.stderr.write("Both message bus URL and service's queue name are "
                         "required for health probe to work")
        sys.exit(0)  # return success

    try:
        cfg.CONF.set_override('rabbit_max_retries', 2,
                              group=rabbit_group)  # 3 attempts
    except cfg.NoSuchOptError as ex:
        cfg.CONF.register_opt(cfg.IntOpt('rabbit_max_retries', default=2),
                              group=rabbit_group)

    check_service_status(transport, service_queue_name)


def run_health_check():
    oslo_messaging.set_transport_defaults(control_exchange='ranger-agent')

    rabbit_group = cfg.OptGroup(name='oslo_messaging_rabbit',
                                title='RabbitMQ options')
    cfg.CONF.register_group(rabbit_group)
    cfg.CONF.register_cli_opt(cfg.StrOpt('service-name'))
    cfg.CONF.register_cli_opt(cfg.BoolOpt('liveness-probe', default=False,
                                          required=False))
    cfg.CONF.register_cli_opt(cfg.BoolOpt('check-all-pids', default=False,
                                          required=False))

    cfg.CONF(sys.argv[1:])

    log.logging.basicConfig(level=log.ERROR)

    dict_services = {
        "ranger-agent-engine": "ord-notifier-q",
        "ranger-agent-api": "ord-listener-q"
    }

    service_name = cfg.CONF.service_name
    if service_name in dict_services:
        service_queue_name = dict_services[service_name]
    else:
        sys.stderr.write("Invalid service name: %s\n" % service_name)
        sys.exit(0)  # return success

    if service_name == 'ranger-agent-api':
        test_ranger_agent_api_reachable()

    test_tcp_socket(service_name)
    test_rpc_liveness(rabbit_group, service_queue_name)


if __name__ == "__main__":
    run_health_check()

    sys.exit(0)  # return success
