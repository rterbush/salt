install_remote_management_tools:
  cmd.run:
    - name: '
      Install-WindowsFeature -IncludeAllSubFeature -Name RSAT'
    - shell: powershell
    - runas: Administrator
    - password: {{ pillar['adminpassword'] }}

remove_essentials_role:
  cmd.run:
    - name: '
      Remove-WssConfigurationData -Force'
    - shell: powershell
    - runas: Administrator
    - password: {{ pillar['adminpassword'] }}

uninstall_essentials_experience:
  win_servermanager.removed:
    - name: ServerEssentialsRole

install_dotnet_features:
  win_servermanager.installed:
    - name: Net-Framework-Core
