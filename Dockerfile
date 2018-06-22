FROM debian:stretch

ENV FOREMAN_VERSION="1.16" PATH=/opt/puppetlabs/bin:$PATH

# Dependencies installation
RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      cron \
      gnupg \
      systemd \
      wget; \
    rm -rf /var/lib/apt/lists/*

# Systemd configuration
RUN set -ex; \
    cd /lib/systemd/system/sysinit.target.wants/; \
    ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1; \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*; \
    rm -f /lib/systemd/system/plymouth*; \
    rm -f /lib/systemd/system/systemd-update-utmp*; \
    systemctl set-default multi-user.target
ENV init /lib/systemd/systemd
VOLUME [ "/sys/fs/cgroup" ]

# Puppet installation
RUN set -ex; \
    wget -O /tmp/puppet5-release-stretch.deb https://apt.puppetlabs.com/puppet5-release-stretch.deb; \
    dpkg -i /tmp/puppet5-release-stretch.deb; \
    rm /tmp/puppet5-release-stretch.deb; \
    apt-get update; \
    apt-get -y install puppetserver; \
    rm -rf /var/lib/apt/lists/*

# Foreman-installer installation
RUN set -ex; \
    echo "deb http://deb.theforeman.org/ stretch $FOREMAN_VERSION" > /etc/apt/sources.list.d/foreman.list; \
    echo "deb http://deb.theforeman.org/ plugins $FOREMAN_VERSION" >> /etc/apt/sources.list.d/foreman.list; \
    wget -q https://deb.theforeman.org/pubkey.gpg -O- | apt-key add -; \
    apt-get update; \
    apt-get -y install foreman-installer; \
    rm -rf /var/lib/apt/lists/*

# Foreman and Foreman-Proxy installations
COPY config/foreman-installer/scenarios.d/foreman-answers.yaml /etc/foreman-installer/scenarios.d/foreman-answers.yaml
RUN set -x; \
    mv /bin/hostname /tmp/; \
    echo "echo $(facter fqdn)" > /bin/hostname; \
    chmod +x /bin/hostname; \
    apt-get update; \
    foreman-installer; \
    mv /tmp/hostname /bin/; \
    rm -rf /var/lib/apt/lists/*

# Dependencies clean-up
RUN set -ex; \
    apt-get purge -y --auto-remove wget

# Save original configurations
RUN set -ex; \
    mv /etc/foreman /etc/foreman.dist; \
    mv /etc/foreman-proxy /etc/foreman-proxy.dist

# Config volumes
RUN mkdir /etc/foreman
VOLUME /etc/foreman
VOLUME /etc/foreman-installer
RUN mkdir /etc/foreman-proxy
VOLUME /etc/foreman-proxy

# Log volumes
VOLUME /var/log/foreman
VOLUME /var/log/foreman-installer
VOLUME /var/log/foreman-proxy

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["/lib/systemd/systemd"]

EXPOSE 80
EXPOSE 443
EXPOSE 8140

# vim:set ft=dockerfile:
