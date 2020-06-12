#!/bin/bash

# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
set -xe

#NOTE: Deploy command

#NOTE: override file
tee /tmp/ranger-agent.yaml << EOF
conf:
  ranger_agent:
    DEFAULT:
      enable_rds_callback_check: false
      enable_heat_health_check: false
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

#NOTE: Get the over-rides to use
: ${OSH_EXTRA_HELM_ARGS_RANGER_AGENT:="$(./tools/deployment/common/get-values-overrides.sh ranger-agent)"}

#NOTE: Deploy command
: ${OSH_EXTRA_HELM_ARGS:=""}

helm upgrade --install ranger-agent ./ranger-agent \
  --namespace=openstack \
  --values=/tmp/ranger-agent.yaml \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_RANGER_AGENT}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

helm status ranger-agent
helm test ranger-agent --timeout 900