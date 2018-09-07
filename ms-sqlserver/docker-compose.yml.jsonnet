local applianceConf = import "../CAF.conf.jsonnet";
local containerConf = import "container.conf.json";

[{
	version: '3',

	services: {
		container: {
			container_name: containerConf.containerName,
			image: 'microsoft/mssql-server-linux',
			restart: 'always',
			ports: ['1433:1433'],
			networks: ['network'],
			volumes: ['volume:/var/opt/mssql'],
			environment: ['SA_PASSWORD=Admin+001', 'ACCEPT_EULA=Y']
		}
	},

	networks: {
		network: {
			external: {
				name: containerConf.defaultNetworkName
			},
		},
	},

	volumes: {
		volume: {
			external: {
				name: containerConf.containerName
			},
		},
	},
}]