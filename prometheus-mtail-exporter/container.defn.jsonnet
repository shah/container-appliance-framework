local applianceConf = import "CAF.conf.jsonnet";
local containerConf = import "container.conf.json";
local mtailExporterConf = import "prometheus-mtail-exporter.conf.json";

local webServicePort = mtailExporterConf.webServicePort;
local webServicePortInContainer = webServicePort;
local mtailProgramsHomeInHost = containerConf.containerDefnHome + "/mtail-3.0.0-rc16-examples";
local mtailProgramsHomeInContainer = "/etc/mtail";
local mtailLogsHomeInContainer = "/var/log/mtail";

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3.4',

		services: {
			container: {
				build: '.',
				container_name: containerConf.containerName,
				image: containerConf.containerName + ':latest',
				restart: 'always',
				ports: [webServicePort + ':' + webServicePortInContainer],
				networks: ['network'],
				volumes: [
					"logs:" + mtailLogsHomeInContainer,
				 	mtailProgramsHomeInHost + ':' + mtailProgramsHomeInContainer,
				],
				command: 
					"--port "+ webServicePortInContainer + " " +
					"--progs " + mtailProgramsHomeInContainer + " " +
					"--log_dir " + mtailLogsHomeInContainer + " " +
					"--logs /var/log/syslog", // for testing, this is just logging the internal container's logs
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
			logs: {
				name: containerConf.containerName + "_logs"
			},
		},
	})
}