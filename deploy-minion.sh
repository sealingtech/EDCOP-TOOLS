# !/bin/bash
# ======================== Master EDCOP Environment =========================#
#             For use with the EDCOP project, SealingTech 2017               #
#                                                                            #
# Script to build the master node for EDCOP                                  #
# Be sure to run this script within its native directory!                    #
#                                                                            #
# Please check out the offical configuration guide for more information      #
# ========================================================================== #
EDCOPDIR='/edcop-cluster'
ESDIR='/esdata'
MORDIR='/data/moloch/raw'
MOLDIR='/data/moloch/logs'
SURDIR='/data/suricata'
BRODIR='/data/bro'


echo "########## Joining existing Kubernetes Cluster Script  ########## "
echo "Before you begin to build the environment, you will need to change this node's hostname. " 
echo "Please input a unqiue hostname for this node: "
read hostname
hostnamectl set-hostname $hostname
	
MasterIP()
{
    echo "Please enter the IP address of the master node: "
    read MASTERIP
    if [[ "$MASTERIP" =~ ^(([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$ ]]; then
    echo "VALID IP..."
    echo $MASTERIP "Is the master node"
    WorkerIP
    else
    echo "Invalid  Master IP...please input a valid IP address"
    checkM
fi
}
WorkerIP()
{
    echo "Please enter the IP address of the worker node: "
    read NODEIP
    if [[ "$NODEIP" =~ ^(([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$ ]]; then
    echo "VALID IP..."
    echo $NODEIP "Is the worker node"
    ClusterSetup
    else
    echo "Invalid Node IP...please input a valid IP address"
    checkW
fi
}
ClusterSetup()
{
    echo "Please enter the interface you would like to monitor: "
    read INTERFACE
    echo "You will need to enter a cluster password for Moloch data transfer, which will be used for all of the nodes as well."
    echo "Please enter a cluster password: "
    read CLUSTERPW
}
Dependecy_Setup()
{
    # Remove previous installation of docker if present
    sudo yum -y remove docker \
         docker-common \
         container-selinux \
         docker-selinux \
         docker-engine
    
    # Disable SELinux
    sudo setenforce 0
	
    # Install Docker version 17.06	 
    sudo yum -y install epel-release
    sudo yum install -y yum-utils device-mapper-persistent-data lvm2 git wget net-tools python-pip python-wheel
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum -y makecache fast
    sudo yum -y install docker-ce-17.06.0.ce-1.el7.centos.x86_64
    sudo systemctl start docker
	
    # Setting environmental variables
    echo 262144 > /proc/sys/vm/max_map_count
    if [[ ! -e "$ESDIR" ]]; then
            mkdir $ESDIR
    elif [[ ! -d $ESDIR ]]; then
            echo "$ESDIR already exists!" 1>&2
    fi
	
    # Creating directories
    mkdir -p /data $MORDIR $MOLDIR $SURDIR $BRODIR
    chmod 757 $ESDIR $MORDIR $MOLDIR $SURDIR $BRODIR
    
    # Opening ports
    sudo iptables -I INPUT -i docker0 -j ACCEPT
    sudo firewall-cmd --zone=internal --add-port=8080/tcp --permanent
    sudo firewall-cmd --zone=internal --add-port=8080/udp --permanent
    sudo firewall-cmd --zone=internal --add-port=8005/tcp --permanent
    sudo firewall-cmd --zone=internal --add-port=8005/udp --permanent
    sudo firewall-cmd --zone=internal --add-port=4500/udp --permanent
    sudo firewall-cmd --zone=internal --add-port=500/udp --permanent
    sudo firewall-cmd --reload
}
buildContainers()
{
    # Removing previous installations and cloning the required files
    rm -rf ~/$EDCOPDIR /root/.kube /root/.rancher
    git clone https://github.com/sealingtech/edcop-cluster.git ~/$EDCOPDIR
	
    # Install and configure oinkmaster
    wget http://prdownloads.sourceforge.net/oinkmaster/oinkmaster-2.0.tar.gz
    sudo mkdir /etc/oinkmaster /etc/suricata /etc/suricata/rules
    tar xf oinkmaster-2.0.tar.gz -C /etc/oinkmaster/ --strip-components=1
    cd /etc/oinkmaster
    sudo mv ./oinkmaster.pl /usr/local/bin/oinkmaster
    sed -i '0,/# url/s/# url =.*/url = https:\/\/rules.emergingthreats.net\/open\/suricata-3.2\/emerging.rules.tar.gz/' ./oinkmaster.conf
    oinkmaster -C /etc/oinkmaster/oinkmaster.conf -o /etc/suricata/rules
    
    # Make the scripts executables
    cd ~/$EDCOPDIR/containers/minion/moloch
    chmod u+x ./startmoloch.sh ./buildmoloch.sh
	
    # Editing config files with sed commands
    cd ~/$EDCOPDIR/containers/minion
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
     
    # Building Docker images
    echo "Now building docker images..."
    sudo docker build -t elasticsearch ./elasticsearch
    sudo docker build -t logstash ./logstash
    sudo docker build -t filebeat ./filebeat
    sudo docker build --network=host -t packetbeat ./packetbeat
    sudo docker pull redis
    sudo docker build --network=host -t moloch ./moloch
    sudo docker build -t suricata ./suricata
    sudo docker build -t bro ./bro
    echo -e "\nYour Moloch cluster password is $CLUSTERPW."
    echo "If you forget this password, you may edit the buildmoloch.sh and startmoloch.sh files to find them again."
    sleep 5
    cd
}
RancherEnvrionment()
{
    # Registering the node as a Rancher Agent
    pip install --upgrade pip rancher-agent-registration
    rancher-agent-registration --url http://$MASTERIP:'8080' --key "" --secret "" --host-ip "$NODEIP"
    echo "Joining existing kubernetes cluster.. (Approximately 2 minutes) "
    sleep 2m  # wait to join kubernetes cluster
    
    # Installing kubectl
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
    mkdir -p /root/.kube/
    cd /root/.kube
printf '
apiVersion: v1
kind: Config
clusters:
- cluster:
    api-version: v1
    insecure-skip-tls-verify: true
    server: "https://'$MASTERIP':8080/r/projects/1a7/kubernetes:6443"
  name: "EDCOP"
contexts:
- context:
    cluster: "EDCOP"
    user: "EDCOP"
  name: "EDCOP"
current-context: "EDCOP"
users:
- name: "EDCOP"
  user:
   token: "QmFzaWMgTlRNd1FUZ3pOVEJETmpnNU9EaERORVpCUlRNNlRWWXhkbVJSYmt4Q2RYWkRXVVJRV21OTFZ6ZFRibTB6YmxGME56VTJlR0l6WmtWdVkzTTBhZz09"' >> config
    
    # Label worker
    kubectl label nodes $(hostname) nodetype=worker --overwrite
    
    #nodelogs
    #cd ~/$EDCOPDIR/kubernetes/nodelogs
    #kubectl apply -f nodelogs-service.yaml
    #kubectl apply -f nodelogs.yaml
    #sleep 30   #sleep for 30 to allow elasticsearch + redis to start
    #suricata
    #cd ~/$EDCOPDIR/kubernetes/suricata
    #kubectl apply -f suricata.yaml
    #bro
    #cd ~/$EDCOPDIR/kubernetes/bro
    #kubectl apply -f bro.yaml
    #packetbeat
    #cd ~/$EDCOPDIR/kubernetes/packetbeat
    #kubectl apply -f packetbeat.yaml
    #moloch
    #cd ~/$EDCOPDIR/kubernetes/moloch-node
    #kubectl apply -f moloch-nodes.yaml
}
checkM() #IP VALIDATION - Master
{
    MasterIP
}
checkW() #IP VALIDATION - Worker
{
    WorkerIP
}
MasterIP
Dependecy_Setup
echo "dependecies installed"
echo "Now creating EDCOP Envrionment..."
buildContainers
RancherEnvrionment
echo 'The Elasticssearch cluster will be located at http://'$NODEIP':30001'
echo 'The Moloch webviewer will be located at http://'$NODEIP':8005'
# Reload the firewall for moloch now that it's started
sudo firewall-cmd --reload
