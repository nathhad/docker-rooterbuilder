#!/bin/bash

# This is the image init script
# If the image is fresh, the script will install
# the autobuild system and the build environment.

echo "Starting container."

if [ ! -f /build/autobuild/setupcomplete ] ; then
	# This is a fresh image.
	# Download rooter:

	cd /build/rooter/
	echo "Cloning fresh rooter 18.06.7 image."
	git clone --depth 1 --branch main --single-branch https://github.com/ofmodemsandmen/rootersource18 rooter18067
	echo "Update build packages."
	cd /build/rooter/rooter18067/
	mkdir -p ./images

	# Download autobuild:
	echo "Downloading autobuild."
	cd /build/autobuild
	git clone --depth 1 --branch main --single-branch https://github.com/nathhad/autobuilder /build/autobuild

	# Copy the container autobuild conf template in.
	cp /build/init/autobuild19.conf /build/autobuild/autobuild19.local.conf
	echo "autobuild.local.conf copied in from template."

	# Create the autobuild output directory.
	mkdir /build/autobuild/output
	echo "Autobuild ouput directory created."

	# Place the marker file to skip this in the future.
	touch /build/autobuild/setupcomplete
	echo "First run setup complete."
fi

echo "System ready to go."

# Launch abtrigger.docker trigger loop.
export FORCE_UNSAFE_CONFIGURE=1
exec /bin/bash /build/autobuild/abtrigger.docker


