"""A script to collect images urls from EPG responses and retrieve images via HTTP GET:
 * get EPG index,
 * get EPG segment details for each segment - in asynchronous mode,
 * sequentially iterate through all events within each segment and collect image URLs:
    - "poster" and "wall".
 * fetch every image url - in asynchronous mode.
Countries: NL/CH/DE/IE/PL/AT/CZ/HU/RO/SK
http://epg.prod.de.dmdsdp.com/de/en/events/segments/index
"""
import sys
import os
import datetime
import logging
import argparse
import requests
import uuid
import asyncio
from aiohttp.client_exceptions import ClientConnectorError, ClientPayloadError, \
                                      ServerDisconnectedError
import tools
from async_http import AsyncHttpReturn, AsyncHttpNoReturn
from elastic import ElasticSearch
from report import Report
import socket
from import_file import import_file

class ImagesLinksExaminer(AsyncHttpNoReturn):
    """A class to send HTTP GET requests asynchronously without storing the returned responses."""

    def __init__(self, db_conn, elastic, urls):
        """A class initializer.

        :param db_conn: a connection to the SQLite database to keep detailed results about each URL.
        :param elastic: an instance of ElasticSearch class.
        :param urls: a list of images URLs.
        """
        super(ImagesLinksExaminer, self).__init__(urls)
        self.db_conn = db_conn
        self.elastic = elastic

    async def aget(self, event):
        """Fetch a URL, log the response, return nothing."""
        try:
            async with self.session.get(event["url"], timeout=1200) as response:
                await response.read()
                self._log_response(response, event)
        except (asyncio.TimeoutError, ClientConnectorError,
                ClientPayloadError, ServerDisconnectedError) as err:
            logging.error("Could not fetch the image URL %s due to %s" % (event["url"], err))
            sql = "INSERT INTO recs (channel, date, start, category, title, url, segment, \
                                     own_id, own_title, own_start, own_end) \
                   VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');" % \
                  (event["channel"], event["date"], event["start"], event["type"],
                   event["title"], event["url"], event["segment"],
                   event["own_id"], event["own_title"], event["own_start"], event["own_end"])
            tools.db_commit(self.db_conn, sql)
            self.elastic.update_data(event["uuid"], {"%s" % event["type"]: {"status": "FAIL"}})

    @tools.timing
    def verify(self):
        """A method to fetch all the given URLs, log the responses without storing the results.
        Note: no need to declare loop = asyncio.get_event_loop() since self.loop will be used.
        """
        future = asyncio.ensure_future(self.run())
        self.loop.run_until_complete(future)
        self.loop.close()

    def _log_response(self, response, info):
        """Log response with different log level depending on the response code; return nothing."""
        sql = "INSERT INTO recs (response_code, response_status, channel, date, start, url, \
                                 category, title, segment, own_id, own_title, own_start, own_end) \
               VALUES (%d, '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');" % \
              (response.status, response.reason, info["channel"], info["date"], info["start"],
               response.url, info["type"], info["title"], info["segment"],
               info["own_id"], info["own_title"], info["own_start"], info["own_end"])
        tools.db_commit(self.db_conn, sql)
        if response.status == 200:
            logging.debug("%s %s %s" % (response.status, response.reason, response.url))
            kwargs = {"%s" % info["type"]: {"status": "OK"}}
        else:
            logging.warning("%s %s %s" % (response.status, response.reason, response.url))
            kwargs = {"%s" % info["type"]: {"status": "UNREACHABLE"}}
        self.elastic.update_data(info["uuid"], kwargs)


