#!/bin/bash

SYSNAME="sourcebpir4"
VERSION="11.7.01.b"

docker build -t "nathhad/rooter${SYSNAME}:${VERSION}" .
docker tag "nathhad/rooter${SYSNAME}:${VERSION}" "nathhad/rooter${SYSNAME}:latest"
