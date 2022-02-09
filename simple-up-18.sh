#!/bin/bash

# Check that volumes exist; create if not
if [ "$(docker volume ls | grep -c 'rb_output')" -ne "1" ] ; then docker volume create rb_output ; fi
if [ "$(docker volume ls | grep -c 'r18_autobuild')" -ne "1" ] ; then docker volume create r18_autobuild ; fi
if [ "$(docker volume ls | grep -c 'r18_build')" -ne "1" ] ; then docker volume create r18_build ; fi

# Create and start the container
docker run -dit \
--name r18build \
--privileged \
--mount src=r18_autobuild,dst=/build/autobuild \
--mount src=r18_build,dst=/build/rooter \
--mount src=rb_output,dst=/build/output \
--mount type=tmpfs,dst=/tmp/ \
--restart unless-stopped \
nathhad/rooter18067:latest
