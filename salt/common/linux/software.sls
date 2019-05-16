system_upgrade:
  pkg.uptodate:
    - refresh: True

required_software:
  pkg.latest:
    - pkgs:
      - yum-plugin-versionlock
      - deltarpm
      - bind-utils
      - nfs-utils
      - net-tools
      - lvm2
      - bzip2
      - gcc
      - aide
      - rsyslog
      - ntp
      - git
      - gnutls
      - file-libs
      - openssh-clients
      - openssh
      - openssl
      - libtevent
      - kernel
      - kernel-tools
      - binutils
      - libssh2
      - libxml2
      - libcurl
      - openldap
      - nspr
      - pcre
      - openssh-server
      - curl
      - ssmtp
      - mailx
      - chrony
      - libndp
      - openssl-libs

purge_packages:
  pkg.purged:
    - pkgs:
      - cups

install_ntpd_config:
  file.managed:
    - source: salt://{{ slspath }}/files/ntp.conf.template
    - name: /etc/ntp.conf
    - user: root
    - group: root
    - mode: 644
    - replace: True
    - create: True
    - template: jinja
    - defaults:
        ntpserver: {{ pillar['ntpserver'] }}

ntpd:
  service.running:
    - enable: True
