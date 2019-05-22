{%- load_yaml as vars %}
destdir: {{ pillar['scriptdir'] }}
tsbin: {{ pillar['tsinstallbin'] }}
uppernode: {{ grains['id'].split('.') | first | upper }}
{%- endload %}

upload_ts:
  file.managed:
    - name: {{ vars.destdir }}\{{ vars.tsbin }}
    - source: salt://files/Applications/{{ vars.tsbin }}
    - makedirs: True

upload_install_script:
  file.managed:
    - name: {{ vars.destdir }}/auto-install-tradestation.py
    - source: salt://{{ slspath }}/files/auto-install-tradestation.py
    - makedirs: True
    - require:
      - file: upload_ts

create_install_task:
  module.run:
    - task.create_task:
      - name: install-task
      - user_name: TS
      - password: {{ pillar['userpass'] }}
      - action_type: Execute
      - cmd: 'psexec'
      - arguments: '\\{{ vars.uppernode }} -accepteula -nobanner -u {{ vars.uppernode }}\TS -p {{ pillar['userpass'] }} -h -i 1 C:\salt\bin\python.exe {{ vars.destdir }}\auto-install-tradestation.py'
      - trigger_enabled: True
      - trigger_type: 'Once'
      - force: True
      - allow_demand_start: True
    - require:
      - file: upload_install_script

run_install_task:
  module.run:
    - task.run:
      - name: install-task

# delete_install_task:
#   module.run:
#     - task.delete_task:
#       - name: install-task
#     - require:
#       - module: run_install_task

# cleanup_ts:
#   file.absent:
#     - name: {{ vars.destdir }}/{{ vars.tsbin }}
#     - require:
#       - module: run_install_task

# cleanup_script:
#   file.absent:
#     - name: {{ vars.destdir }}/auto-install-tradestation.py
#     - require:
#       - module: run_install_task
