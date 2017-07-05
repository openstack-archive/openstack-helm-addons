
cluster:
  name: {{ .Values.conf.elasticsearch.cluster.name }}

node:
  master: ${NODE_MASTER}
  data: ${NODE_DATA}
  name: ${NODE_NAME}

network.host: {{ .Values.conf.elasticsearch.network.host }}

path:
  data: {{ .Values.conf.elasticsearch.path.data }}
  logs: {{ .Values.conf.elasticsearch.path.logs }}

bootstrap:
  memory_lock: {{ .Values.conf.elasticsearch.bootstrap.memory_lock }}

http:
  enabled: ${HTTP_ENABLE}
  compression: true

discovery:
  zen:
    ping.unicast.hosts: ${DISCOVERY_SERVICE}
    minimum_master_nodes: {{ .Values.conf.elasticsearch.zen.min_masters }}
