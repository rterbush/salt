pip_update:
  pip.installed:
    - name: pip
    - upgrade: True
    - force_reinstall: True

pip_install_required:
  pip.installed:
    - requirements: salt://common/windows/files/python-requirements.txt
    - upgrade: True
    - force_reinstall: True


