FROM ubuntu:14.04

ENV TELEGRAF_VERSION 0.10

EXPOSE 8125
EXPOSE 8092
EXPOSE 8094

EXPOSE 80
EXPOSE 443

RUN apt-get update && \
    apt-get install -y wget

RUN wget http://get.influxdb.org/telegraf/telegraf_0.10.4.1-1_amd64.deb && \
    dpkg -i telegraf_0.10.4.1-1_amd64.deb && \
    rm telegraf_0.10.4.1-1_amd64.deb

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["telegraf", "-config", "/etc/telegraf/telegraf.conf"]
