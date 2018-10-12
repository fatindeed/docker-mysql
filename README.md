# MySQL Docker image based on Alpine Linux

[![Docker Stars](https://img.shields.io/docker/stars/fatindeed/mysql.svg)](https://hub.docker.com/r/fatindeed/mysql/) [![Docker Pulls](https://img.shields.io/docker/pulls/fatindeed/mysql.svg)](https://hub.docker.com/r/fatindeed/mysql/) [![Docker Automated build](https://img.shields.io/docker/automated/fatindeed/mysql.svg)](https://hub.docker.com/r/fatindeed/mysql/) [![Docker Build Status](https://img.shields.io/docker/build/fatindeed/mysql.svg)](https://hub.docker.com/r/fatindeed/mysql/)

[![Download size](https://images.microbadger.com/badges/image/fatindeed/mysql.svg)](https://microbadger.com/images/fatindeed/mysql "Get your own image badge on microbadger.com") [![Version](https://images.microbadger.com/badges/version/fatindeed/mysql.svg)](https://microbadger.com/images/fatindeed/mysql "Get your own version badge on microbadger.com") [![Source code](https://images.microbadger.com/badges/commit/fatindeed/mysql.svg)](https://microbadger.com/images/fatindeed/mysql "Get your own commit badge on microbadger.com")

This image is based on the popular [Alpine Linux project](http://alpinelinux.org), available in [the `alpine` official image](https://hub.docker.com/_/alpine). Alpine Linux is much smaller than most distribution base images (~5MB), and thus leads to much slimmer images in general.

This variant is highly recommended when final image size being as small as possible is desired. The main caveat to note is that it does use [musl libc](http://www.musl-libc.org) instead of [glibc and friends](http://www.etalabs.net/compare_libcs.html), so certain software might run into issues depending on the depth of their libc requirements. However, most software doesn't have an issue with this, so this variant is usually a very safe choice. See [this Hacker News comment thread](https://news.ycombinator.com/item?id=10782897) for more discussion of the issues that might arise and some pro/con comparisons of using Alpine-based images.

To minimize image size, it's uncommon for additional related tools (such as `git` or `bash`) to be included in Alpine-based images. Using this image as a base, add the things you need in your own Dockerfile (see the [`alpine` image description](https://hub.docker.com/_/alpine/) for examples of how to install packages if you are unfamiliar).

# How to use this image

## Start a `mysql` server instance

Starting a MySQL instance is simple:

```console
$ docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql
```

... where `some-mysql` is the name you want to assign to your container, `my-secret-pw` is the password to be set for the MySQL root user.

## ... via [`docker stack deploy`](https://docs.docker.com/engine/reference/commandline/stack_deploy/) or [`docker-compose`](https://github.com/docker/compose)

Example `stack.yml` for `mysql`:

```yaml
# Use root/example as user/password credentials
version: '3.1'

services:

  db:
    image: fatindeed/mysql
    restart: always
    ports:
      - 3306:3306
    environment:
      MYSQL_ROOT_PASSWORD: example

  adminer:
    image: adminer
    restart: always
    ports:
      - 8080:8080
    links:
      - db
```

Run `docker stack deploy -c stack.yml mysql` (or `docker-compose -f stack.yml up`), wait for it to initialize completely, and visit `http://swarm-ip:8080`, `http://localhost:8080`, or `http://host-ip:8080` (as appropriate).

## Environment Variables

When you start the `mysql` image, you can adjust the configuration of the MySQL instance by passing one or more environment variables on the `docker run` command line. Do note that none of the variables below will have any effect if you start the container with a data directory that already contains a database: any pre-existing database will always be left untouched on container startup.

### `MYSQL_ROOT_PASSWORD`

This variable is mandatory and specifies the password that will be set for the MySQL `root` superuser account. In the above example, it was set to `my-secret-pw`.

### `MYSQL_DATABASE`

This variable is optional and allows you to specify the name of a database to be created on image startup. If a user/password was supplied (see below) then that user will be granted superuser access ([corresponding to `GRANT ALL`](http://dev.mysql.com/doc/en/adding-users.html)) to this database.

### `MYSQL_USER`, `MYSQL_PASSWORD`

These variables are optional, used in conjunction to create a new user and to set that user's password. This user will be granted superuser permissions (see above) for the database specified by the `MYSQL_DATABASE` variable. Both variables are required for a user to be created.

Do note that there is no need to use this mechanism to create the root superuser, that user gets created by default with the password specified by the `MYSQL_ROOT_PASSWORD` variable.

# Official repository

-   [Alpine Linux](https://hub.docker.com/_/alpine/)
-   [MySQL](https://hub.docker.com/_/mysql/)
-   [MariaDB](https://hub.docker.com/_/mariadb/)