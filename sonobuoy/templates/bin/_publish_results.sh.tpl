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

set -xe

while [ "$(ls -l $RESULTS_DIR/*.tar.gz | wc -l)" -eq 0 ]; do
  sleep 5
done

file_name=$(ls $RESULTS_DIR/*.tar.gz | xargs -n1 basename)
prefixed_file_name={{ .Values.conf.swift.object_name_prefix }}$file_name

openstack container create {{ .Values.conf.swift.container_name }}
openstack container show {{ .Values.conf.swift.container_name }}

openstack object create --name $prefixed_file_name {{ .Values.conf.swift.container_name }} $RESULTS_DIR/$file_name
openstack object show {{ .Values.conf.swift.container_name }} $prefixed_file_name

swift post {{ .Values.conf.swift.container_name }} $prefixed_file_name -H \"X-Delete-After:{{ .Values.conf.swift.delete_objects_after_seconds }}\"

# NOTE(aw442m): Delete results after publishing to avoid collisions when using host path
if [[ ! -z "${RESULTS_DIR}" ]]; then
  rm "${RESULTS_DIR}"/"${file_name}"
fi
