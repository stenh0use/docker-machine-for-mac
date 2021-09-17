VAGRANT_HOST=$(shell grep v.name Vagrantfile | awk '{gsub(/"/, "", $$3); print $$3}')
VAGRANT_IP=$(shell grep "private_network, ip" Vagrantfile | awk '{gsub(/"/, "", $$4); print $$4}')

INFO='\033[0;32m'
WARN='\033[0;33m'
RESET='\033[0m'

define docker-machine-rm
	docker-machine rm -f $(VAGRANT_HOST) 2> /dev/null
endef

.PHONY: docker-machine-rm
docker-machine-rm:
	@ $(call docker-machine-rm)

define docker-machine-add
	docker-machine create -d generic \
		--generic-ssh-user vagrant \
		--generic-ssh-key ~/.vagrant.d/insecure_private_key \
		--generic-ip-address $(VAGRANT_IP) \
		$(VAGRANT_HOST)
endef

.PHONY: docker-machine-add
docker-machine-add: docker-machine-rm
	@ $(call docker-machine-add) || /bin/bash -c "\
		$(call vagrant-reload) && \
		$(call docker-machine-rm) && \
		$(call docker-machine-add)"

.PHONY: docker-machine-check
docker-machine-check:
	@ eval `docker-machine env $(VAGRANT_HOST)` && \
	docker ps > /dev/null && \
	echo $(INFO)Docker Machine setup was successful$(RESET) && \
	echo $(WARN)To connect to this host run \"eval \`docker-machine env $(VAGRANT_HOST)\`\". \
	To make this your default docker machine add the command or the output from \
	\"docker-machine env $(VAGRANT_HOST)\" to your ~/.bash_profile$(RESET)

define vagrant-reload
	vagrant reload
endef

.PHONY: vagrant-reload
vagrant-reload:
	@ $(call vagrant-reload)

.PHONY: vagrant-destroy
vagrant-destroy: check-clean
	@ vagrant destroy -f

.PHONY: vagrant-up
vagrant-up:
	@ vagrant up

.PHONY: vagrant-halt
vagrant-halt:
	@ vagrant halt

.PHONY: down
down: vagrant-halt

.PHONY: up
up: vagrant-up

.PHONY: build
build: install-requirements vagrant-up vagrant-reload docker-machine-add docker-machine-check

.PHONY: clean
clean: check-clean docker-machine-rm vagrant-destroy
	@ rm -rf .vagrant

.PHONY: destroy
destroy: clean

.PHONY: check-clean
check-clean:
	@ printf "Are you sure you want to destroy the '$(VAGRANT_HOST)' VM? [y/N]: " && read ans && [ $${ans:-N} = y ]

.PHONY: install-requirements
install-requirements:
	@ ansible-galaxy install -r ../resources/requirements.yml -p ../resources/roles && \
	VBG_PLUGIN=`vagrant plugin list | grep vagrant-vbguest || true` && \
	if [ -z "$$VBG_PLUGIN" ]; then \
		vagrant plugin install vagrant-vbguest && \
		vagrant plugin install vagrant-disksize; \
	else \
		echo "vagrant-vbguest is already installed"; \
	fi
