"""Implementation of OTT library's keywords for Robot Framework.
The availability of LIVE and VoD content for OTT devices is checked.
Actual playing of the content and its quality check is not performed.
"""
import os
from abc import ABCMeta, abstractmethod
from xml.parsers.expat import ExpatError
import re
import json
import time
try:
    import urllib.parse as urlparse
except ImportError:
    import urllib.parse as urlparse
import xmltodict
import requests
from lxml import etree
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError


def filter_chars(str_input):
    """Function removes "bad" symbols from a string.
    This can be used to filter HTTP response text before parsing it into XML.
    """
    return re.sub("[^\040-\176]", "", str_input).encode("ascii")


def utc_to_time(time_str):
    """Function parses a string of UTC time into Python time structure.

    :param time_str: a string representing time in the UTC format.

    :return: a time structure.

    :Example:

    >>> utc_to_time("2017-07-24T11:50:57Z")
    time.struct_time(tm_year=2017, tm_mon=7, tm_mday=24, tm_hour=11, tm_min=50,
    tm_sec=57, tm_wday=0, tm_yday=205, tm_isdst=-1)
    """
    return time.strptime(time_str, "%Y-%m-%dT%H:%M:%SZ")


def epoch(time_str):
    """Function converts a UTC time string to seconds elapsed since Epoch time.

    :param time_str: a string representing time in the UTC format.

    :return: number of seconds since the Epoch.

    :Example:

    >>> epoch("2017-07-24T11:50:57Z")
    1500889857
    """
    return int(time.mktime(utc_to_time(time_str)))


def seconds(duration):
    """A method to convert a duration string into number of seconds.

    :param duration: a string representing time duration.

    :return: number of seconds, integer or float.

    :Example:

    >>> seconds('PT13H58M100.6S')
    50380.6
    """
    if not duration:
        return 0
    pattern = re.compile(r"P((?:(\d*)Y)?(?:(\d*)M)?(?:(\d*)D)?)?" + \
        r"(T(?:(\d*)H)?(?:(\d*)M)?(?:(\d*(?:\.\d*)?)S))?")
    groups = pattern.match(duration).groups()
    g_hours = int(groups[5] or 0)
    g_minutes = int(groups[6] or 0)
    g_seconds = float(groups[7] or 0)
    g_minutes += 60 * g_hours
    g_seconds += 60 * g_minutes
    return g_seconds


class Content(object):
    """A factory class to generate an instance of the protocol class."""

    @staticmethod
    def get_manifest(url, protocol=None, verbosity=1):
        """
        Factory method to determine a protocol from the url
        and return an object of a protocol class derived from Manifest() class.

        :param url: an URL of a manifest.
        :param protocol: a streaming protocol, a string (available values: "DASH", "HSS", "HLS").
        :param verbosity: print debug messages in protocol class if value > 0.

        :return: an instance of a protocol class
        """
        protocol = str(protocol).upper()
        if protocol not in ["DASH", "HSS", "HLS"]:
            url_parts = url.split("/")
            protocol = url_parts[3].upper() # will coincide with a desired class name
            if protocol.endswith("DASH"):
                protocol = "DASH"
            elif protocol.endswith("SS"):
                protocol = "HSS"
            elif protocol.endswith("LS"):
                protocol = "HLS"
        return globals()[protocol](url, verbosity)


