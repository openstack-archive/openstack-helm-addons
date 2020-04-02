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
Script returns failure to Kubernetes when one of the ranger services
sends a non 200 OK response or timed out

sys.stderr.write() writes to pod's events on failures.

Usage example for Ranger-agent-engine:
# python health-probe.py --config-file /etc/ranger/ranger.conf

"""

import json
import os
import psutil
import signal
import requests
import sys

from oslo_config import cfg
from oslo_log import log

try:
    from configparser import ConfigParser
except ImportError:
    from ConfigParser import ConfigParser


def run_health_check():
    cfg.CONF.register_cli_opt(cfg.StrOpt('service-name', required=True))
    cfg.CONF.register_cli_opt(cfg.BoolOpt('liveness-probe', default=False,
                                          required=False))

    cfg.CONF(sys.argv[1:])
    log.logging.basicConfig(level=log.ERROR)

    config = ConfigParser()
    config.read(cfg.CONF.config_file)

    services = ['audit', 'cms', 'fms', 'ims', 'rds', 'rms', 'uuid']
    service_name = cfg.CONF.service_name

    if service_name not in services:
        sys.stderr.write("Invalid service name: %s\n" % service_name)
        sys.exit(0)  # return success

    try:
        port = config.get(service_name, 'port')
        url = "http://localhost:{}".format(port)
        response = requests.get(url, timeout=100)
        if response.status_code != 200 and response.status_code != 404:
            sys.stderr.write("Health probe detects %s service problem "
                             ": %s\n" % (service_name, response.status_code))
            sys.exit(1)

    except requests.exceptions.ConnectionError as ce:
        sys.stderr.write("Health probe ConnectionError Exp:%s\n" % str(ce))
    except requests.exceptions.ReadTimeout as to:
        sys.stderr.write("Health probe ReadTimeout Exp:%s\n" % str(to))
    except Exception as ex:
        sys.stderr.write("Health probe UnExpected Exp:%s\n" % str(ex))


def check_pid_running(pid):
    if psutil.pid_exists(int(pid)):
       return True
    else:
       return False


if __name__ == "__main__":
    if "liveness-probe" in ','.join(sys.argv):
        pidfile = "/tmp/liveness.pid"  #nosec
    else:
        pidfile = "/tmp/readiness.pid"  #nosec
    data = {}
    if os.path.isfile(pidfile):
        with open(pidfile,'r') as f:
            data = json.load(f)
        if check_pid_running(data['pid']):
            if data['exit_count'] > 1:
                # Third time in, kill the previous process
                os.kill(int(data['pid']), signal.SIGTERM)
            else:
                data['exit_count'] = data['exit_count'] + 1
                with open(pidfile, 'w') as f:
                    json.dump(data, f)
                sys.exit(0)
    data['pid'] = os.getpid()
    data['exit_count'] = 0
    with open(pidfile, 'w') as f:
        json.dump(data, f)

    run_health_check()
