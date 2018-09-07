# Default Makefile targets for simple docker-compose.yml.jsonnet source
# with an external default network and no volumes.

DOCKER_COMPOSE_YAML := docker-compose.yml
DOCKER_COMPOSE_JSONNET := $(DOCKER_COMPOSE_YAML).jsonnet

default: configure

configure: generate-container-conf $(DOCKER_COMPOSE_YAML) 

## If the container is running, inspect its settings
inspect: configure
	docker ps -a | grep $(CONTAINER_NAME)
	docker port $(CONTAINER_NAME)

## If the container is running, show its logs
logs: configure
	docker logs $(CONTAINER_NAME)

## Start the container and all dependencies
start: configure
	docker-compose up -d --force-recreate

## Stop the container but retain generated files
stop: configure
	docker-compose down

## Stop the container and clean up generated files
clean: stop 
	echo "Removing generated docker-compose YAML config"
	rm -f $(DOCKER_COMPOSE_YAML)
	echo "Removing generated container config"
	rm -f $(CONTAINER_CONF_GENERATED_FILE)
