#!env python3

from __future__ import unicode_literals
from __future__ import print_function

from os import path
import sys
import time
import logging
import re

import salt.config
import salt.runner
import salt.client

jobscript = {
    'DP': 'run_prototype_opt.py'
    }

try:
    from config import setup_logging
except ModuleNotFoundError as error:
    print("Create config.py file by renaming the config.py.template file and edit settings")
    sys.exit(1)

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
        print_event=False)
        return n

    def workerPop(self):
        n = self.runner.cmd('queue.pop', ['winworker'], print_event=False)
        return n[0]

    def jobPop(self):
        #j = self.runner.cmd('queue.pop', ['winjob'], print_event=False)
        j = self.runner.cmd('queue.list_items', ['winjob'], print_event=False)
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
    setup_logging()
    logger = logging.getLogger(path.basename(__file__))

    jf = JobForeman()

    logger.info("Waiting for workers...")
    while True:
        try:
            workerCnt = jf.workerCount()
            jobCnt = jf.jobCount()

            if workerCnt > 0 and jobCnt > 0:
                node = jf.workerPop()
                unode = re.split('^(\w+)\..*$', node)[1].upper()

                # request job parameters
                job = jf.jobPop()
                import ipdb; ipdb.set_trace()
                jobid = re.split('^(\w+)-.*$', job)[1]
                task = jobid[:2]

                # get pillar data for work node
                pil = jf.workerPillar(node)

                # generate command arguments
                args = ('\\\\{0} -accepteula -nobanner -u {1}\\TS -p {2} -h -i 1 C:\\salt\\bin\\python.exe {{ scriptdir }}\\{3} {4}').format(unode, unode, pil['userpass'], jobscript[task], jobid )

                # distribute work
                logger.info("{0}-sending work to {1}...".format(time.strftime('%Y-%m-%d|%H:%M:%S'), node))
                ret = jf.scheduleWork(node, args, pil['userpass'])
                if ret[node] is not True:
                    logger.error("Failed to schedule work...")
                    sys.exit(1)

                ret = jf.runWork(node)
                if ret[node] is not True:
                    logger.error("Failed to run work...")
                    sys.exit(1)
            else:
                time.sleep(10)

        except Exception as err:
            logger.error("{0}".format(err))
            sys.exit(1)






