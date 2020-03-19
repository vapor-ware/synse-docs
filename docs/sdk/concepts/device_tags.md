---
hero: Device Tags
---

Tags are ways to identify groups of devices, making it easier to perform operations on multiple devices
at once, such as getting readings.

> For more detailed information on device tags and their structure, see the [Tags](../../server/user/tags.md)
> page in the Synse Server documentation.

When specifying tags in a device configuration, the tag may contain a Go template string to allow
templated values to be passed in at runtime if you don't know them at config time. A good example
of this is when running a plugin on Kubernetes as a [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)
and the plugin is specific to the node it is running on (e.g. the server has sensors on it). In
such a case, you may want to be able to filter by rack location, so you can specify a template
to capture that info:

```yaml
tags:
- rack/id:{{ env "NODE_NAME" }}
```

Currently, tag templates only support the `env` function, which allows you to get a value from
environment. Note that these templates are not parsed on config load. Instead, they are parsed
a little later on device build. This allows the SDK to first unify multiple potential sources of
configuration (e.g. from file, environment, or command line). 

The SDK auto-generates some tags, such an an ID tag and a Type tag. Additional tags can be
specified for a device in its [configuration](../configuration/device.md#configuration-options).
A simple example of configuring device tags is below:

```yaml
version: 3
devices:
- type: example
  tags:
  - tag1
  - vapor/example:tag
  instances:
  - info: an example device instance
    tags:
    - vapor/another:tag
```
