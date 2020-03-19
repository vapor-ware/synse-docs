---
hero: Reading Outputs
---

*Outputs* provide definitions of the metadata associated with device readings. They provide information about the
type of reading, what the precision of the value, and the unit of the reading.

All readings must be associated with an output -- without the context that an Output provides,
the reading is effectively just an arbitrary value. Outputs may be set in a [Device
Handler](device_handlers.md) (if the handler is device-specific), or in the [device configuration](../configuration/device.md#output),
if the handler is general-purpose.

A number of built-in Outputs are provided by the SDK are a good starting point for plugin, but will
not be enough for all devices/plugins. Custom Outputs may be registered with the plugin (see below for
an example). It is important to note that since Outputs are referenced by name, their names must be
unique. If an Output is defined which conflicts with an existing one (whether custom or built-in),
the SDK will return an error.

### Example

Below is an example of a simple output type definition for a custom "time" reading, as well as how
it is registered to the plugin. See the [Device Handlers](device_handlers.md) section for an example
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

## Built-ins

The Synse plugin SDK provides a number of built-in reading output types with sane values
which can be used by any plugin. This "core" set of outputs provides a good foundation
to describe what data plugins can support, but individual plugin implementations are free
to define their own outputs, as shown above.

Below is a table describing the outputs built-in to the SDK. If you are interested in
adding more built-in outputs, feel free to open a pull request. In the table below,
a value of `-` indicates no value.

| Name | Type | Precision | Unit |
| :--- | :--- | :-------: | :--- |
| color | `color` | - | - |
| direction | `direction` | - | - |
| electric-current | `current` | 3 | Ampere (A) |
| electric-resistance | `resistance` | 2 | Ohm (Ω) |
| frequency | `frequency` | 2 | Hertz (Hz) |
| humidity | `humidity` | 2 | Percent humidity (%) |
| kilojoule | `energy` | 3 | Kilojoule (kJ) |
| kilowatt-hour | `energy` | 3 | Kilowatt-hour (kWh) |
| microseconds | `duration` | 6 | Microseconds (µs) |
| nanoseconds | `duration` | 6 | Nanoseconds (ns) |
| pascal | `pressure` | 3 | Pascal (Pa) |
| percentage | `percentage` | - | Percent (%) |
| psi | `pressure` | 3 | Pounds per square inch (PSI) |
| rpm | `frequency` | 2 | Revolutions per minute (RPM) |
| seconds | `duration` | 3 | Seconds (s) |
| state | `state` | - |  - |
| status | `status` | - | - |
| switch | `state` | 1 | -  |
| temperature | `temperature` | 2 | Celsius (C) |
| velocity | `velocity` | 3 | Meters per second (m/s) |
| voltage | `voltage` | 5 | Volt (V) |
| volt-second | `flux` | 3 | Volt second (Vs) |
| watt | `power` | 3 | Watt (W) |
| weber | `flux` | 3 | Weber (Wb) |

## Documenting Outputs

Whether a plugin uses built-in outputs, custom outputs, or a mix of both, it is helpful
to plugin users to document which outputs that plugin uses. There is no set
way that outputs should be defined, but an example of how they could be defined is provided
below for reference (taken from the [Synse emulator plugin](https://github.com/vapor-ware/synse-emulator-plugin)).

```markdown
### Outputs

Outputs are referenced by name. A single device may have more than one instance
of an output type. A value of `-` in the table below indicates that there is no value
set for that field. The *custom* section describes outputs which this plugin defines
while the *built-in* section describes outputs this plugin uses which are built-in to
the SDK.

**Custom**

| Name    | Description                                      | Unit  | Type    | Precision |
| ------- | ------------------------------------------------ | :---: | ------- | :-------: |
| airflow | A measure of airflow, in millimeters per second. | mm/s  | `speed` | 3         |

**Built-in**

| Name          | Description                                        | Unit  | Type          | Precision |
| ------------- | -------------------------------------------------- | :---: | ------------- | :-------: |
| color         | A color, represented as an RGB string.             | -     | `color`       | -         |
| direction     | A measure of directionality.                       | -     | `direction`   | -         |
| humidity      | A measure of humidity, as a percentage.            | %     | `humidity`    | 2         |
| kilowatt-hour | A measure of energy, in kilowatt-hours.            | kWh   | `energy`      | 3         |
| pascal        | A measure of pressure, in Pascals.                 | Pa    | `pressure`    | 3         |
| rpm           | A measure of frequency, in revolutions per minute. | RPM   | `frequency`   | 2         |
| state         | A generic description of state.                    | -     | `state`       | -         |
| status        | A generic description of status.                   | -     | `status`      | -         |
| temperature   | A measure of temperature, in degrees Celsius.      | C     | `temperature` | 2         |
| voltage       | A measure of voltage, in Volts.                    | V     | `voltage`     | 5         |
| watt          | A measure of power, in Watts.                      | W     | `power`       | 3         |
```
