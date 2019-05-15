---
hero: Introduction 
---

The Synse Plugin SDK is the official SDK used to write plugins for the Synse platform.
Synse Server provides an HTTP API for monitoring
and controlling physical and virtual devices, but it is the backing plugins that
provide the support (telemetry and control) for all of the devices that Synse Server
exposes.

The SDK handles most of the common functionality needed for plugins, such as configuration
parsing, background read/write, transaction generation and tracking, meta-info caching, and more.
This means the plugin author should only need to worry about the plugin-specific device support.

.. image:: _static/plugin-arch.svg