class Manifest(Content, metaclass=ABCMeta):
    """Abstract class to handle Manifest."""

    def __init__(self, url, verbosity=1):
        """The class initializer.

        :param url: the URL to a content's Manifest.
        :param verbosity: print debug messages if value > 0, default value is 1.
        """
        self.bitrateholder = []
        self.url = url
        self.verbosity = verbosity
        # url part common for video/audio/subtitles:
        self.link = url[:url.rfind("/")]
        self.session = requests.Session()
        self.manifest_str = self._read_manifest()
        protocol = "HSS" if "ss" in url.split("/")[3] else "DASH"
        try:
            self.manifest_dict = xmltodict.parse(self.manifest_str)
        except ExpatError as err:
            self.manifest_dict = None
            protocol = "HLS"
            if self.verbosity > 0:
                print(("Can't parse Manifest: %s. Not XML data? OK for HLS." % err))
        self.protocol = protocol
        asset = re.search(r"[0-9a-f\-]{36}", url)
        # for VoD, self.asset will be non-empty string otherwise empty string:
        self.asset = asset.group(0) if asset else ""
        # for LIVE, self.channel will be non-empty string otherwise empty string:
        self.channel = self.link[self.link.rfind("/")+1:] if not asset else ""
        pos = url.find("device=")
        # assumed device is the last arg, we need only start pos:
        self.device = url[pos+7:] if pos != -1 else ""
        self.chunks = {}  # {<url_1>: <code_1>, .., <url_N>: <code_N>}
        self.played_ok = None
        try:
            # Use folder name where this file is placed
            # (as Traxis, Fabrix, PurchaseMicroservice, etc) as a tag
            folder_name = os.path.basename(os.path.dirname(os.path.realpath(__file__)))
            BuiltIn().set_test_variable("${ENDPOINT_TAG}", "%s" % folder_name)
        except RobotNotRunningError:
            pass

    @abstractmethod
    def collect_chunks_urls(self):
        """A method to collect URLs of all the chunks described in the Manifest."""
        pass  # pylint: disable=W0107

    @abstractmethod
    def play(self, tries, interval):
        """A method to check the availability of content URLs."""
        pass  # pylint: disable=W0107

    def _retry_get_url(self, url, tries, interval):
        i = 0
        url_ok = False
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urlparse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        while i < tries:
            i += 1
            try:
                resp = self.session.get(url)
            except requests.exceptions.ConnectionError as err:
                print(("Could not retrieve %s due to %s" % (url, err)))
                return False
                # Alternatively, to ignore DNS failure and refused connection errors, uncomment:
                # print("Ignored %s. Request %s is retried" % (err, url))
                # time.sleep(interval)
                # continue
            if self.verbosity > 0:
                print(("%s - %s %s" % (url, resp.status_code, resp.reason)))
            elif resp.status_code == 200:
                url_ok = True
                break
            time.sleep(interval)
        self.chunks.update({url: resp.status_code})
        return url_ok

    def _read_manifest(self):
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urlparse.urlparse(self.url).path)
        except RobotNotRunningError:
            pass

        response = self.session.get(self.url)
        if response.status_code != 200:
            return ""
        manifest_str = response.text.strip()
        try:
            xml = etree.fromstring(filter_chars(manifest_str))
            return etree.tostring(xml, pretty_print=True)
        except etree.XMLSyntaxError:
            return manifest_str

    def get_manifest_str(self):
        """A method returns Manifest content in the form of a string."""
        return self.manifest_str

    def get_manifest_dict(self):
        """A method returns Manifest content in the form of a dictionary."""
        return self.manifest_dict

    def print_manifest_str(self):
        """A method prints Manifest text."""
        print((self.manifest_str))

    def print_manifest_dict(self):
        """A method prints Manifest data loaded in a dictionary."""
        print((json.dumps(self.manifest_dict, indent=4)))

    def show(self, print_self=True, print_str=True, print_dict=True):
        """A method prints Manifest data in different forms."""
        if print_self:
            template = "Manifest = [\n\turl='%s',\n\tlink='%s',\n\tprotocol='%s'," + \
                       "\n\tdevice='%s',\n\tasset='%s',\n\tchannel='%s'\n]"
            args = (self.url, self.link, self.protocol, self.device, self.asset, self.channel)
            print((template % args))
        if print_str:
            self.print_manifest_str()
        if print_dict:
            self.print_manifest_dict()
        return self


