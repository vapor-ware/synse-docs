---
hero: Testing 
---

## Writing Tests

Whenever additions or changes are made to the code base, tests should be added (or updated)
to verify that the changes behave as expected.

Test cases for Synse Server can be found in the project's `tests` directory. The structure of
the test directory mirrors that of the package directory. Tests for a given file (e.g. `synse_server/foo/bar.py`)
should have the same name, prefixed with "test" (e.g. `tests/foo/test_bar.py`).

Tests are written using the [pytest](https://docs.pytest.org/en/latest/) framework. Test
dependencies are defined in the project's `tox.ini` configuration.

## Running Tests

The test command is defined in the [tox](https://tox.readthedocs.io/en/latest/) configuration
and can be run by invoking `tox` with the path to the directory containing the tests. For
convenience, a Makefile target can also be used.

```bash
# run tests directly via tox
tox tests/unit

# run tests via make
make test
```

Test output will be displayed in the console. Test artifacts will also be generated
and kept in a `results/` directory. These artifacts include:

- `results/coverage`: The coverage report for the last test run.
- `results/pytest`: The pytest results as an HTML page.
