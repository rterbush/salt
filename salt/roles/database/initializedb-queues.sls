{% set sysconf = salt['pillar.get']('systembuilder_conf') -%}
{% set dbconf = salt['pillar.get']('postgresql_conf') -%}

copy_db_init_sql_queues:
  file.managed:
    - name: /var/tmp/init-salt-queues.sql
    - source: salt://{{ slspath }}/files/init-salt-queues.sql

apply_db_init_sql_queues:
  cmd.run:
    - name: '
          PGPASSWORD={{ dbconf.owner_pass }} psql -h {{ dbconf.dbhost }} -U {{ dbconf.owner }} -f /var/tmp/init-salt-queues.sql'

remove_db_init_sql_queues:
  file.absent:
    - name: /var/tmp/init-salt-queues.sql
