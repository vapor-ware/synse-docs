---
hero: Plugin Metadata
---

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

Synse requires plugins to have a unique ID. At a high level, this is to ensure the uniqueness
of [device ids](device_ids.md), especially when multiple instances of a plugin may
be running with similar configurations against the same Synse Server instance. Since Synse Server
uses the plugin ID to route requests appropriately, they must be unique. 

A plugin ID can use multiple different sources as components to generate a unique deterministic
ID, but ultimately it is up to the plugin configurer to ensure that the sources are configured
correctly to prevent ID collisions. How plugin ID components are configured depends on how
the plugin is deployed. See the [plugin configuration](../configuration/plugin.md#configuration-options)
for details on the config options.  