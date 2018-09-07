DOCKER_HOST_IP_ADDR := $(shell echo `/sbin/ifconfig eth0 | grep -i mask | awk '{print $$2}'| cut -f2 -d:`)
CURRENT_USER := $(shell echo `whoami`)
CURRENT_USER_ID := $(shell echo `id -u`)
CURRENT_USER_GROUP_ID := $(shell echo `id -g`)
CURRENT_USER_HOME := $(HOME)
CURRENT_DIR_PATH := $(shell echo `pwd`)
CURRENT_DIR_NAME := $(shell basename `pwd`)

CONTAINER_NAME := $(CURRENT_DIR_NAME)
CONTAINER_PATH := $(CURRENT_DIR_PATH)

CAF_HOME = $(shell realpath ../)
APPLIANCE_HOME = $(shell realpath $(CAF_HOME)/..)

DOCKER_NETWORK_NAME := appliance

CAF_CONF_FILE := $(CAF_HOME)/CAF.conf.jsonnet
APPLIANCE_CONF_FILE := $(APPLIANCE_HOME)/appliance.conf.jsonnet

# If the APPLIANCE_CONF_FILE exists, then the CAF is acting as a submodule to
# a "primary" appliance so let's let the rest of the Makefile act accordingly
ifneq ("$(wildcard $(APPLIANCE_CONF_FILE))","")
PRIMARY_CONF_FILE = $(APPLIANCE_CONF_FILE)
IS_SUBMODULE = 1
else
PRIMARY_CONF_FILE = $(CAF_CONF_FILE)
APPLIANCE_HOME = $(CAF_HOME)
IS_SUBMODULE = 0
endif

CONTAINER_CONF_JSONNET_TMPL := $(CAF_HOME)/lib/container.conf.tmpl.jsonnet
CONTAINER_CONF_GENERATED_FILE := container.conf.json
