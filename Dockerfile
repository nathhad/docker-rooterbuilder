FROM nathhad/rooterbase:11.1.01
LABEL maintainer="Chuck Sanders <nathhad@gmail.com>"
LABEL version="11.1.01.a"

RUN apt-get update && \
	apt-get install -y cron && \
	apt-get clean && \
	mkdir /build/init && \
	mkdir /serve/ && \
	mkdir /serve/rooter && \
	echo "PATH=$PATH:/build/autobuild" >> /root/.bashrc

ADD --chown=root:root ./imagesetup/* /build/init/

ENTRYPOINT ["/build/init/init.sh"]
