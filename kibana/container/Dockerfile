FROM docker.elastic.co/kibana/kibana:6.1.1

ADD kibana.yml /usr/share/kibana/config/kibana.yml

USER root
RUN yum -y update && \
	yum -y install net-tools && \
	yum -y clean all
USER kibana 

EXPOSE 5601
