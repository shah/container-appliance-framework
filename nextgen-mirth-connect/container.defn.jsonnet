local applianceConf = import "CAF.conf.jsonnet";
local containerConf = import "container.conf.json";
local containerSecrets = import "nextgen-mirth-connect.secrets.jsonnet";

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3.4',

		services: {
			container: {
				build: '.',
				container_name: containerConf.containerName,
				image: containerConf.containerName + ':latest',
				restart: 'always',
				ports: [
					'8180:8080',
					'8443:8443'
				],
				networks: ['network'],
				volumes: [
					'storage:/var/spool/mirth',
					containerConf.containerRuntimeConfigHome + "/mirth.properties:/opt/mirth-connect/conf/mirth.properties",
				],
				labels: {
					'traefik.enable': 'true',
					'traefik.docker.network': applianceConf.defaultDockerNetworkName,
					'traefik.domain': containerConf.containerName + '.' + applianceConf.applianceFQDN,
					'traefik.backend': containerConf.containerName,
					'traefik.frontend.entryPoints': 'http,https',
					'traefik.frontend.rule': 'Host:' + containerConf.containerName + '.' + applianceConf.applianceFQDN,
				}
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
	}),

	// This will be put into the container as the "starter" user for the mirth MySQL user
	"setup-mysql-db.sql" : |||
		CREATE USER '%(dbUserName)s'@'localhost' IDENTIFIED BY '%(dbUserPassword)s';
		GRANT USAGE ON *.* TO '%(dbUserName)s'@'localhost'
		    IDENTIFIED BY '%(dbUserPassword)s'
		    WITH MAX_QUERIES_PER_HOUR 0 
				 MAX_CONNECTIONS_PER_HOUR 0 
				 MAX_UPDATES_PER_HOUR 0 
				 MAX_USER_CONNECTIONS 0;
		CREATE DATABASE IF NOT EXISTS `%(database)s`;
		GRANT ALL PRIVILEGES ON `%(database)s`.* TO '%(dbUserName)s'@'localhost';
	||| % { database : containerSecrets.database, dbUserName : containerSecrets.dbUserName, dbUserPassword : containerSecrets.dbUserPassword },
}
