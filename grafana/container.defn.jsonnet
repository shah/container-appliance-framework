local applianceConf = import "CAF.conf.jsonnet";
local containerConf = import "container.conf.json";
local containerSecrets = import "grafana.secrets.jsonnet";
local prometheusConf = import "prometheus.conf.jsonnet";

local webServicePort = 3000;
local webServicePortInContainer = webServicePort;

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3.4',

		services: {
			container: {
				container_name: containerConf.containerName,
				image: 'grafana/grafana',
				restart: 'always',
				ports: [webServicePort + ':' + webServicePortInContainer],
				networks: ['network'],
				volumes: [
					'storage:/var/lib/grafana',
					containerConf.containerRuntimeConfigHome + '/provisioning:/etc/grafana/provisioning',
				],
				environment: [
					"GF_DEFAULT_INSTANCE_NAME=" + applianceConf.applianceName,
					"GF_SECURITY_ADMIN_USER=" + containerSecrets.adminUser,
					"GF_SECURITY_ADMIN_PASSWORD=" + containerSecrets.adminPassword,
					"GF_USERS_ALLOW_SIGN_UP=false"
				],
				labels: {
					'traefik.enable': 'true',
					'traefik.docker.network': applianceConf.defaultDockerNetworkName,
					'traefik.domain': containerConf.containerName + '.' + applianceConf.applianceFQDN,
					'traefik.backend': containerConf.containerName,
					'traefik.frontend.entryPoints': 'http,https',
					'traefik.frontend.rule': 'Host:' + containerConf.containerName + '.' + applianceConf.applianceFQDN,
				}
			},
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

	"after_configure.make-plugin.sh": |||
		#!/bin/bash
		GRAFANA_PROV_DASHBOARDS_HOME=etc/provisioning/dashboards
		echo "Replacing DS_PROMETHEUS with 'Prometheus' in $GRAFANA_PROV_DASHBOARDS_HOME"
		sed -i 's/$${DS_PROMETHEUS}/Prometheus/g' $GRAFANA_PROV_DASHBOARDS_HOME/*.json
	|||,

	"etc/provisioning/datasources/prometheus.yml" : std.manifestYamlDoc({
		apiVersion: 1,
		datasources: [
			{
				name: "Prometheus",
				type: "prometheus",
				access: "proxy",
				url: 'http://' + containerConf.DOCKER_HOST_IP_ADDR + ":" + prometheusConf.webServicePort
			},
		],
	}),
}