# /srv/salt/formulas/top.sls
base:
  '*':
    - common
  'wnode*':
    - roles.winworker
  'hedge.*':
    - roles.database
    - roles.grinder
