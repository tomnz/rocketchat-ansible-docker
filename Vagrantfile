# -*- mode: ruby -*-
# vi: set ft=ruby :
# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"

  config.vm.define "rocketchat" do |machine|
    machine.vm.network "private_network", ip: "172.17.177.21"
  end

  config.vm.define 'controller' do |machine|
    machine.vm.network "private_network", ip: "172.17.177.11"

    # Need to mount /vagrant read-only:
    # - Ansible requires this for ansible.cfg to be used
    # - SSH requires this for using the rocketchat SSH key
    machine.vm.synced_folder ".", "/vagrant", mount_options: ["dmode=500", "fmode=500"]

    # Make sure we're using Python 3 for Ansible
    machine.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update -y
      sudo apt-get install -y python3 python3-pip
      pip3 install ansible
    SHELL

    # Install Ansible requirements
    machine.vm.provision "shell", inline: <<-SHELL
      cd /vagrant
      ansible-galaxy install -r requirements.yml
    SHELL

    # Launch the Ansible playbook on rocketchat
    machine.vm.provision "playbook", type: "ansible_local" do |ansible|
      ansible.playbook       = "playbook.yml"
      ansible.verbose        = true
      ansible.install        = true
      ansible.limit          = "rocketchat"
      ansible.inventory_path = "hosts-Vagrant.yml"
    end
  end
end
