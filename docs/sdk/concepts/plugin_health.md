---
hero: Plugin Health
---

The SDK provides a notion of health for a plugin via *health checks*. The overall health
status of the plugin is exposed by a health file, making it easy to integrate into
container management health checks, e.g. for Docker Compose or Kubernetes.

By default, the health file is `/etc/synse/plugin/healthy`. Plugin health status (healthy,
unhealthy) is designated by the presence/absence of this file, where is presence indicates
that the plugin is health, and the absence that it is unhealthy. With this, simply running
`cat /etc/synse/plugin/healthy` is enough to know whether or not a plugin is healthy.

The overall plugin health is determined by a number of health checks. The SDK provides
some built-in health checks which are enabled by default (and can be disabled in the
[plugin configuration](../configuration/plugin.md#configuration-options)). These health
checks periodically check whether the read/write buffers are full or close to full.

Custom health checks may be registered with the plugin. This allows a plugin to use
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
