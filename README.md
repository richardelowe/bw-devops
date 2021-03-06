# bw-devops

This is a contribution aimed at speeding up the creation of an AWS EC2 node for BWCE continuous integration.

The main entry point is cloudformation/devops.template. It is a AWS CloudFormation template that you can run using the CloudFormation Service and selecting "Create Stack" and uploading that file to S3.

You are then prompted for a few parameters
<ul>
  <li><code>BWCECFURL</code>, the URL for the bwce_cf.zip package (v2.3), e.g. from S3,</li>
  <li><code>BWCEDockerURL</code>, the URL for the bwce_docker.zip package (v2.3), a portion of the bwce install (docker subdir) you need to zip and make available, e.g. from S3,</li>
  <li><code>GitHubToken</code>, an access token for your GitHub repository containing a clone of <a href="https://github.com/eschweit-at-tibco/bookstore">bookstore</a>,</li>
  <li><code>JenkinsPwd</code>, the password you want to set for the <code>admin</code> user on Jenkins,</li>
  <li><code>KeyName</code>, the name of a EC2 Key Pair name you want to use to ssh into the created instance,</li>
  <li><code>TypeTag</code>, the label that will be added on the Type tag to any of the created EC2 resources created.</li>
</ul>

Here are some details of what is actually performed by this template:
<ol>
  <li>Create a CentOS-based EC2 M3.medium instance in your current AWS region,</li>
  <li>Attach a Security Group to it with universal access on <code>TCP:22</code> (SSH) and <code>TCP:80</code> (HTTP) as well as internal <code>TCP:0-65535</code> access within the Security Group,</li>
  <li>Perform updates on the created machine (OS + Extended Packages),</li>
  <li>Install base packages: <code>python</code>, <code>pip</code>, <code>wget</code>,</li>
  <li>Install AWS CloudFormation Bootstrap, <code>aws-cfn-bootstrap</code>,</li>
  <li>Install and configure <code>jenkins</code></li>
  <ul>
    <li>Install and configure <code>maven</code> 3.3.9, including preparing a local repository for BWCE stuff,</li>
    <li>Install <code>jenkins</code> last stable version,</li>
    <li>Configure a SSH key to run <code>jenkins</code> CLI,</li>
    <li>Create the admin user with the provided <code>JenkinsPwd</code>,</li>
    <li>Add the following plugins: <code>build-pipeline-plugin</code>, <code>dashboard-view</code>, <code>workflow-aggregator</code>, and <code>plain-credentials</code> with all their dependencies,</li>
    <li>Configure <code>Maven</code> in <code>jenkins</code>,</li>
    <li>Create the the GitHub connectivity with the provided <code>GitHubToken</code> credentials,</li>
    <li>Setup a build pipeline for the <code>bookstore</code> sample,</li>
    <li>Disable Jenkins CLI access,</li>
  </ul>
  <li>Install and configure <code>docker</code>,</li>
  <li>Install and configure the required BWCE bits,</li>
  <li>Install and configure <code>runman</code> (the execution part of <code>postman</code>) for Rest API testing,</li>
  <li>Install and configure <code>nginx</code> to reverse proxy <code>jenkins</code> on port 80.</li>
</ol>
