//local appliance = import "../appliance.libsonnet";
local applianceConf = import "../CAF.conf.jsonnet";
local containerConf = import "container.conf.json";

local containerLogPath = containerConf.containerRootPath + '/log';

[{
	version: '3',

	services: {
		container: {
			container_name: containerConf.containerName,
			image: 'traefik:latest',
			restart: 'always',
			ports: ['80:80', '443:443', '8099:8099'],
			networks: ['network'],
			volumes: [
				'/var/run/docker.sock:/var/run/docker.sock',
				containerConf.containerRootPath + '/traefik.toml:/traefik.toml',
				containerConf.containerRootPath + '/acme.json:/acme.json',
				containerLogPath + '/service.log:/var/log/traefik-service.log',
				containerLogPath + '/access.log:/var/log/traefik-access.log',
			],
		}
	},

	networks: {
		network: {
			external: {
				name: containerConf.defaultNetworkName
			},
		},
	},
}]