
pip_install_required:
  pip.installed:
    - requirements: salt://common/windows/files/python-requirements.txt
    - upgrade: True
