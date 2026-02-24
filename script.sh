#!/bin/bash
apt-get update
cd /home/ubuntu
sudo add-apt-repository ppa:openjdk-r/ppa
sudo apt-get update
sudo apt-get install unzip -y
sudo apt-get install openjdk-21-jdk -y
sudo apt install openjdk-21-jre -y

wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.6.2.tgz
tar -xzf apache-jmeter-5.6.2.tgz
rm apache-jmeter-5.6.2.tgz
echo "Hi PDi" >/home/ubuntu/index.nginx-debian.html
   # Set environment variables#!/bin/bash

sudo apt-get install cifs-utils -y
sudo mkdir -p /mnt/PRL_Test_Results
sudo mkdir -p /mnt/share
sudo mount -t cifs -o username=Administrator,password='hLfm=5SnxaRZQ?4ghk*@SUTD8&7QYEcn' //10.70.5.6/mnt/share /mnt/share
echo "Network drive mounted at /mnt/share"

sudo wget https://jmeter-plugins.org/files/packages/jpgc-csvars-0.1.zip
sudo wget https://jmeter-plugins.org/files/packages/jpgc-json-2.7.zip
sudo wget https://go.microsoft.com/fwlink/?linkid=2262747
sudo wget https://downloads.apache.org/commons/csv/binaries/commons-csv-1.11.0-bin.zip

unzip sqljdbc_12.6.1.0_enu.zip
unzip jpgc-csvars-0.1.zip
unzip jpgc-json-2.7.zip
unzip commons-csv-1.11.0-bin.zip

sudo cp /home/ubuntu/commons-csv-1.11.0-bin/commons-csv-1.11.0/commons-csv-1.11.0.jar /home/ubuntu/apache-jmeter-5.6.2/lib/ext/
sudo cp /home/ubuntu/sqljdbc_12.6.1.0_enu/sqljdbc_12.6/enu/jars/mssql-jdbc-12.6.1.jre8.jar /home/ubuntu/apache-jmeter-5.6.2/lib/ext/
sudo cp /home/ubuntu/lib/ext/jmeter-plugins-csvars-0.1.jar /home/ubuntu/apache-jmeter-5.6.2/lib/ext/
sudo cp /home/ubuntu/lib/ext/jmeter-plugins-json-2.7.jar /home/ubuntu/apache-jmeter-5.6.2/lib/ext/

sudo rm -rf lib commons-csv-1.11.0-bin sqljdbc_12.6.1.0_enu
sudo chmod 777 -R /home/ubuntu/apache-jmeter-5.6.2
sudo chmod 777-R /home/ubuntu
export JMETER_HOME=/home/ubuntu/apache-jmeter-5.6.2
export PATH=$PATH:$JMETER_HOME/bin
source /etc/environmentecho "Downloading and installing ${plugin_name} version ${version}..."
cd /home/ubuntu/apache-jmeter-5.6.2/lib/ext/
sudo wget https://repo1.maven.org/maven2/kg/apc/jmeter-plugins-manager/1.6/jmeter-plugins-manager-1.6.jar
sudo wget  https://repo1.maven.org/maven2/kg/apc/jmeter-plugins-manager/1.9/jmeter-plugins-manager-1.9.jar
sudo wget  https://repo1.maven.org/maven2/kg/apc/jmeter-plugins-manager/1.3/jmeter-plugins-manager-1.3.jar
sudo wget https://repo1.maven.org/maven2/kg/apc/jmeter-plugins-dummy/0.4/jmeter-plugins-dummy-0.4.jar
sudo wget https://github.com/yciabaud/jmeter-ssh-sampler/releases/download/jmeter-ssh-sampler-1.2.0/ApacheJMeter_ssh-1.2.0.jar
sudo wget https://github.com/johrstrom/jmeter-prometheus-plugin/releases/download/0.7.1/jmeter-prometheus-plugin-0.7.1.jar

