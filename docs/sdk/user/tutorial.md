---
hero: Tutorial
---

This page goes through a tutorial to create a simple plugin which will provide readings
for a single "memory" device. For more examples, see the SDK's `examples` directory or
the Synse [emulator plugin](https://github.com/vapor-ware/synse-emulator-plugin).

For this tutorial, we will get the memory data using [github.com/shirou/gopsutil](https://github.com/shirou/gopsutil),
which you can get with 

```
go get github.com/shirou/gopsutil
```

## 1. Planning

Prior to writing code for the plugin, it is a good idea to figure out what the plugin
will do, what data it will provide, and what devices it will have. This will provide
concrete definitions and constraints when implementing the plugin.

**Goals**

- Provide readings for memory usage
- Do not support writing (doesn't make sense for this use case)
- Have the readings updated every 5 seconds

**Devices**

- One "memory" device which will have reading outputs of:
  - total memory (in bytes)
  - free memory (in bytes)
  - used percentage (percent)

## 2. Create the plugin skeleton

With an idea of what we want the plugin to do, the next step would be to lay down the
foundation for the plugin. This tutorial will only go over the bare minimum for what is
needed, however additional things may be added to enhance the development flow (Makefile, 
CI, dependency management, etc).

We know that we will be defining a plugin with a new memory type device, so we should have
a device configuration, a plugin configuration, plugin-specific reading outputs, and the plugin
source itself:

```
.
├── config
│   └── device
│       └── memory.yaml
├── config.yaml
├── handlers.go
├── outputs.go
└── plugin.go
```

!!! note
    A plugin can be structured in different ways. Since this is a simple example
    plugin, a simple structure is being used. This example does not aim to define
    a "correct" structure.
    

## 3. Write the configurations

Once the project structure is in place, we can define the various configurations.
It is not necessary to define them before writing the plugin source itself, though
it can be helpful so you know exactly what data the plugin will be dealing with
when it is implemented.

### 3a. Plugin configuration

The plugin configuration defines how the plugin itself will behave. For a reference
on configuration options, see the [plugin configuration](configuration.plugin.md) documentation.

From the *goals* listed earlier, we know that we will want the plugin to update its readings
every 5 seconds. Additionally, we need to choose whether the plugin will run in serial mode
or parallel mode. Since reading the memory info we want is not serial-bound, we can run it in
parallel mode. The plugin must also run either using unix socket or TCP for the gRPC transport.
In general, plugins should choose to use TCP as it is easier to manage.

With this, we can define our simple plugin configuration:

```yaml
# config.yaml

version: 3
debug: false
network:
  type: tcp
  address: ':5001'
settings:
  mode: parallel
  read:
    interval: 5s
```

Debug logging can be verbose, so it is disabled here. If you wish to see debug logs,
just set `#!yaml debug: true`.

### 3b. Device configuration

The device configuration defines the devices that the plugin will manage and collect
data from. For a reference on configuration options, see the [device configuration](configuration.device.md) documentation.

From the [planning section](#1-planning), we know that we will want a "memory"-type device, of which
we will have a single instance which provides multiple readings. All devices need to be associated with
a *device handler* which the plugin implements. Since we have not implemented the plugin yet, that
device handler does not exist, but we can still give it a name for when we do implement it -- we'll
call it "virtual-memory".

```yaml
# config/device/memory.yaml

version: 3
devices:
- type: memory
  handler: virtual-memory
  instances:
  - info: Virtual Memory Usage
    data:
      id: 1
```

Above, we device the "memory" device which uses the "virtual-memory" handler. There is one
instance, which we two things:

- **info**: A human readable string that helps us identify the device
- **data**: Data associated with the device. Generally this would give the plugin
  info on how to connect to the device, such as the port number, address, etc. Since this
  example plugin is so simple, there is no need for that -- the memory usage is just for
  the system the plugin is running on. We still need to specify something for the data
  because of Synse [deterministic device IDs](concepts.md#deterministic-device-ids). Providing
  unique data here allows us to generate a unique deterministic ID hash for the device.

## 4. Define reading outputs

The SDK provides some built-in [outputs](concepts.md#outputs), but as per the [planning](#1-planning)
section, this plugin will require some custom outputs:

- total memory
- free memory
- percent memory used

Total memory and free memory are returned as bytes, and the percent memory used is returned
as a percentage, so we can define a `bytes` and `percent` custom output:

```go
// outputs.go

package main

import "github.com/vapor-ware/synse-sdk/sdk/output"

var (
	outputBytes = output.Output{
		Name: "bytes",
		Unit: &output.Unit{
			Name: "bytes",
			Symbol: "B",
		},
	}

	outputPercent = output.Output{
		Name: "percent",
		Precision: 2,
		Unit: &output.Unit{
			Name: "percent",
			Symbol: "%",
		},
	}
)
```

These outputs will be registered with the plugin in a [later step]().

## 5. Define the device handler

If you have read through the SDK documentation, you should know that devices are configured with
a *device handler*, which tells the plugin how to read from/write to the device. As stated in the
planning step, this plugin will only support reading. In the [device configuration](#3b-device-configuration)
step, we also specified that our memory-type device will use a handler named "virtual-memory".

Below, we define the virtual-memory device using [gopsutil](https://github.com/shirou/gopsutil)
to get the memory data we desire.

```go
// handlers.go

package main

import (
	"github.com/shirou/gopsutil/mem"
	"github.com/vapor-ware/synse-sdk/sdk"
	"github.com/vapor-ware/synse-sdk/sdk/output"
)

var virtualMemoryHandler = sdk.DeviceHandler{
	Name: "virtual-memory",
	Read: func(device *sdk.Device) ([]*output.Reading, error) {
		vMemStat, err := mem.VirtualMemory()
		if err != nil {
			return nil, err
		}
		
		total := outputBytes.MakeReading(vMemStat.Total)
		total.Info = "total"
		
		free := outputBytes.MakeReading(vMemStat.Total)
		free.Info = "free"
		
		pctUsed := outputBytes.MakeReading(vMemStat.Total)
		pctUsed.Info = "percent memory used"

		return []*output.Reading{
			total,
			free,
			pctUsed,
		}, nil
	},
}
```

Notice that for each reading, `Info` is set to provide additional information on what the
reading is for. Without this, we would get two bytes outputs without knowing which is a measure
of the free memory vs. the total memory.

## 6. Create the plugin

With all the configuration defined, the custom outputs defined, and the plugin's device handler
defined, its time to create the plugin itself and register everything with it.

The plugin should be created within the `#!go main()` function and will require some metadata
to be defined, namely a plugin name and maintainer. We'll call the plugin "memory tutorial" and
the maintainer will be "vaporio".

```go
// plugin.go

package main

import (
	"log"

	"github.com/vapor-ware/synse-sdk/sdk"
)

func main() {
	sdk.SetPluginInfo(
		"memory tutorial",
		"vaporio",
		"a tutorial plugin for reading virtual memory",
		"",
	)

	// Create a new plugin instance.
	plugin, err := sdk.NewPlugin()
	if err != nil {
		log.Fatal(err)
	}

	// Register custom output types.
	err = plugin.RegisterOutputs(
		&outputBytes,
		&outputPercent,
	)
	if err != nil {
		log.Fatal(err)
	}

	// Register the plugin's device handler.
	err = plugin.RegisterDeviceHandlers(
		&virtualMemoryHandler,
	)
	if err != nil {
		log.Fatal(err)
	}

	// Run the plugin.
	if err := plugin.Run(); err != nil {
		log.Fatal(err)
	}
}
```

## 7. Build and run the plugin

With all the plugin files defined, the plugin can now be built and run.

```
go build -o plugin
```

Running the plugin, you should see logs similar to:

```
INFO[0000] [config] loading configuration                ext=yaml loader=plugin name=config paths="[. ./config /etc/synse/plugin/config]" policy=optional
INFO[0000] [config] found matching config                file=config.yaml loader=plugin path=. policy=optional
INFO[0000] Plugin Info:                                 
INFO[0000]   Tag:         vaporio/memory-tutorial       
INFO[0000]   Name:        memory tutorial               
INFO[0000]   Maintainer:  vaporio                       
INFO[0000]   VCS:                                       
INFO[0000]   Description: a tutorial plugin for reading virtual memory 
INFO[0000] Version Info:                                
INFO[0000]   Plugin Version: -                          
INFO[0000]   SDK Version:    3.0.0                      
INFO[0000]   Git Commit:     -                          
INFO[0000]   Git Tag:        -                          
INFO[0000]   Build Date:     -                          
INFO[0000]   Go Version:     -                          
INFO[0000]   OS/Arch:        darwin/amd64               
INFO[0000] Plugin Config:                               
INFO[0000]   Version: 3                                 
INFO[0000]   Debug:   false                             
INFO[0000]   ID:                                        
INFO[0000]     UsePluginTag: true                       
INFO[0000]     UseMachineID: false                      
INFO[0000]     UseEnv:       []                         
INFO[0000]     UseCustom:    []                         
INFO[0000]   Settings:                                  
INFO[0000]     Mode: parallel                           
INFO[0000]     Listen:                                  
INFO[0000]       Disable: false                         
INFO[0000]     Read:                                    
INFO[0000]       Disable:   false                       
INFO[0000]       QueueSize: 128                         
INFO[0000]       Interval:  5s                          
INFO[0000]       Delay:     0s                          
INFO[0000]     Write:                                   
INFO[0000]       Disable:   false                       
INFO[0000]       QueueSize: 128                         
INFO[0000]       BatchSize: 128                         
INFO[0000]       Interval:  1s                          
INFO[0000]       Delay:     0s                          
INFO[0000]     Transaction:                             
INFO[0000]       TTL: 5m0s                              
INFO[0000]     Limiter:                                 
INFO[0000]       Rate:  0                               
INFO[0000]       Burst: 0                               
INFO[0000]     Cache:                                   
INFO[0000]       Enabled: false                         
INFO[0000]       TTL:     3m0s                          
INFO[0000]   Network:                                   
INFO[0000]     Type:    tcp                             
INFO[0000]     Address: :5001                           
INFO[0000]     TLS:                                     
INFO[0000]       Key:                                   
INFO[0000]       Cert:                                  
INFO[0000]       CACerts:    []                         
INFO[0000]       SkipVerify: false                      
INFO[0000]   Health:                                    
INFO[0000]     HealthFile:     /etc/synse/plugin/healthy 
INFO[0000]     UpdateInterval: 30s                      
INFO[0000]   DynamicRegistration:                       
INFO[0000]     Config: []                               
INFO[0000] [id] generated plugin id namespace            id=f61f04ae-6338-5cbd-9bdf-ca6ed6c307db
INFO[0000] [plugin] initializing                        
INFO[0000] [device manager] initializing                
INFO[0000] [config] loading configuration                ext=yaml loader=device name= paths="[./config/device /etc/synse/plugin/config/device]" policy=required
INFO[0000] [config] found matching config                file=memory.yaml loader=device path=./config/device policy=required
INFO[0000] [device manager] added new device             id=aad3aac1-c1e2-54ac-8809-cb2883daa979 type=memory
INFO[0000] [device manager] created devices              devices=1
INFO[0000] [server] tls/ssl not configured, using insecure transport 
INFO[0000] [plugin] executing pre-run actions            actions=2
INFO[0000] [health] registered default health check      name="read queue health" type=periodic
INFO[0000] [health] registered default health check      name="write queue health" type=periodic
INFO[0000] [plugin] running                             
INFO[0000] [device manager] starting                    
INFO[0000] [state manager] starting                     
INFO[0000] [scheduler] starting                         
INFO[0000] [server] starting                            
INFO[0000] [plugin] will terminate on: [SIGTERM, SIGINT] 
INFO[0000] [scheduler] listeners will not be scheduled (no listener handlers registered) 
INFO[0000] [scheduler] starting read scheduling          delay=0s interval=5s mode=parallel
INFO[0000] [server] serving                              addr=":5001" mode=tcp
INFO[0000] [scheduler] writing will not be scheduled (no write handlers registered) 
```

You can use the [Synse CLI](../../cli/intro.md) to interact with the plugin directly, or continue
on to run it alongside Synse Server and interact with it through the Synse API. You can terminate
the plugin with `^C`.

## 8. Running with Synse Server

The easiest way to run the plugin with Synse Server is to create a docker image for the plugin.

```dockerfile
# Dockerfile

FROM scratch

COPY plugin plugin

ENTRYPOINT ["./plugin"]
```

Since the `scratch` image requires a linux/amd64 binary, we should rebuild the plugin for
that architecture:

```
$ GOOS=linux GOARCH=amd64 go build -o plugin
```

Then, the Docker image can be build -- we'll tag the image as `vaporio/tutorial-plugin`.

```
docker build -t vaporio/tutorial-plugin .
```

We now have a docker image for the plugin, but it needs some additional configuration
to run, namely mounting the plugin and device configuration we defined into the container.
We can create a compose file to mount in the configuration and connect it to a Synse Server
instance. See the [Synse Server documentation](../../server/intro.md) for details on how
the server container is configured.

```yaml
# compose.yaml

version: '3'
services:
  synse-server:
    container_name: synse-server
    image: vaporio/synse-server
    ports:
    - '5000:5000'
    environment:
      SYNSE_PLUGIN_TCP: 'tutorial-plugin:5001'
    links:
    - tutorial-plugin

  tutorial-plugin:
    container_name: tutorial-plugin
    image: vaporio/tutorial-plugin
    expose:
    - 5001
    volumes:
    - ./config.yaml:/etc/synse/plugin/config/config.yaml
    - ./config/device:/etc/synse/plugin/config/device
``` 

Which can be run with:

```
docker-compose -f compose.yaml up -d
```

Once running, you should see both containers up

```console
$ docker ps
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS              PORTS                    NAMES
6556deaf8b0f        vaporio/synse-server      "/usr/bin/tini -- bi…"   31 seconds ago      Up 30 seconds       0.0.0.0:5000->5000/tcp   synse-server
d110ab9e1ac7        vaporio/tutorial-plugin   "./plugin"               32 seconds ago      Up 31 seconds       5001/tcp                 tutorial-plugin
```

You can now interact with the plugin via the [Synse Server API](../../server/api.v3.md), e.g.

```console
$ curl localhost:5000/v3/read
[
  {
    "device":"aad3aac1-c1e2-54ac-8809-cb2883daa979",
    "timestamp":"2019-05-28T20:09:57Z",
    "type":"",
    "device_type":"memory",
    "unit":{
      "name":"bytes",
      "symbol":"B"
    },
    "value":2095575040,
    "context":{
      "info":"total"
    }
  },
  {
    "device":"aad3aac1-c1e2-54ac-8809-cb2883daa979",
    "timestamp":"2019-05-28T20:09:57Z",
    "type":"",
    "device_type":"memory",
    "unit":{
      "name":"bytes",
      "symbol":"B"
    },
    "value":2095575040,
    "context":{
      "info":"free"
    }
  },
  {
    "device":"aad3aac1-c1e2-54ac-8809-cb2883daa979",
    "timestamp":"2019-05-28T20:09:57Z",
    "type":"",
    "device_type":"memory",
    "unit":{
      "name":"bytes",
      "symbol":"B"
    },
    "value":2095575040,
    "context":{
      "info":"percent memory used"
    }
  }
]
```
