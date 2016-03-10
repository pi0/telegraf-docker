# Telegraf

Telegraf is an open source agent written in Go for collecting metrics and data on the system it's running on or from other services. Telegraf writes data it collects to InfluxDB in the correct format.

[Telegraf Documentation] (https://docs.influxdata.com/telegraf/v0.10/introduction/getting-started-telegraf/)


##Using this image

###Exposed Ports

- 8125 StatsD
- 8092 UDP
- 8094 TCP

- 80 and 443 are additional exposed Ports

###Running using default config
The default config resides on /etc/telegraf/telegraf.conf. However it requires a running influxdb instance as output plugin.

Ensure that influxdb is running on localhost and port 8086 is accessible.

Minimal example to start influxdb container
```
docker run -p 8083:8083 -p 8086:8086 influxdb   
```
Starting telegraf using default config
```
docker run --net=host telegraf
```

###Run using a supplied file
#####Using the config flag
```
docker run -i --name telegraf -v /path/on/host/:/root/ telegraf  -config /root/telegraf.conf
```
#####Mounting the host config file at the location of default file
```
docker run -i --name telegraf -v /tmp/telegraf.conf:/etc/telegraf/telegraf.conf:ro telegraf
```
Here the config file is /tmp/telegraf.conf on the host.

Read more about the telegraf configuration [here] (https://docs.influxdata.com/telegraf/v0.10/introduction/configuration/)


##Using the image with input plugins
#####Aerospike
Start aerospike on a container. (For this example aerospike, influxdb all run in containers)
```
docker run -tid --name aerospike -p 3000:3000 -p 3001:3001 -p 3002:3002 -p 3003:3003 aerospike
```
Edit the config file and add aerospike as a plugin
```
[[inputs.aerospike]]
        servers = ["172.17.0.2:3000"] 
```
Start influxDB, and add it as the output plugin
```
[[outputs.influxdb]]
      urls = ["http://172.17.0.3:8086"]     database = "telegraf"       precision = "s"
      timeout = "5s"
```
Start the telegraf by supplying it the modified config file

Check that the aerospike measurement is added in influxdb


#####Nginx
Modify the nginx default config
```    
    server {
        listen 8090;
        location /basic_status {
            stub_status on;
            access_log on;
        }
    }
```
Start the nginx container as such (nginx.conf is in /tmp/nginx.conf on host):- 
```
docker run -p 8090:8090  -p 8080:80 -v /tmp/nginx.conf:/etc/nginx/nginx.conf:ro  -v /tmp/:/usr/share/nginx/html:ro   nginx
```
Verify the status page : [http://localhost:8090/basic_status](http://localhost:8090/basic_status)

Run telegraf image supplying a config file

Check that the nginx measurement is added in influxdb

#####StatsD
Expose the UDP port 8125
```
docker run -i --name telegraf -v /path/on/host:/root/ -p 8125:8125/udp telegraf -config /root/telegraf.conf
````
Mock the statsD data
```
for i in {1..50}; do echo $i;echo "foo:1|c" | nc -u -w0 127.0.0.1 8125; done
```

Check that the measurement foo is added in the DB


###Supported Plugins
 - [Output] (https://docs.influxdata.com/telegraf/v0.10/outputs/)
 - [Input] (https://docs.influxdata.com/telegraf/v0.10/outputs/)
