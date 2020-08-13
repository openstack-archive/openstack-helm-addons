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

# NOTE: Get the over-rides to use
export HELM_CHART_ROOT_PATH="${HELM_CHART_ROOT_PATH:="${OSH_PATH:="../openstack-helm"}"}"
: ${OSH_EXTRA_HELM_ARGS_KEYSTONE:="$(./tools/deployment/common/get-values-overrides.sh keystone)"}

#NOTE: Lint and package chart
make -C ${HELM_CHART_ROOT_PATH} keystone

#NOTE: Deploy command
: ${OSH_EXTRA_HELM_ARGS:=""}
helm upgrade --install keystone ${HELM_CHART_ROOT_PATH}/keystone \
    --namespace=openstack \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_KEYSTONE}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
helm status keystone
export OS_CLOUD=openstack_helm
sleep 30 #NOTE(portdirect): Wait for ingress controller to update rules and restart Nginx
openstack endpoint list

FEATURE_GATE="tls"; if [[ ${FEATURE_GATES//,/ } =~ (^|[[:space:]])${FEATURE_GATE}($|[[:space:]]) ]]; then
  curl --cacert /etc/openstack-helm/certs/ca/ca.pem -L https://keystone.openstack.svc.cluster.local
  curl --cacert /etc/openstack-helm/certs/ca/ca.pem -L https://keystone-api.openstack.svc.cluster.local:5000
fi
