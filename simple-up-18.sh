#!/bin/bash

docker run -dit \
--name r18build \
--privileged \
--log-driver syslog \
--mount src=r18_autobuild,dst=/build/autobuild \
--mount src=r18_build,dst=/build/rooter \
--mount src=r19_output,dst=/build/output \
--mount type=tmpfs,dst=/tmp/ \
nathhad/rooter18067:latest
