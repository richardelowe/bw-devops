#!/bin/bash

export GIT_TIB_URL=https://raw.githubusercontent.com/TIBCOSoftware/bw6-plugin-maven

# install bw/bwce maven plugin
cd /tmp
wget --no-check-certificate --content-disposition ${GIT_TIB_URL}/master/Installer/TIB_BW_Maven_Plugin_1.2.1.zip
unzip TIB_BW_Maven_Plugin_1.2.1.zip -d TIB_BW_Maven
cd TIB_BW_Maven
chmod +x install.sh
mkdir /opt/tibco
echo /opt/tibco | ./install.sh
cd /opt/tibco/bw/6.3/maven/plugins/bw6-maven-plugin
./install.sh

#install bwce docker 
cd /opt/tibco
mkdir bwce
cd bwce
wget --no-check-certificate --content-disposition $1
unzip bwce_docker.zip
cd docker/resources/bwce-runtime
wget --no-check-certificate --content-disposition $2
docker build -t bwce:latest .

chown -R jenkins:jenkins /opt/tibco
