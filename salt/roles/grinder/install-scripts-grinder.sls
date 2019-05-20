{%- load_yaml as bits %}
destdir: {{ pillar['grinder:destdir'] }}
filesdir: {{ pillar['sharedrive'] }}/{{ pillar['datadir'] }}
{%- endload %}

{{ bits.destdir }}:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

{{ bits.destdir }}/bin/__init__.py:
  file.managed:
    - source: salt://{{ slspath }}/files/__init__.py
    - user: root
    - group: root
    - mode: 640
    - create: True
    - replace: True

{{ bits.destdir }}/bin/create_data_series.py:
  file.managed:
    - source: salt://{{ slspath }}/files/00_create_data_series.py
    - user: root
    - group: root
    - mode: 750
    - create: True
    - replace: True

{{ bits.destdir }}/bin/create_prototype.py:
  file.managed:
    - source: salt://{{ slspath }}/files/01_create_prototype.py
    - user: root
    - group: root
    - mode: 750
    - create: True
    - replace: True

{{ bits.destdir }}/bin/create_data_series.py:
  file.managed:
    - source: salt://{{ slspath }}/files/02_gen_prototype_code.py
    - user: root
    - group: root
    - mode: 750
    - create: True
    - replace: True

{{ bits.destdir }}/bin/config.py:
  file.managed:
    - source: salt://{{ slspath }}/files/config.py.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 640
    - create: True
    - replace: True
    - defaults:
        dbuser: {{ pillar['systembuilder_conf:dbuser'] }}
        dbpass: {{ pillar['systembuilder_conf:dbpass'] }}
        dbhost: {{ pillar['systembuilder_conf:dbhost'] }}
        dbport: {{ pillar['systembuilder_conf:dbport'] }}
        database: {{ pillar['systembuilder_conf:dbname'] }}
        tsuser: {{ pillar['tsusername'] }}
        tspass: {{ pillar['tspassword'] }}
        tsprog: {{ pillar['tsprogram'] }}
        filesdir: {{ filesdir }}

{{ bits.destdir }}/sbin/grinderd.py:
  file.managed:
    - source: salt://{{ slspath }}/files/grinderd.py
    - user: root
    - group: root
    - mode: 750
    - create: True
    - replace: True

/lib/systemd/system/grinderd.service:
  file.managed:
    - source: salt://{{ slspath }}/files/grinderd.service.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - replace: True
    - defaults:
        workingdir: {{ bits.destdir }}/bin
        sbindir: {{ bits.destdir }}/sbin
