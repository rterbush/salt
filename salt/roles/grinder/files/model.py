#
# model.py
#
import logging
from os import path
from math import ceil
from datetime import datetime, date, time, timedelta
from sqlalchemy import (BigInteger, Integer, Column, String, Float, DateTime,
                        Date, Time, Boolean, ForeignKey, UniqueConstraint)
from sqlalchemy.orm import relationship
from sqlalchemy.ext.hybrid import hybrid_property, hybrid_method
from database import Base, db_session

logger = logging.getLogger(path.basename(__file__))


class Prototype(Base):
    """
    """
    __tablename__ = 'prototype'

    id = Column(Integer, primary_key=True, autoincrement=True)
    category = Column(String(5))
    symbol_id = Column(Integer, ForeignKey('symbol.id'), nullable=False)
    session_id = Column(Integer, ForeignKey('session.id'), nullable=False)
    data_series_id = Column(Integer, ForeignKey('data_series.id'), nullable=False)
    timeframe1 = Column(String(15), nullable=False)
    timeframe2 = Column(String(15))
    bos_smart_code = Column(String(60), nullable=False)
    max_bars_back = Column(Integer, nullable=False)
    l_s_b = Column(Integer, nullable=False)
    trades_per_day = Column(Integer, default=1, nullable=False)
    daytrading_swing = Column(Integer, default=0, nullable=False)
    poi_switch = Column(String(25), nullable=False)
    poi_n1 = Column(String(25), nullable=False)
    natr = Column(String(25), nullable=False)
    fract = Column(String(25), nullable=False)
    filter1_switch = Column(String(25), nullable=False)
    filter1_n1 = Column(String(25), nullable=False)
    filter1_n2 = Column(String(25), nullable=False)
    filter2_switch = Column(String(25), nullable=False)
    filter2_n1 = Column(String(25), nullable=False)
    filter2_n2 = Column(String(25), nullable=False)
    tsegment = Column(Integer, default=0, nullable=False)
    stop_loss = Column(Integer, default=0, nullable=False)
    profit_target = Column(Integer, default=0, nullable=False)
    status = Column(String(25), default='new', nullable=False)
    status_state = Column(String(25), default='new', nullable=False)
    fitness_func = Column(String(60), default='TradeStation Index', nullable=False)
    use_genetic_opt = Column(Boolean, default=True, nullable=False)
    opt_code_xml = Column(String(5000))
    opt_run_time = Column(Time)

    created_date = Column(DateTime, default=datetime.now)
    last_updated_date = Column(DateTime, default=datetime.now)

    session = relationship("Session", back_populates="prototypes")
    symbol = relationship("Symbol", back_populates="prototypes")
    data_series = relationship("DataSeries", back_populates="prototypes")
    """
    UniqueConstraint(
        category, symbol_id, session_id, data_series_id, timeframe1, l_s_b,
        trades_per_day, daytrading_swing, poi_switch, poi_n1, natr, fract, filter1_switch,
        filter1_n1, filter1_n2, filter2_switch, filter2_n1, filter2_n2, tsegment,
        name='prototype_u1'
    )
    UniqueConstraint(
        category, symbol_id, session_id, data_series_id, timeframe1, timeframe2, l_s_b,
        trades_per_day, daytrading_swing, poi_switch, poi_n1, natr, fract, filter1_switch,
        filter1_n1, filter1_n2, filter2_switch, filter2_n1, filter2_n2, tsegment,
        name='prototype_u2'
    )
    """
    def __repr__(self):
        return ('<Prototype(id:{} category:{} symbol_id:{} data_series_id:{} tf1:{} tf2:{} status:{} created_date:{} last_updated_date:{})>'.format(
                self.id, self.category, self.symbol_id, self.data_series_id, self.timeframe1, self.timeframe2, self.status, self.created_date, self.last_updated_date)
            )


class Symbol(Base):
    """
    """
    __tablename__ = 'symbol'

    id = Column(Integer, primary_key=True, autoincrement=True)
    ticker = Column(String(25), unique=True)
    description = Column(String(100), nullable=False)
    session_id = Column(Integer, ForeignKey('session.id'), nullable=False)

    created_date = Column(DateTime, default=datetime.now)
    last_updated_date = Column(DateTime, default=datetime.now)

    prototypes = relationship("Prototype", order_by=Prototype.id, back_populates="symbol")
    session = relationship("Session", back_populates="symbols")

    def __repr__(self):
        return ('<Symbol(id:{} ticker:{} description:{} created_date:{} last_updated_date:{})>'.format(
                self.id, self.ticker, self.description, self.created_date, self.last_updated_date)
            )


class Session(Base):
    """
    """
    __tablename__ = 'session'

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(50), unique=True, nullable=False)
    description = Column(String(255), default='')
    start_time = Column(Time, default=time(8, 30))
    end_time = Column(Time, default=time(15, 15))

    created_date = Column(DateTime, default=datetime.now)
    last_updated_date = Column(DateTime, default=datetime.now)

    prototypes = relationship("Prototype", order_by=Prototype.id, back_populates="session")
    symbols = relationship("Symbol", order_by=Symbol.id, back_populates="session")

    def __repr__(self):
        return ('<Session(id:{} name:{} desc:{} start:{} end:{} created_date:{} last_updated_date:{})>'.format(
                self.id, self.name, self.description, self.start_time, self.end_time, self.created_date, self.last_updated_date)
            )

    @hybrid_property
    def sess_len(self):
        return (datetime.combine(date.today(), self.end_time) - datetime.combine(date.today(), self.start_time))


class DataSeries(Base):
    """
    """
    __tablename__ = 'data_series'

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(50), nullable=False)
    block = Column(Integer, nullable=False)
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=False)

    created_date = Column(DateTime, default=datetime.now)
    last_updated_date = Column(DateTime, default=datetime.now)

    UniqueConstraint(name, block, name='data_series_u1')
    prototypes = relationship("Prototype", order_by=Prototype.id, back_populates="data_series")

    def __repr__(self):
        return ('<DataSeries(id:{} name:{} block:{} start_date:{} end_date:{} created_date:{} last_updated_date:{})>'.format(
                self.id, self.name, self.block, self.start_date, self.end_date, self.created_date, self.last_updated_date)
            )

    @hybrid_method
    def mod_start_date(self, bars_in_sess, max_bars_back, tf2=False):
        """
        Returns the modified start date based on:
          - number of bars in session
          - max bars back required
          - secondary data is used on not
        """
        if tf2 is None:
            add_days = ceil(max_bars_back / bars_in_sess) / 5 * 7
        elif tf2 == 'Daily':
            add_days = max_bars_back
        else:
            logger.error('{} timeframe 2 not handled yet in DataSeries.')

        return self.start_date - timedelta(days=add_days)

