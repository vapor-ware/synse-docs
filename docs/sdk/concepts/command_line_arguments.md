---
hero: Command Line Arguments
---

The SDK provides plugins with a few basic command line arguments out of the box. These
can be seen by running a plugin with the `--help` flag. 

```
$ ./plugin --help
Usage of ./plugin:
  -debug
    	enable debug logging
  -dry-run
    	run only the setup actions to verify functionality and configuration
  -version
    	print the plugin version information
```

A plugin may add additional command line arguments as needed. To do so, the plugin must
define the flags that it uses, preferably in the file containing the `main()` function
where the plugin is initialized.

```go
import (
    "flag"
)

var customFlag bool

func init() {
    flag.BoolVar(&customFlag, "custom", false, "some custom functionality")
}
```

This flag will be parsed on plugin `Run()`. As such, it can only be used after the plugin
has been run.
