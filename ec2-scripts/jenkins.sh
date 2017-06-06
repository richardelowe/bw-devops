#!/bin/bash

# download the jenkins package
wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key
yum -y install jenkins > /tmp/yum-jenkins.log 2>&1

# add centos to the jenkins group
usermod -a -G jenkins centos

# install jenkins at /jenkins and disable the setup wizard
sed 's/JENKINS_HOME=.*$/JENKINS_HOME=\"\/jenkins\"/;s/JENKINS_JAVA_OPTIONS=\"/&-Djenkins.install.runSetupWizard=false /' /etc/sysconfig/jenkins > /etc/sysconfig/jenkins.new
mv -f /etc/sysconfig/jenkins.new /etc/sysconfig/jenkins

set GIT_URL=https://raw.githubusercontent.com/eschweit-at-tibco/bw-devops/master

# create SSH key
ssh-keygen -t rsa -N "" -f key.pem
set SSH_KEY=$(cat key.pem.pub)

# download the groovy initialisation script for jenkins (setting admin)
wget --no-check-certificate --content-disposition -P /tmp ${GIT_URL}/ec2-scripts/init.groovy
sed "s/##PWD##/${1}/##SSHKEY##/${SSH_KEY}/" /tmp/init.groovy > /jenkins/init.groovy

# download the groovy config script for jenkins (installing plugins)
wget --no-check-certificate --content-disposition -P /tmp ${GIT_URL}/ec2-scripts/configure.groovy
sed "s/##GHTOKEN##/${2}/" /tmp/configure.groovy > /jenkins/configure.groovy

chown -R jenkins:jenkins /jenkins > /tmp/chown1.log 2>&1

# add jenkins user to sudoers and disable tty
echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
echo "Defaults:%jenkins !requiretty" >> /etc/sudoers
echo "Defaults:jenkins !requiretty" >> /etc/sudoers

# configure maven
echo "export M2_HOME=/usr/share/maven" >> /etc/profile.d/maven.sh

# start Jenkins
service jenkins start

set JENKINS_URL=http://localhost:8080

# wait for Jenkins Web Server to be up
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' ${JENKINS_URL})" != "200" ]]; do sleep 5; done

wget ${JENKINS_URL}/jnlpJars/jenkins-cli.jar

foreach value ( github build-pipeline-plugin dashboard-view workflow-aggregator plain-credentials )
  java -jar jenkins-cli.jar -s ${JENKINS_URL} -auth admin:admin install-plugin $value
done

java -jar jenkins-cli.jar -remoting -s ${JENKINS_URL} -i key.pem groovy configure.groovy
java -jar jenkins-cli.jar -remoting -s ${JENKINS_URL} -i key.pem groovy disable-cli.groovy
