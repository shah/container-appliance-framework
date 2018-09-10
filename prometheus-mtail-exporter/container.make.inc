MTAIL_VERSION_IN_CONTAINER := $(shell docker inspect --format "{{ index .Config.Labels \""deploy.mtail.releases.version"\"}}" $(CONTAINER_NAME))

## Get the examples from the deployed version of mtail
get-mtail-examples:
	echo "Downloading mtail $(MTAIL_VERSION_IN_CONTAINER) examples from source release package on GitHub"
	wget -O mtail-SRC-$(MTAIL_VERSION_IN_CONTAINER).tar.gz https://github.com/google/mtail/archive/v$(MTAIL_VERSION_IN_CONTAINER).tar.gz
	tar -xzf mtail-SRC-$(MTAIL_VERSION_IN_CONTAINER).tar.gz
	mv mtail-$(MTAIL_VERSION_IN_CONTAINER)/examples ./mtail-$(MTAIL_VERSION_IN_CONTAINER)-examples
	rm -rf mtail-SRC-$(MTAIL_VERSION_IN_CONTAINER).tar.gz mtail-$(MTAIL_VERSION_IN_CONTAINER)
	echo "Examples are available in ./mtail-$(MTAIL_VERSION_IN_CONTAINER)-examples"
