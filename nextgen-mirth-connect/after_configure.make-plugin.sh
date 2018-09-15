#!/bin/bash
mkdir -p etc/init.d
sudo useradd -u 1001 cs_mirth
sudo chmod +x "docker-entrypoint.sh"
sudo chmod +x "etc/init.d/setup-mysql-db.sh"

