pip_install_required:
  pip.installed:
    - requirements: salt://common/windows/files/python-requirements.txt
    - force_reinstall: True
    - reload_modules: True


