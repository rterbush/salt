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

create_db_salt_user:
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
