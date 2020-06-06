# projector-docker
[![JetBrains incubator project](https://jb.gg/badges/incubator.svg)](https://confluence.jetbrains.com/display/ALL/JetBrains+on+GitHub)

Some scripts to create and run a Docker container with projector and IDE.

For more info, please check out [Projector.md](https://github.com/JetBrains/projector-server/blob/master/docs/Projector.md).

## TL;DR
How to run IntelliJ IDEA Community in Docker and access it via a web browser?

Clone this `projector-docker` repo and make the following actions:
```shell script
./clone-projector-core.sh
./build-container.sh
./run-container.sh
```

This will run **nginx** and **Projector Server with IntelliJ IDEA Community** locally.

To access Projector Server with IDE, use <http://localhost:8080/projector/>.

There will be a sample Kotlin + Java project opened, just close some dialogs. If you want to try **your project**, you can clone it via Git.

If you don't want to clone the project every time you start the container, go further: use [`run-container-mounted.sh`](#run-container-mountedsh-containername).

## Accessing IDE run on another machine

If you want to access IDE run on another host, you need to change page parameters. Here are the default parameters, so you probably need to change `localhost` in both places to needed IP: <http://localhost:8080/projector/?host=localhost&port=8887>.

## Script list
### `clone-projector-core.sh`
Clones projector projects from Git to proper locations:
- `../projector-client`.
- `../projector-markdown-plugin`.
- `../projector-server`.

**Note**: if you already have these projects locally existing, you can place them to proper locations and avoid this script.

### `build-container.sh [containerName] [ideDownloadUrl]`
Builds a Docker container locally.

### `build-container-dev.sh [containerName] [ideDownloadUrl]`
Compiles and builds a Docker container locally. The script assumes the JAVA_HOME is set to a JDK 11.

### `create-image.sh [containerName] [tarGzFileName]`
Creates a Docker image from a built container and saves it as a `tar.gz` archive.

### `load-image.sh [tarGzFileName]`
Loads the Docker image locally.

### `run-container.sh [containerName]`
Runs the Docker container.

Starts the server on port 8887.

### `run-container-mounted.sh [containerName]`
Runs the Docker container. Also, it mounts your `~/projector-docker` dir as the home dir in the container, so settings and projects can be saved between launches.

Feel free to change `~/projector-docker` dir to your desired one. **Please note that the host dir should be created manually** to eliminate permissions problems.

**For Mac and Windows hosts**: to speed up work with mounted dirs, you can try adding the `:cached` suffix. It will look like this: `-v ~/projector-docker:/home/projector-user:cached`.

Starts the server on port 8887.

## License
[GPLv2](LICENSE.txt).
