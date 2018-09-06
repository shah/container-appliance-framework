# Default Makefile targets for simple docker-compose.yml.jsonnet source
# with an external default network and no volumes.

DOCKER_COMPOSE_YAML := docker-compose.yml
DOCKER_COMPOSE_JSONNET := $(DOCKER_COMPOSE_YAML).jsonnet

default: configure

$(DOCKER_COMPOSE_YAML): $(DOCKER_COMPOSE_JSONNET)
	echo "Generating $(DOCKER_COMPOSE_YAML) from $(DOCKER_COMPOSE_JSONNET)"
	jsonnet --ext-str CAF_HOME=$(CAF_HOME) \
			--ext-str APPLIANCE_HOME=$(APPLIANCE_HOME) \
			--ext-str IS_SUBMODULE=$(IS_SUBMODULE) \
	        --ext-str containerName=$(CONTAINER_NAME) \
	        --ext-str defaultNetworkName=$(DOCKER_NETWORK_NAME) \
			--ext-str containerRootPath=$(CONTAINER_PATH) \
			--ext-str currentUserName=$(CURRENT_USER) \
			--ext-str currentUserHome=$(CURRENT_USER_HOME) \
			-y -o $(DOCKER_COMPOSE_YAML) \
			-S $(DOCKER_COMPOSE_JSONNET)
	echo "Validating $(DOCKER_COMPOSE_YAML)"
	docker-compose config --quiet

configure: $(DOCKER_COMPOSE_YAML) 

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
