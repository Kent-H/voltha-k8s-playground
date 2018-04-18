# Voltha Kubernetes Playground

The purpose of this project is to demonstrate a quick start deployment of VOLTHA using VMs to build 
a 3 node Kubernetes cluster on which VOLTHA can be started without the need to build the source 
code tree or use, a rather large, off-line mode installer.

The project contains a `Vagrantfile` and associated `Ansible` playbook scripts
to provision the cluster using `VirtualBox`, `Ubuntu 16.04` and `Kubespray`.

## Prerequisites

You need the following installed to use this playground.

- `Vagrant`, version 1.9.3 or better. Earlier versions of vagrant do not work
with the Vagrant Ubuntu 16.04 box and network configuration.
- `VirtualBox`, tested with Version 5.2.8 r121009 on MacOSX
- Internet access, this playground pulls Vagrant boxes from the Internet as well
as installs Ubuntu application packages from the Internet.

## Bringing Up The cluster

To bring up the cluster, clone this repository to a working directory.

```
git clone http://github.com/ciena/voltha-k8s-playground
```


Change into the working directory, prepare the environment and bring up VMs.  The playground is 
configured to deploy a single-master cluster.  

*NOTE: Although it is possible to deploy as a multi-master cluster, high availability support is 
not yet supported by the playground due to some stability issues.*

```
cd voltha-k8s-playground

# Pull the kubespray repository, prepare inventory and adjust configuration
sh ./scripts/prepare-playground.sh

# Bring up and provision VMs
vagrant up
```

Vagrant will start three machines. Each machine will have a NAT-ed network
interface, through which it can access the Internet, and a `private-network`
interface in the subnet 172.42.42.0/24. The private network is used for
intra-cluster communication.

Once the VMs are active, Kubernetes will be installed and configured through the ansible 
scripts provided with the Kubespray framework.

After the installation of Kubernetes is complete, vagrant will move on to setup and start the 
VOLT-HA components.

## Cluster Verification

After the installation is complete you can verify the status of the cluster by issuing the
commands below.  

* Log in to the master node
```
vagrant ssh k8s1
```

* View the current role assignments
```
vagrant@k8s1:~$ kubectl get nodes -o wide

NAME      STATUS    ROLES         AGE       VERSION   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
k8s1      Ready     master,node   1h        v1.9.5    <none>        Ubuntu 16.04.4 LTS   4.4.0-116-generic   docker://17.3.2
k8s2      Ready     node          1h        v1.9.5    <none>        Ubuntu 16.04.4 LTS   4.4.0-116-generic   docker://17.3.2
k8s3      Ready     node          1h        v1.9.5    <none>        Ubuntu 16.04.4 LTS   4.4.0-116-generic   docker://17.3.2
```

* View the running system pods
```
vagrant@k8s1:~$ kubectl -n kube-system get po -o wide

NAME                                    READY     STATUS    RESTARTS   AGE       IP               NODE
calico-node-h8gf5                       1/1       Running   0          1h        172.42.42.102    k8s2
calico-node-mz5hf                       1/1       Running   0          1h        172.42.42.103    k8s3
calico-node-rwc95                       1/1       Running   0          1h        172.42.42.101    k8s1
kube-apiserver-k8s1                     1/1       Running   0          1h        172.42.42.101    k8s1
kube-controller-manager-k8s1            1/1       Running   0          1h        172.42.42.101    k8s1
kube-dns-79d99cdcd5-9wk7g               3/3       Running   0          1h        10.233.68.1      k8s2
kube-dns-79d99cdcd5-z748d               3/3       Running   0          1h        10.233.70.1      k8s3
kube-proxy-k8s1                         1/1       Running   0          1h        172.42.42.101    k8s1
kube-proxy-k8s2                         1/1       Running   0          1h        172.42.42.102    k8s2
kube-proxy-k8s3                         1/1       Running   0          1h        172.42.42.103    k8s3
kube-scheduler-k8s1                     1/1       Running   0          1h        172.42.42.101    k8s1
kubedns-autoscaler-5564b5585f-zzjdn     1/1       Running   0          1h        10.233.102.193   k8s1
kubernetes-dashboard-69cb58d748-p24ql   1/1       Running   0          1h        10.233.102.194   k8s1
nginx-proxy-k8s3                        1/1       Running   0          1h        172.42.42.103    k8s3
```

