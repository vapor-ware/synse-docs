---
hero: Helm Charts
---

We provide a [Helm](https://helm.sh/) chart repo for various Synse components to help make
deploying Synse on [Kubernetes](https://kubernetes.io/) fast and simple.

You can add our helm chart repo to your local helm server with

=== "helm3"

    ```
    helm repo add synse https://charts.vapor.io
    ```
    
=== "helm2"

    ```
    helm repo add synse https://charts.vapor.io
    ```


Our available charts are listed in the [vapor-ware/synse-charts](https://charts.vapor.io) repo.
Alternatively, you can search for `synse` with `helm`:

=== "helm3"

    ```console
    $ helm search repo synse
    NAME               	CHART VERSION	APP VERSION	DESCRIPTION                                       
    synse/synse-loadgen	1.0.2        	1.0.2      	Generate request loads against the Synse Server...
    synse/synse-server 	3.1.3        	3.1.0      	An API to monitor and control physical and virt...
    synse/emulator     	3.1.5        	3.2.2      	A Synse plugin providing emulated devices and r...
    synse/etamay       	1.0.1        	0.1.0      	A dynamic metadata service                        
    synse/juniper-jti  	0.1.4        	0.1.1      	Synse plugin to consume Juniper networking tele...
    synse/modbus       	2.1.8        	2.0.8      	Modbus over IP plugin for Synse                   
    synse/openconfig   	0.2.3        	0.1.1      	Synse plugin to collect networking telemetry wi...
    synse/prophetess   	1.0.4        	0.2.1      	A tool for extracting data from extractors, tra...
    synse/snmp         	2.1.3        	2.0.2      	SNMP plugin for Synse                             
    synse/snmp-ups     	0.2.1        	0.1.0      	SNMP plugin the RFC1628 UPS MIB                   
    ```

=== "helm2"

    ```console
    $ helm search synse
    NAME               	CHART VERSION	APP VERSION	DESCRIPTION                                                 
    synse/synse-loadgen	1.0.2        	1.0.2      	Generate request loads against the Synse Server...
    synse/synse-server 	3.1.3        	3.1.0      	An API to monitor and control physical and virt...
    synse/emulator     	3.1.5        	3.2.2      	A Synse plugin providing emulated devices and r...
    synse/etamay       	1.0.1        	0.1.0      	A dynamic metadata service                        
    synse/juniper-jti  	0.1.4        	0.1.1      	Synse plugin to consume Juniper networking tele...
    synse/modbus       	2.1.8        	2.0.8      	Modbus over IP plugin for Synse                   
    synse/openconfig   	0.2.3        	0.1.1      	Synse plugin to collect networking telemetry wi...
    synse/prophetess   	1.0.4        	0.2.1      	A tool for extracting data from extractors, tra...
    synse/snmp         	2.1.3        	2.0.2      	SNMP plugin for Synse                             
    synse/snmp-ups     	0.2.1        	0.1.0      	SNMP plugin the RFC1628 UPS MIB                                       
    ```