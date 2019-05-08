saltutil.sync_all:
  salt.function:
    - tgt: {{ pillar['incoming_id'] }}
    - reload_modules: True

saltutil.refresh_pillar:
  salt.function:
    - tgt: {{ pillar['incoming_id'] }}
    - require:
      - salt: saltutil.sync_all

mine.update:
  salt.function:
    - tgt: {{ pillar['incoming_id'] }}
    - require:
      - salt: saltutil.refresh_pillar

linux_required_software:
  salt.state:
    - tgt: 'G@kernel:Linux and {{ pillar['incoming_id'] }}'
    - tgt_type: compound
    - sls: common.linux
    - require:
      - salt: mine.update

windows_required_software:
  salt.state:
    - tgt: 'G@os:Windows and {{ pillar['incoming_id'] }}'
    - tgt_type: compound
    - sls: common.windows
    - require:
      - salt: pkg.refresh_db

first_reboot_windows:
  salt.function:
    - name: system.reboot
    - tgt: 'G@os:Windows and {{ pillar['incoming_id'] }}'
    - tgt_type: compound
    - require:
      - salt: windows_required_software

first_reboot_linux:
  salt.function:
    - name: system.reboot
    - tgt: 'G@kernel:Linux and {{ pillar['incoming_id'] }}'
    - tgt_type: compound
    - require:
      - salt: linux_required_software

wait_for_first_reboot:
  salt.wait_for_event:
    - name: salt/minion/*/start
    - id_list:
      - {{ pillar['incoming_id'] }}

highstate_run:
  salt.state:
    - tgt: {{ pillar['incoming_id'] }}
    - highstate: True
