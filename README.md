# ROOter Builder 19.07.6 (Docker)

This is a containerized build environment for ROOter GoldenOrb based on
OpenWRT release 19.07.6. At the time of this writing, this is the
primary build environment for ROOter, and covers 125 router models.

This container also includes the [nathhad/autobuilder](https://github.com/nathhad/autobuilder)
wrapper script system. It is meant to be a main building block to
construct and deploy ROOter autobuild servers, but also provides
full support for building custom images, including all of the usual
custom image abilities supported by the ROOter build environment.

## Relevant Links:

- [ROOter GoldenOrb](https://www.ofmodemsandmen.com/)
- [ROOter support forum](https://forums.whirlpool.net.au/thread/3vx1k1r3?p=-1#bottom) (one giant thread, all developers active)
- [ROOter Autobuild Images](http://www.aturnofthenut.com/autobuilds/) (most recent standard images, 19.06.7 only)
- [ROOter Custom Images](http://aturnofthenut.com/upload/) (from support requests on the forum)
- [ROOter 19.07.6 build system](https://github.com/ofmodemsandmen/RooterSource)
- [ROOter 19.07.6 build system instructions](http://www.aturnofthenut.com/builds/buildocs.pdf)
- [Autobuild System](https://github.com/nathhad/autobuilder)

## Getting Started (Quick Setup)

These steps will get you going using the basic, default settings.

Before you begin, you will need:

- A working docker install
- A user account with the permissions needed to work with docker (either root, or in the docker group)
- Space. The build environment itself is only a few gigs, but building ROOter is *very, very* space intensive compared to most Docker jobs. 200GB minimum to build the full 125 router catalog (which will use 160-180 GB).

By default, Docker stores *everything* under `/var/lib/docker`. If you don't have a generous partition for that,
it's a great way to fill up and lock up your root drive, which will waste half of your afternoon fixing. I strongly
recommend setting this up on a partition that isn't your root drive. If this is a new install and not a system
with other Docker containers already running, I recommend moving your Docker root file location right off the bat
before you begin. Follow [the instructions here](https://evodify.com/change-docker-storage-location/) and scroll straight
down to the heading that reads, "Change Docker storage location: THE RIGHT WAY!"

If you've got your storage straight, you're ready to set up the image.

1. **Set up storage volumes**

Your storage volumes are the only persistent part of the image, the program part of the image starts
clean every time you restart the container (reboot, etc). You need to create the volumes you will
use for the container.

```
docker volume create r19_autobuild
docker volume create r19_build
docker volume create r19_output
```

Those three will hold your configuration files, your actual build environment, and the resulting output images.

2. **Download and install the image**

```
docker pull nathhad/rooter19076:latest
```

3. **Download the Git**

The git has a few helpful scripts, and is worth grabbing some or all of. This quick setup assumes
you download at least part.

The easy way, the whole thing (you can change the last bit to change the destination of the download):

```
git clone --depth 1 --branch main --single-branch https://github.com/nathhad/docker-rooter19076 ~/docker-rooter19076
```

The minimum recommended component for this quick startup is the quick start script, which you can
[download here](https://github.com/nathhad/docker-rooter19076/raw/main/simple-up.sh).

4. **Start the container**

The first time you start the container, it will pull both the build environment and the autobuild
wrapper setup down off of github. This will take several minutes at a minimum, so you will need
to wait for that step to complete first. To first start the container, cd to the folder where
you downloaded the startup script in step 3, and run:

```
. simple-startup.sh
```

To know when initial container setup is complete, you'll need to watch the output of the container
using docker logs. Execute this command:

```
docker logs -f r19build
```

Wait for a line that reads `System ready to go.` You can then `Ctrl-C` out of watching the log.

Once you run the image the first time, and it initializes the environment in your storage
volumes, the container will skip that step in the future, and startup of the container will
only take a few seconds.

If for some reason you want to clear your container and start over, you can run wipeimage.sh, which
is included in the git. This will wipe both the build environment and autobuild settings container.
This is not recommended as a frequent practice unless recovering from something quite wrong -
wiping the autobuild volume will remove any tuning settings, and wiping the build volume will
wipe out any custom image definitions you have created. However, other than losing these bits
of information, no other harm will come of wiping the storage; the container will simply
re-download the build and autobuild environments when you next start it, and start fresh.

5. **Building Images**

At this point setup is complete, and you are ready to build images.

Most autobuild commands can be issued from inside or outside of the container. Building custom
images must be done from the command line inside the container, because it requires a fair
bit of interactive input. For this quick start guide, we will assume you will do all work
from inside. Step into your running image with the following command:

```
docker exec -it r19build /bin/bash
```

Your command terminal will change to show you inside the container now. Example:

```
chuck@felix:~/$ docker exec -it r19build /bin/bash
root@2c22c3f20b77:~#
```

The characters after `root@` will be different for your machine; this is the ID number
of your container, and will change any time you create a new container (for example,
by updating to a newer image, covered in a later step). For the rest of this quick
start, I will show that "inside the image" prompt for any commands meant to be run
from within your container.

You may exit the container at any time with the usual `exit` command. This will not
stop the container from running, merely log you out of it.

## Autobuild Wrapper System

The Autobuild wrapper system is used for rapidly building stock images and keeping your
build environment up to date. While many Autobuild commands can be issued from outside
the container, for now, plan to be at a command line inside the container to get started.

Your main interface with the autobuild system is the abmanage script, which does include
basic helpfile output:

```
root@2c22c3f20b77:~# abmanage help
```

Use is best illustrated with several examples.

Update the build system catalog, and show all new routers (any router which doesn't
already have an existing image in the /build/output folder):

```
root@2c22c3f20b77:~# abmanage -p new
```

You can print the status of the entire catalog. It's long, so you will need to format
the output to make it readable. If you are on a large terminal (160x50 or bigger) you
can get beautiful output by piping to column. Example, without an update:

```
root@2c22c3f20b77:~# abmanage status | column
```

For smaller terminals that won't fit multiple columns, example with update:

```
root@2c22c3f20b77:~# abmanage -p status | less
```

Print a list of all new routers (routers which are in the catalog but have no images
in the /build/output folder):

```
root@2c22c3f20b77:~# abmanage new
```

Update the build catalog, print a list of all new routers, and build all new routers
if there are any (using the `-e` flag):

```
root@2c22c3f20b77:~# abmanage -pe new
```

List all routers in current copy of catalog *with an image* where the newest image is over 5 days old:

```
root@2c22c3f20b77:~# abmanage stale 5
```

Update, and build a fresh copy of every router *with an existing image*:

```
root@2c22c3f20b77:~# abmanage -pe stale 0
```

At the moment, there is no `all` command as I have not needed it, but I do plan
to add one in the future. An equivalent to a "build all" directive can be
accomplished right now by following `abmanage -pe new` with `abmanage -e stale 0`
to run a fresh image of every router in the catalog.

There are two currently supported cleanup commands. `prune <integer>` will find
every router with more than `<integer>` completed images, and move any extras
above that number to the trash folder. `stray` will move any images not in
the current catalog to the trash folder; please be aware that stray will also
sweep up custom images. The trash folder is /build/output/trash, and this folder
currently requires manual cleanup.

## Building Custom Images

Building custom images works exactly as described in the
[ROOter 19.07.6 build system instructions](http://www.aturnofthenut.com/builds/buildocs.pdf).
Running in a container doesn't change anything about this process by default, except
for the root file location of the build system, which will be at
/build/rooter/rooter19076. Once your container is running, simply step into
the container as explained above, then navigate to the right folder:

```
root@2c22c3f20b77:~# cd /build/rooter/rooter19076
```

From there, open the build system instructions above, and skip
straight past all of the setup instructions to the heading
which reads **Creating Custom Images**.

Once you have built a custom image, you will need to move it manually
to the right folder to get it out of your container. The custom build
script will leave its output in a subfolder of the build system.
You will need to move it to the normal output folder with the
following command:

```
root@2c22c3f20b77:~# mv /build/rooter/rooter19076/images/*.zip /build/output/
```

## Accessing your images

Once you have built what you need, you just need to get it out of the
container. Luckily Docker makes this fairly straightforward, as the contents
of those storage volumes are directly accessible from outside the container,
too.

The following examples assume the Docker root is still at the default
location, `/var/lib/docker`. If you moved your docker file system to
another partition like I recommended way up before we even started Step 1,
you'll need to substitute the correct root path.

The contents of your /build/output storage directory will be directly
accessible here:

```
/var/lib/docker/volumes/r19_output/_data
```

You can copy them straight out, though you'll usually need root privileges
to do so, as Docker runs as root by default.


