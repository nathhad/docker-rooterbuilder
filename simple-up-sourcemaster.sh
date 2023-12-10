#!/bin/bash

# Check that volumes exist; create if not
if [ "$(docker volume ls | grep -c 'rb_output')" -ne "1" ] ; then docker volume create rb_output ; fi
if [ "$(docker volume ls | grep -c 'rsm_autobuild')" -ne "1" ] ; then docker volume create r22_autobuild ; fi
if [ "$(docker volume ls | grep -c 'rsm_build')" -ne "1" ] ; then docker volume create r22_build ; fi

# Create and start the container
docker run -dit \
--name rsmbuild \
--privileged \
--mount src=rsm_autobuild,dst=/build/autobuild \
--mount src=rsm_build,dst=/build/rooter \
--mount src=rb_output,dst=/build/output \
--mount type=tmpfs,dst=/tmp/ \
--restart unless-stopped \
--env PUID=$(id -u) \
--env PGID=$(id -g) \
nathhad/rootersourcemaster:latest
