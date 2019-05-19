# -*- coding: utf-8 -*-
'''
Integration tests for the beacon states
'''

# Import Python Libs
from __future__ import absolute_import, print_function, unicode_literals
import logging

import tornado

# Import Salt Testing Libs
import salt.utils.versions
from salt.ext.six import PY3
from tests.support.case import ModuleCase
from tests.support.helpers import destructiveTest
from tests.support.mixins import SaltReturnAssertsMixin
from tests.support.unit import skipIf


log = logging.getLogger(__name__)

TORNADO_50 = (
    salt.utils.versions.LooseVersion(tornado.version) >=
    salt.utils.versions.LooseVersion('5.0')
)

@destructiveTest
@skipIf(TORNADO_50 and PY3, "We need to make this work with tornado 5.0")
class BeaconStateTestCase(ModuleCase, SaltReturnAssertsMixin):
    '''
    Test beacon states
    '''
    def setUp(self):
        '''
        '''
        self.run_function('beacons.reset', f_timeout=300)

    def tearDown(self):
        self.run_function('beacons.reset', f_timeout=300)

    def test_present_absent(self):
        kwargs = {'/': '38%', 'interval': 5}
        ret = self.run_state(
            'beacon.present',
            name='diskusage',
            f_timeout=300,
            **kwargs
        )
        self.assertSaltTrueReturn(ret)

        ret = self.run_function('beacons.list',
                                return_yaml=False,
                                f_timeout=300)
        self.assertTrue('diskusage' in ret)
        self.assertTrue({'interval': 5} in ret['diskusage'])
        self.assertTrue({'/': '38%'} in ret['diskusage'])

        ret = self.run_state(
            'beacon.absent',
            name='diskusage',
            f_timeout=300
        )
        self.assertSaltTrueReturn(ret)

        ret = self.run_function('beacons.list',
                                return_yaml=False,
                                f_timeout=300)
        self.assertEqual(ret, {'beacons': {}})
