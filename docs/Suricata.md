# Suricata
## Introduction
Suricata is designed to be deployed a large number of hosts.  Suricata is defined as a Daemonset which means the tool will be deployed to all hosts with a specific node tag.  This tag by default is "sensor" but it may be desired to change this if users want to have multiple Suricata instances across the cluster with various options.  Suricata can be placed inline or in a passive only alert mode. Suricata has been designed to pass or detect layer-2 traffic only and will not modify traffic in any fashion. In the inline mode the container will have a total of three interfaces.  One will be connected to the overlay network and two will be used for passing the traffic in the inline mode.  Traffic will come in to one interface, be inspected and then passed out the other side.  In passive mode two interfaces will be used, one for listening to traffic and the other will be used for the overlay network.

For log management this tool is able to be placed in standalone, cluster or external mode.  [See Deployment Options for details](Deployment_Options.md).  Logs will not be stored locally in Suricata and instead will be immediately sent to Redis where they can be ingested and processed by Logstash.  This design limits the writing to disks to sensors.  It is essential to monitor Redis to ensure this queue doesn't build faster than Logstash can process this information.

Suricata rules are downloaded from emerging threats when the container is first initialized currently.  This will be changed in the future to allow better management of rules.

##Usage
View all available options to the user:
```
helm inspect edcop/suricata
```
 
Deploy in passive mode:
```
helm install --set inline=false --set net1=passive edcop/suricata
```

Deploy in standalone mode and specify an external Redis server:
```
helm install --set deploymentOptions.deployment=external --set deploymentOptions.externalOptions.externalHost=10.10.0.6 deploymentOptions.externalOptions.externalPort=6379 edcop/suricata
```
More advanced editing of variables can be done with the following commands:
```
helm inspect edcop/suricata > values.yaml

#Edit the file as desired by the user

helm install -f values.yaml edcop/suricata
```

Tony Rocks!!!!


