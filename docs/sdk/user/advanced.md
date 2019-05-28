---
hero: Advanced Usage 
---

This page describes some of the more advanced features and concepts of the Synse SDK.

## Applying Functions to Device Readings

There may be instances, particularly when dealing with a general-purpose type plugin, you may
want to perform some additional actions a device's raw reading, such as converting a value to
a particular unit. In such cases, the [device's configuration](configuration.device.md#apply)
may specify the functions to apply. 

The SDK provides some built-in functions which can be used, available in the `github.com/vapor-ware/synse-sdk/sdk/funcs`
package. As an example, the function "FtoC" converts a value from degrees Fahrenheit to degrees Celsius.

The SDK allows you to register custom functions which are made available to devices managed
by the plugin. See below for an example. It is important to note that functions are referenced
by their name, so all function names must be unique. If a function name conflicts with an existing
name (whether custom or built-in), the SDK will raise an error.

### Example

Below is an example of a simple custom function, as well as how to register it with a plugin
and how to configure a device to use the custom function.

*fns.go*

```go
package main

import (
	"fmt"
	
	"github.com/vapor-ware/synse-sdk/sdk/funcs"
)

var CustomFunction = funcs.Func{
	Name: "custom-function",
	Fn: func(value interface{}) (interface{}, error) {
		v, ok := value.(int)
		if !ok {
			return nil, fmt.Errorf("failed to cast value")
		}

		return v * 2, nil
	},
}
```

*main.go*

```go
package main

import (
	"log"

	"github.com/vapor-ware/synse-sdk/sdk"
	"github.com/vapor-ware/synse-sdk/sdk/funcs"
)

func main() {
    // Create a new plugin instance
    plugin, err := sdk.NewPlugin()
	if err != nil {
		log.Fatal(err)
	}
	
	// Register custom functions
	err = funcs.Register(
		&CustomFunction,
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

*device-config.yaml*

```yaml
version: 3
devices:
- type: example-device
  instances:
  - info: Sample Device 1
    data:
      foo: bar
    apply:
    - custom-function
```

## Command Line Arguments

The SDK has some built-in command line arguments for plugins. These can be seen by running
the plugin with the `--help` flag.

```
$ ./plugin --help
Usage of ./plugin:
  -debug
    	enable debug logging
  -dry-run
    	run only the setup actions to verify functionality and configuration
  -version
    	print the plugin version information
```

A plugin can add its own command line args if it needs to as well. This can be done simply
by defining the flags that the plugin needs, e.g.

```go
import (
    "flag"
)

var customFlag bool

func init() {
    flag.BoolVar(&customFlag, "custom", false, "some custom functionality")
}
```

This flag will be parsed on plugin `Run()`, so it can only be used after the plugin
has been run.

## Pre Run Actions

*Pre-run actions* are functions which the plugin will execute before starting its
main run logic. These actions can be used for plugin-wide setup, should a plugin require
it. There is no limit to what a pre-run action could do, but some possibilities include
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
used for plugin-wide shut down or cleanup. There is no limit to what a post-run action can do,
but some examples include cleaning up the filesystem or gracefully terminating a connection.

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

* type

The device setup actions will apply to the devices whose field values match the filter values.
Multiple device setup actions can target the same device(s). In this case, they are applied
to the device in the order by which they were registered with the plugin.

### Example

Below is a simple example of defining a device setup action and its filter, and registering
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

## Plugin Options

The SDK provides many default values and behaviors for the plugin. A plugin can override the
values it needs to by passing *plugin options* to the plugin constructor. An example of this
would be changing the [configuration policy](configuration.plugin.md#config-policies) of the plugin.

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

## Dynamic Registration

Typically, devices are registered with a plugin through configuration files available to
the plugin at startup. This will not work for plugins which do not necessarily know what
devices are available immediately. A good example of this is IPMI, where the plugin would
know the address to a BMC, but would not necessarily know which devices that BMC supports.

In such cases, *dynamic registration* can be used. Dynamic registration is when devices are
either registered directly at runtime, without the typical device config YAML(s). There are
two types of dynamic registration:

- registration of device config(s) *(e.g. it creates configurations for a device)*
- registration of device(s) *(e.g. it creates the device directly)*

By default, a plugin does not do any dynamic registration. To enable it, the plugin
configuration will need to have the [dynamic registration](configuration.plugin.md#configuration-options)
option set with the necessary configuration. The values that this config option can hold
are up to the plugin to define, as it will use them when executing its custom dynamic
registration handler (registered via [plugin option](#plugin-options)).

For the IPMI example, this could mean passing in the IP addresses (and any authentication options)
for each BMC into the plugin config and registering a handler function which uses that
information to connect to each BMC and query it for its devices, using those results to
generate SDK devices.

A simple example of this can be found in the [dynamic registration example plugin](https://github.com/vapor-ware/synse-sdk/tree/master/examples/dynamic_registration).

## Plugin Health

The SDK provides a notion of health for a plugin via *health checks*. The overall health
status of the plugin is exposed by a health file, making it easy to integrate into
container management health checks, e.g. for docker-compose or Kubernetes.

By default, the health file is `/etc/synse/plugin/healthy`. Plugin health status (healthy,
unhealthy) is designated by the presence/absence of this file, where is presence indicates
that the plugin is health, and the absence that it is unhealthy. With this, simply running
`cat /etc/synse/plugin/healthy` is enough to know whether or not a plugin is healthy.

The overall plugin health is determined by a number of health checks. The SDK provides
some built-in health checks which are enabled by default (and can be disabled in the
[plugin configuration](configuration.plugin.md#configuration-options)). These health
checks periodically check whether the read/write buffers are full or close to full.

Custom health checks can be registered with the plugin. This allows a plugin to use
any metric it deems fit as a measure of health. Currently, the only type of health
check which is supported is the *periodic* check, which runs periodically on a timer.

## Example

Below is a simple example showcasing how a custom health check can be registered
with a plugin instance.

*main.go*

```go
package main

import (
	"log"

	"github.com/vapor-ware/synse-sdk/sdk"
	"github.com/vapor-ware/synse-sdk/sdk/health"
)

func customHealthCheck() error {
	// perform some check and return an error if the check fails
	return nil
}

func main() {
    // Create a new plugin instance
    plugin, err := sdk.NewPlugin(
		sdk.PluginConfigRequired(),
	)
	if err != nil {
		log.Fatal(err)
	}
	
	customCheck := health.NewPeriodicHealthCheck("example health check", 3*time.Second, customHealthCheck)
	if err := plugin.RegisterHealthChecks(customCheck); err != nil {
		log.Fatal(err)
	}
	
	// Run the plugin
	if err := plugin.Run(); err != nil {
		log.Fatal(err)
	}
}
```  

For a more complete example, see the [health check example plugin](https://github.com/vapor-ware/synse-sdk/tree/master/examples/health_check).

## C Backend

Plugins can be written with C backends. In general, this means that the read/write
handlers or some related logic is written in C. This feature is not specific to the
SDK, but is a feature of Go itself.

For more information on this, see the [CGo Documentation](https://golang.org/cmd/cgo/)
and the [example C plugin](https://github.com/vapor-ware/synse-sdk/tree/master/examples/c_plugin).


## Application Metrics

A plugin can be configured to expose application metrics via its [plugin configuration](configuration.plugin.md#configuration-options).
When enabled, [Prometheus](https://prometheus.io/) metrics are exposed on port `2112` for
the application at the `/metrics` endpoint.