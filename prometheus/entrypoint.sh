#!/bin/sh

prometheusconfig=`/bin/cat /prometheus/prometheus.yml 2>/dev/null | wc -l`
if [[ "$prometheusconfig" -gt "0" ]]; then

    echo "Changing the app url: " $APP_URL
    sed -i -e 's|{{.APP_URL}}|'$APP_URL'|g' /prometheus/prometheus.yml
    sed -i -e 's|{{.API_TOKEN}}|'$API_TOKEN'|g' /prometheus/prometheus.yml
    /bin/cat /prometheus/prometheus.yml > /etc/prometheus/prometheus.yml

fi

BIND=9090
echo "****** Runing Prometheus ******"
/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --web.listen-address=:$BIND
