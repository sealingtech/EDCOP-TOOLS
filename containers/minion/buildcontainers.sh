# !/bin/bash
# ======================== Building the Containers ========================= #

# Build the containers
sudo docker build -t logstash ./logstash
sudo docker build -t filebeat ./filebeat
sudo docker build -t packetbeat ./packetbeat
sudo docker pull redis
#sudo docker build -t edcop-moloch ./Moloch
#sudo docker build -t edcop-suricata ./Suricata
#sudo docker build -t edcop-bro ./Bro

# Tag the images
docker tag logstash edcop-master.local:5000/logstash
docker tag filebeat edcop-master.local:5000/filebeat
docker tag packetbeat edcop-master.local:5000/packetbeat
docker tag redis edcop-master.local:5000/redis
#docker tag edcop-moloch edcop-master:5000/registry/edcop-moloch
#docker tag edcop-suricata edcop-master:5000/registry/edcop-suricata
#docker tag edcop-bro edcop-master:5000/registry/edcop-bro

# Push the images
docker push edcop-master.local:5000/logstash
docker push edcop-master.local:5000/filebeat
docker push edcop-master.local:5000/packetbeat
docker push edcop-master.local:5000/redis
#docker push edcop-master:5000/registry/edcop-bro
#docker push edcop-master:5000/registry/edcop-suricata
#docker push edcop-master:5000/registry/edcop-moloch
