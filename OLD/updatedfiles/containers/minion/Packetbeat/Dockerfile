FROM docker.elastic.co/beats/packetbeat:5.5.0
COPY packetbeat.yml /usr/share/packetbeat/packetbeat.yml
USER root
RUN chown packetbeat /usr/share/packetbeat/packetbeat.yml && \
	yum -y update && \
	yum -y install net-tools && \
	yum -y clean all

USER packetbeat


