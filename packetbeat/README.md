# EDCOP Packetbeat Guide

Table of Contents
-----------------
 
* [Configuration Guide](#configuration-guide)
	* [Image Repository](#image-repository)
	* [Networks](#networks)
	* [Node Selector](#node-selector)
	* [Packetbeat Configuration](#packetbeat-configuration)
	* [Logstash Configuration](#logstash-configuration)
	* [Redis Configuration](#redis-configuration)
	
# Configuration Guide

Within this configuration guide, you will find instructions for modifying Packetbeat's helm chart. All changes should be made in the *values.yaml* file.
Please share any bugs or features requests via GitHub issues.
 
## Image Repository

By default, images are pulled from *edcop-master:5000* which is presumed to be hosted on the master node. If you're changing this value, make sure the image names match the names of the tools, e.g. *packetbeat*, *logstash*, and *redis*. If not, you will have to change the image names in the *packetbeat-daemonset.yaml* file.
 
```
image:
  repository: edcop-master
```

## Networks

Packetbeat only uses 2 interfaces because it can only be deployed in passive mode. By default, these interfaces are named *calico* and *passive*. 

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

## Packetbeat Configuration

Currently, Packetbeat configuration settings only consist of limiting CPU/memory usage, but we would like to add the option of configuring custom protocols in the future. Additionally, there is no configmap for Packetbeat's config file, so you will need to change its Docker image to include custom protocols and other options. 

```
packetbeatConfig:
  limits:
    cpu: 2
	memory: 4G
```

## Logstash Configuration

Logstash is currently included in the Daemonset to streamline the rules required for the data it ingests. Having one Logstash instance per node would clutter rules and cause congestion with log filtering, which would harm our events/second speed. This instance will only deal with Packetbeat's logs and doesn't need complicated filters to figure out which tool the logs came from.
Please make sure to read the [Logstash Performance Tuning Guide](https://www.elastic.co/guide/en/logstash/current/performance-troubleshooting.html) for a better understanding of managing Logstash's resources. 

```
logstashConfig:
  threads: 2 
  batchCount: 250
  initialJvmHeap: 4g
  maxJvmHeap: 4g
  pipelineOutputWorkers: 2 
  pipelineBatchSize: 150  
  limits:
    cpu: 2
    memory: 8G
```

## Redis Configuration

Redis is also included in the Daemonset for the same reasons Logstash is. Currently, you can only limit the resources of Redis in this section, but in the future we would like to add configmaps for tuning purposes. 

```
redisConfig:
  limits:
    cpu: 2
    memory: 8G
```
