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

# download the groovy initialisation script for jenkins (setting admin and installing plugins)
wget --no-check-certificate --content-disposition -P /jenkins https://raw.githubusercontent.com/eschweit-at-tibco/bw-devops/master/ec2-scripts/init.groovy
sed "s/##PWD##/${1}/" /jenkins/init.groovy > /tmp/init.groovy
mv -f /tmp/init.groovy /jenkins/init.groovy

chown -R jenkins:jenkins /jenkins > /tmp/chown1.log 2>&1

# add jenkins user to sudoers and disable tty
echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
echo "Defaults:%jenkins !requiretty" >> /etc/sudoers
echo "Defaults:jenkins !requiretty" >> /etc/sudoers

# start Jenkins
service jenkins start
