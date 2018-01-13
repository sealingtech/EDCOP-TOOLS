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

IP()
{
    echo "########## Building Docker containers script ########## "
    echo "Please enter the IP address of this master node: "
    read MASTERIP
    if [[ "$MASTERIP" =~ ^(([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$ ]]; then
        echo "VALID IP..."
        echo $MASTERIP "Is the master node"
        ClusterSetup
    else
        echo "Invalid IP...please input a valid IP address"
        check
fi
}

ClusterSetup()
{
    echo "Please enter the interface you would like to monitor: "
    read INTERFACE
    echo "You will need to enter a cluster password for Moloch data transfer, which will be used for all of the nodes as well."
    echo "Please enter a cluster password: "
    read CLUSTERPW
    echo "Finally, you need to enter a password for the admin user in order to access the Moloch web viewer."
    echo "Please enter an admin password:"
    read ADMINPW
    echo "Please input a unique hostname for this master node: "
    read hostname
    hostnamectl set-hostname $hostname
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
    mkdir -p /data $MORDIR $MOLDIR
    chmod 757 $ESDIR $MORDIR $MOLDIR
    
    # Opening ports
    sudo iptables -I INPUT -i docker0 -j ACCEPT
    sudo firewall-cmd --zone=internal --add-port=8080/tcp --permanent
    sudo firewall-cmd --zone=internal --add-port=8080/udp --permanent
    sudo firewall-cmd --zone=internal --add-port=8005/tcp --permanent
    sudo firewall-cmd --zone=internal --add-port=8005/udp --permanent
    sudo firewall-cmd --reload
}

buildContainers()
{
    # Removing previous installations and cloning the required files
    rm -rf ~/$EDCOPDIR /root/.kube /root/.rancher 
    git clone https://github.com/sealingtech/edcop-cluster.git ~/$EDCOPDIR
    cd ~/$EDCOPDIR/containers/master/moloch
    chmod u+x ./startmoloch.sh ./buildmoloch.sh 
	
    # Editing config files with sed commands
    cd ~/$EDCOPDIR/containers/master 
    echo "Configuring output and interfaces for master node $MASTERIP..."
    sed -i 's/CONTAINERINT=.*/'CONTAINERINT=$INTERFACE'/' ./moloch/buildmoloch.sh
    sed -i 's/ESURL=.*/'ESURL=$MASTERIP'/' ./moloch/buildmoloch.sh
    sed -i 's/ESURL=.*/'ESURL=$MASTERIP'/' ./moloch/startmoloch.sh
    echo "Setting Moloch passwords..."
    sed -i 's/CLUSTERPASSWORD=.*/'CLUSTERPASSWORD=$CLUSTERPW'/' ./moloch/buildmoloch.sh
    sed -i 's/ADMINPASSWORD=.*/'ADMINPASSWORD=$ADMINPW'/' ./moloch/startmoloch.sh
    echo -e "Complete!\n"
    
    # Building Docker images
    echo "Now building docker images..."
    sudo docker build -t elasticsearch ./elasticsearch
    sudo docker build -t kibana ./kibana
    sudo docker build --network=host -t moloch ./moloch
    echo -e "\nYour Moloch cluster password is $CLUSTERPW, and your admin password is $ADMINPW."
    echo "If you forget these passwords, you may edit the buildmoloch.sh and startmoloch.sh files to find them again."
    sleep 5
    cd
}
 
RancherEnvrionment()
{
    # Creating Rancher server
    docker run -d --restart=unless-stopped -p 8080:8080 rancher/server:stable
    echo "Rancher server is being created...." 
    sleep 1m
	
    # Installing kubectl
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl 
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
    mkdir -p /root/.kube/
	
    # Setup Rancher environment 
    wget https://github.com/rancher/cli/releases/download/v0.6.5/rancher-linux-amd64-v0.6.5.tar.gz
    tar -xzvf rancher-linux-amd64-v0.6.5.tar.gz
    rm -rf rancher-linux-amd64-v0.6.5.tar.gz
    cd rancher-v0.6.5/
    sudo mv rancher /bin 
    mkdir -p /root/.rancher
    cd /root/.rancher
    
    # First environment is ALWAYS 1a5 
    printf '{"url":"http://'$MASTERIP':8080/v2-beta/schemas","environment":"1a5"}' >> cli.json
    rancher env rm Default #remove default environment 
    sleep 5
    rm cli.json
    printf '{"url":"http://'$MASTERIP':8080/v2-beta/schemas","environment":"1a7"}' >> cli.json
    rancher env create -t kubernetes EDCOP
    
    # Creating Rancher Agent
    pip install --upgrade pip rancher-agent-registration
    rancher-agent-registration --url http://$MASTERIP:'8080' --key "" --secret "" --host-ip "$MASTERIP"
    echo "Kubernetes is launching... (This will take 5 minutes)" 
    sleep 5m  # wait for Kubernetes to launch 
	
    # Configure kubectl
    cd /root/.kube/
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
    # Label master host
    kubectl label nodes $(hostname) nodetype=master --overwrite
	
    # Deploying applications onto the master node
    echo "Deploying applications..."
    cd ~/$EDCOPDIR/kubernetes/elasticsearch
    kubectl apply -f elasticsearch-master.yaml 
    sleep 5
    kubectl apply -f elasticsearch-master-service.yaml
    sleep 30   #sleep for 30 to allow elasticsearch to start
    cd ~/$EDCOPDIR/kubernetes/kibana
    kubectl apply -f kibana.yaml
    sleep 5 
    kubectl apply -f kibana-service.yaml 
    cd ~/$EDCOPDIR/kubernetes/moloch-master
    kubectl apply -f moloch-master.yaml
    echo 'Master node initialized' 
    kubectl get nodes 
    echo 'Kubernetes envirionment created' 
    rancher environment ps  
}

check() #IP VALIDATION 
{
        IP
}

IP
Dependecy_Setup
echo "dependencies installed"
buildContainers
RancherEnvrionment
echo "Now creating EDCOP Envrionment..." 
echo 'The Rancher server will be located at http://'$MASTERIP':8080'
echo 'The Kibana webviewer will be located at http://'$MASTERIP':30002'
echo 'The Elasticssearch cluster is located at http://'$MASTERIP':30000'

# Reload the firewall for moloch now that it's started
sudo firewall-cmd --reload 
