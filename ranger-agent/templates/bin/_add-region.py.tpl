#!/usr/bin/env python

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

import base64
import json
import os
import requests
import sys
import time


def get_token():
    headers = {'Content-Type': 'application/json'}
    keystone_ep = os.environ['OS_AUTH_URL']
    url = keystone_ep + '/auth/tokens'

    data = {
        "auth": {
            "identity": {
                "methods": [
                    "password"
                ],
                "password": {
                    "user": {
                        "name": os.environ['OS_USERNAME'],
                        "domain": {
                            "name": os.environ['OS_USER_DOMAIN_NAME']
                        },
                        "password": os.environ['OS_PASSWORD']
                    }
                }
            },
            "scope": {
                "project": {
                    "domain": {
                        "name": os.environ['OS_PROJECT_DOMAIN_NAME']
                    },
                    "name": os.environ['OS_PROJECT_NAME']
                }
            }
        }
    }

    try:
        verify = os.environ['CAFILE'] or False
        resp = requests.post(
            url, data=json.dumps(data), headers=headers,
            verify=verify, timeout=120)

        if resp.status_code != 201:
            sys.stderr.write("Failed to get token for region: %s - %s\n" %
                             (resp.status_code, resp.text,))
            sys.exit(0)
        token = resp.headers['x-subject-token']
        return token
    except Exception as exp:
        sys.stderr.write(
            "Exp: Failed to get token for region: %s\n" % str(exp))
        sys.exit(0)


def build_payload():

    try:
        parameters = os.environ['PARAMETERS']

        payload = json.loads(parameters)
        payload['status'] = "functional"
        payload['id'] = os.environ['OS_REGION_NAME']
        payload['name'] = os.environ['OS_REGION_NAME']
        payload['vlcpName'] = os.environ['OS_REGION_NAME']

        payload['address'] = {
            "street": os.environ['LOCATION_ADDRESS'],
            "city": os.environ['LOCATION_NAME'],
            "state": os.environ['LOCATION_STATE'],
            "zip": os.environ['LOCATION_ZIP'],
            "country": os.environ['LOCATION_COUNTRY']}

        payload['CLLI'] = os.environ['LOCATION_ID']
        payload['locationType'] = os.environ['LOCATION_ID']

        description = "Automatic creation of Region %s" % os.environ['OS_REGION_NAME']
        payload['description'] = description

        payload['endpoints'] = [
            {"publicURL": os.environ['DASHBOARD_ENDPOINT'],
             "type": "dashboard"},
            {"publicURL": os.environ['IDENTITY_ENDPOINT'],
             "type": "identity"},
            {"publicURL": os.environ['ORD_ENDPOINT'],
             "type": "ord"}]

        return json.dumps(payload)

    except Exception as exp:
        sys.stderr.write("Exp: Error building payload: %s\n" % str(exp))
        sys.exit(0)


def notify_ranger_create_region(payload):
    headers = {}
    headers = {'Content-Type': 'application/json'}
    headers['X-Auth-Token'] = get_token()
    payload = build_payload()

    url = os.environ['RMS_ENDPOINT']

    done = False
    # Retry up to 3 times
    for i in range(3):
        time.sleep(15) if i != 0 else None
        try:
            resp = requests.post(
                url, data=payload, headers=headers, timeout=120)

            if resp.status_code == 409:
                sys.stdout.write("Region already existed\n")
                done = True
                break
            elif resp.status_code == 201:
                result = resp.json()
                sys.stdout.write("Region created successfully: %s\n" % result)
                done = True
                break
            else:
                sys.stderr.write("Failed to create region: %s - %s\n" %
                                 (resp.status_code, resp.text,))
                continue

        except requests.exceptions.ConnectionError as ce:
            sys.stderr.write("ConnectionError Exp: %s\n" % str(ce))
            continue
        except requests.exceptions.ReadTimeout as to:
            sys.stderr.write("ReadTimeout Exp: %s\n" % str(to))
            continue
        except Exception as ex:
            sys.stderr.write("Unknown Exp: %s\n" % str(ex))
            continue

    return done


if __name__ == "__main__":
    payload = build_payload()
    sys.stdout.write("Json dumps: %s\n" % payload)
    sys.stdout.flush()

    duration = int(os.environ['RETRY_DURATION_MINUTES'])
    interval = int(os.environ['RETRY_INTERVAL_MINUTES'])
    retries = duration//interval

    for retry in range(retries):
        if notify_ranger_create_region(payload):
            break
        else:
            sys.stderr.flush()
            time.sleep(interval*60)
