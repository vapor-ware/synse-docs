---
hero: Plugin Configuration 
---

The plugin configuration defines how a plugin should behave at runtime. It specifies
the options ranging from logging level, performance tuning, and transport security.

Plugin configuration is defined in a YAML file. Most configuration options
have sane default values. For simple plugins, these default values may suffice
and no additional plugin configuration may be required.

## Config Location

The plugin configuration YAML must be named `config.{yml|yaml}`. By default, the
plugin will look for that file in the following directories (in the order in which
they are specified):

- `$PWD/` (`./`)
- `./config/`
- `/etc/synse/plugin/config/`

Once a matching YAML file is found, it will attempt to load it as a plugin configuration
and will not continue searching in any remaining paths.

As plugins are intended to be run in a container, a custom configuration would
need to be mounted in to one of the locations above, e.g.

```
docker run \
  -v $PWD/custom-cfg.yaml:/etc/synse/plugin/config/config.yaml \
  ...
```

### Overriding Config Location

The plugin configuration may be specified off of the default search paths. In
this case, the plugin will need to be told where the config file is. This can
be done with the `PLUGIN_CONFIG` environment variable. For example, if the
configuration file were in `/tmp/cfg`:

```
docker run \
  -v $PWD/custom-cfg.yaml:/tmp/cfg/config.yaml \
  -e PLUGIN_CONFIG=/tmp/cfg/config.yaml \
  ...
```

The `PLUGIN_CONFIG` environment variable can be used to specify either the
full path to the file (e.g. `/tmp/cfg/config.yaml`), or the path to the
directory containing the config file (e.g. `/tmp/cfg`).

This can also be done simply in a compose file:

```yaml
version: '3'
services:
  plugin:
    image: plugin-image
    environment:
      PLUGIN_CONFIG: /tmp/cfg/config.yml
    volumes:
    - ./custom-cfg.yaml:/tmp/cfg/config.yaml
```

## Config Policies

A plugin can define a configuration policy for its plugin configuration. There are two
policy types that can be set:

| Policy | Description |
| :----- | :---------- |
| *Optional* | The plugin configuration is optional. If no plugin configuration is found, either on the search path or via env override, the plugin will just use configuration defaults. |
| *Required* | The plugin configuration is required. If no plugin configuration is found, either on the search path or via env override, the plugin will terminate with an error. This should be used in the cases where the default values would not be enough to fully configure the plugin. |

The default config policy for plugin configuration is `Optional`.

Configuration policies may be set as a `PluginOption` in the plugin constructor, e.g.

```go
import (
  "github.com/vapor-ware/synse-sdk/sdk"
)

func main() {
  plugin, err := sdk.NewPlugin(
    sdk.PluginConfigRequired(),
  )
}
```


## Configuration Options

This section describes the supported configuration options for a plugin, including any
restrictions on the values and any defaults.

-----

### Version

| | |
| ------ | ------ |
| ***description*** | The major version of the plugin configuration. For all plugins using the SDK for Synse v3, this should be `3`. |
| ***type*** | int |
| ***key*** | `version` |

```YAML tab=
version: 3
```

-----

### Debug

| | |
| ------ | ------ |
| ***description*** | Run the plugin with debug logging. If false, the plugin will run with normal (info) logging. |
| ***type*** | bool |
| ***key*** | `debug` |
| ***default*** | `false` |
| ***supported*** | `true`, `false` |

```YAML tab=
debug: true
```

-----

### ID

Settings for generating the plugin ID namespace.

Group key: `id`

#### Use Machine ID

| | |
| ------ | ------ |
| ***description*** | Use the machine ID as part of the input for plugin namespace generation. This is disabled by default, as it does not work well in containers, the primary run environment for plugins. |
| ***type*** | bool|
| ***key*** | `useMachineID` |
| ***default*** | `false` |
| ***supported*** | `true`, `false` |

```YAML tab=
id:
  useMachineID: true
```

#### Use Plugin Tag

