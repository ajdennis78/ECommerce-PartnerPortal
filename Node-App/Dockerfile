FROM centos:centos6

MAINTAINER Jennifer Li (jennifer.li@appdynamics.com)

# Enable EPEL for Node.js
RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm

# Install npm
RUN yum install -y npm --enablerepo=epel
RUN npm config set registry http://registry.npmjs.org/
RUN yum install -y vim
RUN yum install -y git

# Add app source
RUN mkdir /nodecellar
ADD /nodecellar /nodecellar

# Install app dependencies
RUN npm -g install npm@next
RUN cd /nodecellar && npm install appdynamics@4.1.0
RUN cd /nodecellar && npm install express
RUN cd /nodecellar && npm install request
RUN cd /nodecellar && npm install mongodb
RUN cd /nodecellar && npm install socket.io

# Install and start mongo
ADD /mongodb-org-3.0.repo /etc/yum.repos.d/
RUN yum install -y mongodb-org

# Set envrironment variable
COPY /env.sh /
RUN chmod 777 /env.sh
COPY /start.sh /
RUN chmod 777 /start.sh

# Expose Ports
EXPOSE  3000

# Set environment variable and start the App
CMD /start.sh 