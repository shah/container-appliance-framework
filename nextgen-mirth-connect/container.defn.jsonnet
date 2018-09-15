local applianceConf = import "CAF.conf.jsonnet";
local containerConf = import "container.conf.json";
local containerSecrets = import "nextgen-mirth-connect.secrets.jsonnet";
local mysqlSecrets = import "mysql.secrets.jsonnet";

local containerUserId = 1001;
local containerUserName = "cs_mirth";

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
					containerConf.containerRuntimeConfigHome + '/init.d/:/docker-entrypoint-init.d',
					containerConf.containerRuntimeConfigHome + "/mirth.properties:/opt/mirth-connect/conf/mirth.properties",
				],
				environment: [
					'MIRTH_SERVICE_USERID=' + containerUserId,
					'MIRTH_SERVICE_USERNAME=' + containerUserName
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

	// This script will be automatically run after the make configure target is called
	// (execute bit will be set automatically upon discovery by the Makefile).
	"after_configure.make-plugin.sh" : |||
		#!/bin/bash
		mkdir -p etc/init.d
		sudo useradd -u %(containerUserId)d %(containerUserName)s
		sudo chmod +x "docker-entrypoint.sh"
		sudo chmod +x "etc/init.d/setup-mysql-db.sh"
	||| % { containerUserId : containerUserId, containerUserName : containerUserName },

	"docker-entrypoint.sh" : |||
		#! /bin/bash
		set -e
		echo "Entered docker-entrypoint.sh at `date`, running scripts in /docker-entrypoint-init.d"
		run-parts --verbose /docker-entrypoint-init.d
		if [ "$1" = 'java' ]; then
			chown -R %(containerUserName)s /opt/mirth-connect/appdata
			exec gosu %(containerUserName)s "$@"
		fi
		exec "$@"
	||| % { containerUserName : containerUserName },

	"etc/init.d/setup-mysql-db.sh" : |||
		if [ -v setup-mysql-db.sh.log ]; then
			echo "User $USER executed setup-mysql-db.sh on `date`" > setup-mysql-db.sh.log
			mysql -h %(host)s -u root -p'$(mysqlRootPasswd)s' < setup-mysql-db.sql >> setup-mysql-db.sh.log
		else
			echo "setup-mysql-db.sh was already run, ignoring."
		fi
	||| % { host : containerConf.DOCKER_HOST_IP_ADDR, mysqlRootPasswd : mysqlSecrets.rootPassword },

	"etc/init.d/setup-mysql-db.sql" : |||
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

	"etc/mirth.properties" : |||
		# directories
		dir.appdata = appdata
		dir.tempdata = ${dir.appdata}/temp
		#
		# ports
		http.port = 8080
		https.port = 8443
		#
		# password requirements
		password.minlength = 0
		password.minupper = 0
		password.minlower = 0
		password.minnumeric = 0
		password.minspecial = 0
		password.retrylimit = 0
		password.lockoutperiod = 0
		password.expiration = 0
		password.graceperiod = 0
		password.reuseperiod = 0
		password.reuselimit = 0
		#
		# keystore
		keystore.path = ${dir.appdata}/keystore.jks
		keystore.storepass = 81uWxplDtB
		keystore.keypass = 81uWxplDtB
		keystore.type = JCEKS
		#
		# server
		http.contextpath = /
		server.url =
		#
		http.host = 0.0.0.0
		https.host = 0.0.0.0
		#
		https.client.protocols = TLSv1.2,TLSv1.1
		https.server.protocols = TLSv1.2,TLSv1.1,SSLv2Hello
		https.ciphersuites = TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDH_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDH_RSA_WITH_AES_256_GCM_SHA384,TLS_DHE_RSA_WITH_AES_256_GCM_SHA384,TLS_DHE_DSS_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDH_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDH_RSA_WITH_AES_128_GCM_SHA256,TLS_DHE_RSA_WITH_AES_128_GCM_SHA256,TLS_DHE_DSS_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384,TLS_RSA_WITH_AES_256_CBC_SHA256,TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA384,TLS_ECDH_RSA_WITH_AES_256_CBC_SHA384,TLS_DHE_RSA_WITH_AES_256_CBC_SHA256,TLS_DHE_DSS_WITH_AES_256_CBC_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA,TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA,TLS_ECDH_RSA_WITH_AES_256_CBC_SHA,TLS_DHE_RSA_WITH_AES_256_CBC_SHA,TLS_DHE_DSS_WITH_AES_256_CBC_SHA,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256,TLS_RSA_WITH_AES_128_CBC_SHA256,TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA256,TLS_ECDH_RSA_WITH_AES_128_CBC_SHA256,TLS_DHE_RSA_WITH_AES_128_CBC_SHA256,TLS_DHE_DSS_WITH_AES_128_CBC_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_128_CBC_SHA,TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA,TLS_ECDH_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_DSS_WITH_AES_128_CBC_SHA,TLS_EMPTY_RENEGOTIATION_INFO_SCSV
		#
		# Determines whether or not channels are deployed on server startup.
		server.startupdeploy = true
		#
		# Determines whether libraries in the custom-lib directory will be included on the server classpath.
		# To reduce potential classpath conflicts you should create Resources and use them on specific channels/connectors instead, and then set this value to false.
		server.includecustomlib = false
		#
		# administrator
		administrator.maxheapsize = 512m
		#
		# properties file that will store the configuration map and be loaded during server startup
		configurationmap.path = ${dir.appdata}/configuration.properties
		#
		# options: derby, mysql, postgres, oracle, sqlserver
		database = mysql
		database.url = jdbc:mysql://%(host)s:3306/%(database)s
		database.max-connections = 20
		database.username = %(dbUserName)s
		database.password = %(dbUserPassword)s
		#
		# Added  for 3.5.2
		server.api.accesscontrolalloworigin=*
		server.api.accesscontrolallowcredentials=false
		server.api.accesscontrolallowmethods=GET, POST, DELETE, PUT
		server.api.accesscontrolallowheaders=Content-Type
		server.api.accesscontrolexposeheaders=
		server.api.accesscontrolmaxage=
		https.ephemeraldhkeysize=2048
	||| % { host : containerConf.DOCKER_HOST_IP_ADDR, database : containerSecrets.database, dbUserName : containerSecrets.dbUserName, dbUserPassword : containerSecrets.dbUserPassword },
}
