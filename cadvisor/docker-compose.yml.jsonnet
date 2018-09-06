local containerName = std.extVar('containerName');
local defaultNetworkName = std.extVar('defaultNetworkName');
local CAFconf = import "../CAF.conf.jsonnet";

[{
	version: '3',

	services: {
		container: {
			container_name: containerName,
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
}]