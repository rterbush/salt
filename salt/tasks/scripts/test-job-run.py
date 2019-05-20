#!env python

from __future__ import unicode_literals
from __future__ import print_function

import os.path
import sys
import time

import salt.config
import salt.loader

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

def run_notepad():
    """Run notepad and do some small stuff with it"""
    start = time.time()
    app = application.Application()

    app.start(r"notepad.exe")

    # type some text - note that extended characters ARE allowed
    app.Notepad.Edit.set_edit_text("I am typing s\xe4me text to Notepad\r\n\r\n"
        "And then I am going to quit")

    # Try and save
    app.Notepad.menu_select("File->SaveAs")
    app.SaveAs.EncodingComboBox.select("UTF-8")
    app.SaveAs.Edit.set_edit_text("example-utf8.txt")
    app.SaveAs.Save.click()
    app.ConfirmSaveAs.Yes.wait('exists').click()

    time.sleep(20)

    # exit notepad
    app.Notepad.menu_select("File->Exit")

if __name__ == "__main__":
    run_notepad()

    __caller__  = salt.client.Caller()
    __opts__    = salt.config.minion_config('C:/salt/conf/minion')
    __grains__  = salt.loader.grains(__opts__)

    estr   = ('systembuilder/task/{0}/completed').format(__grains__['id'])

    ret = __caller__.cmd('event.send', estr,
                        { 'completed': True,
                        'message': "System Builder job completed"})



