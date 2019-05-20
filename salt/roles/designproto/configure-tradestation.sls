{%- load_yaml as bits %}
destdir: C:\\temp
srcdir: 'salt://roles/designproto/files'
uppernode: {{ grains['id'].split('.') | first | upper }}
{%- endload %}

upload_config_script:
  file.managed:
    - name: {{ bits.destdir }}/auto-configure-tradestation.py
    - source: salt://{{ slspath }}/files/auto-configure-tradestation.py
    - template: jinja
    - makedirs: True
    - defaults:
        destdir: {{ bits.destdir }}
        tsuser: {{ pillar['tsusername'] }}
        tspass: {{ pillar['tspassword'] }}
        tsprog: {{ pillar['tsprogram'] }}
        smartcode: {{ pillar['smartcode'] }}

upload_smart_code_framework:
  file.managed:
    - name: {{ bits.destdir }}\000-BOS-SMART-CODE-V1.9.ELD
    - source: salt://files/TradeStation/ELD/000-BOS-SMART-CODE-V1.9.ELD
    - makedirs: True

create_config_task:
  module.run:
    - task.create_task:
      - name: config-task
      - user_name: TS
      - password: {{ pillar['userpass'] }}
      - action_type: Execute
      - cmd: 'psexec'
      - arguments: '\\{{ bits.uppernode }} -accepteula -nobanner -u {{ bits.uppernode }}\TS -p {{ pillar['userpass'] }} -h -i 1 C:/salt/bin/python.exe {{ bits.destdir }}/auto-configure-tradestation.py'
      - trigger_enabled: True
      - trigger_type: 'Once'
      - force: True
      - allow_demand_start: True
    - require:
      - file: upload_config_script

run_config_task:
  module.run:
    - task.run:
      - name: config-task

# delete_config_task:
#   module.run:
#     - task.delete_task:
#       - name: config-task

# cleanup_config_script:
#   file.absent:
#     - name: {{ bits.destdir }}/auto-configure-tradestation.py
#     - require:
#       - run: run_config_task
