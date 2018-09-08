local applianceConf = import "CAF.conf.jsonnet";
local containerConf = import "container.conf.json";

{
	"docker-compose.yml" : {
		version: '3',

		services: {
			container: {
				container_name: containerConf.containerName,
				image: 'dperson/samba',
				restart: 'always',
				ports: ['139:139', '445:445'],
				networks: ['network'],
				command: '-s ' + '"' + containerConf.currentUserName + '_Home;/'+ containerConf.currentUserName +'_Home;yes;no;yes;admin;admin"',
				volumes: [
					containerConf.currentUserHome + ':/'+ containerConf.currentUserName +'_Home',
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
					name: containerConf.defaultNetworkName
				},
			},
		},
	}
}