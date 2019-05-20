#!/usr/bin/env python3
#
# gen_prototype_code.py
#
import logging
from os import path
from lxml import etree
from math import ceil
from os import path
from dicttoxml import dicttoxml
from datetime import datetime, date, timedelta
from database import init_engine, init_db, db_session
from model import Symbol, DataSeries, Prototype, Session

from time import sleep

try:
    from config import DB_URI, TS, BOS_WORKING_DIR, setup_logging, WFA_CONST
except ModuleNotFoundError as error:
    print("Create config.py file by renaming the config.py.template file and edit settings")
    exit()


def add_securities(proto, securities):
    """
    """
    intervals = {
        '15min': {'ChartType': 'Bar', 'Compression': 'Minute', 'Quantity': 15},
        '20min': {'ChartType': 'Bar', 'Compression': 'Minute', 'Quantity': 20},
        '30min': {'ChartType': 'Bar', 'Compression': 'Minute', 'Quantity': 30},
        '45min': {'ChartType': 'Bar', 'Compression': 'Minute', 'Quantity': 45},
        '60min': {'ChartType': 'Bar', 'Compression': 'Minute', 'Quantity': 60},
        '90min': {'ChartType': 'Bar', 'Compression': 'Minute', 'Quantity': 90},
        '120min': {'ChartType': 'Bar', 'Compression': 'Minute', 'Quantity': 120},
        '240min': {'ChartType': 'Bar', 'Compression': 'Minute', 'Quantity': 240},
        '360min': {'ChartType': 'Bar', 'Compression': 'Minute', 'Quantity': 360},
        'Daily': {'ChartType': 'Bar', 'Compression': 'Daily'},
    }
    tf1 = proto.timeframe1
    tf2 = proto.timeframe2
    bars = ceil(proto.session.sess_len / intervals[tf1]['Quantity'] / timedelta(minutes=1))
    mod_start_date = proto.data_series.mod_start_date(bars, proto.max_bars_back, tf2)

    # Timeframe 1
    security = etree.SubElement(securities, "Security")
    symbol = etree.SubElement(security, "Symbol")
    symbol.text = proto.symbol.ticker

    interval = dicttoxml(intervals[tf1], custom_root="Interval", attr_type=False)
    security.append(etree.fromstring(interval))

    history = etree.SubElement(security, "History")
    sdate = etree.SubElement(history, "FirstDate")
    sdate.text = mod_start_date.strftime('%Y-%m-%d')
    edate = etree.SubElement(history, "LastDate")
    edate.text = proto.data_series.end_date.strftime('%Y-%m-%d')

    # Timeframe 2
    if tf2:
        security = etree.SubElement(securities, "Security")
        symbol = etree.SubElement(security, "Symbol")
        symbol.text = proto.symbol.ticker

        interval = dicttoxml(intervals[tf2], custom_root="Interval", attr_type=False)
        security.append(etree.fromstring(interval))

        history = etree.SubElement(security, "History")
        sdate = etree.SubElement(history, "FirstDate")
        sdate.text = mod_start_date.strftime('%Y-%m-%d')
        edate = etree.SubElement(history, "LastDate")
        edate.text = proto.data_series.end_date.strftime('%Y-%m-%d')


def add_strategy(proto, strategies):
    """
    """
    def new_input(param):
        input = {}
        output = None

        if isinstance(param['value'], bool):
            input['Name'] = param['name']
            input['Value'] = param['value']
            input['Type'] = 'TrueFalse'
            output = dicttoxml(input, custom_root="Input", attr_type=False)

        elif isinstance(param['value'], int) or isinstance(param['value'], float) or param['value'].isdigit():
            input['Name'] = param['name']
            input['Value'] = param['value']
            input['Type'] = 'Numeric'
            output = dicttoxml(input, custom_root="Input", attr_type=False)

        elif 'range' in param['value']:
            input['Name'] = param['name']
            input['Start'] = param['value'].split(':')[1].split(',')[0]
            input['Stop'] = param['value'].split(':')[1].split(',')[1]
            input['Step'] = param['value'].split(':')[1].split(',')[2]
            input['Type'] = 'Numeric'
            output = dicttoxml(input, custom_root="OptRange", attr_type=False)

        else:
            raise Exception('Unhandled parameter in new_input(): {}'.format(param))

        return output


    second_data = True if proto.timeframe2 else False
    strategy = etree.SubElement(strategies, "Strategy")
    name = etree.SubElement(strategy, "Name")
    name.text = proto.bos_smart_code

    inputs = etree.SubElement(strategy, "Inputs")
    inputs.append(etree.fromstring(
        new_input({'name': 'SecondDataYesNo', 'value': second_data})
    ))
    inputs.append(etree.fromstring(
        new_input({'name': 'L_S_B', 'value': proto.l_s_b})
    ))
    start = int(proto.session.start_time.strftime('%H%M'))
    inputs.append(etree.fromstring(
        new_input({'name': 'sess_start', 'value': start})
    ))
    end = int(proto.session.end_time.strftime('%H%M'))
    inputs.append(etree.fromstring(
        new_input({'name': 'sess_end', 'value': end})
    ))
    inputs.append(etree.fromstring(
        new_input({'name': 'TradesPerDay', 'value': proto.trades_per_day})
    ))
    inputs.append(etree.fromstring(
        new_input({'name': 'DaytradingOrSwing', 'value': proto.daytrading_swing})
    ))
    inputs.append(etree.fromstring(
        new_input({'name': 'POI_Switch', 'value': proto.poi_switch})
    ))
    inputs.append(etree.fromstring(
        new_input({'name': 'POI_N1', 'value': proto.poi_n1})
    ))
    inputs.append(etree.fromstring(
        new_input({'name': 'NATR', 'value': proto.natr})
    ))
    inputs.append(etree.fromstring(
        new_input({'name': 'Fract', 'value': proto.fract})
    ))
    inputs.append(etree.fromstring(
        new_input({'name': 'Filter1_Switch', 'value': proto.filter1_switch})
    ))
    inputs.append(etree.fromstring(
        new_input({'name': 'Filter1_N1', 'value': proto.filter1_n1})
    ))
    inputs.append(etree.fromstring(
        new_input({'name': 'Filter1_N2', 'value': proto.filter1_n2})
    ))
    inputs.append(etree.fromstring(
        new_input({'name': 'Filter2_Switch', 'value': proto.filter2_switch})
    ))
    inputs.append(etree.fromstring(
        new_input({'name': 'Filter2_N1', 'value': proto.filter2_n1})
    ))
    inputs.append(etree.fromstring(
        new_input({'name': 'Filter2_N2', 'value': proto.filter2_n2})
    ))
    inputs.append(etree.fromstring(
        new_input({'name': 'Tsegment', 'value': proto.tsegment})
    ))
    inputs.append(etree.fromstring(
        new_input({'name': 'SL', 'value': proto.stop_loss})
    ))
    inputs.append(etree.fromstring(
        new_input({'name': 'PT', 'value': proto.profit_target})
    ))


