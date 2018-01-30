#High Level Process of Building Capabilities Inside EDCOP
The following process is considered best practice for creating new capabilities inside of EDCOP.

The general process for developing capabilities inside of EDCOP are as follows:
-Plan Design
-Build Docker container
-Create Helm Package
-Test

#Plan Design
The first step is to understand what your goals are for creating this capability and what components will be needed.  Often a capability will need multiple containers to function properly.  See the Design Guide for information on how pods should be structured.  Some things to bear in mind:
1. Containers should only carry software.  Kubernetes will lay down all configurations.  Any user configurations will be done using Helm.  More on this in later steps.  This will allow containers to be reused in different pods across the architecture.  
2. Each container should only have a single process in it.  For sharing information between containers the preffered mechanism is using network to localhosts.  It is also possible to share volumes between pods so one container writes and the other containers picks up these files.  http://blog.kubernetes.io/2015/06/the-distributed-system-toolkit-patterns.html
3. Containers should be designed to be short lived.  This should be bared in mind where possible:

```"In the old way of doing things, we treat our servers like pets, for example Bob the mail server. If Bob goes down, it’s all hands on deck. The CEO can’t get his email and it’s the end of the world. In the new way, servers are numbered, like cattle in a herd. For example, www001 to www100. When one server goes down, it’s taken out back, shot, and replaced on the line."```

-source: http://cloudscaling.com/blog/cloud-computing/the-history-of-pets-vs-cattle/

In Kubernetes it is assumed that containers will be forever shifting and moving around.  Upgrades no longer take place, instead we simply replace the containers.  In cases where we require persistence care must be made to ensure data isn't lost.  This can come from persistent volumes.  See the design guide for information on options for this.

#Building Docker Containers
A container is needed to start this process.  There are some rules that must be followed to maintain standardization across the platform. 

First step is to build the container.  It is necessary to first start with a particular base image.  When building from scratch we reccomend the Centos container.  It is possible to use Docker Hub, but bear in mind that the source of images should be looked at.  If questions arise, talk it through with the rest of the team.  The container must be built in a manner that is automated using Dockerfiles.   
From: Which container the base image is from.  Use latest so that the container can be built and rebuilt for updates.
Maintainer: Your name and email for when there are questions.

Containers will be build inside of here:
EDCOP-TOOLS/containers

Create a new directory for your tool name.

After this the steps to isntall your software are next.  This usually involves adding repositories, downloading software, etc.  In this example the container is building Suricata from source code.  When building, development libraries often aren't needed after it is built, so clean those up.  Always run yum clean all at the end.  Finally your initial script should be named docker-entrypoint.sh (this is not always followed, but is generally a good convention.  This should be a small shell script that starts up your software.  Place the docker-extrypoint.sh file in the same directory as the the Dockerfile. Make sure this file is executable.  