class ImagesLinks(AsyncHttpReturn):
    """A class to collect images urls using EPG micro-service and fetch each url asynchronously."""

    def __init__(self, db_conn, elastic, epg_endpoint, country, language, day_start, day_end):
        """A class initializer.

        :param db_conn: a connection to the SQLite database to keep detailed results about events.
        :param elastic: an instance of ElasticSearch class.
        :param epg_endpoint: a string of EPG endpoint, e.g. "epg.labe2esi.nl.dmdsdp.com".
        :param country: a string of country code, e.g. "BE".
        :param language: a string of language code, e.g. "nl".
        :param day_start: an index of segment hash to start from (min = 0, max = segment_end):
                          0 = today - 7 days; 7 = today; 20 = today + 13 days.
        :param day_end: an index of segment hash to end with (min = segment_start, max = 20):
                        0 = today - 7 days; 7 = today; 20 = today + 13 days.
        """
        super(ImagesLinks, self).__init__([], True)
        self.db_conn = db_conn
        self.elastic = elastic
        self.requests_session = requests.Session()
        self.epg_endpoint = epg_endpoint
        self.country = country.lower()
        self.language = language
        self.images = ["poster", "wall"]
        self.segments = self.get_epg_segments("http://%s/%s/%s/events/segments/index" %
                                              (self.epg_endpoint, self.country, self.language),
                                              day_start, day_end)
        self.urls = ["http://%s/%s/%s/events/segments/%s" % (self.epg_endpoint, self.country,
                                                             self.language, segment)
                     for segment in self.segments]

    async def aget(self, url):
        """Override aget() method to call a supporting function self._get_images_urls().
        Each call will return a list of discovered images URLs.
        An empty list is returned if ClientPayloadError or ServerDisconnectedError occurred.
        """
        try:
            async with self.session.get(url, timeout=1200) as response:
                data = await response.json() if response.status == 200 else {}
                images_urls = self._get_images_urls(data, url[url.rfind("/") + 1:])
                return images_urls
        except (asyncio.TimeoutError, ClientConnectorError,
                ClientPayloadError, ServerDisconnectedError) as err:
            logging.error("Could not fetch the URL vf %s due to %s" % (url, err))
        return []

    @tools.timing
    def collect_urls(self):
        """A method to collect images URLs from EPG micro-service:
        1) collect desired EPG segment hashes from EPG index;
        2) for each segment iterate over all events and collect images urls & details in the form of
           a list of dictionaries with keys: 'segment', 'channel', 'url', 'type', 'starttime'.
        Note: no need to declare loop = asyncio.get_event_loop() since self.loop will be used.
        """
        future = asyncio.ensure_future(self.run())
        self.loop.run_until_complete(future)
        results = []
        for task_urls in future.result():
            results.extend(task_urls)
        logging.info("Collected URLs: %s." % len(results))
        return results

    @tools.timing
    def get_epg_segments(self, epg_index_url, start, end):
        """A method to collect segment hashes from EPG index response.
        Each segment has 21 hashes - one hash per day:
        starting from "7 days ago" up to "13 days in future", the 7th hash is for "today".

        :param epg_index_url: a string, e.g. "http://epg.labe2esi.nl.dmdsdp.com/be/nl/events/index".
        :param start: an integer - an index of a segment hash in the list of 21 hashes.
        :param end: an integer - an index of a segment hash in the list of 21 hashes.

        :return: a list of segments hashes.
        """
        if start < 0 or start > end or end > 20:
            return []
        segments = []
        response = None
        try:
            response = self.requests_session.get(epg_index_url)
        except (requests.exceptions.RequestException, requests.exceptions.ConnectionError,
                requests.exceptions.Timeout, TimeoutError, socket.error) as error:
            logging.warning("ERROR when sent GET to %s :\n%s" % (epg_index_url, error))
        if response.status_code == 200:
            if response.text:
                data = response.json()
                if "entries" in data:
                    for entry in data["entries"]:
                        segments.extend([item for item in entry["segments"][start:end + 1]])
                else:
                    logging.warning("Index %s contains no entries." % epg_index_url)
            else:
                logging.warning("Empty index returned for %s." % epg_index_url)
        else:
            logging.warning("Code %s returned for %s. Reason is: %s" % (response.status_code, epg_index_url, response.reason))
        logging.info("Segments found: %s." % len(segments))
        return segments

    def send_event_to_elastic(self, event):
        now = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S.%fZ")
        NO = "MISSING"
        kwargs = {"uuid": event["uuid"],
                  "channel": event["channel"], "country": self.country, "start": now, "end": now,
                  "poster_status": "IN PROGRESS" if event["poster"] else NO,
                  "poster_value": event["poster"],
                  "wall_status": "IN PROGRESS" if event["wall"] else NO,
                  "wall_value": event["wall"],
                  "id_status": "OK" if event["own_id"] and event["own_id"] != "missing" else NO,
                  "id_value": "%s" % event["own_id"],
                  "title_status": "OK" if event["own_title"] and event["own_title"] != "missing" \
                                   else NO,
                  "title_value": "%s" % event["own_title"],
                  "start_status": "OK" if isinstance(event["own_start"], int) else NO,
                  "start_value": "%s" % (int(event["own_start"] * 1000)),
                  "end_status": "OK" if isinstance(event["own_end"], int) else NO,
                  "end_value": "%s" % (int(event["own_end"]) * 1000)}
        self.elastic.send_data(kwargs)

    def _extend_event(self, event, date, channel, segment):
        title = event.get("title", "") \
                     .replace("'", "''") \
                     .encode('ascii', 'xmlcharrefreplace') \
                     .decode()
        missing = "missing"
        res = {"uuid": uuid.uuid4(),
               "channel": channel, "segment": segment, "title": title, "date": date.split()[0],
               "start": tools.timestamp_to_human(event.get("startTime", "")),
               "wall": event.get("wall"), "poster": event.get("poster"),
               "own_id": event.get("id", missing),
               "own_title": title if event.get("title") is not None else missing,
               "own_start": event.get("startTime", missing),
               "own_end": event.get("endTime", missing)}
        return res

    def _get_images_urls(self, data, segment):
        """A method to collect images urls from all the events of the given segment data."""
        urls = []
        if data and "entries" in data and data["entries"] and "events" in data["entries"][0]:
            for event in data["entries"][0]["events"]:
                res = self._extend_event(event, tools.timestamp_to_human(data["time"]),
                                         data["entries"][0]["channelId"], segment)
                self.send_event_to_elastic(res)
                for image in self.images:
                    if res[image]:
                        tmp = {k: v for k, v in res.items()}
                        tmp.update({"url": res[image] + "?w=0&h=0", "type": image})
                        urls.append(tmp)
                    else:
                        logging.warning("Event %s has no %s." % (res["own_id"], image))
                        sql = "INSERT INTO recs (channel, date, start, category, title, segment, \
                                                 own_id, own_title, own_start, own_end) \
                               VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');" % \
                              (res["channel"], res["date"], res["start"], image,
                               res["title"], res["segment"],
                               res["own_id"], res["own_title"], res["own_start"], res["own_end"])
                        tools.db_commit(self.db_conn, sql)
        else:
            logging.warning("No events for segment %s." % segment)
        return urls


