{%- load_yaml as bits%}
uppernode: {{ salt['grains.get']('host') | upper | regex_search('^(\w+)\..*') }}
hostname: {{ salt['grains.get']('host') }}
{%- endload %}

set_computer_name:
  system.computer_name:
    - name: {{ bits.uppernode }}

set_computer_hostname:
  system.hostname:
    - name: {{ bits.hostname }}

install_windows_updates:
  wua.uptodate:
    - software: True
    - drivers: True
    - skip_hidden: False
    - skip_reboot: False
    - skip_mandatory: False

set_execution_policy:
  cmd.run:
    - name: '
      set-executionpolicy bypass'
    - shell: powershell
    - require:
      - wua: install_windows_updates

set-time-server:
  cmd.script:
    - source: salt://{{ slspath }}/files/set-time-server.ps1.jinja
    - shell: powershell
    - template: jinja

enable_rdp:
  rdp.enabled

set_private_network_policy:
  reg.present:
    - name: 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles'
    - vname: Category
    - vtype: REG_DWORD
    - vdata: 1
    - win_owner: Administrators

disable_IE_prompts_1406:
  reg.present:
    - name: 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
    - vname: 1406
    - vtype: REG_DWORD
    - vdata: 0
    - win_owner: Administrators

disable_IE_prompts_1601:
  reg.present:
    - name: 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
    - vname: 1601
    - vtype: REG_DWORD
    - vdata: 0
    - win_owner: Administrators

disable_IE_enhanced_security_0:
  reg.present:
    - name: 'HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components'
    - vname: IsInstalled
    - vtype: REG_DWORD
    - vdata: 0
    - win_owner: Administrators

disable_IE_enhanced_security_1:
  reg.present:
    - name: 'HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components/{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}'
    - vname: IsInstalled
    - vtype: REG_DWORD
    - vdata: 0
    - win_owner: Administrators

disable_IE_enhanced_security_2:
  reg.present:
    - name: 'HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components/{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}'
    - vname: IsInstalled
    - vtype: REG_DWORD
    - vdata: 0
    - win_owner: Administrators

force_machine_based_browser_security:
  reg.present:
    - name: 'HKLM\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings'
    - vname: Security_HKLM_only
    - vtype: REG_DWORD
    - vdata: 1
    - win_owner: Administrators

disable_UAC:
  reg.present:
    - name: 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    - vname: EnableLUA
    - vtype: REG_DWORD
    - vdata: 0
    - win_owner: Administrators

