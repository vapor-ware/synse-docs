---
hero: Usage
---

# Usage

To list available commands and usage information, either run `synse` with no parameters
or with the `--help` flag.

```bash
$ synse
Command-line interface for the Synse platform.

Synse is a platform for monitoring and controlling physical and virtual
devices at data center scale.

This tool provides simple access to Synse APIs as well as simple
management and development utilities for the Synse platform.

https://github.com/vapor-ware/synse

Usage:
  synse [command]

Available Commands:
  # ...
```

Additional usage information for any CLI command can be found by running the command
with the `--help` flag.

```bash
$ synse [command] --help
```

## Overview

There are three primary groups of commands:

### `server`

These commands allow you to interact with an instance of Synse Server. The sub-commands
correspond to the actions available via Synse Server's [API](../server/api.v3.md).

### `plugin`

These commands allow you to interact with an instance of a Synse plugin. The sub-commands
are similar to those for the `server` command, however they are routed directly to the
plugin via the internal [gRPC API](https://github.com/vapor-ware/synse-server-grpc).

### `context`

These commands deal with configuration management for the instances of Synse
Server and Synse plugins which you wish to interact with. Contexts are persisted,
so you can define contexts for numerous instances and switch between them. The
persisted context can be found in your home directory as `.synse.yml`.

#### Example

If you have an instance of Synse Server running at `localhost:5000` and a plugin
running at `localhost:5001`, you can add those contexts to the CLI via:

```
synse context add server local-synse localhost:5000
synse context add plugin local-pluin localhost:5001
```

This will add the contexts to the CLI, but will not automatically set them
as the current active context. To do so, you may either invoke the above `add`
command with the `--set` flag, or you can use the `set` command

```
synse context set local-synse
```

There may only be one current context for Synse Server and one current context
for Synse plugins at any time. To view the contexts, use the `list` command.

```
synse context list
```

Entries with a `*` under the `CURRENT` heading indicate that the context is
set as a current active context.
