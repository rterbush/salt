# /srv/salt/formulas/top.sls
base:
  '*':
    - common
  'wnode[1-3].*':
    - roles.ts
  'hedge.*':
    - roles.phidb
