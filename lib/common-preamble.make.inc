CURRENT_DIR_PATH := $(shell echo `pwd`)
CURRENT_DIR_NAME := $(shell basename `pwd`)
CONTAINER_NAME := $(CURRENT_DIR_NAME)
DOCKER_NETWORK_NAME := appliance

# ../ would be CAF repo root
CAF_CONF_FILE := ../CAF.conf.jsonnet

# ../../ would be CAF's repo parent (as part of another appliance)
APPLIANCE_CONF_FILE := ../../appliance.conf.jsonnet

# If the APPLIANCE_CONF_FILE exists, then the CAF is acting as a submodule to
# a "primary" appliance so let's let the rest of the Makefile act accordingly
ifneq ("$(wildcard $(APPLIANCE_CONF_FILE))","")
PRIMARY_CONF_FILE = APPLIANCE_CONF_FILE
IS_SUBMODULE = 1
else
PRIMARY_CONF_FILE = CAF_CONF_FILE
IS_SUBMODULE = 0
endif
