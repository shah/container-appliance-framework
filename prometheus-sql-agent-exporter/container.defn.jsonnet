local applianceConf = import "CAF.conf.jsonnet";
local containerConf = import "container.conf.json";

local webServicePort = applianceConf.sharedContainers.prometheusSqlAgentExporter.webServicePort;
local webServicePortInContainer = webServicePort;

local dataSourcesConfigFileName = "data-sources-config.yml";
local queriesBasePath = "queries";

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
					containerConf.containerDefnHome + '/'+ queriesBasePath +':/' + queriesBasePath,
					containerConf.containerDefnHome + '/'+ dataSourcesConfigFileName +':/'+ dataSourcesConfigFileName,
				],
				// TODO: replace the -service config with a CAF.libsonnet function call so multiple containers can share
				command: "-port "+ webServicePortInContainer + " " +
				         "-service http://" + containerConf.DOCKER_HOST_IP_ADDR + ":" + applianceConf.sharedContainers.sqlAgent.webServicePort + " " +
				         "-config /" + dataSourcesConfigFileName + " " +
						 "-queryDir /" + queriesBasePath
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

 	"data-sources-config.yml" : std.manifestYamlDoc({
		defaults: {
			"data-source": "ms-sqlserver",
			"query-interval": "10s",
			"query-timeout": "5s",
			"query-value-on-error": -1
		},
		"data-sources": {
			"ms-sqlserver": {
				driver: "mssql",
				properties: {
					host: containerConf.DOCKER_HOST_IP_ADDR,
					port: 1433,
					user: "SA",
					password: "Admin+001",
					database: "cprsql"
				}
			}
		}
	}),
}