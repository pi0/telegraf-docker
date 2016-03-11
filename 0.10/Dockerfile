FROM debian:jessie

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates apt-transport-https

RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 684A14CF2582E0C5 && \
    echo "deb https://repos.influxdata.com/debian jessie stable" > /etc/apt/sources.list.d/influxdata.list && \
    apt-get update 

ENV TELEGRAF_VERSION 0.10.4.1-1
RUN apt-get install -y telegraf=$TELEGRAF_VERSION

EXPOSE 8125 8092 8094

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["telegraf", "-config", "/etc/telegraf/telegraf.conf"]