def add_settings(proto, settings):
    """
    """
    genetic_options = etree.SubElement(settings, "GeneticOptions")
    gen = etree.SubElement(genetic_options, "Generations")
    gen.text = str(WFA_CONST['Generations'])
    pop_size = etree.SubElement(genetic_options, "PopulationSize")
    pop_size.text = str(WFA_CONST['PopulationSize'])
    cross_rate = etree.SubElement(genetic_options, "CrossoverRate")
    cross_rate.text = str(WFA_CONST['CrossOverRate'])
    mute_rate = etree.SubElement(genetic_options, "MutationRate")
    mute_rate.text = str(WFA_CONST['MutationRate'])

    result_options = etree.SubElement(settings, "ResultOptions")
    fitness = etree.SubElement(result_options, "FitnessMetric")
    fitness.text = proto.fitness_func
    keep_tests = etree.SubElement(result_options, "NumTestsToKeep")
    keep_tests.text = str(WFA_CONST['KeepTests'])

    out_sample = etree.SubElement(settings, "OutSample")
    excl_pct = etree.SubElement(out_sample, "ExcludePercent")
    first = etree.SubElement(excl_pct, "ExcludeFirst")
    first.text = str(WFA_CONST['ExcludeFirst'])
    last = etree.SubElement(excl_pct, "ExcludeLast")
    last.text = str(WFA_CONST['ExcludeLast'])

    general_options = etree.SubElement(settings, "GeneralOptions")
    mbb = etree.SubElement(general_options, "MaxBarsBack")
    mbb.text = str(proto.max_bars_back)


if __name__ == "__main__":
    setup_logging()
    logger = logging.getLogger(path.basename(__file__))

    engine = init_engine(DB_URI)
    if engine is not None:
        logger.info("Connected to Postgres database.")

    while True:
        try:
            # get next new/new prototype
            p = db_session.query(Prototype) \
                .filter_by(status='new', status_state='new') \
                .order_by(Prototype.id) \
                .first()
            if p is None:
                logger.info("Sleeping...")
                sleep(60)
                continue

            logger.info("Generating code for: {}".format(p))

            p.status_state = 'gen_code' # generating code status. Set back to new on error
            db_session.commit()

            job = etree.Element("Job")
            method = etree.SubElement(job, "Method")
            method.text = 'Genetic' if p.use_genetic_opt else 'Exhaustive'
            securities = etree.SubElement(job, "Securities")

            add_securities(p, securities)

            strategies = etree.SubElement(job, "Strategies")
            add_strategy(p, strategies)

            settings = etree.SubElement(job, "Settings")
            add_settings(p, settings)

            opt_code = etree.tostring(job, xml_declaration=True, encoding="utf-8", pretty_print=True, ).decode()

            # create filename: DP[id]-[ticker]-[block].xml
            filename = "DP{0:04d}-{1}-{2}.xml".format(p.id, p.symbol.ticker, p.data_series.block)
            f = open(path.join(BOS_WORKING_DIR, "DP_XML", filename),"w+")
            f.write(opt_code)
            f.close

            p.opt_code = opt_code
            p.status = 'code'
            p.status_state = 'done'
            db_session.commit()

        except:
            p.status = 'new'
            p.status_state = 'new'
            db_session.commit()
            raise