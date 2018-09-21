local applianceConf = import "CAF.conf.jsonnet";
local containerConf = import "container.conf.json";
local containerSecrets = import "samba.secrets.jsonnet";
local sambaConf = import "samba.conf.jsonnet";

local command(cmd, params, repl) = [cmd, params % repl];

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
				command: 
					std.flattenArrays(
						[command("-u", "%(userName)s;%(password)s;%(userId)d;%(groupName)s", x) for x in containerSecrets.sambaUsers] +
						[command("-s", "%(shareName)s;%(sharePathInContainer)s;%(browseable)s;%(readOnly)s;%(guest)s;%(users)s;%(admins)s;%(usersThatCanWriteToROShare)s;%(comment)s", x) for x in sambaConf.sambaShares]
					),
				volumes:
					["%(sharePathInHost)s:%(sharePathInContainer)s" % x for x in sambaConf.sambaShares],
				environment: [
					'USERID=1000',
					'GROUPID=1000',
					'TZ=EST5EDT',
					'NMBD=True',
					'RECYCLE=False',
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
