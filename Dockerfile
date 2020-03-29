FROM ubuntu:latest

RUN apt-get update -y && \
    apt-get install wget gnupg2 software-properties-common adduser libfontconfig1 -y

ARG PROMETHEUS_VERSION="2.12.0"
ARG ARCH="amd64"
ARG OS="linux"

RUN cd /tmp && \
    wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.${OS}-${ARCH}.tar.gz && \
    tar -zxvf prometheus-${PROMETHEUS_VERSION}.${OS}-${ARCH}.tar.gz && \
    mv prometheus-${PROMETHEUS_VERSION}.${OS}-${ARCH}/ /prometheus/ && \
    export PATH=$PATH:/prometheus/

ARG GRAFANA_URL="https://s3-us-west-2.amazonaws.com/grafana-releases/master/grafana-latest.linux-x64.tar.gz"
ARG GF_UID="472"
ARG GF_GID="472"

ENV PATH=/usr/share/grafana/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    GF_PATHS_CONFIG="/etc/grafana/grafana.ini" \
    GF_PATHS_DATA="/var/lib/grafana" \
    GF_PATHS_HOME="/usr/share/grafana" \
    GF_PATHS_LOGS="/var/log/grafana" \
    GF_PATHS_PLUGINS="/var/lib/grafana/plugins" \
    GF_PATHS_PROVISIONING="/etc/grafana/provisioning"

RUN apt-get update && apt-get install -qq -y tar libfontconfig curl ca-certificates && \
    mkdir -p "$GF_PATHS_HOME/.aws" && \
    curl "$GRAFANA_URL" | tar xfvz - --strip-components=1 -C "$GF_PATHS_HOME" && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -r -g $GF_GID grafana && \
    useradd -r -u $GF_UID -g grafana grafana && \
    mkdir -p "$GF_PATHS_PROVISIONING/datasources" \
             "$GF_PATHS_PROVISIONING/dashboards" \
             "$GF_PATHS_LOGS" \
             "$GF_PATHS_PLUGINS" \
             "$GF_PATHS_DATA" && \
    cp "$GF_PATHS_HOME/conf/sample.ini" "$GF_PATHS_CONFIG" && \
    cp "$GF_PATHS_HOME/conf/ldap.toml" /etc/grafana/ldap.toml && \
    chown -R grafana:grafana "$GF_PATHS_DATA" "$GF_PATHS_HOME/.aws" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS" && \
    chmod 777 "$GF_PATHS_DATA" "$GF_PATHS_HOME/.aws" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS"

RUN ln -s /prometheus/prometheus /bin/prometheus
RUN ln -s /prometheus/promtool /bin/promtool

COPY ./prometheus/prometheus.yml /prometheus/prometheus.yml

COPY ./grafana/config.ini /etc/grafana/grafana.ini
COPY ./grafana/datasource.yml /etc/grafana/provisioning/datasources/datasource.yml
COPY ./grafana/dashboards/ /etc/grafana/provisioning/dashboards/

COPY ./entrypoint.sh /entrypoint.sh

EXPOSE $PORT 9090 3000

WORKDIR /

ENTRYPOINT [ "/entrypoint.sh" ]
CMD 