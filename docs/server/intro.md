---
hero: Introduction
---

# Synse Server

> *[github.com/vapor-ware/synse-server](https://github.com/vapor-ware/synse-server)*

Synse Server provides a simple HTTP API to monitor and control physical and virtual devices.
It exposes the devices managed by its registered plugins through a uniform API. This makes
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

Synse Server is a micro-service that provides an HTTP interface for interaction and control
of devices. Synse Server does not directly interface with the devices -- that job is left to
the plugins that Synse Server can interface with. Plugins implement a given protocol to talk
to a given collection of devices, whether that is a serial protocol for sensors, or an HTTP
protocol for some external REST API is up to the plugin implementation.

![Architecture](../assets/img/arch.svg)

Synse Server acts as the "front-end" interface for all the different protocols/devices.
It gives a uniform API to the user, routes commands to the proper device (e.g. to the plugin
that manages the referenced device), and does some aggregation, caching, and formatting of
the response data.

The general flow through Synse Server for a device read, for example, is:

- get an incoming HTTP request
- lookup the device's managing plugin
- dispatch a gRPC read request to the plugin for that device
- await a response from the plugin
- take the data returned from the plugin and format it into the JSON response scheme
- return the data to the caller
