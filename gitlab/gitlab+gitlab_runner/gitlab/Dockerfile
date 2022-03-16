## 转载自：http://www.sunrisenan.com/docs/boge/boge-1d5f8uble7t8s
FROM gitlab/gitlab-ce:13.8.6-ce.0

RUN rm /etc/apt/sources.list \
    && echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
COPY sources.list /etc/apt/sources.list

RUN apt-get update -yq && \
    apt-get install -y vim iproute2 net-tools iputils-ping curl wget software-properties-common unzip postgresql-client-12 && \
    rm -rf /var/cache/apt/archives/*

RUN ln -svf /usr/bin/pg_dump /opt/gitlab/embedded/bin/pg_dump

#---------------------------------------------------------------
# docker build -t gitlab/gitlab-ce:13.8.6-ce.1 .