// This is a template for the container.conf.jsonnet file that is generated
// automatically for each container.
{
	GENERATED_ON : std.extVar('GENERATED_ON'),

	CAF_HOME : std.extVar('CAF_HOME'),
	DOCKER_HOST_IP_ADDR : std.extVar('DOCKER_HOST_IP_ADDR'),

	containerName : std.extVar('containerName'),
	containerDefnHome : std.extVar('containerDefnHome'),
	containerRuntimeConfigHome : $.containerDefnHome + "/etc",

	currentUser : {
		name : std.extVar('currentUserName'),
		id : std.extVar('currentUserId'),
		groupId : std.extVar('currentUserGroupId'),
		home : std.extVar('currentUserHome')
	},
}