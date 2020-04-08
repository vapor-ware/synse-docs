# Synse Docs

This repository contains the source files for the Synse platform's hosted documentation.

The documentation covers multiple projects:

- [Synse Server](https://github.com/vapor-ware/synse-server)
- [Synse SDK](https://github.com/vapor-ware/synse-sdk)
- [Synse CLI](https://github.com/vapor-ware/synse-cli)

## Structure

All project documentation is written in Markdown and is found in the [`docs`](docs)
subdirectory. All markdown files in the `docs` directory are for the documentation
"Home" section.

Subdirectories within the `docs` directory designate different sections of the documentation
corresponding to different Synse projects. For example, the [`docs/server`](docs/server)
directory contains documentation for Synse Server.

For more information on writing and styling docs, see the [`mkdocs` documentation](https://www.mkdocs.org/).

## Building

The documentation can be built locally, which can be helpful for writing and styling the docs.
A make target is specified for convenience:

```
make serve
```

This will build the docs into a `site` directory and serve them on `http://127.0.0.1:8000`.

## Releasing

This documentation is hosted on [Read the Docs](https://readthedocs.org/), so whenever a change is
pushed to a tracked branch, like master, it will get rebuilt and updated automatically.
