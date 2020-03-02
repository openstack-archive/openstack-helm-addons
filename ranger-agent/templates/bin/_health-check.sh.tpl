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
function apireadiness () {
  IS_SERVICE_RUNNING=$(ps aux|awk '$12 == "/usr/local/bin/ranger-agent-api" {print $8}')

  if [ ! -z "$IS_SERVICE_RUNNING" -a "$IS_SERVICE_RUNNING"!=" " ]; then
    exit 0
  else
    exit 1
  fi

}
function enginereadiness () {
  IS_SERVICE_RUNNING=$(ps aux|awk '$12 == "/usr/local/bin/ranger-agent-engine" {print $8}')

  if [ ! -z "$IS_SERVICE_RUNNING" -a "$IS_SERVICE_RUNNING"!=" " ]; then
    exit 0
  else
    exit 1
  fi

}
function engineliveness () {
  enginereadiness
}
