#!/bin/bash

SYSNAME="sourcebpir4"
VERSION="11.8.02.a"

docker build -t "nathhad/rooter${SYSNAME}:${VERSION}" .
docker tag "nathhad/rooter${SYSNAME}:${VERSION}" "nathhad/rooter${SYSNAME}:latest"
