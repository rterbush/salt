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
import salt.output

jobscript = {'test': 'test-job-run.py'}

class JobForeman(object):
    def __init__(self):
        self.opts    = salt.config.master_config('/etc/salt/master')
        self.runner  = salt.runner.RunnerClient(self.opts)

    def workerCount(self):
        n = self.runner.cmd('queue.list_length', ['winworker'], print_event=False)
        return n

    def jobCount(self):
        n = self.runner.cmd('queue.list_length', ['winjob'],
        backend='pgjsonb', print_event=False)
        return n

    def workerPop(self):
        n = self.runner.cmd('queue.pop', ['winworker'], print_event=False)
        return n

    def jobPop(self):
        j = self.runner.cmd('queue.pop', ['winjob'], backend='pgjsonb', print_event=False)
        return j

    def workerPillar(self, minion):
        p = self.runner.cmd('pillar.show_pillar', [minion], print_event=False)
        return p

    def scheduleWork(self, args, password):
        task = {}
        task['schedule_work'] = {
            'module.run': [
                {'name': 'task.create_task'},
                {'m_name': 'scheduled-work'},
                {'m_user_name': 'TS'},
                {'m_password': password },
                {'m_action_type': 'Execute'},
                {'m_cmd': 'psexec'},
                {'m_arguments': args },
                {'m_trigger_enabled': 'True'},
                {'m_trigger_type': 'Once'},
                {'m_force': 'True'},
                {'m_allow_demand_start': 'True'},
            ]
        }

        return self.runner.cmd(task)


if __name__ == "__main__":

    jf = JobForeman()

    while True:
        try:
            workerCnt = jf.workerCount()
            jobCnt = jf.jobCount()
            time.sleep(10)
        except:
            raise
        jobCnt = 1
        if workerCnt > 0 and jobCnt > 0:
            node = jf.workerPop()
            unode = re.split('^(\w+)\..*$', node)[0].upper()
            job = jf.jobPop()
            pil = jf.workerPillar(node)
            task = job['task']

            args = ('\\{0} -acceptula -nobanner -u {1}\TS -p {2} -h -i 1 python.exe {3}').format(node, unode, pil['userpass'], jobscript['test'] )
            print(args)

            #ret = jf.scheduleWork(args, pill['userpass'])


