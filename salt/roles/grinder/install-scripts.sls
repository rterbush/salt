{% set grinder = salt['pillar.get']('grinder') -%}
{% set dbconf = salt['pillar.get']('systembuilder_conf') -%}
{%- load_yaml as vars %}
destdir: {{ grinder.destdir }}
sharedir: {{ pillar['sharefolder'] }}
smartcode: {{ pillar['smartcode'] }}
scriptdir: {{ pillar['scriptdir'] }}
{%- endload %}

{{ vars.destdir }}:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

/var/log/grinder:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

{{ vars.destdir }}/bin/__init__.py:
  file.managed:
    - source: salt://{{ slspath }}/files/__init__.py
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - dir_mode: 750
    - create: True
    - replace: True

{{ vars.destdir }}/bin/model.py:
  file.managed:
    - source: salt://{{ slspath }}/files/model.py
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - dir_mode: 750
    - create: True
    - replace: True

{{ vars.destdir }}/bin/database.py:
  file.managed:
    - source: salt://{{ slspath }}/files/database.py
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - dir_mode: 750
    - create: True
    - replace: True

{{ vars.destdir }}/bin/exceptions.py:
  file.managed:
    - source: salt://{{ slspath }}/files/exceptions.py
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - dir_mode: 750
    - create: True
    - replace: True

{{ vars.destdir }}/bin/logging.yaml:
  file.managed:
    - source: salt://{{ slspath }}/files/logging.yaml
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - dir_mode: 750
    - create: True
    - replace: True

{{ vars.destdir }}/bin/create_data_series.py:
  file.managed:
    - source: salt://{{ slspath }}/files/00_create_data_series.py
    - user: root
    - group: root
    - mode: 750
    - makedirs: True
    - dir_mode: 750
    - create: True
    - replace: True

{{ vars.destdir }}/bin/create_prototype.py:
  file.managed:
    - source: salt://{{ slspath }}/files/01_create_prototype.py
    - template: jinja
    - user: root
    - group: root
    - mode: 750
    - makedirs: True
    - dir_mode: 750
    - create: True
    - replace: True
    - defaults:
      smartcode: {{ vars.smartcode }}


{{ vars.destdir }}/bin/gen_prototype_code.py:
  file.managed:
    - source: salt://{{ slspath }}/files/02_gen_prototype_code.py
    - user: root
    - group: root
    - mode: 750
    - makedirs: True
    - dir_mode: 750
    - create: True
    - replace: True

{{ vars.destdir }}/bin/config.py:
  file.managed:
    - source: salt://{{ slspath }}/files/config.py.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - dir_mode: 750
    - create: True
    - replace: True
    - defaults:
        dbuser: {{ dbconf.dbuser }}
        dbpass: {{ dbconf.dbpass }}
        dbhost: {{ dbconf.dbhost }}
        dbport: {{ dbconf.dbport }}
        database: {{ dbconf.dbname }}
        sharedir: {{ vars.sharedir }}

{{ vars.destdir }}/bin/grinderd.py:
  file.managed:
    - source: salt://{{ slspath }}/files/grinderd.py
    - template: jinja
    - user: root
    - group: root
    - mode: 750
    - makedirs: True
    - dir_mode: 750
    - create: True
    - replace: True
    - defaults:
        scriptdir: {{ vars.scriptdir }}

/lib/systemd/system/grinderd.service:
  file.managed:
    - source: salt://{{ slspath }}/files/grinderd.service.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - replace: True
    - defaults:
        workingdir: {{ vars.destdir }}/bin
        sbindir: {{ vars.destdir }}/bin

/lib/systemd/system/genprotod.service:
  file.managed:
    - source: salt://{{ slspath }}/files/genprotod.service.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - replace: True
    - defaults:
        workingdir: {{ vars.destdir }}/bin
        sbindir: {{ vars.destdir }}/bin

/etc/profile.d/grinder.sh:
  file.managed:
    - source: salt://{{ slspath }}/files/grinder.sh.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - replace: True
    - defaults:
        destdir: {{ vars.destdir }}
