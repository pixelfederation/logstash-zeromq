FROM docker.elastic.co/logstash/logstash:5.6.7

USER root
ADD https://teration.net/logstash-mixin-zeromq-4.0.0.gem /opt/logstash-mixin-zeromq-4.0.0.gem
ADD https://download.opensuse.org/repositories/network:/messaging:/zeromq:/release-stable/CentOS_7/network:messaging:zeromq:release-stable.repo /etc/yum.repos.d/zeromq:release-stable.repo

RUN yum install -y libzmq5 && \
    ln -sf /usr/lib64/libzmq.so.5 /usr/local/lib/libzmq.so

RUN logstash-plugin install --no-verify /opt/logstash-mixin-zeromq-4.0.0.gem && \
    logstash-plugin install logstash-input-zeromq logstash-output-zeromq

RUN yum clean all && \
    rm -rf /var/cache/yum

USER logstash
