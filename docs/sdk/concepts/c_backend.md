---
hero: Using a C Backend
---

Plugins may be written with C backends. In general, this means that the read/write
handlers or some related logic is written in C. This feature is not specific to the
SDK, but is a feature of Go itself.

For more information on this, see the [CGo Documentation](https://golang.org/cmd/cgo/)
and the [example C plugin](https://github.com/vapor-ware/synse-sdk/tree/master/examples/c_plugin).
