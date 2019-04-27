{% set stratconf = salt['pillar.get']('miningcore_conf') -%}
{% set dbconf = salt['pillar.get']('postgresql_conf') -%}

create_db_miningcore:
  postgres_user.present:
    - name: {{ stratconf.dbuser }}
    - encrypted: True
    - refresh_password: True
    - login: True
    - password: {{ stratconf.dbpass }}
    - db_user: {{ dbconf.owner }}
    - db_password: {{ dbconf.owner_pass }}
    - db_host: {{ dbconf.dbhost }}
    - db_port: {{ dbconf.dbport }}
  postgres_database.present:
    - name: miningcore
    - owner: miningcore
    - db_user: {{ dbconf.owner }}
    - db_password: {{ dbconf.owner_pass }}
    - db_host: {{ dbconf.dbhost }}
    - db_port: {{ dbconf.dbport }}
  postgres_privileges.present:
    - name: miningcore
    - object_name: miningcore
    - object_type: database
    - privileges:
        - ALL
    - db_user: {{ dbconf.owner }}
    - db_password: {{ dbconf.owner_pass }}
    - db_host: {{ dbconf.dbhost }}
    - db_port: {{ dbconf.dbport }}

restore_db_miningcore:
  archive.extracted:
    - name: /var/tmp
    - source: s3://crush-bin/backups/miningcore_dump.sql.tar.xz
    - source_hash: s3://crush-bin/backups/miningcore_dump.sql.tar.xz.sha256sum
    - enforce_toplevel: False
    - options: J
    - archive_format: tar
  cmd.run:
    - name: '
          PGPASSWORD={{ stratconf.dbpass }} psql -U miningcore -d miningcore -f /var/tmp/miningcore_dump.sql'
  file.absent:
    - name: /var/tmp/miningcore_dump.sql
