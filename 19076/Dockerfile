FROM nathhad/rooterbase:11.1.04
LABEL maintainer="Chuck Sanders <nathhad@gmail.com>"
LABEL version="11.1.04.b"

RUN mkdir /build/init && \
	echo "PATH=$PATH:/build/autobuild" >> /root/.bashrc && \
	echo "export FORCE_UNSAFE_CONFIGURE=1" >> /root/.bashrc

ADD --chown=root:root ./imagesetup/* /build/init/

ENTRYPOINT ["/bin/bash", "/build/init/init.sh"]
