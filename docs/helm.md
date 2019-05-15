---
hero: Helm Charts
---

We provide a [Helm](https://helm.sh/) chart repo for various Synse components to help make
deploying Synse on [Kubernetes](https://kubernetes.io/) fast and simple.

You can add our helm chart repo to your local helm server with
```
helm repo add synse https://charts.vapor.io
```

Our available charts are listed in the [vapor-ware/synse-charts](https://charts.vapor.io) repo.
Alternatively, you can search for `synse` with `helm`:

```
$ helm search synse
NAME               	CHART VERSION	APP VERSION	DESCRIPTION
synse/synse-server 	0.1.1        	2.2.4      	An HTTP API for the monitoring and control of physical an...
synse/emulator     	0.1.0        	2.2.0      	Emulator plugin for Synse Server.
synse/modbus       	0.2.0        	1.1.0      	Synse Modbus Over IP Plugin.
synse/snmp         	0.1.0        	           	Synse SNMP Plugin.
```