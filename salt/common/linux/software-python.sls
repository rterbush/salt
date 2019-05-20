pip_install_linux_required:
  pip.installed:
    - requirements: salt://{{ slspath }}/files/python-requirements.txt
    - force_reinstall: True
    - reload_modules: True