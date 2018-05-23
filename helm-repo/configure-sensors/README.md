# EDCOP Host-Setup

Table of Contents
-----------------
 
* [Configuration Guide](#configuration-guide)
* [Image Repository](#image-repository)
* [Network Interface](#network-interfaces)
* [Node Selector](#nodeselector)

# Configuration Guide

Within this configuration guide, you will find instructions for modifying Host-Setup.  Host-Setup is designed to help deploy SR-IOV networks and optimize performance across all sensors.

WARNING: While Host-setup doesn't require a reboot, there should be no sensors deployed before running this tool.  Delete all sensors utilizing either of the inline or passive networks.  Once this has been run it is possible to re-run this.
 
## Image Repository

This points to the location of the Docker container registry.  If you're changing these values, make sure you include the full repository name.
 
```
images:
    host-setup: gcr.io/edcop-public/host-setup:2
```
 
## Network Interfaces
Configure specific settings to define the network interface cards.  The deviceName settings must the be the same across the cluster.  The numOfVirtualFunctions setting will be the number of virtual functions that will be created on each NIC.  Each sensor will consume one SR-IOV virtual function.  Finally, the irqCoreAssignment is the CPU core that will handle all interrupts for the Network Interface Card.
```
networkInterfaces: 
    inline1interface:
        #Configure the interface names
        deviceName: enp216s0f1
        #Configure the number of virtual functions to be created on the interface
        numOfVirtualFunctions: 4
        #Configure the core that will handle interrupts for the network interface
        irqCoreAssignment: 8
    inline2interface:
        deviceName: enp216s0f2
        numOfVirtualFunctions: 4
        irqCoreAssignment: 8
    passive1interface:
        deviceName: enp216s0f3
        numOfVirtualFunctions: 4
        irqCoreAssignment: 8    
```  

## NodeSelector
The Nodetype option will configure which systems Configure Sensors will be applied to.  This should only be systems which will carry sensors and should NEVER include the master node.
  
```
nodeSelector:
  nodetype: worker
```