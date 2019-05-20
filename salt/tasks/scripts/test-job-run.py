#!env python

from __future__ import unicode_literals
from __future__ import print_function

import os.path
import sys
import time
sys.stderr = open('C:\\temp\\err.txt', 'w')

import salt.config
import salt.loader
import salt.client

try:
    from pywinauto import application
except ImportError:
    pywinauto_path = os.path.abspath(__file__)
    pywinauto_path = os.path.split(os.path.split(pywinauto_path)[0])[0]
    sys.path.append(pywinauto_path)
    from pywinauto import application

from pywinauto import tests
from pywinauto.findbestmatch import MatchError
from pywinauto.timings import Timings

Timings.slow()
Timings.window_find_timeout = 90

def run_notepad():
    """Run notepad and do some small stuff with it"""
    start = time.time()
    app = application.Application()

    app.start(r"notepad.exe")

    time.sleep(10)

    # exit notepad
    app.Notepad.menu_select("File->Exit")


if __name__ == "__main__":
    __caller__  = salt.client.Caller()
    __opts__    = salt.config.minion_config('C:/salt/conf/minion')
    __grains__  = salt.loader.grains(__opts__)

    run_notepad()

    estr   = ('systembuilder/task/{0}/completed').format(__grains__['id'])
    ret = __caller__.cmd('event.send', estr,
                        { 'completed': True,
                        'message': "System Builder job completed"})



