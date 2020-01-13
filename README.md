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

To access the run IDEA, use <http://172.31.131.39:8080/?flushDelay=1&host=localhost&port=8887>.

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
