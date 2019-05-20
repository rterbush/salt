#!/usr/bin/env python3
#
# run_prototype_opt.py
#
import logging

from os import path
from time import sleep
from datetime import datetime, date, timedelta
from database import init_engine, init_db, db_session
from model import Symbol, DataSeries, Prototype, Session
from subprocess import Popen
from pywinauto import Desktop
from pywinauto.timings import Timings

Timings.slow()
Timings.window_find_timeout = 90

try:
    from config import DB_URI, TS, BOS_WORKING_DIR, setup_logging
except ModuleNotFoundError as error:
    print("Create config.py file by renaming the config.py.template file and edit settings")
    exit()


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


def get_next_proto(status='new', state='new'):
    """
    Query next prototype for processing
    """
    p = db_session.query(Prototype) \
        .filter_by(status=status, status_state=state) \
        .order_by(Prototype.id) \
        .first()

    logger.info("Querying database for the next {}/{} prototype to process: {}".format(status, state, p))
    return p


if __name__ == "__main__":
    setup_logging()
    logger = logging.getLogger(path.basename(__file__))

    engine = init_engine(DB_URI)
    if engine is not None:
        logger.info("Connected to Postgres database.")

    app = launch_tradestation(TS)

    workspace = open_workspace(app, "BosOptAuto.tsw")

    while True:
        try:
            p = get_next_proto('code', 'done')
            if p is None:
                logger.info("No new code/done prototype to be processed. Sleeping...")
                sleep(60)
                continue

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

        except:
            # set status back to code/done
            p.status = 'code'
            p.status_state = 'done'
            db_session.commit()
            raise