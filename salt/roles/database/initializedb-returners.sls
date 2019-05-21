{% set sysconf = salt['pillar.get']('systembuilder_conf') -%}
{% set dbconf = salt['pillar.get']('postgresql_conf') -%}

copy_db_init_sql_returners:
  file.managed:
    - name: /var/tmp/init-salt-returners.sql
    - source: salt://{{ slspath }}/files/init-salt-returners.sql

apply_db_init_sql_returners:
  cmd.run:
    - name: '
          PGPASSWORD={{ dbconf.owner_pass }} psql -h {{ dbconf.dbhost }} -U {{ dbconf.owner }} -f /var/tmp/init-salt-returners.sql'

remove_db_init_sql_returners:
  file.absent:
    - name: /var/tmp/init-salt-returners.sql
