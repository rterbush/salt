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

create_salt_queue_user:
  postgres_user.present:
    - name: salt
    - encrypted: True
    - refresh_password: True
    - login: True
    - password: salt
    - db_user: salt
    - db_password: salt
    - db_host: salt
    - db_port: {{ dbconf.dbport }}

create_salt_queue_db:
  postgres_database.present:
    - name: salt
    - owner: salt
    - db_user: salt
    - db_password: salt
    - db_host: salt
    - db_port: {{ dbconf.dbport }}

configure_salt_queue_priv:
  postgres_privileges.present:
    - name: salt
    - object_name: salt
    - object_type: database
    - privileges:
        - ALL
    - db_user: salt
    - db_password: salt
    - db_host: salt
    - db_port: {{ dbconf.dbport }}

init_salt_queues_db:
  file.managed:
    - name: /var/tmp/init-salt-queues.sql
    - source: files://{{ slspath }}/files/init-salt-queues.sql
  cmd.run:
    - name: '
          PGPASSWORD=salt psql -U salt -d salt -f /var/tmp/init-salt-queues.sql'
  file.absent:
    - name: /var/tmp/init-salt-queues.sql