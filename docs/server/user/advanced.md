---
hero: Advanced Usage 
---

This section covers some of the more advanced features, components, and usage
of Synse Server.

## Health Check / Liveness Probe

When creating a deployment with Docker Compose, Kubernetes, etc., you can set a
"health check" (or liveness and readiness probe) for the service. To illustrate,
below are simple examples for defining a health check in a compose file and
Kubernetes manifest.

### Compose File

```yaml
# compose.yml

version: '3.4'
services:
  synse-server:
    image: vaporio/synse-server
    ports:
    - '5000:5000'
    healthcheck:
      test: ['CMD', 'curl', '-f', 'http://localhost:5000/test']
      interval: 1m
      timeout: 5s
      retries: 3
      start_period: 5s  
```

!!! note
    The `healthcheck` option is supported in compose file versions 2.1+, but the
    `start_period` option is only supported in compose file versions 3.4+. For more
    information, see the [healthcheck reference](https://docs.docker.com/compose/compose-file/#healthcheck).


This can be run with `docker-compose -f compose.yml up -d`, after which you can check the
status and should see a health indicator:

```console
$ docker ps
CONTAINER ID        IMAGE                            COMMAND                  CREATED              STATUS                        PORTS                    NAMES
bd81be6222ac        vaporio/synse-server:latest      "/usr/bin/tini -- sy…"   About a minute ago   Up About a minute (healthy)   0.0.0.0:5000->5000/tcp   synse-server
```

### Kubernetes

Kubernetes has built-in support for defining [readiness and liveness probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)
for your deployed Pods. For an example Synse deployment using Kubernetes, see the [Deploying](deploying.md#deploying-with-kubernetes)
page. From that example, all you would need to do is add in a liveness/readiness
probe definition, e.g.

```yaml
livenessProbe:
  initialDelaySeconds: 30
  periodSeconds: 5
  httpGet:
    path: /test
    port: http
readinessProbe:
  initialDelaySeconds: 5
  httpGet:
    path: /test
    port: http
```


## Plugin Service Discovery

Synse supports dynamic discovery of plugins. This adds flexibility as you do not need to
explicitly define a reference to a plugin that may change (such as an IP address), and 
reduces the amount of configuration for deployments with many plugins.

### via Kubernetes

Currently, the only supported mode of plugin discovery is through [Kubernetes service endpoints](https://kubernetes.io/docs/concepts/services-networking/service/).
In short, this means that for a plugin deployment with a Service specified,
labels can be set on that Service to identify it to Synse Server as a plugin. 

This is useful because a [Pod](https://kubernetes.io/docs/concepts/workloads/pods/pod/) may
be restarted or scheduled on a different Node; tying the plugin's identity to the resource
rather than an address means it can move around on the network and still be accessible to
the server without a need to update the configuration.

Below is a basic example configuration which will create a Service and
Deployment for Synse Server and the emulator plugin. Synse Server is configured to discover the
plugin using endpoint labels, specifically the `app=synse` and `component=plugin` labels.

In the example below, Synse Server is configured for plugin discovery via environment variables,
but it could also be done with a mounted ConfigMap specifying the [discovery config options](configuration.md#discover).

```yaml
apiVersion: v1
kind: Service
metadata:
  name: synse
  labels:
    app: synse
    component: server
spec:
  ports:
    - port: 5000
      name: http
  clusterIP: None
  selector:
    app: synse
    component: server
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: synse
  labels:
    app: synse
    component: server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: synse
      component: server
  template:
    metadata:
      labels:
        app: synse
        component: server
    spec:
      containers:
      - name: synse-server
        image: vaporio/synse-server
        ports:
        - name: http
          containerPort: 5000
        env:
        - name: SYNSE_PLUGIN_DISCOVER_KUBERNETES_ENDPOINTS_LABELS_APP
          value: synse
        - name: SYNSE_PLUGIN_DISCOVER_KUBERNETES_ENDPOINTS_LABELS_COMPONENT
          value: plugin
---
apiVersion: v1
kind: Service
metadata:
  name: emulator-plugin
  labels:
    app: synse
    component: plugin
    plugin: emulator
spec:
  ports:
    - port: 5001
      name: http
  clusterIP: None
  selector:
    app: synse
    component: plugin
    plugin: emulator
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: emulator-plugin
  labels:
    app: synse
    component: plugin
    plugin: emulator
spec:
  replicas: 1
  selector:
    matchLabels:
      app: synse
      component: plugin
      plugin: emulator
  template:
    metadata:
      labels:
        app: synse
        component: plugin
        plugin: emulator
    spec:
      containers:
      - name: emulator
        image: vaporio/emulator-plugin
        ports:
        - name: http
          containerPort: 5001
```

## Plugin Refresh

Occasionally, a plugin may go offline. This could be due to the plugin restarting after getting
into bad state, an ephemeral network issue, or a deployment manager (e.g. Kubernetes) updating/migrating
the plugin.

In such cases, attempts to communicate with the plugin will fail, and Synse Server will mark it as
"inactive". This flag is used internally to skip over the plugin when performing subsequent gRPC calls
in order to reduce the overhead of waiting for the gRPC request to time out.

Periodically, Synse Server refreshes its plugins. That means it will look at plugin sources (whether
that is config or dynamic discovery) and attempt to re-establish communication with all of them. This
allows it to discover any new plugins and to check up on inactive plugins. If those inactive plugins respond,
they are marked as active.

If a plugin which was previously found via discovery or other means now does not show up, the plugin is
marked as "disabled" internally. It will still show up as inactive to the user. The "disabled" flag is
used to gate additional requests to the plugin until it is re-discovered on a subsequent refresh.

A plugin refresh may also be initiated manually via the [`/plugin?refresh=true`](../api.v3.md#plugins) request.

## Plugin State: Active vs Inactive

As mentioned in the section above, Synse Server internally marks plugins as "active" or "inactive". This
determination is done based on whether Synse Server was able to communicate with the plugin. An error in
issuing requests to plugins will lead them to be marked as "inactive". Note that error responses from the
plugin do not put it in an error state (e.g. device not found), however errors like connection issues, timeouts,
etc. will put them into an "inactive" state.

The notion of "active" vs "inactive" is really just an internal optimization to allow Synse Server to respond
to requests in a more timely manner. As an example, if there were two plugins configured and one became
unreachable, reading all devices would mean issuing a request to both plugins, collecting the readings, and
returning them to the user. Without denoting the plugin as "inactive", the request would take longer as it
would block until the gRPC request to the unreachable plugin timed out or failed to connect.

With the notion of "active" vs "inactive", once a plugin fails a request once, it will be marked inactive
so future requests do not need to block on it, resulting in a more timely response. When put into an inactive
state, the plugin will attempt to reconnect to the plugin in a background task, exponentially backing off.
Once Synse Server can reconnect with the plugin and get a response from it, the plugin is put back into
an "active" state.

[Plugin refresh](#plugin-refresh) is related to this notion of active/inactive, but the two concepts are
different. Plugin refresh describes the process of searching for and registering new plugins, where as
the "active/inactive" plugin state describes whether Synse Server was able to connect to that registered
plugin.

## Secure Communication

The server APIs can be secured by providing a [certificate and key](configuration.md#ssl). While
this may work for small/personal use cases, it is recommended to use a more robust TLS termination
frontend for it in production. Many such solutions exist, such as [Nginx](https://www.nginx.com/),
and there are numerous examples of how to set this up elsewhere.

The internal server --> plugin gRPC API may also be secured via TLS. The [configuration](configuration.md)
page provides details on the configuration options to set this up. Note that Synse does not do any
cert generation or management -- this is something you will need to do on your own.

There are numerous tutorials on generating certs - for example, you can generate a [self-signed cert](https://www.digitalocean.com/community/tutorials/openssl-essentials-working-with-ssl-certificates-private-keys-and-csrs),
[bootstrap a CA to sign your certs](https://github.com/square/certstrap), or generate [self-signed certs
in a different way](https://coreos.com/os/docs/latest/generate-self-signed-certificates.html).

For an example, see: [Deploying with Docker Compose](deploying.md#deploying-with-docker-compose)