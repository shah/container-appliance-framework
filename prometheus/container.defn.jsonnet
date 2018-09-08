local applianceConf = import "CAF.conf.jsonnet";
local containerConf = import "container.conf.json";

local webServicePort = 8010;
local promConfigFileInContainer = '/etc/prometheus/prometheus.yml';
local tsdbStoragePathInContainer = '/var/prometheus/data';

{
	"docker-compose.yml" : {
		version: '3.4',

		services: {
			container: {
				container_name: containerConf.containerName,
				image: 'prom/prometheus:latest',
				command: '--storage.tsdb.path='+ tsdbStoragePathInContainer +' --web.listen-address :'+ webServicePort +' --config.file=' + promConfigFileInContainer,
				restart: 'always',
				ports: [webServicePort + ':' + webServicePort],
				networks: ['network'],
				volumes: [
					'storage:' + tsdbStoragePathInContainer,
					containerConf.containerDefnHome + '/prometheus.yml:' + promConfigFileInContainer,
				],
				user: "root", // SNS: by default Prometheus container runs as nobody:nogroup but volumes are owned by root so we switch
				labels: {
					'traefik.enable': 'true',
					'traefik.docker.network': containerConf.defaultNetworkName,
					'traefik.domain': containerConf.containerName + '.' + applianceConf.applianceFQDN,
					'traefik.backend': containerConf.containerName,
					'traefik.frontend.entryPoints': 'http,https',
					'traefik.frontend.rule': 'Host:' + containerConf.containerName + '.' + applianceConf.applianceFQDN,
				}
			},
		},

		networks: {
			network: {
				external: {
					name: containerConf.defaultNetworkName
				},
			},
		},

		volumes: {
			storage: {
				name: containerConf.containerName
			},
		},
	}
}