//local appliance = import "../appliance.libsonnet";
local containerRootPath = std.extVar('containerRootPath');
local containerLogPath = containerRootPath + '/log';
local containerName = std.extVar('containerName');
local defaultNetworkName = std.extVar('defaultNetworkName');

[{
	version: '3',

	services: {
		container: {
			container_name: containerName,
			image: 'traefik:latest',
			restart: 'always',
			ports: ['80:80', '443:443', '8099:8099'],
			networks: ['network'],
			volumes: [
				'/var/run/docker.sock:/var/run/docker.sock',
				containerRootPath + '/traefik.toml:/traefik.toml',
				containerRootPath + '/acme.json:/acme.json',
				containerLogPath + '/service.log:/var/log/traefik-service.log',
				containerLogPath + '/access.log:/var/log/traefik-access.log',
			],
		}
	},

	networks: {
		network: {
			external: {
				name: defaultNetworkName
			},
		},
	},
}]