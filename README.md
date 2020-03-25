# projector-docker
Some scripts to create and run a Docker container with projector and IDEA.

## TL;DR
If you've just cloned the `projector-docker` repo, you probably should make the following actions:
1. `clone-projector-core.sh`.
1. `build-container.sh`.
1. `run-container.sh`.

If you've received a `tar.gz` Docker image, you probably should run the following ones:
1. `load-image.sh`.
1. `run-container.sh`.

Both instructions will run **nginx** and **projector with IDEA** locally.

To access projector with IDEA, use <http://localhost:8080/projector/>.

## Accessing IDEA run on another machine

If you want to access IDEA run on another host, you need to change page parameters. Here are the default parameters, so you probably need to change `localhost` in both places to needed IP: <http://localhost:8080/projector/?host=localhost&port=8887>.

## Script list
### `clone-projector-core.sh`
Clones projector from Git.

**Note**: you can omit this cloning by creating a symlink to your existing `projector-core`:
```shell script
ln -s YOUR_REAL_PATH_TO_PROJECTOR_CORE PATH_TO_PROJECTOR_DOCKER/projector-core
```

### `build-container.sh`
Builds a Docker container locally.

### `build-container-dev.sh`
Compiles and builds a Docker container locally. The script assumes the JAVA_HOME is set to a JDK 11.

### `create-image.sh`
Creates a Docker image from a built container and saves it as a `tar.gz` archive.

### `load-image.sh`
Loads the Docker image locally.

### `run-container.sh`
Runs the Docker container.

Starts the server on 8887.

### `run-container-mounted.sh`
Runs the Docker container. Also, it mounts your `~/IdeaProjects` dir to the container, so you can open your projects. Feel free to change `~/IdeaProjects` dir to your desired one. Please note that the projects are visible from Docker, but permissions can forbid to compile them by default. Maybe permissions can be changed to allow that.

**For Mac and Windows hosts**: to speed up work with mounted dirs, you can try adding the `:cached` suffix. It will look like this: `-v /Users/<USER>/<PATH>:<DOCKER_PATH>:cached`.

Starts the server on 8887.
