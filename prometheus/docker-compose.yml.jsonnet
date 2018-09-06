local containerName = std.extVar('containerName');
local containerRootPath = std.extVar('containerRootPath');
local defaultNetworkName = std.extVar('defaultNetworkName');
local CAFconf = import "../CAF.conf.jsonnet";

local webServicePort = 8010;
local promConfigFileInContainer = '/etc/prometheus/prometheus.yml';
local tsdbStoragePathInContainer = '/var/prometheus/data';

[{
	version: '3',

	services: {
		container: {
			container_name: containerName,
			image: 'prom/prometheus:latest',
			command: '--storage.tsdb.path='+ tsdbStoragePathInContainer +' --web.listen-address :'+ webServicePort +' --config.file=' + promConfigFileInContainer,
			restart: 'always',
			ports: [webServicePort + ':' + webServicePort],
			networks: ['network'],
			volumes: [
				'volume:' + tsdbStoragePathInContainer,
				containerRootPath + '/prometheus.yml:' + promConfigFileInContainer,
			],
			user: "root", // SNS: by default Prometheus container runs as nobody:nogroup but volumes are owned by root so we switch
			labels: {
				'traefik.enable': 'true',
				'traefik.docker.network': defaultNetworkName,
				'traefik.domain': containerName + '.' + CAFconf.applianceFQDN,
				'traefik.backend': containerName,
				'traefik.frontend.entryPoints': 'http,https',
				'traefik.frontend.rule': 'Host:' + containerName + '.' + CAFconf.applianceFQDN,
			}
		},
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