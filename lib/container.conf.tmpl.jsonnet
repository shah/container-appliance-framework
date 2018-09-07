// This is a template for the container.conf.jsonnet file that is generated
// automatically for each container.
{
	GENERATED_ON : std.extVar('GENERATED_ON'),

	CAF_HOME : std.extVar('CAF_HOME'),
	APPLIANCE_HOME : std.extVar('APPLIANCE_HOME'),
	IS_SUBMODULE : std.extVar('IS_SUBMODULE'),

	containerName : std.extVar('containerName'),
	containerRootPath : std.extVar('containerRootPath'),

	defaultNetworkName : std.extVar('defaultNetworkName'),

	currentUserName : std.extVar('currentUserName'),
	currentUserId : std.extVar('currentUserId'),
	currentUserGroupId : std.extVar('currentUserGroupId'),
	currentUserHome : std.extVar('currentUserHome')
}