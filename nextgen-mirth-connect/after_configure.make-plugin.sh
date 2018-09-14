#!/bin/bash

echo "Create the same user that the Dockerfile does, otherwise will get permission errors"
echo "TODO: don't hardcode the userId or userName, pass them using ARG in Dockerfile"
sudo useradd -u 1000 mirth
