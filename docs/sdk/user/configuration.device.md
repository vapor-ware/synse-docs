---
hero: Device Configuration 
---

Device configuration(s) define the devices that a plugin will manage and expose to
the rest of the Synse platform. Device configs generally specify metadata for that
device, making it easier for a human to identify it, and any information needed for
the plugin to interface with the device -- think protocol/address information.

Device configuration can be defined in one or more YAML files, contained in the same
directory. All plugins will need a device configuration in order to expose devices.

## Config Location

The device configuration YAML(s) do not have any requirements for the file name,
but they all must have either the `.yml` or `.yaml` file extension. The plugin
will automatically search for device configurations in the following directories
(in the order in which they are listed):

- `./config/device`
- `/etc/synse/plugin/config/device`

Once any YAML files are found, it will attempt to load them as device configurations
and will not continue searching in any remaining paths.

As plugins are intended to be run in a container, a custom configuration would
need to be mounted in to one of the locations above, e.g.

```
docker run \
  -v $PWD/device-cfg.yaml:/etc/synse/plugin/config/device/device.yaml \
  ...
```

### Overriding Config Location

Device configurations may be specified off of the default search paths. In
this case, the plugin will need to be told which directory contains the device
configuration(s). This can be done with the `PLUGIN_DEVICE_CONFIG` environment
variable. For example, if the device configs were in `/tmp/devices/`:

```
docker run \
  -v $PWD/configs/:/tmp/devices/ \
  -e PLUGIN_DEVICE_CONFIG=/tmp/devices \
  ...
```

The `PLUGIN_DEVICE_CONFIG` environment variable may also specify a single file
to use as the device configuration, if all device configs are defined in one file.

This can also be done simply in a compose file:

```yaml
version: '3'
services:
  plugin:
    image: plugin-image
    environment:
      PLUGIN_DEVICE_CONFIG: /tmp/cfg/device.yml
    volumes:
    - ./device-cfg.yaml:/tmp/cfg/device.yaml
```

## Config Policies

A plugin can define a configuration policy for its device configuration(s). There are two
policy types that can be set:

| Policy | Description |
| :----- | :---------- |
| *Optional* | The device configuration is optional. If no device configuration is found, either on the search path or via env override, the plugin will not terminate and will continue running normally. This is generally set when a plugin either has some configs hard-coded, or is designed to load devices dynamically and does not need a device configuration file. |
| *Required* | The device configuration is required. If no device configuration is found, either on the search path or via env override, the plugin will terminate with an error. |

The default config policy for plugin configuration is `Required`.

Configuration policies may be set as a `PluginOption` in the plugin constructor, e.g.

```go
import (
  "github.com/vapor-ware/synse-sdk/sdk"
)

func main() {
  plugin, err := sdk.NewPlugin(
    sdk.DeviceConfigOptional(),
  )
}
```


## Configuration Options

This section describes the supported configuration options for a device configuration, including any
restrictions on the values.

-----

### Version

| | |
| ------ | ------ |
| ***description*** | The major version of the device configuration. For all plugins using the SDK for Synse v3, this should be `3`. |
| ***type*** | int |
| ***key*** | `version` |

```YAML tab=
version: 3
```

-----

### Devices

