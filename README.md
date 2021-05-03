# Docker for Mac - Docker Machine / Vagrant / Ansible

Motivation: Docker for Mac was proving to be a workflow pain rather than a workflow gain. It was slowing down my 16" Macbook Pro (32GB RAM, 6 CPUs), draining the battery, and causing the fans to constantly spin at full speed. There had also been occurrences where kernel modules had been removed, rendering it difficult to do system development.

If you need docker and kernel modules to support things like SCTP, IP_VS, WireGuard etc. then this project might be for you.

This Vagrant box is intended to replace Docker for Mac and utilises docker-machine, Vagrant, VirtualBox and Ansible, whilst utilising a fully featured linux server.

## Background

Vagrant and VirtualBox can be used to quickly build or rebuild virtual servers.

This Vagrant profile installs [docker](https://www.docker.com/) using the [Ansible](http://www.ansible.com/) provisioner and finishes up with the docker-machine configuration.

## Getting Started

Each docker-machine directory contains a `Vagrantfile` for a different base operating systems (hereafter this folder shall be called the [vagrant_root]), which tells Vagrant how to set up your virtual machine in VirtualBox.

To use the vagrant file, you will need to have done the following:

  1. Download and Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
  2. Download and Install [Vagrant](https://www.vagrantup.com/downloads.html)
  3. If you want to completely remove Docker for Mac [run this script](https://github.com/docker/toolbox/blob/master/osx/uninstall.sh) (recommended)
  4. If you removed Docker for Mac you'll then need to [Download and install](https://docs.docker.com/engine/install/binaries/) the `docker` cli binary
  4. Install Docker Machine [docker-machine](https://docs.docker.com/machine/install-machine/)
  5. Install [Ansible](http://docs.ansible.com/ansible/latest/intro_installation.html)
  6. Open a shell prompt (Terminal app on a Mac) and cd into the folder containing the `Vagrantfile` of the target operating systems that you want to build.

Once all of that is done, you can simply type in `make build`, and Vagrant will create a new VM, install the base box, and configure it to work with `docker`.

Once the new VM is up and running, you should see the message:


    Docker Machine setup was successful
    To connect to this host run "eval `docker-machine env <vagrant_hostname>`". To make this your default docker machine add the command or the output from "docker-machine env <vagrant_hostname>" to your ~/.bash_profile


### Setting up your hosts file

If you want to modify your host machine's hosts file (`/etc/hosts`), to add the docker machine hostname you can do so adding the line below:

    <vagrant_ip>  <vagrant_hostname>

eg.

    192.168.33.3  docker-debian-10

(Where `docker-debian-10`) is the hostname you have configured in the `Vagrantfile`).

If you'd like additional assistance editing your hosts file, please read [How do I modify my hosts file?](http://www.rackspace.com/knowledge_center/article/how-do-i-modify-my-hosts-file) from Rackspace.

### Managing your docker-machine

The setup of your docker machine is handled during the build stage. If you need to update or re-do this in any way the following commands are helpful.

|         command           |                        description                            |
|---------------------------|---------------------------------------------------------------|
|`make build`               | build a the `docker-machine` vm and configure for use with docker|
|`make destroy`             | this will destroy the vagrant box and clean up the `.vagrant` directory|
|`make up`                  | the same as `vagrant up`, you can use this to start the `docker-machine` vm if it has already been built and needs to be started again.|
|`make down`                | the same as `vagrant halt`, you can use this to shutdown your `docker-machine` vm.|
|`make docker-machine-add`  | add the vagrant box as a docker machine|
|`make docker-machine-rm`   | remove the vagrant box as a docker machine|
|`make docker-machine-check`| check that the vagrant box is correctly setup as a docker machine|

<br>

### SSH access
If you need or want ssh access to the vm you can ssh in with two methods.

1. The Vagrant method: from within the machines directory execute:

    vagrant ssh

2. The docker-machine method: from anywhere execute the command:

    docker-machine ssh <docker-machine-name>

### Mounting Volumes

The docker machine mounts the "/Users" folder in the docker VM to allow you to continue using the the existing functionality to mount volumes from the Mac locations.

eg.

    docker run -d -v ~/dev/project/config.json:/opt/my_app/config.json -v $PWD:/data centos:7

More locations can be added if required in the Vagrant file. After updating with the new location execute `vagrant reload` to take effect.

eg.

    config.vm.synced_folder "/Library", "/Library"

### Exposing Ports
Any time you want to expose a port from docker you need to remember that the docker host will have changed from localhost to the IP address on the VM. If anyone has any good ideas to fix that magic let me know via the issues. If you really want to use localhost you can set a range in virtual box and port forward the ports that way.

eg. exposing ports `-p 8080:80` in docker will mean to query that port from your mac you would query the VM IP instead.


    curl http://192.168.33.3:8080

or if you configured your /etc/hosts as per the above instructions.

    curl http://docker-debian-10:8080

### Communicating with Mac OS localhost and DNS

The existing magic hostname (`host.docker.internal`) that lets docker containers talk to services on the Mac's `localhost` has been configured to use the Mac's interface IP address connected to the VM's private network. Any services on the Mac would need to be listing on this interface in order for this to work.

Other custom hostnames can be configured if required by adding the variable `dnsmasq_custom_hosts` to the `resources/vars/main.yml` file.

Usage:

    dnsmasq_custom_hosts:
      - hostname: custom.hostname.local
        ip_address: 192.168.3.1

### SELinux
CentOS Stream8 Docker Machine's docker daemon is configured with SELinux support enabled (`selinux-enabled`).

## Author Information

James Stenhouse

Vagrant file and Readme adapted from: [Jeff Geerling](https://www.jeffgeerling.com/), [Ansible Vagrant Examples](https://github.com/geerlingguy/ansible-vagrant-examples)
