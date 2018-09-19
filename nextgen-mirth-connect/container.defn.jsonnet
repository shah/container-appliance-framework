local applianceConf = import "CAF.conf.jsonnet";
local containerConf = import "container.conf.json";
local containerSecrets = import "nextgen-mirth-connect.secrets.jsonnet";
local mysqlSecrets = import "mysql.secrets.jsonnet";

local webServicePort = 8443;
local containerUserId = 1001;
local containerUserName = "cs_mirth";

{
	"Dockerfile" : |||
		FROM openjdk:11
		ENV MIRTH_VERSION 3.6.1.b220
		ENV TZ=Europe/Amsterdam
		#
		RUN useradd -u %(containerUserId)s %(containerUserName)s
		#
		# grab gosu for easy step-down from root
		RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
		RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
			&& wget --quiet -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
			&& wget --quiet -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
			&& gpg --verify /usr/local/bin/gosu.asc \
			&& rm /usr/local/bin/gosu.asc \
		&& chmod +x /usr/local/bin/gosu
		#
		VOLUME /opt/mirth-connect/appdata
		#
		RUN \
			cd /tmp && \
			wget --quiet http://downloads.mirthcorp.com/connect/${MIRTH_VERSION}/mirthconnect-${MIRTH_VERSION}-unix.tar.gz && \
			tar xvzf mirthconnect-${MIRTH_VERSION}-unix.tar.gz && \
			rm -f mirthconnect-${MIRTH_VERSION}-unix.tar.gz && \
			mv Mirth\ Connect/* /opt/mirth-connect/ && \
			chown -R %(containerUserName)s /opt/mirth-connect
		#
		WORKDIR /opt/mirth-connect
		EXPOSE %(webServicePort)d
		COPY entrypoint.sh /
		COPY wait.sh /usr/bin/wait
		ENTRYPOINT ["/entrypoint.sh"]
		CMD ["java", "-Duser.timezone=${TZ}", "-jar", "mirth-server-launcher.jar"]
	||| % { containerUserId: containerUserId, containerUserName: containerUserName, webServicePort: webServicePort },
	 
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3.4',

		services: {
			container: {
				build: '.',
				container_name: containerConf.containerName,
				image: containerConf.containerName + ':latest',
				restart: 'always',
				ports: [
					webServicePort + ':' + webServicePort,
				],
				networks: ['network'],
				volumes: [
					'spool:/var/spool/mirth',
					'storage:/opt/mirth-connect/appdata',					
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
			spool: { 
				name: containerConf.containerName + "_spool"
			},
		},
	}),

	// This script will be automatically run after the make configure target is called
	// (execute bit will be set automatically upon discovery by the Makefile).
	"after_configure.make-plugin.sh" : |||
		#!/bin/bash
		sudo useradd -u %(containerUserId)d %(containerUserName)s
		sudo chmod +x "entrypoint.sh"
		sudo chmod +x "wait.sh"
	||| % { containerUserId : containerUserId, containerUserName : containerUserName },

	"wait.sh" : importstr "../lib/wait-for-tcp-port-availability.sh",

	"entrypoint.sh" : |||	
		#! /bin/bash
		set -e
		if [ "$1" = 'java' ]; then
			chown -R %(containerUserName)s /opt/mirth-connect/appdata
			exec gosu %(containerUserName)s "$@"
		fi
		exec "$@"
	||| % { containerUserName : containerUserName },
}
