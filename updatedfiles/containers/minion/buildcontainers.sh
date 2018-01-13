# !/bin/bash
# ======================== Building the Containers ========================= #

# Build the containers
sudo docker build -t edcop-elasticsearch ./Elasticsearch
sudo docker build -t edcop-logstash ./Logstash
sudo docker build -t edcop-filebeat ./Filebeat
sudo docker build -t edcop-packetbeat ./Packetbeat
sudo docker pull redis
sudo docker build -t edcop-moloch ./Moloch
sudo docker build -t edcop-suricata ./Suricata
sudo docker build -t edcop-bro ./Bro

# Tag the images
docker tag edcop-elasticsearch registry.edcop.sealingtech.org:5000/registry/edcop-elasticsearch
docker tag edcop-logstash registry.edcop.sealingtech.org:5000/registry/edcop-logstash
docker tag edcop-filebeat registry.edcop.sealingtech.org:5000/registry/edcop-filebeat
docker tag edcop-packetbeat registry.edcop.sealingtech.org:5000/registry/edcop-packetbeat
docker tag redis registry.edcop.sealingtech.org:5000/registry/edcop-redis
docker tag edcop-moloch registry.edcop.sealingtech.org:5000/registry/edcop-moloch
docker tag edcop-suricata registry.edcop.sealingtech.org:5000/registry/edcop-suricata
docker tag edcop-bro registry.edcop.sealingtech.org:5000/registry/edcop-bro

# Push the images
docker push registry.edcop.sealingtech.org:5000/registry/edcop-elasticsearch
docker push registry.edcop.sealingtech.org:5000/registry/edcop-logstash
docker push registry.edcop.sealingtech.org:5000/registry/edcop-filebeat
docker push registry.edcop.sealingtech.org:5000/registry/edcop-packetbeat
docker push registry.edcop.sealingtech.org:5000/registry/edcop-redis
docker push registry.edcop.sealingtech.org:5000/registry/edcop-bro
docker push registry.edcop.sealingtech.org:5000/registry/edcop-suricata
docker push registry.edcop.sealingtech.org:5000/registry/edcop-moloch
