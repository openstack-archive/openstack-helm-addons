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

#-----------------------------------------------------------------------
# Two ways to invoke this script
#-----------------------------------------------------------------------
# 1. Provide a shaker.conf file listing the shaker configuration params
#    which should go as input to shaker
# 2. Provide the parameters explicitly
#----------------------------------------------------------------------

# (1):
# sudo -H -E su -c 'export SHAKER_CONF_HOST="/tmp/shaker.conf"; \
#                   export CLONE_SHAKER_SCENARIOS="false"; \
#                   export SHAKER_SCENARIOS_REPO="https://git.openstack.org/openstack/shaker"; \
#                   export COPY_SHAKER_REPORTS_ON_HOST="false"; \
#                   cd $CURR_WORK/openstack-helm-addons; ./tools/gate/scripts/090-shaker.sh ${OSH_EXTRA_HELM_ARGS}' ${username}

# (2):
# sudo -H -E su -c 'export OSH_EXT_NET_NAME="public"; \
#                   export OSH_EXT_SUBNET_NAME="public-subnet"; \
#                   export OS_USERNAME="admin"; \
#                   export OS_PASSWORD="password"; \
#                   export OS_AUTH_URL="http://keystone.openstack.svc.cluster.local/v3"; \
#                   export OS_PROJECT_NAME="admin"; \
#                   export OS_REGION_NAME="RegionOne"; \
#                   export OS_PROJECT_ID=""; \
#                   export OS_PROJECT_DOMAIN_NAME="Default"; \
#                   export OS_USER_DOMAIN_NAME="Default"; \
#                   export OS_IDENTITY_API_VERSION=3; \
#                   export EXTERNAL_NETWORK_NAME="public"; \
#                   export SCENARIO="/opt/shaker/shaker/scenarios/openstack/full_l2.yaml"; \
#                   export AVAILABILITY_ZONE="nova"; \
#                   export FLAVOR_ID="shaker-flavor"; \
#                   export IMAGE_NAME="shaker-image"; \
#                   export SERVER_ENDPOINT_IP=""; \
#                   export CLONE_SHAKER_SCENARIOS="false"; \
#                   export SHAKER_SCENARIOS_REPO="https://git.openstack.org/openstack/shaker"; \
#                   export COPY_SHAKER_REPORTS_ON_HOST="false"; \
#                   cd $CURR_WORK/openstack-helm-addons; ./tools/gate/scripts/090-shaker.sh ${OSH_EXTRA_HELM_ARGS}' ${username}

set -xe

: ${OSH_EXT_NET_NAME:="public"}
: ${OSH_EXT_SUBNET_NAME:="public-subnet"}
: ${OSH_EXT_SUBNET:="172.24.4.0/24"}
: ${OSH_BR_EX_ADDR:="172.24.4.1/24"}
: ${OSH_PRIVATE_SUBNET_POOL:="11.0.0.0/8"}
: ${OSH_PRIVATE_SUBNET_POOL_NAME:="shared-default-subnetpool"}
: ${OSH_PRIVATE_SUBNET_POOL_DEF_PREFIX:="24"}
: ${OSH_VM_KEY_STACK:="heat-vm-key"}
: ${OSH_PRIVATE_SUBNET:="11.0.0.0/24"}

# Shaker conf params
: ${OS_USERNAME:="admin"}
: ${OS_PASSWORD:="password"}
: ${OS_AUTH_URL:="http://keystone.openstack.svc.cluster.local/v3"}
: ${OS_PROJECT_NAME:="admin"}
: ${OS_REGION_NAME:="RegionOne"}
: ${OS_USER_DOMAIN_NAME:="Default"}
: ${OS_PROJECT_DOMAIN_NAME:="Default"}
: ${OS_PROJECT_ID:=""}
: ${EXTERNAL_NETWORK_NAME:=$OSH_EXT_NET_NAME}
: ${SCENARIO:="shaker/shaker/scenarios/openstack/full_l2.yaml"}
: ${AVAILABILITY_ZONE:="nova"}
: ${OS_IDENTITY_API_VERSION:="3"}
: ${OS_INTERFACE:="public"}

: ${REPORT_FILE:="shaker-result.html"}
: ${OUTPUT_FILE:="shaker-result.json"}
: ${FLAVOR_ID:="shaker-flavor"}
: ${IMAGE_NAME:="shaker-image"}
: ${SERVER_ENDPOINT_IP:=""}
: ${SERVER_ENDPOINT_INTF:="eth0"}
: ${SHAKER_PORT:=31999}
: ${COMPUTE_NODES:=1}

: ${EXECUTE_TEST:="true"}
: ${DEBUG:="true"}
: ${CLEANUP_ON_ERROR:="true"}
: ${CLONE_SHAKER_SCENARIOS:="false"}
: ${SHAKER_SCENARIOS_REPO:="https://git.openstack.org/openstack/shaker"}
: ${COPY_SHAKER_REPORTS_ON_HOST:="false"}
: ${SHAKER_CONF_HOST:=""}

