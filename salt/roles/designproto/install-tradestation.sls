{%- load_yaml as bits %}
destdir: 'C:/temp'
tsbin: 'TradeStation 9.5 Setup.exe'
srcdir: '{{ pillar['sharedrive'] }}:/{{ pillar['datadir'] }}/Applications/'
uppernode: {{ grains['id'].split('.') | first | upper }}
{%- endload %}

upload_ts:
  file.managed:
    - name: {{ bits.destdir }}/{{ bits.tsbin }}
    - source: {{ bits.srcdir }}/{{ bits.tsbin }}
    - makedirs: True

upload_install_script:
  file.managed:
    - name: {{ bits.destdir }}/auto-install-tradestation.py
    - source: {{ bits.srcdir }}/auto-install-tradestation.py
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
      - arguments: '\\{{ bits.uppernode }} -accepteula -nobanner -u {{ bits.uppernode }}\TS -p {{ pillar['userpass'] }} -h -i 1 C:\salt\bin\python.exe {{ bits.destdir }}\auto-install-tradestation.py'
      - trigger_enabled: True
      - trigger_type: 'Once'
      - force: True
      - allow_demand_start: True
      - require:
        - file: upload_install_script

run_install_task:
  module.run:
    - task.run_wait:
      - name: install-task

delete_install_task:
  module.run:
    - task.delete_task:
      - name: install-task

cleanup_ts:
  file.absent:
    - name: {{ bits.destdir }}/{{ bits.tsbin }}
    - require:
      - cmd: install_ts

cleanup_script:
  file.absent:
    - name: {{ bits.destdir }}/auto-install-tradestation.py
    - require:
      - run: run_install_task