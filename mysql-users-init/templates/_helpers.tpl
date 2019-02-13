{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a fully qualified cleanup name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cleanup.fullname" -}}
{{- printf "%s-%s" .Release.Name "cleanup" | trunc 63 -}}
{{- end -}}

{{- /*
Read a single optional secret or string from values into an `env` `value:` or
`valueFrom:`, depending on the user-defined content of the value.

Example:
  - name: OS_AUTH_URL
{{ include "mysql_users_secret_env" .Values.auth.url | indent 4 }}

Make sure to change the name of this template when copying to keep it unique,
e.g. chart_name_secret_env.
*/}}
{{- define "mysql_users_init_secret_env" -}}
{{- if eq (kindOf .) "map" -}}
valueFrom:
  secretKeyRef:
    name: "{{ .secret_name }}"
    key: "{{ .secret_key }}"
{{- else -}}
value: "{{ . }}"
{{- end -}}
{{- end -}}
