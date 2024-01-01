#!/bin/bash

#
# NEW SYSTEM VARIABLES
#
# These are the minimum variables to change to create a new build system docker image.
SYSNAME="glinet"
SYSDIR="/mnt/overflow"

# Check that volumes exist; create if not
if [ "$(docker volume ls | grep -c 'rb_output')" -ne "1" ] ; then docker volume create rb_output ; fi
#if [ "$(docker volume ls | grep -c ${SYSNAME}_autobuild)" -ne "1" ] ; then docker volume create ${SYSNAME}_autobuild ; fi
#if [ "$(docker volume ls | grep -c ${SYSNAME}_build)" -ne "1" ] ; then docker volume create ${SYSNAME}_build ; fi
mkdir -p "${SYSDIR}/${SYSNAME}_autobuild"
mkdir -p "${SYSDIR}/${SYSNAME}_build"


# Create and start the container
docker run -dit \
--name "$SYSNAME" \
--privileged \
--mount type=bind,src="${SYSDIR}/${SYSNAME}_autobuild",dst=/build/autobuild \
--mount type=bind,src="${SYSDIR}/${SYSNAME}_build",dst=/build/rooter \
--mount src=rb_output,dst=/build/output \
--mount type=tmpfs,dst=/tmp/ \
--restart unless-stopped \
--env PUID=$(id -u) \
--env PGID=$(id -g) \
nathhad/rooter${SYSNAME}:latest
