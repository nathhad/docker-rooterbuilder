#!/bin/bash

# This is the image init script
# If the image is fresh, the script will install
# the autobuild system and the build environment.

if [ ! -f /build/autobuild/setupcomplete ] ; then
	# This is a fresh image.
	# Download rooter:

	cd /build/rooter/
	echo "Cloning fresh rooter image."
	git clone https://github.com/ofmodemsandmen/RooterSource rooter19076
	echo "Update build packages."
	cd /build/rooter/19076/
	mkdir -p ./images

	# Download autobuild:
	echo "Downloading autobuild."
	cd /build/autobuild/
	git clone https://github.com/nathhad/autobuilder

	# Copy the container autobuild conf template in.
	cp /build/init/autobuild19.conf /build/autobuild/autobuild19.conf

	# Place the marker file to skip this in the future.
	touch /build/autobuild/setupcomplete
fi

# Create the symlink to correct autobuild directory
ln -s /build/autobuild /serve/rooter/autobuild

# Set up Cron
echo "*/1 * * * * /bin/bash /build/abmanage/abtrigger" > /etc/cron.d/autobuild.crontab
chmod 644 /etc/cron.d/autobuild.crontab
crontab /etc/cron.d/autobuild.crontab
cron -L 0

# Launch a bash process and wait
exec /bin/bash

