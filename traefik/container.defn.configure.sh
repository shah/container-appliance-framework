#!/bin/bash

echo "Preparing ACME config permissions for LetsEncrypt configuration"
touch acme.json
chmod 600 acme.json
