#!/bin/bash

export GIT_URL=https://raw.githubusercontent.com/eschweit-at-tibco/bw-devops/master
export GIT_TIB_URL=https://raw.githubusercontent.com/TIBCOSoftware/bw6-plugin-maven

yum -y install unzip > /tmp/yum-unzip.log 2>&1

# install maven
cd /tmp
wget http://www.eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
tar xzf apache-maven-3.3.9-bin.tar.gz
mkdir /usr/local/maven
mv apache-maven-3.3.9 /usr/local/maven/
alternatives --install /usr/bin/mvn mvn /usr/local/maven/apache-maven-3.3.9/bin/mvn 1
export M3_HOME=/usr/local/maven/apache-maven-3.3.9
echo "export M3_HOME=/usr/local/maven/apache-maven-3.3.9" >> /etc/profile.d/maven.sh
sed "s:<localRepository>.*:--><localRepository>/opt/tibco/maven</localRepository><\!--:" ${M3_HOME}/conf/settings.xml > settings.xml
mv -f settings.xml ${M3_HOME}/conf/settings.xml

# download and install the jenkins package
wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key
yum -y install jenkins > /tmp/yum-jenkins.log 2>&1

# add centos to the jenkins group
usermod -a -G jenkins centos

# install jenkins at /jenkins and disable the setup wizard
sed 's/JENKINS_HOME=.*$/JENKINS_HOME=\"\/jenkins\"/;s/JENKINS_JAVA_OPTIONS=\"/&-Djenkins.install.runSetupWizard=false /' /etc/sysconfig/jenkins > /etc/sysconfig/jenkins.new
mv -f /etc/sysconfig/jenkins.new /etc/sysconfig/jenkins

# create jenkins dir
mkdir /jenkins

# create SSH key
ssh-keygen -t rsa -N "" -f key.pem
export SSH_KEY=$(cat key.pem.pub)

# download the groovy initialisation script for jenkins (setting admin)
wget --no-check-certificate --content-disposition -P /tmp ${GIT_URL}/ec2-scripts/init.groovy
sed "s:##PWD##:${1}:;s:##SSHKEY##:${SSH_KEY}:" /tmp/init.groovy > /jenkins/init.groovy

# download the groovy config script for jenkins (installing plugins)
wget --no-check-certificate --content-disposition -P /tmp ${GIT_URL}/ec2-scripts/configure.groovy
sed "s:##GHTOKEN##:${2}:" /tmp/configure.groovy > /jenkins/configure.groovy

# download the groovy config script for jenkins (installing plugins)
wget --no-check-certificate --content-disposition -P /jenkins ${GIT_URL}/ec2-scripts/disable-cli.groovy

chown -R jenkins:jenkins /jenkins > /tmp/chown1.log 2>&1
chown -R jenkins:jenkins /opt/tibco

# add jenkins user to sudoers and disable tty
echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
echo "Defaults:%jenkins !requiretty" >> /etc/sudoers
echo "Defaults:jenkins !requiretty" >> /etc/sudoers

# start Jenkins
service jenkins start

export JENKINS_URL=http://localhost:8080

# wait for Jenkins Web Server to be up
while [[ "$(curl -s -o /dev/null -m 5 -w ''%{http_code}'' ${JENKINS_URL})" != "200" ]]; do sleep 5; done

wget ${JENKINS_URL}/jnlpJars/jenkins-cli.jar

for value in "github build-pipeline-plugin dashboard-view workflow-aggregator plain-credentials"
do
  java -jar jenkins-cli.jar -remoting -s ${JENKINS_URL} -i key.pem install-plugin $value
done

java -jar jenkins-cli.jar -remoting -s ${JENKINS_URL} -i key.pem restart

# wait for Jenkins Web Server to be up
while [[ "$(curl -s -o /dev/null -m 5 -w ''%{http_code}'' ${JENKINS_URL})" != "200" ]]; do sleep 5; done

java -jar jenkins-cli.jar -remoting -s ${JENKINS_URL} -i key.pem groovy /jenkins/configure.groovy
java -jar jenkins-cli.jar -remoting -s ${JENKINS_URL} -i key.pem groovy /jenkins/disable-cli.groovy
