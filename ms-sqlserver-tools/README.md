On certain hosts/server there may be multiple SQL Server instances running.
The default port is 1433 but in case that port (1433) is not working, try this
on the Windows host of the SQL Server instances:

    netstat -abn

You'll see something like this:

    Active Connections
       Proto  Local Address          Foreign Address        State
       TCP    0.0.0.0:1433           0.0.0.0:0              LISTENING
       TCP    169.254.173.244:1433   169.254.173.244:3952   ESTABLISHED

This [help page](https://social.msdn.microsoft.com/Forums/sqlserver/en-US/2cdcab2e-ea49-4fd5-b2b8-13824ab4619b/help-server-not-listening-on-1433) 
has a good summary of how find the port number.