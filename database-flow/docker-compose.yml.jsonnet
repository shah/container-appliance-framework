local applianceConf = import "../CAF.conf.jsonnet";
local containerConf = import "container.conf.json";

[{
	version: '3',

	services: {
		container: {
			build: '.',
			container_name: containerConf.containerName,
			image: containerConf.containerName + ':latest',
			restart: 'always',
			ports: ['4260:4260'],
			networks: ['network'],
			volumes: ['volume:/root/.databaseflow'],
			labels: {
				'traefik.enable': 'true',
				'traefik.docker.network': containerConf.defaultNetworkName,
				'traefik.domain': containerConf.containerName + '.' + applianceConf.applianceFQDN,
				'traefik.backend': containerConf.containerName,
				'traefik.frontend.entryPoints': 'http,https',
				'traefik.frontend.rule': 'Host:' + containerConf.containerName + '.' + applianceConf.applianceFQDN,
			}
		}
	},

	networks: {
		network: {
			external: {
				name: containerConf.defaultNetworkName
			},
		},
	},

	volumes: {
		volume: {
			external: {
				name: containerConf.containerName
			},
		},
	},
}]