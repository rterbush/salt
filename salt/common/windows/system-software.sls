disable_essentials_wizard:
  reg.absent:
    - name: 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'
    - vname: EssentialsRoleConfigWizard

install_dotnet_features:
  win_servermanager.installed:
    - name: Net-Framework-Core
