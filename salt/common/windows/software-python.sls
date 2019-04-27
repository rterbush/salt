python-pip:
  pkg.installed

pywinauto:
  pip.installed:
    - cwd: 'C:\salt\bin\scripts'
    - bin_env: 'C:\salt\bin\scripts\pip.exe'
    - upgrade: True

