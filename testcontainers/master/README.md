# EDCOP-Master-Containers
Docker containers for the master server

These containers use the official elastic images alongside small configuration changes to create our environment. The current version for official Elastic docker images is 5.5.0, and are available from Elastic's Docker hub. 

# Installation
Each application was built and tested utilizing Kubernetes as a deployment solution, and their configuration files reflect Kubernetes networking patterns. Make sure your node names are unique, or kubernetes will be unable to register these nodes. 
Please consult the master configuration guide for steps on how to install and configure these services. By default, we have disabled X-Pack paid services as they require a subscription with Elastic beyond the 30 day trial.

# Warning:
These containers are to be used on the master server ONLY, and must be started before the node applications. This Elasticsearch container will become the master and will give Kibana access to the Elasticsearch cluster. 
