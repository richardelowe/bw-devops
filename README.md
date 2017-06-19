# bw-devops

This is a contribution aimed at speeding up the creation of an AWS EC2 node target at BWCE continuous integration.

The main entry point is cloudformation/devops.template. It is a AWS CloudFormation template that you can run using the CloudFormation Service and selecting "Create Stack" and uploading that file to S3.

You are then prompted for a few parameters
<ul>
  <li><code>BWCECFURL</code>, the URL for the bwce_cf.zip package (v2.3), e.g. from S3,</li>
  <li><code>BWCEDockerURL</code>, the URL for the bwce_docker.zip package (v2.3), a portion of the bwce install (docker subdir) you need to repackage, e.g. from S3,</li>
  <li><code>GitHubToken</code>, an access token for your GitHub repository containing a clone of <a href="https://github.com/eschweit-at-tibco/bookstore">bookstore</a>,</li>
  <li><code>JenkinsPwd</code>, the password you want to set for the <code>admin</code> user on Jenkins,</li>
  <li><code>KeyName</code>, the name of a EC2 Key Pair name you want to use to ssh into the created instance,</li>
  <li><code>TypeTag</code, the label that will be added on the Type tag to any of the created EC2 resources created.</li>
</ul>