class DASH(Manifest):
    """Class handles DASH (Dynamic Adaptive Streaming over HTTP) manifests."""

    def _get_header_url(self, item, replacement):
        header = item["SegmentTemplate"]["@initialization"]
        pattern = r"\$[a-zA-Z]{3,}\$"
        entry = re.findall(pattern, header)[0]
        url = "%s/%s" % (self.link, header.replace(entry, replacement))
        return url

    def _get_media_url(self, item, replacement, number):
        media = item["SegmentTemplate"]["@media"]
        pattern = r"\$[a-zA-Z]{3,}\$"
        entries = re.findall(pattern, media)
        media_parts = media.split("/")
        media_parts[-1] = media_parts[-1].replace(entries[-1], number)
        media_parts[-2] = media_parts[-2].replace(entries[-2], replacement)
        url = "%s/%s" % (self.link, "/".join(media_parts))
        return url

    def _collect_live(self, item):
        number = str(int(
            (epoch(self.manifest_dict["MPD"]["UTCTiming"]["@value"]) - \
             epoch(self.manifest_dict["MPD"]["@availabilityStartTime"]) - \
             seconds(self.manifest_dict["MPD"]["Period"]["@start"])
            ) \
             * int(item["SegmentTemplate"]["@timescale"]) \
             / int(item["SegmentTemplate"]["@duration"]) \
             + int(item["SegmentTemplate"]["@startNumber"])
        ))
        tmp = item["Representation"]
        repr_items = tmp if isinstance(tmp, list) else [tmp]
        for r_item in repr_items:
            header = self._get_header_url(item, r_item["@id"])
            media = self._get_media_url(item, r_item["@id"], number)
            for url in [header, media]:
                self.chunks.update({url: None})

    @staticmethod
    def __prepare_time_items(s_items):
        val_t = int(s_items[0]["@t"]) if "@t" in s_items[0] else 0
        time_items = [val_t]
        for s_item in s_items:
            # If there's no R, consider it as 1:
            val_r = int(s_item["@r"]) + 1 if "@r" in s_item else 1
            # The val of R is a repetition of D values -
            # it is a sum with the previous one in the list:
            val_d = int(s_item["@d"])
            i = 0
            while i < val_r:
                _tm = time_items[-1] + val_d
                time_items.append(_tm)
                i += 1
        return time_items

    def _collect_vod(self, item):
        tmp = item["Representation"]
        repr_items = tmp if isinstance(tmp, list) else [tmp]
        for r_item in repr_items:
            header = self._get_header_url(item, r_item["@bandwidth"])
            urls = [header]
            tmp = item["SegmentTemplate"]["SegmentTimeline"]["S"]
            s_items = tmp if isinstance(tmp, list) else [tmp]
            time_items = self.__prepare_time_items(s_items)
            # Drop the last chunks to handle the VSPP issues with different layers in manifest file:
            for val in time_items[:-3]:
                # TestChunk.py skips val=0, we don't; feel free to add "if val > 0:"
                media = self._get_media_url(item, r_item["@bandwidth"], str(val))
                urls.append(media)
            for url in urls:
                self.chunks.update({url: None})

    def collect_chunks_urls(self):
        """Parse manifest and collect all the chunks urls into self.chunks dictionary."""
        for item in self.manifest_dict["MPD"]["Period"]["AdaptationSet"]:
            if "UTCTiming" in self.manifest_dict["MPD"]:
                self._collect_live(item)
            else:
                self._collect_vod(item)
        return self

    def play(self, tries=1, interval=0.1):
        """Method builds content URLs from DASH manifest and GETs each URL."""
        if self.manifest_dict:
            self.played_ok = bool(self.chunks)
            for chunk_url in self.chunks:
                link_ok = self._retry_get_url(chunk_url, tries, interval)
                self.played_ok = self.played_ok and link_ok
        else:
            self.played_ok = False
        return self


