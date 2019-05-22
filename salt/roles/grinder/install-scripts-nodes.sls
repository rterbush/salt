{% set grinder = salt['pillar.get']('grinder') -%}
{% set dbconf = salt['pillar.get']('systembuilder_conf') -%}
{%- load_yaml as bits %}
destdir: {{ grinder.destdir }}
filesdir: {{ pillar['nfs_mount_point_unix'] }}/BOS
{%- endload %}

{{ bits.destdir }}:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

/var/log/grinder:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750


{{ bits.destdir }}/run_prototype_opt.py:
  file.managed:
    - source: salt://{{ slspath }}/files/03_run_prototype_opt.py
    - user: root
    - group: root
    - mode: 750
    - makedirs: True
    - dir_mode: 750
    - create: True
    - replace: True

Must configure for Windows deploy
