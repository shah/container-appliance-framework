## Run a SQL command in the container
sqlcmd:
	sudo docker exec -it $(CONTAINER_NAME) /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $(DBA_USER_PASSWORD)
