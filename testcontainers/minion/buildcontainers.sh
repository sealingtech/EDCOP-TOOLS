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

sudo docker build -t edcop-elasticsearch ./Elasticsearch
sudo docker build -t edcop-logstash ./Logstash
sudo docker build -t edcop-filebeat ./Filebeat
sudo docker build -t edcop-packetbeat ./Packetbeat
sudo docker pull redis
sudo docker build -t edcop-moloch ./Moloch
sudo docker build -t edcop-bro ./Bro