class HSS(Manifest):
    """Class handles HSS (HTTP Smooth Streaming) manifests."""

    @staticmethod
    def sum_of_prev_elems_in_array(arr):
        """Creates an array where each element is the sum of its previous ones.

        :param arr: an array, like [1,2,3]

        :return: [1,3,6] for an array like [1,2,3]
        """
        result = []
        for num in range(1, len(arr) + 1):
            prev_elems_arr = [arr[prev_a] for prev_a in range(0, num)]
            result += [sum(prev_elems_arr)]
        return result

    def _get_stream_start_times(self, stream):
        """Given a stream dictionary based on StreamIndex XML node,
        process its "c" entries to get the chunks start times.

        :param stream: dictionary based on StreamIndex XML node

        :return: an array containing the start times to be used with each bitrate
        """
        clips = [clip for clip in stream['c'] if clip]
        durations = [int(clips[0]['@t'])] if '@t' in clips[0] else [0]
        durations += [int(clip['@d']) for clip in clips]
        start_times = self.sum_of_prev_elems_in_array(durations)
        return start_times

    def collect_chunks_urls(self):
        """Parse manifest and collect all the chunks urls into self.chunks dictionary."""
        holder = self.manifest_dict["SmoothStreamingMedia"]["StreamIndex"][0]["QualityLevel"]
        for rate in holder:
            if not rate["@Bitrate"] in self.bitrateholder:
                self.bitrateholder.append(rate["@Bitrate"])
        for stream in self.manifest_dict["SmoothStreamingMedia"]["StreamIndex"]:
            url = "%s/%s" % (self.link, stream["@Url"])
            tmp = stream["QualityLevel"]
            quality_levels = tmp if isinstance(tmp, list) else [tmp]
            bitrates = [q["@Bitrate"] for q in quality_levels]
            start_times = self._get_stream_start_times(stream)
            for bitrate in bitrates:
                link = url.replace("{bitrate}", str(bitrate))
                # Ignoring the last chunk due to known last-404-error:
                for start_time in start_times[:-1]:
                    # TestChunk.py skips start_time=0, we don't; feel free to add "if"
                    chunk_url = link.replace("{start time}", str(start_time))
                    self.chunks.update({chunk_url: None})

        return self

    def play(self, tries=1, interval=0.1):
        """Method sends HTTP GET request(s) for each chunk obtained from HSS Manifest."""
        if self.manifest_dict:
            self.played_ok = bool(self.chunks)
            for chunk_url in self.chunks:
                link_ok = self._retry_get_url(chunk_url, tries, interval)
                self.played_ok = self.played_ok and link_ok
        else:
            self.played_ok = False
        return self


class HLS(Manifest):
    """Class handles HLS (HTTP Live Streaming) manifests."""

    def _get_playlists_links(self):
        """Method builds links to all playlists mentioned in the Manifest."""
        playlists_links = []
        lines = self.manifest_str.split("\n")
        for line in lines:
            if not line.startswith("#") and ".m3u8" in line:
                link = "%s/%s" % (self.link, line.strip())
                playlists_links.append(link)
        return playlists_links

    def get_playlist_chunks_links(self, playlist_link):
        """Method builds links to chunks for each playlist."""
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urlparse.urlparse(playlist_link).path)
        except RobotNotRunningError:
            pass

        chunks_links = []
        lines = self.session.get(playlist_link).text.strip().split("\n")
        for line in lines:
            line = line.strip()
            if line.endswith(".ts") or line.endswith(".aac"):
                if playlist_link.endswith(".m3u8"):
                    tmp = playlist_link[:playlist_link.rfind("/")]
                else:
                    tmp = playlist_link
                url = "%s/%s" % (tmp, line[line.find("/")+1:].strip())
                if url.endswith(".ts"):
                    level_value = url.split('Level')[1].split(')/')[0].strip('(')
                    if not level_value in self.bitrateholder:
                        self.bitrateholder.append(level_value)
                chunks_links.append(url)
        return chunks_links

    def collect_chunks_urls(self):
        """Parse manifest and collect all the chunks urls into self.chunks dictionary."""
        playlists = self._get_playlists_links()
        for playlist in playlists:
            chunks = self.get_playlist_chunks_links(playlist)
            for chunk in chunks:
                self.chunks.update({chunk: None})
        return self

    def play(self, tries=1, interval=0.1):
        """Method sends HTTP GET request(s) for each chunk obtained from HLS Manifest."""
        self.played_ok = bool(self.chunks)
        for chunk in self.chunks:
            chunk_ok = self._retry_get_url(chunk, tries, interval)
            self.played_ok = self.played_ok and chunk_ok
        return self


class Keywords(object):
    """Keywords visible in Robot Framework."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @staticmethod
    def play(url, protocol=None, tries=1, interval=0.1, verbosity=0):
        """A keyword checks the availability of each URL obtained from Manifest.

        :param url: the URL to a DASH, HSS or HLS Manifest.
        :param protocol: a streaming protocol, a string (available values: "DASH", "HSS", "HLS").
        :param tries: number of attempts, 0 is for infinite, default is 1.
        :param interval: interval in seconds, default is 0.1.
        :param verbosity: a boolean to print info messages, default is True.

        :return: True if all URLs have been successfully GETted, False otherwise.
        """
        tries, interval, verbosity = int(tries), float(interval), int(verbosity)
        result = Content().get_manifest(url, protocol, verbosity)
        result.collect_chunks_urls().play(tries, interval)
        return result
