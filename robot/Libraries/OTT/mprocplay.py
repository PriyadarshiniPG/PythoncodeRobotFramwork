"""
This script serves 2 goals:
 1. Implementation of OTT library's keyword "play" for Robot Framework using multiprocessing:
    i.e. manifests will be checked in parallel - one process per manifest.
    The availability of LIVE and VoD content for OTT devices is checked.
    Actual playing of the content and its quality check is not performed.
 2. Command line tool to verify availability of chunks for manifests urls.
    For usage, follow description of play_manifests_from_file() function below. Examples to run:
    $ python asyncplay.py <file_name> <batch_size> <limit>
    $ python asyncplay.py manifests_urls.txt 20 100  # limit=0 will process all urls from the file
    Set batch_size value appropriate to avoid running out of resources.
    Note, on Intel(R) Core(TM) i5-6300U CPU @ 2.40 GHz 2.50 GHz, 16 GB RAM, Ethernet 1.0Gbps:
       - concurrent 1000 assets crashed the most resources on the machine - cut network, hung apps;
       - concurrent 100 assets took 53 minutes, system fully survived;
       - 100 assets with concurrent 20 assets in each batch took 51 minutes, system fully survived.
"""
import os
import sys
from pathos.helpers import mp
from .keywords import Content
sys.path.append(os.path.normpath(os.path.dirname(__file__)))


def _play_worker(url, protocol, tries, interval, verbosity, send_end):
    """A 'worker' function - it will 'play' one manifest.

    :param url: the URL to a DASH, HSS or HLS Manifest.
    :param protocol: a streaming protocol, a string (available values: "DASH", "HSS", "HLS").
    :param tries: number of attempts, 0 is for infinite, default is 1.
    :param interval: interval in seconds, default is 0.1.
    :param verbosity: a boolean to print info messages, default is True.
    :param send_end: the second end of the pipe returned by Pipe() function.

    :return: an error message (should be an empty string if no errors occurred).
    """
    obj = Content().get_manifest(url, protocol, verbosity)
    error = "" if obj.get_manifest_str() else "Failed to READ Manifest: %s. " % url
    obj.collect_chunks_urls().play(tries, interval)
    if not obj.played_ok:
        failed_chunks = [url for url in list(obj.chunks.keys()) if obj.chunks[url] != 200]
        error += "For Manifest %s chunks failed: %s/%s. " % (url,
                                                             len(failed_chunks),
                                                             len(list(obj.chunks.keys())))
    send_end.send(error)


def play_manifests_concurrently(urls, protocol=None, tries=1, interval=0.1, verbosity=0):
    """Play all manifests concurrently, using multiprocessing: one manifest per process.
    Be careful to run out of resources! You can use play_manifests_batches() instead.

    :param urls: a list of DASH, HSS or HLS manifests URLs.
    :param protocol: a streaming protocol, a string (available values: "DASH", "HSS", "HLS").
    .. note :: if specified, it will be applied to all manifests.
    :param tries: number of attempts, 0 is for infinite, default is 1.
    :param interval: interval in seconds, default is 0.1.
    :param verbosity: a boolean to print info messages, default is True.

    :return: a string of all error messages (should be an empty string if no errors occurred).
    """
    tries, interval, verbosity = int(tries), float(interval), int(verbosity)
    processes = []
    pipe_list = []
    i = 0
    while i < len(urls):
        recv_end, send_end = mp.Pipe(False)
        proc = mp.Process(target=_play_worker,
                          args=(urls[i], protocol, tries, interval, 0, send_end))
        processes.append(proc)
        pipe_list.append(recv_end)
        i += 1

    for proc in processes:
        proc.start()

    for proc in processes:
        proc.join()

    errors = [item.recv() for item in pipe_list]
    return "".join(errors)


def play_manifests_from_file(fname, batch_size=50, limit=0, protocol=None, tries=1, interval=0.1):
    """Play batches of manifests, using multiprocessing: one manifest per process within each batch.
    The list of urls is split into slices (batches), we iterate through batches sequentially,
    and 'play' manifests concurrently within each batch.
    Be careful to run out of resources! Set appropriate value for 'batch_count'.

    :param fname: a file name to grab manifests urls from.
    :param batch_size: a size of each batch of manifests urls.
    :param limit: the limit of urls to proceed, default is 0 to proceed all urls.
    :param protocol: a streaming protocol, a string (available values: "DASH", "HSS", "HLS").
    .. note :: if specified, it will be applied to all manifests.
    :param tries: number of attempts, 0 is for infinite, default is 1.
    :param interval: interval in seconds, default is 0.1.

    :return: nothing; if any chunks failed, details will be saved into _result_.txt file.
    """
    print(("Reading %s to get the list of manifests urls and start requesting chunks" % fname))
    if os.path.isfile(fname):
        with open(fname, "r") as _f:
            manifests_urls = [line.strip() for line in _f.readlines() if "http" in line]
        print(("Discovered %s urls" % len(manifests_urls)))
        play_manifests_batches(manifests_urls, batch_size, limit, protocol, tries, interval)
    else:
        print(("No manifests file %s found, nothing to do." % fname))


def play_manifests_batches(urls, batch_size=50, limit=0, protocol=None, tries=1, interval=0.1):
    """Play batches of manifests, using multiprocessing: one manifest per process within each batch.
    The list of urls is split into slices (batches), we iterate through batches sequentially,
    and 'play' manifests concurrently within each batch.
    Be careful to run out of resources! Set appropriate value for 'batch_count'.

    :param urls: a list of manifests urls.
    :param batch_size: a size of each batch of manifests urls.
    :param limit: the limit of urls to proceed, default is 0 to proceed all urls.
    :param protocol: a streaming protocol, a string (available values: "DASH", "HSS", "HLS").
    .. note :: if specified, it will be applied to all manifests.
    :param tries: number of attempts, 0 is for infinite, default is 1.
    :param interval: interval in seconds, default is 0.1.

    :return: error message string (can be long), or empty string if all chunks passed.
    """
    err_msg = ""
    batch_size, limit, tries, interval = int(batch_size), int(limit), int(tries), float(interval)
    if urls:
        count = len(urls) if limit == 0 else limit
        batch_count = count // batch_size + (count % batch_size > 0)
        i = 0
        while i < count:
            print(("Starting batch %s/%s" % (i // batch_size + 1, batch_count)))
            err_msg += play_manifests_concurrently(urls[i:i + batch_size],
                                                   protocol, tries, interval, 0)
            i += batch_size
        if not err_msg:
            print("Done. Passed.")
        else:
            with open("_result_.txt", "w") as _f:
                _f.write("%s\n" % err_msg)
            print("Done. Failed. See errors in _result_.txt")
    else:
        print("Nothing to do.")
    return err_msg


def debug_script():
    """Read script arguments, read manifests URLs from file & check all chunks for each manifest."""
    try:  # try to read script arguments
        file_name = sys.argv[1]
        batch_size = abs(int(sys.argv[2]))
        limit = abs(int(sys.argv[3]))
    except (ValueError, IndexError) as err:
        file_name, batch_size, limit = "manifests_urls.txt", 20, 100
        print(("Bad argument(s) detected: %s. Defaults will be loaded." % err))
    print(("Settings loaded: file=%s, batch_size=%s, limit=%s " % (file_name, batch_size, limit)))
    # Risk to run out of resources!
    # Set proper batch_count, see also some comments at the top of this file.
    play_manifests_from_file(file_name, batch_size, limit)


if __name__ == "__main__":
    debug_script()
