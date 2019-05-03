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


