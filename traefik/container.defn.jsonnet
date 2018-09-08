//local appliance = import "../appliance.libsonnet";
local applianceConf = import "../CAF.conf.jsonnet";
local containerConf = import "container.conf.json";

{
	"docker-compose.yml" : {
		version: '3.4',

		services: {
			container: {
				container_name: containerConf.containerName,
				image: 'traefik:latest',
				restart: 'always',
				ports: ['80:80', '443:443', '8099:8099'],
				networks: ['network'],
				volumes: [
					'/var/run/docker.sock:/var/run/docker.sock',
					containerConf.containerDefnHome + '/traefik.toml:/traefik.toml',
					containerConf.containerDefnHome + '/acme.json:/acme.json',
					'logs:/var/log/traefik',
				],
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
			logs: { 
				name: containerConf.containerName + "_logs"
			},
		},
	}
}