## Run a SQL command in the container
mysql:
	sudo docker exec -it $(CONTAINER_NAME) mysql -uroot -p

## One some mysql clients you might encounter ERROR 2059 (HY000): Authentication plugin 'caching_sha2_password' cannot be loaded
## If so, this target fixes that error
fix-error-2059:
	sudo docker exec -d $(CONTAINER_NAME) mysql -uroot -p -e "use mysql; ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '1234'; FLUSH PRIVILEGES;"
