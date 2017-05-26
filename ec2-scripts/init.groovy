#!groovy

import jenkins.model.*
import hudson.security.*

// create admin account
def instance = Jenkins.getInstance()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin", "##PWD##")
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)
instance.save()

def p = AgentProtocol.all()
p.each { x ->
  if (x.name?.contains("CLI")) {
    // removing protocol
    p.remove(x)
  }
}

// disable CLI access over /cli URL
def removal = { lst ->
  lst.each { x ->
    if (x.getClass().name.contains("CLIAction")) {
      // removing extension
      lst.remove(x)
    }
  }
}

removal(instance.getExtensionList(RootAction.class))
removal(instance.actions)

// installation of plugins
def installed = false
def initialised = false
def pluginsString = "git s3 jenkins-cloudformation-plugin build-pipeline-plugin dashboard-view workflow-aggregator"
def plugins = pluginsString.split()
def pm = instance.getPluginManager()
def uc = instance.getUpdateCenter()

plugins.each() {
  if (!pm.getPlugin(it)) {
    if (!initialised) {
      uc.updateAllSites()
      initialised = true
    }
    
    def plugin = uc.getPlugin(it)
    if (plugin) {
      plugin.deploy()
      installed = true
    }
  }
}

if (installed) {
  instance.save()
//  instance.doSafeRestart()
}
