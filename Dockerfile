FROM docker.elastic.co/logstash/logstash:5.6.7

USER root
ADD https://teration.net/logstash-mixin-zeromq-4.0.0.gem /opt/logstash-mixin-zeromq-4.0.0.gem
ADD https://download.opensuse.org/repositories/network:/messaging:/zeromq:/release-stable/CentOS_7/network:messaging:zeromq:release-stable.repo /etc/yum.repos.d/zeromq:release-stable.repo

RUN yum install -y libzmq5 && \
    logstash-plugin install --no-verify /opt/logstash-mixin-zeromq-4.0.0.gem && \
    logstash-plugin install logstash-input-zeromq logstash-output-zeromq && \
    yum clean all && \
    rm -rf /var/cache/yum

USER logstash
