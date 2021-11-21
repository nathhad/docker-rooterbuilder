FROM nathhad/rooterbase:11.1.03
LABEL maintainer="Chuck Sanders <nathhad@gmail.com>"
LABEL rooterversion="18.06.7"
LABEL version="11.1.03.c"

RUN mkdir /build/init && \
	mkdir /serve/ && \
	mkdir /serve/rooter && \
	mkdir /root/.config && \
	ln -s /build/autobuild /root/.config/autobuild19 && \
	echo "PATH=$PATH:/build/autobuild" >> /root/.bashrc

ADD --chown=root:root ./imagesetup/* /build/init/

ENTRYPOINT ["/bin/bash", "/build/init/init.sh"]
