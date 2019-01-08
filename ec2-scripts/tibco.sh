#!/bin/bash

export GIT_TIB_URL=https://raw.githubusercontent.com/TIBCOSoftware/bw6-plugin-maven
export TIB_MAVEN_ZIP_NAME=TIB_BW_Maven_Plugin_2.1.0.zip
export TIB_BW_VERSION=6.5

# install bw/bwce maven plugin
cd /tmp
wget --no-check-certificate --content-disposition ${GIT_TIB_URL}/master/Installer/${TIB_MAVEN_ZIP_NAME}
unzip ${TIB_MAVEN_ZIP_NAME} -d TIB_BW_Maven
cd TIB_BW_Maven
chmod +x install.sh
mkdir /opt/tibco
echo /opt/tibco | ./install.sh
cd /opt/tibco/bw/${TIB_BW_VERSION}/maven/plugins/bw6-maven-plugin
./install.sh

#install bwce docker 
cd /opt/tibco
mkdir bwce
cd bwce
wget --no-check-certificate --content-disposition $1
unzip bwce_docker.zip
cd docker/resources/bwce-runtime
wget --no-check-certificate --content-disposition $2
cd /opt/tibco/bwce/docker
docker build -t bwce:latest .

chown -R jenkins:jenkins /opt/tibco
