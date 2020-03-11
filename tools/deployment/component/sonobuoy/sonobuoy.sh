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

helm dependency update sonobuoy
helm upgrade --install sonobuoy sonobuoy \
    --namespace=heptio-sonobuoy \
    --set endpoints.identity.namespace=openstack \
    --set manifests.serviceaccount_readonly=true
helm test sonobuoy

# test that the readonly service account CANNOT perform pod/exec in any namespaces
for namespace in $(kubectl get namespaces --no-header | awk '{print $1}'); do
  if kubectl auth can-i create pods \
    --subresource=exec \
    --as=system:serviceaccount:heptio-sonobuoy:heptio-sonobuoy-sonobuoy-readonly-serviceaccount \
    --namespace="$namespace" ; then
    echo "ERROR: should be able to perform pods/exec in $namespace namespace" >&2
    exit 1
  fi
done

# exec namespace is needed to setup Role for pod/exec for readonly-serviceaccount
kubectl create namespace exec

helm upgrade --install another-sonobuoy sonobuoy \
    --namespace=sonobuoy \
    --set endpoints.identity.namespace=openstack \
    --set manifests.serviceaccount_readonly=true \
    --set manifests.serviceaccount_readonly_exec=true \
    --set conf.exec_role_namespace=exec \
    --set conf.publish_results=false
helm test another-sonobuoy

# test that the readonly service account can perform pod/exec in exec namespace
if ! kubectl auth can-i create pods \
  --subresource=exec \
  --as=system:serviceaccount:sonobuoy:sonobuoy-sonobuoy-readonly-serviceaccount \
  --namespace=exec ; then
  echo "ERROR: should be able to perform pods/exec in exec namespace" >&2
  exit 1
fi

# test that the readonly service account CANNOT perform pod/exec in other namespaces
for namespace in $(kubectl get namespaces --no-header | awk '$1 != "default" {print $1}'); do
  if kubectl auth can-i create pods \
    --subresource=exec \
    --as=system:serviceaccount:sonobuoy:sonobuoy-sonobuoy-readonly-serviceaccount \
    --namespace="$namespace" ; then
    echo "ERROR: should be able to perform pods/exec in $namespace namespace" >&2
    exit 1
  fi
done
