//local appliance = import "../appliance.libsonnet";
local containerName = std.extVar('containerName');
local defaultNetworkName = std.extVar('defaultNetworkName');

[{
	version: '3',

	services: {
		container: {
			container_name: containerName,
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