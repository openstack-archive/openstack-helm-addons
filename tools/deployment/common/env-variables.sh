#!/bin/bash
#
#  Licensed under the Apache License, Version 2.0 (the "License"); you may
#  not use this file except in compliance with the License. You may obtain
#  a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#  License for the specific language governing permissions and limitations
#  under the License.

export API_ADDR=$(kubectl get endpoints kubernetes -o json | jq -r '.subsets[0].addresses[0].ip')
export API_PORT=$(kubectl get endpoints kubernetes -o json | jq -r '.subsets[0].ports[0].port')
