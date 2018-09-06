SHELL := /bin/bash
MAKEFLAGS := silent

default: start

start:
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock:ro --pid host --network host -it docker.io/nicolargo/glances

