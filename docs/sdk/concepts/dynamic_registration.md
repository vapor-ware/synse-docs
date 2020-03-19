---
hero: Dynamic Device Registration
---

Typically, devices are registered with a plugin through [configuration files](../configuration/device.md) available to
the plugin at startup. This will not work for plugins which do not necessarily know what
devices are available immediately. A good example of this is IPMI -- the plugin would
know the address of a BMC, but would not necessarily know which devices that BMC supports.

In such cases, *dynamic registration* can be used. Dynamic registration is when devices are
registered directly at runtime, without the typical device config YAML(s). There are
two types of dynamic registration:

- registration of device config(s) *(e.g. it creates configurations for a device)*
- registration of device(s) *(e.g. it creates the device directly)*

By default, a plugin does not do any dynamic registration. To enable it, the plugin
configuration will need to have the [dynamic registration](../configuration/plugin.md#configuration-options)
option set with the necessary configuration. The values that this config option can hold
are up to the plugin to define, as it will use them when executing its custom dynamic
registration handler (registered via [plugin option](plugin_options.md)).

For the IPMI example, this could mean passing in the IP addresses (and any authentication options)
for each BMC into the plugin config and registering a handler function which uses that
information to connect to each BMC and query it for its devices, using those results to
generate Synse devices.

A simple example of this can be found in the [dynamic registration example plugin](https://github.com/vapor-ware/synse-sdk/tree/master/examples/dynamic_registration).
