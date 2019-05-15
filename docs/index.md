---
hero: Home
---

# Synse Platform

<p align="center"><img src="assets/img/logo.png" width="200px" /></p>

**Synse** is a simple, scalable platform to enable detailed monitoring and control of
data center equipment, or more generally *physical and virtual devices*. The platform
is designed for remote lights-out management and automation.

There are two main components to the Synse platform, the [server](server/intro.md) and
the [plugins](plugins.md). 

## Components

### Plugins

Plugins interface directly with devices and expose the device to the rest of the platform.
They enable data collection from the devices, such as collecting temperature, humidity,
power consumption, or LED status. In addition, plugins allow data to be written to the
devices which support it. This can range from simply blinking an LED indicator, to remotely
managing an HVAC system.

### Server

The server component provides a simple HTTP and WebSocket API which makes it easy to interact
with the devices the plugins expose. It tracks the devices available to the system and routes
incoming requests to the appropriate plugin for a specified device. The simple unified API
which the server provides means that you can interface with a temperature sensor over RS-485,
an LED over I²C, and server power over IPMI in the same way via HTTP.

## The Synse Ecosystem

While the server and plugins are the two primary components, there are a number of projects
which make up the *Synse ecosystem*:

* [vapor-ware/synse-server](https://github.com/vapor-ware/synse-server): The API server providing
    a uniform HTTP/WebSocket API to interact with physical and virtual devices via plugin backends.
* [vapor-ware/synse-sdk](https://github.com/vapor-ware/synse-sdk): The official SDK (written in
    Go) for Synse plugin development.
* [vapor-ware/synse-server-grpc](https://github.com/vapor-ware/synse-server-grpc): The gRPC API
    for the bi-directional communication between Synse Server and the Synse plugins.
* [vapor-ware/synse-cli](https://github.com/vapor-ware/synse-cli): A command-line interface to
    interact with the server (via the HTTP API) and plugins (via the gRPC API) directly from
    your console.
* [vapor-ware/synse-client-python](https://github.com/vapor-ware/synse-client-python): A Python
    client for the Synse Server API.
* [vapor-ware/synse-client-go](https://github.com/vapor-ware/synse-client-go): A Golang client
    for the Synse Server API.
