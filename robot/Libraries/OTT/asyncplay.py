# pylint: disable=E0001
"""
This script requires Python 3 and serves 2 goals:
 1. Implementation of OTT library's keyword "play" for Robot Framework using asyncio and aiohttp:
    i.e. manifests will be checked in sequence, but their chunks will be requested in async mode.
    The availability of LIVE and VoD content for OTT devices is checked via HTTP HEAD requests.
    Actual playing of the content and its quality check is not performed.
    Note: this requires Python 3 and Robot Framework supports Python 3,
          however, there are external libraries (e.g. SSHLibrary) which works only in Python 2.
          So, if you need to run tests using Robot Framework on Python 3, take care of imports.
 2. Command line tool to verify availability of chunks for manifests urls.
    For usage, follow description of play_manifests_from_file() function below. Examples to run:
    $ python3 asyncplay.py <file_name> <tries> <interval> <limit> <verbosity>
    $ python3 asyncplay.py manifests_urls.txt 1 0.01 0 0  # limit=0 will process all urls from file.
        or, for a single manifest URL:
    $ python3 asyncplay.py "http://<...>/Manifest?start=0&end=-1&device=Orion-HSS" 1 0 0 0
    Note: async mode is fast, it can cause 503 and 504 errors, and if so, retries will be executed.
"""
import os
import sys
import logging
import time
import socket
import asyncio
from aiohttp import ClientSession, TCPConnector
from aiohttp.client_exceptions import ClientConnectorError, ServerDisconnectedError
sys.path.append(os.path.normpath(os.path.dirname(__file__)))
from keywords import Content


def v_print(msg, verbosity):
    """Print a message on screen depending on verbosity value."""
    if verbosity:
        logging.info(msg)
        #print(msg)


async def fetch(session, url, tries, interval, verbosity):
    """Function sends HTTP HEAD request for the given chunk URL and makes retries if needed."""
    try:
        async with session.head(url, headers={"Cache-Control": "no-cache"}) as response:
            i = 0
            while i < tries:
                await response.read()
                if response.status != 200:
                    if response.status in [503, 504]:  # if we caused a DoS attack - sleep & try again
                        v_print("URL: %s. Status code %s" % (url, response.status), verbosity)
                        tries += 1
                    else:
                        v_print("URL: %s. Status code %s" % (url, response.status), verbosity)
                    time.sleep(interval)
                    i += 1
                else:
                    break
            return {url: response.status}
    except (ClientConnectorError, ServerDisconnectedError, asyncio.TimeoutError) as err:
        msg = "" if not err else " due to " + str(err)
        logging.error("Could not fetch the URL %s%s", url, msg)
        return {url: None}


async def bound_fetch(sem, session, url, tries, interval, verbosity):
    """Function handles semaphores and sends the URL of a chunk to fetch() for final validation."""
    async with sem:
        return await fetch(session, url, tries, interval, verbosity)


async def run(urls, tries, interval, verbosity=0):
    """Function creates and schedules async tasks and collect their results."""
    tasks = []
    sem = asyncio.Semaphore(1000)
    tcp_conn = TCPConnector(family=socket.AF_INET, ssl=False, limit=1)
    async with ClientSession(connector=tcp_conn, trust_env=True) as session:
        for url in urls:
            task = asyncio.ensure_future(bound_fetch(sem, session, url, tries, interval, verbosity))
            tasks.append(task)
        responses = asyncio.gather(*tasks)
        await responses
    return responses.result()


def play_one_manifest_async(manifest_url, protocol=None, tries=1, interval=0.1, verbosity=0):
    """Function to validate chunks in async mode."""
    obj = Content().get_manifest(manifest_url, protocol)
    manifest_str = obj.get_manifest_str()
    if not manifest_str or "Can't parse Manifest" in str(manifest_str):
        return ["Failed to READ Manifest: %s. " % manifest_url]
    urls = list(obj.collect_chunks_urls().chunks.keys())

    loop = asyncio.get_event_loop()
    future = asyncio.ensure_future(run(urls, tries, interval, verbosity))
    loop.run_until_complete(future)

    results = future.result()
    obj.played_ok = bool(results)
    for result in results:
        obj.chunks.update(result)
        if list(result.values())[0] != 200:
            obj.played_ok = False
    failed_chunks = [url for url in list(obj.chunks.keys()) if obj.chunks[url] != 200]
    #For failed chunks, check if it fails only in One layer but not in multiple layers
    if obj.protocol == "HSS":
        text_to_find = "QualityLevels("
    elif obj.protocol == "HLS":
        text_to_find = "Level("
    if not obj.played_ok:
        for fail in failed_chunks:
            for bit in obj.bitrateholder:
                if fail.find(text_to_find + str(bit) + ")") != -1:
                    tmp = list(obj.bitrateholder)
                    tmp.remove(str(bit))
                    for i in tmp:
                        layerstr = fail.replace(
                            text_to_find + str(bit) + ")", text_to_find + str(i) + ")")
                        if not layerstr in failed_chunks:
                            obj.played_ok = True

    msg = "Chunks total: %s; passed: %s; failed %s for %s" % \
          (len(obj.chunks), len(obj.chunks) - len(failed_chunks), len(failed_chunks), manifest_url)
    logging.info(msg)
    return obj


