#!py

import re

def run():
  config = {}

  upname = re.match('^(\w+)\..*', __grains__['id'])[1].upper()

  config['set_computer_name'] = {
    'module.run': [
      {'name': 'system.set_computer_name'},
      {'m_name': upname },
    ],
  }

  return config