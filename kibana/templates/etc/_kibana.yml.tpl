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

# Kibana is served by a back end server. This setting specifies the port to use.
server.port: {{ .Values.network.kibana.port }}

# Specifies the address to which the Kibana server will bind. IP addresses and host names are both valid values.
# The default is 'localhost', which usually means remote machines will not be able to connect.
# To allow connections from remote users, set this parameter to a non-loopback address.
server.host: {{ .Values.conf.server.host | default "localhost" }}

# The maximum payload size in bytes for incoming server requests.
server.maxPayloadBytes: {{ .Values.conf.server.max_payload_bytes | default 1048576 }}

# The URL of the Elasticsearch instance to use for all your queries.
elasticsearch.url: {{ tuple "log_database" "default" "client" . | include "helm-toolkit.endpoints.keystone_endpoint_uri_lookup" }}

# When this setting's value is true Kibana uses the hostname specified in the server.host
# setting. When the value of this setting is false, Kibana uses the hostname of the host
# that connects to this Kibana instance.
elasticsearch.preserveHost: {{ .Values.conf.elasticsearch.preserve_host | default true }}

# Kibana uses an index in Elasticsearch to store saved searches, visualizations and
# dashboards. Kibana creates a new index if the index doesn't already exist.
kibana.index: {{ .Values.conf.kibana.index | default ".kibana" }}

# The default application to load.
kibana.defaultAppId: {{ .Values.conf.kibana.default_app_id | default "discover" }}

# If your Elasticsearch is protected with basic authentication, these settings provide
# the username and password that the Kibana server uses to perform maintenance on the Kibana
# index at startup. Your Kibana users still need to authenticate with Elasticsearch, which
# is proxied through the Kibana server.
{{ if .Values.conf.elasticsearch.auth.enabled }}
elasticsearch.username: {{ .Values.conf.elasticsearch.username }}
elasticsearch.password: {{ .Values.conf.elasticsearch.password }}
{{ end }}

# Enables SSL and paths to the PEM-format SSL certificate and SSL key files, respectively.
# These settings enable SSL for outgoing requests from the Kibana server to the browser.
{{ if .Values.conf.server.ssl.enabled }}
server.ssl.enabled: {{ .Values.conf.server.ssl.enabled }}
server.ssl.certificate: {{ .Values.conf.server.ssl.certificate }}
server.ssl.key: {{ .Values.conf.server.ssl.key }}
{{ end }}

# Optional settings that provide the paths to the PEM-format SSL certificate and key files.
# These files validate that your Elasticsearch backend uses the same key files.
{{ if .Values.conf.elasticsearch.ssl.enabled }}
elasticsearch.ssl.certificate: {{ .Values.conf.elasticsearch.ssl.certificate }}
elasticsearch.ssl.key: {{ .Values.conf.elasticsearch.ssl.key }}

# Optional setting that enables you to specify a path to the PEM file for the certificate
# authority for your Elasticsearch instance.
# example: elasticsearch.ssl.certificateAuthorities: [ "/path/to/your/CA.pem" ]
elasticsearch.ssl.certificateAuthorities: {{ .Values.conf.elasticsearch.ssl.certificate_authorities }}

# To disregard the validity of SSL certificates, change this setting's value to 'none'.
elasticsearch.ssl.verificationMode: {{ .Values.conf.elasticsearch.ssl.verification_mode }}
{{ end }}

# Time in milliseconds to wait for Elasticsearch to respond to pings. Defaults to the value of
# the elasticsearch.requestTimeout setting.
elasticsearch.pingTimeout: {{ .Values.conf.elasticsearch.ping_timeout }}

# Time in milliseconds to wait for responses from the back end or Elasticsearch. This value
# must be a positive integer.
elasticsearch.requestTimeout: {{ .Values.conf.elasticsearch.request_timeout }}

# List of Kibana client-side headers to send to Elasticsearch. To send *no* client-side
# headers, set this value to [] (an empty list).
# example: elasticsearch.requestHeadersWhitelist: [ authorization ]
elasticsearch.requestHeadersWhitelist: {{ .Values.conf.elasticsearch.request_headers_whitelist }}

# Header names and values that are sent to Elasticsearch. Any custom headers cannot be overwritten
# by client-side headers, regardless of the elasticsearch.requestHeadersWhitelist confuration.
elasticsearch.customHeaders: {{ .Values.conf.elasticsearch.custom_headers }}

# Time in milliseconds for Elasticsearch to wait for responses from shards. Set to 0 to disable.
elasticsearch.shardTimeout: {{ .Values.conf.elasticsearch.shard_timeout }}

# Time in milliseconds to wait for Elasticsearch at Kibana startup before retrying.
elasticsearch.startupTimeout: {{ .Values.conf.elasticsearch.startup_timeout }}

# Enables you specify a file where Kibana stores log output.
logging.dest: "stdout"

# Set the value of this setting to true to suppress all logging output.
logging.silent: {{ .Values.conf.logging.silent }}

# Set the value of this setting to true to suppress all logging output other than error messages.
logging.quiet: {{ .Values.conf.logging.quiet }}

# Set the value of this setting to true to log all events, including system usage information
# and all requests.
logging.verbose: {{ .Values.conf.logging.verbose }}

# Set the interval in milliseconds to sample system and process performance
# metrics. Minimum is 100ms. Defaults to 5000.
ops.interval: {{ .Values.conf.ops.interval }}

# The default locale. This locale can be used in certain circumstances to substitute any missing
# translations.
i18n.defaultLocale: {{ .Values.conf.il8n.default_locale }}
