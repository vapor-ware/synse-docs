---
hero: Getting Synse Server
---

## Docker

Synse Server is available from [DockerHub](https://hub.docker.com/r/vaporio/synse-server).

```
docker pull vaporio/synse-server
```

Pushes to `master` build a new `:latest` tag for the Synse Server image. GitHub tags build new
images with the corresponding tag as well. For example, if a new tag `v1.2.3` was pushed, the following
image tags would be created:

- `vaporio/synse-server:latest`
- `vaporio/synse-server:v1`
- `vaporio/synse-server:v1.2`
- `vaporio/synse-server:v1.2.3`

## Helm

A [Helm](https://helm.sh/) chart for Synse Server is available from the [Synse Charts repository](https://github.com/vapor-ware/synse-charts).

You can add the repo to a local helm http web server (`helm serve`) with

```
helm repo add synse https://charts.vapor.io
```

The repo can be updated with

```
helm repo update synse
```

To see the available helm charts that the Synse Charts repo provides, simply search for 'synse'

```console
$ helm search synse
synse/synse-server 	3.0.0        	3.0.0      	An API to monitor and control physical and virtual infras...
...
```

## Source

Synse Server lives on [GitHub](https://github.com/vapor-ware/synse-server), making it easy to
get the source. You can either fork/clone the repo, or download a particular release from the
project's [releases](https://github.com/vapor-ware/synse-server/releases) page.
