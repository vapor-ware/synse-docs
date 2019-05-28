---
hero: Setup 
---

## Getting

To begin developing the Synse SDK, you will first need your own copy of the source code.
Fork the [GitHub repo](https://github.com/vapor-ware/synse-sdk) and clone it down
to your local workspace.

## Requirements

It is recommended to use the following development tools:

- Go 1.11+: The SDK was developed using Go 1.11.
- [`dep`](https://github.com/golang/dep): Dependency management tooling.
- [`docker`](https://www.docker.com): Build and run Synse plugins in a containerized
  environment.
- [`docker-compose`](https://docs.docker.com/compose/install): Define and run deployments
  for development and testing.
- [`make`](https://www.gnu.org/software/make): Run predefined targets that simplify
  various development actions and workflows.

## Workflow

To aid in developer workflow, Makefile targets are provided for common development
tasks. To see what targets are provided, see the project `Makefile`, or run `make help`
from the project repo root.

```console
$ make help
build           Build the SDK locally
check-examples  Check that the examples run without failing.
ci              Run CI checks locally (build, test, lint)
clean           Remove temporary files
cover           Run tests and open the coverage report
dep             Ensure and prune dependencies
dep-update      Ensure, update, and prune dependencies
docs            Build the docs locally
examples        Build the examples
fmt             Run goimports on all go files
github-tag      Create and push a tag with the current version
godoc           Run godoc to get a local version of docs on port 8080
help            Print usage information
lint            Lint project source files
setup           Install the build and development dependencies
test            Run all tests
version         Print the version of the SDK
```

It is recommended to run tests, formatting, and linting locally prior to pushing/opening
a pull request. These steps, including building the examples, are also run in CI.
CI failures will prevent pull requests from being merged.
