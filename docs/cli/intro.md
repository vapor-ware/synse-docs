---
hero: Introduction 
---

# Synse CLI

> *[github.com/vapor-ware/synse-cli](https://github.com/vapor-ware/synse-cli)*

The Synse CLI is a command line tool which can be used to interface with Synse Server
and Synse plugins directly. It allows for real-time queries and interaction with devices
exposed by Synse, making it easy to get started with Synse, develop, and debug.


## Installing

### Homebrew

To install from [Homebrew](https://brew.sh/), you will first need to add the vapor-ware tap

```
brew tap vapor-ware/formula
```

To install:

```
brew install vapor-ware/formula/synse
```

The CLI will be installed as `synse` and be placed on your path.

```bash
$ which synse
/usr/local/bin/synse
```

### Precompiled Binaries

Precompiled binaries are available as artifacts on GitHub [releases](https://github.com/vapor-ware/synse-cli/releases).
To download the binary and place it on your $PATH:

```shell
# Set variables for download
export CLI_VERSION="3.0.0"
export CLI_OS="darwin"
export CLI_ARCH="amd64"

# Download and install the CLI
wget \
  https://github.com/vapor-ware/synse-cli/releases/download/${CLI_VERSION}/synse-cli_${CLI_VERSION}_${CLI_OS}_${CLI_ARCH}.tar.gz \
  -O /usr/local/bin/synse

# Make the binary executable
chmod +x /usr/local/bin/synse
```

### From Source

If you wish to build from source, you will first need to fork and clone the repo. From within the
project root directory, you can build using the Makefile target:

```
make build
```

Which will create the `synse` binary in the project directory. If you wish, you can add it to
your PATH.
