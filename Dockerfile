FROM debian:stretch

# Dependencies installation
RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      gnupg \
      wget; \
    rm -rf /var/lib/apt/lists/*

# Puppet installation
RUN set -ex; \
    wget -O /tmp/puppet5-release-stretch.deb https://apt.puppetlabs.com/puppet5-release-stretch.deb; \
    dpkg -i /tmp/puppet5-release-stretch.deb && rm /tmp/puppet5-release-stretch.deb

# Foreman-installer installation
RUN set -ex; \
    echo "deb http://deb.theforeman.org/ stretch 1.16" > /etc/apt/sources.list.d/foreman.list; \
    echo "deb http://deb.theforeman.org/ plugins 1.16" >> /etc/apt/sources.list.d/foreman.list; \
    wget -q https://deb.theforeman.org/pubkey.gpg -O- | apt-key add -; \
    apt-get update; \
    apt-get -y install foreman-installer; \
    rm -rf /var/lib/apt/lists/*

# Dependencies clean-up
RUN set -ex; \
    apt-get purge -y --auto-remove wget

# Config volumes
RUN mkdir /etc/foreman
VOLUME /etc/foreman
VOLUME /etc/foreman-installer
RUN mkdir /etc/foreman-proxy
VOLUME /etc/foreman-proxy

# Log volumes
RUN mkdir /var/log/foreman
VOLUME /var/log/foreman
VOLUME /var/log/foreman-installer
RUN mkdir /var/log/foreman-proxy
VOLUME /var/log/foreman-proxy

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["tail", "-f", "/var/log/foreman/production.log"]

EXPOSE 80
EXPOSE 443
EXPOSE 8140

# vim:set ft=dockerfile:
