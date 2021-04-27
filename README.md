# QuadStingray/webtrees:2.0.15

![Docker Build Status](https://img.shields.io/docker/build/quadstingray/webtrees) ![Docker Pulls](https://img.shields.io/docker/pulls/quadstingray/webtrees) ![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/quadstingray/webtrees) ![Docker Image Version (latest by date)](https://img.shields.io/docker/v/quadstingray/webtrees) 

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
docker pull quadstingray/webtrees:2.0.15
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
docker run --publish 80:80 quadstingray/webtrees:2.0.15
```



## Persistence
Webtrees store his dat by default  `/var/www/html/data`. So for persistence of your data and database config, you should mount an external volume to that path.

## Environment Variables

| Variable                       | Default Value    | Informations                                                                             |
|:-------------------------------|:-----------------|:-----------------------------------------------------------------------------------------|
| PHP_MAX_EXECUTION_TIME         | "80"             |  PHP Script max execution time                                                           |
| PHP_POST_MAX_SIZE              | "265M"           |  Max size for post request                                                               |
| PHP_UPLOAD_MAX_FILESIZE        | "265M"           |  Max size of File Upload                                                                 |
| PHP_OTHER_CONFIG               | ""               |  You can inject every php.ini value, e.g. `track_errors = yes \n register_globals = off` |
