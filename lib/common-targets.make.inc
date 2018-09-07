generate-container-conf:
	echo "Generating $(CONTAINER_CONF_GENERATED_FILE) from $(CONTAINER_CONF_JSONNET_TMPL)"
	jsonnet --ext-str GENERATED_ON="`date`" \
			--ext-str CAF_HOME=$(CAF_HOME) \
			--ext-str APPLIANCE_HOME=$(APPLIANCE_HOME) \
			--ext-str IS_SUBMODULE=$(IS_SUBMODULE) \
	        --ext-str containerName=$(CONTAINER_NAME) \
	        --ext-str defaultNetworkName=$(DOCKER_NETWORK_NAME) \
			--ext-str containerRootPath=$(CONTAINER_PATH) \
			--ext-str currentUserName=$(CURRENT_USER) \
			--ext-str currentUserId=$(CURRENT_USER_ID) \
			--ext-str currentUserGroupId=$(CURRENT_USER_GROUP_ID) \
			--ext-str currentUserHome=$(CURRENT_USER_HOME) \
			-o $(CONTAINER_CONF_GENERATED_FILE) \
			$(CONTAINER_CONF_JSONNET_TMPL)

$(DOCKER_COMPOSE_YAML): $(DOCKER_COMPOSE_JSONNET)
	echo "Generating $(DOCKER_COMPOSE_YAML) from $(DOCKER_COMPOSE_JSONNET)"
	jsonnet -y -o $(DOCKER_COMPOSE_YAML) $(DOCKER_COMPOSE_JSONNET)
	echo "Validating $(DOCKER_COMPOSE_YAML)"
	docker-compose config --quiet

clean-generated-artifacts:
	echo "Removing generated docker-compose YAML config"
	rm -f $(DOCKER_COMPOSE_YAML)
	echo "Removing generated container config"
	rm -f $(CONTAINER_CONF_GENERATED_FILE)
	
TARGET_MAX_CHAR_NUM=10
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
	@echo ''
	@echo 'Environment:'		
	@echo '  DOCKER_HOST_IP_ADDR: $(DOCKER_HOST_IP_ADDR)'
	@echo '  CAF_HOME: $(CAF_HOME)'
	@echo '  APPLIANCE_HOME: $(APPLIANCE_HOME)'	
	@echo '  PRIMARY_CONF_FILE: $(PRIMARY_CONF_FILE)'		
	@echo '  IS_SUBMODULE: $(IS_SUBMODULE)'
	@echo '  CURRENT_USER: $(CURRENT_USER) ($(CURRENT_USER_ID):$(CURRENT_USER_GROUP_ID))'
	@echo '  CURRENT_USER_HOME: $(CURRENT_USER_HOME)'	
	@echo '  CONTAINER_NAME: $(CONTAINER_NAME)'
	@echo '  CONTAINER_PATH: $(CONTAINER_PATH)'
	@echo '  DOCKER_NETWORK_NAME: $(DOCKER_NETWORK_NAME)'
