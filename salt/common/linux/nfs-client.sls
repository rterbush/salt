mount_nfs_volume:
  mount.mounted:
    - name: {{ pillar['nfs_mount_point'] }}
    - device: '{{ pillar['nfs_server'] }}:/{{ pillar['nfs_share'] }}'
    - fstype: nfs
    - opts: rw,bg,soft,defaults
    - mkmnt: True
    - persist: True
    - dump: 0
    - pass_num: 0