---
hero: Concepts
---

This page provides details on some of the core components and concepts in the SDK. Understanding
these components and concepts will make it easier to configure, run, and debug plugins, as well
as develop plugins of your own.

## Plugin Metadata


## Device Tags


> For more detailed information on device tags, see the [Tags](../../server/user/tags.md) page
> in the Synse Server documentation.

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


## Applying Functions to Device Readings


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