| | |
| ------ | ------ |
| ***description*** | Use the plugin tag (string comprised of maintainer and plugin name) as part of the input for plugin namespace generation. |
| ***type*** | bool |
| ***key*** | `usePluginTag` |
| ***default*** | `true` |
| ***supported*** | `true`, `false` |

```YAML tab=
id:
  usePluginTag: true
```

#### Use Env

| | |
| ------ | ------ |
| ***description*** | Use the values from the specified environment variables as part of the input for plugin namespace generation. |
| ***type*** | list[string] |
| ***key*** | `useEnv` |
| ***default*** | `[]` |

```YAML tab=
id:
  useEnv:
  - ENV_1
  - ENV_2
```

#### Use Custom

| | |
| ------ | ------ |
| ***description*** | Use custom string identifiers as part of the input for plugin namespace generation. |
| ***type*** | list[string] |
| ***key*** | `useCustom` |
| ***default*** | `[]` |

```YAML tab=
id:
  useCustom:
  - foo
  - bar
```

-----

### Metrics

Setting for exposing application metrics.

Group key: `metrics`

#### Enabled

| | |
| ------ | ------ |
| ***description*** | Enable application metrics export via Prometheus. |
| ***type*** | bool |
| ***key*** | `enabled` |
| ***default*** | `false` |
| ***supported*** | `true`, `false` |

```YAML tab=
metrics:
  enabled: true
```

-----

### Settings

The settings for the runtime behavior of the plugin.

Group key: `settings`

#### Mode

| | |
| ------ | ------ |
| ***description*** | The run mode of the plugin scheduler. This can either be "serial" or "parallel". |
| ***type*** | string |
| ***key*** | `mode` |
| ***default*** | `parallel` |
| ***supported*** | `serial`, `parallel` |

```YAML tab=
settings:
  mode: parallel
```

#### Listen

The settings for how listener-type handlers should behave.

Group key: `listen`

***Disable***

| | |
| ------ | ------ |
| ***description*** | Globally disable listening for the plugin. |
| ***type*** | bool |
| ***key*** | `disable` |
| ***default*** | `false` |
| ***supported*** | `true`, `false` |

```YAML tab=
settings:
  listen:
    disable: false
```

#### Read

The settings for how read-type handlers should behave.

Group key: `read`

***Disable***

| | |
| ------ | ------ |
| ***description*** | Globally disable reading for the plugin. |
| ***type*** | bool |
| ***key*** | `disable` |
| ***default*** | `false` |
| ***supported*** | `true`, `false` |

```YAML tab=
settings:
  read:
    disable: false
```

***Interval***

