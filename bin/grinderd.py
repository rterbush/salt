#!env python3

from __future__ import unicode_literals
from __future__ import print_function

import os.path
import sys
import time
import logging
import re

import salt.config
import salt.runner
import salt.client

jobscript = {'test': 'test-job-run.py'}

class JobForeman(object):
    def __init__(self):
        self.opts    = salt.config.master_config('/etc/salt/master')
        self.runner  = salt.runner.RunnerClient(self.opts)
        self.local   = salt.client.LocalClient()

    def workerCount(self):
        n = self.runner.cmd('queue.list_length', ['winworker'], print_event=False)
        return n

    def jobCount(self):
        n = self.runner.cmd('queue.list_length', ['winjob'],
        backend='pgjsonb', print_event=False)
        return n

    def workerPop(self):
        n = self.runner.cmd('queue.pop', ['winworker'], print_event=False)
        return n[0]

    def jobPop(self):
        j = self.runner.cmd('queue.pop', ['winjob'], backend='pgjsonb', print_event=False)
        return j

    def workerPillar(self, minion):
        p = self.runner.cmd('pillar.show_pillar', [minion], print_event=False)
        return p

    def scheduleWork(self, minion, args, password):
        t = self.local.cmd(minion, 'task.create_task', ['scheduled-work'],
            kwarg = {
            'user_name': 'TS',
            'password': password,
            'action_type': 'Execute',
            'cmd': 'psexec',
            'arguments': args,
            'trigger_type': 'Once',
            'trigger_enabled': True,
            'allow_demand_start': True,
            'force': True,
            })
        return t

    def runWork(self, minion):
        t = self.local.cmd(minion, 'task.run', ['scheduled-work'])
        return t


if __name__ == "__main__":

    jf = JobForeman()

    print("Waiting for workers...")
    while True:
        try:
            workerCnt = jf.workerCount()
            #jobCnt = jf.jobCount()

            jobCnt = 1
            if workerCnt > 0 and jobCnt > 0:
                node = jf.workerPop()
                unode = re.split('^(\w+)\..*$', node)[1].upper()

                # request job parameters
                #job = jf.jobPop()

                # get pillar data for work node
                pil = jf.workerPillar(node)

                # map task to appropriate script name
                #task = job['task']
                task = 'test'

                # generate command arguments
                args = ('\\\\{0} -accepteula -nobanner -u {1}\TS -p {2} -h -i 1 C:\\salt\\bin\\python.exe C:\\temp\\{3}').format(unode, unode, pil['userpass'], jobscript[task] )

                # distribute work
                print("%s-sending work to %s..." % (time.strftime('%Y-%m-%d|%H:%M:%S'), node))
                ret = jf.scheduleWork(node, args, pil['userpass'])
                if ret[node] is not True:
                    print("Failed to schedule work...")
                    exit()

                ret = jf.runWork(node)
                if ret[node] is not True:
                    print("Failed to run work...")
                    exit()
        except Exception as err:
            print("%s", err)
            exit(1)






