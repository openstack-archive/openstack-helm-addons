set -xe

#NOTE: Deploy command

#NOTE: override file
tee /tmp/ranger-agent.yaml << EOF
conf:
  ranger_agent:
    DEFAULT:
      enable_rds_callback_check: False
  ssh:
    ssh_key: null
    ssh_config: null
dependencies:
  static:
    api:
      jobs:
        - ranger-agent-db-sync
        - ranger-agent-ks-user
        - ranger-agent-ks-endpoints
        - ranger-agent-rabbit-init
      services:
        - service: oslo_db
          endpoint: internal
    engine:
      jobs:
        - ranger-agent-db-sync
        - ranger-agent-ks-user
        - ranger-agent-rabbit-init
      services:
        - service: oslo_db
          endpoint: internal
        - service: identity
          endpoint: internal
    db_init:
      services:
        - service: oslo_db
          endpoint: internal
    db_sync:
      jobs:
        - ranger-agent-db-init
      services:
        - service: oslo_db
          endpoint: internal
    db_drop:
      services:
        - service: oslo_db
          endpoint: internal
    ks_user:
      services:
        - service: identity
          endpoint: internal
    ks_service:
      services:
        - service: identity
          endpoint: internal
    ks_endpoints:
      jobs:
        - ranger-agent-ks-service
      services:
        - service: identity
          endpoint: internal
    rabbit_init:
      services:
        - service: oslo_messaging
          endpoint: internal
    image_repo_sync:
      services:
        - endpoint: internal
          service: local_image_registry
EOF

helm upgrade --install ranger-agent ./ranger-agent \
  --namespace=openstack \
  --values=/tmp/ranger-agent.yaml

#NOTE: Wait for deploy
./tools/gate/scripts/wait-for-pods.sh openstack
