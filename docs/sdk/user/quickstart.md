---
hero: Quickstart
---

## Getting

## Configuring

A plugin built with the SDK can take two different types of configuration: 

1. [**Plugin Configuration**](configuration.plugin.md): This is the configuration for the plugin itself,
   defining how it should behave at runtime.
2. [**Device Configuration**](configuration.device.md): This is the configuration which tells the plugin
   about the devices that it manages. 

View the configuration pages, linked above, for more details.

## Simple Example

An example of a simple plugin that showcases the basics of how to implement a plugin, see 
the [examples/simple_plugin](https://github.com/vapor-ware/synse-sdk/tree/master/examples/simple_plugin)
directory.

The [examples](https://github.com/vapor-ware/synse-sdk/tree/master/examples) contains other
examples, showcasing different features and different levels of plugin complexity. The
[emulator plugin](https://github.com/vapor-ware/synse-emulator-plugin) is another good
reference for plugin implementation and setup.