def read_many_manifests_async(manifests_urls, protocol=None, tries=1, interval=0.1, verbosity=0):
    """Function to validate manifests in sequence, but chunks will be verified in async mode."""
    error_msg = ""
    for manifest_url in manifests_urls:
        res = play_one_manifest_async(manifest_url, protocol, tries, interval, verbosity)
        failed_chunks = [url for url in list(res.chunks.keys()) if res.chunks[url] != 200]
        error_msg += "For Manifest %s chunks failed: %s/%s. " % (manifest_url,
                                                                 len(failed_chunks),
                                                                 len(list(res.chunks.keys())))
    return error_msg


def play_manifests_from_file(fname, protocol=None, tries=1, interval=0.01, limit=0, verbosity=0):
    """Request chunks of manifests in async mode.
    Use non-zero intervals to avoid Denial of Service errors (if they occur, a retry will be made).

    :param fname: a file name to grab manifests urls from.
    :param protocol: a streaming protocol, a string (available values: "DASH", "HSS", "HLS").
    .. note :: if specified, it will be applied to all manifests.
    :param tries: number of attempts, default is 1 - i.e. no retries allowed.
    :param interval: interval in seconds, default is 0.01.
    :param limit: a number of manifests to verify, default is 0 to process all discovered manifests.
    :param verbosity: a non-negative integer; if zero, then chunks failuires are not printed.

    :return: nothing; TODO: if any chunks failed, details will be saved into _result_.txt file.
    """
    print(("Reading %s to get the list of manifests urls and start requesting chunks." % fname))
    if os.path.isfile(fname):
        with open(fname, "r") as _f:
            manifests_urls = [line.strip() for line in _f.readlines() if "http" in line]
        msg = "Discovered %s urls" % len(manifests_urls)
        logging.info(msg)
        limit = limit or len(manifests_urls)
        for manifest_url in manifests_urls[:limit]:
            result = play_one_manifest_async(manifest_url, protocol, tries, interval, verbosity)
            msg = analyze_result(result, manifest_url)
            logging.info(msg)
    else:
        msg = "No manifests file %s found, nothing to do." % fname
        print(msg)
    return msg


def analyze_result(result, url):
    """Function to analyze result and return message"""
    msg = ""
    if isinstance(result, list):
        msg = "%s\n" % result[0]  # grab error message - if exists, it is always only one
        result = type("", (), dict(played_ok=False))()  # we need only result.played_ok
    msg += "Manifest %s: %s" % ("OK" if result.played_ok else "FAIL", url)
    return msg


def debug_one_manifest():
    """Debug function - parse one manifest and check chunks availability."""
    endpoint = "wp5.pod1.vod.prod.ukv.dmdsdp.com"
    asset = "483975bd7e57637f61be8f855baff60d_76C703DB11596FD8661832D429A6A8E7"
    manifest_url = "http://%s/shss/%s/index.ism/Manifest?device=Orion-HSS" % (endpoint, asset)
    result = play_one_manifest_async(manifest_url, tries=1, interval=0.1, verbosity=1)
    return result


def debug_script():
    """Read script arguments, read manifests URLs from file & check all chunks for each manifest."""
    msg = ""
    try:
        tries = abs(int(sys.argv[2]))
        interval = abs(float(sys.argv[3]))
        limit = abs(int(sys.argv[4]))
        verbosity = abs(int(sys.argv[5]))
        if "http" in sys.argv[1]:
            result = play_one_manifest_async(sys.argv[1], None, tries, interval, verbosity)
            msg = analyze_result(result, sys.argv[1])
            logging.info(msg)
        else:
            play_manifests_from_file(sys.argv[1], None, tries, interval, limit, verbosity)
    except (ValueError, IndexError) as err:
        cmd = "$ python3 asyncplay.py <file|url> <tries> <interval> <limit> <verbosity>"
        print(("%s\nBad arguments. Usage: %s" % (err, cmd)))
    return msg


if __name__ == "__main__":
    # debug_one_manifest()
    LOG_FNAME = "urls.log" if "http" in sys.argv[1] else '%s.log' % "_".join(sys.argv[1:2])
    logging.root.handlers = []
    logging.basicConfig(level=logging.DEBUG if int(sys.argv[5]) else logging.INFO,
                        filename=LOG_FNAME, filemode='w',
                        format='%(asctime)-25s %(levelname)-10s %(message)s')
    LOG_FMT = logging.Formatter('%(asctime)-25s %(levelname)-10s %(message)s')
    LOG_SH = logging.StreamHandler()
    LOG_SH.setLevel(logging.INFO)
    LOG_SH.setFormatter(LOG_FMT)
    logging.getLogger("").addHandler(LOG_SH)

    debug_script()