| | |
| ------ | ------ |
| ***description*** | The duration that the read loop should sleep between iterations. An interval may be useful for tuning the performance of a plugin, particularly for serial protocols. It is not recommended to set the interval to 0 as the loop would be unbounded and would consume excessive CPU resources. |
| ***type*** | duration |
| ***key*** | `interval` |
| ***default*** | `1s` |
| ***supported*** | [duration](https://golang.org/pkg/time/#example_Duration) strings |

```YAML tab=
settings:
  read:
    interval: 1s
```

***Delay***

| | |
| ------ | ------ |
| ***description*** | A plugin-global delay between successive reads within a single loop iteration. A delay may be useful for tuning the performance of a plugin, particularly for serial protocols. |
| ***type*** | duration |
| ***key*** | `delay` |
| ***default*** | `0s` |
| ***supported*** | [duration](https://golang.org/pkg/time/#example_Duration) strings |

```YAML tab=
settings:
  read:
    delay: 1s
```

***QueueSize***

| | |
| ------ | ------ |
| ***description*** | The size of the read queue. This is the size of the channel that passes along readings as they are collected. This can be set to tune performance for read-intensive plugins. |
| ***type*** | int |
| ***key*** | `queueSize` |
| ***default*** | `128` |

```YAML tab=
settings:
  read:
    queueSize: 128
```

#### Write 

The settings for how write-type handlers should behave.

Group key: `write`

***Disable***

| | |
| ------ | ------ |
| ***description*** | Globally disable writing for the plugin. |
| ***type*** | bool |
| ***key*** | `disable` |
| ***default*** | `false` |
| ***supported*** | `true`, `false` |

```YAML tab=
settings:
  write:
    disable: false
```

***Interval***

| | |
| ------ | ------ |
| ***description*** | The duration that the write loop should sleep between iterations. An interval may be useful for tuning the performance of a plugin, particularly for serial protocols. It is not recommended to set the interval to 0 as the loop would be unbounded and would consume excessive CPU resources. |
| ***type*** | duration |
| ***key*** | `interval` |
| ***default*** | `1s` |
| ***supported*** | [duration](https://golang.org/pkg/time/#example_Duration) strings |

```YAML tab=
settings:
  write:
    interval: 1s
```

***Delay***

| | |
| ------ | ------ |
| ***description*** | A plugin-global delay between successive writes within a single loop iteration. A delay may be useful for tuning the performance of a plugin, particularly for serial protocols. |
| ***type*** | duration |
| ***key*** | `delay` |
| ***default*** | `0s` |
| ***supported*** | [duration](https://golang.org/pkg/time/#example_Duration) strings |

```YAML tab=
settings:
  write:
    delay: 1s
```

***QueueSize***

| | |
| ------ | ------ |
| ***description*** | The size of the write queue. This is the size of the channel that passes along write requests as they are collected. This can be set to tune performance for write-intensive plugins. |
| ***type*** | int |
| ***key*** | `queueSize` |
| ***default*** | `128` |

```YAML tab=
settings:
  write:
    queueSize: 128
```

***BatchSize***

| | |
| ------ | ------ |
| ***description*** | The maximum number of writes to process in a single loop iteration. This can be set to tune performance for plugins with slow-writing devices. |
| ***type*** | int |
| ***key*** | `batchSize` |
| ***default*** | `128` |

```YAML tab=
settings:
  write:
    batchSize: 128
```

#### Transaction

The settings relating to write transactions.

Group key: `transaction`

***TTL***

| | |
| ------ | ------ |
| ***description*** | The time-to-live for the transaction in the transaction cache. |
| ***type*** | duration |
| ***key*** | `ttl` |
| ***default*** | `5m` |
| ***supported*** | [duration](https://golang.org/pkg/time/#example_Duration) strings |

```YAML tab=
transaction:
  ttl: 5m
```

#### Limiter

Settings for rate limiting on reads and writes.

Group key: `limiter`

***Rate***

| | |
| ------ | ------ |
| ***description*** | The limit, or maximum frequency of events. A rate of 0 signifies "unlimited". |
| ***type*** | int |
| ***key*** | `rate` |
| ***default*** | `0` |

```YAML tab=
limiter:
  rate: 0
```

***Burst***

| | |
| ------ | ------ |
| ***description*** | The bucket size for the limiter, or maximum number of events that can be fulfilled at once. If this is 0, it will take the same value as the rate. |
| ***type*** | int |
| ***key*** | `burst` |
| ***default*** | `0` |

```YAML tab=
limiter:
  burst: 0
```

#### Cache

Settings for the in-memory windowed cache of plugin reading data.

Group key: `cache`

***Enabled***

| | |
| ------ | ------ |
| ***description*** | Enable the in-memory cache to hold a small window of reading data. |
| ***type*** | bool |
| ***key*** | `enabled` |
| ***default*** | `false` |
| ***supported*** | `true`, `false` |

```YAML tab=
cache:
  enabled: true
```

***TTL***

| | |
| ------ | ------ |
| ***description*** | The time-to-live for a reading in the cache. This is only used if the cache is enabled. Once a reading exceeds this TTL, it is removed from the cache. |
| ***type*** | duration |
| ***key*** | `ttl` |
| ***default*** | `3m` |
| ***supported*** | [duration](https://golang.org/pkg/time/#example_Duration) strings |

```YAML tab=
cache:
  ttl: 3m
```

-----

### Network

Settings for a plugin's networking behavior.

Group key: `network`

#### Type

| | |
| ------ | ------ |
| ***description*** | The protocol type for the plugin to use for gRPC transport. |
| ***type*** | string |
| ***key*** | `type` |
| ***default*** | `tcp` |
| ***supported*** | `tcp`, `unix` |

```YAML tab=
network:
  type: tcp
```

#### Address

| | |
| ------ | ------ |
| ***description*** | The address the gRPC server will run on. For "tcp", this should be the host/port (e.g. "0.0.0.0:5001"). For "unix", this should be the path to the socket (e.g. "/tmp/plugin.sock"). |
| ***type*** | string |
| ***key*** | `address` |

```YAML tab=
network:
  address: "0.0.0.0:5001"
```

#### TLS

Settings for TLS/SSL configuration for the plugin's gRPC server. If this is not set, insecure transport is used.

Group key: `tls`

***Cert***

| | |
| ------ | ------ |
| ***description*** | The path to the cert file to use for the gRPC server. |
| ***type*** | string |
| ***key*** | `cert` |

```YAML tab=
network:
  tls:
    cert: /path/to/cert.crt
```

***Key***

| | |
| ------ | ------ |
| ***description*** | The path to the key file to use for the gRPC server. |
| ***type*** | string |
| ***key*** | `key` |

```YAML tab=
network:
  tls:
    key: /path/to/key.key
```

***CA Certs***

| | |
| ------ | ------ |
| ***description*** | A list of certificate authority certs to use. If none are specified, the OS system-wide CA certs are used. |
| ***type*** | list[string] |
| ***key*** | `caCerts` |

```YAML tab=
network:
  tls:
    caCerts: 
    - /path/to/cacerts.ca
```

***Skip Verify***

| | |
| ------ | ------ |
| ***description*** | Skip certificate checks. |
| ***type*** | bool |
| ***key*** | `skipVerify` |
| ***default*** | `false` |
| ***supported*** | `true`, `false` |

```YAML tab=
network:
  tls:
    skipVerify: true
```

-----

### Dynamic Registration

Settings for dynamic device registration,

Group key: `dynamicRegistration`

#### Config

| | |
| ------ | ------ |
| ***description*** | The configuration(s) for dynamic device registration which is performed at runtime. |
| ***type*** | list[map] |
| ***key*** | `config` |
| ***default*** | `[]` |

```YAML tab=
dynamicRegistration:
  config:
  - foo: 1
    bar: "baz"
```

-----

### Health

Settings for plugin health checks.

Group key: `health`

#### Health File

| | |
| ------ | ------ |
| ***description*** | The fully-qualified path to the file which will be used to signal that the plugin is healthy. If the file does not exist, the plugin can be considered in an "unhealthy" state. |
| ***type*** | string |
| ***key*** | `healthFile` |
| ***default*** | `/etc/synse/plugin/healthy` |

```YAML tab=
health:
  healthFile: /etc/synse/plugin/healthy
```

#### Update Interval

| | |
| ------ | ------ |
| ***description*** | The frequency with which the health file will be updated. This is essentially how frequently the plugin health status gets updated. |
| ***type*** | duration |
| ***key*** | `updateInterval` |
| ***default*** | `30s` |
| ***supported*** | [duration](https://golang.org/pkg/time/#example_Duration) strings |

```YAML tab=
health:
  updateInterval: 30s
```

#### Checks

Settings for the individual plugin health check behaviors.

Group key: `checks`

***Disable Defaults***

| | |
| ------ | ------ |
| ***description*** | Disable the default plugin health checks which are built-in to the plugin. |
| ***type*** | bool |
| ***key*** | `disableDefaults` |
| ***default*** | `false` |
| ***supported*** | `true`, `false` |

```YAML tab=
health:
  checks:
    disableDefaults: false
```

## Example

Below is an example of a relatively simple plugin configuration:

```yaml
version: 3
debug: true
network:
  type: tcp
  address: ":5001"
settings:
  mode: parallel
  read:
    interval: 1s
  write:
    interval: 2s
```

