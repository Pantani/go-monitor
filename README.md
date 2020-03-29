# Go-monitor

Prometheus Monitoring Server with a Grafana Dashboard for TrustWallet Go applications.

## Requirements

- Docker

## Use

Change the env var `APP_URL` inside the `.env` file for your application URL, and run:

```
docker-compose up -d
```

Grafana Dashboard: `localhost:3000`
Prometheus: `localhost:9090`
