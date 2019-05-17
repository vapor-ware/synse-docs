---
hero: Debugging 
---

## Debug Mode

By default, Synse Server runs with logging set at `INFO` level. To run it in `DEBUG`
mode, you can either set `#!yaml logging: debug` in the Synse Server configuration YAML, or you
can set it via environment variable, e.g. `SYNSE_LOGGING=debug`.

This can be set for `docker run`

```
docker run -p 5000:5000 -e SYNSE_LOGGING=debug vaporio/synse-server
```

or via compose file (or other orchestration configuration)

```yaml
version: '3'
services:
  synse-server:
    image: vaporio/synse-server
    environment:
      SYNSE_LOGGING: debug
    ports:
      - "5000:5000"
```

## Getting Logs

When running Synse Server in a Docker container, its logs are output to the container's
stdout/stderr, so they can be accessed via `docker logs`, e.g.

```
docker logs synse-server
```
