{%- load_yaml as vars %}
destdir: {{ pillar['scriptdir'] }}
srcdir: 'salt://roles/designproto/files'
uppernode: {{ grains['id'].split('.') | first | upper }}
smartcode: {{ pillar['smartcode'] }}
{%- endload %}

upload_config_script:
  file.managed:
    - name: {{ vars.destdir }}/auto-configure-tradestation.py
    - source: salt://{{ slspath }}/files/auto-configure-tradestation.py
    - template: jinja
    - makedirs: True
    - defaults:
        destdir: {{ vars.destdir }}
        tsuser: {{ pillar['tsusername'] }}
        tspass: {{ pillar['tspassword'] }}
        tsprog: {{ pillar['tsprogram'] }}
        smartcode: {{ pillar['smartcode'] }}

upload_smart_code_framework:
  file.managed:
    - name: {{ vars.destdir }}\{{ vars.smartcode }}.ELD
    - source: salt://files/TradeStation/ELD/{{ vars.smartcode }}.ELD
    - makedirs: True

create_config_task:
  module.run:
    - task.create_task:
      - name: config-task
      - user_name: TS
      - password: {{ pillar['userpass'] }}
      - action_type: Execute
      - cmd: 'psexec'
      - arguments: '\\{{ vars.uppernode }} -accepteula -nobanner -u {{ vars.uppernode }}\TS -p {{ pillar['userpass'] }} -h -i 1 C:/salt/bin/python.exe {{ vars.destdir }}/auto-configure-tradestation.py'
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
#     - name: {{ vars.destdir }}/auto-configure-tradestation.py
#     - require:
#       - run: run_config_task
