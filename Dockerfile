# vim:set ft=dockerfile:
FROM debian:stretch

RUN set -ex; \
  if ! command -v gpg > /dev/null; then \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      gnupg \
      dirmngr \
    ; \
  rm -rf /var/lib/apt/lists/*; \
fi


# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.10
RUN set -x \
  && apt update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
  && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
  && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
  && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true \
  && apt-get purge -y --auto-remove ca-certificates wget

# Puppet installation
RUN set -x \
  && wget -O /tmp/puppet5-release-stretch.deb https://apt.puppetlabs.com/puppet5-release-stretch.deb \
  && dpkg -i /tmp/puppet5-release-stretch.deb && rm /tmp/puppet5-release-stretch.deb

# Foreman-installer installation
RUN set -x \
  && echo "deb http://deb.theforeman.org/ stretch 1.16" > /etc/apt/sources.list.d/foreman.list \
  && echo "deb http://deb.theforeman.org/ plugins 1.16" >> /etc/apt/sources.list.d/foreman.list \
  && wget -q https://deb.theforeman.org/pubkey.gpg -O- | apt-key add - \
  && apt update && apt -y install foreman-installer

# Pre-configuration
COPY foreman-installer-answers.yaml /etc/foreman/

# Foreman installation
CMD foreman-installer

EXPOSE 443
