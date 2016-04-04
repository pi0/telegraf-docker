# Telegraf

Telegraf is an open source agent written in Go for collecting metrics
and data on the system it's running on or from other services.
Telegraf writes data it collects to InfluxDB in the correct format.

[Telegraf Official Docs](https://docs.influxdata.com/telegraf/latest/introduction/getting-started-telegraf/)

## Using this image

##### Exposed Ports

-	8125 StatsD
-	8092 UDP
-	8094 TCP

##### Using default config

The default configuration requires a running InfluxDB instance as an output plugin. Ensure that InfluxDB is running on port 8086 before starting the Telegraf container.

Minimal example to start an InfluxDB container

	docker run -p 8083:8083 -p 8086:8086 influxdb

Starting Telegraf using default config

	docker run --net=host telegraf

##### Using a custom config file

First generate a sample configuration and save it under `/path/on/host/telegraf.conf` on the host:

    docker run --rm \
       telegraf telegraf -sample-config > /path/on/host/telegraf.config

Then, once you've customised `/path/on/host/telegraf.conf`, you can run the Telegraf container with the configuration file mounted in the shared volume Telegraf expects to find its configuration:

    docker run -v /path/on/host/:/etc/telegraf:ro \
           telegraf

Read more about the Telegraf configuration [here](https://docs.influxdata.com/telegraf/latest/introduction/configuration/)

##### Using the container with input plugins

These examples assume you are using a custom configuration file which
you're mounting into the container as a shared volume.

In each case you need to create a Docker bridge network. For these
examples we'll assume that the following command has been run:

    docker network create --driver bridge telegraf_nw

###### Aerospike

First start aerospike in a container, ensuring it's added to the
`telegraf_nw` bridge network:

    docker run -d \
           --net=telegraf_nw \
           --name aerospike \
           -p 3000:3000 -p 3001:3001 -p 3002:3002 -p 3003:3003 \
           aerospike

Edit your Telegraf config file and specify the correct aerospike host
and port:

	[[inputs.aerospike]]
	        servers = ["aerospike:3000"]

Start the InfluxDB container:

    docker run -d -P \
           --net=telegraf_nw \
           --name influxdb \
           influxdb

Configure it correctly as an output plugin in your Telegraf config:

	[[outputs.influxdb]]
	      urls = ["http://influxdb:8086"]
	      database = "telegraf"
	      precision = "s"
	      timeout = "5s"

Start Telegraf as follows, assuming your Telegraf configuration file is located at `/path/on/host/telegraf.conf`:

    docker run -d \
           --net=telegraf_nw \
           -v /path/on/host:/etc/telegraf:ro \
           telegraf

###### Nginx

Assuming an nginx configuration at `/path/on/host/nginx.conf`, modify the nginx default config:

	    server {
	        listen 8090;
	        location /nginx_status {
	            stub_status on;
	            access_log on;
	        }
	    }

Start the nginx container:

    docker run --name=nginx \
           --net=telegraf_nw \
           -p 8090:8090 -p 8080:80 \
           -v /path/on/host:/etc/nginx:ro \
           nginx

Verify the status page : [http://localhost:8090/nginx_status](http://localhost:8090/nginx_status).

Configure the nginx input plugin on your Telegraf configuration:

    [[inputs.nginx]]
      urls = ["http://nginx/nginx_status"]

Run Telegraf using the config file:

    docker run -d \
           --net=telegraf_nw \
           -v /path/on/host:/etc/telegraf:ro \
           telegraf

###### StatsD

Telegraf has a StatsD plugin, allowing Telegraf to run as a StatsD
server that metrics can be sent to. In order for this to work, you
must first configure the [StatsD plugin](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/statsd) in your config file.

Run Telegraf with the UDP port 8125 exposed:

    docker run -d \
           --net=telegraf_nw \
           -p 8125:8125/udp \
           -v /path/on/host:/etc/telegraf:ro \
           telegraf

Send Mock StatsD data

	    for i in {1..50}; do echo $i;echo "foo:1|c" | nc -u -w0 127.0.0.1 8125; done

Check that the measurement `foo` is added in the DB

### Supported Plugins

[Output](https://docs.influxdata.com/telegraf/latest/outputs/)

[Input](https://docs.influxdata.com/telegraf/latest/outputs/)

## Supported Docker versions

This image is officially supported on Docker version 1.10.1
