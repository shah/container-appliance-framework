local applianceConf = import "../CAF.conf.jsonnet";
local containerConf = import "container.conf.json";

[{
	version: '3',

	services: {
		container: {
			container_name: containerConf.containerName,
			image: 'google/cadvisor:latest',
			restart: 'always',
			ports: ['8080:8080'],
			networks: ['network'],
			volumes: [
				'/:/rootfs:ro',
				'/var/run:/var/run:rw',
				'/sys:/sys:ro',
				'/var/lib/docker/:/var/lib/docker:ro',
				'/dev/disk/:/dev/disk:ro'
			],
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