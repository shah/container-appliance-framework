FROM ubuntu

ARG mtailVersion=3.0.0-rc16
ARG mtailHome=/mtail
ARG mtailReleasePackage=https://github.com/google/mtail/releases/download/v${mtailVersion}/mtail_v${mtailVersion}_linux_amd64
ARG mtailProgramsHome=/etc/mtail

WORKDIR ${mtailHome}

ADD ${mtailReleasePackage} ${mtailHome}/mtail-${mtailVersion}
RUN chmod a+rx ${mtailHome}/mtail-${mtailVersion} && ln -s ${mtailHome}/mtail-${mtailVersion} /usr/bin/mtail

VOLUME ["${mtailProgramsHome}"]

EXPOSE 3903

LABEL author="Shahid N. Shah <shahid@shah.org>" \
	  deploy.mtail.releases.version="${mtailVersion}" \
	  deploy.mtail.releases.downloadPath="${mtailReleasePackage}" \
	  deploy.mtail.home="${mtailProgramsHome}" \
	  deploy.mtail.progsHome="${mtailProgramsHome}"

ENTRYPOINT ["/usr/bin/mtail"]
