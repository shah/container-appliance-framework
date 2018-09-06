// local cafLib = import "./lib/appliance.libsonnet";
// local extVar = std.extVar('containerName');

{
  domainName: 'appliances.local',
  applianceName: 'barge',
  applianceHostName: $.applianceName,
  applianceFQDN: $.applianceHostName + '.' + $.domainName,
}