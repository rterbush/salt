#!py

import re

def run():
  config = {}

  trtable = str.maketrans('.','-')

  upname = re.split('^(\w+\.\w+\.\w+)\..*', __grains__['id'])[0].translate(trtable).upper()

  config['set_computer_name'] = {
    'module.run': [
      {'name': 'system.set_computer_name'},
      {'m_name': upname },
    ],
  }

  return config