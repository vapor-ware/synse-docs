---
hero: Testing 
---

The Synse SDK strives to follow the [Golang testing](https://golang.org/pkg/testing/)
best practices. Tests for each file are found in the same directory following the pattern
`FILENAME_test.go`, so given a file named `plugin.go`, the test file would be `plugin_test.go`.

## Writing Tests

There are many [articles](https://blog.alexellis.io/golang-writing-unit-tests/) and tutorials
out there on how to write unit tests for Golang. In general, this repository tries to follow "best
practices" as best as possible, striving to be consistent with how tests are written. This makes
them easier to read and maintain. When writing new tests, use the existing ones as a guide.

Whenever additions or changes are made to the code base, there should be corresponding tests which
cover those changes. Many unit tests already exists, so some changes may not require tests to be added.
While good code coverage does not ensure bug-free code, it does help to identify bugs early on in the
development cycle. Writing good tests is just as important as any implementation work.

## Running Tests

Tests can be run with `go test`, e.g.

```
$ go test ./sdk/...
```

For convenience, there is a make target to do this

```
$ make test
```

While the above make target will report coverage at a high level, it may be useful to
view a detailed coverage report, showing which lines were hit and which were missed.
For that, you can use the make target

```
make cover
```

This will run unit tests and output the resulting coverage reports as an HTML page.
