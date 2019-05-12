mount_nfs_volume:
  mount.mounted:
    - name: /mnt/systemdev
    - device: '{{ pillar['nfs_server'] }}:/{{ pillar['nfs_mount_pt'] }}'
    - fstype: nfs
    - opts: rw,bg,soft,defaults
    - mkmnt: True
    - persist: True
    - dump: 0
    - pass_num: 0