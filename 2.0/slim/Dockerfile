FROM openjdk:8u252-slim
LABEL MAINTAINER="José Carlos Paiva <josepaiva94@gmail.com>,José Paulo Leal <zp@dcc.fc.up.pt>"

# update && upgrade && install necessary packages
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y apt-utils build-essential wget

# Get Mooshak installer
RUN wget http://mooshak2.dcc.fc.up.pt/install/MooshakInstaller.jar

# Install Mooshak with configs in install.config
ADD install.conf /
RUN grep "^[^#]" install.conf | java -jar MooshakInstaller.jar -cui

# Fix permissions
RUN chmod +x /home/mooshak/tomcat8/bin/*.sh

# Expose port 80
EXPOSE 80

# Data volume
VOLUME /home/mooshak/data

# Run Mooshak server
ENTRYPOINT ["/home/mooshak/tomcat8/bin/catalina.sh", "run"]

