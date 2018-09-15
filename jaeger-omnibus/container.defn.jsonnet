local applianceConf = import "CAF.conf.jsonnet";
local containerConf = import "container.conf.json";

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3',

		services: {
			container: {
				container_name: containerConf.containerName,
				image: 'jaegertracing/all-in-one:latest',
				restart: 'always',
				ports: [
					'5775:5775/udp',
					'6831:6831/udp',
					'6832:6832/udp',
					'5778:5778',
					'16686:16686',
					'14268:14268',
					'9411:9411'
				],
				networks: ['network'],
				environment: [
					'COLLECTOR_ZIPKIN_HTTP_PORT=9411',
				],
				labels: {
					'traefik.enable': 'true',
					'traefik.port': '16686',
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
	})
}
