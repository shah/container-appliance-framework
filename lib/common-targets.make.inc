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
	@echo '  CAF_HOME: $(CAF_HOME)'
	@echo '  APPLIANCE_HOME: $(APPLIANCE_HOME)'	
	@echo '  PRIMARY_CONF_FILE: $(PRIMARY_CONF_FILE)'		
	@echo '  IS_SUBMODULE: $(IS_SUBMODULE)'
	@echo '  CURRENT_USER: $(CURRENT_USER)'
	@echo '  CURRENT_USER_HOME: $(CURRENT_USER_HOME)'	
	@echo '  CONTAINER_NAME: $(CONTAINER_NAME)'
	@echo '  CONTAINER_PATH: $(CONTAINER_PATH)'
	@echo '  DOCKER_NETWORK_NAME: $(DOCKER_NETWORK_NAME)'
