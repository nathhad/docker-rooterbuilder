#!/bin/bash

docker volume rm r19_build && docker volume create r19_build
docker volume rm r19_autobuild && docker volume create r19_autobuild
