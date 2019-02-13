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
Create a fully qualified agent name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "agent.fullname" -}}
{{- printf "%s-%s" .Release.Name "agent" | trunc 63 -}}
{{- end -}}

{{/*
Create a fully qualified agent name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "aggregator.fullname" -}}
{{- printf "%s-%s" .Release.Name "aggregator" | trunc 63 -}}
{{- end -}}

{{/*
Create a fully qualified api name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "api.fullname" -}}
{{- printf "%s-%s" .Release.Name "api" | trunc 63 -}}
{{- end -}}

{{/*
Create a fully qualified forwarder name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "forwarder.fullname" -}}
{{- printf "%s-%s" .Release.Name "forwarder" | trunc 63 -}}
{{- end -}}

{{/*
Create a fully qualified grafana name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "grafana.fullname" -}}
{{- printf "%s-%s" .Release.Name "grafana" | trunc 63 -}}
{{- end -}}

{{/*
Create a fully qualified kafka name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "kafka.fullname" -}}
{{- printf "%s-%s" .Release.Name "kafka" | trunc 63 -}}
{{- end -}}

{{/*
Create a fully qualified keystone name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "keystone.fullname" -}}
{{- printf "%s-%s" .Release.Name "keystone" | trunc 63 -}}
{{- end -}}

{{/*
Create a fully qualified notification name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "notification.fullname" -}}
{{- printf "%s-%s" .Release.Name "notification" | trunc 63 -}}
{{- end -}}

{{/*
Create a fully qualified persister name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "persister.fullname" -}}
{{- printf "%s-%s" .Release.Name "persister" | trunc 63 -}}
{{- end -}}

{{/*
Create a fully qualified storm-supervisor name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "thresh.fullname" -}}
{{- printf "%s-%s" .Release.Name "thresh" | trunc 63 -}}
{{- end -}}

{{/*
Create a fully qualified zookeeper name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "zookeeper.fullname" -}}
{{- printf "%s-%s" .Release.Name "zookeeper" | trunc 63 -}}
{{- end -}}

{{/*
Create a fully qualified client name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "client.fullname" -}}
{{- printf "%s-%s" .Release.Name "client" | trunc 63 -}}
{{- end -}}

{{/*
Create a fully qualified cleanup name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cleanup.fullname" -}}
{{- printf "%s-%s" .Release.Name "cleanup" | trunc 63 -}}
{{- end -}}

{{/*
Create a fully qualified alarms name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "alarms.fullname" -}}
{{- printf "%s-%s" .Release.Name "alarms" | trunc 63 -}}
{{- end -}}

{{/*
Create a fully qualified tempest test name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "tempest_tests.fullname" -}}
{{- printf "%s-%s" .Release.Name "tempest-tests" | trunc 63 -}}
{{- end -}}

{{/*
Create a fully qualified smoke tests name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "smoke_tests.fullname" -}}
{{- printf "%s-%s" .Release.Name "smoke-tests" | trunc 63 -}}
{{- end -}}

{{/*
Create a fully qualified memcached name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "memcached.fullname" -}}
{{- printf "%s-%s" .Release.Name "memcached" | trunc 63 -}}
{{- end -}}

{{/*
Create a fully qualified alarm definition controller name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "alarm_definition_controller.fullname" -}}
{{- printf "%s-%s" .Release.Name "adc" | trunc 63 -}}
{{- end -}}
