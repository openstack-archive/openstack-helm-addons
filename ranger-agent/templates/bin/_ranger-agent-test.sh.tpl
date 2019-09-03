#!/bin/bash

{{/*
Copyright 2017 The Openstack-Helm Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

set -ex

# Come up with a ranger agent payload
region="${REGION_NAME}"
url="${RANGER_SERVICE_URL}"
expected_on_execution="${END_STATUS_KEY}"
UUID=$(python -c 'import uuid; print uuid.uuid1()')

PAYLOAD="{\"ord-notifier\":{
    \"request-id\":\"$UUID\",
    \"resource-id\":\"$UUID\",
    \"resource-type\":\"flavor\",
    \"resource-template-version\":\"1\",
    \"resource-template-name\":\"sanity-test.yaml\",
    \"resource-template-type\":\"hot\",
    \"operation\":\"create\",
    \"region\":\"$region\"
    }
}"

function assertContains()
{
    expected=$1
    msg=$2

    if echo "$msg" | grep -q "$expected"; then
      echo "***TEST IS PASSED: EXPECTED=$expected is in Responce"
    else
      echo "***FAILED: EXPECTED=$expected in Responce"
      exit 1
    fi
}

request_submit_response="$(curl -i -X POST -d "${PAYLOAD}"  $url --header "Content-type:application/json")"
expected_on_request="Submitted"

assertContains "${expected_on_request}" "${request_submit_response}"

# Ranger agent support pull or push both model.
# once request submitted openstack take some time to synchronize.
# we are pulling status for testing purpose by sleeping thread for 15 sec
sleep 15

resource_status_from_engine="$(curl -s "$url?Id=$UUID")"
assertContains "${expected_on_execution}" "$resource_status_from_engine"
