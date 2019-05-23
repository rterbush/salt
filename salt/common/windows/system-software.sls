{%- if not match.grain_pcre('osrelease:10') %}
install_remote_management_tools:
  cmd.run:
    - name: '
      Add-WindowsCapability -Online -Name Rsat.ServerManager.Tools~~~~0.0.1.0'
    - shell: powershell
    - runas: Administrator
    - password: {{ pillar['adminpassword'] }}

disable_essentials_wizard:
  reg.absent:
    - name: 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'
    - vname: EssentialsRoleConfigWizard

install_dotnet_features:
  win_servermanager.installed:
    - name: Net-Framework-Core

uninstall_essentials_experience:
  win_servermanager.removed:
    - name: ServerEssentialsRole
{%- endif %}
