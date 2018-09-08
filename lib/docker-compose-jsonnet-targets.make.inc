# Default Makefile targets for simple docker-compose.yml.jsonnet source
# with an external default network and no volumes.

default: inspect

CUSTOM_CONFIGURE_SCRIPT_NAME := ./container.defn.configure.sh

configure: generate-container-conf
ifneq ("$(wildcard $(CUSTOM_CONFIGURE_SCRIPT_NAME))","")
	echo "Found custom configuration script $(CUSTOM_CONFIGURE_SCRIPT_NAME) for $(CONTAINER_NAME)"
	$(CUSTOM_CONFIGURE_SCRIPT_NAME) $(CONTAINER_NAME)
else
	echo "No custom configuration script $(CUSTOM_CONFIGURE_SCRIPT_NAME) found for $(CONTAINER_NAME)"
endif

## If the container is running, inspect its settings
inspect:
ifdef CONTAINER_IS_RUNNING
	docker ps -a --filter "name=$(CONTAINER_NAME)" --format "table {{.ID}} {{.Names}}\t{{.Status}}\t{{.Ports}}\\t{{.Networks}}"
	printf "Volumes: "
	docker inspect -f '{{ json .Mounts }}' $(CONTAINER_NAME) | jq 
else
	echo "Container $(CONTAINER_NAME) is not running, here's docker ps -a:"
	echo ''
	docker ps -a --format "table {{.ID}} {{.Names}}\t{{.Status}}"
endif

## If the container is running, show its logs
logs:
ifdef CONTAINER_IS_RUNNING
	docker logs $(CONTAINER_NAME)
else
	echo "Container $(CONTAINER_NAME) is not running, here's docker ps -a:"
	echo ''
	docker ps -a --format "table {{.ID}} {{.Names}}\t{{.Status}}"
endif

## If the container is running, show its ports
ports:
ifdef CONTAINER_IS_RUNNING
	docker port $(CONTAINER_NAME)
else
	echo "Container $(CONTAINER_NAME) is not running, here's docker ps -a:"
	echo ''
	docker ps -a --format "table {{.ID}} {{.Names}}\t{{.Status}}"
endif

## Start the container and all dependencies
start: configure
	docker-compose up -d --force-recreate

## Stop the container but retain volumes and generated files
stop: configure
	docker-compose down

## Stop the container and delete associated volumes
kill: configure
	docker-compose down --volumes

## Stop the container and clean up generated files
clean: kill clean-generate-container-conf
