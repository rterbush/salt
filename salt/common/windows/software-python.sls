
pip_install_required:
  pip.installed:
    - requirements: salt://common/windows/files/python-requirements.txt
    - upgrade: True
    - use_wheel: True
    - force_reinstall: True
