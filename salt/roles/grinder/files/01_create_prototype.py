#!/usr/bin/env python3
#
# create_prototype.py
#
# The workflow state is managed with the "state" and "state_status" columns of
# the prototype

import logging
from os import path
from datetime import datetime
from database import init_engine, init_db, db_session
from model import Symbol, DataSeries, Prototype, Session
from sqlalchemy.exc import IntegrityError

try:
    from config import DB_URI, TS, setup_logging
except ModuleNotFoundError as error:
    print("Create config.py file by renaming the config.py.template file and edit settings")
    exit()


def get_args():
    """Creates a new prototype in the database and set the status to new. This is the first
    step in the design & prototype phase.
    """
    import sys
    from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
    parser = ArgumentParser(description=get_args.__doc__)
    parser.add_argument("ticker", type=str,
                        help="Ticker that exists in TradeStation")
    parser.add_argument("timeframe1", type=str, #choices=['15min','20min','30min','45min','60min','90min','120min'],
                        help="Timeframe 1 is the main timeframe the prototype runs on. [15min, 20min, 30min, 45min, 60min, 90min, 120min]")
    parser.add_argument("timeframe2", type=str, #choices=['15min','20min','30min','45min','60min','90min','120min'],
                        help="Timeframe 2 is the secondary timeframe for further filtering. [120min, 240min, 360min, Daily, None]")
    parser.add_argument("data_series", type=str,
                        help="Name of the data series used to determine block.")
    parser.add_argument("block", type=int,
                        help="Block number to run prototype on. Usually 1 to 10 but depends on the data series.")
    parser.add_argument("-b", "--bos_smart_code", type=str, default='BOS-SMART-CODE-1.8.1',
                        help="BOS Smart Code Version to use. Default BOS-SMART-CODE-1.8.1")
    parser.add_argument("-m", "--max_bars_back", type=int, default=200,
                        help="Number of bars the strategy will reference in the code. Default 200")
    parser.add_argument("-sw", "--swing", action="store_true",
                        help="Swing strategy instead of a breakout strategy.")
    parser.add_argument("-s", dest="session", type=str, default=None,
                        help="Name of the session if different than the default which is usually 8:30 to 15:15. If nothing specified, then use the default session of symbol")
    parser.add_argument("-lsb", dest="l_s_b", type=int, default=3,
                        help="1=Long, 2=Short or 3=Both. Default=3")
    parser.add_argument("-tpd", dest="trades_per_day", type=int, default=1,
                        help="Number of trades per day. Default 1")
    parser.add_argument("-p", dest="poi", type=str, default="range:1,12,1",
                        help="Point of Initiation switch 1..12 step 1. [preset:basic 1..4, preset:adv 5..8, preset:ma 9..12")
    parser.add_argument("-p1", dest="poi_n1", type=str, default="range:1,15,1",
                        help="MovAvg lookback for POI_Switch 9 to 12 only.")
    parser.add_argument("-natr", type=str, default="range:5,60,5",
                        help="ATR Lookback from 5-60 Step 5.")
    parser.add_argument("-fract", type=str, default="range:0.6,3.0,0.15",
                        help="Fraction of ATR. Default: 0.6 - 3.0 step 0.15")
    parser.add_argument("-f1", dest="filter1", type=str, default="range:1,40,1",
                        help="Filter 1 switch. preset:vol (1-8), preset:trend (9-16), preset:pullback (17-24), preset:price (25-32), preset:volume (33-40). Default: 1-40 step 1")
    parser.add_argument("-f1n1", dest="filter1_n1", type=str, default="range:1,20,1",
                        help="Filter 1 lookback period 1. Default: 1-20 step 1")
    parser.add_argument("-f1n2", dest="filter1_n2", type=str, default="range:1,20,1",
                        help="Filter 1 lookback period 2. Default: 1-20 step 1")
    parser.add_argument("-f2", dest="filter2", type=str, default="range:1,40,1",
                        help="Filter 2 switch. preset:vol (1-8), preset:trend (9-16), preset:pullback (17-24), preset:price (25-32), preset:volume (33-40). Default: 1-40 step 1")
    parser.add_argument("-f2n1", dest="filter2_n1", type=str, default="range:1,20,1",
                        help="Filter 2 lookback period 1. Default: 1-20 step 1")
    parser.add_argument("-f2n2", dest="filter2_n2", type=str, default="range:1,20,1",
                        help="Filter 2 lookback period 2. Default: 1-20 step 1")
    parser.add_argument("-ts", dest="tsegment", type=int, default="0",
                        help="Time segment: 0 = full range, 1=first third of the session, 2=middle third, 3=last third of the session")
    parser.add_argument("-sl", dest="stop_loss", type=int, default="0",
                        help="Stop Loss in $$$")
    parser.add_argument("-pt", dest="profit_target", type=int, default="0",
                        help="Profit Target in $$$")
    parser.add_argument("--exhaustive", action="store_true",
                        help="Use exhaustive optimization instead of genetic by default.")
    parser.add_argument('-f', '--fitness', default='TradeStation Index',
                        choices=['TradeStation Index', 'Net Profit', 'ProfitFactor', 'Expectancy Score', 'Avg Trade'],
                        help='Fitness function for optimization (default: %(default)s)')


    """
    L_S_B                // 1=LONG strategies only, 2=SHORT strategies only, 3=LONG and SHORT strategies
    TradesPerDay(1)
    DaytradingORswing(0) [0,1]
    POI_Switch           // 1-12 STEP 1 {1-4 BASIC POIs, 5-8 ADVANCED POIs, 9-12 MOVING AVERAGE POIs}
    POI_N1               // 1-15 STEP 1 {FOR POI_SWITCH 9-12 ONLY}
    NATR                 // 5-60 STEP 5
    Fract                // 0.6 - 3 STEP 0.1 or 0.15 (or use F-SEGMENT concept)
    Filter1_Switch       // 1-40   {1-8 VOLATILITY, 9-16 TREND INDICATORS, 17-24 PULLBACKS, 25-32 PRICE ACTION, 33-40 VOLUME}
    Filter1_N1           // 1-20 step 1
    Filter1_N2           // 1-20 step 1
    Filter2_Switch       // 1-40   {1-8 VOLATILITY, 9-16 TREND INDICATORS, 17-24 PULLBACKS, 25-32 PRICE ACTION, 33-40 VOLUME}
    Filter2_N1           // 1-20 step 1
    Filter2_N2           // 1-20 step 1
    Tsegment(0)          // 0 = full range, 1=first third of the session, 2=middle third, 3=last third of the session
    SL(0)
    PT(0)
    """
    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit()

    return parser.parse_args()


