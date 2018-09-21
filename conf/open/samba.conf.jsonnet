local containerConf = import "container.conf.json";

{					
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
