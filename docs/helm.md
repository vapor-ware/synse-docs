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
synse/synse-loadgen	1.0.0        	1.0.0      	Generate request loads against the Synse Server API         
synse/synse-server 	3.0.0        	3.0.0      	An API to monitor and control physical and virtual infras...
synse/emulator     	3.0.0        	3.0.0      	A Synse plugin providing emulated devices and reading data  
synse/modbus       	2.0.0        	2.0.0      	Modbus over IP plugin for Synse                             
synse/prophetess   	1.0.0        	0.2.0      	A tool for extracting data from extractors, transforming ...
synse/snmp         	2.0.0        	2.0.0      	SNMP plugin for Synse                                       
```