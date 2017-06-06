#!groovy

import jenkins.model.*
import hudson.security.*
import jenkins.security.s2m.*
import org.jenkinsci.main.modules.cli.auth.ssh.UserPropertyImpl

// create admin account
def instance = Jenkins.getInstance()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
def adminUser = hudsonRealm.createAccount("admin", "##PWD##")
def sshProperty = new UserPropertyImpl("##SSHKEY##")
adminUser.addProperty(sshProperty)
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)
instance.save()
