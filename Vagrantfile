# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # This Vagrant configuration uses two VMs to emulate remotely configuring a
  # target machine.
  # After configuration, RocketChat should be available for testing at:
  # http://localhost:3080

  # managed-node is the VM we will configure using the Ansible playbook
  config.vm.define "managed-node" do |managed|
    managed.vm.box = "bento/ubuntu-18.04"

    managed.vm.network "private_network", ip: "192.168.33.11"
    # # Forward SSH for configuring via Ansible
    # managed.vm.network "forwarded_port", guest: 22, host: 3122, host_ip: "127.0.0.1"
    # # Forward RocketChat
    # managed.vm.network "forwarded_port", guest: 3000, host: 3080, host_ip: "127.0.0.1"

    # Disable injection of Ansible files
    managed.vm.synced_folder ".", "/vagrant", disabled: true

    managed.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update
      sudo apt-get install python -y
    SHELL
  end

  # control-node is the VM which we will remotely use to configure managed-node
  config.vm.define "control-node" do |control|
    control.vm.box = "bento/ubuntu-18.04"

    control.vm.provision "shell", inline: <<-SHELL
       sudo apt-get update -y
       sudo apt-get install -y software-properties-common
       sudo apt-add-repository ppa:ansible/ansible
       sudo apt-get update -y
       sudo apt-get install -y ansible
     SHELL

     control.vm.provision "shell", privileged: false, inline: <<-SHELL
       ssh-keygen -t rsa -q -f "/home/vagrant/.ssh/id_rsa" -N ""
       ssh-keygen -R 192.168.33.11
       ssh-keyscan -t rsa -H 192.168.33.11 >> /home/vagrant/.ssh/known_hosts
       sshpass -p 'vagrant' ssh-copy-id -i /home/vagrant/.ssh/id_rsa.pub vagrant@192.168.33.11
     SHELL

     control.vm.provision "ansible", type: "shell", privileged: false, inline: <<-SHELL
      cd /vagrant
      ansible-playbook -i hosts-Vagrant.yml -u vagrant playbook.yml
     SHELL
  end

  # Configure VirtualBox if used
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  # Configure Hyper-V if used
  config.vm.provider "hyperv" do |hv|
    hv.maxmemory = 2048
    hv.cpus = 2
  end
end
