#!/usr/bin/env python3
#
# create_data_series.py
#
import logging
from os import path
from datetime import datetime
from database import init_engine, init_db, db_session
from model import DataSeries

try:
    from config import DB_URI, TS, setup_logging
except ModuleNotFoundError as error:
    print("Create config.py file by renaming the config.py.template file and edit settings")
    exit()


def get_args():
    """This program creates a new data series in the database and splits it up
    into the number of blocks specified.
    """
    import sys
    from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
    parser = ArgumentParser(description=get_args.__doc__,
                            formatter_class=ArgumentDefaultsHelpFormatter)
    parser.add_argument("name", type=str,
                        help="Name of the data series, i.e DS-2008-2017-10.")
    parser.add_argument("start_date", type=str,
                        help="Start Date for the data series in YYYY-MM-DD format.")
    parser.add_argument("end_date", type=str,
                        help="End Date for the data series in YYYY-MM-DD format.")
    parser.add_argument("num_blocks", type=int, default=10,
                        help="Number of blocks to divide the data series into. Default is 10")
    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit()
    return parser.parse_args()


if __name__ == "__main__":
    setup_logging()
    logger = logging.getLogger(path.basename(__file__))

    args = get_args()
    name = args.name
    start_dt = datetime.strptime(args.start_date, '%Y-%m-%d')
    end_dt = datetime.strptime(args.end_date, '%Y-%m-%d')
    num_blocks = args.num_blocks

    # check start_dt < end_dt
    if start_dt > end_dt:
        logger.error("Start date ({}) must be before end date ({}).".format(start_dt.date(), end_dt.date()))
        exit()

    engine = init_engine(DB_URI)
    init_db()
    if engine is not None:
        logger.info("Connected to Postgres database.")

    # check if data series exists
    ds = db_session.query(DataSeries) \
        .filter_by(name=name) \
        .first()

    if ds:
        logger.error("Data series {} already exists.".format(name))
        exit()

    # add new data series
    inc = (end_dt - start_dt) / num_blocks
    s = start_dt
    for i in range(1, num_blocks+1):
        e = s + inc
        logger.info("Block {}: {} to {}".format(i, s.date(), e.date()))
        ds = DataSeries(name=name, block=i, start_date=s.date(), end_date=e.date())
        db_session.add(ds)
        s = e

    db_session.commit()

    logger.info("{} added to the database.".format(ds))