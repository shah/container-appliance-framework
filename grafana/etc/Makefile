SHELL := /bin/bash
MAKEFLAGS := silent

default: configure

configure: configure-datasources
clean: clean-datasources

configure-datasources: configure-prometheus-datasource replace-DS_PROMETHEUS-variables-in-provisioned-dashboards
clean-datasources: clean-prometheus-datasource

GRAFANA_DATASOURCES_HOME := $(shell realpath ./provisioning/datasources)
GRAFANA_DASHBOARDS_HOME := $(shell realpath ./provisioning/dashboards)
PROMETHEUS_CONTAINER_HOME := $(shell realpath ../../prometheus)
PROMETHEUS_DATASRC_CONF := $(PROMETHEUS_CONTAINER_HOME)/grafana-provisioning-datasource.yml

configure-prometheus-datasource: clean-prometheus-datasource
ifneq ("$(wildcard $(PROMETHEUS_DATASRC_CONF))","")
	echo "Copying $(PROMETHEUS_DATASRC_CONF) to $(GRAFANA_DATASOURCES_HOME)/prometheus.yml"
	mkdir -p $(GRAFANA_DATASOURCES_HOME)
	cp $(PROMETHEUS_DATASRC_CONF) $(GRAFANA_DATASOURCES_HOME)/prometheus.yml
	ls -al $(GRAFANA_DATASOURCES_HOME)
else
	echo "Grafana Datasource config $(PROMETHEUS_DATASRC_CONF) does not exist."
	echo "Has Promethus container been started?"
endif

clean-prometheus-datasource:
	echo "Removing $(GRAFANA_DATASOURCES_HOME)/prometheus.yml"
	rm -f $(GRAFANA_DATASOURCES_HOME)/prometheus.yml

replace-DS_PROMETHEUS-variables-in-provisioned-dashboards:
	echo "Replacing DS_PROMETHEUS with 'Prometheus' in $(GRAFANA_DASHBOARDS_HOME)"
	sed -i 's/$${DS_PROMETHEUS}/Prometheus/g' $(GRAFANA_DASHBOARDS_HOME)/*.json