# this is minimalist db.properties file for running artifactory via
# helm talking to mysql
#
# it should be made available to the artifactory user and writable as
# it will be updated with an encrypted password

type=mysql
driver=com.mysql.jdbc.Driver
{{ if .Values.endpoints.oslo_db.namespace }}
# known namespace, using fqdn
url=jdbc:mysql://{{- .Values.endpoints.oslo_db.hosts.default -}}.{{- .Values.endpoints.oslo_db.namespace -}}.svc.cluster.local:{{ tuple "oslo_db" "internal" "mysql" . | include "helm-toolkit.endpoints.endpoint_port_lookup" }}{{- .Values.endpoints.oslo_db.path -}}?characterEncoding=UTF-8&elideSetAutoCommits=true
{{ else }}
# namespace not given, do not not use fqdn
url=jdbc:mysql://{{- .Values.endpoints.oslo_db.hosts.default -}}:{{ tuple "oslo_db" "internal" "mysql" . | include "helm-toolkit.endpoints.endpoint_port_lookup" }}{{- .Values.endpoints.oslo_db.path -}}?characterEncoding=UTF-8&elideSetAutoCommits=true
{{ end }}
username={{ .Values.endpoints.oslo_db.auth.artifactory.username }}
password={{ .Values.endpoints.oslo_db.auth.artifactory.password }}
