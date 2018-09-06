//local appliance = import "../appliance.libsonnet";
local containerName = std.extVar('containerName');
local defaultNetworkName = std.extVar('defaultNetworkName');
local CAFconf = import "../CAF.conf.jsonnet";

[{
	version: '3',

	services: {
		container: {
			build: '.',
			container_name: containerName,
			image: containerName + ':latest',
			restart: 'always',
			ports: ['4260:4260'],
			networks: ['network'],
			volumes: ['volume:/root/.databaseflow'],
			labels: {
				'traefik.enable': 'true',
				'traefik.docker.network': defaultNetworkName,
				'traefik.domain': containerName + '.' + CAFconf.applianceFQDN,
				'traefik.backend': containerName,
				'traefik.frontend.entryPoints': 'http,https',
				'traefik.frontend.rule': 'Host:' + containerName + '.' + CAFconf.applianceFQDN,
			}
		}
	},

	networks: {
		network: {
			external: {
				name: defaultNetworkName
			},
		},
	},

	volumes: {
		volume: {
			external: {
				name: containerName
			},
		},
	},
}]