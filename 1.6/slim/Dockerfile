FROM buildpack-deps:jessie-curl
LABEL MAINTAINER="José Carlos Paiva <josepaiva94@gmail.com>,José Paulo Leal <zp@dcc.fc.up.pt>"

# Set environment variables for Mooshak version and locale
ENV MOOSHAK_VERSION=1.6.3 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

# Fix Debian Jessie repositories to use archive.debian.org since Jessie repos are archived
# Then update, upgrade and install all necessary packages in one RUN to reduce image layers
RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i '/jessie-updates/d' /etc/apt/sources.list && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --allow-unauthenticated apt-utils build-essential locales tcl apache2 apache2-suexec supervisor \
        lpr time cron host rsync libxml2-utils xsltproc && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Configure Apache modules by creating symlinks in mods-enabled
RUN mkdir -p /etc/apache2/mods-enabled && \
    cd /etc/apache2/mods-enabled && \
    ln -s ../mods-available/userdir.conf && \
    ln -s ../mods-available/userdir.load && \
    ln -s ../mods-available/suexec.load && \
    ln -s ../mods-available/cgi.load

# Add custom Apache userdir configuration
ADD apache-userdir.conf /etc/apache2/mods-available/userdir.conf

# Create directory needed by Apache runtime
RUN mkdir -p /var/run/apache2

# Download and install Mooshak version 1.6.3
ADD https://mooshak.dcc.fc.up.pt/download/mooshak-${MOOSHAK_VERSION}.tgz /tmp/mooshak-${MOOSHAK_VERSION}.tgz
RUN cd /tmp && \
    tar xzf mooshak-${MOOSHAK_VERSION}.tgz && \
    cd mooshak-${MOOSHAK_VERSION} && \
    # Patch install script to bypass suexec check
    sed -e 's/proc check_suexec {} {/proc check_suexec {} { return;/' < install > install-modded && \
    sh install-modded && \
    cd / && \
    # Clean up installation files
    rm -rf /tmp/mooshak-${MOOSHAK_VERSION}.tgz /tmp/mooshak-${MOOSHAK_VERSION}

# Expose port 80 for HTTP traffic
EXPOSE 80

# Declare a volume for Mooshak data persistence
VOLUME /home/mooshak/data

# Add Supervisor configuration file to manage processes
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Start Supervisor as the container entrypoint
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
