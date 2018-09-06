SHELL := /bin/bash
MAKEFLAGS := silent

include ../lib/common-preamble.make.inc

LOG_PATH := log
DOCKER_COMPOSE_YAML := docker-compose.yml
DOCKER_COMPOSE_JSONNET := $(DOCKER_COMPOSE_YAML).jsonnet

default: configure

$(DOCKER_COMPOSE_YAML): $(DOCKER_COMPOSE_JSONNET)
	echo "Generating $(DOCKER_COMPOSE_YAML) from $(DOCKER_COMPOSE_JSONNET)"
	jsonnet --ext-str containerName=$(CONTAINER_NAME) \
	        --ext-str defaultNetworkName=$(DOCKER_NETWORK_NAME) \
			--ext-str containerRootPath=$(CURRENT_DIR_PATH) \
			-y -o $(DOCKER_COMPOSE_YAML) \
			-S $(DOCKER_COMPOSE_JSONNET)
	echo "Validating $(DOCKER_COMPOSE_YAML)"
	docker-compose config --quiet

configure: $(DOCKER_COMPOSE_YAML) 

setup-dependencies: configure
	echo "Preparing ACME config permissions for LetsEncrypt configuration"
	touch acme.json
	chmod 600 acme.json
	echo "Creating log directory $(LOG_PATH)"
	mkdir -p $(LOG_PATH)
	touch $(LOG_PATH)/access.log
	touch $(LOG_PATH)/service.log

## If the container is running, inspect its settings
inspect: configure
	docker ps -a | grep $(CONTAINER_NAME)
	docker port $(CONTAINER_NAME)

## If the container is running, show its logs
logs: configure
	docker logs $(CONTAINER_NAME)

## Start the container and all dependencies
start: configure setup-dependencies
	docker-compose up -d --force-recreate

## Stop the container but retain generated files
stop: configure
	docker-compose down

## Stop the container and clean up generated files
clean: stop 
	echo "Removing LetsEncrypt configuration"
	rm acme.json
	echo "Removing log directory"
	rm -rf $(LOG_PATH)
	echo "Removing generated docker-compose YAML config"
	rm -f $(DOCKER_COMPOSE_YAML)

include ../lib/common-targets.make.inc