The VOLT-HA environment uses `etcd` by default.  If required you can switch back to `consul` 
using the available consul kubernetes manifest.

* View the running VOLT-HA components
```
vagrant@k8s1:~$ kubectl -n kube-system get po -o wide

NAME                                      READY     STATUS    RESTARTS   AGE       IP               NODE
default-http-backend-8c74c48d4-r6z45      1/1       Running   0          58m       10.233.102.205   k8s1
etcd-d8f87hssh2                           1/1       Running   0          57m       10.233.68.22     k8s2
etcd-jcdwgmwx9s                           1/1       Running   0          58m       10.233.102.212   k8s1
etcd-lrglvf5cj2                           1/1       Running   0          58m       10.233.70.20     k8s3
etcd-operator-67cc97bf76-bnlfw            1/1       Running   0          58m       10.233.68.16     k8s2
fluentd-85djp                             1/1       Running   0          58m       10.233.68.15     k8s2
fluentd-g6w2b                             1/1       Running   0          58m       10.233.102.209   k8s1
fluentd-sp7zg                             1/1       Running   0          58m       10.233.70.19     k8s3
fluentdactv-57bb6f4bcd-hllcm              1/1       Running   0          58m       10.233.70.18     k8s3
fluentdstby-69699b7454-chwf2              1/1       Running   0          58m       10.233.68.14     k8s2
freeradius-5db4fd4fd6-rrx2v               1/1       Running   0          57m       10.233.70.27     k8s3
kafka-0                                   1/1       Running   0          58m       10.233.68.13     k8s2
kafka-1                                   1/1       Running   0          58m       10.233.70.17     k8s3
kafka-2                                   1/1       Running   0          58m       10.233.102.208   k8s1
netconf-776f99fff9-7bwz4                  1/1       Running   0          58m       10.233.102.213   k8s1
netconf-776f99fff9-twl8r                  1/1       Running   0          58m       10.233.70.25     k8s3
netconf-776f99fff9-vnt7d                  1/1       Running   0          58m       10.233.68.20     k8s2
nginx-ingress-controller-67cc8d74-rlz2w   1/1       Running   0          58m       10.233.70.15     k8s3
ofagent-68787fc777-52bv5                  1/1       Running   0          58m       10.233.70.22     k8s3
ofagent-68787fc777-qb7kn                  1/1       Running   0          58m       10.233.102.211   k8s1
ofagent-68787fc777-zvm7f                  1/1       Running   0          58m       10.233.68.18     k8s2
vcli-6d5f996f87-sbgcg                     1/1       Running   0          58m       10.233.70.24     k8s3
vcli-6d5f996f87-zmf9h                     1/1       Running   0          58m       10.233.68.19     k8s2
vcore-59c78b8c56-5c4x6                    1/1       Running   0          58m       10.233.68.17     k8s2
vcore-59c78b8c56-sccpq                    1/1       Running   0          58m       10.233.102.210   k8s1
vcore-59c78b8c56-wsbc8                    1/1       Running   0          58m       10.233.70.21     k8s3
voltha-c797d4c9f-tjsv9                    1/1       Running   0          58m       10.233.70.23     k8s3
zookeeper1-0                              1/1       Running   0          58m       10.233.70.16     k8s3
zookeeper2-0                              1/1       Running   0          58m       10.233.102.207   k8s1
zookeeper3-0                              1/1       Running   0          58m       10.233.102.206   k8s1
```

