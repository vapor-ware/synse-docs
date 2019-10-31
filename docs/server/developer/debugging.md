---
hero: Debugging 
---

## Debug Mode

By default, Synse Server runs with logging set at `DEBUG` level. To run it at `INFO`
mode, you can either set `#!yaml logging: info` in the Synse Server configuration YAML, or you
can set it via environment variable, e.g. `SYNSE_LOGGING=info`.

This can be set for `docker run`

```
docker run -p 5000:5000 -e SYNSE_LOGGING=info vaporio/synse-server
```

or via compose file (or other orchestration configuration)

```yaml
version: '3'
services:
  synse-server:
    image: vaporio/synse-server
    ports:
    - '5000:5000'
    environment:
      SYNSE_LOGGING: info
```

## Getting Logs

When running Synse Server in a Docker container, its logs are output to the container's
stdout/stderr, so they can be accessed via `docker logs`, e.g.

```
docker logs synse-server
```