def get_symbol(ticker):
    """
    Retrieves the symbol from the database if it exists.
    """
    s = db_session.query(Symbol) \
        .filter_by(ticker = ticker) \
        .one()
    if not s:
        logger.error("Symbol {} does not exist. Please create first.".format(ticker))
        exit()
    else:
        logger.info("Loaded symbol {}".format(s.ticker))
    return s


def get_data_series(name, block):
    """
    Retrieves the data series from the database if it exists.
    """
    ds = db_session.query(DataSeries) \
        .filter_by(name=name, block=block) \
        .one()
    if not ds:
        logger.error("DataSeries {} with block {} does not exist. Please create first.".format(name, block))
        exit()
    else:
        logger.info("Loaded block {} from data series {}".format(ds.block, ds.name))
    return ds


def get_session(name):
    """
    Retrieves the session from the database if it exists.
    """
    s = db_session.query(Session) \
        .filter_by(name=name) \
        .one()
    if not s:
        logger.error("Session {} does not exist. Please create first.".format(name))
        exit()
    else:
        logger.info("Loaded session {} from database".format(s.name))
    return s


def validate_timeframe(tf, secondary=False):
    """
    """
    valid_primary = ['15min', '20min', '30min', '45min', '60min', '90min', '120min']
    valid_secondary = ['60min', '90min', '120min', '240min', '360min', 'Daily', 'None']

    if not secondary:
        if tf in valid_primary:
            return tf
        else:
            logger.error('Timeframe1 not valid. Should be one of {}'.format(valid_primary))
            exit()
    else:
        if tf == 'None':
            return None
        elif tf in valid_secondary:
            return tf
        else:
            logger.error('Timeframe2 not valid. Should be one of {}'.format(valid_secondary))
            exit()

if __name__ == "__main__":
    setup_logging()
    logger = logging.getLogger(path.basename(__file__))

    args = get_args()
    logger.debug(args)

    engine = init_engine(DB_URI)
    init_db()
    if engine is not None:
        logger.info("Connected to Postgres database.")

    symbol = get_symbol(args.ticker)
    data_series = get_data_series(args.data_series, args.block)

    if args.session:
        session = get_session(args.session)
    else:
        session = symbol.session

    category = 'SW' if args.swing else 'BO'
    tf1 = validate_timeframe(args.timeframe1)
    tf2 = validate_timeframe(args.timeframe2, secondary=True)
    max_bars = args.max_bars_back
    day_swing = 0 if category == 'BO' else 1
    use_genetic = False if args.exhaustive else True

    p = Prototype(
        category=category,
        symbol=symbol,
        session=session,
        data_series=data_series,
        timeframe1=tf1,
        timeframe2=tf2,
        bos_smart_code=args.bos_smart_code,
        max_bars_back=max_bars,
        l_s_b=args.l_s_b,
        trades_per_day=args.trades_per_day,
        daytrading_swing=day_swing,
        poi_switch=args.poi,
        poi_n1=args.poi_n1,
        natr=args.natr,
        fract=args.fract,
        filter1_switch=args.filter1,
        filter1_n1=args.filter1_n1,
        filter1_n2=args.filter1_n2,
        filter2_switch=args.filter2,
        filter2_n1=args.filter2_n1,
        filter2_n2=args.filter2_n2,
        tsegment=args.tsegment,
        stop_loss=args.stop_loss,
        profit_target=args.profit_target,
        fitness_func=args.fitness,
        use_genetic_opt=use_genetic
    )
    try:
        db_session.add(p)
        db_session.flush()
    except IntegrityError:
        db_session.rollback()
        logger.error("Prototype already exits {}".format(p))
    else:
        db_session.commit()
        logger.info("Prototype added {}".format(p))