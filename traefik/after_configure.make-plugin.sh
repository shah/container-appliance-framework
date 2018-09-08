#!/bin/bash

echo "Preparing ACME config permissions for LetsEncrypt configuration"
sudo touch acme.json
sudo chmod 600 acme.json
