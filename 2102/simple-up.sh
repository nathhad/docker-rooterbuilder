#!/bin/bash

# Check that volumes exist; create if not
if [ "$(docker volume ls | grep -c 'rb_output')" -ne "1" ] ; then docker volume create rb_output ; fi
if [ "$(docker volume ls | grep -c 'r21_autobuild')" -ne "1" ] ; then docker volume create r19_autobuild ; fi
if [ "$(docker volume ls | grep -c 'r21_build')" -ne "1" ] ; then docker volume create r19_build ; fi

# Create and start the container
docker run -dit \
--name r21build \
--privileged \
--mount src=r21_autobuild,dst=/build/autobuild \
--mount src=r21_build,dst=/build/rooter \
--mount src=rb_output,dst=/build/output \
--mount type=tmpfs,dst=/tmp/ \
--restart unless-stopped \
--env PUID=$(id -u) \
--env PGID=$(id -g) \
nathhad/rooter2102:latest
