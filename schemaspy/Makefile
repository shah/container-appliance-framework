SHELL := /bin/bash
MAKEFLAGS := silent
CWD := `pwd`
CONFIG_PATH := $(CWD)
DOCS_PATH := $(CWD)/html

default: schemaspy

$(DOCS_PATH): 
	echo "Creating documentation directory $(DOCS_PATH)"
	mkdir -p $(DOCS_PATH)

schemaspy: $(DOCS_PATH)
	docker run --rm -v "$(DOCS_PATH):/output" -v "$(CONFIG_PATH):/config" schemaspy/schemaspy -configFile /config/schemaspy.conf

clean: 
	echo "Removing documentation directory $(DOCS_PATH)"
	rm -rf $(DOCS_PATH)
