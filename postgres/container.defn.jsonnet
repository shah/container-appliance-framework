local applianceConf = import "CAF.conf.jsonnet";
local containerConf = import "container.conf.json";
local containerSecrets = import "postgres.secrets.jsonnet";

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3.4',

		services: {
			container: {
				container_name: containerConf.containerName,
				image: 'postgres',
				restart: 'always',
				ports: [containerSecrets.databasePort + ':5432'],
				networks: ['network'],
				volumes: ['storage:/var/lib/postgresql/data'],
				environment: [
					'POSTGRES_USER=' + containerSecrets.adminUser,
					'POSTGRES_PASSWORD=' + containerSecrets.adminPassword
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
		while [ $(docker inspect --format "{{json .State.Status }}" $CONTAINER_NAME) != "\"running\"" ]; do printf "."; sleep 1; done
		echo "done."
	|||
}