cd /home/ubuntu/apache-jmeter-5.6.2/lib/
sudo wget https://github.com/shashi-a2/jmeter_jar_files/releases/download/v2/mssql-jdbc-12.6.1.jre8.jar
sudo wget https://github.com/shashi-a2/jmeter_jar_files/releases/download/v2/commons-csv-1.11.0.jar
sudo wget https://repo1.maven.org/maven2/com/jcraft/jsch/0.1.55/jsch-0.1.55.jar

cd /home/ubuntu/apache-jmeter-5.6.2/bin/
PRIVATE_IP=$(hostname -I | awk '{print $1}')

set -e

# 1. Set paths
JMETER_BIN_PATH="/home/ubuntu/apache-jmeter-5.6.2/bin"
LOG4J_CONFIG_PATH="${JMETER_BIN_PATH}/log4j2.xml"
JMETER_USER="ubuntu"
JMETER_BAT_PATH="${JMETER_BIN_PATH}/jmeter.bat"
JMETER_SH_PATH="${JMETER_BIN_PATH}/jmeter.sh"

# 2. Set log level to ERROR (keep default log file name)
echo "Updating log4j2.xml to set log level to ERROR..."
sed -i 's|<Root level=".*">|<Root level="error">|' "$LOG4J_CONFIG_PATH"

# 3. Ensure bin directory is owned by ubuntu user
echo "Ensuring ownership of $JMETER_BIN_PATH for user $JMETER_USER..."
sudo chown "$JMETER_USER:$JMETER_USER" "$JMETER_BIN_PATH"

# 4. Comment out heap dump setting in jmeter.bat (Windows)
if [[ -f "$JMETER_BAT_PATH" ]]; then
    sed -i.bak 's/^set DUMP=-XX:+HeapDumpOnOutOfMemoryError/REM set DUMP=-XX:+HeapDumpOnOutOfMemoryError/' "$JMETER_BAT_PATH"
    echo "Heap dump setting commented in jmeter.bat"
fi

# 5. Comment out heap dump setting in jmeter.sh (Linux)
if [[ -f "$JMETER_SH_PATH" ]]; then
    sed -i.bak 's/^DUMP="-XX:+HeapDumpOnOutOfMemoryError"/# DUMP="-XX:+HeapDumpOnOutOfMemoryError"/' "$JMETER_SH_PATH"
    echo "Heap dump setting commented in jmeter.sh"
fi

# 6. Done
echo "JMeter configuration complete"
echo "   → Log file: $JMETER_BIN_PATH/jmeter.log (default)"
echo "   → Log level: ERROR"
echo "   → Heap dump settings disabled"

   # Get the publicip
public_ip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
sudo echo "RMI_HOST_DEF=-Djava.rmi.server.hostname=$public_ip" >> /home/ubuntu/apache-jmeter-5.6.2/bin/jmeter-server
sudo echo "server.rmi.ssl.disable=true" >> /home/ubuntu/apache-jmeter-5.6.2/bin/user.properties

OLD_VALUE='-Xms1g -Xmx1g -XX:MaxMetaspaceSize=256m'
NEW_VALUE='-Xms8g -Xmx12g -XX:MaxMetaspaceSize=256m'
sudo sed -i "s|${OLD_VALUE}|${NEW_VALUE}|g" /home/ubuntu/apache-jmeter-5.6.2/bin/jmeter

sudo ufw enable -y
sudo ufw allow 22
sudo ufw allow 1099
sudo ufw allow 50000
sudo ufw allow 4445
cd /home/ubuntu/apache-jmeter-5.6.2/lib
sudo wget https://repo1.maven.org/maven2/com/jcraft/jsch/0.1.55/jsch-0.1.55.jar
cd /home/ubuntu/apache-jmeter-5.6.2/bin
sudo ./jmeter-server -Dserver.rmi.localport=50000 -Dserver_port=1099 -Djava.rmi.server.hostname="$public_ip" -Jserver.rmi.ssl.disable=true > /dev/null 2>&1 &

echo 'ubuntu  ALL=(ALL:ALL) ALL' >> /etc/sudoers