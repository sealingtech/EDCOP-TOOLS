FROM docker.elastic.co/kibana/kibana:5.5.0

ADD kibana.yml /usr/share/kibana/config/kibana.yml

USER root
RUN yum -y update && \
	yum -y install net-tools && \
	yum -y clean all
USER kibana 

EXPOSE 5601