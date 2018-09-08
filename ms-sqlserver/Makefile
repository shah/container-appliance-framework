SHELL := /bin/bash
MAKEFLAGS := silent

include ../lib/common-preamble.make.inc
include ../lib/docker-compose-jsonnet-targets.make.inc

## Start the container and all dependencies but don't finish until the container is healthy
start-and-wait-until-healthy: configure create-volumes
	docker-compose up -d --force-recreate
	./wait-until-healthy.sh $(CONTAINER_NAME)

## Run a SQL command in the container
sqlcmd:
	sudo docker exec -it $(CONTAINER_NAME) /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $(DBA_USER_PASSWORD)

include ../lib/common-targets.make.inc
