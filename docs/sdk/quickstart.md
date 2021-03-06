---
hero: Quickstart
---

## Getting

There are a number of open-sourced plugins built using the SDK which are listed on the
[plugins](../plugins.md) page. The plugin binary can be installed from its corresponding
GitHub release. Docker images are available for all plugins as well.

To get the SDK for plugin development, simply

```
go get github.com/vapor-ware/synse-sdk/sdk
```

## Configuring

A plugin built with the SDK can take two different types of configuration: 

1. [**Plugin Configuration**](configuration/plugin.md): The configuration for the plugin itself,
   defining how it should behave at runtime.
2. [**Device Configuration**](configuration/device.md): The configuration which tells the plugin
   about the devices that it interfaces with. 

For details on how to configure a plugin, see the pages linked above.

## Simple Example

An example of a simple plugin that showcases the basics of how to implement a plugin, see 
the [examples/simple_plugin](https://github.com/vapor-ware/synse-sdk/tree/master/examples/simple_plugin)
directory.

The [examples](https://github.com/vapor-ware/synse-sdk/tree/master/examples) directory contains other
basic example plugins, showcasing different features and different levels of plugin complexity. The
[emulator plugin](https://github.com/vapor-ware/synse-emulator-plugin) is another good
reference for plugin implementation and setup.
