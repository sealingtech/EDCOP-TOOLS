FROM docker.elastic.co/beats/filebeat:5.6.0

VOLUME /data

USER root
RUN chown filebeat /usr/share/filebeat/filebeat.yml && \
	yum -y update && \
	yum -y install net-tools && \
	yum -y clean all

#USER filebeat

ADD filebeat.yml /usr/share/filebeat/filebeat.yml
