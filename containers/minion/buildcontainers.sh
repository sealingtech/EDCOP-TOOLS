# !/bin/bash
# ======================== Building the Containers ========================= #

# Build the containers
sudo docker build -t edcop-logstash ./Logstash
sudo docker build -t edcop-filebeat ./Filebeat
sudo docker build -t edcop-packetbeat ./Packetbeat
sudo docker pull redis
#sudo docker build -t edcop-moloch ./Moloch
#sudo docker build -t edcop-suricata ./Suricata
#sudo docker build -t edcop-bro ./Bro

# Tag the images
docker tag edcop-logstash edcop-master:5000/registry/edcop-logstash
docker tag edcop-filebeat edcop-master:5000/registry/edcop-filebeat
docker tag edcop-packetbeat edcop-master:5000/registry/edcop-packetbeat
docker tag redis edcop-master:5000/registry/edcop-redis
#docker tag edcop-moloch edcop-master:5000/registry/edcop-moloch
#docker tag edcop-suricata edcop-master:5000/registry/edcop-suricata
#docker tag edcop-bro edcop-master:5000/registry/edcop-bro

# Push the images
docker push edcop-master:5000/registry/edcop-logstash
docker push edcop-master:5000/registry/edcop-filebeat
docker push edcop-master:5000/registry/edcop-packetbeat
docker push edcop-master:5000/registry/edcop-redis
#docker push edcop-master:5000/registry/edcop-bro
#docker push edcop-master:5000/registry/edcop-suricata
#docker push edcop-master:5000/registry/edcop-moloch