```FROM centos:latest
MAINTAINER Ed Sealing <ed.sealing@sealingtech.org>

#Install required libraries
RUN yum -y update && \
        yum -y install epel-release && \
        yum -y install GeoIP file libpcap htop net-tools vim libnet libtool libedit libarchive libmnl libmpc libnfnetlink libyaml lzo rsync libnetfilter_queue jansson tcpdump hiredis.x86_64 hiredis-devel.x86_64&& \
        yum -y install automake autoconf git libtool make gcc gcc-c++ libyaml-devel libpcap-devel pcre-devel file-devel zlib-devel jansson-devel nss-devel libcap-ng-devel libnet-devel libnetfilter_queue-devel lua-devel which bzip2-devel GeoIP-devel python-pyelftools GeoIP-devel cmake rpm-build ruby ruby-libs ruby-irb rubygems ruby-devel sqlite-devel && \
        gem install fpm && \
        mkdir /tmp/{build,hyperscan,ragel,boost-1.64,suricata,rpms} && \
        cd /tmp/build && \
        curl -L -O http://www.colm.net/files/ragel/ragel-6.9.tar.gz && \
        tar xzf ragel-6.9.tar.gz && \
        cd ragel-6.9 && \
        ./configure --prefix=/usr && \
        make && \
        make install DESTDIR=/tmp/ragel && \
        fpm --prefix=/ -s dir -t rpm -n ragel -v 6.9 -C /tmp/ragel -p /tmp/rpms/ && \
        yum -y localinstall /tmp/rpms/ragel*.rpm && \
        cd /tmp/build && \
        curl -L -o boost_1_64_0.tar.gz https://dl.bintray.com/boostorg/release/1.64.0/source/boost_1_64_0.tar.gz && \
        tar xzf boost_1_64_0.tar.gz && \
        cd boost_1_64_0 && \
        ./bootstrap.sh --prefix=/tmp/boost-1.64 --with-libraries=graph && \
        ./b2 install && \
        cd /tmp/build && \
        git clone https://github.com/01org/hyperscan && \
        mkdir -p ./hyperscan/build && \
        cd hyperscan/build && \
        cmake -DCMAKE_INSTALL_PREFIX:PATH=/tmp/hyperscan -DBUILD_STATIC_AND_SHARED=1 -DBOOST_ROOT=/tmp/boost-1.64/ ../ && \
        make && \
        make install && \
        fpm --prefix=/usr/ -s dir -t rpm -n hyperscan -v 4.3.1 -d 'ragel' -C /tmp/hyperscan -p /tmp/rpms/ && \
        yum -y localinstall /tmp/rpms/hyperscan*.rpm && \
        cd /tmp/build && \
        curl -L -O https://www.openinfosecfoundation.org/download/suricata-4.0.1.tar.gz && \
        tar xzf suricata-4.0.1.tar.gz && \
        cd suricata-4.0.1 && \
        ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --enable-hiredis --enable-nfqueue --with-libhs-libraries=/usr/lib/ --with-libhs-includes=/usr/include/hs/ --enable-lua --enable-geoip && \
        make && \
        make install-full DESTDIR=/tmp/suricata && \
        fpm --prefix=/ -s dir -t rpm -n suricata -v 4.0.1 -C /tmp/suricata/ -p /tmp/rpms/ && \
        yum -y localinstall /tmp/rpms/{hyperscan-*.rpm,ragel-*.rpm,suricata-*.rpm} && \
        ldconfig && \
        cd / && \
        echo y | gem uninstall fpm && \
        yum -y erase automake autoconf git make gcc gcc-c++ libyaml-devel libpcap-devel pcre-devel file-devel zlib-devel nss-devel libcap-ng-devel libnet-devel libnetfilter_queue-devel lua-devel bzip2-devel GeoIP-devel python-pyelftools GeoIP-devel cmake rpm-build ruby ruby-libs ruby-irb rubygems ruby-devel bzip2 dwz elfutils fipscheck fipscheck-lib gdb libgnome-keyring libnfnetlink-devel libstdc++-devel nspr-devel nss-softokn-devel nss-softokn-freebl-devel nss-util-devel openssh openssh-clients perl-Error perl-Git perl-TermReadKey perl-srpm-macros python-construct python-six redhat-rpm-config rubygem-bigdecimal rubygem-io-console rubygem-json rubygem-psych rubygem-rdoc unzip zip sqlite-devel && \
        rm -rf /tmp/{hyperscan,suricata,ragel,boost-1.64,build,rpms} && \
        yum -y clean all

RUN yum -y install wget
        

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x docker-entrypoint.sh
RUN cp docker-entrypoint.sh /bin
RUN mkdir -p /logs/suricata

ENTRYPOINT ["docker-entrypoint.sh"]
```



One thing to note at this stage, we are not concerned with configuration, that will come later.  What should be understood about the container:  

1. Where are my configuration files that need to be manipulated?  Find these files and save them off to a location for later use.
2. Is the container writing any information that should remain persistent?

To build the container start in the same directory as the filename and run the command:

```docker build -t edcop-master:5000/<name of container>```

