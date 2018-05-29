FROM centos:latest

RUN yum -y update && yum -y install epel-release && \
	yum -y install jq wget nodejs bzip2 curl net-tools fontconfig freetype freetype-devel fontconfig-devel libyaml-devel libpcap-devel libstdc++ ethtool pcre tcpdump pcre-devel libyaml pkgconfig flex bison gcc-c++ zlib-devel e2fsprogs-devel openssl-devel file-devel make gettext libuuid-devel perl-JSON bzip2-libs bzip2-devel perl-libwww-perl libpng-devel xz libffi-devel GeoIP vim && \
	wget https://files.molo.ch/builds/centos-7/moloch-1.1.0-1.x86_64.rpm && \
	rpm -i moloch-1.1.0-1.x86_64.rpm

ADD scripts/docker-entrypoint.sh /data/moloch/docker-entrypoint.sh

ENV ES_HOST elasticsearch
ENV NETWORK_INTERFACE eth0
ENV CLUSTER_PW secretpw
ENV ADMIN_PW supersecretpw

RUN chmod +x /data/moloch/*.sh && \
	chmod +x /data/moloch/db/db.pl /data/moloch/*/*.sh && \
	cd /data/moloch/viewer && \
	ln -s /data/moloch/bin/node /usr/bin/nodejs && \
	/data/moloch/bin/npm update && \
	/data/moloch/bin/npm install . && \
	yum clean -y all

EXPOSE 8005

WORKDIR /data/moloch

ENTRYPOINT ["./docker-entrypoint.sh"]
