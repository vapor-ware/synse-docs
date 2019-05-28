---
hero: Setup 
---

## Getting

To begin developing Synse Server, you will first need your own copy of the source code.
Fork the [GitHub repo](https://github.com/vapor-ware/synse-server) and clone it down
to your local workspace.

## Requirements

It is recommended to use the following development tools:

- [`tox`](https://tox.readthedocs.io/en/latest): Create reproducible environments for
  testing, linting, and other development actions.
- [`pyenv`](https://github.com/pyenv/pyenv): Python version management - Synse Server
  requires Python 3.6 or greater.
- [`docker`](https://www.docker.com): Build and run Synse Server in a containerized
  environment.
- [`docker-compose`](https://docs.docker.com/compose/install): Define and run deployments
  for development and testing.
- [`make`](https://www.gnu.org/software/make): Run predefined targets that simplify
  various development actions and workflows.

## Workflow

To aid in the developer workflow, Makefile targets are provided for common development
tasks. To see what targets are provided, see the project `Makefile`, or run `make help`
from the project repo root.

```console
$ make help
api-doc          Open the locally generated HTML API reference
clean            Clean up build and test artifacts
cover            Run unit tests and open their resulting HTML coverage report
deps             Update the frozen pip dependencies (requirements.txt)
docker           Build the docker image locally
docs             Build project documentation locally
fmt              Automatic source code formatting (isort)
github-tag       Create and push a tag with the current version
help             Print Make usage information
i18n             Update the translations catalog
lint             Run linting checks on the project source code (isort, flake8)
run              Run Synse Server with emulator locally (localhost:5000)
test             Run all tests
test-unit        Run the unit tests
version          Print the version of Synse Server
```

It is recommended to run tests, formatting, and linting locally prior to pushing/opening
a pull request. These steps, including building the package and docker image, are also
run in CI. CI failures will prevent pull requests from being merged.
