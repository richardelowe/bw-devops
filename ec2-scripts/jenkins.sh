#!/bin/sh

sed 's/JENKINS_HOME=.*$/JENKINS_HOME=\"\/jenkins\"/;s/JENKINS_JAVA_OPTIONS=\"/&-Djenkins.install.runSetupWizard=false /' /etc/sysconfig/jenkins > /etc/sysconfig/jenkins.new
mv -f /etc/sysconfig/jenkins.new /etc/sysconfig/jenkins

sed "s/##PWD##/${1}/" /jenkins/init.groovy > /tmp/init.groovy
mv -f /tmp/init.groovy /jenkins/init.groovy
