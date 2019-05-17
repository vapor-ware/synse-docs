---
hero: Monitoring 
---

Synse Server does not currently provide a built-in monitoring solution for the
data that it exposes. It can provide basic application-level metrics via a
[Prometheus](https://prometheus.io) exporter.

## Configuring

By default, application metrics export is disabled. To enable it, you would need
to set the following values in the application [configuration](configuration.md#metrics):

```yaml
metrics:
  enabled: true
```

This can also be done via environment variable

```
SYNSE_METRICS_ENABLED=true
```

## Getting metrics

Once configured, you can run Synse Server and verify that metrics are enabled by
hitting `#!shell http://${server}/metrics`. If enabled, the route should resolve and
you should get Prometheus export data, e.g.

```
# HELP python_gc_collected_objects Objects collected during gc
# TYPE python_gc_collected_objects histogram
python_gc_collected_objects_bucket{generation="0",le="500.0"} 132.0
python_gc_collected_objects_bucket{generation="0",le="1000.0"} 132.0
python_gc_collected_objects_bucket{generation="0",le="5000.0"} 132.0
python_gc_collected_objects_bucket{generation="0",le="10000.0"} 132.0
python_gc_collected_objects_bucket{generation="0",le="50000.0"} 132.0
python_gc_collected_objects_bucket{generation="0",le="+Inf"} 132.0
python_gc_collected_objects_count{generation="0"} 132.0
python_gc_collected_objects_sum{generation="0"} 1045.0
python_gc_collected_objects_bucket{generation="1",le="500.0"} 12.0
...
```

## Viewing application metrics

An example deployment is provided in the project's [GitHub repository](https://github.com/vapor-ware/synse-server/tree/master/monitoring)
which starts up a Synse Server instance, a Prometheus instance to collect application metrics,
and a Grafana instance (with pre-built example dashboard) to visualize those metrics.

From the project source, you can simply run:

```bash
# vapor-ware/synse-server: monitoring/
docker-compose up -d
```

All components will start up and be exposed locally

| Service | Address |
| :------ | :------ |
| **synse-server** | `localhost:5000` |
| **prometheus** | `localhost:9090` |
| **grafana** | `localhost:3000` |

The login for the Grafana dashboard at `localhost:3000` is `admin`/`admin`. Once logged in,
you can select the "Synse Server Application Metrics" dashboard. 

To get requests data, you will need to hit Synse Server [endpoints](../api.v3.md), e.g.

- `localhost:5000/test`
- `localhost:5000/version`
- `localhost:5000/v3/config`
- `localhost:5000/v3/plugin`
- `localhost:5000/v3/scan`
- ...


![](../../assets/img/server-monitoring.png)