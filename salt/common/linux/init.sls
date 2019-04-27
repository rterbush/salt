include:
  - {{ slspath }}.software
  - {{ slspath }}.services
  - {{ slspath }}.smtp
  - {{ slspath }}.sysctl
  - {{ slspath }}.permissions

install_motd:
  file.managed:
    - name: /etc/motd
    - source: salt://files/motd.template
    - user: root
    - group: root
    - mode: 644
    - template: jinja

install_logrotate_conf:
  file.managed:
    - name: /etc/logrotate.conf
    - source: salt://{{ slspath }}/files/logrotate.conf.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja

install_driver_blacklist:
  file.managed:
    - name: /etc/modprobe.d/blacklist
    - source: salt://{{ slspath }}/files/blacklist.template
    - user: root
    - group: root
    - mode: 600

install_sshd_config:
  file.managed:
    - name: /etc/ssh/sshd_config
    - source: salt://{{ slspath }}/files/sshd_config.template
    - user: root
    - group: root
    - mode: 600

install_sysconfig_chronyd:
  file.managed:
    - name: /etc/sysconfig/chronyd
    - source: salt://{{ slspath }}/files/chronyd.template
    - user: root
    - group: root
    - mode: 600

disable_driver_cramfs:
  file.managed:
    - name: /etc/modprobe.d/disable-cramfs.conf
    - source: salt://{{ slspath }}/files/disable-cramfs.conf.template
    - user: root
    - group: root
    - mode: 644

disable_driver_hfs:
  file.managed:
    - name: /etc/modprobe.d/disable-hfs.conf
    - source: salt://{{ slspath }}/files/disable-hfs.conf.template
    - user: root
    - group: root
    - mode: 644

disable_driver_freevxfs:
  file.managed:
    - name: /etc/modprobe.d/disable-freevxfs.conf
    - source: salt://{{ slspath }}/files/disable-freevxfs.conf.template
    - user: root
    - group: root
    - mode: 644

disable_driver_jffs2:
  file.managed:
    - name: /etc/modprobe.d/disable-jffs2.conf
    - source: salt://{{ slspath }}/files/disable-jffs2.conf.template
    - user: root
    - group: root
    - mode: 644

disable_driver_hfsplus:
  file.managed:
    - name: /etc/modprobe.d/disable-hfsplus.conf
    - source: salt://{{ slspath }}/files/disable-hfsplus.conf.template
    - user: root
    - group: root
    - mode: 644

disable_driver_squashfs:
  file.managed:
    - name: /etc/modprobe.d/disable-squashfs.conf
    - source: salt://{{ slspath }}/files/disable-squashfs.conf.template
    - user: root
    - group: root
    - mode: 644

disable_driver_udf:
  file.managed:
    - name: /etc/modprobe.d/disable-udf.conf
    - source: salt://{{ slspath }}/files/disable-udf.conf.template
    - user: root
    - group: root
    - mode: 644

disable_driver_vfat:
  file.managed:
    - name: /etc/modprobe.d/disable-vfat.conf
    - source: salt://{{ slspath }}/files/disable-vfat.conf.template
    - user: root
    - group: root
    - mode: 644

/etc/ssh/banner:
  file.absent: []

mount_shm:
  mount.mounted:
    - name: /dev/shm
    - fstype: tmpfs
    - device: tmpfs
    - opts: 'defaults,nodev,nosuid,noexec'

login_notification:
  file.blockreplace:
    - name: /etc/profile
    - marker_start: "###--login notify start--###"
    - marker_end: "###--login notify end--###"
    - source: salt://common/linux/files/ssh-login-notify.jinja
    - append_if_not_found: True

