FROM docker.elastic.co/beats/filebeat:6.1.1

VOLUME /var/EDCOP/logs/bro

#ADD filebeat.yml /usr/share/filebeat/filebeat.yml

USER root
RUN chown filebeat /usr/share/filebeat/filebeat.yml && \
	yum -y update && \
	yum -y install net-tools && \
	yum -y clean all

USER filebeat


