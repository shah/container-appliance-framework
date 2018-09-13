## Run a SQL command in the container
mysql:
	sudo docker exec -it $(CONTAINER_NAME) mysql -uroot -p
