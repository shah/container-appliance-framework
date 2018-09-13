local applianceConf = import "CAF.conf.jsonnet";
local containerConf = import "container.conf.json";
local containerSecrets = import "ms-sqlserver.secrets.jsonnet";

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3.4',

		services: {
			container: {
				container_name: containerConf.containerName,
				image: 'microsoft/mssql-server-linux',
				restart: 'always',
				ports: ['1433:1433'],
				networks: ['network'],
				volumes: ['storage:/var/opt/mssql'],
				environment: ['SA_PASSWORD=' + containerSecrets.SA_password, 'ACCEPT_EULA=Y']
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