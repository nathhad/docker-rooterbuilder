#!/bin/bash

# This is the image init script
# If the image is fresh, the script will install
# the autobuild system and the build environment.

#
# NEW SYSTEM VARIABLES
#
# These are the minimum variables to change to create a new build system docker image.

GITSOURCE="https://github.com/ofmodemsandmen/ROOterSource2203"
SYSNAME="rooter2203"


# Begin working script:

echo "Starting container."

if [ ! -f /build/autobuild/setupcomplete ] ; then
	# This is a fresh image.
	# Download rooter:

	cd /build/rooter/
	echo "Cloning fresh rooter image."
	git clone --depth 1 --branch main --single-branch "$GITSOURCE" "$SYSNAME"
	echo "Update build packages."
	cd "/build/rooter/$SYSNAME/"
	mkdir -p ./images
	echo "Run dirclean for fresh build environment."
	make dirclean
	echo "Dirclean complete."
	# Add host staging directory to the gitignore file:
	echo 'staging_dir/host/*' >> "/build/rooter/$SYSNAME/.gitignore"

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


