/etc/at.allow:
  file.managed:
    - user: root
    - group: root
    - mode: 600
    - replace: False
    - create: True

/etc/cron.deny:
  file.managed:
    - user: root
    - group: root
    - mode: 600
    - replace: False
    - create: True

/etc/at.deny:
  file.managed:
    - user: root
    - group: root
    - mode: 600
    - replace: False
    - create: True

/etc/cron.allow:
  file.managed:
    - user: root
    - group: root
    - mode: 600
    - replace: False
    - create: True

/etc/crontab:
  file.managed:
    - user: root
    - group: root
    - mode: 600
    - replace: False
    - create: False

/etc/passwd:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - replace: False
    - create: False

/etc/shadow:
  file.managed:
    - user: root
    - group: root
    - mode: 000
    - replace: False
    - create: False

/etc/group:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - replace: False
    - create: False

/etc/gshadow:
  file.managed:
    - user: root
    - group: root
    - mode: 000
    - replace: False
    - create: False

/etc/shadow-:
  file.managed:
    - user: root
    - group: root
    - mode: 000
    - replace: False
    - create: False

/etc/passwd-:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - replace: False
    - create: False

/etc/group-:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - replace: False
    - create: False

/etc/gshadow-:
  file.managed:
    - user: root
    - group: root
    - mode: 000
    - replace: False
    - create: False

/etc/grub.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 600
    - replace: False
    - create: False

# using hosts is to constraining right now. rely on firewall and net acl
# /etc/hosts.allow:
#   file.managed:
#     - source: salt://{{ slspath }}/files/hosts.allow.template
#     - user: root
#     - group: root
#     - mode: 644
#     - replace: True
#     - create: True

# /etc/hosts.deny:
#   file.managed:
#     - source: salt://{{ slspath }}/files/hosts.deny.template
#     - user: root
#     - group: root
#     - mode: 644
#     - replace: True
#     - create: True

/etc/bashrc:
  file.managed:
    - source: salt://{{ slspath }}/files/bashrc.template
    - user: root
    - group: root
    - mode: 644
    - replace: True
    - create: True

/etc/profile.d/umask.sh:
  file.managed:
    - source: salt://{{ slspath }}/files/umask.sh.template
    - user: root
    - group: root
    - mode: 644
    - replace: True
    - create: True

/etc/login.defs:
  file.managed:
    - source: salt://{{ slspath }}/files/login.defs.template
    - user: root
    - group: root
    - mode: 644
    - replace: True
    - create: True

/etc/default/useradd:
  file.managed:
    - source: salt://{{ slspath }}/files/useradd.template
    - user: root
    - group: root
    - mode: 644
    - replace: True
    - create: True

/etc/pam.d/system-auth-local:
  file.managed:
    - source: salt://{{ slspath }}/files/system-auth-local.template
    - user: root
    - group: root
    - mode: 644
    - replace: True
    - create: True

/etc/pam.d/system-auth:
  file.symlink:
    - target: /etc/pam.d/system-auth-local
    - force: True
    - require:
      - file: /etc/pam.d/system-auth-local

/etc/pam.d/password-auth-local:
  file.managed:
    - source: salt://{{ slspath }}/files/password-auth-local.template
    - user: root
    - group: root
    - mode: 644
    - replace: True
    - create: True

/etc/pam.d/password-auth:
  file.symlink:
    - target: /etc/pam.d/password-auth-local
    - force: True
    - require:
      - file: /etc/pam.d/password-auth-local

/etc/security/opasswd:
  file.managed:
    - user: root
    - group: root
    - mode: 640
    - create: True
    - replace: False

/etc/security/pwquality.conf:
  file.managed:
    - source: salt://{{ slspath }}/files/pwquality.conf.template
    - user: root
    - group: root
    - mode: 644
    - replace: True
    - create: True

/etc/issue:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - replace: False
    - create: False

/etc/issue.net:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - replace: False
    - create: False

/etc/cron.d:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 700
    - allow_symlink: False

/etc/cron.daily:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 700
    - allow_symlink: False

/etc/cron.weekly:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 700
    - allow_symlink: False

/etc/cron.hourly:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 700
    - allow_symlink: False

/etc/cron.monthly:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 700
    - allow_symlink: False
