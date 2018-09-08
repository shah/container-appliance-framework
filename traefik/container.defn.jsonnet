local manifestToml = import "manifestToml.libsonnet";
local applianceConf = import "CAF.conf.jsonnet";
local containerConf = import "container.conf.json";

local application = 'my-app';
local module = 'uwsgi_module';
local dir = '/var/www';
local permission = 644;

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3.4',

		services: {
			container: {
				container_name: containerConf.containerName,
				image: 'traefik:latest',
				restart: 'always',
				ports: ['80:80', '443:443', '8099:8099'],
				networks: ['network'],
				volumes: [
					'/var/run/docker.sock:/var/run/docker.sock',
					containerConf.containerDefnHome + '/traefik.toml:/traefik.toml',
					containerConf.containerDefnHome + '/acme.json:/acme.json',
					'logs:/var/log/traefik',
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

		volumes: {
			logs: { 
				name: containerConf.containerName + "_logs"
			},
		},
	}),

 	"traefik.toml" : manifestToml({
		"debug": false,
		"logLevel": "INFO",
		"defaultEntryPoints": [
			"https",
			"http"
		],
		"entryPoints": {
			"http": {
				"address": ":80",
				"redirect": {
					"entryPoint": "https"
				}
			},
			"https": {
			"address": ":443",
			"tls": {}
			}
		},
		"retry": {},
		"docker": {
			"endpoint": "unix:///var/run/docker.sock",
			"domain": "appliance.local",
			"watch": true,
			"exposedByDefault": false
		},
		"acme": {
			"email": "admin@appliance.local",
			"storage": "acme.json",
			"entryPoint": "https",
			"onHostRule": true,
			"httpChallenge": {
				"entryPoint": "http"
			}
		},
		"traefikLog": {
			"filePath": "/var/log/traefik/service.log"
		},
		"accessLog": {
			"filePath": "/var/log/traefik/access.log"
		},
		"web": {
			"address": ":8099"
		}
	}),
}