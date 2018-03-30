# EDCOP Stenographer Guide

Table of Contents
-----------------
 
* [Configuration Guide](#configuration-guide)
	* [Image Repository](#image-repository)
	* [Networks](#networks)
	* [Persistent Storage](#persistent-storage)
	* [Node Selector](#node-selector)
	* [Stenographer Configuration](#stenographer-configuration)
		* [File Limits](#file-limits)
		* [Resource Limits](#resource-limits)
	
# Configuration Guide

Within this configuration guide, you will find instructions for modifying Stenographer's helm chart. All changes should be made in the *values.yaml* file.
Please share any bugs or features requests via GitHub issues.
 
## Image Repository

By default, images are pulled from *edcop-master:5000* which is presumed to be hosted on the master node. If you're changing these values, make sure you use the full repository name.
 
```
images:
  stenographer: edcop-master:5000/stenographer
```
 
## Networks

Stenographer only uses 2 interfaces because it can only be deployed in passive mode to record traffic. By default, these interfaces are named *calico* and *passive*. 

```
networks:
  overlay: calico
  passive: passive
```
 
To find the names of your networks, use the following command:
 
```
# kubectl get networks
NAME		AGE
calico		1d
passive		1d
inline-1	1d
inline-2	1d
```

## Persistent Storage

These values tell Kubernetes where Stenographer's indices and packets should be stored on the host for persistent storage. The *packets* option is for Stenographer's raw packets and the *index* option is for Stenographer's indexed data. By default, these values are set to */var/EDCOP/data/logs/stenographer* but should be changed according to your logical volume setup. 

```
volumes:
  logs:
    packets: /var/EDCOP/data/logs/stenographer/packets
    index: /var/EDCOP/data/logs/stenographer/index
```
	  
## Node Selector

This value tells Kubernetes which hosts the daemonset should be deployed to by using labels given to the hosts. Hosts without the defined label will not receive pods. 
 
```
nodeSelector:
  nodetype: worker
```
 
To find out what labels your hosts have, please use the following:
```
# kubectl get nodes --show-labels
NAME		STATUS		ROLES		AGE		VERSION		LABELS
master 		Ready		master		1d		v1.9.1		...,nodetype=master
minion-1	Ready		<none>		1d		v1.9.1		...,nodetype=minion
minion-2	Ready		<none>		1d		v1.9.1		...,nodetype=minion
```

## Stenographer Configuration

Stenographer is used to quickly write packets to disk, so no advanced configuration is required for accepting traffic. Clusters that run Stenographer will need 2 networks: an overlay and passive tap network. 

### File Limits

Stenographer allows you to set limits on the maximum file size and the maximum number of open files. It is recommended to allow Stenographer to have unlimited files open, but you should set a limit on the file sizes to control Stenographer's disk space usage. By default, Stenographer will fill up 90% of a disk before starting to delete old files. The larger your file sizes, the more you will lose once Stenographer starts to purge old data. By default, Stenographer limits files to 4GB.

```
stenographerConfig:
  maxFileSize: 4194304
  maxOpenFiles: 1000000
```

### Resource Limits

You can set limits on Stenographer to ensure it doesn't use more CPU/memory space than necessary. Finding the right balance can be tricky, so some testing may be required. Also, please note that Stenographer can easily take up 75%+ of a single core and can also hog disk write space which takes up resources from reading back packet data. 

```
stenographerConfig:
  limits:
    cpu: 2
    memory: 4G
```
