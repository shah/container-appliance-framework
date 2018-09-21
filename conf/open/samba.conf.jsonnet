local containerConf = import "container.conf.json";

{	
	sambaSetup : {
		userId: containerConf.currentUser.id,
		groupId: containerConf.currentUser.groupId,
		timeZone: "EST5EDT",
		serveNetBIOS: true,
		recycle: false
	},	
	
	sambaShares : [
		{
			shareName: "%(name)s_Home" % containerConf.currentUser,
			sharePathInContainer: "/%(name)s_Home" % containerConf.currentUser,
			sharePathInHost: containerConf.currentUser.home,
			browseable: "yes",
			readOnly: "no",
			guest: "no",
			users: "admin",
			admins: "admin",
			usersThatCanWriteToROShare: "admin",
			comment: "%(name)s Home" % containerConf.currentUser,
		},
	],
}
