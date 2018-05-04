rm -rf helm-repo/*


cd helm-repo

#Bro
mkdir bro
cp -rpf ../bro/helm/* bro/
cp ../bro/README.md bro/
helm package bro
rm -rf bro/


#Suricata
mkdir suricata
cp -rpf ../suricata/helm/* suricata/
cp ../suricata/README.md suricata/
helm package suricata
rm -rf suricata/


#Elasticsearch
mkdir elasticsearch
cp -rpf ../elasticsearch/helm/* elasticsearch/
cp ../elasticsearch/README.md elasticsearch/
helm package elasticsearch
rm -rf elasticsearch/

#Kibana
mkdir kibana
cp -rpf ../kibana/helm/* kibana/
cp ../kibana/README.md kibana/
helm package kibana
rm -rf kibana/


helm repo index . --url http://repos.sealingtech.org/charts/



# Clean up
rm -rf suricata/ bro/
