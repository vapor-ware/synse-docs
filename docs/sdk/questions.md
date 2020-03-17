---
hero: Questions and Answers
---

This page lists some questions that have come up about the SDK and provides some answers to
those questions. If you have and questions that you think would be a good fit to add here,
open an issue or pull request.

------

## Why do plugin logs show that a "handler has no devices to read"?

An example of what this might look like:

```
time="2020-02-26T21:55:52.846Z" level=debug msg="[scheduler] handler has no devices to read" delay=0s handler=max11608.temperature mode=serial
``` 

This log message originates from the SDK when performing bulk reads for a
[device handler](concepts.md#device-handlers). Because of how this feature is implemented,
the SDK must gather all devices for the handlers which implement an bulk read function in
order to perform the bulk read. If there are no devices, this message gets logged. It does
not mean that the plugin is not performing reads - it just means that there are no configured
devices for the specified handler to read.
