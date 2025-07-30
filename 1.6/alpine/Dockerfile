FROM alpine:3.7
LABEL maintainer="José Carlos Paiva <josepaiva94@gmail.com>, José Paulo Leal <zp@dcc.fc.up.pt>"

# Mooshak version environment variable
ENV MOOSHAK_VERSION=1.6.3

# Locale and glibc variables
ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    ALPINE_GLIBC_VERSION="2.27-r0" \
    ALPINE_GLIBC_KEY_URL="https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub" \
    ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download"

# Update package index and upgrade existing packages
RUN apk update && apk upgrade

# Install build tools and essential packages in one RUN to reduce layers
RUN apk add --no-cache build-base bash tcl apache2 apache2-ctl apache2-utils \
    file shadow tini openrc curl supervisor cups-client dcron bind-tools \
    rsync libxml2-utils libxslt ca-certificates wget

# Install glibc and locale support for Alpine
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub ${ALPINE_GLIBC_KEY_URL} && \
    wget ${ALPINE_GLIBC_BASE_URL}/${ALPINE_GLIBC_VERSION}/glibc-${ALPINE_GLIBC_VERSION}.apk && \
    wget ${ALPINE_GLIBC_BASE_URL}/${ALPINE_GLIBC_VERSION}/glibc-bin-${ALPINE_GLIBC_VERSION}.apk && \
    wget ${ALPINE_GLIBC_BASE_URL}/${ALPINE_GLIBC_VERSION}/glibc-i18n-${ALPINE_GLIBC_VERSION}.apk && \
    apk add --no-cache glibc-${ALPINE_GLIBC_VERSION}.apk glibc-bin-${ALPINE_GLIBC_VERSION}.apk glibc-i18n-${ALPINE_GLIBC_VERSION}.apk && \
    rm -rf *.apk /etc/apk/keys/sgerrand.rsa.pub

# Generate locales from locale.md
COPY ./locale.md /locale.md
RUN cat /locale.md | xargs -I {} /usr/glibc-compat/bin/localedef -i {} -f UTF-8 {}.UTF-8

# Configure Apache modules if needed (uncomment and adjust if required)
# RUN mkdir -p /etc/apache2/mods-enabled && cd /etc/apache2/mods-enabled && \
#     ln -s ../mods-available/userdir.conf && \
#     ln -s ../mods-available/userdir.load && \
#     ln -s ../mods-available/suexec.load && \
#     ln -s ../mods-available/mpm_prefork.conf && \
#     ln -s ../mods-available/mpm_prefork.load && \
#     ln -s ../mods-available/cgi.load

# Replace default Apache config with custom config
ADD httpd.conf /etc/apache2/httpd.conf

# Create necessary directories for Apache runtime
RUN mkdir -p /var/run/apache2

# Disable mailbox creation for useradd
RUN echo "CREATE_MAIL_SPOOL=no" >> /etc/default/useradd

# Download and install Mooshak
ADD https://mooshak.dcc.fc.up.pt/download/mooshak-${MOOSHAK_VERSION}.tgz /tmp/mooshak-${MOOSHAK_VERSION}.tgz
RUN cd /tmp && \
    tar xzf mooshak-${MOOSHAK_VERSION}.tgz && \
    cd mooshak-${MOOSHAK_VERSION} && \
    sed -e 's/proc check_suexec {} {/proc check_suexec {} { return;/' < install > install-modded && \
    sh install-modded

# Clean installation files
RUN rm -rf /tmp/mooshak-${MOOSHAK_VERSION}.tgz /tmp/mooshak-${MOOSHAK_VERSION}

# Expose HTTP port
EXPOSE 80

# Define data volume
VOLUME /home/mooshak/data

# Add Supervisor config
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Start supervisord to manage processes
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]