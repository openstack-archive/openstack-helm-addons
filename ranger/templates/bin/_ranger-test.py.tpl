# Copyright 2020 The Openstack-Helm Authors.
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

Usage example for Ranger-helm-test:
# python ranger-test.py

"""

import os
import requests
import sys

def run_service_verification():
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
            url = os.environ[service]
            if not url.endswith('/'):
                url = url + '/'
            response = requests.get(url, timeout=100)
            if response.status_code == 200 or response.status_code == 404:
                results[service] = 'passed'

        except requests.exceptions.ConnectionError as ce:
            sys.stderr.write("Ranger service ConnectionError Exp:%s\n" % str(ce))
        except requests.exceptions.ReadTimeout as to:
            sys.stderr.write("Ranger service ReadTimeout Exp:%s\n" % str(to))
        except Exception as ex:
            sys.stderr.write("Ranger service UnExpected Exp:%s\n" % str(ex))

    for value in results.values():
        if value == 'failed':
            sys.stderr.write("Ranger service detects problem "
                             ": %s\n" % results)
            sys.exit(1)


if __name__ == "__main__":
    run_service_verification()
