import time
import datetime
import logging
import sqlite3
import asyncio


def timestamp_to_human(timestamp, fmt="%Y-%m-%d %H:%M:%S"):
    if not isinstance(timestamp, int):
        return ""
    return datetime.datetime.utcfromtimestamp(timestamp).strftime(fmt)


def seconds_to_human(seconds):
    m, s = divmod(seconds, 60)
    h, m = divmod(m, 60)
    if h:
        result = "%dh %02dm %02ds" % (h, m, s)
    elif m:
        result = "%02dm %02ds" % (m, s)
    elif s >= 1:
        result = "%02ds" % s
    else:
        result = "%02dms" % (1000 * (seconds - int(seconds)))
    return result


def timing(func):
    def wrapper(*args):
        start = time.time()
        result = func(*args)
        end = time.time()
        elapsed = seconds_to_human(end - start)
        logging.info("Function '%s' took %s." % (func.__name__, elapsed))
        return result
    return wrapper


def configure_logging(args):
    log_fname = 'images-%s-%s-%s-%s.log' % (args["country"], args["language"],
                                               args["start"], args["finish"])
    logging.root.handlers = []
    logging.basicConfig(level=logging.DEBUG if args["verbose"] else logging.INFO,
                        filename=log_fname, filemode='w',
                        format='%(asctime)-25s %(levelname)-10s %(message)s')
    log_fmt = logging.Formatter('%(asctime)-25s %(levelname)-10s %(message)s')
    log_sh = logging.StreamHandler()
    log_sh.setLevel(logging.INFO)
    log_sh.setFormatter(log_fmt)
    logging.getLogger("").addHandler(log_sh)


def reset_event_loop():
    asyncio.get_event_loop().close()
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)


def db_connect(db_file):
    try:
        conn = sqlite3.connect(db_file)
        return conn
    except Exception as err:
        logging.error(err)
    return None


def db_init(db_conn):
    sqls = ['CREATE TABLE IF NOT EXISTS recs (\
                          id INTEGER PRIMARY KEY, \
                          date TEXT, \
                          start TEXT, \
                          response_code INTEGER default NULL, \
                          response_status TEXT default NULL, \
                          channel TEXT, \
                          url TEXT default NULL, \
                          category TEXT, \
                          title TEXT, \
                          segment TEXT, \
                          own_id TEXT, \
                          own_title TEXT, \
                          own_start TEXT, \
                          own_end TEXT);',
            'DELETE FROM recs;']
    for sql in sqls:
        db_commit(db_conn, sql)


def db_query(conn, sql):
    return conn.execute(sql).fetchall()


def db_commit(conn, sql):
    try:
        conn.execute(sql)
        conn.commit()
    except Exception as err:
        print(err)
        print(sql)


if __name__ == "__main__":
    conn = db_connect("DE-de.db")
    count = db_query(conn, "SELECT COUNT(*) FROM recs")[0][0]
    print(count)
