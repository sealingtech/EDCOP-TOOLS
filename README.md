# edcop-cluster
Docker Containers for EDCOP deployments spread across multiple nodes.

If you're looking for a single server version of the EDCOP, please visit https://github.com/sealingtech/edcop-deployment.

# About
These containers use the official Elastic images alongside small configuration changes to create our environment. The current version for official Elastic docker images is 5.5.0, and are available from Elastic's Docker hub. By default, we have disabled X-Pack paid services as they require a subscription with Elastic beyond the 30 day trial. 

Each application was built and tested utilizing Kubernetes deployed through Rancher, and reflects Etcd DNS and Rancher overlay networking services.

# Installation
Please use the master/minion node scripts to automatically build the environment, or consult the official configuration guides for manual steps. This repository should only be used for clustered deployments, and will not work with single server deployments. 

# EDCOP-TOOLS
# EDCOP-TOOLS
# EDCOP-TOOLS
