# projector-docker
Some scripts to create and run a Docker container with projector and IDEA.

## TL;DR
If you've just cloned the `projector-docker` repo, you probably should make the following actions:
1. `clone-projector-core.sh`.
1. `build-container.sh` (the script assumes the JAVA_HOME is set to a JDK 11).
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
Compiles projector and builds a Docker container locally.

### `create-image.sh`
Creates a Docker image from a built container and saves it as a `tar.gz` archive.

### `load-image.sh`
Loads the Docker image locally.

### `run-container.sh`
Runs the Docker container.

Starts the server on 8887.
