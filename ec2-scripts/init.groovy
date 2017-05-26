#!groovy

import jenkins.model.*
import hudson.security.*
import jenkins.security.s2m.*
  
import com.cloudbees.plugins.credentials.SystemCredentialsProvider
import org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl
import com.cloudbees.plugins.credentials.CredentialsScope
import hudson.util.Secret

// create admin account
def instance = Jenkins.getInstance()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin", "##PWD##")
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)
instance.save()

// disable CLI
def CLIConfig = jenkins.CLI.get()
CLIConfig.setEnabled(false)

// Agent Master ACL
instance.injector.getInstance(AdminWhitelistRule.class).setMasterKillSwitch(false);
instance.save()

// install plugins
def installed = false
def initialised = false
def pluginsString = "githug build-pipeline-plugin dashboard-view workflow-aggregator"
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
}

// configure maven
define mavenPluginExtension = instance.getExtensionList(hudson.tasks.Maven.DescriptorImpl.class)[0];
define mavenList = (mavenPluginExtension.installations as List);
mavenList.add(new hudson.tasks.Maven.MavenInstallation("M3", "/usr/share/maven", []));
mavenPluginExtension.installations = mavenList
mavenPluginExtesion.save()

// configure credentials for github
def credential = new StringCredentialsImpl(CredentialsScope.GLOBAL,
                                           UUID.randomUUID().toString(),
                                           "Access to GitHub",
                                           Secret.fromString("9ded3dec8aeef7cbb216479ad28e415f06828754"));

def credentialsStore = jenkins.model.Jenkins.instance.getExtensionList(com.cloudbees.plugins.credentials.SystemCredentialsProvider.class)[0]
def credentials = credentialsStore.getCredentials()
credentials.add(credential)
credentialsStore.save()

// configure github server
