FROM centos:latest
RUN yum -y install epel-release
RUN yum -y update && \
        yum -y install sudo supervisor git cmake make gcc gcc-c++ flex bison libpcap-devel openssl-devel python-devel swig zlib-devel GeoIP-devel libpcap gperftools vim-minimal wget kernel-headers kernel-devel kernel
RUN yum -y install --enablerepo=C7.3.1611-base "kernel-devel-uname-r == $(uname -r)" && \
        wget https://www.bro.org/downloads/bro-2.5.tar.gz && \
        tar xzf bro-2.5.tar.gz && \
        cd bro-2.5 && \
        #split the configure and make \
        ./configure && \
        make install && \
        cd /
RUN yum upgrade
RUN     git clone https://github.com/J-Gras/bro-af_packet-plugin.git && \
        cd bro-af_packet-plugin && \
        ./configure --bro-dist=/bro-2.5 && \
        make && \
        make install && \
        yum -y clean all

ADD startbro.sh /startbro.sh
ADD reset-network.sh /reset-network.sh
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN chmod +x /startbro.sh && \
    chmod +x /reset-network.sh && \
    ./startbro.sh

WORKDIR /usr/local/bro/logs/

CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]
