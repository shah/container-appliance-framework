SHELL := /bin/bash
MAKEFLAGS := silent

include ../lib/common-preamble.make.inc

LOG_PATH := log
DOCKER_COMPOSE_YAML := docker-compose.yml
DOCKER_COMPOSE_JSONNET := $(DOCKER_COMPOSE_YAML).jsonnet

default: configure

configure: generate-container-conf $(DOCKER_COMPOSE_YAML) 

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
	echo "Removing generated container config"
	rm -f $(CONTAINER_CONF_GENERATED_FILE)

include ../lib/common-targets.make.inc
