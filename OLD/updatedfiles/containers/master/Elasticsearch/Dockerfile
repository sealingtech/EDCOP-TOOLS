FROM docker.elastic.co/elasticsearch/elasticsearch:5.5.0
ADD elasticsearch.yml /usr/share/elasticsearch/config/

USER root
RUN yum -y update && \
	yum -y install net-tools && \
	chown elasticsearch:elasticsearch config/elasticsearch.yml && \
        bin/elasticsearch-plugin install io.fabric8:elasticsearch-cloud-kubernetes:5.5.0 && \
	yum -y clean all

USER elasticsearch

EXPOSE 9200
EXPOSE 9300
