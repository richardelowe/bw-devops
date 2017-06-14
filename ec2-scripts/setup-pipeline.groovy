#!groovy

import jenkins.model.*
import java.io.*

def source = new FileInputStream('/tmp/pipeline.xml')
def tli = Jenkins.instance.createProjectFromXML("BW-Bookstore", source)
tli.save()
