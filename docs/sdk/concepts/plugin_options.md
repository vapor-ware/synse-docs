---
hero: Plugin Options
---

The SDK provides many default values and behaviors for the plugin. A plugin can override the
values it needs to by passing *plugin options* to the plugin constructor. An example of this
would be changing the [configuration policy](../configuration/plugin.md#config-policies) of the plugin.

Plugin options are passed to the `#!go sdk.NewPlugin` constructor. 

*main.go*

```go
package main

import (
	"log"

	"github.com/vapor-ware/synse-sdk/sdk"
)

func main() {
    // Create a new plugin instance
    plugin, err := sdk.NewPlugin(
		sdk.PluginConfigRequired(),
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

There are a number of built-in plugin options which can be used:

| Function | Description |
| :------- | :---------- |
| `CustomDeviceIdentifier` | Set a custom function for creating a deterministic ID for plugin devices. |
| `CustomDynamicDeviceRegistration` | Set a custom function for dynamically registering plugin devices. |
| `CustomDynamicDeviceConfigRegistration` | Set a custom function for dynamically registering device configurations with the plugin. |
| `CustomDeviceDataValidator` | Set a custom function that can be used to validate the `Data` field of a device configuration. |
| `PluginConfigRequired` | Set the plugin config policy to "required". |
| `DeviceConfigOptional` | Set the device config policy to "optional". |
| `DynamicConfigRequired` | Set the dynamic config policy to "required". |

For a more complete example, see the [device actions example plugin](https://github.com/vapor-ware/synse-sdk/tree/master/examples/device_actions).
