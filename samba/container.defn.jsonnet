local applianceConf = import "CAF.conf.jsonnet";
local containerConf = import "container.conf.json";
local containerSecrets = import "samba.secrets.jsonnet";

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3',

		services: {
			container: {
				container_name: containerConf.containerName,
				image: 'dperson/samba',
				restart: 'always',
				ports: ['139:139', '445:445'],
				networks: ['network'],
				command: '-s ' + '"' + containerConf.currentUser.name + '_Home;/'+ containerConf.currentUser.name +'_Home;yes;no;yes;'+ containerSecrets.homeShareUserName +';'+ containerSecrets.homeSharePassword +'"',
				volumes: [
					containerConf.currentUser.home + ':/'+ containerConf.currentUser.name +'_Home',
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
					name: applianceConf.defaultDockerNetworkName
				},
			},
		},
	})
}
