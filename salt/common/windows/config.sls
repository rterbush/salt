install_windows_updates:
  wua.uptodate:
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
      - wua: install_windows_updates

security-cis-17:
  cmd.script:
    - source: salt://common/windows/files/security-cis-17.ps1
    - shell: powershell

set-time-server:
  cmd.script:
    - source: salt://common/windows/files/set-time-server.ps1
    - shell: powershell

install_dotnet_features:
  win_servermanager.installed:
    - force: True
    - name: Net-Framework-Core

uninstall_essentials_experience:
  win_servermanager.uninstalled:
    - force: True
    - name: ServerEssentialsRole