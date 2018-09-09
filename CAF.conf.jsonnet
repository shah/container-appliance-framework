{
  domainName: 'appliances.local',
  applianceName: 'barge',
  applianceHostName: $.applianceName,
  applianceFQDN: $.applianceHostName + '.' + $.domainName,
  defaultDockerNetworkName : 'appliance',

  sharedContainers : {
    sqlAgent : {
      webServicePort : 5000,
    },
    prometheusSqlAgentExporter : {
      webServicePort : 7878,
    },
    mtailExporter : {
      webServicePort : 3903,
    },
  },
}