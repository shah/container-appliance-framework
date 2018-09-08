local applianceConf = import "CAF.conf.jsonnet";
local containerConf = import "container.conf.json";

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3.4',

		services: {
			container: {
				build: '.',
				container_name: containerConf.containerName,
				image: containerConf.containerName + ':latest',
				restart: 'always',
				ports: ['4260:4260'],
				networks: ['network'],
				volumes: ['storage:/root/.databaseflow'],
				labels: {
					'traefik.enable': 'true',
					'traefik.docker.network': applianceConf.defaultDockerNetworkName,
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
					name: applianceConf.defaultDockerNetworkName
				},
			},
		},

		volumes: {
			storage: { 
				name: containerConf.containerName
			},
		},
	})
}