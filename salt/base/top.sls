# /srv/salt/formulas/top.sls
base:
  '*':
    - common
#  'wnode[1-3].*':
#    - roles.designproto
#  'hedge.*':
#    - roles.database
