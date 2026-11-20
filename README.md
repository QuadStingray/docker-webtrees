# quadstingray/webtrees:2.2.6

![Docker Pulls](https://img.shields.io/docker/pulls/quadstingray/webtrees) ![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/quadstingray/webtrees) ![Docker Image Version (latest by date)](https://img.shields.io/docker/v/quadstingray/webtrees) 

- [Introduction](#introduction)
  - [Contributing](#contributing)
  - [Issues](#issues)
- [Getting started](#getting-started)
  - [Installation](#installation)
  - [Quickstart](#quickstart)
  - [Persistence](#persistence)
  - [Environment Variables](#environment-variables)

# Introduction
Git-Repository to build [Docker](https://www.docker.com/) containerimage for [Webtrees](https://github.com/fisharebest/webtrees).

## Contributing
If you find this image helpfull, so you can see here how you can help:
- Send a pull request with your features and bug fixes
- Help users resolve their [issues](https://github.com/QuadStingray/docker-webtrees/issues).

## Issues
Before reporting your issue please try updating Docker to the latest version and check if it resolves the issue. Refer to the Docker [installation guide](https://docs.docker.com/installation) for instructions.

If that recommendations do not help then [report your issue](../../issues/new) along with the following information:

- Output of the `docker version` and `docker info` commands
- The `docker run` command or `docker-compose.yml` used to start the
  image. Mask out the sensitive bits.

# Getting started
## Installation
Automated builds of the image are available on
[Dockerhub](https://hub.docker.com/r/quadstingray/webtrees)

```bash
docker pull quadstingray/webtrees:2.2.6
```

Alternatively you can build the image yourself.
```bash
docker build . --tag 'quadstingray/webtrees:dev';
```

## docker-compose
You should now be able to use the image simply by running

```bash
docker-compose up -d
```
You access the server on http://localhost:10088/.  Choose mySQL for
the database, enter webtrees-mysql for the database host, and port 3306.
Username, password, and DB name are your choices.

## Quickstart
Start Webtrees using:

```bash
docker run --publish 80:80 quadstingray/webtrees:2.2.6
```

## Custom Module Manager
The image `quadstingray/webtrees:2.2.6-cmm` (or `latest-cmm`) additionally contains the [Custom Module Manager](https://github.com/Jefferson49/CustomModuleManager), which installs and updates webtrees custom modules from the control panel.

```bash
docker run --publish 80:80 quadstingray/webtrees:2.2.6-cmm
```

Modules installed by the Custom Module Manager are stored in `/var/www/html/modules_v4`. To keep them when the container is recreated, mount a named volume to that path (a named volume is initialized with the bundled Custom Module Manager, an empty bind mount would hide it).



## Security

The image is rebuilt from the current `php:8.5-apache` (Debian trixie) base with all Debian security updates applied. Build-only packages (`*-dev`, compiler) are removed again, and the PHP libraries shipped with webtrees (guzzle, commonmark, symfony, flysystem) are raised to their patched releases during the build.

- Apache runs its workers as `www-data`. The application code belongs to `root` and is read-only for the web server; only `/var/www/html/data` and `/var/www/html/modules_v4` are writable. Because of this, the built-in "upgrade webtrees" function of the control panel does not work. Upgrade by pulling a new image instead.
- Recommended `docker run` options (already set in `docker-compose.yml`):

```bash
docker run --publish 80:80 \
  --security-opt no-new-privileges:true \
  --cap-drop ALL --cap-add CHOWN --cap-add SETUID --cap-add SETGID --cap-add NET_BIND_SERVICE --cap-add KILL \
  quadstingray/webtrees:2.2.6
```

### NGINX2Root (CVE-2026-123007 and related)
This image uses Apache httpd, not nginx, and is not affected by the NGINX2Root bugs itself. If you run nginx as a reverse proxy in front of webtrees, update it to 1.30.7 / 1.31.9 or newer (or disable HTTP/2 until then). The published exploit chain escapes from the container through a Linux kernel bug in SCTP, so also update the kernel of the Docker host. Until a kernel fix is available, you can block the module on the host with `echo "install sctp /bin/false" > /etc/modprobe.d/disable-sctp.conf`. This does not help if SCTP is compiled into the kernel or the module is already loaded.

## Persistence
Webtrees store his dat by default  `/var/www/html/data`. So for persistence of your data and database config, you should mount an external volume to that path.

## Environment Variables

| Variable                       | Default Value    | Informations                                                                             |
|:-------------------------------|:-----------------|:-----------------------------------------------------------------------------------------|
| PHP_MAX_EXECUTION_TIME         | "80"             |  PHP Script max execution time                                                           |
| PHP_POST_MAX_SIZE              | "265M"           |  Max size for post request                                                               |
| PHP_UPLOAD_MAX_FILESIZE        | "265M"           |  Max size of File Upload                                                                 |
| PHP_OTHER_CONFIG               | ""               |  You can inject every php.ini value, e.g. `track_errors = yes \n register_globals = off` |
