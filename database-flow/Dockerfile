FROM openjdk:8-alpine
RUN apk update && apk add  wget
RUN cd /root && wget https://github.com/KyleU/databaseflow/releases/download/v1.2.6/DatabaseFlow.jar
WORKDIR /root
VOLUME ["/root/.databaseflow"]
EXPOSE 4260
CMD ["java", "-jar" , "DatabaseFlow.jar"]
