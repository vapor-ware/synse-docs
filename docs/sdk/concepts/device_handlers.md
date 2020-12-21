---
hero: Device Handlers
---

A *device handler* is the primary integration point between the SDK and a plugin's core logic.
It defines how particular devices get read from and written to. All plugins need to implement
device handlers in order to interface with devices.

Device handlers are each named; those names are required to be unique for the plugin, as the
handler name is how it is referenced in [device configuration](../configuration/device.md#handler).
Plugins should document the handlers that they implement so plugin users know which handlers
are available to them.

## Capabilities

A device handler can specify a number of functions which determine its capabilities when
interfacing with devices:

- **Read**: Defines single-device read behavior. 
- **Bulk Read**: Defines group read behavior for all devices which use the handler.
- **Write**: Defines single-device write behavior.
- **Listen**: *(Deprecated in v2.0.3)* Defines push-based read behavior, where the plugin listens for
    the pushed readings. For an updated approach to implementing "listener" capabilities, see the
    [Subscribing to data streams](./subscribing_to_data.md) page.

For handlers which define a write function, `Actions` may also be specified on the handler -- this 
is a list of the write actions which the handler supports. It is surfaced upstream to the user as
device metadata.

!!! note
    If both a *read* and *bulk read* handler are defined, the bulk read capabilities will be
    ignored and the handler will only use the single-read function. If bulk read is desired,
    ensure no single-read function is defined.

The presence/absence of functions on a device handler determine a its capabilities. That is
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
	Read: func(device *sdk.Device) ([]*output.Reading, error) {
		now := time.Now().UTC().Format(time.RFC3339)
		
		return []*output.Reading{
			Time.MakeReading(now),
		}, nil
	},
}
```

!!! note
    For the definition of the `Time` output type, see the [Outputs example](reading_outputs.md#example).

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

## Documenting Device Handlers

It is important for a plugin to document the handlers that they implement so plugin users
know what is available to them when configuring devices for the plugin. There is no set
way that handlers should be defined, but an example of how they could be defined is provided
below for reference (taken from the [Synse emulator plugin](https://github.com/vapor-ware/synse-emulator-plugin)).

```markdown
### Device Handlers

Device Handlers are referenced by name.

| Name        | Description                                 | Outputs                   | Read  | Write | Bulk Read | Listen |
| ----------- | ------------------------------------------- | ------------------------- | :---: | :---: | :-------: | :----: |
| airflow     | A handler for emulated airflow devices.     | `airflow`                 | ✓     | ✓     | ✗         | ✗      |
| energy      | A handler for emulated energy devices.      | `kilowatt-hour`           | ✓     | ✓     | ✗         | ✗      |
| fan         | A handler for emulated fan devices.         | `direction`, `rpm`        | ✓     | ✓     | ✗         | ✗      |
| humidity    | A handler for emulated humidity devices.    | `humidity`, `temperature` | ✓     | ✓     | ✗         | ✗      |
| led         | A handler for emulated LED devices.         | `color`, `state`          | ✓     | ✓     | ✗         | ✗      |
| lock        | A handler for emulated lock devices.        | `status`                  | ✓     | ✓     | ✗         | ✗      |
| power       | A handler for emulated power devices.       | `watt`                    | ✓     | ✓     | ✗         | ✗      |
| pressure    | A handler for emulated pressure devices.    | `pascal`                  | ✓     | ✓     | ✗         | ✗      |
| temperature | A handler for emulated temperature devices. | `temperature`             | ✓     | ✓     | ✗         | ✗      |
| voltage     | A handler for emulated voltage devices.     | `voltage`                 | ✓     | ✓     | ✗         | ✗      |
``` 
