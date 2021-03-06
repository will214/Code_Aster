# coding: utf-8

"""
Configuration for Calibre 7

. $HOME/dev/codeaster/devtools/etc/env_unstable.sh

waf configure --use-config=calibre7 --prefix=../install/std
waf install -p
"""

import os
ASTER_ROOT = os.environ['ASTER_ROOT']
YAMMROOT = '/opt/aster-prerequisites-yamm/v2014_12'

import intel

def configure(self):
    opts = self.options

    self.env['ADDMEM'] = 250
    self.env.append_value('OPT_ENV', ['. ' + ASTER_ROOT + '/env.sh'])

    self.env.append_value('LIBPATH', [
        #'/usr/lib/atlas-base/atlas',                # for NumPy, see issue18751
        YAMMROOT + '/prerequisites/Python_273/lib',
        YAMMROOT + '/prerequisites/Hdf5_1810/lib',
        YAMMROOT + '/tools/Medfichier_308/lib',
        YAMMROOT + '/prerequisites/Mumps_for_aster/lib',
        YAMMROOT + '/prerequisites/Mumps_for_aster/libseq',
        YAMMROOT + '/prerequisites/Metis_40/lib',
        YAMMROOT + '/prerequisites/Scotch_5111/lib'])

    self.env.append_value('INCLUDES', [
        YAMMROOT + '/prerequisites/Python_273/include/python2.7',
        YAMMROOT + '/prerequisites/Hdf5_1810/include',
        YAMMROOT + '/tools/Medfichier_308/include',
        YAMMROOT + '/prerequisites/Metis_40/Lib',
        YAMMROOT + '/prerequisites/Scotch_5111/include'])

    # to fail if not found
    opts.enable_hdf5 = True
    opts.enable_med = True
    opts.enable_metis = True
    opts.enable_mumps = True
    opts.enable_scotch = True
    opts.enable_mfront = True

    opts.enable_petsc = False
