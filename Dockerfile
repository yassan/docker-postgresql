FROM ubuntu:bionic-20181204 AS add-apt-repositories

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y wget gnupg \
 && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
 && echo 'deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main' >> /etc/apt/sources.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CB64A157 \
 && echo "deb http://ppa.launchpad.net/groonga/ppa/ubuntu bionic main" >> /etc/apt/sources.list \
 && echo "deb-src http://ppa.launchpad.net/groonga/ppa/ubuntu bionic main"  >> /etc/apt/sources.list

FROM ubuntu:bionic-20181204

ARG GIT_REVITION=unkown
ARG GIT_ORIGIN=unkown
ARG IMAGE_NAME=unkown

LABEL maintainer="yassan0627@gmail.com" \
      git-revision=$GIT_REVISION \
      git-origin=$GIT_ORIGIN \
      image-name=$IMAGR_NAME

ENV PG_APP_HOME="/etc/docker-postgresql" \
    PG_VERSION=10 \
    PG_USER=postgres \
    PG_HOME=/var/lib/postgresql \
    PG_RUNDIR=/run/postgresql \
    PG_LOGDIR=/var/log/postgresql \
    PG_CERTDIR=/etc/postgresql/certs

ENV PG_BINDIR=/usr/lib/postgresql/${PG_VERSION}/bin \
    PG_DATADIR=${PG_HOME}/${PG_VERSION}/main

COPY --from=add-apt-repositories /etc/apt/trusted.gpg /etc/apt/trusted.gpg

COPY --from=add-apt-repositories /etc/apt/sources.list /etc/apt/sources.list

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y acl sudo postgresql-${PG_VERSION}-pgroonga groonga-tokenizer-mecab\
      postgresql-client-${PG_VERSION} postgresql-contrib-${PG_VERSION} \
 && ln -sf ${PG_DATADIR}/postgresql.conf /etc/postgresql/${PG_VERSION}/main/postgresql.conf \
 && ln -sf ${PG_DATADIR}/pg_hba.conf /etc/postgresql/${PG_VERSION}/main/pg_hba.conf \
 && ln -sf ${PG_DATADIR}/pg_ident.conf /etc/postgresql/${PG_VERSION}/main/pg_ident.conf \
 && rm -rf ${PG_HOME} \
 && rm -rf /var/lib/apt/lists/*

COPY runtime/ ${PG_APP_HOME}/

COPY entrypoint.sh /sbin/entrypoint.sh

RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 5432/tcp

WORKDIR ${PG_HOME}

ENTRYPOINT ["/sbin/entrypoint.sh"]
