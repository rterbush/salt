mount_nfs_volume_salt:
  mount.mounted:
    - name: {{ pillar['nfs_mount_point_salt'] }}
    - device: '{{ pillar['nfs_server'] }}:/{{ pillar['nfs_share'] }}'
    - fstype: nfs
    - opts: rw,bg,soft,defaults
    - mkmnt: True
    - persist: True
    - dump: 0
    - pass_num: 0

mount_nfs_volume_unix:
  mount.mounted:
    - name: {{ pillar['nfs_mount_point_unix'] }}
    - device: '{{ pillar['nfs_server'] }}:/{{ pillar['nfs_share'] }}'
    - fstype: nfs
    - opts: rw,bg,soft,defaults
    - mkmnt: True
    - persist: True
    - dump: 0
    - pass_num: 0
