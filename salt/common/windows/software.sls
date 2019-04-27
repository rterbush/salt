# Chocolatey for package management

install_choco:
  module.run:
    - name: chocolatey.bootstrap

install_flauinspect:
  chocolatey.installed:
    - name: flauinspect




