#!/bin/bash

docker run -dit \
--name r19build \
--privileged \
--log-driver syslog \
--mount src=r19_autobuild,dst=/build/autobuild \
--mount src=r19_build,dst=/build/rooter \
--mount src=r19_output,dst=/build/output \
--mount type=tmpfs,dst=/tmp/ \
rooter19076:latest
