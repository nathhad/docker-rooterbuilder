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

# Getting Started (Quick Setup)

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

```bash
docker volume create r19_autobuild
docker volume create r19_build
docker volume create r19_output
```

Those three will hold your configuration files, your actual build environment, and the resulting output images.

2. **Download and install the image**

```shell
docker pull nathhad/rooter19076:latest
```

3. **Download the Git**

The git has a few helpful scripts, and is worth grabbing some or all of. This quick setup assumes
you download at least part.

The easy way, the whole thing (you can change the last bit to change the destination of the download):

```bash
git clone --depth 1 --branch main --single-branch https://github.com/nathhad/docker-rooter19076 ~/docker-rooter19076
```

The minimum recommended component for this quick startup is the quick start script, which you can
[download here](https://github.com/nathhad/docker-rooter19076/raw/main/simple-up.sh).

4. **Start the container**

The first time you start the container, it will pull both the build environment and the autobuild
wrapper setup down off of github. This will take several minutes at a minimum, so you will need
to wait for that step to complete first. To first start the container, cd to the folder where
you downloaded the startup script in step 3, and run:

```bash
. simple-startup.sh
```

To know when initial container setup is complete, you'll need to watch the output of the container
using docker logs. Execute this command:

```bash
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

```bash
docker exec -it r19build /bin/bash
```

Your command terminal will change to show you inside the container now. Example:

```bash
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

```bash
root@2c22c3f20b77:~# abmanage help
```

Use is best illustrated with several examples.

Update the build system catalog, and show all new routers (any router which doesn't
already have an existing image in the /build/output folder):

```bash
root@2c22c3f20b77:~# abmanage -p new
```

You can print the status of the entire catalog. It's long, so you will need to format
the output to make it readable. If you are on a large terminal (160x50 or bigger) you
can get beautiful output by piping to column. Example, without an update:

```bash
root@2c22c3f20b77:~# abmanage status | column
```

For smaller terminals that won't fit multiple columns, example with update:

```bash
root@2c22c3f20b77:~# abmanage -p status | less
```

Print a list of all new routers (routers which are in the catalog but have no images
in the /build/output folder):

```bash
root@2c22c3f20b77:~# abmanage new
```

Update the build catalog, print a list of all new routers, and build all new routers
if there are any (using the `-e` flag):

```bash
root@2c22c3f20b77:~# abmanage -pe new
```

List all routers in current copy of catalog *with an image* where the newest image is over 5 days old:

```bash
root@2c22c3f20b77:~# abmanage stale 5
```

Update, and build a fresh copy of every router *with an existing image*:

```bash
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

## Triggering Autobuilds By Name

If you need the server to build stock autobuild images of specific router models,
that is also easy to command, by sending the list of routers you want directly to the
autobuild system's *trigger file*. This is also how abmanage starts builds with the
`-e` flag. In this Docker image, the autobuild system's trigger file is located
at `/tmp/go` in temporary storage. Once the trigger system has picked up your
command (it will check every 60 seconds), it will remove the trigger file.

For example:

```bash
root@2c22c3f20b77:/# echo "ALIX-2D13 APU2C4 AR150 AR300LITE AR750 AR750S" >> /tmp/go
```

will queue up six routers for immediate build in the queue, which will start in a
minute or less.

The router names may be separated interchangeably by spaces or line feeds. That means
if you sent some routers to the trigger, and immediately realized you forgot a few,
you can immediately append them to the trigger file the same way. For example, the
following is exactly equivalent to the block above:

```bash
root@2c22c3f20b77:/# echo "ALIX-2D13 APU2C4 AR150 AR300LITE" >> /tmp/go
root@2c22c3f20b77:/# echo "AR750 AR750S" >> /tmp/go
```

As long as you get them appended before the trigger system catches it, all of the
routers will be included in the batch that will be started.

The only thing to be careful of: make *certain* you always *append* to your
trigger file using `>>` rather than overwriting using `>`.

*What if you're too slow, and the system triggers before you add your second batch?*
That's okay too. The trigger system will have cleared the first batch from the file
when it started that batch running, and you can keep adding more routers manually
to the trigger file using `>>` while it runs. The system will wait to check the
trigger again until the current build set is complete. Afterward, it will spot
your new additions again within a minute, and start another batch.

*What if you want some time to prepare your manual list first?* That's easy, too.
Just start your list in a temporary file - nano is installed inside the image
for this use, and for system tuning. You can take your time putting your list
together. When you're done, you can just save and move that file to the trigger file
location. If your temporary list was /tmp/mylist, just execute:

```bash
root@2c22c3f20b77:/# mv /tmp/mylist /tmp/go
```

If your use case has you re-running the same manual list of routers over and over,
you can save your list to /build/autobuild/mylist instead (as the autobuild folder
is persistent, and the tmp folder is not), and just copy the list to the trigger
whenever you need to start a build:

```bash
root@2c22c3f20b77:/# cp /build/autobuild/mylist /tmp/go
```

## Building Custom Images

Building custom images works exactly as described in the
[ROOter 19.07.6 build system instructions](http://www.aturnofthenut.com/builds/buildocs.pdf).
Running in a container doesn't change anything about this process by default, except
for the root file location of the build system, which will be at
/build/rooter/rooter19076. Once your container is running, simply step into
the container as explained above, then navigate to the right folder:

```bash
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

```bash
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

```bash
/var/lib/docker/volumes/r19_output/_data
```

You can copy them straight out, though you'll usually need root privileges
to do so, as Docker runs as root by default.

# Maintenance and Tuning

## Stopping, Starting, and Restarting

Your container can be stopped, started, and restarted at your convenience,
and will of course be stopped if the computer is rebooted. This container
is not set to automatically restart by default, and must be manually
started after a reboot, though that can be trivially changed if you
desire (as described in plenty of other Docker guides and info).

To stop your container:

```bash
docker stop r19build
```

Most importantly, your container *does not need to be re-created*
in order to restart it. Simply start it with:

```bash
docker start r19build
```

## Updating the Container Image

**Updating the build environment** itself is handled from within using
`abmanage -p status` (or any other command that supports the -p flag).

**Updating the autobuild wrapper:** step into the container, and cd to
/build/autobuild/. Execute `git pull` here, and as long as you have
not modified any of the original autobuild files, any updates to
the autobuild wrapper system will be pulled down and incorporated
automatically. (This is why you should put any configuration
changes in autobuild19.local.conf, as changing autobuild19.conf
directly will block the git update.)

**Updating the build container's image:** this is actually the easiest
update. All of the working programs in the container are a static
image, and containers themselves are disposable (because all your
actual data, including the ROOter build system files and the
autobuild wrapper files,  is stored in the persistent volumes). To update the
container's software, you simply stop the container, remove it,
pull a newer copy of the container image (Docker will only pull
updates, not a full fresh copy), and start a new container.

```bash
docker stop r19build
docker rm r19build
docker pull nathhad/rooter19076:latest
./simple-up.sh
```

With that, you have a new container with all of the most current
software updates, and your fresh container will pick right back
up where the old one left off in your build environment.

## Performance Tuning - Autobuilds

The autobuild wrapper already builds a good bit of performance tuning
into the build process when creating a stock image. The main tuning
adjustment to make is thread count. Image builds can benefit substantially
from parallel processing. The default autobuild configuration is for
two parallel threads; however, most relatively new build machines
(really, anything first generation Intel Core i5 or i7 or newer, or
equivalent) is almost certainly going to benefit from turning up the
thread count.

To adjust the thread count, edit the file `/build/autobuild/autobuild19.local.conf`
with nano. Near the bottom, look for the line that reads:

```bash
MAKEFLAGS='-j2'
```

That makeflag will control the number of parallel threads run in the parts of
the build that can be run parallel. A good place to start with most systems
is at your number of processor cores (real cores, not virtual cores provided
by hyperthreading) plus 1. Ultimately your final system tuning will be via
trial and error.

Make your adjustment, start a build, and open htop (on your host machine, not
in the container). In the top right, you will see three numbers after the
label Load Average; they represent the average over the past one, five,
and fifteen minutes. You want to primarily watch the first number when the
system is working hard. Your target number should be your number of cores
if you have a non-hyperthreading processor, or roughly 1.3 times your
number of cores on a hyperthreading processor.

You do not need to worry about overloading your processor in a way that
interferes with other services running on your host computer. The autobuild
wrapper automatically deprioritizes all of the threads run as part of the
build process, so if another process needs the CPU resources, the build threads
will automatically get held back long enough to get the more critical work done.

The only think you need to keep an eye on is your system temperatures. If your
cooling system isn't up to the task and you don't routinely use your machine
hard, tuning the autobuild system to max out your processor for 30 hours
straight is a very effective way to find out. (That's also true if testing
your cooling system is actually the goal, except unlike a lot of test
suites, this way gets actual work done and shows you the performance under
a real workload.)

## Performance Tuning - Custom Builds

Because the custom build system doesn't use the autobuild wrapper, the performance
tuning (deprioritizing the build, then making it run multiple threads) is not
automatically included. Luckily you can turn on these features manually.

Please refer back to the rooter custom build instructions document when reading
this section. We will be working with the following example build command
directly from the build instructions:

```bash
./build archerc7v5 -eb custom-c7v5
```

First, to deprioritize this command and everything else it runs by five
priority points, we run the command through `nice`.

```bash
nice -n 5 ./build archerc7v5 -eb custom-c7v5
```

This does the *exact* same thing as the first command, just with the process
and all of its children deprioritized. Now we can safely run more threads.
To do that without modifying anything in the build script, we need to manually
pass an environment variable to make when we start the build, this way:

```bash
MAKEFLAGS='-j3' nice -n 5 ./build archerc7v5 -eb custom-c7v5
```

The above version of the command will run the build deprioritized, with up to
three threads at once - and is exactly how the autobuild wrapper calls the
build script when doing automated builds.

# To Do: Upcoming Features

The containerized version of the autobuild system is still a work in progress.
The following work or new features are all either in the works, or planned as
soon as I can get to them.

- More documentation: This README is really all there is so far. Documentation
is sadly lacking. I do aim to rectify this as quickly as possible.

- Fixed logging: The autobuild wrapper system has great logging when run on
bare metal, but it's not working in the container system yet. I have some
learning to do to fix that one.

- Improved control from outside the container: w.i.p.
