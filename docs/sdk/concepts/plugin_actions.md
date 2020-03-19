---
hero: Plugin Actions
---

## Pre Run Actions

*Pre-run actions* are functions which the plugin will execute before starting its
main run logic. These actions can be used for plugin-wide setup, should a plugin require
it. There is no limit to what a pre-run action could do; some possibilities include
performing authentication, verifying a backend exists, or additional validation of
configuration(s).

Actions must be specified via the SDK's `PluginAction` type, which requires a name and
the function to run. The names for actions are used for identifying the action. While
there is no strict check for duplicate names, it is strongly recommended to provide
unique names to different plugin actions so they are clearly discernible in the logs.

### Example

Below is a simple example of a pre-run action being registered with a plugin instance.

*main.go*

```go
package main

import (
	"log"

	"github.com/vapor-ware/synse-sdk/sdk"
)

func action1(p *sdk.Plugin) error {
	// Perform the pre-run action here
	log.Debug("running action-1")
	
	return nil
}

func main() {
    // Create a new plugin instance
    plugin, err := sdk.NewPlugin()
	if err != nil {
		log.Fatal(err)
	}
	
	// Register pre-run actions
	plugin.RegisterPreRunActions(
		&sdk.PluginAction{
			Name:   "action-1",
			Action: action1,
		},
	)
	
	// Run the plugin
	if err := plugin.Run(); err != nil {
		log.Fatal(err)
	}
}
``` 

For a more complete example, see the [device actions example plugin](https://github.com/vapor-ware/synse-sdk/tree/master/examples/device_actions).

## Post Run Actions

*Post-run actions* are functions which the plugin will execute after it is shut down gracefully.
A plugin gracefully terminates when it catches a SIGTERM or SIGINT signal. These actions can be
used for plugin-wide shut down or cleanup. There is no limit to what a post-run action can do;
some examples include cleaning up the filesystem or gracefully terminating a connection.

Actions must be specified via the SDK's `PluginAction` type, which requires a name and
the function to run. The names for actions are used for identifying the action. While
there is no strict check for duplicate names, it is strongly recommended to provide
unique names to different plugin actions so they are clearly discernible in the logs.

### Example

Below is a simple example of a post-run action being registered with a plugin instance.

*main.go*

```go
package main

import (
	"log"

	"github.com/vapor-ware/synse-sdk/sdk"
)

func action1(p *sdk.Plugin) error {
	// Perform the post-run action here
	log.Debug("running action-1")
	
	return nil
}

func main() {
    // Create a new plugin instance
    plugin, err := sdk.NewPlugin()
	if err != nil {
		log.Fatal(err)
	}
	
	// Register post-run actions
	plugin.RegisterPostRunActions(
		&sdk.PluginAction{
			Name:   "action-1",
			Action: action1,
		},
	)
	
	// Run the plugin
	if err := plugin.Run(); err != nil {
		log.Fatal(err)
	}
}
``` 

For a more complete example, see the [device actions example plugin](https://github.com/vapor-ware/synse-sdk/tree/master/examples/device_actions).

## Device Setup Actions

In some cases, setup actions may need to be run at a per-device level, in which case,
the plugin-wide pre-run actions are too high level and not suitable. The SDK allows
*device setup actions* to be registered with the plugin for such cases.

These actions are performed after the pre-run actions, but before the plugin's main
run logic. These actions are useful when only certain types of devices may need additional
setup, whether it be some form of authentication, bit-setting, connecting, etc.

Device setup actions must be specified via the SDK's `DeviceAction` type, which requires a name,
a filter to match which devices it applies to, and the function to run. The names for actions are
used for identifying the action. While there is no strict check for duplicate names, it is strongly
recommended to provide unique names to different plugin actions so they are clearly discernible in
the logs.

The device filter is required and is in the form of a `#!go map[string]string`. The keys correspond
to fields of a Device instance. Currently, the supported filter keys are:

* "type"

The device setup actions will apply to the devices whose field values match the filter values.
Multiple device setup actions can target the same device(s). Note that they are applied
to the device in the order by which they were registered with the plugin.

### Example

Below is a simple example of defining a device setup action and registering
it with a plugin instance.

*main.go*

```go
package main

import (
	"log"

	"github.com/vapor-ware/synse-sdk/sdk"
)

func action1(p *sdk.Plugin, d *sdk.Device) error {
	// Perform the device setup action here
	log.Debug("running action-1")
	
	return nil
}

func main() {
    // Create a new plugin instance
    plugin, err := sdk.NewPlugin()
	if err != nil {
		log.Fatal(err)
	}
	
	// Register device setup actions
	err = plugin.RegisterDeviceSetupActions(
		&sdk.DeviceAction{
			Name:   "action-1",
			Filter: map[string]string{"type": {"temperature"}},
			Action: action1,
		},
	)
	
	// Run the plugin
	if err := plugin.Run(); err != nil {
		log.Fatal(err)
	}
}
``` 

For a more complete example, see the [device actions example plugin](https://github.com/vapor-ware/synse-sdk/tree/master/examples/device_actions).
