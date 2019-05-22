#
# run_prototype_opt.py
#
import sys
import logging

from os import path
from time import sleep
from datetime import datetime, date, timedelta
from database import init_engine, init_db, db_session
from model import Symbol, DataSeries, Prototype, Session
from subprocess import Popen
from pywinauto import Desktop
from pywinauto.timings import Timings

import salt.config
import salt.loader
import salt.client

Timings.slow()
Timings.window_find_timeout = 90

try:
    from config import DB_URI, TS, BOS_WORKING_DIR, setup_logging
except ModuleNotFoundError as error:
    print("Create config.py file by renaming the config.py.template file and edit settings")
    sys.exit(1)


def launch_tradestation(TS):
    """
    """
    app = Desktop(backend="uia").window(title_re="TradeStation.*")
    if not app.exists():
        logger.info("Launching TradeStation application {}".format(TS['program']))
        Popen(TS['program'], shell=True)
        app.wait('visible')
        app.UserNameEdit.set_edit_text(TS['username'])
        app.PasswordEdit.set_edit_text(TS['password'])
        app.WorkOffline.click()
        app.Main.wait('visible')
    else:
        logger.info("TradeStation is already opened.")

    return app


def open_workspace(app, workspace):
    """
    """
    workspace = path.join(BOS_WORKING_DIR, "TEMPLATES", "BosOptAuto.tsw")
    if not app.BosOptAuto.exists():
        logger.info("Opening TradeStation workspace: {}".format(workspace))
        if not path.exists(workspace):
            logger.error("Workspace {} does not exist.  Needs to be created.".format(workspace))
            exit()
        app.MenuBar.type_keys("%FO") # File > Open Workspace
        app.OpenWorkspace.type_keys("%N") # Filename box
        app.OpenWorkspace.ComboBox1.Edit.set_edit_text(workspace)
        app.OpenWorkspace.type_keys("%O") # Open
        app.BosOptAuto.wait('visible')
    else:
        logger.info("Workspace {} is already opened.".format(workspace))

    return workspace


def get_proto_params(id):
    """
    Query prototype ID for processing
    """
    p = db_session.query(Prototype) \
        .filter_by(id=id)

    logger.info("Querying database for prototype id: {} to process: {}".format(id, p))
    return p

def register_complete():
    estr   = ('systembuilder/task/{0}/completed').format(__grains__['id'])
    __caller__.cmd('event.send', estr,
                  { 'completed': True,
                    'message': "System Builder job completed"})


if __name__ == "__main__":
    if len(sys.argv) < 2:
        logger.error("Prototype optimization requires prototype ID...")
        sys.exit(1)

    dpid = sys.argv[1]
    __caller__  = salt.client.Caller()
    __opts__    = salt.config.minion_config('C:/salt/conf/minion')
    __grains__  = salt.loader.grains(__opts__)

    setup_logging()
    logger = logging.getLogger(path.basename(__file__))

    engine = init_engine(DB_URI)
    if engine is not None:
        logger.info("Connected to Postgres database.")

    app = launch_tradestation(TS)

    workspace = open_workspace(app, "BosOptAuto.tsw")

    try:
        p = get_proto_params(dpid)
        if p is None:
            logger.info("Scheduled prototype job not found...")
            sys.exit(1)

        logger.info("Setting status_state to wfa in database.")
        p.status_state = 'wfa' # wfa status_state. Set back to new on error or error?
        db_session.commit()

        # Format TradingApp
        logger.info("Format TradingApp and set the input parameters for optimization run.")
        app.BosOptAuto.set_focus()
        app.MenuBar.type_keys("%FF{ENTER}{ENTER}")
        Timings.fast()
        app["Format TradingApp: BosOptAuto"].wait("visible")
        app["Format TradingApp: BosOptAuto"].TabControl.select("General")
        app["Format TradingApp: BosOptAuto"].type_keys("%r{}".format(p.max_bars_back))
        app["Format TradingApp: BosOptAuto"].TabControl.select("Inputs")

        filename = "DP{0:04d}-{1}-{2}".format(p.id, p.symbol.ticker, p.data_series.block)
        job_file = path.join(BOS_WORKING_DIR, "DP_XML", filename +".xml")
        is_file = path.join(BOS_WORKING_DIR, "IS", filename + "-IS.txt")
        oos_file = path.join(BOS_WORKING_DIR, "OOS", filename + "-OOS.txt")

        logger.info("Inputs:")
        logger.info("  JobFile: {}".format(job_file))
        logger.info("  IsFile : {}".format(is_file))
        logger.info("  OosFile: {}".format(oos_file))

        app["Format TradingApp: BosOptAuto"].Inputs.PropertyList.set_focus()
        app["Format TradingApp: BosOptAuto"].Inputs.PropertyList.type_keys('"{}"'.format(job_file))   # JobFile
        app["Format TradingApp: BosOptAuto"].Inputs.PropertyList.type_keys('{DOWN}')
        app["Format TradingApp: BosOptAuto"].Inputs.PropertyList.type_keys('"{}"'.format(is_file))    # ResultsIS
        app["Format TradingApp: BosOptAuto"].Inputs.PropertyList.type_keys('{DOWN}')
        app["Format TradingApp: BosOptAuto"].Inputs.PropertyList.type_keys('"{}"'.format(oos_file))   # ResultsOOS
        app["Format TradingApp: BosOptAuto"].Ok.click()
        Timings.slow()

        stime = datetime.now()
        logger.info("Starting optimization...")
        app.BosOptAuto.StartOptimizatin.click()
        status = app.BosOptAuto.Edit.iface_value.CurrentValue
        sleep(5)
        while status == 'Running':
            status = app.BosOptAuto.Edit.iface_value.CurrentValue
            logger.info("Optimization status: {}".format(status))
            sleep(10)

        runtime = datetime.now() - stime
        logger.info("Optimization completed [{}] in {}.".format(status, runtime))

        p.opt_run_time = runtime
        p.status = 'wfa'
        p.status_state = 'done'
        db_session.commit()
        register_complete()

    except:
        # set status back to code/done
        p.status = 'code'
        p.status_state = 'done'
        db_session.commit()
        raise
