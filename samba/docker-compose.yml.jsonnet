//local appliance = import "../appliance.libsonnet";
local containerName = std.extVar('containerName');
local defaultNetworkName = std.extVar('defaultNetworkName');
local currentUserName = std.extVar('currentUserName');
local currentUserHome = std.extVar('currentUserHome');

[{
	version: '3',

	services: {
		container: {
			container_name: containerName,
			image: 'dperson/samba',
			restart: 'always',
			ports: ['139:139', '445:445'],
			networks: ['network'],
			command: '-s ' + '"' + currentUserName + '_Home;/'+ currentUserName +'_Home;yes;no;yes;admin;admin"',
			volumes: [
				currentUserHome + ':/'+ currentUserName +'_Home',
			],
			environment: [
				'USERID=1000',
				'GROUPID=1000',
				'TZ=EST5EDT',
				'NMBD=True',
				'RECYCLE=False',
				'USER=admin;admin;1001;admin'
			],
		}
	},

	networks: {
		network: {
			external: {
				name: defaultNetworkName
			},
		},
	},
}]