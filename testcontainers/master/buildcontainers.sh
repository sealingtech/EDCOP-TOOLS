# !/bin/bash
# ======================== Building the Containers ========================= #
#             For use with the EDCOP project, SealingTech 2017               #
#                                                                            #
# Script to build the Docker containers within this directory.               #
# Be sure to run this script within its native directory!                    #
#									                                                           #
# Please check out the offical configuration guide for more information      #
# ========================================================================== #

echo "########## Building Docker containers script ########## "
echo "Please enter the IP address of this master node: "
read NODEIP
echo "Please enter the interface you would like to monitor: "
read INTERFACE
echo "You will need to enter a cluster password for Moloch data transfer, which will be used for all of the nodes as well."
echo "Please enter a cluster password: "
read CLUSTERPW
echo "Finally, you need to enter a password for the admin user in order to access the Moloch web viewer."
echo "Please enter an admin password:"
read ADMINPW

echo "Configuring output and interfaces for master node $NODEIP..."
sed -i 's/CONTAINERINT=.*/'CONTAINERINT=$INTERFACE'/' ./Moloch/buildmoloch.sh
sed -i 's/ESURL=.*/'ESURL=$INTERFACE'/' ./Moloch/buildmoloch.sh
sed -i 's/ESURL=.*/'ESURL=$NODEIP'/' ./Moloch/startmoloch.sh
echo "Setting Moloch passwords..."
sed -i 's/CLUSTERPASSWORD=.*/'CLUSTERPASSWORD=$CLUSTERPW'/' ./Moloch/buildmoloch.sh
sed -i 's/ADMINPASSWORD=.*/'ADMINPASSWORD=$ADMINPW'/' ./Moloch/startmoloch.sh
echo -e "Complete!\n"

echo "Now building docker images..."
sudo docker build -t elasticsearch ./Elasticsearch
sudo docker build -t kibana ./Kibana
sudo docker build --network=host -t moloch ./Moloch

echo -e "\nYour Moloch cluster password is $CLUSTERPW, and your admin password is $ADMINPW."
echo "If you forget these passwords, you may edit the buildmoloch.sh and startmoloch.sh files to find them again."
