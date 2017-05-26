#!groovy

import jenkins.model.*
import hudson.security.*
import jenkins.security.s2m.*
  
import com.cloudbees.plugins.credentials.SystemCredentialsProvider
import org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl
import com.cloudbees.plugins.credentials.CredentialsScope
import hudson.util.Secret
import org.jenkinsci.plugins.github.config.*

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
def credentials = new StringCredentialsImpl(CredentialsScope.GLOBAL,
                                            UUID.randomUUID().toString(),
                                            "Access to GitHub",
                                            Secret.fromString("##GHTOKEN##"));

def credentialsStore = jenkins.model.Jenkins.instance.getExtensionList(com.cloudbees.plugins.credentials.SystemCredentialsProvider.class)[0]
def globalDomain = com.cloudbees.plugins.credentials.domains.Domain.getGlobal()
credentialsStore.storeImpl.addCredentials(globalDomain, credentials)
credentialsStore.save()

// configure github server
def githubPluginExtension = instance.getExtensionList(org.jenkinsci.plugins.github.config.GitHubPluginConfig.class)[0];
def serverConfig = new GitHubServerConfig(credentials.getId())
def configs = githubPluginExtension.getConfigs();
configs.add(serverConfig)
githubPluginExtension.save()
