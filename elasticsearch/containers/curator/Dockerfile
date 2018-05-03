FROM centos:latest

RUN yum -y update && yum -y install epel-release && \ 
    yum -y install python-pip

RUN pip install -U --quiet elasticsearch-curator==5.5.1
RUN useradd -ms /bin/bash elasticsearch

USER elasticsearch

CMD ["/bin/bash"]