* View the running services 
```
vagrant@k8s1:~$ kubectl -n voltha get svc -o wide

NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                                        AGE       SELECTOR
default-http-backend   ClusterIP   10.233.34.204   <none>        80/TCP                                         59m       app=default-http-backend
etcd                   ClusterIP   None            <none>        2379/TCP,2380/TCP                              58m       app=etcd,etcd_cluster=etcd
etcd-client            ClusterIP   10.233.25.66    <none>        2379/TCP                                       58m       app=etcd,etcd_cluster=etcd
fluentd                ClusterIP   None            <none>        24224/TCP                                      58m       app=fluentd
fluentdactv            ClusterIP   None            <none>        24224/TCP                                      58m       app=fluentdactv
fluentdstby            ClusterIP   None            <none>        24224/TCP                                      58m       app=fluentdstby
freeradius             ClusterIP   None            <none>        1812/UDP,1813/UDP,18120/TCP                    58m       app=freeradius
ingress-nginx          NodePort    10.233.21.250   <none>        80:30080/TCP,443:30443/TCP                     59m       app=ingress-nginx
kafka                  ClusterIP   None            <none>        9092/TCP                                       58m       app=kafka
netconf                ClusterIP   None            <none>        830/TCP                                        58m       app=netconf
vcli                   ClusterIP   10.233.33.39    <none>        5022/TCP                                       58m       app=vcli
vcore                  ClusterIP   None            <none>        8880/TCP,18880/TCP,50556/TCP                   58m       app=vcore
voltha                 ClusterIP   None            <none>        8882/TCP,8001/TCP,8443/TCP,50555/TCP           58m       app=voltha
zoo1                   ClusterIP   None            <none>        2181/TCP,2888/TCP,3888/TCP                     58m       app=zookeeper-1
zoo2                   ClusterIP   None            <none>        2181/TCP,2888/TCP,3888/TCP                     58m       app=zookeeper-2
zoo3                   ClusterIP   None            <none>        2181/TCP,2888/TCP,3888/TCP                     58m       app=zookeeper-3
```

## Statistics collection

The following command will start all the necessary containers for statistics collection such as PMs 
from the VOLT-HA environment.
```
cd /vagrant && ansible-playbook -i kubespray/inventory/voltha/hosts.ini ansible/deploy-stats.yml
```

You should now see new running containers:

```
NAME                                      READY     STATUS    RESTARTS   AGE       IP               NODE
dashd-786944f4dc-9mnrb                    1/1       Running   0          1m        10.233.68.13     k8s2
...
grafana-86766858f8-95qzl                  1/1       Running   0          2m        10.233.70.13     k8s3
...
shovel-75fc5f8db5-9f25x                   1/1       Running   0          1m        10.233.102.202   k8s1
...
```

## EAPOL authentication using the RG and PON simulator

The VOLT-HA kubernetes playground comes with the containerized ponsim as well as the RG tester 
container.  In this section, you will learn how to configure your VOLTHA kubernetes environment 
to perform an EAPOL authentication by completing the following steps:

- Setting up PON bridge (if needed)
- Start the PON simulator and related components
- Create a ponsim olt device
- Customize the ONOS configuration
- Use the RG to perform an authentication request


Follow the steps below to start using the PON simulator.

### Setup the PON bridge (ONLY IF MISSING)

A CNI component for the pon0 bridge should have been configured when the 
cluster was first deployed.

Verify if the file is present:
```
cat /etc/cni/net.d/20-pon0.conf
```

The output should look like the following:
```
{
    "name": "pon0",
    "type": "bridge",
    "bridge": "pon0",
    "isGateway": true,
    "ipMask": true,
    "ipam": {
        "type": "host-local",
        "subnet": "10.22.0.0/16",
        "routes": [
          { "dst": "0.0.0.0/0" }
        ]
    }
}


```
If the file is present, you can move on to starting the PON simulator.

If the file is missing it can be created on each host in the cluster using one the following 
ansible script.
```
cd /vagrant && ansible-playbook -b --become-user=root --limit="all" -i kubespray/inventory/voltha/hosts.ini ansible/config.yml
```

### Start PONSIM

The following command will start the ponsim and all related components.
- FreeRADIUS
- ONOS
- OLT (1 instance) 
- ONU (4 instances)
- RG (1 instance)
```
cd /vagrant && ansible-playbook -b --become-user=root --limit="all" -i kubespray/inventory/voltha/hosts.ini ansible/deploy-ponsim.yml
```

### Create a PONSIM OLT device

Once your PON simulator is up and running, an olt device can be created in the voltha cli.


Find the IP of the cli 
```
kubectl -n voltha get svc -o wide | grep vcli
```

Log in to the VOLT-HA cli
```
ssh -p 5022 voltha@<ip of vcli service>
```

Create a new ponsim olt device
```
preprovision_olt -t ponsim_olt -H olt:50060
enable
```

Find the serial number (desc.serial_num) of the logical device associated to this OLT instance.  
Please keep this information as it will be used in future steps.

