# Default Makefile targets for simple docker-compose.yml.jsonnet source with a
# custom volume with the same name as the container (directory it's in).

DOCKER_COMPOSE_YAML := docker-compose.yml
DOCKER_COMPOSE_JSONNET := $(DOCKER_COMPOSE_YAML).jsonnet

default: configure

configure: generate-container-conf $(DOCKER_COMPOSE_YAML) 

## Create Docker volumes used by the container
create-volumes: configure
	printf "Creating Docker volume "
	docker volume create $(CONTAINER_NAME)
	docker volume inspect $(CONTAINER_NAME) --format "Volume $(CONTAINER_NAME) mountpoint: '{{printf .Mountpoint }}'"

## If the container is running, inspect its settings
inspect: configure
	docker ps -a | grep $(CONTAINER_NAME)
	docker volume inspect $(CONTAINER_NAME)
	docker port $(CONTAINER_NAME)

## If the container is running, show its logs
logs: configure
	docker logs $(CONTAINER_NAME)

## If the container is running, show its ports
ports: configure
	docker port $(CONTAINER_NAME)

## Start the container and all dependencies
start: configure create-volumes
	docker-compose up -d --force-recreate

## Stop the container but retain external volumes and networks
stop: configure
	docker-compose down

## DANGEROUS: Stop the container and DELETE ALL volumes
clean: stop 
	printf "Removing volume "
	docker volume rm $(CONTAINER_NAME)
	echo "Removing generated docker-compose YAML config"
	rm -f $(DOCKER_COMPOSE_YAML)
	echo "Removing generated container config"
	rm -f $(CONTAINER_CONF_GENERATED_FILE)
