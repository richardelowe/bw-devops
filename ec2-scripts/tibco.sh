# install bw/bwce maven plugin
wget --no-check-certificate --content-disposition ${GIT_TIB_URL}/master/Installer/TIB_BW_Maven_Plugin_1.2.1.zip
unzip TIB_BW_Maven_Plugin_1.2.1.zip -d TIB_BW_Maven
cd TIB_BW_Maven
chmod +x install.sh
mkdir /opt/tibco
echo /opt/tibco | ./install.sh
cd /opt/tibco/bw/6.3/maven/plugins/bw6-maven-plugin
./install.sh

#install bwce docker 
cd /opt/tibco
mkdir bwce
cd bwce
wget https://s3-ap-southeast-2.amazonaws.com/eschweittibcosydney/bwce_docker.zip
unzip bwce_docker.zip
cd docker/resources/bwce-runtime
wget https://s3-ap-southeast-2.amazonaws.com/eschweittibcosydney/bwce_cf.zip
docker build -t bwce:latest .

chown -R jenkins:jenkins /opt/tibco
