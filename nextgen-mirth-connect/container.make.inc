## Enter the associated MySQL container as root
mysql-root:
	docker exec -it $(CONTAINER_NAME) -h $(DOCKER_HOST_IP_ADDR) mysql -u"root" -p

## Enter the associated MySQL container as mirth service user
mysql:
	# TODO: don't hardcode the s_mirth user, pass it using variables
	docker exec -it $(CONTAINER_NAME) mysql -h $(DOCKER_HOST_IP_ADDR) -u"s_mirth" -p

## Run the mirth user creation script that was placed into the build in Dockerfile
setup-mysql-db:
	docker exec -it $(CONTAINER_NAME) mysql -h $(DOCKER_HOST_IP_ADDR) -u"root" -p -e 'source /opt/mirth-connect/setup-mysql-db.sql'
