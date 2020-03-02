#!/bin/bash

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

helm upgrade --install another-sonobuoy sonobuoy \
    --namespace=sonobuoy \
    --set endpoints.identity.namespace=openstack \
    --set manifests.serviceaccount_readonly=true \
    --set conf.publish_results=false
helm test another-sonobuoy
