"""Implementation of Fabrix library's keywords for Robot Framework."""
# pylint: disable=R1705
import os
from abc import ABCMeta, abstractmethod
import re
import json
import urllib.parse
import requests
import xmltodict
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError


def to_seconds(duration):
    """A function to convert a duration string into number of seconds.

    :param duration: a string representing time duration.
    :return: number of seconds, integer or float.

    :Example:

    >>> to_seconds("PT13H58M100.6S")
    50380.6
    """
    if duration == "":
        return 0
    pattern = re.compile(r"P((?:(\d*)Y)?(?:(\d*)M)?(?:(\d*)D)?)?" + \
                         r"(T(?:(\d*)H)?(?:(\d*)M)?(?:(\d*(?:\.\d*)?)S))?")
    matches = pattern.match(duration)
    groups = matches.groups()
    hours = int(groups[5] or 0)
    minutes = int(groups[6] or 0)
    seconds = float(groups[7] or 0)
    minutes += 60 * hours
    seconds += 60 * minutes
    return seconds


class Content(object, metaclass=ABCMeta):
    """An abstract class to handle VoD assets and recordings."""

    def __init__(self, host, port, min_duration=0, max_duration=3600, limit=1000):
        """The class initializer.

        :param host: the IP address of Fabrix host.
        :param port: the port number of Fabrix host.
        :param min_duration: minimal required duration in seconds, default is 0.
        :param limit: maximal number of returned items, default is 1000.
        """
        self.host = host
        self.port = port
        self.limit = int(limit)
        self.min_duration = int(min_duration)  # seconds
        self.max_duration = int(max_duration)  # seconds
        self.data = None  # XML to Dict of the Fabrix response

    @abstractmethod
    def read_from_fabrix(self):
        """A method to retrieve content items from Fabrix."""
        pass  # pylint: disable=W0107

    def show(self):
        """Print nicely the data loaded from the returned Fabrix response."""
        try:
            print((json.dumps(self.data, indent=4)))
        except ValueError:
            print((self.data))


class Assets(Content):
    """A class to obtain VoD assets from Fabrix."""

    def __init__(self, host, port, min_duration=300, max_duration=600, limit=10):
        """The class initializer.

        :param host: the IP address of Fabrix host.
        :param port: the port number of Fabrix host.
        :param min_duration: minimal required duration in seconds, default is 300.
        :param limit: maximal number of returned items, default is 10.
        """
        super(Assets, self).__init__(host, port, min_duration, max_duration, limit)
        self.url = ("http://%s:%s/v2/search_vod_assets?duration_min=%s&duration_max=%s&limit=%s&" +
                    "state=2") % \
                   (self.host, self.port, self.min_duration, self.max_duration, self.limit)
        self.assets = []
        try:
            # Use folder name where this file is placed
            # (as Traxis, Fabrix, PurchaseMicroservice, etc) as a tag
            folder_name = os.path.basename(os.path.dirname(os.path.realpath(__file__)))
            BuiltIn().set_test_variable("${ENDPOINT_TAG}", "%s" % folder_name)
        except RobotNotRunningError:
            pass

    def read_from_fabrix(self):
        """Implementation of the abstract method.

        The method sends a GET request to Fabrix,
        parses the returned response text (in the form of XML),
        filters VoD assets to meet the searching requirements,
        collects the assets' ids.
        """
        print(("\nReading assets: %s" % self.url))

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(self.url).path)
        except RobotNotRunningError:
            pass

        response_text = requests.get(self.url).text
        self.data = xmltodict.parse(response_text)["search_vod_assets_reply"]
        i = 0
        tmp = self.data["assets"]["asset"]
        items = tmp if isinstance(tmp, list) else [tmp]
        for item in items:
            duration = float(to_seconds(item["duration"]))
            if self.min_duration <= duration <= self.max_duration:
                self.assets.append(item["id"])
                i += 1
        self.limit = len(self.assets)
        print((self.assets))
        return self

    def read_asset_properties(self, asset):
        """A method retrieves VoD asset details from Fabrix via HTTP GET request.

        :param asset: a VoD asset ID value.

        :return: a dictionary built from the Fabrix response XML-text.

        :Example URL:

        http://172.30.107.84:5929/v2/view_asset_properties?id=\
        80f3e0ddc1134c240e24f11bc762eda1_ec80816b362f47f54c637f2ad253deb4
        """
        url = "http://%s:%s/v2/view_asset_properties?id=%s" % (self.host, self.port, asset)

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        response_text = requests.get(url).text
        return xmltodict.parse(response_text)["view_asset_properties"]

    def get_asset_by_external_id(self, external_id):
        """A method to VoD asset search on Fabrix by external_id.

        :param external_id:
            id like 2aea972bd30a0d03499087ffca2d19ae_93048748BB8E07264A80238E4BD47AAC, string

        :return: asset details XML or wrong responce.
        """
        url = "http://%s:%s/v2/search_vod_assets?id=%s" % (self.host, self.port, external_id)
        response = requests.get(url)
        if response.status_code == 200:
            return response.text
        return response


