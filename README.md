# projector-docker
[![JetBrains incubator project](https://jb.gg/badges/incubator.svg)](https://confluence.jetbrains.com/display/ALL/JetBrains+on+GitHub)

Some scripts to create and run a Docker container with projector and IDE.

For more info, please check out [Projector.md](https://github.com/JetBrains/projector-server/blob/master/docs/Projector.md).

## Run IntelliJ IDEA in Docker
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

If you want to try other distribution, click "Other versions" on an [IDE download page](https://www.jetbrains.com/idea/download/) and copy a link to a `tar.gz` file. Please ensure that you select `tar.gz` **with JBR**, not without.

## FAQ
**Q**: Can I somehow **secure** my **connection**?  
**A**: You can enable SSL for connection. First of all, provide the `ORG_JETBRAINS_PROJECTOR_SERVER_SSL_PROPERTIES_PATH` environment variable on the server-side using the `-e` parameter of `docker run`. It should contain a path to a file with properties: you can place the file to a mounted dir. Example of such a file:

```shell script
STORE_TYPE=JKS
FILE_PATH=/path-to/keystore.jks
STORE_PASSWORD=mypassword
KEY_PASSWORD=mypassword
```

If you do everything right, the server launch log will contain something like `WebSocket SSL is enabled: /path-to/properties.file`. If it logs `WebSocket SSL is disabled` instead, something is wrong. Maybe the env variable can’t be found or there is an exception parsing the properties file (it will be logged).  
After that, enable it on the client-side by adding the `wss` query parameter like this: <http://localhost:8080/projector/?wss>. Make sure that your browser trusts the certificate you use.

**Q**: Can I assign a **connection password**?  
**A**: Yes, you can set a password that will be validated on connection start on the server. On the server-side, provide the `ORG_JETBRAINS_PROJECTOR_SERVER_HANDSHAKE_TOKEN` environment variable containing the password. On the client-side, you can specify the password in query parameters like this: <http://localhost:8080/projector/?token=mySecretPassword>.

**Q**: I’ve mounted the home dir in **Docker** container and it seems that I **can’t edit files**, there are exceptions about permissions and missing files. What to do?  
**A**: It can happen when the owner of the directory on the host is root. So you should recreate the directory on the host yourself with normal user permissions.

## License
[GPLv2](LICENSE.txt).
