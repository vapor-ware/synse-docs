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
    - "5000:5000"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/test"]
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
labels can be set on that Service to identify it as a plugin. 

This is useful because [Pod](https://kubernetes.io/docs/concepts/workloads/pods/pod/) may
be restarted or scheduled on a different Node and tying the plugin's identity to the resource
rather than an address means it can move around on the network and still be accessible to
the server without a need to update the configuration.

Below is a basic example Kubernetes configuration which will create a Service and
Deployment for Synse Server and the emulator plugin. Synse Server is configured to discover the
plugin using endpoint labels, specifically the `app=synse` and `component=plugin` labels.

In the example below, Synse Server is configured for plugin discovery via environment variables,
but it could also be done with a mounted ConfigMap specifying the [doscovery config options](configuration.md#discover).

```
SYNSE_PLUGIN_DISCOVER_KUBERNETES_ENDPOINTS_LABELS_APP=synse
SYNSE_PLUGIN_DISCOVER_KUBERNETES_ENDPOINTS_LABELS_COMPONENT=plugin
```

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

## Secure Communication

The server APIs can be secured by providing a [certificate and key](configuration.md#ssl). While
this may work for small/personal use cases, it is recommended to use a more robust TLS termination
frontend for us in production. Many such solutions, such as [Nginx](https://www.nginx.com/), exist
and there are numerous examples of how to set this up elsewhere.

The internal server --> plugin gRPC API may also be secured via TLS. The [configuration](configuration.md)
page provides details on the configuration options to set this up. Note that Synse does not do any
cert generation or management -- this is something you will need to do on your own.

There are numerous tutorials on generating certs - for example, you can generate a [self-signed cert](https://www.digitalocean.com/community/tutorials/openssl-essentials-working-with-ssl-certificates-private-keys-and-csrs),
[bootstrap a CA to sign your certs](https://github.com/square/certstrap), or generate [self-signed certs
in a different way](https://coreos.com/os/docs/latest/generate-self-signed-certificates.html).

For an example, see: [Deploying with Docker Compose](deploying.md#deploying-with-docker-compose)