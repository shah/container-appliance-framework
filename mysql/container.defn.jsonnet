local applianceConf = import "CAF.conf.jsonnet";
local containerConf = import "container.conf.json";
local containerSecrets = import "mysql.secrets.jsonnet";

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3.4',

		services: {
			container: {
				container_name: containerConf.containerName,
				image: 'mysql/mysql-server',
				restart: 'always',
				ports: [containerSecrets.databasePort + ':3306'],
				command: "mysqld --innodb-buffer-pool-size=20M",
				networks: ['network'],
				volumes: ['storage:/var/lib/mysql'],
				environment: [
					'MYSQL_ROOT_HOST=%',  // allow root access from any host (TODO: make this secure later)
					'MYSQL_ROOT_PASSWORD=' + containerSecrets.rootPassword
				]
			}
		},

		networks: {
			network: {
				external: {
					name: applianceConf.defaultDockerNetworkName
				},
			},
		},

		volumes: {
			storage: {
				name: containerConf.containerName
			},
		},
	}),

	"after_start.make-plugin.sh" : |||
		#!/bin/bash
		CONTAINER_NAME=$1
		printf "Waiting until $CONTAINER_NAME is healthy."
		while [ $(docker inspect --format "{{json .State.Health.Status }}" $CONTAINER_NAME) != "\"healthy\"" ]; do printf "."; sleep 1; done
		echo "done."
	|||
}