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

# fqdn
{{- define "util.region"}}cluster{{- end}}
{{- define "util.tld"}}local{{- end}}

{{- define "util.fqdn" -}}
{{- $fqdn := .Release.Namespace -}}
{{- if .Values.endpoints.fqdn -}}
{{- $fqdn := .Values.endpoints.fqdn -}}
{{- end -}}
{{- $fqdn -}}
{{- end -}}

#-----------------------------------------
# hosts
#-----------------------------------------

# infrastructure services
{{- define "util.postgresql_host"}}postgresql.{{.Release.Namespace}}.svc.{{ include "util.region" . }}.{{ include "util.tld" . }}{{- end}}


{{- define "util.joinListWithComma" -}}
{{ range $k, $v := . }}{{ if $k }},{{ end }}{{ $v }}{{ end }}
{{- end -}}

{{- define "util.template" -}}
{{- $name := index . 0 -}}
{{- $context := index . 1 -}}
{{- $v:= $context.Template.Name | split "/" -}}
{{- $n := len $v -}}
{{- $last := sub $n 1 | printf "_%d" | index $v -}}
{{- $wtf := $context.Template.Name | replace $last $name -}}
{{ include $wtf $context }}
{{- end -}}

{{- define "util.hash" -}}
{{- $name := index . 0 -}}
{{- $context := index . 1 -}}
{{- $v:= $context.Template.Name | split "/" -}}
{{- $n := len $v -}}
{{- $last := sub $n 1 | printf "_%d" | index $v -}}
{{- $wtf := $context.Template.Name | replace $last $name -}}
{{- include $wtf $context | sha256sum | quote -}}
{{- end -}}
