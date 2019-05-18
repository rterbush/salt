#!env python3

from __future__ import unicode_literals
from __future__ import print_function

import os.path
import sys
import time
import logging

import salt.client
import salt.config
import salt.loader
import salt.runner


if __name__ == "__main__":

    opts    = salt.config.minion_config('/etc/salt/master')
    runner  = salt.runner.RunnerClient(opts)

    while True:
        try:
            workerCnt = runner.cmd('queue.list_length', ['winworker'] )
            print('worker queue: {0}').format(workerCnt)
            time.sleep(10)
        except:
            raise
