#!env python

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

    __runner__ = salt.runner.RunnerClient()

    while True:
        try:
            workerCnt = __runner__.cmd('queue.list_length', 'winworker' )
            print('worker queue: {0}', workerCnt)
            time.sleep(10)

