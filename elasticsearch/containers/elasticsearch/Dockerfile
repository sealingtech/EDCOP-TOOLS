FROM docker.elastic.co/elasticsearch/elasticsearch:6.2.4
ADD elasticsearch.yml /usr/share/elasticsearch/config/

USER root
RUN yum -y update && \
	yum -y install net-tools && \
	chown elasticsearch:elasticsearch config/elasticsearch.yml && \
	yum -y clean all

ENV DISCOVERY_SERVICE es-discovery
ENV MEMORY_LOCK false

USER elasticsearch

EXPOSE 9200
EXPOSE 9300
