certbot:
  pkg.latest

/usr/bin/c_rehash:
  pkg.latest

# need to upgrade
certbot-dns-route53:
  pip.installed

# /etc/letsencrypt/cli.ini:
#   file.managed:
#     - source: salt://common/linux/files/letsencrypt.template.jinja
#     - user: root
#     - makedirs: true

root_cert_install:
  file.managed:
    - source: salt://common/linux/files/DST_Root_CA_X3.pem
    - name: /etc/pki/ca-trust/source/anchors/DST_ROOT_CA_X3.pem
    - mode: 640
  file.managed:
    - source: salt://common/linux/files/ISRG_Root_X1.pem
    - name: /etc/pki/ca-trust/source/anchors/ISRG_Root_X1.pem
    - mode: 640
  file.managed:
    - source: salt://common/linux/files/letsencryptauthorityx3.pem
    - name: /etc/pki/ca-trust/source/anchors/letsencryptauthorityx3.pem
    - mode: 640
  file.managed:
    - source: salt://common/linux/files/lets-encrypt-x3-cross-signed.pem
    - name: /etc/pki/ca-trust/source/anchors/lets-encrypt-x3-cross-signed.pem
    - mode: 640
  cmd.run:
    - name: '
          /bin/update-ca-trust force-enable && /bin/update-ca-trust extract'
    - runas: root
  cmd.run:
    - name: '
          /usr/bin/c_rehash'
    - cwd: /etc/pki/tls/certs
    - runas: root
