#!/bin/bash

{{/*
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

COMMAND="${@:-start}"

function start () {

    if [[ ${SERVICE_TYPE} = "uuid" ]]; then
      exec ranger-uuidgen
    fi
    if [[ ${SERVICE_TYPE} = "audit" ]]; then
      exec ranger-audit
    fi
    if [[ ${SERVICE_TYPE} = "rms" ]]; then
      exec ranger-rms
    fi
    if [[ ${SERVICE_TYPE} = "cms" ]]; then
      exec ranger-cms
    fi
    if [[ ${SERVICE_TYPE} = "ims" ]]; then
      exec ranger-ims
    fi
    if [[ ${SERVICE_TYPE} = "fms" ]]; then
      exec ranger-fms
    fi
}

function stop() {
  kill -TERM 1
}

$COMMAND
