#!/bin/bash

{{/*
Copyright 2019, AT&T Intellectual Property

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

{{- $envAll := . -}}

set -xe

rm /etc/apt/sources.list
tee /etc/apt/sources.list << EOF
{{- $components := include "helm-toolkit.utils.joinListWithSpace" .Values.conf.test.components -}}
{{ range .Values.conf.test.dists }}
deb [ allow-insecure=yes ] {{ tuple "api" "public" "api" $envAll | include "helm-toolkit.endpoints.keystone_endpoint_uri_lookup" }} {{ . }} {{ $components -}}
{{ end }}
EOF

apt-get update
