#!/bin/bash

{{/*
Copyright 2017 The Openstack-Helm Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

set -ex

COMMAND="${@:-start}"

function start () {

if [ -n "${SSH_KEY}" ] && [ -n "${SSH_KEY_CONFIGURATION}" ];then
    if [[ $(stat -c %F ${USER_HOME}/.ssh) = "directory" ]]; then
      rm -fr ${USER_HOME}/.ssh
    fi

    mkdir -p ${USER_HOME}/.ssh
    echo -e "${SSH_KEY}" >>${USER_HOME}/.ssh/${SSH_KEY_FILE}
    echo -e "${SSH_KEY_CONFIGURATION}" >>${USER_HOME}/.ssh/config

    chown ${USER}: ${USER_HOME}/.ssh
    chmod 0700 -R ${USER_HOME}/.ssh
    chmod 0644 ${USER_HOME}/.ssh/config
    chmod 0600 ${USER_HOME}/.ssh/${SSH_KEY_FILE}
fi

  exec ranger-agent-engine \
        --config-file /etc/ranger-agent/ranger-agent.conf
}

function stop() {

  kill -TERM 1

}

$COMMAND