# DO NOT CHANGE: Change requires update in shaker charts
: ${SHAKER_CONF:="/opt/shaker/shaker.conf"}
: ${SHAKER_DATA:="/opt/shaker/data"}
: ${SHAKER_DATA_HOSTPATH_MOUNT:="/opt/shaker-data"}
: ${SHAKER_DATA_HOSTPATH:="/tmp/shaker-data"}

#NOTE: Pull images and lint chart
: ${OSH_PATH:="../openstack-helm"}
make -C ${OSH_PATH} pull-images shaker

#NOTE: Deploy command
if [ ! -z ${SHAKER_CONF_HOST} ] && [ -f ${SHAKER_CONF_HOST} ]; then
  SERVER_ENDPOINT_IP=`cat ${SHAKER_CONF_HOST} | awk '/server_endpoint/ {print $2}' | cut -f1 -d':'`
  SHAKER_PORT=`cat ${SHAKER_CONF_HOST} | awk '/server_endpoint/ {print $2}' | cut -f2 -d':'`
else
  # Export AUTH variables required by shaker-image-builder utility
  export OS_USERNAME=${OS_USERNAME}
  export OS_PASSWORD=${OS_PASSWORD}
  export OS_AUTH_URL=${OS_AUTH_URL}
  export OS_PROJECT_NAME=${OS_PROJECT_NAME}
  export OS_REGION_NAME=${OS_REGION_NAME}
  export EXTERNAL_NETWORK_NAME=${EXTERNAL_NETWORK_NAME}
  export OS_PROJECT_ID=${OS_PROJECT_ID}

  if [ $OS_IDENTITY_API_VERSION = "3" ]; then
    export OS_PROJECT_DOMAIN_NAME=${OS_PROJECT_DOMAIN_NAME}
    export OS_USER_DOMAIN_NAME=${OS_USER_DOMAIN_NAME}
  else
    export OS_PROJECT_DOMAIN_NAME=
    export OS_USER_DOMAIN_NAME=
  fi

  export stack_exists=`openstack network list | grep ${OSH_EXT_NET_NAME} | awk '{print $4}'`

  if [ -z $stack_exists ]; then
    openstack stack create --wait \
      --parameter network_name=${OSH_EXT_NET_NAME} \
      --parameter physical_network_name=${OSH_EXT_NET_NAME} \
      --parameter subnet_name=${OSH_EXT_SUBNET_NAME} \
      --parameter subnet_cidr=${OSH_EXT_SUBNET} \
      --parameter subnet_gateway=${OSH_BR_EX_ADDR%/*} \
      -t ${OSH_PATH}/tools/gate/files/heat-public-net-deployment.yaml \
      heat-public-net-deployment
  fi

  default_sec_grp_id=`openstack security group list --project ${OS_PROJECT_NAME} | grep default | awk '{split(\$0,a,"|"); print a[2]}'`
  for sg in $default_sec_grp_id
  do
    icmp=`openstack security group rule list $sg | grep icmp | awk '{split(\$0,a,"|"); print a[2]}'`
    if [ "${icmp}" = "" ]; then openstack security group rule create --proto icmp $sg; fi
    shaker=`openstack security group rule list $sg | grep tcp | grep ${SHAKER_PORT} | awk '{split(\$0,a,"|"); print a[2]}'`
    if [ "${shaker}" = "" ]; then openstack security group rule create --proto tcp --dst-port ${SHAKER_PORT} $sg; fi
  done

  IMAGE_NAME=$(openstack image show -f value -c name \
  $(openstack image list -f csv | awk -F ',' '{ print $2 "," $1 }' | \
  grep "${IMAGE_NAME}" | head -1 | awk -F ',' '{ print $2 }' | tr -d '"'))

  if [ -z $IMAGE_NAME ]; then
  # Install shaker to use shaker-image-builder utility
    sudo apt-add-repository "deb http://nova.clouds.archive.ubuntu.com/ubuntu/ trusty multiverse"
    sudo apt-get update
    sudo apt-get -y install python-dev libzmq-dev
    sudo pip install pbr pyshaker

    # Run shaker-image-builder utility to build shaker image
    # For debug mode
    # shaker-image-builder --nocleanup-on-error --debug
    # For debug mode - with disk-image-builder mode
    # shaker-image-builder --nocleanup-on-error --debug --image-builder-mode dib
    shaker-image-builder

    IMAGE_NAME=$(openstack image show -f value -c name \
      $(openstack image list -f csv | awk -F ',' '{ print $2 "," $1 }' | \
      grep "^\"shaker" | head -1 | awk -F ',' '{ print $2 }' | tr -d '"'))
  fi

  if [ $CLONE_SHAKER_SCENARIOS = "true" ]; then
    SHAKER_SCENARIO="${SHAKER_DATA}/${SCENARIO}"
  else
    SHAKER_SCENARIO="/opt/${SCENARIO}"
  fi
fi

#NOTE: Deploy shaker pods
tee /tmp/shaker.yaml << EOF
shaker:
  controller:
    external_ip: ${SERVER_ENDPOINT_IP}
conf:
  script: |
    #!/bin/bash
    set -xe

    # Clone the shaker test-cases
    if [ ${CLONE_SHAKER_SCENARIOS} = "true" ]; then
      cd ${SHAKER_DATA}; git clone $SHAKER_SCENARIOS_REPO; cd -;
    fi

    if [ -z ${SERVER_ENDPOINT_IP} ]; then
      export server_endpoint=\`ip a | grep "global ${SERVER_ENDPOINT_INTF}" | cut -f6 -d' ' | cut -f1 -d'/'\`
    else
      export server_endpoint=${SERVER_ENDPOINT_IP}
    fi

    echo ===========================
    printenv | grep -i os_

    echo ==========  SHAKER CONF PARAMETERS  =================
    cat ${SHAKER_CONF}
    echo =====================================================

    env -i HOME="$HOME" bash -l -c "printenv; shaker --server-endpoint \$server_endpoint:${SHAKER_PORT} --config-file ${SHAKER_CONF}"

    if [ $COPY_SHAKER_REPORTS_ON_HOST = "true" ]; then
      export DATA_FOLDER_NAME=`date +%Y%m%d_%H%M%S`
      mkdir ${SHAKER_DATA_HOSTPATH_MOUNT}/\$DATA_FOLDER_NAME
      echo \$DATA_FOLDER_NAME > ${SHAKER_DATA_HOSTPATH_MOUNT}/latest-shaker-data-name.txt
      declare -a file_extns_arr_to_copy=(html json subunit conf yaml stream)
      for i in "\${file_extns_arr_to_copy[@]}"
      do
        if [ -e ${SHAKER_DATA}/*.\$i ]; then cp -avb ${SHAKER_DATA}/*.\$i ${SHAKER_DATA_HOSTPATH_MOUNT}/\$DATA_FOLDER_NAME/; fi
      done
      cp -avb ${SHAKER_CONF} ${SHAKER_DATA_HOSTPATH_MOUNT}/\$DATA_FOLDER_NAME/
    fi
EOF

if [ -z ${SHAKER_CONF_HOST} ] || [ ! -f ${SHAKER_CONF_HOST} ]; then
tee -a /tmp/shaker.yaml << EOF
  shaker:
    shaker:
      DEFAULT:
        debug: ${DEBUG}
        cleanup_on_error: ${CLEANUP_ON_ERROR}
        scenario_compute_nodes: ${COMPUTE_NODES}
        report: ${SHAKER_DATA}/${REPORT_FILE}
        output: ${SHAKER_DATA}/${OUTPUT_FILE}
        scenario: ${SHAKER_SCENARIO}
        flavor_name: ${FLAVOR_ID}
        external_net: ${EXTERNAL_NETWORK_NAME}
        image_name: ${IMAGE_NAME}
        scenario_availability_zone: ${AVAILABILITY_ZONE}
        os_username: ${OS_USERNAME}
        os_password: ${OS_PASSWORD}
        os_auth_url: ${OS_AUTH_URL}
        os_project_name: ${OS_PROJECT_NAME}
        os_region_name: ${OS_REGION_NAME}
        os_identity_api_version: ${OS_IDENTITY_API_VERSION}
        os_interface: ${OS_INTERFACE}
EOF

if [ $OS_IDENTITY_API_VERSION = "3" ]; then
tee -a /tmp/shaker.yaml << EOF
        os_project_domain_name: ${OS_PROJECT_DOMAIN_NAME}
        os_user_domain_name: ${OS_USER_DOMAIN_NAME}
EOF
fi

else

echo "  shaker:" >> /tmp/shaker.yaml
echo "    shaker:" >> /tmp/shaker.yaml
cp ${SHAKER_CONF_HOST} ${SHAKER_CONF_HOST}.tmp
sed -i -e 's/^/      /' ${SHAKER_CONF_HOST}.tmp
cat ${SHAKER_CONF_HOST}.tmp >> /tmp/shaker.yaml
rm -rf ${SHAKER_CONF_HOST}.tmp

fi

helm upgrade --install shaker ./shaker \
  --namespace=openstack \
  --values=/tmp/shaker.yaml \
  ${OSH_EXTRA_HELM_ARGS} \
  ${OSH_EXTRA_HELM_ARGS_SHAKER}

#NOTE: Wait for deploy
./tools/gate/scripts/wait-for-pods.sh openstack 2400

#NOTE: Validate Deployment info
kubectl get -n openstack jobs --show-all

if [ -n $EXECUTE_TEST ]; then
  helm test shaker --timeout 2700

  if [ $COPY_SHAKER_REPORTS_ON_HOST = "true" ]; then
    shaker_pod_name=`kubectl -n openstack get pods | grep shaker-run-tests | cut -f1 -d' '`
    latest_data_folder=`cat ${SHAKER_DATA_HOSTPATH}/latest-shaker-data-name.txt`
    kubectl -n openstack logs ${shaker_pod_name} > ${SHAKER_DATA_HOSTPATH}/${latest_data_folder}/${shaker_pod_name}.logs
  fi
fi
