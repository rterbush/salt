pip_install_linux_required:
  pip.installed:
    - requirements: salt://{{ slspath }}/files/python-requirements.txt
    - reload_modules: True
    - force_reinstall: False