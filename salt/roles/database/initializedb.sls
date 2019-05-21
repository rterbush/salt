{% set sysconf = salt['pillar.get']('systembuilder_conf') -%}
{% set dbconf = salt['pillar.get']('postgresql_conf') -%}

create_db_systembuilder:
  postgres_user.present:
    - name: {{ sysconf.dbuser }}
    - encrypted: True
    - refresh_password: True
    - login: True
    - password: {{ sysconf.dbpass }}
    - db_user: {{ dbconf.owner }}
    - db_password: {{ dbconf.owner_pass }}
    - db_host: {{ dbconf.dbhost }}
    - db_port: {{ dbconf.dbport }}
  postgres_database.present:
    - name: systembuilder
    - owner: systembuilder
    - db_user: {{ dbconf.owner }}
    - db_password: {{ dbconf.owner_pass }}
    - db_host: {{ dbconf.dbhost }}
    - db_port: {{ dbconf.dbport }}
  postgres_privileges.present:
    - name: systembuilder
    - object_name: systembuilder
    - object_type: database
    - privileges:
        - ALL
    - db_user: {{ dbconf.owner }}
    - db_password: {{ dbconf.owner_pass }}
    - db_host: {{ dbconf.dbhost }}
    - db_port: {{ dbconf.dbport }}

create_db_salt_queues:
  postgres_user.present:
    - name: salt
    - encrypted: True
    - refresh_password: True
    - login: True
    - password: salt
    - db_user: {{ dbconf.owner }}
    - db_password: {{ dbconf.owner_pass }}
    - db_host: {{ dbconf.dbhost }}
    - db_port: {{ dbconf.dbport }}

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
