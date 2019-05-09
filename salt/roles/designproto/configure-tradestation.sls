{%- load_yaml as bits %}
destdir: 'C:/temp'
srcdir: 'salt://roles/designproto/files'
uppernode: {{ grains['id'].split('.') | first | upper }}
{%- endload %}

upload_config_script:
  file.managed:
    - name: {{ bits.destdir }}/auto-configure-tradestation.py
    - source: {{ bits.srcdir }}/auto-configure-tradestation.py
    - template: jinja
    - makedirs: True
    - defaults:
        tsuser: {{ pillar['tsusername'] }}
        tspass: {{ pillar['tspassword'] }}

create_wnode_ssh_public_key:
  file.managed:
    - name: 'C:\Users\TS\.ssh\wnode-ssh-key.pub'
    - source: salt://{{ slspath }}/files/wnode-ssh-key.pub
    - makedirs: True

create_wnode_ssh_private_key:
  file.managed:
    - name: 'C:\Users\TS\.ssh\wnode-ssh-key'
    - source: salt://{{ slspath }}/files/wnode-ssh-key
    - makedirs: True

create_known_hosts:
  file.managed:
    - name: 'C:\Users\TS\.ssh\known_hosts'
    - source: salt://{{ slspath }}/files/known_hosts.bitbucket.org

create_repo_target:
  file.directory:
    - name: 'C:\Users\TS\framework'
    - win_owner: TS
    - win_perms:
      TS:
        perms: full_control
    - win_inheritance: True

clone_framework_repo:
  git.latest:
    - name: git@bitbucket.org:signalbuilders/tradestation-framework.git
    - rev: master
    - branch: master
    - force_checkout: True
    - update_head: False
    - force_reset: True
    - fetch_tags: False
    - sync_tags: False
    - depth: 1
    - target: 'C:\Users\TS\framework'
    - identity: 'C:\Users\TS\.ssh\wnode-ssh-key'
    - user: TS
    - password: {{ pillar['userpass'] }}

create_config_task:
  module.run:
    - task.create_task:
      - name: config-task
      - user_name: TS
      - password: {{ pillar['userpass'] }}
      - action_type: Execute
      - cmd: 'psexec'
      - arguments: '\\{{ bits.uppernode }} -accepteula -nobanner -u {{ bits.uppernode }}\TS -p {{ pillar['userpass'] }} -h -i 1 C:\salt\bin\python.exe {{ bits.destdir }}\auto-configure-tradestation.py'
      - trigger_enabled: True
      - trigger_type: 'Once'
      - force: True
      - allow_demand_start: True
      - require:
        - file: upload_config_script

run_config_task:
  module.run:
    - task.run_wait:
      - name: config-task

delete_config_task:
  module.run:
    - task.delete_task:
      - name: config-task

cleanup_config_script:
  file.absent:
    - name: {{ bits.destdir }}/auto-configure-tradestation.py
    - require:
      - run: run_config_task