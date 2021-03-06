---
hero: Device Aliases
---

Plugin devices each have an [ID](device_ids.md) associated with them, which is generated by the
SDK deterministically. These IDs are computed hashes and are not a human-friendly means to identify
or reference a device manually.

To make this easier, the Synse SDK allows devices to have an *alias* associated with it. A device
alias is just a string which should be human readable and provides a meaningful way to reference
the device, as an alternative to the device ID. In order to ensure that a device alias only references
a single device, the aliases must also be unique. While there are some safeguards/checks built into the
SDK, it is the responsibility of the plugin configurer to ensure that there are no alias collisions.   

A device alias can be used in place of a device ID for all Synse operations. Device aliases are defined
in the [device configuration](../configuration/device.md#alias). There are two ways that
an alias can be specified: explicitly, or via template.

### Explict Alias

An explicit alias is just a string which is not processed any further. For example:

```yaml
version: 3
devices:
- type: example-device
  instances:
  - info: example device instance 1
    alias:
      name: device-1
``` 

This example configuration defines `device-1` as the device's explicit alias.

### Templated Alias

The device alias may also be defined with a [Go template](https://golang.org/pkg/text/template/) string.

```yaml
version: 3
devices:
- type: example-device
  instances:
  - info: example device instance 1
    context:
      partNumber: abc123
    alias:
      template: 'device-{{ .Device.Type }}-{{ ctx "partNumber" }}-1'
```

In the above example, the alias would render out to `"device-example-device-abc123-1"`.

An `AliasContext` provides the context for the template. From it, the device information and plugin information
can be referenced.

***Alias Context***

| Key  | Description |
| :--- | :---------- |
| `.Meta.Name` | The name of the plugin. |
| `.Meta.Maintainer` | The plugin maintainer. |
| `.Meta.Description` | The description of the plugin. |
| `.Meta.VCS` | The VCS string for the plugin. |
| `.Device.Type` | The type of the device. |
| `.Device.Info` | The device's configured human-readable info string. |
| `.Device.Handler` | The name of the device's [device handler](device_handlers.md). |
| `.Device.SortIndex` | The optional custom sort index for the device. |
| `.Device.WriteTimeout` | The duration string for the device write timeout. |
| `.Device.Output` | The name of the optionally configured device [output](reading_outputs.md). |

Additionally, the SDK provides some simple template functions:

| Function | Description | Example |
| :------- | :---------- | :------ |
| `env` | Get a value from the environment. | `{{ env "PLUGIN_HOSTNAME" }}` |
| `ctx` | Get a value from the device's configured `context`. | `{{ ctx "manufacturer" }}` |
