---
hero: Device IDs
---

Since devices are referenced by IDs, it is important that those IDs serve as the sole identity
for the device and that it will not change, even if the plugin is restarted. To achieve this,
the SDK encodes a notion of *"deterministic unique device IDs"*, where the primary assumption is that
in order for a plugin to know how to communicate with a single device, it needs to know something
unique about that device, whether it be a register, file, address, or port. Using this unique bit
of configuration, along with some other data points, the SDK can generate a deterministic hash
to represent the device.

There may be multiple instances of a plugin running all with similar configuration. To combat the
device ID collision this would cause upstream in Synse Server (which aggregates all devices from
all registered plugins), the device ID uses the [plugin ID](plugin_metadata.md#plugin-id) as its base,
so all devices are unique to their plugin.

By default, the plugin uses all the fields in a device's `data` configuration. To override this
behavior, a plugin can specify its own custom device identifier. An example of this can be found
in the SDK's [example multi-device plugin](https://github.com/vapor-ware/synse-sdk/tree/master/examples/multi_device_plugin).
