local applianceConf = import "../CAF.conf.jsonnet";
local containerConf = import "container.conf.json";

[{
	version: '3',

	services: {
		container: {
			container_name: containerConf.containerName,
			image: 'dbhi/sql-agent',
			restart: 'always',
			ports: ['5000:5000'],
			networks: ['network'],
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
}]