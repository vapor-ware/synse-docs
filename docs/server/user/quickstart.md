---
hero: Quickstart 
---

This page assumes you have [gotten](getting.md#docker) the Docker image for Synse Server.

It will go over:

- [Starting Synse Server](#starting-synse-server)
- [Using an Emulator Backend](#using-an-emulator-backend)
- [A Simple Emulator Deployment](#a-simple-emulator-deployment)

## Starting Synse Server

Synse Server can be run "out of the box" with no additional configuration necessary:

```
docker run --name synse-server -p 5000:5000 -d vaporio/synse-server
```

This will run a new Synse Server container, exposed on port 5000. You can hit [API Endpoints](../api.v3.md)
to see what Synse Server provides, but there will be minimal data available. Synse gets
all device data from plugins; with no plugins registered, there will be no device data.

You may also verify it started up correctly by inspecting the container logs:

```
docker logs synse-server
```

Or hitting the status or version endpoints:

```console
$ curl localhost:5000/test
{
  "status": "ok",
  "timestamp": "2019-05-16T18:07:05Z"
}

$ curl localhost:5000/version
{
  "version": "3.0.0",
  "api_version": "v3"
}
```

## Using an Emulator Backend

To get device data, the [emulator plugin](https://github.com/vapor-ware/synse-emulator-plugin) can be
registered with Synse Server. If you are already running a server instance (e.g. from the previous
section), you will need to terminate it.

```
docker rm -f synse-server
```

Now, you can start a new instance of Synse Server, this time [configuring](configuration.md) it
to register the emulator plugin at `emulator:5001`.

```
docker run --name synse-server -p 5000:5000 -d \
    -e SYNSE_PLUGIN_TCP="emulator:5001" \
    vaporio/synse-server
```

At this point, you could check the logs and see errors because there is no `emulator:5001` yet
so it can not register it as a plugin.

To register an emulator plugin instance to the running server instance, you will need to create
a new docker network and connect it to the synse server instance

```
docker network create synse-net
docker network connect synse-net synse-server
```

You can then run the emulator plugin, exposing port `5001` and giving it the `emulator` alias
on the network so the server can find it at `emulator:5001`.

```
docker run -d --expose 5001 \
    --network synse-net \
    --network-alias emulator \
    vaporio/emulator-plugin
```

You can follow the server logs and see that it will eventually rebuild the cache and find the
plugin. You can also force a cache rebuild immediately by hitting the [`/scan`](../api.v3.md#scan)
endpoint with the query parameter `?force=true`.

```
...
timestamp='2019-05-16T18:00:31.877338Z' level='debug' event='refreshing plugin manager'
timestamp='2019-05-16T18:00:31.877482Z' level='info' event='loading plugins from configuration'
timestamp='2019-05-16T18:00:31.877691Z' level='debug' event='plugin from config' mode='tcp' address='emulator:5001'
timestamp='2019-05-16T18:00:32.942294Z' level='debug' event='registered plugin' id='4032ffbe-80db-5aa5-b794-f35c88dff85c' tag='vaporio/emulator-plugin'
timestamp='2019-05-16T18:00:32.942498Z' level='info' event='marking plugin as active' id='4032ffbe-80db-5aa5-b794-f35c88dff85c' tag='vaporio/emulator-plugin'
timestamp='2019-05-16T18:00:32.942679Z' level='debug' event='plugin manager refresh complete' plugin_count=1
timestamp='2019-05-16T18:00:32.943049Z' level='debug' event='getting devices from plugin' plugin='vaporio/emulator-plugin' plugin_id='4032ffbe-80db-5aa5-b794-f35c88dff85c'
...
``` 

## A Simple Emulator Deployment

Running Synse Server with an emulator backend is even simpler when done with a [compose file](https://docs.docker.com/compose).

```yaml
# 
# compose.yml
#
# A simple deployment to run Synse Server with the emulator
# plugin, both in debug mode.
#

version: '3'
services:
  synse-server:
    image: vaporio/synse-server
    ports:
    - '5000:5000'
    links:
    - emulator
    environment:
      SYNSE_LOGGING: debug
      SYNSE_PLUGIN_TCP: 'emulator:5001'
  
  emulator:
    image: vaporio/emulator-plugin
    command: ['--debug']
    expose:
    - 5001
```

Which can be run with:

```
docker-compose -f compose.yml up -d
```