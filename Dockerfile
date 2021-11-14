FROM nathhad/rooterbase:11.1.02
LABEL maintainer="Chuck Sanders <nathhad@gmail.com>"
LABEL version="11.1.02.d"

RUN mkdir /build/init && \
	mkdir /serve/ && \
	mkdir /serve/rooter && \
	echo "PATH=$PATH:/build/autobuild" >> /root/.bashrc

ADD --chown=root:root ./imagesetup/* /build/init/

ENTRYPOINT ["/bin/bash", "/build/init/init.sh"]
