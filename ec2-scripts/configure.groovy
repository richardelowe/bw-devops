#!groovy

import jenkins.model.*
import com.cloudbees.plugins.credentials.SystemCredentialsProvider
import org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl
import com.cloudbees.plugins.credentials.CredentialsScope
import hudson.util.Secret
import org.jenkinsci.plugins.github.config.*

def instance = Jenkins.getInstance()

// configure maven
def mavenPluginExtension = instance.getExtensionList(hudson.tasks.Maven.DescriptorImpl.class)[0];
def mavenList = (mavenPluginExtension.installations as List);
mavenList.add(new hudson.tasks.Maven.MavenInstallation("M3", "/usr/local/maven/apache-maven-3.3.9", []));
mavenPluginExtension.installations = mavenList
mavenPluginExtension.save()

// configure credentials for github
def credentials = new StringCredentialsImpl(CredentialsScope.GLOBAL,
                                            UUID.randomUUID().toString(),
                                            "Access to GitHub",
                                            Secret.fromString("##GHTOKEN##"))

def credentialsStore = jenkins.model.Jenkins.instance.getExtensionList(com.cloudbees.plugins.credentials.SystemCredentialsProvider.class)[0]
def globalDomain = com.cloudbees.plugins.credentials.domains.Domain.global()
credentialsStore.addCredentials(globalDomain, credentials)
credentialsStore.save()

// configure github server
def githubPluginExtension = instance.getExtensionList(org.jenkinsci.plugins.github.config.GitHubPluginConfig.class)[0];
def serverConfig = new GitHubServerConfig(credentials.getId())
def configs = githubPluginExtension.getConfigs()
configs.add(serverConfig)
githubPluginExtension.save()
