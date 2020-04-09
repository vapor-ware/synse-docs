---
hero: Introduction
---

# Synse Server

> *[github.com/vapor-ware/synse-server](https://github.com/vapor-ware/synse-server)*

Synse Server provides a simple HTTP and WebSocket API to monitor and control physical and virtual devices.
It exposes the devices managed by its registered plugins through this uniform API, making
it easy to read from and write to devices across any number of backends through a simple
curl-able interface.

## Features

- Simple ``curl``-able JSON API
- Plugin architecture allows support for any kind of device
- Read from devices
- Write to devices
- Enumerate all devices managed by plugins
- Get meta information on all devices
- Asynchronous request processing
- Dockerized for scalability and deployability
- Securable via TLS/SSL
- *and more*

## Architecture

Synse Server is designed as a containerized micro-service to provide a uniform interface
to monitor and control devices registered to plugins. It does not directly interface with
devices -- that job is left to the plugins which Synse Server interfaces with over an
internal gRPC API.

Synse Server can be thought of as the "front-end" interface for devices. When a plugin is
registered with Synse Server, plugin metadata is collected along with a full accounting of
registered devices. This allows Synse Server to have a complete view of all devices across
all plugins and to build a routing table to seamlessly dispatch incoming requests to the
appropriate plugin.

Considering that, in most cases, devices are not liable to change frequently (e.g. once they
are plugged in, one can assume that they will stay plugged in for a while), Synse Server
also does basic caching of plugin and device data.

![Architecture](../assets/img/arch.svg)

The general flow through Synse Server for a device read, for example, is:

- get an incoming HTTP request
- lookup the device's managing plugin
- dispatch a gRPC read request to the plugin for that device
- await a response from the plugin
- take the data returned from the plugin and format it into the JSON response scheme
- return the data to the caller

Overall, Synse Server is an integral, though fairly simple, component of the Synse Platform.