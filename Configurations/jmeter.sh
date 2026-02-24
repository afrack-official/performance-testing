#!/bin/bash
# Get the publicip
cd /home/ubuntu
unzip apache-jmeter.zip
public_ip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
sudo echo "RMI_HOST_DEF=-Djava.rmi.server.hostname=$public_ip" >> /home/ubuntu/apache-jmeter-5.6.2/bin/jmeter-server
sudo echo "server.rmi.ssl.disable=true" >> /home/ubuntu/apache-jmeter-5.6.2/bin/user.properties
cd /home/ubuntu/apache-jmeter-5.6.2/bin
sudo ./jmeter-server -Dserver.rmi.localport=50000 -Dserver_port=1099 -Djava.rmi.server.hostname="$public_ip" -Jserver.rmi.ssl.disable=true > /dev/null 2>&1 &