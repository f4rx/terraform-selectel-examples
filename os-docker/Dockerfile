FROM ubuntu:18.04
RUN apt update && apt-get install -y locales
RUN echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && locale-gen
RUN apt -y -qq install python-openstackclient && \
    apt -y -qq install curl python-pip python-dev python3-dev git libxml2-dev libxslt1-dev python-openssl python3-openssl python-pyasn1 libffi-dev libssl-dev build-essential
RUN apt install -y python-oslo.log bash-completion
RUN pip install python-octaviaclient
RUN openstack complete > /etc/bash_completion.d/openstack
RUN echo "source /etc/bash_completion" >> /root/.bashrc && echo "source /etc/bash_completion.d/openstack" >> /root/.bashrc && \
    echo "OK"


