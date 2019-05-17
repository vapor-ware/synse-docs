---
hero: v3 API Reference
---

Synse Server can provide an interface to registered devices through an HTTP API or
a WebSocket API. Both APIs expose the same information, with only some changes to the
expected response data.

## HTTP API

In the API [Reference](#reference) section below, each item describes the URI and method(s) for
the endpoint, as well as the expected response data on success, and possible error codes on failure.

Within this document:

- `localhost:5000`, `#!shell ${server}`, and other references to the hostname/IP and port
  of the Synse Server instance are all functionally equivalent and serve only as a placeholder
  which should be replaced with instance's IP/port.
- The examples provided for each item use the [Synse Python Client](https://github.com/vapor-ware/synse-client-python)
  for the Python examples.
- All specified URI parameters are required.
- All specified query parameters are optional.

### Requests

Each item defines the basic endpoint information in a table which looks like:

| | | |
| --- | --- | --- |
| HTTP | **GET** | `/test` |

This says that for the HTTP API, issue a GET request against the `/test` URI. Given a Synse Server
instance running at `localhost:5000`, this would translate to

```
GET http://localhost:5000/test
```

### Responses

Each item also defines a *Response Data* section, which describes the JSON payload that is returned
on success. For the HTTP API, this is the exact data that is returned (no additional formatting is done).

## WebSocket API

You can connect to the WebSocket API via:

```bash
ws://${server}/v3/connect
```

where `${server}` is the hostname[:port] of the Synse Server instance.

In the API [Reference](#reference) section below, each item describes the *event* of the request
for the WebSocket API. Both client requests and server responses use the same message format:

```json
{
  "id": 0,
  "event": "request/status",
  "data": {}
}
```

The fields of the request structure are described below:

| Field | Description |
| :---- | :---------- |
| *id* | The numeric ID of the message. Each client session should track and increment its own IDs. The server reflects this ID in the response message(s). This can be used for matching responses with their originating requests. |
| *event* | The type of the message that is being sent. All client requests are prefixed with `request/`. All server responses are prefixed with `response/`. |
| *data* | The data being sent. For **requests**, this will include the equivalent of URI parameters and query parameters. If a given event does not have any such parameters, this can be left empty (`"data": {}`) or it can be omitted entirely. For **responses**, this will hold the server response data -- this is equivalent to the response you would get from the HTTP API. |

An error is returned with `response/error`. If the error occurs prior to the request
being parsed (or due to an invalid request which cannot be parsed), the return ID will be -1.

Within this document:

- The contents of the `data` field for a given request are not explicitly called out. They are instead
  implied from the HTTP URI parameters (required) and query parameters (optional). The names of the
  parameters correspond to their keys in the `data` field.
- One exception to the above is for writes - POSTed data is specified via the `payload` key.

### Requests

Each item defines the basic event information in a table which looks like:

| | | |
| --- | --- | --- |
| WebSocket | **request** | `"request/status"` |
| | **response** | `"response/status"` |

This says that for the WebSocket API, issue a status request using the `request/status` event.
This would translate into the message:

```json
{
  "id": 0,
  "event": "request/status"
}
```

### Responses

Responses use the same message scheme, where:

- the response `id` is the request ID reflected back
- the `event` is the corresponding response event for the given request type
- the `data` contains the JSON data defined in the *Response Data* section

The table, above, also lists the response event corresponding to the given request
event. A consolidated table of all request-response event mappings follows. Note
that all requests can have an error response.

| Request | Response |
| :------ | :------- |
| `request/status`        | `response/status` |
| `request/version`       | `response/version` |
| `request/config`        | `response/config` |
| `request/plugin`        | `response/plugin` |
| `request/plugin_health` | `response/plugin_health` |
| `request/scan`          | `response/device_summary` |
| `request/tags`          | `response/tags` |
| `request/info`          | `response/device` |
| `request/read`          | `response/reading` |
| `request/read_device`   | `response/reading` |
| `request/read_cache`    | `response/reading` |
| `request/write_async`   | `response/write_async` |
| `request/write_sync`    | `response/write_sync` |
| `request/transaction`   | `response/transaction` |


## Reference

### Errors

Most errors returned from Synse Server will come back with a JSON payload in order to
provide additional context for the error. Some errors will not return a JSON payload;
this class of error is generally due to the service not being ready, available, or
reachable.

#### *HTTP Codes*

An error response will be returned with one of the following HTTP codes:

- **400**: Invalid user input. This can range from invalid POSTed JSON, unsupported query
  parameters being used, or invalid resource types.
- **404**: The specified resource was not found.
- **405**: Action not supported for device (read/write).
- **500**: Server side processing error.

#### *Response Data*

```json
{
  "http_code": 404,
  "description": "resource not found",
  "timestamp": "2019-01-01T12:00:00Z",
  "context": "transaction not found: f041883c-cf87-55d7-a978-3d3103836412"
}
```

The fields of the response are described below:

| Field | Description |
| :---- | :---------- |
| *http_code* | The HTTP code corresponding to the error. (e.g. 400, 404, 500) |
| *description* | A short description of the error. |
| *timestamp* | The RFC3339 formatted timestamp at which the error occurred. |
| *context* | Contextual message associated with the error's root cause. This will typically include the pertinent internal state. |

??? note "HTTP"
    **Request**
    ```
    GET http://localhost:5000/v3/transaction/f041883c-cf87-55d7-a978-3d3103836412
    ```
    
    **Response**
    ```json
    {
      "http_code": 404,
      "description": "resource not found",
      "timestamp": "2019-01-01T12:00:00Z",
      "context": "transaction not found: f041883c-cf87-55d7-a978-3d3103836412"
    }
    ```

??? note "WebSocket"
    **Request**
    ```json
    {
      "id": 0,
      "event": "request/transaction",
      "data": {
        "transaction": "f041883c-cf87-55d7-a978-3d3103836412"
      }
    }
    ```
    
    **Response**
    ```json
    {
      "id": 0,
      "event": "response/error",
      "data": {
        "http_code": 404,
        "description": "resource not found",
        "timestamp": "2019-01-01T12:00:00Z",
        "context": "transaction not found: f041883c-cf87-55d7-a978-3d3103836412"
      }
    }
    ```



---

### Test

| | | |
| --- | --- | --- |
| HTTP      | **GET**      | `/test` |
| WebSocket | **request**  | `"request/status"` |
|           | **response** | `"response/status"` |

A dependency and side-effect free check to see whether Synse Server is
reachable and responsive.

If the endpoint is reachable (e.g. if Synse Server is up and ready), this
will return a 200 response with the described JSON response. If the test
endpoint is unreachable or otherwise fails, it will return a 500 response.

??? hint "Example"
    ***shell***
    ```shell
    curl http://${server}:5000/test
    ```
    
    ***python***
    ```python
    from synse import client
    
    api_client = client.HTTPClientV3('localhost')
    resp = api_client.test()
    
    print(resp.raw)
    ```

#### *Response Data*

```json
{
  "status": "ok",
  "timestamp": "2019-01-01T12:00:00Z"
}
```

The fields of the response are described below:

| Field | Description |
| :---- | :---------- |
| *status* | "ok" if the endpoint returns successfully. |
| *timestamp* | The time at which the status was tested. |

??? note "HTTP"
    **Request**
    ```
    GET http://localhost:5000/test
    ```
    
    **Response**
    ```json
    {
      "status": "ok",
      "timestamp": "2019-01-01T12:00:00Z"
    }
    ```

??? note "WebSocket"
    **Request**
    ```json
    {
      "id": 0,
      "event": "request/status"
    }
    ```
    
    **Response**
    ```json
    {
      "id": 0,
      "event": "response/status",
      "data": {
        "status": "ok",
        "timestamp": "2019-01-01T12:00:00Z"
      }
    }
    ```

##### Error

No JSON - route not reachable/service not ready

* **500** - Catchall processing error



---

### Version

| | | |
| --- | --- | --- |
| HTTP      | **GET**      | `/version` |
| WebSocket | **request**  | `"request/version"` |
|           | **response** | `"response/version"` |

Get the version info of the Synse Server instance. The API version
provided by this endpoint should be used in subsequent requests.

??? hint "Example"
    ***shell***
    ```shell
    curl http://${server}:5000/version
    ```
    
    ***python***
    ```python
    from synse import client
    
    api_client = client.HTTPClientV3('localhost')
    resp = api_client.version()
    
    print(resp.raw)
    ```

#### *Response Data*

```json
{
  "version": "3.0.0",
  "api_version": "v3"
}
```

The fields of the response are described below:

| Field | Description |
| :---- | :---------- |
| *version* | The full version (major.minor.micro) of the Synse Server instance. |
| *api_version* | The API version (major.minor) that can be used to construct subsequent API requests. |

??? note "HTTP"
    **Request**
    ```
    GET http://localhost:5000/version
    ```
    
    **Response**
    ```json
    {
      "version": "3.0.0",
      "api_version": "v3"
    }
    ```

??? note "WebSocket"
    **Request**
    ```json
    {
      "id": 0,
      "event": "request/version"
    }
    ```
    
    **Response**
    ```json
    {
      "id": 0,
      "event": "response/version",
      "data": {
        "version": "3.0.0",
        "api_version": "v3"
      }
    }
    ```

##### Error

No JSON - route not reachable/service not ready

* **500** - Catchall processing error



---

### Config

| | | |
| --- | --- | --- |
| HTTP      | **GET**      | `/v3/config` |
| WebSocket | **request**  | `"request/config"` |
|           | **response** | `"response/config"` |

Get a the unified configuration of the Synse Server instance.

This endpoint is added as a convenience to make it easier to determine what configuration the
server instance is running with. The Synse Server configuration is made up of default, file,
environment, and override config components. This endpoint provides the final joined configuration
which Synse Server ultimately runs with.

??? hint "Example"
    ***shell***
    ```shell
    curl http://${server}:5000/v3/config
    ```
    
    ***python***
    ```python
    from synse import client
    
    api_client = client.HTTPClientV3('localhost')
    resp = api_client.config()
    
    print(resp.raw)
    ```

#### *Response Data*

The response JSON will match the configuration scheme. See: [Config](server.md#configuration).

##### Error

The [error response](#errors) can be one of:

* **500** - Catchall processing error



---

### Plugin Info

| | | |
| --- | --- | --- |
| HTTP      | **GET**      | `/v3/plugin/<plugin_id>` |
| WebSocket | **request**  | `"request/plugin"` |
|           | **response** | `"response/plugin"` |

Get detailed information about the specified plugin.

If a plugin has registered with Synse Server and is communicating successfully,
it will be marked as "active". If registration or communication fail, it will be
marked as "inactive".

You can get a summary of all currently registered plugins via [Plugins](#plugins).

??? hint "Example"
    ***shell***
    ```shell
    curl http://${server}:5000/v3/plugin/4032ffbe-80db-5aa5-b794-f35c88dff85c
    ```
    
    ***python***
    ```python
    from synse import client
    
    api_client = client.HTTPClientV3('localhost')
    resp = api_client.plugin('4032ffbe-80db-5aa5-b794-f35c88dff85c')
    
    print(resp.raw)
    ```

#### *URI Parameters*

| Parameter | Description |
| :-------- | :---------- |
| *plugin_id* | The ID of the plugin to get more information for. Plugin IDs can be enumerated via the `/plugin` endpoint without specifying a URI parameter. |

#### *Response Data*

```json
{
  "name": "emulator plugin",
  "maintainer": "vaporio",
  "tag": "vaporio/emulator-plugin",
  "description": "A plugin with emulated devices and data",
  "vcs": "github.com/vapor-ware/synse-emulator-plugin",
  "id": "4032ffbe-80db-5aa5-b794-f35c88dff85c",
  "active": true,
  "network": {
    "address": "emulator:5001",
    "protocol": "tcp"
  },
  "version": {
    "plugin_version": "3.0.0",
    "sdk_version": "3.0.0",
    "build_date": "2019-05-13T16:20:40",
    "git_commit": "1a1d95b",
    "git_tag": "2.4.5-5-g1a1d95b",
    "arch": "amd64",
    "os": "linux"
  },
  "health": {
    "timestamp": "2019-01-01T12:00:00Z",
    "status": "OK",
    "checks": [
      {
        "name": "read queue health",
        "status": "OK",
        "type": "periodic",
        "message": "",
        "timestamp": "2019-01-01T12:00:00Z"
      },
      {
        "name": "write queue health",
        "status": "OK",
        "type": "periodic",
        "message": "",
        "timestamp": "2019-01-01T12:00:00Z"
      }
    ]
  }
}
```

The fields of the response are described below:

| Field | Description |
| :---- | :---------- |
| *active* | This field specifies whether the plugin is active or not. For more see [plugin activity](server.md#plugin-activity) |
| *id* | An id hash for identifying the plugin, generated from plugin metadata. |
| *tag* | The plugin tag. This is a normalized string made up of its name and maintainer. |
| *name* | The name of plugin. |
| *maintainer* | The maintainer of the plugin. |
| *description* | A short description of the plugin. |
| *vcs* | A link to the version control repo for the plugin. |
| *version* | An object that contains version information about the plugin. |
| *version.plugin_version* | The plugin version. |
| *version.sdk_version* | The version of the Synse SDK that the plugin is using. |
| *version.build_date* | The date that the plugin was built. |
| *version.git_commit* | The git commit at which the plugin was built. |
| *version.git_tag* | The git tag at which the plugin was built. |
| *version.arch* | The architecture that the plugin is running on. |
| *version.os* | The OS that the plugin is running on. |
| *network* | An object that describes the network configurations for the plugin. |
| *network.address* | The address of the plugin for the protocol used. |
| *network.protocol* | The protocol that is used to communicate with the plugin (unix, tcp). |
| *health* | An object that describes the overall health of the plugin. |
| *health.timestamp* | The time at which the health status applies. |
| *health.status* | The health status of the plugin (ok, degraded, failing, error, unknown) |
| *health.checks* | A collection of health check snapshots for the plugin. |

There may be `0..N` health checks for a Plugin, depending on how it is configured.
The health check elements here make up a snapshot of the plugin's health at a given time.

| Field | Description |
| :---- | :---------- |
| *name* | The name of the health check. |
| *status* | The status of the health check (ok, failing) |
| *message* | A message describing the failure, if in a failing state. |
| *timestamp* | The timestamp for which the status applies. |
| *type* | The type of health check (e.g. periodic) |

??? note "HTTP"
    **Request**
    ```
    GET http://localhost:5000/v3/plugin/4032ffbe-80db-5aa5-b794-f35c88dff85c
    ```
    
    **Response**
    ```json
    {
      "name": "emulator plugin",
      "maintainer": "vaporio",
      "tag": "vaporio/emulator-plugin",
      "description": "A plugin with emulated devices and data",
      "vcs": "github.com/vapor-ware/synse-emulator-plugin",
      "id": "4032ffbe-80db-5aa5-b794-f35c88dff85c",
      "active": true,
      "network": {
        "address": "emulator:5001",
        "protocol": "tcp"
      },
      "version": {
        "plugin_version": "3.0.0",
        "sdk_version": "3.0.0",
        "build_date": "2019-05-13T16:20:40",
        "git_commit": "1a1d95b",
        "git_tag": "2.4.5-5-g1a1d95b",
        "arch": "amd64",
        "os": "linux"
      },
      "health": {
        "timestamp": "2019-01-01T12:00:00Z",
        "status": "OK",
        "checks": [
          {
            "name": "read queue health",
            "status": "OK",
            "type": "periodic",
            "message": "",
            "timestamp": "2019-01-01T12:00:00Z"
          },
          {
            "name": "write queue health",
            "status": "OK",
            "type": "periodic",
            "message": "",
            "timestamp": "2019-01-01T12:00:00Z"
          }
        ]
      }
    }
    ```

??? note "WebSocket"
    **Request**
    ```json
    {
      "id": 0,
      "event": "request/plugin",
      "data": {
        "plugin": "4032ffbe-80db-5aa5-b794-f35c88dff85c"
      }
    }
    ```
    
    **Response**
    ```json
    {
      "id": 0,
      "event": "response/plugin",
      "data": {
        "name": "emulator plugin",
        "maintainer": "vaporio",
        "tag": "vaporio/emulator-plugin",
        "description": "A plugin with emulated devices and data",
        "vcs": "github.com/vapor-ware/synse-emulator-plugin",
        "id": "4032ffbe-80db-5aa5-b794-f35c88dff85c",
        "active": true,
        "network": {
          "address": "emulator:5001",
          "protocol": "tcp"
        },
        "version": {
          "plugin_version": "3.0.0",
          "sdk_version": "3.0.0",
          "build_date": "2019-05-13T16:20:40",
          "git_commit": "1a1d95b",
          "git_tag": "2.4.5-5-g1a1d95b",
          "arch": "amd64",
          "os": "linux"
        },
        "health": {
          "timestamp": "2019-01-01T12:00:00Z",
          "status": "OK",
          "checks": [
            {
              "name": "read queue health",
              "status": "OK",
              "type": "periodic",
              "message": "",
              "timestamp": "2019-01-01T12:00:00Z"
            },
            {
              "name": "write queue health",
              "status": "OK",
              "type": "periodic",
              "message": "",
              "timestamp": "2019-01-01T12:00:00Z"
            }
          ]
        }
      }
    }
    ```

##### Error

The [error response](#errors) can be one of:

* **500** - Catchall processing error
* **404** - Plugin not found



---

### Plugins

| | | |
| --- | --- | --- |
| HTTP      | **GET**      | `/v3/plugin` |
| WebSocket | **request**  | `"request/plugin"` |
|           | **response** | `"response/plugin"` |

Get a summary of all plugins currently registered with the server instance.

??? hint "Example"
    ***shell***
    ```shell
    curl http://${server}:5000/v3/plugin
    ```
    
    ***python***
    ```python
    from synse import client
    
    api_client = client.HTTPClientV3('localhost')
    resp = api_client.plugins()
    
    print(resp.raw)
    ```

!!! info
    There is no guarantee that all plugins are represented in the returned list
    if the server is configured to use plugin discovery. When discovering plugins,
    a plugin can only be registered when it makes itself available to the server.
    Depending on the plugin and any setup actions, this may take longer for some
    plugins than others.

#### *Response Data*

```json
[
  {
    "name": "emulator plugin",
    "maintainer": "vapor io",
    "tag": "vaporio/emulator-plugin",
    "description": "a plugin with emulated devices and data",
    "id": "4032ffbe-80db-5aa5-b794-f35c88dff85c",
    "active": true
  },
  {
    "name": "custom-plugin",
    "maintainer": "third-party",
    "tag": "third-party/custom-plugin",
    "description": "a custom third party plugin",
    "id": "3042ffce-81db-5bb6-b794-f35c88dff85d",
    "active": true
  }
]
```

The fields of the response are described below:

| Field | Description |
| :---- | :---------- |
| *active* | This field specifies whether the plugin is active or not. For more see [plugin activity](server.md#plugin-activity) |
| *id* | An id hash for identifying the plugin, generated from plugin metadata. |
| *tag* | The plugin tag. This is a normalized string made up of its name and maintainer. |
| *name* | The name of plugin. |
| *maintainer* | The maintainer of the plugin. |
| *description* | A short description of the plugin. |

??? note "HTTP"
    **Request**
    ```
    GET http://localhost:5000/v3/plugin
    ```
    
    **Response**
    ```json
    [
      {
        "name": "emulator plugin",
        "maintainer": "vapor io",
        "tag": "vaporio/emulator-plugin",
        "description": "a plugin with emulated devices and data",
        "id": "4032ffbe-80db-5aa5-b794-f35c88dff85c",
        "active": true
      },
      {
        "name": "custom-plugin",
        "maintainer": "third-party",
        "tag": "third-party/custom-plugin",
        "description": "a custom third party plugin",
        "id": "3042ffce-81db-5bb6-b794-f35c88dff85d",
        "active": true
      }
    ]
    ```

??? note "WebSocket"
    **Request**
    ```json
    {
      "id": 0,
      "event": "request/plugin"
    }
    ```
    
    **Response**
    ```json
    {
      "id": 0,
      "event": "response/plugin",
      "data": [
        {
          "name": "emulator plugin",
          "maintainer": "vapor io",
          "tag": "vaporio/emulator-plugin",
          "description": "a plugin with emulated devices and data",
          "id": "4032ffbe-80db-5aa5-b794-f35c88dff85c",
          "active": true
        },
        {
          "name": "custom-plugin",
          "maintainer": "third-party",
          "tag": "third-party/custom-plugin",
          "description": "a custom third party plugin",
          "id": "3042ffce-81db-5bb6-b794-f35c88dff85d",
          "active": true
        }
      ]
    }
    ```

##### Error

The [error response](#errors) can be one of:

* **500** - Catchall processing error



---

### Plugin Health

| | | |
| --- | --- | --- |
| HTTP      | **GET**      | `/v3/plugin/health` |
| WebSocket | **request**  | `"request/plugin_health"` |
|           | **response** | `"response/plugin_health"` |

Get a summary of the health of registered plugins.

This provides an easy way to programmatically determine whether the plugins
registered with Synse Server are considered healthy by Synse Server.

??? hint "Example"
    ***shell***
    ```shell
    curl http://${server}:5000/v3/plugin/health
    ```
    
    ***python***
    ```python
    from synse import client
    
    api_client = client.HTTPClientV3('localhost')
    resp = api_client.plugin_health()
    
    print(resp.raw)
    ```

#### *Response Data*

```json
{
  "status": "healthy",
  "updated": "2019-01-01T12:00:00Z",
  "healthy": [
    "4032ffbe-80db-5aa5-b794-f35c88dff85c",
    "3042ffce-81db-5bb6-b794-f35c88dff85d"
  ],
  "unhealthy": [],
  "active": 2,
  "inactive": 0
}
```

The fields of the response are described below:

| Field | Description |
| :---- | :---------- |
| *status* | A string describing the overall health state of the registered plugins. This can be either `"healthy"` or `"unhealthy"`. It will only be healthy if *all* plugins are found to be healthy, otherwise the overall state is unhealthy. |
| *updated* | An RFC3339 timestamp describing the time that the plugin health state was last updated. |
| *healthy* | A list containing the plugin IDs for those plugins deemed to be healthy. |
| *unhealthy* | A list containing the plugin IDs for those plugins deemed to be unhealthy. |
| *active* | The count of active plugins. (see: [plugin activity](server.md#plugin-activity)) |
| *inactive* | The count of inactive plugins. (see: [plugin activity](server.md#plugin-activity)) |

??? note "HTTP"
    **Request**
    ```
    GET http://localhost:5000/v3/plugin/health
    ```
    
    **Response**
    ```json
    {
      "status": "healthy",
      "updated": "2019-01-01T12:00:00Z",
      "healthy": [
        "4032ffbe-80db-5aa5-b794-f35c88dff85c",
        "3042ffce-81db-5bb6-b794-f35c88dff85d"
      ],
      "unhealthy": [],
      "active": 2,
      "inactive": 0
    }
    ```

??? note "WebSocket"
    **Request**
    ```json
    {
      "id": 0,
      "event": "request/plugin_health"
    }
    ```
    
    **Response**
    ```json
    {
      "id": 0,
      "event": "response/plugin_health",
      "data": {
        "status": "healthy",
        "updated": "2019-01-01T12:00:00Z",
        "healthy": [
          "4032ffbe-80db-5aa5-b794-f35c88dff85c",
          "3042ffce-81db-5bb6-b794-f35c88dff85d"
        ],
        "unhealthy": [],
        "active": 2,
        "inactive": 0
      }
    }
    ```

##### Error

The [error response](#errors) can be one of:

* **500** - Catchall processing error



---

### Scan

| | | |
| --- | --- | --- |
| HTTP      | **GET**      | `/v3/scan` |
| WebSocket | **request**  | `"request/scan"` |
|           | **response** | `"response/scan"` |

List the devices that Synse knows about and can read from/write to via
the configured plugins.

This endpoint provides an aggregated view of the devices made known to Synse
Server by each of the registered plugins. This endpoint provides a high-level
view of what exists in the system. Scan info can be filtered to show only those
devices which match a set of provided tags.

By default, scan results are sorted by device id. The `sort` query parameter
can be used to modify the sort behavior.

??? hint "Example"
    ***shell***
    ```shell
    curl http://${server}:5000/v3/scan
    ```
    
    ***python***
    ```python
    from synse import client
    
    api_client = client.HTTPClientV3('localhost')
    resp = api_client.scan()
    
    print(resp.raw)
    ```

#### *Query Parameters*

| Key  | Description |
| :--- | :---------- |
| ns | The default namespace to use for the specified labels. (default: `default`) |
| tags | The [tags](tags.md) to filter devices on. If specifying multiple tags, they should be comma-separated. |
| force | Force a re-scan (do not use the cache). This will take longer than scanning using the cache, since it needs to rebuild the cache. (default: false) |
| sort | Specify the fields to sort by. Multiple fields can be specified as a comma separated string, e.g. `"plugin,id"`. The "tags" field can not be used for sorting. (default: "plugin,sort_index,id", where the `sort_index` is an internal sort preference which a plugin can optionally specify.) |

#### *Response Data*

```json
[
  {
    "id": "c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07",
    "alias": "",
    "info": "Synse Temperature Sensor 1",
    "type": "temperature",
    "plugin": "4032ffbe-80db-5aa5-b794-f35c88dff85c",
    "tags": [
      "system/id:c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07",
      "system/type:temperature"
    ]
  },
  {
    "id": "f041883c-cf87-55d7-a978-3d3103836412",
    "alias": "emulator-led",
    "info": "Synse LED",
    "type": "led",
    "plugin": "4032ffbe-80db-5aa5-b794-f35c88dff85c",
    "tags": [
      "system/id:f041883c-cf87-55d7-a978-3d3103836412",
      "system/type:led"
    ]
  }
]
```

The fields of the response are described below:

| Field | Description |
| :---- | :---------- |
| *id* | The globally unique ID for the device. |
| *alias* | A human-readable name for the device. |
| *info* | A human-readable string providing identifying info about a device. |
| *type* | The type of the device, as defined by its plugin. |
| *plugin* | The ID of the plugin which the device is managed by. |
| *tags* | A list of the tags associated with this device. One of the tags will be the `id` tag. |

??? note "HTTP"
    **Request**
    ```
    GET http://localhost:5000/v3/scan
    ```
    
    **Response**
    ```json
    [
      {
        "id": "c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07",
        "alias": "",
        "info": "Synse Temperature Sensor 1",
        "type": "temperature",
        "plugin": "4032ffbe-80db-5aa5-b794-f35c88dff85c",
        "tags": [
          "system/id:c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07",
          "system/type:temperature"
        ]
      },
      {
        "id": "f041883c-cf87-55d7-a978-3d3103836412",
        "alias": "emulator-led",
        "info": "Synse LED",
        "type": "led",
        "plugin": "4032ffbe-80db-5aa5-b794-f35c88dff85c",
        "tags": [
          "system/id:f041883c-cf87-55d7-a978-3d3103836412",
          "system/type:led"
        ]
      }
    ]
    ```

??? note "WebSocket"
    **Request**
    ```json
    {
      "id": 0,
      "event": "request/scan"
    }
    ```
    
    **Response**
    ```json
    {
      "id": 0,
      "event": "response/scan",
      "data": [
        {
          "id": "c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07",
          "alias": "",
          "info": "Synse Temperature Sensor 1",
          "type": "temperature",
          "plugin": "4032ffbe-80db-5aa5-b794-f35c88dff85c",
          "tags": [
            "system/id:c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07",
            "system/type:temperature"
          ]
        },
        {
          "id": "f041883c-cf87-55d7-a978-3d3103836412",
          "alias": "emulator-led",
          "info": "Synse LED",
          "type": "led",
          "plugin": "4032ffbe-80db-5aa5-b794-f35c88dff85c",
          "tags": [
            "system/id:f041883c-cf87-55d7-a978-3d3103836412",
            "system/type:led"
          ]
        }
      ]
    }
    ```

##### Error

The [error response](#errors) can be one of:

* **500** - Catchall processing error
* **400** - Invalid parameter(s)



---

### Tags

| | | |
| --- | --- | --- |
| HTTP      | **GET**      | `/v3/tags` |
| WebSocket | **request**  | `"request/tags"` |
|           | **response** | `"response/tags"` |

List all of the tags currently associated with devices.

This will list the tags in the specified tag namespace. If no tag namespace
is specified (via query parameters), the default tag namespace is used.

By default, this endpoint will omit the `id` tags since they match the
device id enumerated by the [`/scan`](#scan) endpoint. The `id` tags can
be included in the response by setting the `ids` query parameter to `true`.

Multiple tag namespaces can be queried at once by using a comma delimiter
between namespaces in the `ns` query parameter value string, e.g.
`?ns=default,ns1,ns2`.

Tags are sorted alphanumerically.

??? hint "Example"
    ***shell***
    ```shell
    curl http://${server}:5000/v3/tags
    ```
    
    ***python***
    ```python
    from synse import client
    
    api_client = client.HTTPClientV3('localhost')
    resp = api_client.tags()
    
    print(resp.raw)
    ```

#### *Query Parameters*

| Key  | Description |
| :--- | :---------- |
| ns | The tag namespace(s) to use when searching for tags. (default: `default`) |
| ids | A flag which determines whether `id` tags are included in the response. (default: `false`) |

#### *Response Data*

```json
[
  "system/type:airflow",
  "system/type:fan",
  "system/type:humidity",
  "system/type:led",
  "system/type:lock",
  "system/type:pressure",
  "system/type:temperature"
]
```

??? note "HTTP"
    **Request**
    ```
    GET http://localhost:5000/v3/tags
    ```
    
    **Response**
    ```json
    [
      "system/type:airflow",
      "system/type:fan",
      "system/type:humidity",
      "system/type:led",
      "system/type:lock",
      "system/type:pressure",
      "system/type:temperature"
    ]
    ```

??? note "WebSocket"
    **Request**
    ```json
    {
      "id": 0,
      "event": "request/tags"
    }
    ```
    
    **Response**
    ```json
    {
      "id": 0,
      "event": "response/tags",
      "data": [
        "system/type:airflow",
        "system/type:fan",
        "system/type:humidity",
        "system/type:led",
        "system/type:lock",
        "system/type:pressure",
        "system/type:temperature"
      ]
    }
    ```

##### Error

The [error response](#errors) can be one of:

* **500** - Catchall processing error
* **400** - Invalid parameter(s)



---

### Info

| | | |
| --- | --- | --- |
| HTTP      | **GET**      | `/v3/info/<device_id>` |
| WebSocket | **request**  | `"request/info"` |
|           | **response** | `"response/info"` |

Get the full set of metainfo and capabilities for a specified device.

??? hint "Example"
    ***shell***
    ```shell
    curl http://${server}:5000/v3/info/c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07
    ```
    
    ***python***
    ```python
    from synse import client
    
    api_client = client.HTTPClientV3('localhost')
    resp = api_client.info('c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07')
    
    print(resp.raw)
    ```

#### *URI Parameters*

| Parameter | Description |
| :-------- | :---------- |
| *device_id* | The ID of the device to get info for. IDs should be globally unique. |

#### *Response Data*

```json
{
  "timestamp": "2019-01-01T12:00:00Z",
  "id": "c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07",
  "alias": "",
  "type": "temperature",
  "plugin": "4032ffbe-80db-5aa5-b794-f35c88dff85c",
  "info": "Synse Temperature Sensor 1",
  "metadata": {
    "model":"emul8-temp"
  },
  "capabilities": {
    "mode": "rw",
    "write": {
      "actions": []
    }
  },
  "tags": [
    "system/id:c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07",
    "system/type:temperature"
  ],
  "outputs": [
    {
      "name": "temperature",
      "type": "temperature",
      "precision": 2,
      "unit": {
        "name": "celsius",
        "symbol": "C"
      }
    }
  ]
}
```

The fields of the response are described below:

| Field | Description |
| :---- | :---------- |
| *timestamp* | An RFC3339 timestamp describing the time that the device info was gathered. |
| *id* | The globally unique ID for the device. |
| *alias* | A human-readable name for the device. |
| *type* | The device type, as specified by the plugin. |
| *plugin* | The ID of the plugin that manages the device. |
| *info* | A human-readable string providing identifying info about a device. |
| *metadata* | A map of arbitrary values that provide additional data for the device. |
| *capabilities* | Specifies the actions which the device is able to perform (e.g. read, write). See below for more. |
| *tags* | A list of the tags associated with this device. One of the tags will be the 'id' tag which should match the `id` field. |
| *output* | A list of the output types that the device supports. |

###### Capabilities

| Field | Description |
| :---- | :---------- |
| *mode* | A string specifying the device capabilities. This can be "r" (read only), "rw" (read write), "w" (write only). |
| *read* | Any additional information regarding the device reads. This will currently remain empty. |
| *write* | Any additional information regarding device writes. |
| *write.actions* | A list of actions which the device supports for writing. |

###### Outputs

| Field | Description |
| :---- | :---------- |
| *name* | The name of the output type. This can be namespaced. |
| *type* | The type of the output, as defined by the plugin. |
| *precision* | The number of decimal places the value will be rounded to. |
| *scaling_factor* | A scaling factor which will be applied to the raw reading value. |
| *units* | Information for the reading's units of measure. |
| *unit.name* | The complete name of the unit of measure (e.g. "meters per second"). |
| *unit.symbol* | A symbolic representation of the unit of measure (e.g. m/s). |

??? note "HTTP"
    **Request**
    ```
    GET http://localhost:5000/v3/info/c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07
    ```
    
    **Response**
    ```json
    {
      "timestamp": "2019-01-01T12:00:00Z",
      "id": "c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07",
      "alias": "",
      "type": "temperature",
      "plugin": "4032ffbe-80db-5aa5-b794-f35c88dff85c",
      "info": "Synse Temperature Sensor 1",
      "metadata": {
        "model":"emul8-temp"
      },
      "capabilities": {
        "mode": "rw",
        "write": {
          "actions": []
        }
      },
      "tags": [
        "system/id:c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07",
        "system/type:temperature"
      ],
      "outputs": [
        {
          "name": "temperature",
          "type": "temperature",
          "precision": 2,
          "unit": {
            "name": "celsius",
            "symbol": "C"
          }
        }
      ]
    }
    ```

??? note "WebSocket"
    **Request**
    ```json
    {
      "id": 0,
      "event": "request/info",
      "data": {
        "device": "c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07"
      }
    }
    ```
    
    **Response**
    ```json
    {
      "id": 0,
      "event": "response/info",
      "data": {
        "timestamp": "2019-01-01T12:00:00Z",
        "id": "c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07",
        "alias": "",
        "type": "temperature",
        "plugin": "4032ffbe-80db-5aa5-b794-f35c88dff85c",
        "info": "Synse Temperature Sensor 1",
        "metadata": {
          "model":"emul8-temp"
        },
        "capabilities": {
          "mode": "rw",
          "write": {
            "actions": []
          }
        },
        "tags": [
          "system/id:c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07",
          "system/type:temperature"
        ],
        "outputs": [
          {
            "name": "temperature",
            "type": "temperature",
            "precision": 2,
            "unit": {
              "name": "celsius",
              "symbol": "C"
            }
          }
        ]
      }
    }
    ```

##### Error

The [error response](#errors) can be one of:

* **500** - Catchall processing error
* **404** - Device not found



---

### Read

| | | |
| --- | --- | --- |
| HTTP      | **GET**      | `/v3/read` |
| WebSocket | **request**  | `"request/read"` |
|           | **response** | `"response/reading"` |

Read data from devices which match the set of provided tags. 

Passing in the `id` tag here is functionally equivalent to using the [read device](#read-device)
endpoint.

Reading data will be returned for devices which match *all* of the specified tags.
The contents of prior reads is not necessarily indicative of the content of future
reads. That is to say, if a plugin terminates and a read command is issued, the
devices managed by that plugin which would have matched the tags are no longer available
to Synse (until the plugin comes back up), and as such, can not be read from.
When the plugin becomes available again, the devices from that plugin are available
to be read from.

For readability, readings are sorted by a combination of originating plugin, any
plugin-specified sort index on the reading's device, and by device id.

??? hint "Example"
    ***shell***
    ```shell
    curl http://${server}:5000/v3/read
    ```
    
    ***python***
    ```python
    from synse import client
    
    api_client = client.HTTPClientV3('localhost')
    resp = api_client.read()
    
    print(resp.raw)
    ```

#### *Query Parameters*

| Key  | Description |
| :--- | :---------- |
| ns | The default namespace to use for the specified labels. (default: `default`) |
| tags | The [tags](tags.md) to filter devices on. If specifying multiple tags, they should be comma-separated. |

#### *Response Data*

> **Note**: In the examples below, the key-value pairs in the `context` field
> are arbitrary and only serve as an example of possible values.

```json
[
  {
    "device": "1b714cf2-cc56-5c36-9741-fd6a483b5f10",
    "timestamp": "2019-01-01T12:00:00Z",
    "type": "status",
    "device_type": "lock",
    "unit": null,
    "value": "locked",
    "context": {}
  },
  {
    "device": "fef34490-4952-5e92-bf4d-aad169df980e",
    "timestamp": "2019-01-01T12:00:00Z",
    "type": "humidity",
    "device_type": "humidity",
    "unit": {
      "name": "percent humidity",
      "symbol": "%"
    },
    "value": 9,
    "context": {}
  },
  {
    "device": "fef34490-4952-5e92-bf4d-aad169df980e",
    "timestamp": "2019-01-01T12:00:00Z",
    "type": "temperature",
    "device_type": "humidity",
    "unit": {
      "name": "celsius",
      "symbol": "C"
    },
    "value": 72,
    "context": {}
  },
  {
    "device": "69c2e1e2-e658-5d71-8e43-091f68aa6e84",
    "timestamp": "2019-01-01T12:00:00Z",
    "type": "",
    "device_type": "airflow",
    "unit": {
      "name": "millimeters per second",
      "symbol": "mm/s"
    },
    "value": -90,
    "context": {}
  },
  {
    "device": "01976737-085c-5e4c-94bc-a383d3d130fb",
    "timestamp": "2019-01-01T12:00:00Z",
    "type": "state",
    "device_type": "led",
    "unit": null,
    "value": "off",
    "context": {}
  },
  {
    "device": "01976737-085c-5e4c-94bc-a383d3d130fb",
    "timestamp": "2019-01-01T12:00:00Z",
    "type": "color",
    "device_type": "led",
    "unit": null,
    "value": "000000",
    "context": {}
  },
  {
    "device": "494bd3ed-72ec-53e9-ba65-729610516e25",
    "timestamp": "2019-01-01T12:00:00Z",
    "type": "pressure",
    "device_type": "pressure",
    "unit": {
      "name": "pascal",
      "symbol": "Pa"
    },
    "value": -4,
    "context": {}
  },
  {
    "device": "c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07",
    "timestamp": "2019-01-01T12:00:00Z",
    "type": "temperature",
    "device_type": "temperature",
    "unit": {
      "name": "celsius",
      "symbol": "C"
    },
    "value": 6,
    "context": {}
  }
]
```

The `context` field of a reading is optional and allows the plugin to specify additional
context for the reading. This can be useful in modeling the data for various kinds of
plugins/read behavior.

As an example, a plugin could provide additional data for a reading such as which host
the data originated from, a sample rate, etc (for something like sFlow). Since the context
can contain arbitrary data, it can also be used to label particular readings making them
easier to parse upstream. An example of this would be associating multiple lock devices
with their physical location.

The fields of the response are described below:

| Field | Description |
| :---- | :---------- |
| *device* | The ID of the device which the reading originated from. |
| *device_type* | The type of the device. |
| *type* | The type of the reading. |
| *value* | The value of the reading. |
| *timestamp* | An RFC3339 timestamp describing the time at which the reading was taken. |
| *unit* | The unit of measure for the reading. If there is no unit, this will be `null`. |
| *context* | A mapping of arbitrary values to provide additional context for the reading. |

??? note "HTTP"
    **Request**
    ```
    GET http://localhost:5000/v3/read
    ```
    
    **Response**
    ```json
    [
      {
        "device": "1b714cf2-cc56-5c36-9741-fd6a483b5f10",
        "timestamp": "2019-01-01T12:00:00Z",
        "type": "status",
        "device_type": "lock",
        "unit": null,
        "value": "locked",
        "context": {}
      },
      {
        "device": "fef34490-4952-5e92-bf4d-aad169df980e",
        "timestamp": "2019-01-01T12:00:00Z",
        "type": "humidity",
        "device_type": "humidity",
        "unit": {
          "name": "percent humidity",
          "symbol": "%"
        },
        "value": 9,
        "context": {}
      }
    ]
    ```

??? note "WebSocket"
    **Request**
    ```json
    {
      "id": 0,
      "event": "request/read"
    }
    ```
    
    **Response**
    ```json
    {
      "id": 0,
      "event": "response/reading",
      "data": [
        {
          "device": "1b714cf2-cc56-5c36-9741-fd6a483b5f10",
          "timestamp": "2019-01-01T12:00:00Z",
          "type": "status",
          "device_type": "lock",
          "unit": null,
          "value": "locked",
          "context": {}
        },
        {
          "device": "fef34490-4952-5e92-bf4d-aad169df980e",
          "timestamp": "2019-01-01T12:00:00Z",
          "type": "humidity",
          "device_type": "humidity",
          "unit": {
            "name": "percent humidity",
            "symbol": "%"
          },
          "value": 9,
          "context": {}
        }
      ]
    }
    ```

##### Error

The [error response](#errors) can be one of:

* **500** - Catchall processing error
* **400** - Invalid parameter(s)



---

### Read Device

| | | |
| --- | --- | --- |
| HTTP      | **GET**      | `/v3/read/<device_id>` |
| WebSocket | **request**  | `"request/read_device"` |
|           | **response** | `"response/reading"` |

Read from the specified device. This endpoint is effectively the same as using the [`/read`](#read)
endpoint where the label matches the [device id tag](tags.md#auto-generated), e.g.
`http://HOST:5000/v3/read?tags=id:b33f7ac0`.

??? hint "Example"
    ***shell***
    ```shell
    curl http://${server}:5000/v3/read/c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07
    ```
    
    ***python***
    ```python
    from synse import client
    
    api_client = client.HTTPClientV3('localhost')
    resp = api_client.read('c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07')
    
    print(resp.raw)
    ```

#### *URI Parameters*

| Parameter | Required | Description |
| :-------- | :------- | :---------- |
| *device_id* | yes | The ID of the device to read. [Device IDs](ids.md) are globally unique. |

#### *Response Data*

The response schema for the `/read/{device_id}` endpoint is the same as the response schema
for the [`/read`](#read) endpoint.

> **Note**: In the examples below, the key-value pairs in the `context` field
> are arbitrary and only serve as an example of possible values.

```json
[
  {
    "device": "c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07",
    "timestamp": "2019-01-01T12:00:00Z",
    "type": "temperature",
    "device_type": "temperature",
    "unit": {
      "name": "celsius",
      "symbol": "C"
    },
    "value": 85,
    "context": {}
  }
]
```

The fields of the response are described below:

| Field | Description |
| :---- | :---------- |
| *device* | The ID of the device which the reading originated from. |
| *device_type* | The type of the device. |
| *type* | The type of the reading. |
| *value* | The value of the reading. |
| *timestamp* | An RFC3339 timestamp describing the time at which the reading was taken. |
| *unit* | The unit of measure for the reading. If there is no unit, this will be `null`. |
| *context* | A mapping of arbitrary values to provide additional context for the reading. |

??? note "HTTP"
    **Request**
    ```
    GET http://localhost:5000/v3/read/c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07
    ```
    
    **Response**
    ```json
    [
      {
        "device": "c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07",
        "timestamp": "2019-01-01T12:00:00Z",
        "type": "temperature",
        "device_type": "temperature",
        "unit": {
          "name": "celsius",
          "symbol": "C"
        },
        "value": 85,
        "context": {}
      }
    ]
    ```

??? note "WebSocket"
    **Request**
    ```json
    {
      "id": 0,
      "event": "request/read_device",
      "data": {
        "device": "c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07"
      }
    }
    ```
    
    **Response**
    ```json
    {
      "id": 0,
      "event": "response/reading",
      "data": [
        {
          "device": "c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07",
          "timestamp": "2019-01-01T12:00:00Z",
          "type": "temperature",
          "device_type": "temperature",
          "unit": {
            "name": "celsius",
            "symbol": "C"
          },
          "value": 85,
          "context": {}
        }
      ]
    }
    ```

##### Error

The [error response](#errors) can be one of:

* **500** - Catchall processing error
* **404** - Device not found



---

### Read Cache

| | | |
| --- | --- | --- |
| HTTP      | **GET**      | `/v3/readcache` |
| WebSocket | **request**  | `"request/read_cache"` |
|           | **response** | `"response/reading"` |

Stream reading data from the registered plugins.

All plugins have the capability of caching their readings locally in order to maintain
a higher resolution of state beyond the poll frequency which Synse Server may request at.
This is particularly useful for push-based plugins, where we would lose the pushed
reading if it were not cached.

At the plugin level, caching read data can be enabled, but is disabled by default. Even if
disabled, this route will still return data for every device that supports reading on each
of the configured plugins. When read caching is disabled, this will just return a dump of
the current state for all readings which is maintained by the plugin.

??? hint "Example"
    ***shell***
    ```shell
    curl http://${server}:5000/v3/readcache
    ```
    
    ***python***
    ```python
    from synse import client
    
    api_client = client.HTTPClientV3('localhost')
    resp = api_client.read_cache()
    
    print(resp.raw)
    ```

#### *Query Parameters*

| Key  | Description |
| :--- | :---------- |
| start | An RFC3339 formatted timestamp which specifies a starting bound on the cache data to return. If no timestamp is specified, there will not be a starting bound. |
| end | An RFC3339 formatted timestamp which specifies an ending bound on the cache data to return. If no timestamp is specified, there will not be an ending bound. |

#### *Response Data*

The response schema for the `/readcache` endpoint is the same as the response schema
for the [`/read`](#read) endpoint.

Unlike the [`/read`](#read) and [`/read/{device_id}`](#read-device) endpoints, the response for this endpoint is
streamed JSON. One block of the streamed JSON will appear as follows:

> **Note**: In the examples below, the key-value pairs in the `context` field
> are arbitrary and only serve as an example of possible values.

```json
{
  "device": "c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07",
  "timestamp": "2019-01-01T12:00:00Z",
  "type": "temperature",
  "device_type": "temperature",
  "unit": {
    "name": "celsius",
    "symbol": "C"
  },
  "value": 85,
  "context": {}
}
```

The fields of the response are described below:

| Field | Description |
| :---- | :---------- |
| *device* | The ID of the device which the reading originated from. |
| *device_type* | The type of the device. |
| *type* | The type of the reading. |
| *value* | The value of the reading. |
| *timestamp* | An RFC3339 timestamp describing the time at which the reading was taken. |
| *unit* | The unit of measure for the reading. If there is no unit, this will be `null`. |
| *context* | A mapping of arbitrary values to provide additional context for the reading. |

??? note "HTTP"
    **Request**
    ```
    GET http://localhost:5000/v3/readcache
    ```
    
    **Response**
    ```json
    [
      {
        "device": "c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07",
        "timestamp": "2019-01-01T12:00:00Z",
        "type": "temperature",
        "device_type": "temperature",
        "unit": {
          "name": "celsius",
          "symbol": "C"
        },
        "value": 85,
        "context": {}
      }
    ]
    ```

??? note "WebSocket"
    **Request**
    ```json
    {
      "id": 0,
      "event": "request/read_cache"
    }
    ```
    
    **Response**
    ```json
    {
      "id": 0,
      "event": "response/reading",
      "data": [
        {
          "device": "c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07",
          "timestamp": "2019-01-01T12:00:00Z",
          "type": "temperature",
          "device_type": "temperature",
          "unit": {
            "name": "celsius",
            "symbol": "C"
          },
          "value": 85,
          "context": {}
        }
      ]
    }
    ```

##### Error

The [error response](#errors) can be one of:

* **500** - Catchall processing error
* **400** - Invalid query parameters



---

### Write (Asynchronous)

| | | | |
| --- | --- | --- | --- |
| HTTP      | **POST**     | `/v3/write/<device_id>` | `#!json {"action": "<action>", "data": "<data>"}` |
| WebSocket | **request**  | `"request/write_async"` | |
|           | **response** | `"response/write_async"` |

Write data to a device, in an asynchronous manner.

This endpoint allows writes to be issued to Synse Server, where they will be processed
asynchronously and their status can be polled at some later time. An alternative is to
use the [synchronous write](#write-synchronous) endpoint.

This endpoint will return a transaction ID associated with each write. For simplicity
and to reduce partial state failure cases, Synse only supports writing to a single device
per request, however multiple values can be written to the device if desired. When specifying
multiple write operations for a device, they are processed in the order which they are
provided in the POSTed JSON body.

Not all devices support writing. The write capabilities of a device are defined at the plugin
level and are exposed via the [`/info`](#info) endpoint. If a write is issued to a device which
does not support writing, an error is returned.

??? hint "Example"
    ***shell***
    ```shell
    curl \
      -H "Content-Type: application/json" \
      -X POST \
      -d '{"action": "color", "data": "f38ac2"}' \
      http://${server}:5000/v3/write/4032ffbe-80db-5aa5-b794-f35c88dff85c
    ```
    
    ***python***
    ```python
    from synse import client
    
    api_client = client.HTTPClientV3('localhost')
    resp = api_client.write_async(
      '4032ffbe-80db-5aa5-b794-f35c88dff85c',
      {
        'action': 'color',
        'data': 'f38ac2',
      },
    )
    
    print(resp.raw)
    ```

#### *URI Parameters*

| Parameter | Required | Description |
| :-------- | :------- | :---------- |
| *device_id* | yes | The ID of the device that is being written to. |

#### *POST Body*

```json
[
  {
    "transaction": "56a32eba-1aa6-4868-84ee-fe01af8b2e6d",
    "action": "color",
    "data": "f38ac2"
  }
]
```

The fields of the response are described below:

| Field | Required | Description |
| :---- | :------- | :---------- |
| *transaction* | no | A user-defined transaction ID for the write. If this conflicts with an existing transaction ID, an error is returned. If this is not specified, a transaction ID will be automatically generated for the write action. |
| *action* | yes | The action that the device will perform. This is set at the plugin level and exposed in the [`/info`](#info) endpoint. |
| *data* | sometimes | Any data that an action may require. Not all actions require data. This is plugin-defined. |


To batch multiple writes to a device, the additional writes can be appended to the
POST body JSON list. The writes will be processed in the order which they are provided
in this list. In the example below, "color" will be processed first, then "state".

```json
[
  {
    "action": "color",
    "data": "f38ac2"
  },
  {
    "action": "state",
    "data": "blink"
  }
]
```

#### *Response Data*

```json
[
  {
    "id": "2b717ced-58ff-43dc-ab6f-d4c0c6008ebb",
    "device": "f041883c-cf87-55d7-a978-3d3103836412",
    "context": {
      "action": "color",
      "data": "f38ac2",
      "transaction": ""
    },
    "timeout": "30s"
  },
  {
    "id": "ab42719f-1aab-920d-b37a-0092ba631e2e",
    "device": "f041883c-cf87-55d7-a978-3d3103836412",
    "context": {
      "action": "state",
      "data": "blink",
      "transaction": ""
    },
    "timeout": "30s"
  }
]
```

The fields of the response are described below:

| Field | Description |
| :---- | :---------- |
| *context* | The data written to the device. This is provided as context info to help identify the write action. |
| *device* | The GUID of the device being written to. |
| *transaction* | The ID for the device write transaction. This can be passed to the [`/transaction`](#transaction) endpoint to get the status of the write action. |
| *timeout* | The timeout for the write transaction, after which it will be cancelled. This is effectively the maximum wait time for the transaction to resolve. This is defined by the plugin. |

??? note "HTTP"
    **Request**
    ```
    POST http://localhost:5000/v3/write/f041883c-cf87-55d7-a978-3d3103836412
         [{"action": "color", "data": "f38ac2"}, {"action": "state", "data": "blink"}]
    ```
    
    **Response**
    ```json
    [
      {
        "id": "2b717ced-58ff-43dc-ab6f-d4c0c6008ebb",
        "device": "f041883c-cf87-55d7-a978-3d3103836412",
        "context": {
          "action": "color",
          "data": "f38ac2",
          "transaction": ""
        },
        "timeout": "30s"
      },
      {
        "id": "ab42719f-1aab-920d-b37a-0092ba631e2e",
        "device": "f041883c-cf87-55d7-a978-3d3103836412",
        "context": {
          "action": "state",
          "data": "blink",
          "transaction": ""
        },
        "timeout": "30s"
      }
    ]
    ```

??? note "WebSocket"
    **Request**
    ```json
    {
      "id": 0,
      "event": "request/write_async",
      "data": {
        "device": "f041883c-cf87-55d7-a978-3d3103836412",
        "payload": [
          {
            "action": "color",
            "data": "f38ac2"
          },
          {
            "action": "state", 
            "data": "blink"
          }
        ]
      }
    }
    ```
    
    **Response**
    ```json
    {
      "id": 0,
      "event": "response/write_async",
      "data": [
        {
          "id": "2b717ced-58ff-43dc-ab6f-d4c0c6008ebb",
          "device": "f041883c-cf87-55d7-a978-3d3103836412",
          "context": {
            "action": "color",
            "data": "f38ac2",
            "transaction": ""
          },
          "timeout": "30s"
        },
        {
          "id": "ab42719f-1aab-920d-b37a-0092ba631e2e",
          "device": "f041883c-cf87-55d7-a978-3d3103836412",
          "context": {
            "action": "state",
            "data": "blink",
            "transaction": ""
          },
          "timeout": "30s"
        }
      ]
    }
    ```

##### Error

The [error response](#errors) can be one of:

* **500** - Catchall processing error
* **400** - Invalid JSON provided
* **404** - Device not found
* **405** - Device does not support writing



---

### Write (Synchronous)

| | | | |
| --- | --- | --- | --- |
| HTTP      | **POST**     | `/v3/write/wait/<device_id>` | `#!json {"action": "<action>", "data": "<data>"}` |
| WebSocket | **request**  | `"request/write_sync"` | |
|           | **response** | `"response/write_sync"` |

Write data to a device, waiting for the write to complete.

This endpoint is the synchronous version of the [asynchronous write](#write-asynchronous) endpoint.
In some cases, it may be more convenient to just wait for a response instead of continually
polling Synse Server to check whether the transaction completed. For these cases, this endpoint
can be used.

Note that the length of time it takes for a write to complete depends on the device and its
plugin, so there is likely to be a variance in response times when waiting. It is up to the
user to define a sane timeout such that the request does not prematurely terminate.

??? hint "Example"
    ***shell***
    ```shell
    curl \
      -H "Content-Type: application/json" \
      -X POST \
      -d '{"action": "color", "data": "f38ac2"}' \
      http://${server}:5000/v3/write/wait/4032ffbe-80db-5aa5-b794-f35c88dff85c
    ```
    
    ***python***
    ```python
    from synse import client
    
    api_client = client.HTTPClientV3('localhost')
    resp = api_client.write_sync(
      '4032ffbe-80db-5aa5-b794-f35c88dff85c',
      {
        'action': 'color',
        'data': 'f38ac2',
      },
    )
    
    print(resp.raw)
    ```

#### *URI Parameters*

| Parameter | Required | Description |
| :-------- | :------- | :---------- |
| *device_id* | yes | The ID of the device that is being written to. |

#### *POST Body*
```json
[
  {
    "transaction": "56a32eba-1aa6-4868-84ee-fe01af8b2e6d",
    "action": "color",
    "data": "f38ac2"
  }
]
```

The fields of the response are described below:

| Field | Required | Description |
| :---- | :------- | :---------- |
| *device* | yes | The ID of the device being written to. |
| *transaction* | no | A user-defined transaction ID for the write. If this conflicts with an existing transaction ID, an error is returned. If this is not specified, a transaction ID will be automatically generated for the write action. |
| *action* | yes | The action that the device will perform. This is set at the plugin level and exposed in the [`/info`](#info) endpoint. |
| *data* | sometimes | Any data that an action may require. Not all actions require data. This is plugin-defined. |


To batch multiple writes to a device, the additional writes can be appended to the
POST body JSON list. The writes will be processed in the order which they are provided
in this list. In the example below, "color" will be processed first, then "state".

```json
[
  {
    "action": "color",
    "data": "f38ac2"
  },
  {
    "action": "state",
    "data": "blink"
  }
]
```

#### *Response Data*

```json
[
  {
    "id": "ea80f074-bc80-4fdd-b842-8392514bd19b",
    "created": "2019-01-01T12:00:00Z",
    "updated": "2019-01-01T12:00:00Z",
    "timeout": "30s",
    "status": "DONE",
    "context": {
      "action": "color",
      "data": "f38ac2",
      "transaction": ""
    },
    "message": "",
    "device": "f041883c-cf87-55d7-a978-3d3103836412"
  },
  {
    "id": "56a32eba-1aa6-4868-84ee-fe01af8b2e6d",
    "created": "2019-01-01T12:00:00Z",
    "updated": "2019-01-01T12:00:00Z",
    "timeout": "30s",
    "status": "DONE",
    "context": {
      "action": "state",
      "data": "blink",
      "transaction": ""
    },
    "message": "",
    "device": "f041883c-cf87-55d7-a978-3d3103836412"
  }
]
```

The response for a synchronous write has the same scheme as the [`/transaction`](#transaction) response,
albeit in a list. Some of these fields will not matter to the caller of the synchronous write endpoint,
such as the transaction `id`. 

It is up to the user to iterate though the response and ensure that each individual write completed
successfully. While this endpoint will fail in cases where the plugin is not reachable, the data is
invalid, etc., it will not fail if a write fails to execute properly.

??? note "HTTP"
    **Request**
    ```
    POST http://localhost:5000/v3/write/wait/f041883c-cf87-55d7-a978-3d3103836412
         [{"action": "color", "data": "f38ac2"}, {"action": "state", "data": "blink"}]
    ```
    
    **Response**
    ```json
    [
      {
        "id": "ea80f074-bc80-4fdd-b842-8392514bd19b",
        "created": "2019-01-01T12:00:00Z",
        "updated": "2019-01-01T12:00:00Z",
        "timeout": "30s",
        "status": "DONE",
        "context": {
          "action": "color",
          "data": "f38ac2",
          "transaction": ""
        },
        "message": "",
        "device": "f041883c-cf87-55d7-a978-3d3103836412"
      },
      {
        "id": "56a32eba-1aa6-4868-84ee-fe01af8b2e6d",
        "created": "2019-01-01T12:00:00Z",
        "updated": "2019-01-01T12:00:00Z",
        "timeout": "30s",
        "status": "DONE",
        "context": {
          "action": "state",
          "data": "blink",
          "transaction": ""
        },
        "message": "",
        "device": "f041883c-cf87-55d7-a978-3d3103836412"
      }
    ]
    ```

??? note "WebSocket"
    **Request**
    ```json
    {
      "id": 0,
      "event": "request/write_sync",
      "data": {
        "device": "f041883c-cf87-55d7-a978-3d3103836412",
        "payload": [
          {
            "action": "color",
            "data": "f38ac2"
          },
          {
            "action": "state", 
            "data": "blink"
          }
        ]
      }
    }
    ```
    
    **Response**
    ```json
    {
      "id": 0,
      "event": "response/write_sync",
      "data": [
        {
          "id": "ea80f074-bc80-4fdd-b842-8392514bd19b",
          "created": "2019-01-01T12:00:00Z",
          "updated": "2019-01-01T12:00:00Z",
          "timeout": "30s",
          "status": "DONE",
          "context": {
            "action": "color",
            "data": "f38ac2",
            "transaction": ""
          },
          "message": "",
          "device": "f041883c-cf87-55d7-a978-3d3103836412"
        },
        {
          "id": "56a32eba-1aa6-4868-84ee-fe01af8b2e6d",
          "created": "2019-01-01T12:00:00Z",
          "updated": "2019-01-01T12:00:00Z",
          "timeout": "30s",
          "status": "DONE",
          "context": {
            "action": "state",
            "data": "blink",
            "transaction": ""
          },
          "message": "",
          "device": "f041883c-cf87-55d7-a978-3d3103836412"
        }
      ]
    }
    ```

##### Error

The [error response](#errors) can be one of:

* **500** - Catchall processing error
* **400** - Invalid JSON provided
* **404** - Device not found
* **405** - Device does not support writing



---

### Transaction

| | | |
| --- | --- | --- |
| HTTP      | **GET**      | `/v3/transaction/<transaction_id>` |
| WebSocket | **request**  | `"request/transaction"` |
|           | **response** | `"response/transaction"` |

Check the state and status of a write transaction.

If no *transaction_id* is given, a sorted list of all cached transaction IDs is returned. The
length of time that a transaction is cached is configurable (see the Synse Server [configuration](server.md#configuration)).

If the provided transaction ID does not exist, an error is returned.

??? hint "Example"
    ***shell***
    ```shell
    curl http://${server}:5000/v3/transaction/2b717ced-58ff-43dc-ab6f-d4c0c6008ebb
    ```
    
    ***python***
    ```python
    from synse import client
    
    api_client = client.HTTPClientV3('localhost')
    resp = api_client.transaction('2b717ced-58ff-43dc-ab6f-d4c0c6008ebb')
    
    print(resp.raw)
    ```

#### *URI Parameters*

| Parameter | Required | Description |
| :-------- | :------- | :---------- |
| *transaction_id* | no | The ID of the write transaction to get the status of. Transaction IDs are provided from an [asynchronous write](#write-asynchronous) response. |


#### *Response Data*

```json
{
  "id": "2b717ced-58ff-43dc-ab6f-d4c0c6008ebb",
  "created": "2019-01-01T12:00:00Z",
  "updated": "2019-01-01T12:00:00Z",
  "timeout": "30s",
  "status": "DONE",
  "context": {
    "action": "color",
    "data": "f38ac2",
    "transaction": ""
  },
  "message": "",
  "device": "f041883c-cf87-55d7-a978-3d3103836412"
}
```

The fields of the response are described below:

| Field | Description |
| :---- | :---------- |
| *id* | The ID of the transaction. This is generated and assigned by the plugin being written to. |
| *timeout* | A string representing the timeout for the write transaction after which it will be cancelled. This is effectively the maximum wait time for the transaction to resolve. |
| *device* | The GUID of the device being written to. |
| *context* | The POSTed write data for the given write transaction. |
| *status* | The current status of the transaction. (`pending`, `writing`, `done`, `error`) |
| *created* | The time at which the transaction was created. This timestamp is generated by the plugin. |
| *updated* | The last time the transaction state *or* status was updated. Once the transaction reaches a `done` status or `error` state, no further updates will occur. |
| *message* | Any context information relating to a transaction's error state. If there is no error, this will be an empty string. |

??? note "HTTP"
    **Request**
    ```
    GET http://localhost:5000/v3/transaction/2b717ced-58ff-43dc-ab6f-d4c0c6008ebb
    ```
    
    **Response**
    ```json
    {
      "id": "2b717ced-58ff-43dc-ab6f-d4c0c6008ebb",
      "created": "2019-01-01T12:00:00Z",
      "updated": "2019-01-01T12:00:00Z",
      "timeout": "30s",
      "status": "DONE",
      "context": {
        "action": "color",
        "data": "f38ac2",
        "transaction": ""
      },
      "message": "",
      "device": "f041883c-cf87-55d7-a978-3d3103836412"
    }
    ```

??? note "WebSocket"
    **Request**
    ```json
    {
      "id": 0,
      "event": "request/transaction",
      "data": {
        "transaction": "2b717ced-58ff-43dc-ab6f-d4c0c6008ebb"
      }
    }
    ```
    
    **Response**
    ```json
    {
      "id": 0,
      "event": "response/transaction",
      "data": {
        "id": "2b717ced-58ff-43dc-ab6f-d4c0c6008ebb",
        "created": "2019-01-01T12:00:00Z",
        "updated": "2019-01-01T12:00:00Z",
        "timeout": "30s",
        "status": "DONE",
        "context": {
          "action": "color",
          "data": "f38ac2",
          "transaction": ""
        },
        "message": "",
        "device": "f041883c-cf87-55d7-a978-3d3103836412"
      }
    }
    ```

##### Error

The [error response](#errors) can be one of:

* **500** - Catchall processing error
* **404** - Transaction not found

#### *Status*

Transaction can have one of four statuses:

| Status | Description |
| :----- | :---------- |
| *pending* | The write was received and queued but has not yet been processed. |
| *writing* | The write has been taken off the queue and is being processed. |
| *done* | The write has been processed and completed successfully. (terminal state) |
| *error* | The write failed for any reason. (terminal state) |



---

### Transactions

| | | |
| --- | --- | --- |
| HTTP      | **GET**      | `/v3/transaction` |
| WebSocket | **request**  | `"request/transaction"` |
|           | **response** | `"response/transaction"` |

Check the state and status of a write transaction.

If no *transaction_id* is given, a sorted list of all cached transaction IDs is returned. The
length of time that a transaction is cached is configurable (see the Synse Server [configuration](server.md#configuration)).

If the provided transaction ID does not exist, an error is returned.

??? hint "Example"
    ***shell***
    ```shell
    curl http://${server}:5000/v3/transaction
    ```
    
    ***python***
    ```python
    from synse import client
    
    api_client = client.HTTPClientV3('localhost')
    resp = api_client.transactions()
    
    print(resp.raw)
    ```

#### *URI Parameters*

| Parameter | Required | Description |
| :-------- | :------- | :---------- |
| *transaction_id* | no | The ID of the write transaction to get the status of. Transaction IDs are provided from an [asynchronous write](#write-asynchronous) response. |


#### *Response Data*

```json
[
  "2b717ced-58ff-43dc-ab6f-d4c0c6008ebb",
  "ea80f074-bc80-4fdd-b842-8392514bd19b"
]
```

??? note "HTTP"
    **Request**
    ```
    GET http://localhost:5000/v3/transaction
    ```
    
    **Response**
    ```json
    [
      "2b717ced-58ff-43dc-ab6f-d4c0c6008ebb",
      "ea80f074-bc80-4fdd-b842-8392514bd19b"
    ]
    ```

??? note "WebSocket"
    **Request**
    ```json
    {
      "id": 0,
      "event": "request/transaction"
    }
    ```
    
    **Response**
    ```json
    {
      "id": 0,
      "event": "response/transaction",
      "data": [
        "2b717ced-58ff-43dc-ab6f-d4c0c6008ebb",
        "ea80f074-bc80-4fdd-b842-8392514bd19b"
      ]
    }
    ```

##### Error

The [error response](#errors) can be one of:

* **500** - Catchall processing error
* **404** - Transaction not found

#### *Status*
Transaction can have one of four statuses:

| Status | Description |
| :----- | :---------- |
| *pending* | The write was received and queued but has not yet been processed. |
| *writing* | The write has been taken off the queue and is being processed. |
| *done* | The write has been processed and completed successfully. (terminal state) |
| *error* | The write failed for any reason. (terminal state) |


---

### Device

| | | | |
| --- | --- | --- | --- |
| HTTP | **GET**  | `/v3/device/<device_id>` | |
|      | **POST** | `/v3/device/<device_id>` | `#!json {"action": "<action>", "data": "<data>"}` |
| WebSocket | -- | not supported | |

Read and write to a device.

This endpoint allows read and write access to a device through a single URL,
allowing for FQDN devices. A device can be read via `GET` and written to via `POST`.
The underlying implementations for read and write are the same as the [`/read/{device}`](#read-device)
and [`/write/wait/{device}`](#write-synchronous) requests, respectively.

??? hint "Example"
    ***shell***
    ```shell
    # read from the device
    curl http://${server}:5000/v3/device/4032ffbe-80db-5aa5-b794-f35c88dff85c
    
    # write to the device
    curl \
      -H "Content-Type: application/json" \
      -X POST \
      -d '{"action": "color", "data": "f38ac2"}' \
      http://${server}:5000/v3/device/4032ffbe-80db-5aa5-b794-f35c88dff85c
    ```
    
    ***python***
    ```python
    from synse import client
    
    api_client = client.HTTPClientV3('localhost')
    
    # read from the device
    resp = api_client.read('4032ffbe-80db-5aa5-b794-f35c88dff85c')
    print(resp.raw)
    
    # write to the device
    resp = api_client.write_async(
      '4032ffbe-80db-5aa5-b794-f35c88dff85c',
      {
        'action': 'color',
        'data': 'f38ac2',
      },
    )
    print(resp.raw)
    ```

#### *URI Parameters*

| Parameter | Description |
| :-------- | :---------- |
| *device_id* | The ID of the device that is being read from/written to. |

#### *POST Body*
```json
[
  {
    "transaction": "56a32eba-1aa6-4868-84ee-fe01af8b2e6d",
    "action": "color",
    "data": "f38ac2"
  }
]
```

The fields of the response are described below:

| Field | Required | Description |
| :---- | :------- | :---------- |
| *device* | yes | The ID of the device being written to. |
| *transaction* | no | A user-defined transaction ID for the write. If this conflicts with an existing transaction ID, an error is returned. If this is not specified, a transaction ID will be automatically generated for the write action. |
| *action* | yes | The action that the device will perform. This is set at the plugin level and exposed in the [`/info`](#info) endpoint. |
| *data* | sometimes | Any data that an action may require. Not all actions require data. This is plugin-defined. |


#### *Response Data*

**`GET`**
(See: [`/read`](#read-device))

> **Note**: In the examples below, the key-value pairs in the `context` field
> are arbitrary and only serve as an example of possible values.

```json
[
  {
    "device": "c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07",
    "timestamp": "2019-01-01T12:00:00Z",
    "type": "temperature",
    "device_type": "temperature",
    "unit": {
      "name": "celsius",
      "symbol": "C"
    },
    "value": 85,
    "context": {}
  }
]
```

The fields of the response are described below:

| Field | Description |
| :---- | :---------- |
| *device* | The ID of the device which the reading originated from. |
| *device_type* | The type of the device. |
| *type* | The type of the reading. |
| *value* | The value of the reading. |
| *timestamp* | An RFC3339 timestamp describing the time at which the reading was taken. |
| *unit* | The unit of measure for the reading. If there is no unit, this will be `null`. |
| *context* | A mapping of arbitrary values to provide additional context for the reading. |

??? note "HTTP"
    **Request**
    ```
    GET http://localhost:5000/v3/read/c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07
    ```
    
    **Response**
    ```json
    [
      {
        "device": "c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07",
        "timestamp": "2019-01-01T12:00:00Z",
        "type": "temperature",
        "device_type": "temperature",
        "unit": {
          "name": "celsius",
          "symbol": "C"
        },
        "value": 85,
        "context": {}
      }
    ]
    ```

??? note "WebSocket"
    Not supported - [read device](#read-device) is equivalent


**`POST`**
(See: [`/write`](#write-synchronous))

```json
[
  {
    "id": "2b717ced-58ff-43dc-ab6f-d4c0c6008ebb",
    "created": "2019-01-01T12:00:00Z",
    "updated": "2019-01-01T12:00:00Z",
    "timeout": "30s",
    "status": "DONE",
    "context": {
      "action": "color",
      "data": "f38ac2",
      "transaction": ""
    },
    "message": "",
    "device": "f041883c-cf87-55d7-a978-3d3103836412"
  }
]
```

The fields of the response are described below:

| Field | Description |
| :---- | :---------- |
| *id* | The ID of the transaction. This is generated and assigned by the plugin being written to. |
| *timeout* | A string representing the timeout for the write transaction after which it will be cancelled. This is effectively the maximum wait time for the transaction to resolve. |
| *device* | The GUID of the device being written to. |
| *context* | The POSTed write data for the given write transaction. |
| *status* | The current status of the transaction. (`pending`, `writing`, `done`, `error`) |
| *created* | The time at which the transaction was created. This timestamp is generated by the plugin. |
| *updated* | The last time the transaction state *or* status was updated. Once the transaction reaches a `done` status or `error` state, no further updates will occur. |
| *message* | Any context information relating to a transaction's error state. If there is no error, this will be an empty string. |

??? note "HTTP"
    **Request**
    ```
    POST http://localhost:5000/v3/write/c2f6f762-fa30-5f0a-ba6c-f52d8deb3c07
         [{"action": "color", "data": "f38ac2"}, {"action": "state", "data": "blink"}]
    ```
    
    **Response**
    ```json
    [
      {
        "id": "ea80f074-bc80-4fdd-b842-8392514bd19b",
        "created": "2019-01-01T12:00:00Z",
        "updated": "2019-01-01T12:00:00Z",
        "timeout": "30s",
        "status": "DONE",
        "context": {
          "action": "color",
          "data": "f38ac2",
          "transaction": ""
        },
        "message": "",
        "device": "f041883c-cf87-55d7-a978-3d3103836412"
      },
      {
        "id": "56a32eba-1aa6-4868-84ee-fe01af8b2e6d",
        "created": "2019-01-01T12:00:00Z",
        "updated": "2019-01-01T12:00:00Z",
        "timeout": "30s",
        "status": "DONE",
        "context": {
          "action": "state",
          "data": "blink",
          "transaction": ""
        },
        "message": "",
        "device": "f041883c-cf87-55d7-a978-3d3103836412"
      }
    ]
    ```

??? note "WebSocket"
    Not supported - [write sync](#write-synchronous) is equivalent

##### Error

The [error response](#errors) can be one of:

* **500** - Catchall processing error
* **400** - Invalid JSON provided/Invalid parameters
* **404** - Device not found
* **405** - Device does not support reading/writing
