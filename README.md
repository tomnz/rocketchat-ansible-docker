# RocketChat Ansible Config

Installs RocketChat on a given machine. Installation is Docker-based, and is designed to be self-contained in that it also configures Mongo and an HTTPS proxy.

## TODO

Remaining work, in no particular order:

- Configure `swag` container for HTTPS forwarding
- Configure Ansible handlers for service up/down
- Safe upgrades (explicit trigger with Ansible tag)
  - Docker
  - Docker Compose
  - Rocket.Chat
  - Mongo
  - Swag
- Backups (explicit trigger with Ansible tag)
  - Mongo data
  - Save to remote location? Or specific mounted drive
  - Encryption with PGP or similar?
- Configure schedule for `git pull` and `ansible-playbook`
  - Run upgrades
  - Do backups

## Deploying

Assuming a (fresh) standard Azure VM with an Ubuntu 18.04 LTS image:

- SSH into the VM:
  - `ssh -i (private_key_file) (username)@(public_ip)`
- Clone this repository:
  - `git clone https://github.com/tomnz/rocketchat-ansible-docker.git`
  - `cd rocketchat-ansible-docker`
- Configure prerequisites (view setup.sh for details):
  - `./setup.sh`
- Set environment variable for domain, e.g.:
  - `export ROCKETCHAT_DOMAIN=chat.example.com`
- Provision Ansible:
  - `ansible-galaxy install -r requirements.yml`
  - `ansible-playbook -v -i hosts.yml playbook.yml --extra-vars "{\"rocketchat_domain\": \"${ROCKETCHAT_DOMAIN}\"}"`

## Updating

- SSH into the VM.
  - `ssh -i (private_key_file) (username)@(public_ip)`
- Pull the repository:
  - `cd ~/rocketchat-ansible-docker`
  - `git pull`
- Provision Ansible:
  - `ansible-playbook -v -i hosts.yml playbook.yml --extra-vars "{\"rocketchat_domain\": \"${ROCKETCHAT_DOMAIN}\"}"`

## Testing with Vagrant

Test the configuration (both initial setup, and further updates) locally using [Vagrant](https://www.vagrantup.com/).

The `Vagrantfile` defines two VMs:

- `rocketchat` is the main VM which mimics a cloud VM.
- `controller` is a secondary VM which is used to remotely provision `rocketchat` using the Ansible playbook.

[Install Vagrant](https://www.vagrantup.com/docs/installation) and a suitable provider for your OS such as VirtualBox. On Windows I recommend running inside WSL with the [additional setup steps](https://www.vagrantup.com/docs/other/wsl).

### Running for the first time

    vagrant up

Once the node is provisioned, you should now be able to confirm that RocketChat is running at: [http://172.17.177.21:3000](http://172.17.177.21:3000)

### SSH into Rocket.Chat VM for testing

    vagrant ssh rocketchat
    # Run any commands you like from here, e.g.
    docker logs rocketchat

### Testing an incremental Ansible run

This is useful for validating idempotent Ansible runs - making sure updates happen, data isn't wiped out, etc.

    vagrant provision --provision-with playbook

### Testing a new Ansible run

    vagrant destroy
    vagrant up
