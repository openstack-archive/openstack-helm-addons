#!/bin/bash

# Copyright 2017 The Openstack-Helm Authors.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

set -xe

#NOTE: Lint and package chart
: ${OSH_INFRA_PATH:="../openstack-helm-infra"}
make -C ${OSH_INFRA_PATH} ceph-provisioners

#NOTE: Deploy command
: ${OSH_EXTRA_HELM_ARGS:=""}
CEPH_PUBLIC_NETWORK="$($OSH_INFRA_PATH/tools/deployment/multinode/kube-node-subnet.sh)"
CEPH_CLUSTER_NETWORK="$($OSH_INFRA_PATH/tools/deployment/multinode/kube-node-subnet.sh)"
tee /tmp/ceph-openstack-config.yaml <<EOF
endpoints:
  identity:
    namespace: openstack
  object_store:
    namespace: ceph
  ceph_mon:
    namespace: ceph
network:
  public: ${CEPH_PUBLIC_NETWORK}
  cluster: ${CEPH_CLUSTER_NETWORK}
deployment:
  storage_secrets: false
  ceph: false
  rbd_provisioner: false
  cephfs_provisioner: false
  client_secrets: true
  rgw_keystone_user_and_endpoints: false
bootstrap:
  enabled: false
conf:
  rgw_ks:
    enabled: true
EOF
helm upgrade --install ceph-openstack-config ${OSH_INFRA_PATH}/ceph-provisioners \
  --namespace=openstack \
  --values=/tmp/ceph-openstack-config.yaml \
  ${OSH_EXTRA_HELM_ARGS} \
  ${OSH_EXTRA_HELM_ARGS_CEPH_NS_ACTIVATE}

#NOTE: Wait for deploy
./tools/gate/scripts/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
kubectl get -n openstack jobs
kubectl get -n openstack secrets
kubectl get -n openstack configmaps
