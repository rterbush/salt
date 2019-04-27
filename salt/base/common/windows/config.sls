install_windows_updates:
  win_update.installed:
    - categories:
      - 'Critical Updates'
      - 'Security Updates'
      - 'Updates'

set_execution_policy:
  cmd.run:
    - name: '
      set-executionpolicy bypass'
    - shell: powershell
    - require:
      - win_update: install_windows_updates

security-cis-17:
  cmd.script:
    - source: salt://common/windows/files/security-cis-17.ps1
    - shell: powershell

set-time-server:
  cmd.script:
    - source: salt://common/windows/files/set-time-server.ps1
    - shell: powershell
