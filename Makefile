SHELL := /bin/bash
MAKEFLAGS := silent
CWD := `pwd`
ZSH_THEME := 'appliance'

JSONNET_INSTALLED := $(shell command -v jsonnet 2> /dev/null)
JQ_INSTALLED := $(shell command -v jq 2> /dev/null)
DOCKER_INSTALLED := $(shell command -v docker 2> /dev/null)
USER_IN_DOCKER_GROUP := $(shell groups $$USER | grep '\bdocker\b')
DOCKER_COMPOSE_INSTALLED := $(shell command -v docker-compose 2> /dev/null)
DOCKER_NETWORK_DEFAULT := 'appliance'
DOCKER_NETWORKS_SETUP := $(shell sudo docker network ls | grep $(DOCKER_NETWORK_DEFAULT))
CTOP_INSTALLED := $(shell command -v ctop 2> /dev/null)
PROM_NODE_EXPORTER_INSTALLED := $(shell command -v prometheus-node-exporter 2> /dev/null)

default: help

## Add Ubuntu repos main and university in case they're not already enabled
setup-ubuntu-repositories:
	sudo add-apt-repository main
	sudo add-apt-repository universe

## Switch to ZSH
switch-to-zsh: setup-ubuntu-repositories
	sudo apt-get install zsh
	chsh -s $$(which zsh)
	echo "Your shell has been switched to ZSH, please exit the terminal and log back in."
	echo "If you are greeted with a Zsh shell configuration prompt, select "2" to accept default settings."
	echo "After you log back in, come back to this directory and run 'make setup-oh-my-zsh' to continue."

## Install [Oh-My-ZSH!](http://ohmyz.sh/) CLI improvement utilities
install-oh-my-zsh:
	echo "After installation completes, log out and back in, come back to directory and run 'make setup-oh-my-zsh'."
	sh -c "$$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

## Configure Oh-My-ZSH CLI improvement settings
setup-oh-my-zsh:
	echo "Installing shell/$(ZSH_THEME).zsh-theme theme into $$HOME/.oh-my-zsh/themes."
	cp shell/$(ZSH_THEME).zsh-theme $$HOME/.oh-my-zsh/themes/$(ZSH_THEME).zsh-theme
	echo "Replacing default ZSH theme with $(ZSH_THEME).zsh-theme."
	sed -i.bak 's/ZSH_THEME="robbyrussell"/ZSH_THEME="$(ZSH_THEME)"/' $$HOME/.zshrc
	cat $HOME/.zshrc | grep ZSH_THEME
	echo "*************************************************************************"
	echo "Oh My ZSH! has been configured, please exit the terminal and log back in."
	echo "Add this to the .zshrc to auto-set your terminal window title:"
	echo '    precmd() { print -Pn "\e]0;${USER}@${HOST}%~\a" }'
	echo "*************************************************************************"

setup-git-aliases:
	git config --global alias.update '!git pull && git submodule update --init --recursive'

setup-git-credentials-cache:
	git config --global credential.helper 'cache --timeout 28800'

clean-git-credentials-cache:
	git credential-cache exit

## Configure default git environmental controls
setup-git: setup-git-credentials-cache setup-git-aliases

ONESHELL:
## Setup docker from Ubuntu repo
setup-docker: setup-ubuntu-repositories
ifndef DOCKER_INSTALLED
	echo "Using instructions from https://docs.docker.com/install/linux/docker-ce/ubuntu/"
	sudo apt-get update
	sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $$(lsb_release -cs) stable"
	sudo apt-get update
	sudo apt-get install -y docker-ce
	sudo groupadd docker
	sudo usermod -aG docker $$USER
	sudo systemctl enable docker
	sudo apt install -y docker-compose
	echo "**************************************************************************************"
	echo "* Docker and docker-compose should now be installed if there were no error messages. *"
	echo "* Group docker was added, and user $$USER was configured to be a member of it, so    *"
	echo "* user $$USER should be able to run docker commands without sudo prefix.             *"
	echo "*                                                                                    *"
	echo "* Please REBOOT NOW to make sure users, groups, and everything else are configured.  *"
	echo "**************************************************************************************"
	docker --version
	docker-compose --version
else
	docker --version
	docker-compose --version
endif

setup-docker-networks:
	docker network create $(DOCKER_NETWORK_DEFAULT)

## See if all developer dependencies are installed
check-dependencies: setup-ubuntu-repositories check-jsonnet check-jq check-docker check-docker-compose check-user-in-docker-group check-docker-networks check-ctop check-prometheus-node-exporter
	printf "[*] "
	make -v | head -1
	echo "[*] Shell: $$SHELL"

check-jsonnet:
ifndef JSONNET_INSTALLED
	echo "Did not find jsonnet, creating link to shell/jsonnet version"
	sudo ln -s $(CWD)/shell/jsonnet-v0.11.2 /usr/local/bin/jsonnet
	ls -al /usr/local/bin/jsonnet
	printf "[*] "
	jsonnet --version
else
	printf "[*] "
	jsonnet --version
endif

check-jq: setup-ubuntu-repositories
ifndef JQ_INSTALLED
	echo "[ ] Did not find jq, install using sudo apt-get install jq"
else
	printf "[*] "
	jq --version
endif

check-user-in-docker-group:
ifndef USER_IN_DOCKER_GROUP
	echo "[ ] User $$USER is not in docker group, sudo will be required and scripts won't work."
else
	echo "[*] User $$USER is in docker group"
endif

check-docker:
ifndef DOCKER_INSTALLED
	echo "[ ] Unable to find docker, install it using 'make setup-docker'."
else
	printf "[*] "
	docker --version
endif

check-docker-compose: check-docker
ifndef DOCKER_COMPOSE_INSTALLED
	echo "[ ] Unable to find docker-compose, install it using 'make setup-docker'."
else
	printf "[*] "
	docker-compose --version
endif

check-docker-networks: check-docker
ifndef DOCKER_NETWORKS_SETUP
	echo "[ ] Docker networks not setup yet, configure it with 'make setup-docker-networks'."
else
	echo "[*] Docker networks setup"
endif

check-ctop:
ifndef CTOP_INSTALLED
	echo "Did not find ctop, creating link to shell/ctop version"
	sudo ln -s $(CWD)/shell/ctop-v0.7.1 /usr/local/bin/ctop
	ls -al /usr/local/bin/ctop
	printf "[*] "
	ctop -v
else
	printf "[*] "
	ctop -v
endif

check-prometheus-node-exporter: setup-ubuntu-repositories
ifndef PROM_NODE_EXPORTER_INSTALLED
	printf "[ ] Node Exporter not installed, run sudo apt-get install prometheus-node-exporter"
else
	printf "[*] "
	prometheus-node-exporter --version 2>&1 | head -n 1
	echo ""
endif

## Remove all containers that have exited
clean-exited-containers:
	docker ps -aq --no-trunc -f status=exited | xargs docker rm

## Remove all dangling or untagged container images
clean-dangling-untagged-container-images:
	docker images -q --filter dangling=true | xargs docker rmi

TARGET_MAX_CHAR_NUM=20
## All targets should have a ## Help text above the target and they'll be automatically collected
## Show help, using auto generator from https://gist.github.com/prwhite/8168133
help:
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
