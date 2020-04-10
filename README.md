# projector-docker
Some scripts to create and run a Docker container with projector and IDE.

## TL;DR
If you've just **cloned** the `projector-docker` repo, you probably should make the following actions:
```shell script
./clone-projector-core.sh
./build-container.sh [containerName] [ideDownloadUrl]
./run-container.sh [containerName]
```

If you've **received** a `tar.gz` Docker image, you probably should run the following ones:
```shell script
./load-image.sh [tarGzFileName]
./run-container.sh [containerName]
```

Both instructions will run **nginx** and **projector with IDE** locally.

To access projector with IDE, use <http://localhost:8080/projector/>.

## Accessing IDE run on another machine

If you want to access IDE run on another host, you need to change page parameters. Here are the default parameters, so you probably need to change `localhost` in both places to needed IP: <http://localhost:8080/projector/?host=localhost&port=8887>.

## Script list
### `clone-projector-core.sh`
Clones projector from Git.

**Note**: you can omit this cloning by creating a symlink to your existing `projector-core`:
```shell script
ln -s YOUR_REAL_PATH_TO_PROJECTOR_CORE PATH_TO_PROJECTOR_DOCKER/projector-core
```

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

Starts the server on 8887.

### `run-container-mounted.sh [containerName]`
Runs the Docker container. Also, it mounts your `~/projector-docker` dir as the home dir in the container, so settings and projects can be saved between launches.

Feel free to change `~/projector-docker` dir to your desired one. **Please note that the host dir should be created manually** to eliminate permissions problems.

**For Mac and Windows hosts**: to speed up work with mounted dirs, you can try adding the `:cached` suffix. It will look like this: `-v /Users/<USER>/<PATH>:<DOCKER_PATH>:cached`.

Starts the server on 8887.
