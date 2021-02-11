## Testing with Vagrant

Testing the configuration (both initial setup, and further updates) using [Vagrant](https://www.vagrantup.com/).

The `Vagrantfile` defines two VMs:

- `managed-node` mimics the cloud VM we are deploying to.
- `control-node` mimics the configuring machine, on which Ansible is run (targeting `managed-node`).

Both are currently based on Ubuntu 18.04 LTS - but testing additional OSes in future should be straightforward. To test:

- [Install Vagrant](https://www.vagrantup.com/docs/installation). I'm running on Windows, where I strongly recommend using [Vagrant under WSL](https://www.vagrantup.com/docs/other/wsl), with VirtualBox as the provider. Hyper-V has some quirks such as needing Administrator access, or workarounds for advanced networking options.
- Navigate to the root repo directory, and run `vagrant up`. (You may need to wrangle your Vagrant setup if you are configuring it for the first time).
- Wait for the two nodes to be provisioned, and Ansible to be run against `managed-node`.

You should now be able to confirm that RocketChat is running at: [http://192.168.33.11:80](http://192.168.33.11:80)
