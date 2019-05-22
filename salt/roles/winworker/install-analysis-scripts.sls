{% set dbconf = salt['pillar.get']('systembuilder_conf') -%}
{%- load_yaml as vars %}
destdir: {{ pillar['scriptdir'] }}
sharedir: '{{ pillar['sharedrive'] }}:\{{ pillar['sharefolder'] }}'
tsuser: {{ pillar['tsusername'] }}
tspass: {{ pillar['tspassword'] }}
tsprog: {{ pillar['tsprogram'] }}
{%- endload %}

{{ vars.destdir }}:
  file.directory:
    - win_owner: TS
    - win_inheritance: True

{{ vars.destdir }}/__init__.py:
  file.managed:
    - source: salt://{{ slspath }}/files/__init__.py
    - create: True
    - replace: True

{{ vars.destdir }}/model.py:
  file.managed:
    - source: salt://{{ slspath }}/files/model.py
    - create: True
    - replace: True

{{ vars.destdir }}/database.py:
  file.managed:
    - source: salt://{{ slspath }}/files/database.py
    - create: True
    - replace: True

{{ vars.destdir }}/logging.yaml:
  file.managed:
    - source: salt://{{ slspath }}/files/logging.yaml
    - create: True
    - replace: True

{{ vars.destdir }}/config.py:
  file.managed:
    - source: salt://{{ slspath }}/files/config.py.j2
    - template: jinja
    - create: True
    - replace: True
    - defaults:
        dbuser: {{ dbconf.dbuser }}
        dbpass: {{ dbconf.dbpass }}
        dbhost: {{ dbconf.dbhost }}
        dbport: {{ dbconf.dbport }}
        database: {{ dbconf.dbname }}
        sharedir: {{ vars.sharedir }}
        tsuser: {{ vars.tsuser }}
        tspass: {{ vars.tspass }}
        tsprog: {{ vars.tsprog }}
        logdir: {{ vars.destdir }}\logs

{{ vars.destdir }}/run_prototype_opt.py:
  file.managed:
    - source: salt://{{ slspath }}/files/03_run_prototype_opt.py
    - create: True
    - replace: True