This will build the container and place it in the local docker repository.  Next push it to the shared repository, this is to make the container available to all hosts.  Note, that if you are outside of the cluster you must be able to DNS lookup the edcop-master hostname.  /etc/hosts is a good way to do this.
```docker push edcop-master:5000/<name of container>```

If you want to use a container from Docker Hub with no changes (don't need to do anything to the configuration).  Follow these steps:
```docker pull <docker container name>
docker tag <docker container name> edcop-master:5000/<tool name>
docker push edcop-master:5000/<tool name>```

Note: At some point we will probably change how the repository is handled.

# Create Helm
Helm will be the tool that will deploy and configure containers inside the cluster.  Follow the pod design as closely as possible but generally a helm package will require the following:
1. A pod (of type deployment, a daemonset or a replicaset)
2. A service if the pod needs to be addressable by the outside world
3. An ingress if the service needs to be externally accessible and can't use a node port
4. ConfigMaps to configure the container.

In Github repository start in charts and create a new directory with the name of the tool.
charts

Some notes about best practices that must be followed:
1. Tabs must be two spaces.  This is to keep things consistent.  Space matters in Kubernetes.  It is a good idea to use a text editor that lets you set this.
2. Value names should be camelCase. This is reccomended by Hlem, best to keep it consistent.
3. Always provide defaults designed for a small, single node deployment.  Large scale deployments will need care to properly size these containers and will need to be done on a case by case basis.
Create the helm directory structure using the command:
```helm create <tool name>```
Edit the following files:
Chart-Yaml
```
apiVersion: v1
name: suricata
home: https://github.com/sealingtech/EDCOP
version: 0.1.0
description: EDCOP Suricata Chart
details:
  This Chart provides an inline Suricata daemonset for use with the EDCOP project.
```

Add a useful name, version, description, details and home.  

See the helm developers guide as this document will not detail all the steps required: https://docs.helm.sh/chart_template_guide/#the-chart-template-developer-s-guide

Next delete the sample Values.yaml and anything in the templates directory.  Those are just samples.  Add a pod (see sample):
https://github.com/sealingtech/EDCOP-TOOLS/blob/master/charts/suricata-pod/chart/templates/suricata-daemonset.yaml

To create configmaps, the best method I have found was to manually create these by hand.  To to do this for volume containing multiple config files.:
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: logstash-{{ template "suricata.fullname" . }}-<tool name>
apiVersion: v1
data:
  <file name in directory>: |
  Config file here.....
  
```
Take the configuration and then paste the information into the configmap.  Ensure that you are using two spaces at all times. Add your necessarry markup as needed.

For configmap sample: 
https://github.com/sealingtech/EDCOP-TOOLS/blob/master/charts/suricata-pod/chart/templates/suricata-config.yaml

Once this is done, ensure that your pods can deploy using "helm install ." from the chart directory.  Test to ensure this works.  Next step is to allow users to configure templates.  To do this, use the Helm markup language and values.  Look at samples of how it is done plus the developers guide. https://github.com/sealingtech/EDCOP-TOOLS/blob/master/charts/suricata-pod/chart/values.yaml

Some values that must be configurable for all tools per EDCOP (with sane defaults specified in the design guide):
- CPU and memory limits for all containers
- Kubernetes networks
- Node Selectors
- Environment variables
- repository
- Hostpath and persistent volumes

All settings should have a comment above the setting about what it does.  In pods containing multiple containers, seperate these by by the container names.


The convention these tools will follow are:

```
image:
  repository: edcop-master:5000
networks:
  # Overlay is the name of the default cni network
  overlayNet: calico
  # Net 1 is the name of the first sriov interface
  net1: passive 
  # Net 2 is the name of the second sriov interface  This will be ignored in passive
  net2: inline-2
volumes:
  # Persistent data location on the host to store suricata's logs
  logs:
    hostPath: /var/EDCOP/data/logs/suricata

nodeSelector:
  sensor: true
  environment: Default
Container1:
  #This value does XYZ....
  valueOne: false 
Container2:
  #This value does XYZ
  valueOne: false

```



  


