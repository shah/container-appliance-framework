local applianceConf = import "CAF.conf.jsonnet";
local containerConf = import "container.conf.json";

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3',

		services: {
			container: {
				container_name: containerConf.containerName,
				image: 'linuxserver/syncthing', // https://github.com/linuxserver/docker-syncthing
				restart: 'always',
				ports: [
					'8384:8384',
					'22000:22000',
					'21027:21027/udp'
				],
				networks: ['network'],
				volumes: [
					'*host path to config*:/config', // TODO: fill this out
					'*host path to data*:/mnt/any/dir/you/want', // TODO: fill this out
				],
				environment: [
					"PUID=" + containerConf.currentUserId,
					"PGID=" + containerConf.currentUserGroupId
				],
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
	})
}
