local applianceConf = import "CAF.conf.jsonnet";
local containerConf = import "container.conf.json";

local webServicePort = applianceConf.sharedContainers.prometheusSqlAgentExporter.webServicePort;
local webServicePortInContainer = webServicePort;

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3',

		services: {
			container: {
				container_name: containerConf.containerName,
				image: 'dbhi/prometheus-sql',
				restart: 'always',
				ports: [webServicePort + ':' + webServicePortInContainer],
				networks: ['network'],
				volumes: [
					containerConf.containerRuntimeConfigHome + '/data-sources.yml:/data-sources.yml',
					containerConf.containerRuntimeConfigHome + '/queries:/queries',
				],
				// TODO: replace the -service config with a CAF.libsonnet function call so multiple containers can share
				command: "-port "+ webServicePortInContainer + " " +
				         "-service http://" + containerConf.DOCKER_HOST_IP_ADDR + ":" + applianceConf.sharedContainers.sqlAgent.webServicePort + " " +
				         "-config /data-sources.yml " +
						 "-queryDir /queries"
			}
		},

		networks: {
			network: {
				external: {
					name: applianceConf.defaultDockerNetworkName
				},
			},
		},
	}),
}