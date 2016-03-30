FROM ubuntu:trusty

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates \
    apt-transport-https \
    gnupg \
    wget

RUN wget https://repos.influxdata.com/influxdb.key && \
    gpg --import influxdb.key && \
    rm -f influxdb.key

# Note the use of `get.influxdb.com/telegraf` which differs from the
# other TICK product Dockerfiles.
ENV TELEGRAF_VERSION 0.11.1
RUN wget https://s3.amazonaws.com/get.influxdb.org/telegraf/telegraf_$TELEGRAF_VERSION-1_amd64.deb.asc && \
    wget https://s3.amazonaws.com/get.influxdb.org/telegraf/telegraf_$TELEGRAF_VERSION-1_amd64.deb && \
    gpg --verify telegraf_$TELEGRAF_VERSION-1_amd64.deb.asc telegraf_$TELEGRAF_VERSION-1_amd64.deb && \
    dpkg -i telegraf_$TELEGRAF_VERSION-1_amd64.deb && \
    rm -f telegraf_$TELEGRAF_VERSION-1_amd64.deb*

EXPOSE 8125 8092 8094

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["telegraf", "-config", "/etc/telegraf/telegraf.conf"]