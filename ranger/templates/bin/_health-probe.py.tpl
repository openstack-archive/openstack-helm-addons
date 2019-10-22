# Copyright 2019 The Openstack-Helm Authors.
#
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

import requests
import sys

from oslo_config import cfg
from oslo_log import log

try:
    from configparser import ConfigParser
except ImportError:
    from ConfigParser import ConfigParser


def run_health_check():
    cfg.CONF(sys.argv[1:])
    log.logging.basicConfig(level=log.ERROR)

    config = ConfigParser()
    config.read(cfg.CONF.config_file)

    services = ['audit', 'cms', 'fms', 'ims', 'rds', 'rms', 'uuid']
    results = {'audit': 'failed',
               'cms': 'failed',
               'fms': 'failed',
               'ims': 'failed',
               'rds': 'failed',
               'rms': 'failed',
               'uuid': 'failed'}

    for service in services:
        try:
            port = config.get(service, 'port')
            url = "http://localhost:{}".format(port)
            response = requests.get(url, timeout=10)
            if response.status_code == 200 or response.status_code == 404:
                results[service] = 'passed'

        except requests.exceptions.ConnectionError as ce:
            sys.stderr.write("Health probe ConnectionError Exp:%s\n" % str(ce))
        except requests.exceptions.ReadTimeout as to:
            sys.stderr.write("Health probe ReadTimeout Exp:%s\n" % str(to))
        except Exception as ex:
            sys.stderr.write("Health probe UnExpected Exp:%s\n" % str(ex))

    for value in results.values():
        if value == 'failed':
            sys.stderr.write("Health probe detects problem "
                             ": %s\n" % results)
            sys.exit(1)


if __name__ == "__main__":
    run_health_check()
