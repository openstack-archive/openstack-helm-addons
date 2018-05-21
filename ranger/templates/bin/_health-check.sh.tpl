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

COMMAND="${@:-allservicesreadiness}"

function allservicesreadiness () {
  allservicesliveness
}

function allservicesliveness () {
  IS_CMS_RUNNING=$(ps aux|awk '$12 == "/usr/local/bin/ranger-cms" {print $8}')
  IS_RMS_RUNNING=$(ps aux|awk '$12 == "/usr/local/bin/ranger-rms" {print $8}')
  IS_IMS_RUNNING=$(ps aux|awk '$12 == "/usr/local/bin/ranger-ims" {print $8}')
  IS_FMS_RUNNING=$(ps aux|awk '$12 == "/usr/local/bin/ranger-fms" {print $8}')
  IS_RDS_RUNNING=$(ps aux|awk '$12 == "/usr/local/bin/ranger-rds" {print $8}')
  IS_UUID_RUNNING=$(ps aux|awk '$12 == "/usr/local/bin/ranger-uuidgen" {print $8}')
  IS_AUDIT_RUNNING=$(ps aux|awk '$12 == "/usr/local/bin/ranger-audit" {print $8}')

  for process in "$IS_UUID_RUNNING" "$IS_AUDIT_RUNNING" "$IS_IMS_RUNNING" "$IS_RMS_RUNNING" "$IS_CMS_RUNNING" "$IS_RDS_RUNNING" "$IS_FMS_RUNNING"; do
    if [ -z "$process" ]; then
      exit 1
    fi
  done

  exit 0
}
$COMMAND