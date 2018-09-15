# https://hub.docker.com/r/brandonstevens/mirth-connect/
FROM java

ENV MIRTH_CONNECT_VERSION 3.6.1.b220

ENV MIRTH_SERVICE_USERID 1001
ENV MIRTH_SERVICE_USERNAME cs_mirth

# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN useradd -u $MIRTH_SERVICE_USERID $MIRTH_SERVICE_USERNAME

# grab gosu for easy step-down from root
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN apt-get update && apt-get install -y --no-install-recommends mysql-client ca-certificates wget && rm -rf /var/lib/apt/lists/* \
	&& wget -q -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
	&& wget -q -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu

VOLUME /opt/mirth-connect/appdata

RUN \
  cd /tmp && \
  wget -q http://downloads.mirthcorp.com/connect/$MIRTH_CONNECT_VERSION/mirthconnect-$MIRTH_CONNECT_VERSION-unix.tar.gz && \
  tar xvzf mirthconnect-$MIRTH_CONNECT_VERSION-unix.tar.gz && \
  rm -f mirthconnect-$MIRTH_CONNECT_VERSION-unix.tar.gz && \
  mv Mirth\ Connect/* /opt/mirth-connect/ && \
  chown -R $MIRTH_SERVICE_USERNAME /opt/mirth-connect

WORKDIR /opt/mirth-connect

RUN mkdir /var/spool/mirth
RUN chown -R $MIRTH_SERVICE_USERNAME /var/spool/mirth
VOLUME /var/spool/mirth

EXPOSE 8080 8443

RUN mkdir /docker-entrypoint-init.d
VOLUME /docker-entrypoint-init.d

COPY docker-entrypoint.sh /
ENTRYPOINT ["sh", "/docker-entrypoint.sh"]

CMD ["java", "-jar", "mirth-server-launcher.jar"]

