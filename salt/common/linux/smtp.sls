alternative_mta_set:
  alternatives.set:
    - name: mta
    - path: /usr/sbin/sendmail.ssmtp

ssmtp_configuration_file:
  file.managed:
    - name: /etc/ssmtp/ssmtp.conf
    - source: salt://common/linux/files/ssmtp.conf.jinja
    - template: jinja
    - user: root
    - group: mail
    - mode: 640
    - replace: True

ssmtp_revaliases_file:
  file.managed:
    - name: /etc/ssmtp/revaliases
    - source: salt://common/linux/files/revaliases.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - replace: True
