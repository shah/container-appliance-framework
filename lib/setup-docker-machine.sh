#!/bin/bash

TARGET=docker-machine
GITHUB_REPO=docker/machine

DOWNLOAD_PATH=/tmp/$TARGET
DEST_PATH=/usr/local/bin/$TARGET

# Determine the latest release
REPO_RELEASE=$(curl --silent "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')

# Download the release from GitHub and install it in /usr/local/bin
rm -f $DOWNLOAD_PATH
curl -L https://github.com/$GITHUB_REPO/releases/download/$REPO_RELEASE/$TARGET-$(uname -s)-$(uname -m) > $DOWNLOAD_PATH
sudo install $DOWNLOAD_PATH $DEST_PATH

$TARGET --version
