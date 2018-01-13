FROM docker.elastic.co/beats/packetbeat:6.1.1
COPY packetbeat.yml /usr/share/packetbeat/packetbeat.yml
USER root
RUN chown packetbeat /usr/share/packetbeat/packetbeat.yml && \
	yum -y update && \
	yum -y install net-tools && \
	yum -y clean all

USER packetbeat