```
logical_devices

+------------------+-----------------+------------------+----------------------------------+---------------------------+--------------------------+
|               id |     datapath_id |   root_device_id |                  desc.serial_num | switch_features.n_buffers | switch_features.n_tables |
+------------------+-----------------+------------------+----------------------------------+---------------------------+--------------------------+
| 0001aabbccddeeff | 187723572702975 | 000102f105ecef30 | c34c2c2fb6da40f1ab5e9bc20e02375b |                       256 |                        2 |
+------------------+-----------------+------------------+----------------------------------+---------------------------+--------------------------+
```


### Customize ONOS configuration

The ONOS container has a default configuration which needs to be customized.  A 
configuration file is provided under scripts/netcfg.json for that purpose.

Start by opening the scripts/netcfg.json configuration file.  

Under the *org.opencord.sadis/sadis/entries* section of the document, replace the entry with a 
long string of hex numbers with the value of desc.serial_num that was retrieved in previous steps.

```
   "org.opencord.sadis" : {
     "sadis" : {
        ...
        "entries" : [ {          ...
           }, {
           "id" : "c34c2c2fb6da40f1ab5e9bc20e02375b",
           "hardwareIdentifier" : "00:1b:22:00:b1:78",
           "ipAddress" : "1.2.3.4",
           "nasId" : "B100-NASID"
           } ]
           ...
```

*IMPORTANT NOTE: See __Known Issues__ section in regards to the ponsim_olt serial number*
 

Find the cluster IP address of the ONOS service
```
vagrant@k8s1:~$ kubectl -n voltha get services | grep onos

onos                   ClusterIP   10.233.9.207    <none>        8101/TCP,6653/TCP,8181/TCP                     27m
```


Apply the configuration to your ONOS instance.  Use the appropriate cluster IP address that was 
retrieved in the previous step.

```
curl --user karaf:karaf -X POST -H "Content-Type: application/json" http://10.233.9.207:8181/onos/v1/network/configuration/ -d @scripts/netcfg.json
```


Verify that the configuration was applied by entering the ONOS cli.

```
sshpass -p karaf ssh -o StrictHostKeyChecking=no -p 8101 karaf@10.233.9.207
```

View the ONOS network configuration

```
netcfg
```

At this point, you may need to disable/enable the VOLTHA device that was created in previous 
steps to let ONOS rediscover the device.

### Using the RG tester
Once the PON simulator is started, you can use the RG tester to perform different tests.

Enter the RG tester container
```
kubectl -n voltha exec <rg container id> -ti bash
```

Execute some test (e.g. EAPOL authentication)
```
wpa_supplicant -i eth0 -Dwired -c /etc/wpa_supplicant/wpa_supplicant.conf
```

A successful authentication should look like the following:

```
Successfully initialized wpa_supplicant
eth0: Associated with 01:80:c2:00:00:03
WMM AC: Missing IEs
eth0: CTRL-EVENT-EAP-STARTED EAP authentication started
eth0: CTRL-EVENT-EAP-PROPOSED-METHOD vendor=0 method=4
eth0: CTRL-EVENT-EAP-METHOD EAP vendor 0 method 4 (MD5) selected
eth0: CTRL-EVENT-EAP-SUCCESS EAP authentication completed successfully
```

## Useful tips to deploy and teardown VOLT-HA components.

The VOLT-HA components are deployed automatically when the cluster is first configured.

If you wish to deploy and/or teardown components as you please, you can use the following ansible
 scripts.


* Deploy the VOLT-HA components (__excludes__ statistic collection and ponsim)
```

cd /vagrant && ansible-playbook -i kubespray/inventory/voltha/hosts.ini ansible/deploy.yml
```


* Teardown all the VOLT-HA components (__includes__ statistic collection and ponsim)
```
cd /vagrant && ansible-playbook -i kubespray/inventory/voltha/hosts.ini ansible/teardown.yml
```


## Known Issues

### Serial number of a ponsim_olt device

The implementation of the VOLTHA ponsim_olt device does not currently have the  ability to 
retrieve a serial number.  Every time you enable a ponsim_olt device, a new serial number is 
assigned automatically to the logical device. 

The  downside of this behaviour is that ONOS requires the serial number to successfully 
authenticate the device.  Hence the need to modify the netcfg.json file with the proper id 
information as explained above.

Please refer to [VOL-676](https://jira.opencord.org/browse/VOL-676) for more details and updates 
on this issue.

