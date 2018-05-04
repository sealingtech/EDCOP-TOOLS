FROM docker.elastic.co/logstash/logstash:6.2.4

RUN rm -f /usr/share/logstash/pipeline/logstash.conf

USER root
RUN yum -y update && \
	yum -y install net-tools && \
	/usr/share/logstash/bin/logstash-plugin update logstash-output-elasticsearch && \
	yum -y clean all
USER logstash

#ADD pipeline /usr/share/logstash/pipeline/
ADD logstash.yml /usr/share/logstash/config/logstash.yml

EXPOSE 5044
