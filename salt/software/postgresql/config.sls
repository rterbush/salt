{% set dbconf = salt['pillar.get']('postgresql_conf') -%}

{{ dbconf.owner }}:
 user.present:
    - shell: /usr/sbin/nologin
    - home: {{ dbconf.homedir }}

systemd_postgresql:
  file.managed:
    - name: /etc/systemd/system/postgresql.service
    - source: salt://software/postgresql/files/postgresql.service.jinja
    - template: jinja
    - mode: 644
    - replace: True

postgresql_conf:
  file.blockreplace:
    - name: {{ dbconf.homedir }}/postgresql.conf
    - marker_start: "# Managed by SaltStack: listen_addresses: please do not edit"
    - marker_end: "# Managed by SaltStack: end of salt managed zone --"
    - content: |
        {%- if dbconf.postgresconf %}
        {{ dbconf.postgresconf|indent(8) }}
        {%- endif %}
        {%- if dbconf.dbport %}
        port = {{ dbconf.dbport }}
        {%- endif %}
    - show_changes: True
    - append_if_not_found: True

initialize_postgres_database:
  file.directory:
    - name: {{ dbconf.homedir }}
    - makedirs: true
    - user: {{ dbconf.owner }}
    - group: {{ dbconf.group }}
    - dir_mode: 700
  cmd.run:
    - name: '
          /bin/chcon -R system_u:object_r:postgresql_log_t:s0 {{ dbconf.homedir }}'
  postgres_initdb.present:
    - name: {{ dbconf.homedir }}/data
    - auth: password
    - user: {{ dbconf.owner }}
    - password: {{ dbconf.owner_pass }}
    - encoding: UTF8
    - locale: C
    - runas: {{ dbconf.owner }}

run_daemon_postgresql:
  service.running:
    - name: postgresql
    - enable: True
    - provider: systemd
    - require:
      - postgres_initdb: initialize_postgres_database
