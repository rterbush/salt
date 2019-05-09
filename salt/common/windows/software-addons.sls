# Chocolatey for package management

install_choco:
  module.run:
    - chocolatey.bootstrap: []

install_flauinspect:
  chocolatey.installed:
    - name: flauinspect

install_sysinternals:
  chocolatey.installed:
    - name: sysinternals

install_git:
  chocolatey.installed:
    - name: git.install
    - install_args: '-- params "/WindowsTerminal /SChannel"'

