#!py

from string import maketrans
import re

def run():
  config = {}

  trtable = maketrans('.','-')

  upname = re.split('^(\w+\.\w+\.\w+)\..*', __grains__['id'])[1].translate(trtable).upper()

  config['set_computer_name'] = {
    'module.run': [
      {'name': 'system.set_computer_name'},
      {'m_name': upname },
    ],
  }

  return config
