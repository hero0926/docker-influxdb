FROM ubuntu
MAINTAINER Matt Baldwin (baldwin@stackpointcloud.com)

RUN rm -rf /var/lib/apt/lists/*
RUN apt clean
RUN apt-get clean

ENV DEVIAN_FRONTEND noninteractive
RUN \
 apt update && apt-get update && apt-get -y --no-install-recommends install \
    ca-certificates \
    software-properties-common \
    python-django-tagging \
    python-simplejson \
    python-memcache \
    python-ldap \
    python-cairo \
    python-pysqlite2 \
    python-pip \
    gunicorn \
    supervisor \
    nginx-light \
    nodejs \
    git \
    curl \
    build-essential \
    python-dev


RUN apt install debian-archive-keyring
RUN add-apt-repository 'deb http://httpredir.debian.org/debian experimental main'
RUN add-apt-repository 'deb http://httpredir.debian.org/debian sid main'

RUN apt-get install wget

RUN wget http://launchpadlibrarian.net/109052632/python-support_1.0.15_all.deb
RUN dpkg -i python-support_1.0.15_all.deb

WORKDIR /opt
RUN \
  curl -s -o grafana.tar.gz "https://grafanarel.s3.amazonaws.com/builds/grafana-latest.linux-x64.tar.gz" && \
  curl -s -o influxdb_amd64.deb "https://s3.amazonaws.com/influxdb/influxdb_0.8.8_amd64.deb" && \
  mkdir grafana && \
  tar -xzf grafana.tar.gz --directory grafana --strip-components=1 && rm grafana.tar.gz && \
  dpkg -i influxdb_amd64.deb && rm influxdb_amd64.deb && \
  echo "influxdb soft nofile unlimited" >> /etc/security/limits.conf && \
  echo "influxdb hard nofile unlimited" >> /etc/security/limits.conf && \
  apt-get clean

COPY config.js /opt/grafana/config.js
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY config.toml /opt/influxdb/current/config.toml

VOLUME ["/opt/influxdb/shared/data"]

EXPOSE 80 8083 8086 2003

CMD ["supervisord", "-n"]

