from centos:7

COPY startup.sh /docker-entrypoint.sh

RUN yum -y install iproute wget ethtool && yum -y clean all

RUN wget https://sourceforge.net/projects/e1000/files/i40e%20stable/2.4.3/i40e-2.4.3.tar.gz/download
RUN tar xvzf download

ENTRYPOINT /docker-entrypoint.sh
