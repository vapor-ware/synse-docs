---
hero: Basic Concepts
---

This page provides details on some of the core components and concepts in the SDK. Understanding
these components and concepts will make it easier to configure, run, and debug plugins, as well
as develop plugins of your own.

## Plugin Metadata

All plugins need a small amount of metadata associated with them. It is up to the plugin author
to supply this metadata. It includes:

- ***Name***: *(required)* The name of the plugin.
- ***Maintainer***: *(required)* The plugin author/maintainer.
- ***Description***: A brief description of the plugin.
- ***VCS***: A link to the plugins version control (e.g. GitHub).

Metadata should be set on plugin initialization:

```go
package main

import (
	"log"
	
	"github.com/vapor-ware/synse-sdk/sdk"
)

var (
	pluginName       = "example plugin"
	pluginMaintainer = "vaporio"
	pluginDesc       = "An example plugin snippet"
)

func main() {
	sdk.SetPluginInfo(
		pluginName,
		pluginMaintainer,
		pluginDesc,
		"",
	)

	// Create a new Plugin instance.
	plugin, err := sdk.NewPlugin()
	if err != nil {
		log.Fatal(err)
	}

	// Run the plugin.
	if err := plugin.Run(); err != nil {
		log.Fatal(err)
	}
}
```

An additional piece of plugin metadata is generated from the specified fields, above, called
the "tag" (not to be confused with device tags). A plugin tag is generated from the `name` and
`maintainer` fields, following the template `{{maintainer}}/{{name}}` where both maintainer and
name are normalized. The normalization steps are:

- lower case
- convert dashes (`-`) to underscores (`_`)
- convert spaces to dashes (`-`)

## Plugin ID

TODO

## Deterministic Device IDs

TODO


## Device Tags

Tags are ways to group devices, making it easier to perform operations on multiple devices
at once, such as getting readings.

> For more detailed information on device tags and their structure, see the [Tags](../../server/user/tags.md)
> page in the Synse Server documentation.

