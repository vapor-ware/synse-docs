---
hero: Deploying 
---

This page discusses different ways of deploying Synse Server. Because of Synse's
plugin architecture, it is often easiest and most convenient to run Synse in a
deployment of some sort. Two types of deployments are described here:

- [Deploying with Docker Compose](#deploying-with-docker-compose)
- [Deploying with Kubernetes](#deploying-with-kubernetes)


## Deploying with Docker Compose

If you've gone through the [quickstart](quickstart.md), you will have seen an
example of this already in the [simple emulator deployment](quickstart.md#a-simple-emulator-deployment)
section. Here, that example is extended to use some more advanced features.

!!! note
    Even though communication via unix sockets is supported, it is recommended
    to use TCP based communication when possible, as it is generally easier to
    manage and configure in containerized environments.

The [emulator plugin](https://github.com/vapor-ware/synse-emulator-plugin) will be
[configured](../../sdk/configuration/plugin.md) for TCP with a secure communication
channel using TLS certs. For this example, x509 self-signed certs [were generated](https://www.digitalocean.com/community/tutorials/openssl-essentials-working-with-ssl-certificates-private-keys-and-csrs)
with the signing subject: `"/C=US/ST=Texas/L=Austin/O=Vapor/CN=emulator"`. Afterwards,
we are left with:

```
.
└── certs
    ├── emulator-plugin.crt
    ├── emulator-plugin.csr
    ├── emulator-plugin.key
    ├── rootCA.crt
    ├── rootCA.key
    └── rootCA.srl
```

The emulator plugin will use its built-in defaults for device configuration, but
we will need to supply a custom plugin configuration to set up TLS. The following
file is saved as `emulator-config.yml`:

```yaml
version: 3
debug: true
network:
  type: tcp
  address: ':5001'
  tls:
    skipVerify: true
    key: /tmp/ssl/emulator-plugin.key
    cert: /tmp/ssl/emulator-plugin.crt
    caCerts:
      - /tmp/ssl/rootCA.crt
```

We could provide a custom configuration for Synse Server as well, but since we only
need to supply two values (the certificate and the plugin address), we can do it simply
through environment variables, e.g.

```yaml
environment:
  SYNSE_PLUGIN_TCP: emulator:5001
  SYNSE_GRPC_TLS_CERT: /tmp/ssl/emulator-plugin.crt
```

All that is left is mounting the certificates into the containers appropriately.
Together, the compose file will look like:

```yaml
#
# deploy.yml
#
# An example deployment of Synse Server and the Emulator Plugin
# configured to communicate over TCP with TLS enabled.
#

version: '3'
services:

  # Synse Server
  synse-server:
    container_name: synse-server
    image: vaporio/synse-server
    ports:
    - '5000:5000'
    volumes:
    - ./certs/emulator-plugin.crt:/tmp/ssl/emulator-plugin.crt
    links:
    - emulator
    environment:
      SYNSE_LOGGING: debug
      SYNSE_PLUGIN_TCP: emulator:5001
      SYNSE_GRPC_TLS_CERT: /tmp/ssl/emulator-plugin.crt

  # Emulator Plugin
  emulator:
    container_name: emulator
    image: vaporio/emulator-plugin
    expose:
    - '5001'
    command: ['--debug']
    volumes:
      # mount in the custom plugin config
      - ./emulator-config.yaml:/tmp/config/config.yml
      # mount in the keys/certs needed for gRPC TLS
      - ./certs/emulator-plugin.crt:/tmp/ssl/emulator-plugin.crt
      - ./certs/emulator-plugin.key:/tmp/ssl/emulator-plugin.key
      - ./certs/rootCA.crt:/tmp/ssl/rootCA.crt
    environment:
      # set config override path for custom plugin configuration
      PLUGIN_CONFIG: /tmp/config
```

This can be run with

```
docker-compose -f deploy.yml up -d
```

After it starts, you can inspect the logs to verify both containers have no errors
and have the correct config. You can also check the [`/plugin`](../api.v3.md#plugin-info)
endpoint to verify that the emulator was registered:

```console
$ curl localhost:5000/v3/plugin
[
  {
    "name":"emulator plugin",
    "maintainer":"vaporio",
    "tag":"vaporio\/emulator-plugin",
    "description":"A plugin with emulated devices and data",
    "id":"897fcca8-d30f-5470-a261-2768c5acddab",
    "active":true
  }
]
```

And the [`/scan`](../api.v3.md#scan) endpoint to see the emulated devices.

```console
$ curl localhost:5000/v3/scan
[
  {
    "id":"104aeeaa-2125-5649-8dcb-c516cf6f65c2",
    "alias":"",
    "info":"Synse Airflow Sensor",
    "type":"airflow",
    "plugin":"897fcca8-d30f-5470-a261-2768c5acddab",
    "tags":[
      "system/id:104aeeaa-2125-5649-8dcb-c516cf6f65c2",
      "system/type:airflow"
    ],
    "metadata": {}
  },
  {
    "id":"1c565336-8969-5818-94a6-e4f4a4cf99ba",
    "alias":"",
    "info":"Synse Pressure Sensor 1",
    "type":"pressure",
    "plugin":"897fcca8-d30f-5470-a261-2768c5acddab",
    "tags":[
      "system/id:1c565336-8969-5818-94a6-e4f4a4cf99ba",
      "system/type:pressure"
    ],
    "metadata": {}
  },
  {
    "id":"39a9ca9a-aabf-5241-998f-3d15068a8630",
    "alias":"",
    "info":"Synse Fan",
    "type":"fan",
    "plugin":"897fcca8-d30f-5470-a261-2768c5acddab",
    "tags":[
      "system/id:39a9ca9a-aabf-5241-998f-3d15068a8630",
      "system/type:fan"
    ],
    "metadata": {}
  },
  ... 
]
```

To bring the deployment down,

```console
$ docker-compose -f deploy.yml down
```

## Deploying with Kubernetes

Assuming a working understanding of [Kubernetes](https://kubernetes.io/), deploying Synse on
Kubernetes is fairly simple. This section provides an example of a basic deployment of Synse
Server and the [emulator plugin](https://github.com/vapor-ware/synse-emulator-plugin).

For this example you will need:

- a basic understanding of Kubernetes and manifest definitions
- access to an operational Kubernetes cluster (minikube, kubernetes for docker desktop, GKE, etc.)
- [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed and configured 
  with your cluster as the current context

All that is needed to get Synse Server running with an emulator backend (similar to the [quickstart example](quickstart.md#a-simple-emulator-deployment))
is a single deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: synse
  labels:
    app: synse
spec:
  replicas: 1
  selector:
    matchLabels:
      app: synse
  template:
    metadata:
      labels:
        app: synse
    spec:
      containers:
      - name: synse-server
        image: vaporio/synse-server
        ports:
        - name: http
          containerPort: 5000
        env:
        # Enable debug logging via ENV config
        - name: SYNSE_LOGGING
          value: debug
        # Register the Emulator Plugin via ENV config
        - name: SYNSE_PLUGIN_TCP
          value: localhost:5001

      - name: emulator-plugin
        image: vaporio/emulator-plugin
        ports:
        - name: http
          containerPort: 5001
```

This can be saved as `simple-deploy.yaml` and can be applied to the cluster

```
kubectl apply -f simple-deploy.yaml
```

You can check to see if the Pod came up and is running. Passing in the `-o wide` flag
will also give the address of the Pod in the cluster.

```console
$ kubectl get pods -o wide
NAME                    READY     STATUS    RESTARTS   AGE       IP           NODE
synse-f6956f758-l7hz2   2/2       Running   0          28s       10.1.0.189   docker-for-desktop
```

You can't query the server endpoint directly without setting up a service, ingress, or some other means of
access. Instead, you can [run a debug container](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-service/#running-commands-in-a-pod)
on the cluster to get on the same network.

```console
$ kubectl run -it --rm --restart=Never alpine --image=alpine sh
If you don't see a command prompt, try pressing enter.
/ #
```

We'll need something like `curl`, which can be installed with

```console
/ # apk add curl
fetch http://dl-cdn.alpinelinux.org/alpine/v3.9/main/x86_64/APKINDEX.tar.gz
fetch http://dl-cdn.alpinelinux.org/alpine/v3.9/community/x86_64/APKINDEX.tar.gz
(1/5) Installing ca-certificates (20190108-r0)
(2/5) Installing nghttp2-libs (1.35.1-r0)
(3/5) Installing libssh2 (1.8.2-r0)
(4/5) Installing libcurl (7.64.0-r1)
(5/5) Installing curl (7.64.0-r1)
Executing busybox-1.29.3-r10.trigger
Executing ca-certificates-20190108-r0.trigger
OK: 7 MiB in 19 packages
```

Now, using the Synse Pod IP from before, the API should be accessible:

```console
/ # curl 10.1.0.189:5000/test
{
  "status":"ok",
  "timestamp":"2019-05-17T13:13:48.412790Z"
}
```

You can explore other [API Endpoints](../api.v3.md), or remove the deployment (after exiting the debug container)

```
kubectl delete -f simple-deploy.yaml
```
