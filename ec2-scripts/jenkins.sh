#!/bin/sh

sed 's/JENKINS_HOME=.*$/JENKINS_HOME=\"\/jenkins\"/;s/JENKINS_JAVA_OPTIONS=\"/&-Djenkins.install.runSetupWizard=false /' /etc/sysconfig/jenkins > /etc/sysconfig/jenkins.new
mv -f /etc/sysconfig/jenkins.new /etc/sysconfig/jenkins
