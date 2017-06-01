#!groovy

import jenkins.model.*
import hudson.security.*
import jenkins.security.s2m.*
  
// create admin account
def instance = Jenkins.getInstance()

// disable CLI
def CLIConfig = jenkins.CLI.get()
CLIConfig.setEnabled(false)
CLIConfig.save()

// Agent Master ACL
instance.injector.getInstance(AdminWhitelistRule.class).setMasterKillSwitch(false);
instance.save()
