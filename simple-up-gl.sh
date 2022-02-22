#!/bin/bash

# Check that volumes exist; create if not
if [ "$(docker volume ls | grep -c 'rb_output')" -ne "1" ] ; then docker volume create rb_output ; fi
if [ "$(docker volume ls | grep -c 'rgl_autobuild')" -ne "1" ] ; then docker volume create rgl_autobuild ; fi
if [ "$(docker volume ls | grep -c 'rgl_build')" -ne "1" ] ; then docker volume create rgl_build ; fi

# Create and start the container
docker run -dit \
--name rglbuild \
--privileged \
--mount src=rgl_autobuild,dst=/build/autobuild \
--mount src=rgl_build,dst=/build/rooter \
--mount src=rb_output,dst=/build/output \
--mount type=tmpfs,dst=/tmp/ \
--restart unless-stopped \
--env PUID=$(id -u) \
--env PGID=$(id -g) \
nathhad/rooterglinet:latest
