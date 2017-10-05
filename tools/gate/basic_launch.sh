#!/bin/bash
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
set -ex

source ${WORK_DIR}/tools/gate/funcs/helm.sh
source ${WORK_DIR}/tools/gate/funcs/kube.sh

helm_build

helm search

helm install --name=kibana local/kibana --namespace=kube-system

kube_wait_for_pods kube-system 600

# todo(srwilkers): implement helm tests for postgresql
#helm_test_deployment postgresql openstack

helm install --name=elasticsearch local/elasticsearch --namespace=kube-system \
  --set conf.elasticsearch.bootstrap.memory_lock=false

helm install --name=fluentd local/fluentd --namespace=kube-system

kube_wait_for_pods kube-system 600

helm_test_deployment elasticsearch kube-system
helm_test_deployment fluentd kube-system