| | |
| ------ | ------ |
| ***description*** | The collection of devices defined in the configuration. |
| ***type*** | list[[Device Prototype](#device-prototype)] |
| ***key*** | `devices` |

```YAML tab=
devices:
- <device prototype>
```

-----

### Device Prototype

A device prototype defines the high-level information which applies to a class of
[device instances](#device-instance).

#### Type

| | |
| ------ | ------ |
| ***description*** | The type of the device. Types are not strictly defined and are primarily used as metadata for the higher-level consumer to help identify and categorize the device. Plugins are free to define their own types. |
| ***type*** | string |
| ***key*** | `type` |

```YAML tab=
version: 3
devices:
- type: temperature
```

#### Context

| | |
| ------ | ------ |
| ***description*** | Any additional context information which should be associated with a device instance's reading(s). If specified here, all prototype instances will inherit the context, unless inheritance is disabled. |
| ***type*** | map[string]string |
| ***key*** | `context` |

```YAML tab=
version: 3
devices:
- context:
    manufacturer: vapor
    part_number: 123
```

#### Tags

| | |
| ------ | ------ |
| ***description*** | The set of tags to apply to each of the devices which are instances of this device prototype. It is not required to define supplemental tags. |
| ***type*** | list[string] |
| ***key*** | `tags` |

```YAML tab=
version: 3
devices:
- tags:
  - synse/tag1
  - synse/tag2
```

#### Data

| | |
| ------ | ------ |
| ***description*** | Data that can be applied to each of the devices which are instances of this device prototype. Device data is plugin specific and generally provides the information needed for the plugin to interface with the device, e.g. an address, port, path, etc. If specified, this data will be merged with any instance data, where the instance data will override any conflicting keys. |
| ***type*** | map[string]Any |
| ***key*** | `data` |

```YAML tab=
version: 3
devices:
- data:
    address: localhost:5432
    port: 3000
    timeout: 10
```

#### Handler

| | |
| ------ | ------ |
| ***description*** | The name of the [device handler]() which should be used for devices which are instances of the device prototype. The device handler is defined by the plugin. If the specified handler does not exist, an error will be raised. If specified, this value will be applied to all device instances unless inheritance is disabled or the instance specifies its own handler explicitly. |
| ***type*** | string |
| ***key*** | `handler` |

```YAML tab=
version: 3
devices:
- handler: temperature
```

#### Write Timeout

| | |
| ------ | ------ |
| ***description*** | A custom write timeout for all devices which are instances of the device prototype. This is the time within which a write transaction will remain valid. If a write is still processing after the timeout period, it is cancelled. If this is not specified, a default value of 30s is used. |
| ***type*** | duration |
| ***key*** | `writeTimeout` |
| ***default*** | `30s` |
| ***supported*** | [duration](https://golang.org/pkg/time/#example_Duration) strings |

```YAML tab=
version: 3
devices:
- writeTimeout: 20s
```

#### Instances

| | |
| ------ | ------ |
| ***description*** | The collection of [device instances](#device-instance) that belong to the device prototype. These instances will inherit any specified prototype config unless inheritance is disabled, or the instance provides an overriding value. |
| ***type*** | list[[device instance](#device-instance)] |
| ***key*** | `instances` |

```YAML tab=
version: 3
devices:
-
  instances:
  - <device instance>
```

-----

### Device Instance

#### Type

| | |
| ------ | ------ |
| ***description*** | The type of the device. Types are not strictly defined and are primarily used as metadata for the higher-level consumer to help identify and categorize the device. Plugins are free to define their own types. A device instance can inherit its *type* from its device prototype. |
| ***type*** | string |
| ***key*** | `type` |

```YAML tab=
version: 3
devices:
-
  instances:
  - type: temperature
```

#### Info

| | |
| ------ | ------ |
| ***description*** | A short human-readable description/summary of the device. This is optional and can be used to help identify a device. |
| ***type*** | string |
| ***key*** | `info` |

```YAML tab=
version: 3
devices:
-
  instances:
  - info: Top of rack front temperature sensor
```

#### Context

| | |
| ------ | ------ |
| ***description*** | Any additional context information which should be associated with a device instance's reading(s). Any values specified here will be applied to the reading context automatically by the SDK. |
| ***type*** | map[string]string |
| ***key*** | `context` |

```YAML tab=
version: 3
devices:
-
  instances:
    context:
      model: abc123
      position: rear
```

#### Tags

| | |
| ------ | ------ |
| ***description*** | The set of tags to apply to each of the devices which are instances of this device prototype. It is not required to define supplemental tags. A device instance can inherit (and merge) *tags* from its device prototype. |
| ***type*** | list[string] |
| ***key*** | `tags` |

```YAML tab=
version: 3
devices:
-
  instances:
  - tags:
    - synse/tag1
    - synse/tag2
```

#### Data

| | |
| ------ | ------ |
| ***description*** | The protocol/plugin/device-specific configuration which will be used by the plugin to interface with the device. For example, this could be an address, port, or other similar configuration. A device instance can inherit (and merge) *data* from its device prototype. |
| ***type*** | map[string]Any |
| ***key*** | `data` |

```YAML tab=
version: 3
devices:
-
  instances:
  - data:
      address: /dev/ttyUSB0
      baud: 9600
      parity: e
```

#### Output

| | |
| ------ | ------ |
| ***description*** | The name of the output which the device instance will use. This is optional: some plugins do not need this specified in config as the [device handler]() will already specify this. This config option can be useful for generalized plugins where a handler is meant to be general purpose and could return any kind of output. Outputs are defined in the SDK and by the plugin. If the specified output does not exist, an error is raised. |
| ***type*** | string |
| ***key*** | `output` |

```YAML tab=
version: 3
devices:
-
  instances:
  - output: temperature
```

#### Sort Index

| | |
| ------ | ------ |
| ***description*** | A 1-based index which can be used as a sort parameter in higher level device aggregations (e.g. [Synse Server](../../server/intro.md). This can be useful for displaying devices in a particular order. A 0 value indicates no sort index preference. |
| ***type*** | int |
| ***key*** | `sortIndex` |
| ***default*** | `0` |

```YAML tab=
version: 3
devices:
-
  instances:
  - sortIndex: 2
```

#### Handler

| | |
| ------ | ------ |
| ***description*** | The name of the [device handler]() which should be used for the devices instance. The device handler is defined by the plugin. If the specified handler does not exist, an error will be raised. A device instance can inherit the *handler* from its device prototype. |
| ***type*** | string |
| ***key*** | `handler` |

```YAML tab=
version: 3
devices:
-
  instances:
  - handler: temperature
```

#### Alias

An [alias]() which can be used to reference the device in place of the generated device ID. The alias should be human-readable. It can either be a pre-defined string, or a go template which will be rendered by the SDK.

***Name***

| | |
| ------ | ------ |
| ***description*** | The aliased name for the device. This value is used as-is with no additional processing. |
| ***type*** | string |
| ***key*** | `name` |

```YAML tab=
version: 3
devices:
-
  instances:
  - alias:
      name: front-temperature
```

***Template***

| | |
| ------ | ------ |
| ***description*** | A [Go template](https://golang.org/pkg/text/template/) string which will be rendered into the alias for the device. The template takes in an [`AliasContext`]() for rendering, which includes a reference to the plugin metadata and device data. |
| ***type*** | string |
| ***key*** | `template` |

```YAML tab=
version: 3
devices:
-
  instances:
  - template: "{ .Device.Type }-{ meta port }"
```

#### Scaling Factor

| | |
| ------ | ------ |
| ***description*** | An optional value which specifies a scaling transformation (e.g. a multiplier) to be applied to the device's reading(s). Generally, this only needs to be used for generalized plugins where the plugin handler does not do any scaling. This value should resolve to be numeric. By default, it will have a value of 1 (e.g., no scaling). Negative values and fractional values are supported as well. This can be the value itself (e.g. "0.01") or a mathematical representation of the value (e.g. "1e-2"). |
| ***type*** | string |
| ***key*** | `scalingFactor` |

```YAML tab=
version: 3
devices:
-
  instances:
  - scalingFactor: -1e-3
```

#### Apply

| | |
| ------ | ------ |
| ***description*** | An optional list of [functions]() which will be applied to the device's reading values, in the order that they are defined. There are some built-in functions which the SDK provides; a plugin can also register their own functions. |
| ***type*** | list[string] |
| ***key*** | `apply` |

```YAML tab=
version: 3
devices:
-
  instances:
  - type: temperature
    apply:
    - "FtoC" 
```

#### Write Timeout

| | |
| ------ | ------ |
| ***description*** | A custom write timeout for the device instance. This is the time within which a write transaction will remain valid. If a write is still processing after the timeout period, it is cancelled. If this is not specified, a default value of 30s is used. A device instance can inherit the *writeTimeout* from its device prototype. |
| ***type*** | duration |
| ***key*** | `writeTimeout` |
| ***default*** | `30s` |
| ***supported*** | [duration](https://golang.org/pkg/time/#example_Duration) strings |

```YAML tab=
version: 3
devices:
-
  instances:
  - writeTimeout: 20s
```

#### Disable Inheritance

| | |
| ------ | ------ |
| ***description*** | Disable configuration inheritance from the device prototype for the device instance. |
| ***type*** | bool |
| ***key*** | `disableInheritance` |
| ***default*** | `false` |
| ***supported*** | `true`, `false` |

```YAML tab=
version: 3
devices:
-
  instances:
  - disableInheritance: true
```

## Example

Below is an example of a relatively simple device configuration:

```yaml
version: 3
devices:

- type: temperature
  metadata:
    manufacturer: vapor
  data:
    timeout: 5
  instances:
  - info: Temperature Sensor 1
    alias: temperature-1
    data:
      address: /dev/ttyUSB0
  - info: Temperature Sensor 2
    alias: temperature-2
    data:
      address: /dev/ttyUSB1
      
- type: pressure
  metadata:
    manufacturer: vapor
  data:
    timeout: 5
  instances:
  - info: Pressure Sensor 1
    alias: pressure-1
    data:
      address: /dev/ttyUSB2
  - info: Pressure Sensor 2
    data:
      address: /dev/ttyUSB3
      
- type: led
  writeTimeout: 10s
  data:
    timeout: 6
    baud: 9600
  instances:
  - info: LED 1
    alias: led-1
    data:
      address: /dev/ttyUSB4
```