class Recordings(Content):
    """A class to obtain Recordings from Fabrix."""

    def __init__(self, host, port, min_duration=300, max_duration=600, limit=10,
                 channel="", get_abr=True, get_cbr=True):
        """The class initializer.

        :param host: the IP address of Fabrix host.
        :param port: the port number of Fabrix host.
        :param min_duration: minimal required duration in seconds, default is 300.
        :param limit: maximal number of returned items, default is 10.
        :param channel: channel name, default "" is for all channels.
        :param get_abr: get ABR (Avetrage BitRate) items, default is True.
        :param get_cbr: get CBR (Constant BitRate) items, default is True.
        """
        super(Recordings, self).__init__(host, port, min_duration, max_duration, limit)
        self.channel = channel
        self.get_abr = "1" if get_abr else "0"
        self.get_cbr = "1" if get_cbr else "0"
        self.url = ("http://%s:%s/v2/recordings/search/?state=3&limit=%s&channel=%s" +
                    "&getabr=%s&getcbr=%s") % \
                   (self.host, self.port, self.limit, self.channel, self.get_abr, self.get_cbr)
        self.recordings = []
        try:
            # Use folder name where this file is placed
            # (as Traxis, Fabrix, PurchaseMicroservice, etc) as a tag
            folder_name = os.path.basename(os.path.dirname(os.path.realpath(__file__)))
            BuiltIn().set_test_variable("${ENDPOINT_TAG}", "%s" % folder_name)
        except RobotNotRunningError:
            pass

    def read_from_fabrix(self):
        """Implementation of the abstract method.

        The method sends a GET request to Fabrix,
        parses the returned response text (in the form of XML),
        filters recordings to meet the searching requirements,
        collects the recordings' ids.
        """
        print(("\nReading recordings: %s" % self.url))

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(self.url).path)
        except RobotNotRunningError:
            pass

        response_text = requests.get(self.url).text
        self.data = xmltodict.parse(response_text)["SearchRecordingsReply"]
        i = 0
        tmp = self.data["Recording"]
        items = tmp if isinstance(tmp, list) else [tmp]
        for item in items:
            try:
                duration_str = item["CBRDetails"]["@Duration"]
            except KeyError:
                duration_str = item["ABRDetails"]["@Duration"]
            duration = to_seconds(duration_str)
            if float(duration) >= self.min_duration:
                if self.channel == "" or self.channel == item["@Channel"]:
                    i += 1
                    self.recordings.append(item["@ShowingID"].strip())
        self.limit = len(self.recordings)
        return self


class Keywords(object):
    """Keywords visible in Robot Framework."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @staticmethod
    def get_assets_detailed(host, port, min_duration=300, max_duration=600, limit=10):
        """A keyword to obtain VoD assets from Fabrix.

        :param host: the IP address of Fabrix host.
        :param port: the port number of Fabrix host.
        :param min_duration: minimal required duration in seconds, default is 300.
        :param max_duration: maximal required duration in seconds, default is 600.
        :param limit: maximal number of returned items, default is 10.

        :return: an entire instance of the class Assets().
        """
        return Assets(host, port, min_duration, max_duration, limit).read_from_fabrix()

    @staticmethod
    def get_recordings_detailed(host, port, min_duration=300, max_duration=600, limit=10,
                                channel="", get_abr=True, get_cbr=True):
        """A keyword to obtain recordings from Fabrix.

        :param host: the IP address of Fabrix host.
        :param port: the port number of Fabrix host.
        :param min_duration: minimal required duration in seconds, default is 300.
        :param max_duration: maximal required duration in seconds, default is 600.
        :param limit: maximal number of returned items, default is 10.
        :param channel: channel name, default "" is for all channels.
        :param get_abr: get ABR (Avetrage BitRate) items, default is True.
        :param get_cbr: get CBR (Constant BitRate) items, default is True.

        :return: an entire instance of the class Recordings().
        """
        obj = Recordings(host, port, min_duration, max_duration, limit, channel, get_abr, get_cbr)
        return obj.read_from_fabrix()

    @staticmethod
    def get_assets(host, port, min_duration=300, max_duration=600, limit=10):
        """A keyword to obtain VoD assets from Fabrix.

        :param host: the IP address of Fabrix host.
        :param port: the port number of Fabrix host.
        :param min_duration: minimal required duration in seconds, default is 300.
        :param max_duration: maximal required duration in seconds, default is 600.
        :param limit: maximal number of returned items, default is 10.

        :return: a list of assets' ids.
        """
        obj = Keywords().get_assets_detailed(host, port, min_duration, max_duration, limit)
        return obj.assets

    @staticmethod
    def get_asset_by_external_id(host, port, external_id):
        """A keyword to VoD asset search on Fabrix by external_id.

        :param host: the IP address of Fabrix host.
        :param port: the port number of Fabrix host.
        :param external_id:
            id like 2aea972bd30a0d03499087ffca2d19ae_93048748BB8E07264A80238E4BD47AAC, string

        :return: asset details XML or wrong responce.
        """
        return Assets(host, port).get_asset_by_external_id(external_id)

    @staticmethod
    def get_recordings(host, port, min_duration=300, max_duration=300, limit=10,
                       channel="", get_abr=True, get_cbr=True):
        """A keyword to obtain recordings from Fabrix.

        :param host: the IP address of Fabrix host.
        :param port: the port number of Fabrix host.
        :param min_duration: minimal required duration in seconds, default is 300.
        :param max_duration: maximal required duration in seconds, default is 600.
        :param limit: maximal number of returned items, default is 10.
        :param channel: channel name, default "" is for all channels.
        :param get_abr: get ABR (Average BitRate) items, default is True.
        :param get_cbr: get CBR (Constant BitRate) items, default is True.

        :return: a list of recordings' ids
        """
        obj = Keywords().get_recordings_detailed(host, port, min_duration, max_duration, limit,
                                                 channel, get_abr, get_cbr)
        return obj.recordings
