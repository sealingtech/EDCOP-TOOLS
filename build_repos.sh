rm -rf helm-repo/*


cd helm-repo

#Bro
mkdir bro
cp -rpf ../bro/helm/* bro/
cp ../bro/README.md bro/
helm package bro


#Suricata
mkdir suricata
cp -rpf ../suricata/helm/* suricata/
cp ../suricata/README.md suricata/
helm package suricata



helm repo index . --url http://repos.sealingtech.org/charts/



# Clean up
rm -rf suricata/ bro/
