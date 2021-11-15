##### ROOter Builder 19.07.6 (Docker)

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

## Quick Setup

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


