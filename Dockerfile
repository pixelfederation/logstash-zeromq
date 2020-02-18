FROM jruby:9
ARG LOGSTASH_ZEROMQ_VERSION=0.2.3

WORKDIR /tmp/build

ADD https://github.com/zlosim/logstash-integration-zeromq/archive/v$LOGSTASH_ZEROMQ_VERSION.tar.gz logstash-zeromq.tar.gz

RUN tar -xzvf logstash-zeromq.tar.gz && \
    cd logstash-integration-zeromq-$LOGSTASH_ZEROMQ_VERSION && \
    bundle install && \
    gem build logstash-integration-zeromq.gemspec

FROM docker.elastic.co/logstash/logstash:7.1.1

ARG LOGSTASH_ZEROMQ_VERSION=0.2.3

USER root

COPY --from=0 /tmp/build/logstash-integration-zeromq-$LOGSTASH_ZEROMQ_VERSION/logstash-integration-zeromq-$LOGSTASH_ZEROMQ_VERSION.gem /opt/logstash-integration-zeromq-$LOGSTASH_ZEROMQ_VERSION.gem
ADD https://download.opensuse.org/repositories/network:/messaging:/zeromq:/release-stable/CentOS_7/network:messaging:zeromq:release-stable.repo /etc/yum.repos.d/zeromq:release-stable.repo
ADD https://github.com/lukewaite/logstash-input-cloudwatch-logs/releases/download/v1.0.3/logstash-input-cloudwatch_logs-1.0.3.gem /opt/logstash-input-cloudwatch_logs-1.0.3.gem
ADD http://springdale.math.ias.edu/data/puias/unsupported/7/x86_64//openpgm-5.2.122-2.sdl7.x86_64.rpm /root/openpgm-5.2.122-2.sdl7.x86_64.rpm

RUN rpm -Uvh /root/openpgm-5.2.122-2.sdl7.x86_64.rpm && \
    yum install -y libzmq5 haveged && \
    ln -sf /usr/lib64/libzmq.so.5 /usr/local/lib/libzmq.so

RUN logstash-plugin install --no-verify /opt/logstash-input-cloudwatch_logs-1.0.3.gem && \
    logstash-plugin install --no-verify /opt/logstash-integration-zeromq-$LOGSTASH_ZEROMQ_VERSION.gem && \
    logstash-plugin install --version 7.0 logstash-output-amazon_es

RUN yum clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /root/openpgm-5.2.122-2.sdl7.x86_64.rpm

USER logstash
