FROM docker.elastic.co/elasticsearch/elasticsearch:5.6.0
ADD elasticsearch.yml /usr/share/elasticsearch/config/

USER root
RUN yum -y update && \
	yum -y install net-tools && \
	chown elasticsearch:elasticsearch config/elasticsearch.yml && \
	yum -y clean all

USER elasticsearch

EXPOSE 9200
EXPOSE 9300
