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

### Devices

### Device Prototype

#### Type

#### Metadata

#### Tags

#### Data

#### Handler

#### Write Timeout

#### Instances

### Device Instance

#### Type

#### Info

#### Tags

#### Data

#### Output

#### Sort Index

#### Handler

#### Alias

***Name***

***Template***

#### Scaling Factor

#### Apply

#### Write Timeout

#### Disable Inheritance