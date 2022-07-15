# projector-docker

[![obsolete JetBrains project](https://jb.gg/badges/obsolete.svg)](https://confluence.jetbrains.com/display/ALL/JetBrains+on+GitHub)

Some scripts to create and run a Docker container with Projector and JetBrains IDE.

## The state of the Projector

The development of JetBrains Projector as its own standalone product has been suspended. That said, Projector remains an important part of [JetBrains Gateway](https://www.jetbrains.com/remote-development/gateway/), which is the primary remote development tool for JetBrains IDEs. We will focus our efforts on improving and developing Projector in this limited scenario.

Our goal is to provide a rich, full-featured remote development experience with a look and feel that is equal to or better than what you get when working with IDEs locally. The only way to get everything you’re used to having when working locally (low latency, low network traffic, user-defined and OS-specific shortcuts, themes, settings migrations, ssh-agent/port forwarding, and other things) is by installing a dedicated client-side application. The standalone version of Projector is not capable of meeting these goals.

As a result, we no longer recommend using the standalone version of JetBrains Projector or merely making tweaks to incorporate it into your existing IDE servers. We won’t provide user support or quick-fixes for issues that arise when these setups are used. If you have the option to switch from Projector to Gateway, we strongly recommend you do so.

[Learn more about JetBrains Gateway](https://www.jetbrains.com/remote-development/gateway/)

[Documentation](https://jetbrains.github.io/projector-client/mkdocs/latest/)
| [Issue tracker](https://youtrack.jetbrains.com/issues/PRJ)

## Run JetBrains IDE in Docker

How to run JetBrains IDE in Docker and access it via a web browser?

### Step 1
Firstly, pull an image with needed IDE. You can do it in two ways: 

#### The first one is to pull it from [DockerHub](https://hub.docker.com/orgs/jetbrains/repositories):

```shell
docker pull jetbrains/projector-clion
docker pull jetbrains/projector-datagrip
docker pull jetbrains/projector-goland
docker pull jetbrains/projector-idea-c
docker pull jetbrains/projector-idea-u
docker pull jetbrains/projector-phpstorm
docker pull jetbrains/projector-pycharm-c
docker pull jetbrains/projector-pycharm-p
docker pull jetbrains/projector-rider
docker pull jetbrains/projector-rubymine
docker pull jetbrains/projector-webstorm
```
Tags are distributed on DockerHub as follows:
- `:latest` – this image contains the **latest up-to-date** version of the tested IDE with the latest **stable** version of the Projector;
- `:develop` – this image contains the **latest up-to-date** version of the tested IDE with the **latest commit** of the Projector repository;
- `:<IDE_VERSION>-develop` – this image contains the **selected** version of the IDE with the **latest commit** of the Projector repository;
- `:<IDE_VERSION>-projector-<PROJECTOR_VERSION>` – this image contains the **selected** version of the IDE with the **selected stable** version of Projector.

#### The second way is to pull it from Space:
_On Space, only the latest tested IDE and the `develop` version of Projector are published._

```shell
docker pull registry.jetbrains.team/p/prj/containers/projector-clion
docker pull registry.jetbrains.team/p/prj/containers/projector-datagrip
docker pull registry.jetbrains.team/p/prj/containers/projector-goland
docker pull registry.jetbrains.team/p/prj/containers/projector-idea-c
docker pull registry.jetbrains.team/p/prj/containers/projector-idea-u
docker pull registry.jetbrains.team/p/prj/containers/projector-phpstorm
docker pull registry.jetbrains.team/p/prj/containers/projector-pycharm-c
docker pull registry.jetbrains.team/p/prj/containers/projector-pycharm-p
docker pull registry.jetbrains.team/p/prj/containers/projector-rider
docker pull registry.jetbrains.team/p/prj/containers/projector-rubymine
docker pull registry.jetbrains.team/p/prj/containers/projector-webstorm
```

### Step 2

After that, you can run it via the following command (just replace `IMAGE_NAME` with the needed name, for
example, `jetbrains/projector-clion`):

```shell
docker run --rm -p 8887:8887 -it IMAGE_NAME
```

This will run **Projector Server with the selected JetBrains IDE** locally.

To access Projector Server with IDE, use <http://localhost:8887/>.

If you want to **save the state of the container between launches**, go further: take a look
at [`run-container-mounted.sh`](#run-container-mountedsh-containername) script.

## Run IntelliJ IDEA in Docker (building image yourself)

If you don't want to pull an image, you can build it yourself. Scripts in this repo will help you to do it.

Firstly, please check your **Docker version**: since we
use [Docker BuildKit](https://docs.docker.com/develop/develop-images/build_enhancements/) in our scripts, a current
version of Docker (18.09 or higher) is required.

Clone this `projector-docker` repo and make the following actions:

```shell script
./clone-projector-core.sh
./build-container.sh
./run-container.sh
```

This will run **Projector Server with IntelliJ IDEA Community** locally.

To access Projector Server with IDE, use <http://localhost:8887/>.

There will be a sample Kotlin + Java project opened, just close some dialogs. If you want to try **your project**, you can clone it via Git.

If you **don't want to clone the project every time** you start the container, go further: use [`run-container-mounted.sh`](#run-container-mountedsh-containername).

## Accessing IDE run on another machine

If you want to access IDE run on another host, you need to change page parameters. Here are the default parameters, so you probably need to change `localhost` in both places to needed IP: <http://localhost:8887/?host=localhost&port=8887>.

## Script list
### `clone-projector-core.sh`
Clones projector projects from Git to proper locations:
- `../projector-server`.

**Note**: if you already have these projects locally existing, you can place them to proper locations and avoid this script.

### `build-container.sh [containerName [ideDownloadUrl]]`
Compiles Projector inside Docker and builds a Docker container locally.

### `build-container-dev.sh [containerName [ideDownloadUrl]]`
Compiles Projector outside Docker and builds a Docker container locally. The script assumes the JAVA_HOME is set to a JDK 11.

### `create-image.sh [containerName [tarGzFileName]]`
Creates a Docker image from a built container and saves it as a `tar.gz` archive.

### `load-image.sh [tarGzFileName]`
Loads the Docker image locally.

### `run-container.sh [containerName]`
Runs the Docker container.

Starts the Projector server and hosts web client files on port 8887.

### `run-container-mounted.sh [containerName]`
Runs the Docker container. Also, it mounts your `~/projector-docker` dir as the home dir in the container, so settings and projects can be saved between launches.

Feel free to change `~/projector-docker` dir to your desired one. **Please note that the host dir should be created manually** to eliminate permissions problems.

**For Mac and Windows hosts**: to speed up work with mounted dirs, you can try adding the `:cached` suffix. It will look like this: `-v ~/projector-docker:/home/projector-user:cached`.

Starts the Projector server and hosts web client files on port 8887.

## Tested IDEs
When you build a container, there is an optional `ideDownloadUrl` parameter, so you can select different IDEs to use. Most JetBrains IDEs of versions 2019.1-2020.2 will work. Tested with:
- https://download.jetbrains.com/idea/ideaIC-2019.3.4.tar.gz
- https://download.jetbrains.com/idea/ideaIC-2020.1.1.tar.gz
- https://download.jetbrains.com/idea/ideaIC-202.5103.13.tar.gz
- https://download.jetbrains.com/idea/ideaIU-2019.3.4.tar.gz
- https://download.jetbrains.com/cpp/CLion-2019.3.5.tar.gz
- https://download.jetbrains.com/go/goland-2019.3.4.tar.gz
- https://download.jetbrains.com/datagrip/datagrip-2019.3.4.tar.gz
- https://download.jetbrains.com/webide/PhpStorm-2019.3.4.tar.gz
- https://download.jetbrains.com/python/pycharm-community-2019.3.4.tar.gz
- https://download.jetbrains.com/python/pycharm-professional-2019.3.4.tar.gz
- https://download.jetbrains.com/webstorm/WebStorm-2020.2.2.tar.gz
- https://download.jetbrains.com/rider/JetBrains.Rider-2020.2.4.tar.gz

You can find the up-to-date list of tested IDEs
here: [compatible_ide.json](https://github.com/JetBrains/projector-installer/blob/master/projector_installer/compatible_ide.json)
.

If you want to try other distribution, click "Other versions" on
an [IDE download page](https://www.jetbrains.com/idea/download/) and copy a link to a `tar.gz` file. Please ensure that
you select `tar.gz` **with JBR**, not without.

## FAQ

**Q**: The set of available packages in the container doesn't suit me, what to do?  
**A**: You can add the required packages to the [Dockerfile](Dockerfile) (for example, where `packages for user convenience` are installed) and build your own image. If you believe the packages are handy for most users and don't take much space, feel free to create a PR to this repo adding a package. Please note that we consider these buildscripts as samples, there is no goal to cover all the possible needs in them, but there is a goal to show how to create an image with Projector inside.

**Q**: Can I somehow **secure** my **connection**?  
**A**: Yes, it's described in [documentation](https://jetbrains.github.io/projector-client/mkdocs/latest/ij_user_guide/server_customization/#making-the-connection-secure). You can place the file to a mounted dir.

**Q**: Can I assign a **connection password**?  
**A**: Yes, it's described in [documentation](https://jetbrains.github.io/projector-client/mkdocs/latest/ij_user_guide/server_customization/#assigning-connection-password).

**Q**: I’ve mounted the home dir in **Docker** container and it seems that I **can’t edit files**, there are exceptions about permissions and missing files. What to do?  
**A**: It can happen when the owner of the directory on the host is root. So you should recreate the directory on the host yourself with normal user permissions.

## License
[Apache 2.0](LICENSE.txt).
