// This is a template for the container.conf.jsonnet file that is generated
// automatically for each container.
{
	GENERATED_ON : std.extVar('GENERATED_ON'),

	CAF_HOME : std.extVar('CAF_HOME'),
	APPLIANCE_HOME : std.extVar('APPLIANCE_HOME'),
	IS_SUBMODULE : std.extVar('IS_SUBMODULE'),
	DOCKER_HOST_IP_ADDR : std.extVar('DOCKER_HOST_IP_ADDR'),

	containerName : std.extVar('containerName'),
	containerDefnHome : std.extVar('containerDefnHome'),

	defaultNetworkName : std.extVar('defaultNetworkName'),

	currentUserName : std.extVar('currentUserName'),
	currentUserId : std.extVar('currentUserId'),
	currentUserGroupId : std.extVar('currentUserGroupId'),
	currentUserHome : std.extVar('currentUserHome')
}