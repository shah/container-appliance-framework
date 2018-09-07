# This is considered a "typical" container Makefile and is designed to be 
# symlink'd from a container directory as "Makefile"

SHELL := /bin/bash
MAKEFLAGS := silent

include ../lib/common-preamble.make.inc
include ../lib/docker-compose-jsonnet-targets.make.inc
include ../lib/common-targets.make.inc
