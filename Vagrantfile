# -*- mode: ruby -*-
# # vi: set ft=ruby :

ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip

Vagrant.configure(2) do |config|

  (1..3).each do |i|
    config.vm.define "k8s#{i}" do |s|
      s.ssh.forward_agent = true
      s.vm.box = "bento/ubuntu-16.04"
      s.vm.hostname = "k8s#{i}"

      s.vm.network "private_network", ip: "172.42.42.10#{i}", netmask: "255.255.255.0",
        auto_config: true

      s.vm.provider "virtualbox" do |v|
        v.name = "k8s#{i}"
        v.memory = 3072
        v.cpus = 2
        v.gui = false
      end

      s.vm.provision "file", source: "#{Dir.home}/.ssh/id_rsa", destination: "/home/vagrant/.ssh/id_rsa"
      s.vm.provision :shell, :inline =>"
     	echo '#{ssh_pub_key}' >> /home/vagrant/.ssh/authorized_keys
      ", privileged: false

      s.vm.provision :shell, path: "scripts/bootstrap_ansible.sh"

      if i == 3
        s.vm.provision :shell, :inline =>"
     	  echo '#{ssh_pub_key}' >> /home/vagrant/.ssh/authorized_keys
        ", privileged: false

        s.vm.provision "ansible_local" do |ansible|
          ansible.playbook = "kubespray/cluster.yml"
          ansible.config_file = "kubespray/ansible.cfg"
          ansible.inventory_path = "kubespray/inventory/voltha/hosts.ini"
          ansible.become = true
          ansible.become_user = "root"
          ansible.verbose = true
          ansible.limit = "all"
        end
        s.vm.provision "ansible_local" do |ansible|
          ansible.playbook = "ansible/config.yml"
          ansible.inventory_path = "kubespray/inventory/voltha/hosts.ini"
          ansible.become = true
          ansible.become_user = "root"
          ansible.verbose = true
          ansible.limit = "all"
        end
        s.vm.provision "ansible_local" do |ansible|
          ansible.playbook = "ansible/config-masters.yml"
          ansible.inventory_path = "kubespray/inventory/voltha/hosts.ini"
          ansible.become = true
          ansible.become_user = "root"
          ansible.verbose = true
          ansible.limit = "kube-master"
        end
      end
    end
  end

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end

end
