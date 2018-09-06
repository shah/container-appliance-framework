#!/bin/bash
CONTAINER_NAME=$1
WAIT_FOR_MESSAGE="SQL Server is now ready for client connections."
printf "Waiting until $CONTAINER_NAME is healthy via log output."
docker logs -f $CONTAINER_NAME | while read LOGLINE
do
	if [[ ${LOGLINE} = *"${WAIT_FOR_MESSAGE}"* ]]; then
		break
	fi
done
# while [ $(docker inspect --format "{{json .State.Health.Status }}" $CONTAINER_NAME) != "\"healthy\"" ]; do printf "."; sleep 1; done
echo ""
echo "$WAIT_FOR_MESSAGE"
