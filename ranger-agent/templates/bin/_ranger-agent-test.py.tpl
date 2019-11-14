#!/usr/bin/env python

import base64
import os
import json
import requests
import sys
import uuid
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
        resp = requests.post(url, data=json.dumps(data), headers=headers)

        if resp.status_code != 201:
            sys.stderr.write("Failed to get token for region\n")
            sys.exit(1)
        token = resp.headers['x-subject-token']
        return token
    except Exception as exp:
        sys.stderr.write(
            "Exp: Failed to get token for region: %s\n" % str(exp))
        sys.exit(1)


def notify_ranger_agent_api(uuid):
    """ Send notification message to Ranger-agent-api. """
    region = os.environ['OS_REGION_NAME']
    url = os.environ['RANGER_SERVICE_URL']

    # get token for region and send to ranger-agent-api
    headers = {}
    headers['X-Auth-Token'] = get_token()

    # Prepare the request body
    data_to_send = {
        'ord-notifier': {
            'request-id': uuid,
            'resource-id': uuid,
            'resource-type': 'flavor',
            'resource-template-version': '1',
            'resource-template-name': 'sanity-test.yaml',
            'resource-template-type': 'hot',
            'operation': 'create',
            'region': region
            }
        }

    invalid_template_data = 'template: heat_template_version: 2020-01-01'
    files = {
        'json': (None, json.dumps(data_to_send), 'application/json'),
        'file': ('heat_template',
                 base64.b64encode(invalid_template_data.encode()),
                 'application/yaml')}

    exit_code = 1
    # Retry up to 5 times
    for i in range(5):
        time.sleep(15)
        try:
            resp = requests.post('%s/v1/ord/ord_notifier' % (url),
                                 files=files,
                                 headers=headers)
            if resp.status_code != 200:
                message = 'failure respond code [%d] received.' % (
                    resp.status_code)
                sys.stderr.write("ORD notification failed: %s\n" % message)
                continue
            else:
                ord_status = resp.json()['ord-notifier-response']['status']
                if ord_status == 'Submitted':
                    sys.stderr.write("ORD notification completed.\n")
                    exit_code = 0
                    break
                else:
                    sys.stderr.write("Unexpected ord status: %s\n" %
                                     ord_status)
                    continue
        except Exception as exp:
            sys.stderr.write(
                "Exp: Failed to post resource: %s\n" % str(exp))
            continue

    if exit_code:
        sys.exit(exit_code)


def validate_resource_status(uuid):
    url = os.environ['RANGER_SERVICE_URL']
    expected_code = os.environ['END_STATUS_KEY']
    exit_code = 1

    # Retry up to 5 times
    for i in range(5):
        time.sleep(15)
        try:
            resp = requests.get('%s/v1/ord/ord_notifier?Id=%s' % (url, uuid))
            if resp.status_code != 200:
                sys.stderr.write("Unexpected status code received: %s\n" %
                                 resp.status_code)
                continue
            else:
                ord_error = resp.json()['rds-listener']['error-code']
                if ord_error == expected_code:
                    sys.stderr.write("Expected error code received: %s\n" %
                                     ord_error)
                    exit_code = 0
                    break
                else:
                    sys.stderr.write("Unexpected error code received: %s\n" %
                                     ord_error)
                    continue

        except Exception as exp:
            sys.stderr.write(
                "Exp: Failed to get resource status: %s\n" % str(exp))
            continue

    sys.exit(exit_code)


if __name__ == "__main__":
    test_uuid = uuid.uuid1().hex
    notify_ranger_agent_api(test_uuid)
    validate_resource_status(test_uuid)
