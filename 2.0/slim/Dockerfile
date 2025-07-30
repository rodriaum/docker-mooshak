FROM openjdk:8-slim-bullseye
LABEL MAINTAINER="José Carlos Paiva <josepaiva94@gmail.com>,José Paulo Leal <zp@dcc.fc.up.pt>"

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y apt-utils build-essential wget && \
    rm -rf /var/lib/apt/lists/*

RUN wget --no-check-certificate https://mooshak2.dcc.fc.up.pt/install/MooshakInstaller.jar

ADD install.conf /
RUN grep "^[^#]" install.conf | java -jar MooshakInstaller.jar -cui

RUN chmod +x /home/mooshak/tomcat8/bin/*.sh

# Expõe a porta 80
EXPOSE 80

# Volume para dados persistentes
VOLUME /home/mooshak/data

# Comando padrão para rodar o Mooshak
ENTRYPOINT ["/home/mooshak/tomcat8/bin/catalina.sh", "run"]