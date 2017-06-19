# bw-devops

This is a contribution aimed at speeding up the creation of an AWS EC2 node target at BWCE continuous integration.

The main entry point is cloudformation/devops.template. It is a AWS CloudFormation template that you can run using the CloudFormation Service and selecting "Create Stack" and uploading that file to S3.

You are then prompted for a few parameters
<ul>
<li>BWCECFURL</li>
<li>BWCEDockerURL</li>
<li>GitHubToken</li>
<li>JenkinsPwd</li>
<li>KeyName</li>
<li>TypeTag</li>
</ul>

