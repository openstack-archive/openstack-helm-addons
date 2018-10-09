set -xe

#NOTE: Deploy command

#NOTE: override file
tee /tmp/ranger.yaml << EOF
conf:
  ranger:
    DEFAULT:
      ranger_agent_https_enable: true
      ranger_agent_client_cert_path: '/home/ranger/ord.cert'
  ssh:
    ssh_key: null
    ssh_config: null
  cert:
    ranger_agent_client_cert: null
EOF

helm upgrade --install ranger ./ranger \
  --namespace=openstack \
  --values=/tmp/ranger.yaml

#NOTE: Wait for deploy
./tools/gate/scripts/wait-for-pods.sh openstack
