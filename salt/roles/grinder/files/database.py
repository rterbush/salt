#
# database.py
#
import logging
from os import path
from datetime import time
from sqlalchemy import create_engine
from sqlalchemy.orm import scoped_session, create_session
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.exc import IntegrityError

engine = None
db_session = scoped_session(lambda: create_session(
    bind=engine, autoflush=True, autocommit=False)
)

Base = declarative_base()
Base.query = db_session.query_property()

logger = logging.getLogger(path.basename(__file__))

def init_engine(uri, **kwargs):
    global engine
    engine = create_engine(uri, **kwargs)
    logger.info("Database engine initialized.")
    return engine


def init_db():
    """
    Import all modules here that might define models so that
    they will be registered properly on the metadata.  Otherwise
    you will have to import them first before calling init_db()
    """
    from model import DataSeries, Symbol, Prototype, Session

    logger.info("Creating database and tables...")
    Base.metadata.create_all(bind=engine)

    # Create Default Sessions
    sessions = [
        {'name': 'CME_IDX_830_1515', 'description': 'CME Equity Index Futures Day Session', 'start_time': time(8, 30), 'end_time': time(15, 15)},
    ]
    for s in sessions:
        session = Session(**s)
        if db_session.query(Session) \
                     .filter(Session.name == session.name) \
                     .count() == 0:
            logger.info("Creating Session {}".format(s['name']))
            db_session.add(session)

    default_session = db_session.query(Session) \
        .filter(Session.name == 'CME_IDX_830_1515') \
        .first()

    # Create Default Symbols
    symbols = [
        {'ticker': '@EMD', 'description': 'eMini S&P MidCap 400', 'session': default_session},
        {'ticker': '@EMD.D', 'description': 'eMini S&P MidCap 400 Day Session', 'session': default_session},
    ]
    for s in symbols:
        if db_session.query(Symbol) \
                     .filter(Symbol.ticker == s['ticker']) \
                     .count() == 0:
            logger.info("Creating Symbol {}".format(s['ticker']))
            db_session.add(Symbol(**s))

    db_session.commit()