The SDK will auto-generate some tags, such an an ID tag and a Type tag. Additional tags can be
specified for a device in its [configuration](configuration.device.md#configuration-options).

```yaml
version: 3
devices:
- type: example
  tags:
  - tag1
  - vapor/example:tag
  instances:
  - info: an example device instance
    tags:
    - vapor/another:tag
```

## Device Handlers

All plugins will need to implement one ore more *Device Handlers*. These are the pieces which
define the read/write capabilities of the plugin. All plugin handlers have a name and are referenced
by that name in device configuration. If you are configuring devices for a plugin, you will need to
know which handlers it supports.

If you are writing a plugin, the handler names should be well documented so it is easy to configure
devices for a plugin. As the handler name is its reference, the names are required to be unique. If
there are multiple handlers with the same name, the SDK will raise an error. A device handler can 
specify a number of functions which define its capabilities:

- **Read**: Defines single-device read behavior. 
- **Bulk Read**: Defines group read behavior for all devices which use the handler.
- **Write**: Defines single-device write behavior.
- **Listen**: Defines push-based read behavior, where the plugin listens for the pushed readings.

For handlers which define a write function, `Actions` may also be specified -- this is a list of
the write actions that the handler supports which is surfaced to upstream user as device metadata.

!!! note
    If both a *read* and *bulk read* handler are defined, the bulk read capabilities will be
    ignored and the handler will only use the single-read function. If bulk read is desired,
    ensure no single-read function is defined.

The presence/absence of functions on a device handler determine a device's capabilities. That is
to say, if a handler implements a `Read` function, but no `Write` function, the device is readable
but not writable.

### Example

Below is an example of a simple device handler definition as well as how it is registered to
the plugin.

*handler.go*

```go
package main

import (
	"log"
	"time"

	"github.com/vapor-ware/synse-sdk/sdk"
	"github.com/vapor-ware/synse-sdk/sdk/output"
)

var ExampleHandler = sdk.DeviceHandler{
	Name: "time",
	Read: func(device *sdk.Device) (readings []*output.Reading, e error) {
		now := time.Now().UTC().Format(time.RFC3339)
		
		return []*output.Reading{
			Time.MakeReading(now),
		}, nil
	},
}
```

!!! note
    For the definition of the `Time` output type, see the [Outputs](#outputs) example.

*main.go*

```go
package main

import (
	"log"

	"github.com/vapor-ware/synse-sdk/sdk"
)

func main() {
    // Create a new plugin instance
    plugin, err := sdk.NewPlugin()
	if err != nil {
		log.Fatal(err)
	}
	
	// Register device handlers
	err = plugin.RegisterDeviceHandlers(
		&ExampleHandler,
	)
	if err != nil {
		log.Fatal(err)
	}
	
	// Run the plugin
	if err := plugin.Run(); err != nil {
		log.Fatal(err)
	}
}
```


## Device Aliases

Devices each have an ID associated with them. This ID is generated by the SDK in a deterministic
way. The generated IDs are just computed hashes, which are not human-friendly when it comes to
identifying or referencing devices manually. To make this easier, the Synse SDK allows devices
to have an *alias* specified. The alias can be anything, but in general, it should be something that
is human readable and can identify it in a meaningful way.

The device alias can be used in place of the ID for all Synse operations. There are two ways that
an alias can be specified: explicitly, or via template.

### Explict Alias

An explicit alias is one which is just a static string that is not processed any further. For
example, this would be set in the [device configuration](configuration.device.md#alias) with:

```yaml
version: 3
devices:
- type: example-device
  instances:
  - info: example device instance 1
    alias:
      name: device-1
``` 

This configuration defines `device-1` as the device's explicit alias.

### Templated Alias

The device alias can also be defined with a [Go template](https://golang.org/pkg/text/template/) string.

```yaml
version: 3
devices:
- type: example-device
  instances:
  - info: example device instance 1
    metadata:
      partNumber: abc123
    alias:
      template: 'device-{{ .Device.Type }}-{{ meta "partNumber" }}-1'
```

The `AliasContext` provides the context for the template. From it, the device information and plugin information
can be referenced.

***Alias Context***

| Key  | Description |
| :--- | :---------- |
| `.Meta.Name` | The name of the plugin. |
| `.Meta.Maintainer` | The plugin maintainer. |
| `.Meta.Description` | The description of the plugin. |
| `.Meta.VCS` | The VCS string for the plugin. |
| `.Device.Type` | The type of the device. |
| `.Device.Info` | The devices configured human-readable info string. |
| `.Device.Handler` | The name of the device's [device handler](#device-handlers). |
| `.Device.SortIndex` | The optional custom sort index for the device. |
| `.Device.ScalingFactor` | The optional scaling factor configured for the device's readings. |
| `.Device.WriteTimeout` | The duration string for the device write timeout. |
| `.Device.Output` | The name of the optional custom output. |

Additionally, the SDK provides some simple template functions:

| Function | Description | Example |
| :------- | :---------- | :------ |
| `env` | Get a value from the environment. | `{{env "PLUGIN_HOSTNAME"}}` |
| `meta` | Get a value from the device's configured metadata. | `{{meta "manufacturer"}}` |

## Outputs

Outputs are definitions of the metadata around reading outputs. They provide information on the
type of reading, what the reading precision should be, and the unit of the reading. The SDK has
a number of common outputs built in, available in the `github.com/vapor-ware/synse-sdk/sdk/output`
package. Some of these include:

- Frequency
- Humidity
- Pressure
- Temperature
- State
- Status
- Voltage

All readings need to be associated with an output, as without the context that an Output provides,
the reading is effectively just an arbitrary value of some kind. Outputs can be defined by a [Device
Handler](#device-handlers), if the handler is device-specific, or in the [device configuration](configuration.device.md#output),
if the handler is general-purpose.

The built-in Outputs are a good starting point, but are not enough for all devices/plugins. Custom
Outputs may be registered with the plugin (see below for an example), but it is important to note
that since Outputs are referenced by name, their names must be unique. If an Output is defined with
conflicts with an existing one (whether custom or built-in), the SDK will raise an error.

### Example

Below is an example of a simple output type definition for a custom "time" reading, as well as how
it is registered to the plugin. See the [Device Handlers](#device-handlers) section for an example
of how it can be used.

*outputs.go*

```go
package main

import (
	"github.com/vapor-ware/synse-sdk/sdk/output"
)

var (
	Time = output.Output{
		Name:      "time",
		Type:      "timestamp",
	}
)
```

*main.go*

```go
package main

import (
	"log"

	"github.com/vapor-ware/synse-sdk/sdk"
)

func main() {
    // Create a new plugin instance
    plugin, err := sdk.NewPlugin()
	if err != nil {
		log.Fatal(err)
	}
	
	// Register custom outputs
	err = plugin.RegisterOutputs(
		&Time,
	)
	if err != nil {
		log.Fatal(err)
	}
	
	// Run the plugin
	if err := plugin.Run(); err != nil {
		log.Fatal(err)
	}
}
```