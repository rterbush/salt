include:
  - software.vim

system_upgrade:
  pkg.uptodate:
    - refresh: True

required_software:
  pkg.latest:
    - pkgs:
      - yum-plugin-versionlock
      - deltarpm
      - bind-utils
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
{% if grains['os'] == 'Amazon' %}
      - python27-psutil
      - python27-pip
      - python27-devel
      - python27-boto
      - python27-boto3
      - python27-pyOpenSSL
{% else %}
      - chrony
      - libndp
      - openssl-libs
      - python2-psutil
      - python-devel
      - python2-pip
      - python2-boto
      - python2-boto3
      - pyOpenSSL
{% endif %}

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

ntpd:
  service.running:
    - enable: True
