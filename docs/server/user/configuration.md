---
hero: Configuration 
---

This page describes the configuration options and methodologies for Synse Server.
It has a sane set of default configurations allowing it to run "out of the box",
however minimal configuration is required to register any plugins with it.

Synse Server has three sources of configuration:

1. Built-in defaults
2. Configuration file (YAML)
3. Environment variables

Each item in the list above takes precedence over the item above it (e.g. environment
variable configuration(s) would override YAML file configuration(s)).

## Configuring the Server

### Specifying a Custom Config File

Synse Server looks for a YAML file (`.yml` or `.yaml` extension) named `config` in the
current working directory (`./`) and within the default configuration directory (`/etc/synse/server`).
If the configuration file is not found in either of those locations, no config file is
used and it will just use the default values and any specified environment variables.

A custom configuration specified in `custom-config.yml` can be used to configure a
Synse Server instance by placing the config in one of the search paths, e.g.

```
docker run -d \
    -p 5000:5000 \
    -v $PWD/custom_config.yml:/etc/synse/server/config.yml \
    vaporio/synse-server
```

Assuming the configuration is correct and Synse Server could successfully load it,
you can verify that the config was picked up either by looking at the server logs,
or by hitting the [`/config`](../api.v3.md#config) endpoint.

The above can also be done simply in a compose file:

```yaml
version: '3'
services:
  synse-server:
    image: vaporio/synse-server
    ports:
    - "5000:5000"
    volumes:
    - ./custom_config.yml:/etc/synse/server/config.yml
```

### Specifying Environment Variables

Many configuration options may also be set via environment variable. The general rule is
that each environment variable is the upper-cased configuration key path joined with underscores
and prefixed with `SYNSE_`. That is to say, for the example config `#!json {"foo": {"bar": 20}}`,
the corresponding environment variable would be `SYNSE_FOO_BAR`.

As a more real example, logging and the transaction cache TTL can be set with:

```
docker run -d \
    -p 5000:5000 \
    -e SYNSE_LOGGING=debug \
    -e SYNSE_CACHE_TRANSACTION_TTL=500 \
    vaporio/synse-server
```

The above can also be done simply in a compose file:

```yaml
version: '3'
services:
  synse-server:
    image: vaporio/synse-server
    ports:
    - "5000:5000"
    environment:
    - SYNSE_LOGGING=debug
    - SYNSE_CACHE_TRANSACTION_TTL=500
```

## Configuration Options

This section describes the supported configuration values for Synse Server, including
any restrictions on the values, any defaults, and whether or not it can be set
via environment variable. 

-----

### Logging

| | |
| ------ | ------ |
| ***description*** | The logging level for Synse Server. The values for this option are case-insensitive. |
| ***type*** | string |
| ***key*** | `logging` |
| ***env variable*** | `SYNSE_LOGGING` |
| ***default*** | `info` |
| ***supported*** | `debug`, `info`, `warning`, `error` |

```YAML tab=
logging: info
```

```Environment tab=
SYNSE_LOGGING=info
```

-----

### Pretty JSON

| | |
| ------ | ------ |
| ***description*** | Output the HTTP API response JSON in a "pretty" format by adding spaces and newlines. |
| ***type*** | bool |
| ***key*** | `pretty_json` |
| ***env variable*** | -- |
| ***default*** | `true` |
| ***supported*** | `true`, `false` |

```YAML tab=
pretty_json: true
```

-----

### Locale

| | |
| ------ | ------ |
| ***description*** | Set the locale for logging messages and error output. |
| ***type*** | string |
| ***key*** | `locale` |
| ***env variable*** | `LANGUAGE` |
| ***default*** | `en_US` |
| ***supported*** | `en_US` |

```YAML tab=
locale: en_US
```

```Environment tab=
LANGUAGE=en_US
```

-----

### Plugin

Configuration options for registering plugins with the server instance.

#### TCP

| | |
| ------ | ------ |
| ***description*** | Register plugins configured for TCP-based communication. This is the preferred mode for registering plugins. This option holds list of addresses for each plugin to register. |
| ***type*** | list[string] |
| ***key*** | `plugin.tcp` |
| ***env variable*** | `SYNSE_PLUGIN_TCP` |
| ***default*** | -- |

```YAML tab=
plugin:
  tcp:
  - localhost:5001
  - 192.1.53.2:5002
```

```Environment tab=
SYNSE_PLUGIN_TCP="localhost:5001,192.1.53.2:5002"
```

#### Unix

| | |
| ------ | ------ |
| ***description*** | Register plugins configured for Unix socket based communication. Generally, plugins should be configured for TCP. This option holds a list of paths to the unix sockets for each plugin to register. |
| ***type*** | list[string] |
| ***key*** | `plugin.unix` |
| ***env variable*** | `SYNSE_PLUGIN_UNIX` |
| ***default*** | -- |

```YAML tab=
plugin:
  unix:
  - /tmp/example.sock
```

```Environment tab=
SYNSE_PLUGIN_UNIX="/tmp/example.sock"
```

!!! note
    When registering a plugin via unix socket, Synse Server needs access to that socket. If the
    server is running in a docker container, this means the socket must be mounted in. For convenience,
    Synse Server creates the `/tmp/synse` directory on the container which can be used as a mount
    location for sockets, e.g.
    
    ```
    docker run \
        ...
        -v $PWD/plugin.sock:/tmp/synse/plugin.sock \
        ...
    ```

#### Discover

Configuration options for dynamic plugin discovery. Currently, the only mode of plugin discovery that is
supported is via Kubernetes endpoint labels. As more modes are supported, this section will be updated.
Examples of using Kubernetes discovery can be found on the [Advanced Usage](advanced.md) page. 

***Kubernetes Namespace***

| | |
| ------ | ------ |
| ***description*** | The Kubernetes namespace to use for any configured plugin selectors. If there are no plugin selectors defined, this will have no effect. |
| ***type*** | string | 
| ***key*** | `plugin.discover.kubernetes.namespace` |
| ***env variable*** | `SYNSE_PLUGIN_DISCOVER_KUBERNETES_NAMESPACE` |
| ***default*** | -- |

```YAML tab=
plugin:
  discover:
    kubernetes:
      namespace: default
```

```Environment tab=
SYNSE_PLUGIN_DISCOVER_KUBERNETES_NAMESPACE=default
```

***Kubernetes Endpoint Labels***

| | |
| ------ | ------ |
| ***description*** | The endpoint labels to use as selectors for Kubernetes services which belong to plugins. This is a map where the key is the label name and the value is the value which the key should match to. |
| ***type*** | map[string]string |
| ***key*** | `plugin.discover.kubernetes.endpoints.labels` |
| ***env variable*** | `SYNSE_PLUGIN_DISCOVER_KUBERNETES_ENDPOINTS_LABELS_<KEY>` |
| ***default*** | -- |

```YAML tab=
plugin:
  discover:
    kubernetes:
      endpoints:
        labels:
          app: synse
          component: plugin
```

```Environment tab=
SYNSE_PLUGIN_DISCOVER_KUBERNETES_ENDPOINTS_LABELS_APP=synse
SYNSE_PLUGIN_DISCOVER_KUBERNETES_ENDPOINTS_LABELS_COMPONENT=plugin
```

-----

### Cache

Configuration options for Synse Server caches. There are two caches in the server:

- **device**: A lookup cache for devices and their associated tags.
- **transaction**: A lookup cache for write transactions and their associated devices.

#### Device

***Rebuild Every***

| | |
| ------ | ------ |
| ***description*** | The time interval, in seconds, to invalidate and rebuild the device cache to ensure it is up to date. |
| ***type*** | int |
| ***key*** | `cache.device.rebuild_every` |
| ***env variable*** | -- |
| ***default*** | 180 |

```YAML tab=
cache:
  device:
    rebuild_every: 180  # three minutes
```

#### Transaction

***TTL***

| | |
| ------ | ------ |
| ***description*** | The time-to-live, in seconds, for a transaction in the cache. After this TTL, it will be cleared from the cache and removed from the system. |
| ***type*** | int |
| ***key*** | `cache.transaction.ttl` |
| ***env variable*** | -- |
| ***default*** | 300 |

```YAML tab=
cache:
  transaction:
    ttl: 300  # five minutes
```

-----

### gRPC

Configuration options for requests made from the server to plugins via the internal [gRPC API](https://github.com/vapor-ware/synse-server-grpc).

***Timeout***

| | |
| ------ | ------ |
| ***description*** | The timeout, in seconds, for a gRPC request. |
| ***type*** | int |
| ***key*** | `grpc.timeout` |
| ***env variable*** | -- |
| ***default*** | 3 |

```YAML tab=
grpc:
  timeout: 3
```

#### TLS

TLS configurations for the internal server --> plugin gRPC client.

***Cert***

| | |
| ------ | ------ |
| ***description*** | The path to the TLS certificate for securing the API connection. |
| ***type*** | string |
| ***key*** | `grpc.tls.cert` |
| ***env variable*** | `SYNSE_GRPC_TLS_CERT` |
| ***default*** | -- |

```YAML tab=
grpc:
  tls:
    cert: /path/to/cert.pem
```

```Environment tab=
SYNSE_GRPC_TLS_CERT="/path/to/cert.pem"
```

-----

### SSL

Configuration options for securing the server's HTTP/WebSocket APIs.

***Cert***

| | |
| ------ | ------ |
| ***description*** | The path to the SSL/TLS certificate for securing the API connection. |
| ***type*** | string |
| ***key*** | `ssl.cert` |
| ***env variable*** | `SYNSE_SSL_CERT` |
| ***default*** | -- |

```YAML tab=
ssl:
  cert: /path/to/cert.pem
```

```Environment tab=
SYNSE_SSL_CERT="/path/to/cert.pem"
```

***Key***

| | |
| ------ | ------ |
| ***description*** | The path to the SSL/TLS key for securing the API connection. |
| ***type*** | string |
| ***key*** | `ssl.key` |
| ***env variable*** | `SYNSE_SSL_KEY` |
| ***default*** | -- |

```YAML tab=
ssl:
  key: /path/to/key.key
```

```Environment tab=
SYNSE_SSL_KEY="/path/to/key.key"
```

-----

### Metrics

Configuration options for exposing application metrics via Prometheus exporter.

***Enabled***

| | |
| ------ | ------ |
| ***description*** | Enable application metrics export. |
| ***type*** | bool |
| ***key*** | `metrics.enabled` |
| ***env variable*** | `SYNSE_METRICS_ENABLED` |
| ***default*** | `false` |
| ***supported*** | `true`, `false` |

```YAML tab=
metrics:
  enabled: true
```

```Environment tab=
SYNSE_METRICS_ENABLED=true
```

-----


## Examples






Examples
--------

## Default Configuration

Below is what the default configuration for Synse Server looks like as YAML.

```yaml
locale: en_US
pretty_json: false
logging: info
cache:
  meta:
    ttl: 20
  transaction:
    ttl: 300
grpc:
  timeout: 3
```

## Complete Configuration

Below is a valid (if contrived) and complete example configuration file.

```yaml
logging: debug
pretty_json: true
locale: en_US
plugin:
  tcp:
    - localhost:6000
    - 54.53.52.51:5555
  unix:
    - /tmp/run/example.sock
  discover:
    kubernetes:
      endpoints:
        labels:
          app: synse
          component: plugin
cache:
  meta:
    # time to live in seconds
    ttl: 20
  transaction:
    # time to live in seconds
    ttl: 300
grpc:
  # timeout in seconds
  timeout: 5
  tls:
    cert: /tmp/ssl/example.crt
```