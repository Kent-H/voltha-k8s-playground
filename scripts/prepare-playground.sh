#!/bin/bash

set -e pipefail

# Clone the Kubespray repo
git clone --branch v2.8.5 https://github.com/kubernetes-incubator/kubespray.git

# Prepare inventory
cp -rfp kubespray/inventory/sample kubespray/inventory/voltha

sed -i -e "/bootstrap_os: none/s/.*/bootstrap_os: ubuntu/" \
	kubespray/inventory/voltha/group_vars/all/all.yml
sed -i -e "s/kube_controller_node_monitor_grace_period: .*/kube_controller_node_monitor_grace_period: 20s/" \
        kubespray/roles/kubernetes/master/defaults/main.yml
sed -i -e "s/kube_controller_pod_eviction_timeout: .*/kube_controller_pod_eviction_timeout: 30s/" \
        kubespray/roles/kubernetes/master/defaults/main.yml

# Build inventory
declare -a IPS=(
	172.42.42.101
	172.42.42.102
	172.42.42.103
	)

HOST_PREFIX=k8s CONFIG_FILE=kubespray/inventory/voltha/hosts.ini python3 kubespray/contrib/inventory_builder/inventory.py ${IPS[@]}

platform=`uname -s`
if [[ "$platform" == 'Darwin' ]]; then
  SED_CMD=gsed
else
  SED_CMD=sed
fi
	
# Only keep one master... multi-master is not stable
FILE="$(cat kubespray/inventory/voltha/hosts.ini)"
echo "$FILE" | \
  "$SED_CMD" -e ':begin;$!N;s/\(\[kube-master\]\)\n/\1/;tbegin;P;D' | \
  "$SED_CMD" -e '/\[kube-master\].*/,/\[.*\]/{//!d}' | \
  "$SED_CMD" -e 's/\(\[kube-master\]\)\(.*\)/\1\n\2\n/' \
  > kubespray/inventory/voltha/hosts.ini
