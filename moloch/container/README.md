# Moloch Docker Container

## Docker

For deploying a Moloch instance with Docker, please have a working Elasticsearch deployment running and a way to access it. You can edit the ```Dockerfile``` environment variables and the ```etc/config.ini``` file to set your configuration settings.  


The command below uses a Docker link to link the two containers together:

```
sudo sysctl -w vm.max_map_count=262144
sudo docker run -p 9200:9200 -p 9300:9300 -itd --name elasticsearch docker.elastic.co/elasticsearch/elasticsearch:6.2.4
sudo docker run -itd -p 8005:8005 --cap-add NET_RAW --cap-add NET_ADMIN --link elasticsearch:elasticsearch --name moloch moloch
```

## Kubernetes

For deploying multiple instances, it is recommended that you use a statefulset for both Elasticsearch and Moloch to prevent changes in the container/pod states. You may also want to use a config map for the ```config.ini``` file to further customize your deployment. 


If you're looking for more opensource containerized tools, take a look at https://github.com/sealingtech/EDCOP for a fully automated network security platform that utilizes Docker and Kubernetes for deployments and scaling! 
