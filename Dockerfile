FROM openjdk:8-slim-bullseye
LABEL MAINTAINER="José Carlos Paiva <josepaiva94@gmail.com>,José Paulo Leal <zp@dcc.fc.up.pt>"

# update && upgrade && install necessary packages
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y apt-utils build-essential wget && \
    rm -rf /var/lib/apt/lists/*

# Get Mooshak installer
RUN wget --no-check-certificate https://mooshak2.dcc.fc.up.pt/install/MooshakInstaller.jar

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