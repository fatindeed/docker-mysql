FROM alpine

ARG ALPINE_MIRROR
ARG TIMEZONE=Asia/Shanghai

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL maintainer="James Zhu <168262+fatindeed@users.noreply.github.com>" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="MySQL:alpine" \
      org.label-schema.description="MySQL(MariaDB) Docker image based on Alpine Linux" \
      org.label-schema.url="https://hub.docker.com/r/fatindeed/mysql/" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/fatindeed/docker-mysql" \
      org.label-schema.vendor="James Zhu" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"

COPY docker-entrypoint.sh /usr/local/bin/

RUN set -xe; \
    chmod a+x /usr/local/bin/*; \
# Switch to a mirror if given
    if [ -n "$ALPINE_MIRROR" ]; then \
        ALPINE_MIRROR=${ALPINE_MIRROR//\//\\\/}; \
        sed -i "s/http:\/\/dl-cdn.alpinelinux.org/$ALPINE_MIRROR/g" /etc/apk/repositories; \
    fi; \
    apk add --no-cache pwgen tzdata mysql mysql-client; \
# Setup timezone
    if [ -n "$TIMEZONE" ]; then \
        cp "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime; \
        echo "$TIMEZONE" > /etc/timezone; \
    fi; \
# Setup MariaDB
    mkdir -p /run/mysqld /etc/mysql/conf.d; \
    chown mysql:mysql /run/mysqld; \
    echo -e "[mysqld]\nskip-host-cache\nskip-name-resolve" > /etc/mysql/conf.d/docker.cnf

VOLUME ["/var/lib/mysql"]

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306

CMD ["mysqld", "--user=mysql", "--console"]