FROM centos:latest

RUN yum -y update && yum -y install epel-release && \
    yum -y install wget bzip2 net-tools curl fontconfig freetype freetype-devel fontconfig-devel libpcap-devel libstdc++ ethtool pcre tcpdump pcre-devel libyaml pkgconfig flex bison gcc-c++ zlib-devel e2fsprogs-devel openssl-devel file-devel make gettext libuuid-devel perl-JSON bzip2-libs bzip2-devel perl-libwww-perl libpng-devel xz libffi-devel GeoIP vim && \
    wget https://files.molo.ch/builds/centos-7/moloch-0.19.0-1.x86_64.rpm && \
    rpm -i moloch-0.19.0-1.x86_64.rpm

ADD buildmoloch.sh /data/moloch/buildmoloch.sh
ADD startmoloch.sh /data/moloch/startmoloch.sh

USER root
RUN chmod +x /data/moloch/*.sh && \
    /data/moloch/buildmoloch.sh && \
    chmod +x /data/moloch/db/db.pl /data/moloch/*/*.sh && \
    cd /data/moloch/viewer && \
    /data/moloch/bin/npm update && \
    yum clean -y all

VOLUME ["/data/moloch/logs","/data/moloch/raw"]

EXPOSE 8005

WORKDIR /data/moloch

ENTRYPOINT ["/data/moloch/startmoloch.sh"]