def main(args):
    logging.info("Started.")
    db_file = "%s.db" % "-".join([args["country"], args["language"]])
    db_conn = tools.db_connect(db_file)
    tools.db_init(db_conn)
    current_dir = os.path.dirname(os.path.realpath(__file__))
    sys.path.append("%s/../../robot/resources/stages/" % (current_dir)) # Add robot/resources/stages/ to PATH to resolve import issues
    conf_file = import_file('../../robot/resources/stages/%s' % (args["conf"]))
    es_obj = ElasticSearch(conf_file.ELK_HOST, conf_file.ELK_PORT , conf_file.ELK_EPG_INDEX, conf_file.ELK_EPG_TYPE_NAME)
    if not es_obj.template_exists():
        es_obj.create_template()
    errs = []
    images_links_object = ImagesLinks(db_conn, es_obj, args["endpoint"], args["country"], args["language"],
                       args["start"], args["finish"])
    segments = images_links_object.segments
    if len(segments) < 1:
        errs.append("Segments was not fount")
    urls = images_links_object.collect_urls()

    tools.reset_event_loop()
    ImagesLinksExaminer(db_conn, es_obj, urls).verify()
    logging.info("Completed: all discovered %s URLs have been verified." % len(urls))
    report = Report()
    report.create_images_report(db_file, "%s-report-images-links.pdf" % db_file[:-3])
    report.create_events_report(db_file, "%s-report-events-items.pdf" % db_file[:-3])
    if not report.images_ok:
        errs.append("images validation failed")
    if not report.events_ok:
        errs.append("events validation failed")
    err = ", ".join(errs)
    if err:
        sys.stderr.write(err)
        sys.exit(1)


if __name__ == "__main__":
    EPG_ENDPOINT = "epg.labe2esi.nl.dmdsdp.com"
    COUNTRIES = ["BE", "NL", "CH", "GB", "DE", "IE", "PL", "AT", "CZ", "HU", "RO", "SK"]
    LANGUAGES = ["nl", "en", "de", "pl", "cz", "hu", "ro", "sk"]
    DAY_START = 7
    DAY_FINISH = 7
    GET_POSTER = True
    GET_LANDSCAPE = GET_PORTRAIT = False
    HLP = """Collect Images URLs from EPG micro-service and fetch all the URLs.
    Examples:
1. python verify_images_urls.py -e=epg.labe2esi.nl.dmdsdp.com -c=BE -l=nl -s=7 -f=8
2. python verify_images_urls.py
3. python verify_images_urls.py --endpoint=epg.labe2esi.nl.dmdsdp.com --country=BE --language=nl --start=7 --finish=8
4. python verify_images_urls.py -v
5. python verify_images_urls.py -v -e=epg.labe2esi.nl.dmdsdp.com -c=BE -l=nl -s=7 -f=8
    Commands 1-3 are equivalents, so are 4 and 5.
"""
    parser = argparse.ArgumentParser(description=HLP, formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument("-e", "--endpoint", default=EPG_ENDPOINT, type=str,
                        help="An EPG endpoint, default is '%s'." % EPG_ENDPOINT,
                        required=False)
    parser.add_argument("-c", "--country", default=COUNTRIES[0], type=str, choices=COUNTRIES,
                        help="A country code, default is '%s'." % COUNTRIES[0],
                        required=False)
    parser.add_argument("-l", "--language", default=LANGUAGES[0], type=str, choices=LANGUAGES,
                        help="A language code, default is '%s'." % LANGUAGES[0],
                        required=False)
    parser.add_argument("-s", "--start", default=DAY_START, type=int,
                        help="A day number from [0, 20], default is %s (today)." % DAY_START,
                        required=False)
    parser.add_argument("-f", "--finish", default=DAY_FINISH, type=int,
                        help="A day number from [0, 20], default is %s." % DAY_FINISH,
                        required=False)
    parser.add_argument("-v", "--verbose", default=False,
                        help="Verbose mode, default is False - debug messages are not displayed.",
                        action="store_true")
    parser.add_argument("--conf", default="conf_debug.py", type=str,
                        help="Common configuration file, default is conf_debug.py",
                        required=False)

    args = vars(parser.parse_args())
    tools.configure_logging(args)
    logging.info("Settings loaded: %s" % args)
    main(args)
