#!/bin/bash

# Check that volumes exist; create if not
if [ "$(docker volume ls | grep -c 'rb_output')" -ne "1" ] ; then docker volume create rb_output ; fi
if [ "$(docker volume ls | grep -c 'r22_autobuild')" -ne "1" ] ; then docker volume create r22_autobuild ; fi
if [ "$(docker volume ls | grep -c 'r22_build')" -ne "1" ] ; then docker volume create r22_build ; fi

# Create and start the container
docker run -dit \
--name r22build \
--privileged \
--mount src=r22_autobuild,dst=/build/autobuild \
--mount src=r22_build,dst=/build/rooter \
--mount src=rb_output,dst=/build/output \
--mount type=tmpfs,dst=/tmp/ \
--restart unless-stopped \
--env PUID=$(id -u) \
--env PGID=$(id -g) \
nathhad/rooter2203:latest
