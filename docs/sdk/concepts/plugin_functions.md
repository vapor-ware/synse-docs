---
hero: Plugin Functions
---

## Applying Functions to Device Readings

There may be instances, particularly when dealing with a general-purpose type plugin, you may
want to perform some additional actions on a device's raw reading, such as converting a value to
a particular unit. In such cases, the [device's configuration](../configuration/device.md#apply)
may specify the functions to apply. 

The SDK provides some built-in functions which can be used, available in the `github.com/vapor-ware/synse-sdk/sdk/funcs`
package. As an example, the function "FtoC" converts a value from degrees Fahrenheit to degrees Celsius.

The SDK allows you to register custom functions which are made available to devices managed
by the plugin. See below for an example. It is important to note that functions are referenced
by their name, so all function names must be unique. If a function name conflicts with an existing
name (whether custom or built-in), the SDK will return an error.

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
