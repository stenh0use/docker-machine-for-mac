# Docker for Mac - Docker Machine / Vagrant / Ansible

Motivation: Docker for Mac was proving to be a workflow pain rather than a workflow gain. It was slowing down my 16" Macbook Pro (32GB RAM, 6 CPUs), and over time they were removing kernel modules required to do system development.

This Vagrant box is intended to replace Docker for Mac and utilises the docker-machine + Vagrant + VirtualBox + Ansible.

## Background

Vagrant and VirtualBox (or some other VM provider) can be used to quickly build or rebuild virtual servers.

This Vagrant profile installs [docker](https://www.docker.com/) using the [Ansible](http://www.ansible.com/) provisioner.

## Getting Started

This README file is inside a folder that contains a `Vagrantfile` (hereafter this folder shall be called the [vagrant_root]), which tells Vagrant how to set up your virtual machine in VirtualBox.

To use the vagrant file, you will need to have done the following:

  1. Download and Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
  2. Download and Install [Vagrant](https://www.vagrantup.com/downloads.html)
  3. Install Docker Machine [docker-machine](https://docs.docker.com/machine/install-machine/)
  4. Install [Ansible](http://docs.ansible.com/ansible/latest/intro_installation.html)
  5. Open a shell prompt (Terminal app on a Mac) and cd into the folder containing the `Vagrantfile`
  6. Run the following command to install the necessary Ansible roles for this profile: `$ ansible-galaxy install -r requirements.yml`
  7. Install the Vagrant vbguest plugin `vagrant plugin install vagrant-vbguest`

Once all of that is done, you can simply type in `vagrant up`, and Vagrant will create a new VM, install the base box, and configure it.

Once the new VM is up and running (after `vagrant up` is complete and you're back at the command prompt), you can log into it via SSH if you'd like by typing in `vagrant ssh`. Otherwise, the next steps are below.

### Setting up your hosts file

You need to modify your host machine's hosts file (Mac/Linux: `/etc/hosts`; Windows: `%systemroot%\system32\drivers\etc\hosts`), adding the line below:

    192.168.33.3  docker-debian

(Where `docker-debian`) is the hostname you have configured in the `Vagrantfile`).

If you'd like additional assistance editing your hosts file, please read [How do I modify my hosts file?](http://www.rackspace.com/knowledge_center/article/how-do-i-modify-my-hosts-file) from Rackspace.

### Setting up your docker-machine

To add your new Vagrant box to docker-machine execute the following:

```
docker-machine create -d generic \
  --generic-ssh-user vagrant \
  --generic-ssh-key ~/.vagrant.d/insecure_private_key \
  --generic-ip-address 192.168.33.3 \
  debian
```

Then once that is done, you can execute `eval $(docker-machine env debian)` to load the environment vars, and docker should now be ready to go.

Execute `docker ps` and an output similar to the below should be present.

```
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

### Final Notes
Any time you want to expose a port from docker you need to remember that the docker localhost port will have now changed.

eg. exposing ports `-p 8080:80` in docker will mean to query that port you would query the VM IP instead.

```
curl http://192.168.33.3:8080
```
or if you configured your /etc/hosts as per the above instructions.
```
curl http://docker-debian:8080
```

## Author Information

James Stenhouse

Vagrant file and Readme Adapted from: [Jeff Geerling](https://www.jeffgeerling.com/), [Ansible Vagrant Examples](https://github.com/geerlingguy/ansible-vagrant-examples)
