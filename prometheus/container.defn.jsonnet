local applianceConf = import "CAF.conf.jsonnet";
local containerConf = import "container.conf.json";

local webServicePort = 8010;
local webServicePortInContainer = webServicePort;
local promConfigFileInContainer = '/etc/prometheus/prometheus.yml';
local tsdbStoragePathInContainer = '/var/prometheus/data';

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3.4',

		services: {
			container: {
				container_name: containerConf.containerName,
				image: 'prom/prometheus:latest',
				command: '--storage.tsdb.path='+ tsdbStoragePathInContainer +' --web.listen-address :'+ webServicePortInContainer +' --config.file=' + promConfigFileInContainer,
				restart: 'always',
				ports: [webServicePort + ':' + webServicePortInContainer],
				networks: ['network'],
				volumes: [
					'storage:' + tsdbStoragePathInContainer,
					containerConf.containerDefnHome + '/prometheus.yml:' + promConfigFileInContainer,
				],
				user: "root", // SNS: by default Prometheus container runs as nobody:nogroup but volumes are owned by root so we switch
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

	"prometheus.yml" : std.manifestYamlDoc({
		global: {
			scrape_interval: "15s",
			evaluation_interval: "15s",
			external_labels: {
				monitor: "appliance"
			}
		},
		rule_files: null,
		scrape_configs: [
			// This monitors prometheus itself, localhost refers to the container, not Docker host
			{
				job_name: "prometheus",
				scrape_interval: "5s",
				static_configs: [ { targets: ["localhost:8010"] } ]
			},
			// This requires prometheus-node-exporter package to be installed in Docker host
			{
				job_name: "node",
				scrape_interval: "15s",
				static_configs: [ { targets: [containerConf.DOCKER_HOST_IP_ADDR + ":9100"] } ]
			},
			// This requires prometheus-node-exporter package to be installed in Docker host
			{
				job_name: "sql-agent",
				scrape_interval: "15s",
				static_configs: [ { targets: [containerConf.DOCKER_HOST_IP_ADDR + ":" + applianceConf.sharedContainers.prometheusSqlAgentExporter.webServicePort] } ]
			},
			// TODO: figure out why docker metrics exporter is not working and enable this
			// {
			// 	job_name: "docker",
			// 	scrape_interval: "15s",
			// 	static_configs: [ {	targets: [ containerConf.DOCKER_HOST_IP_ADDR + ":9323"] } ]
			// }
		]
	})
}