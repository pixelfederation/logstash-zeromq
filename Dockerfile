FROM docker.elastic.co/logstash/logstash:5.6.10

USER root
ADD https://teration.net/logstash-mixin-zeromq-4.0.0.gem /opt/logstash-mixin-zeromq-4.0.0.gem
ADD https://download.opensuse.org/repositories/network:/messaging:/zeromq:/release-stable/CentOS_7/network:messaging:zeromq:release-stable.repo /etc/yum.repos.d/zeromq:release-stable.repo
ADD https://github.com/lukewaite/logstash-input-cloudwatch-logs/releases/download/v1.0.3/logstash-input-cloudwatch_logs-1.0.3.gem /opt/logstash-input-cloudwatch_logs-1.0.3.gem
ADD http://springdale.math.ias.edu/data/puias/unsupported/7/x86_64//openpgm-5.2.122-2.sdl7.x86_64.rpm /root/openpgm-5.2.122-2.sdl7.x86_64.rpm

RUN rpm -Uvh /root/openpgm-5.2.122-2.sdl7.x86_64.rpm && \
    yum install -y libzmq5 && \
    ln -sf /usr/lib64/libzmq.so.5 /usr/local/lib/libzmq.so

RUN logstash-plugin install --no-verify /opt/logstash-mixin-zeromq-4.0.0.gem && \
    logstash-plugin install --no-verify /opt/logstash-input-cloudwatch_logs-1.0.3.gem && \
    logstash-plugin install logstash-input-zeromq logstash-output-zeromq && \
    logstash-plugin install --version 6.0.0 logstash-output-amazon_es

RUN yum clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /root/openpgm-5.2.122-2.sdl7.x86_64.rpm

USER logstash
