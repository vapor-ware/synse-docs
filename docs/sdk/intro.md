---
hero: Introduction 
---

# Synse SDK

> *[github.com/vapor-ware/synse-sdk](https://github.com/vapor-ware/synse-sdk)*

The Synse SDK is the official SDK (written in Golang) for writing Synse plugins. Synse plugins
expose devices to the Synse platform and manage read/write access to those devices. The SDK
handles much of the functionality needed for plugins, including:

- configuration parsing
- executing device reads
- executing device writes
- caching reading data
- transaction generation and tracking
- device info caching
- Synse gRPC API support
- and more

By implementing the majority of the plugin mechanics, a plugin author can focus on the protocol
or device specific code for the plugin. The [Synse CLI](../cli/intro.md) can also be useful for
development and debugging, as it allows you to query the plugin gRPC API directly.

![](../assets/img/plugin-arch.svg)

See the [Plugins](../plugins.md) page for a list of some actively maintained Synse plugins.
You can also search for the [`synse-plugin`](https://github.com/topics/synse-plugin) tag on GitHub.
