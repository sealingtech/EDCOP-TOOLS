# !/bin/bash
# ======================== Building the Containers ========================= #
#             For use with the EDCOP project, SealingTech 2017               #
#                                                                            #
# Script to build the Docker containers within this directory.               #
# Be sure to run this script within its native directory!                    #
#									                                                           #
# Please check out the offical configuration guide for more information      #
# ========================================================================== #
#
# Script to edit the interfaces and IP addresses

echo "########## Building containers script ########## "
echo "Please enter the IP address of this node: "
read NODEIP
echo "Please enter the interface you would like to monitor: "
read INTERFACE
echo "Please enter the cluster password for Moloch, this should be the same as the one you used for the master: "
read CLUSTERPW

echo "Configuring output and interfaces for current node $NODEIP..."
sed -i 's/CONTAINERINT=.*/'CONTAINERINT=$INTERFACE'/' ./moloch/buildmoloch.sh
sed -i 's/ESURL=.*/'ESURL=$NODEIP'/' ./moloch/buildmoloch.sh
sed -i 's/ESURL=.*/'ESURL=$NODEIP'/' ./moloch/startmoloch.sh
sed -i 's/CONTAINERINT=.*/'CONTAINERINT=$INTERFACE'/' ./bro/startbro.sh
sed -i 's/CONTAINERINT=.*/'CONTAINERINT=$INTERFACE'/' ./suricata/startsuricata.sh
sed -i 's/hosts: .*/hosts: [\"'$NODEIP':30003\"]/' ./packetbeat/packetbeat.yml
sed -i 's/packetbeat.interfaces.device: .*/packetbeat.interfaces.device: '$INTERFACE'/' ./packetbeat/packetbeat.yml
echo "Setting Moloch passwords..."
sed -i 's/CLUSTERPASSWORD=.*/'CLUSTERPASSWORD=$CLUSTERPW'/' ./moloch/buildmoloch.sh
echo -e "Complete!\n"

echo "WARNING: Building the Docker containers will take upwards of an hour. Please type 'y' to continue."
read -p "Enter [y/n]: " opt

if [[ $opt == "y" ]] ; then
  sudo docker build -t elasticsearch ./elasticsearch
  sudo docker build -t logstash ./logstash
  sudo docker build -t filebeat ./filebeat
  sudo docker build --network=host -t packetbeat ./packetbeat
  sudo docker pull redis
  sudo docker build --network=host -t moloch ./moloch
  sudo docker build -t suricata ./suricata
  sudo docker build -t bro ./bro

else
  echo "Script exited"
fi

