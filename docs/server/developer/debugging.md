---
hero: Debugging 
---

## Debug Mode

By default, Synse Server runs with logging set at `DEBUG` level. To run it at `INFO`
level, you can either set `#!yaml logging: info` in the Synse Server configuration YAML, or you
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

## Profiling

As of Synse Server version `v3.0.1`, a `--profile` flag is made available to run Synse Server in
profiling mode. This uses [cProfile](https://docs.python.org/3/library/profile.html#module-cProfile)
to gather the profiling data. When the flag is set, profiling data will be printed out to console and
written out to file (synse-server.profile).

To set the flag, pass `--profile` in as a command to the container, e.g.

```
docker run vaporio/synse-server --profile
```

or, in a compose file

```yaml
version: '3'
services:
  synse-server:
    image: vaporio/synse-server
    ports:
    - '5000:5000'
    command: ['--profile']
```

To get the profiling data, stop synse server (e.g. `docker stop synse-server`). You can view the
profiling data by:

- looking at the container logs (`docker logs synse-server`)
- copying the profile out of the container (`docker cp synse-server:/synse/synse-server.profile .`)

From there, you can use tools like [`gprof2dot`](https://github.com/jrfonseca/gprof2dot) and
[`dot`](https://github.com/pydot/pydot) to create graphs of the data, or write a simple script
to parse the profiling data as desired.

For example:

```bash
$ gprof2dot -f pstats synse-server.profile -o synse-server.dot
$ dot -Tpng synse-server.dot -o synse-server.png
```
