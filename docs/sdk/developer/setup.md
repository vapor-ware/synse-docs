---
hero: Setup 
---

## Getting

To begin developing the Synse SDK, you will first need your own copy of the source code.
Fork the [GitHub repo](https://github.com/vapor-ware/synse-sdk) and clone it down
to your local workspace.

## Requirements

It is recommended to use the following development tools:

- Go 1.13+: The SDK was developed using Go 1.13.
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
check-examples  Check that the example pluginss run without failing
clean           Remove temporary files
cover           Run tests and open the coverage report
examples        Build the example plugins
fmt             Run goimports on all go files
github-tag      Create and push a tag with the current version
godoc           Server godocs locally on port 8080
help            Print usage information
lint            Lint project source files
test            Run all tests
version         Print the version of the SDK
```

It is recommended to run tests, formatting, and linting locally prior to pushing/opening
a pull request. These steps, including building the examples, are also run in CI.
CI failures will prevent pull requests from being merged.
