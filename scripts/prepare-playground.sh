#!/bin/bash

# Clone the Kubespray repo
git clone --branch v2.5.0 https://github.com/kubernetes-incubator/kubespray.git 

# Prepare inventory
cp -rfp kubespray/inventory/sample kubespray/inventory/voltha

sed -i -e "/bootstrap_os: none/s/.*/bootstrap_os: ubuntu/" \
	kubespray/inventory/voltha/group_vars/all.yml
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

# Only keep one master... multi-master is not stable
cat kubespray/inventory/voltha/hosts.ini | sed -e ':begin;$!N;s/\(\[kube-master\]\)\n/\1/;tbegin;P;D' | sed -e '/\[kube-master\].*/,/\[kube-node\]/{//!d}' | sed -e 's/\(\[kube-master\]\)\(.*\)/\1\n\2\n/' > kubespray/inventory/voltha/hosts.ini.tmp
mv kubespray/inventory/voltha/hosts.ini.tmp kubespray/inventory/voltha/hosts.ini
