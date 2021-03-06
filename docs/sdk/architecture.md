---
hero: Architecture 
---

This page describes the SDK architecture at a high level, providing insight into how
a plugin operates. While not required to develop your own plugin, it can be useful
in understanding how to design your plugin, basic assumptions, and where some pitfalls
may lie.

## Overview

The SDK provides a means to make it easy to develop new plugins, abstracting away much
of the internal state handling, communication layers, and common functionality from the
plugin author. Ideally, this means that a plugin author spends more time on the
plugin-specific logic and less time integrating it into the Synse platform.

At a high level, there are two levels of communication in a plugin:

- communication with [Synse Server](../server/intro.md)
- communication with the devices which the plugin interfaces with

### Plugin Interaction with Synse Server

![](../assets/img/arch.svg)

When Synse Server receives an API request, e.g. a [read](../server/api.v3.md#read) request,
Synse Server will determine which plugin manages the targeted device(s) and issue a
corresponding request to those plugins via the [Synse gRPC API](https://github.com/vapor-ware/synse-server-grpc).

The plugin runs a gRPC server and upon receiving the request, will dispatch it appropriately.
At a high level, there are two types of actions that the plugin will handle:

- retrieve 'static' information
- device read/write

When retrieving static information, it will simply look up the pertinent information
from the appropriate SDK component and return it. This includes things like the plugin
metadata, configured devices, plugin version, etc.

The read and write behavior is more complicated and is described in more detail in the
next section.

The gRPC layer between Synse Server and a plugin can use either TCP or Unix socket
for the transport protocol. It is generally recommended to use TCP, as it is easier
to set up and use.

### Plugin Interaction with Devices

When a plugin starts up, it will load its device configuration and will begin reading from
those devices continually (on a configurable interval). For every read, it will update internal
state, tracking the "latest current reading". When a read request comes in from Synse Server via
the gRPC API, the device is not read directly; instead, the "latest current reading" state is
returned. With a fast enough read interval, the discrepancy between the latest cached reading and
the actual current reading should be negligible for most applications.

This design allows read and write operations to happen constantly and consistently in the background
without having incoming requests dictate the resolution of device readings.

Similarly, when a write request comes in from Synse Server, it is not processed immediately.
It is put onto a "write queue" and is processed in the background on an interval. As such,
writes to a plugin are asynchronous and all have an associated transaction ID.

![](../assets/img/plugin-arch.svg)

The frequency of reads and writes, along with other read/write behavior, is configurable
from the [plugin configuration](configuration/plugin.md#configuration-options).

## Components

The SDK has a number of internal components, each with their own domain of responsibility. Below
is a table which describes what each of the internal components does.

| Component | Description |
| :-------- | :---------- |
| device manager | Loads, maintains, and manages the device instance metadata for the plugin. This is used for device routing and lookups, device info requests, and serves as the source of truth for the devices the plugin should know about. |
| health manager | Loads and runs [health checks](concepts/plugin_health.md) which it aggregates and exposes to provide an overall plugin health status. |
| scheduler | Runs the read/write logic, continuously collecting readings from devices and executing writes off of the write queue. |
| server | The gRPC server which receives requests from Synse Server and generates appropriate responses from the data provided by other components. |
| state manager | Maintains all the internal device state, such as the current readings, windowed reading cache, and write transactions. |

### Scheduler

The scheduler has two run modes:

- **serial**: All reads happen serially, all writes happen serially, and the read loop
  and write loop run serially, alternating between the two.
- **parallel**: All reads happen in parallel, all writes happen in parallel, and the read
  and write loop run in parallel.
  
By default, the scheduler will run in parallel mode, but not all plugins are suited for
this. It is important to determine which mode a plugin will need to run in. For example,
a serial protocol, such as I²C, will fail when run in parallel mode because of collisions
on the serial bus. Alternatively, running in serial mode when a plugin could run in parallel,
e.g. for some HTTP-based plugin, would be detrimental to performance.
