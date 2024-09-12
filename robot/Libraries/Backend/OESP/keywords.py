"""Implementation of OESP library's keywords for Robot Framework.
Script handles sending HTTP GET and POST requests to OESP (Orion Enterprise Service Platform).
"""

import os
import json
import urllib.parse
import requests
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError


class OESP(object):
    """A class to handle requests to OESP (Orion Enterprise Service Platform)."""

    def __init__(self, lab_name, e2e_conf, country=None, language=None, device=None):
        """The class initializer.

        :param lab_name: a lab name, a key of E2E_CONF dictionary in
        robot/resources/stages/conf_ENV.py.
        :param e2e_conf: the entire dictionary E2E_CONF stored in
        robot/resources/stages/conf_ENV.py.
        :param country: a country code, defaults to a value from E2E_CONF[lab_name].
        :param language: a language code, defaults to a value from E2E_CONF[lab_name].
        :param device: a device code, defaults to a value from E2E_CONF[lab_name].
        """
        self.lab_name = lab_name
        self.conf = e2e_conf[lab_name]
        self.country = country or e2e_conf[lab_name]["OESP"]["country"]
        self.language = language or e2e_conf[lab_name]["OESP"]["language"]
        self.device = device or e2e_conf[lab_name]["OESP"]["device"]
        self.oesp_base_url = "https://oesp.%s.orion.upclabs.com/oesp/v2/%s/%s/%s" % \
                             (self.lab_name, self.country, self.language, self.device)
        self.token = None
        self.location = None
        try:
            # Use folder name where this file is placed
            # (as Traxis, Fabrix, PurchaseMicroservice, etc) as a tag
            folder_name = os.path.basename(os.path.dirname(os.path.realpath(__file__)))
            BuiltIn().set_test_variable("${ENDPOINT_TAG}", "%s" % folder_name)
        except RobotNotRunningError:
            pass

    def _set_oesp_session(self, refresh_token=False):
        """A method handles authentication to OESP by sending HTTP POST request(s):
        - the first HTTP POST is mandatory and obtains a token and other data,
        - the second HTTP POST is optional and is sent only if refresh_token is True.
        The OESP token and the location identifier is set as "token" and "location" properties.
        """
        url = "%s/session?token=true" % self.oesp_base_url
        print(url)
        headers = {"Content-Type": "application/json"}
        json_auth = '{"username":"%s","password":"%s"}' % (self.conf["OESP"]["username"],
                                                           self.conf["OESP"]["password"])
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        response = requests.post(url, data=json_auth, headers=headers)
        #print(response.status_code, response.reason, response.text)
        data = json.loads(response.text.strip())
        if refresh_token:
            json_auth = '{"username":"%s","refreshToken":"%s"}' % (self.conf["OESP"]["username"],
                                                                   data["refreshToken"])
            response = requests.post(url, data=json_auth, headers=headers)
            data = json.loads(response.text.strip())
        self.location = data["locationId"]
        self.token = data["oespToken"]

    def get_channels_streaming_details(self):
        """A method authenticates to OESP and retrieves streaming details from the channels data.

        :return: a list of dictionaries, each represents a streaming url and some other details.
        """
        details = []
        self._set_oesp_session()
        url = "%s/channels?personalised=True&byLocationId=%s" % (self.oesp_base_url, self.location)
        print(url)
        headers = {"x-oesp-token": self.token, "x-oesp-username": self.conf["OESP"]["username"]}
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        response = requests.get(url, headers=headers)
        print((response.status_code, response.reason, response.text))
        data = json.loads(response.text.strip())
        for result_item in data["channels"]:
            for media_item in result_item["stationSchedules"]:
                for video_item in media_item["station"]["videoStreams"]:
                    for device in video_item["assetTypes"]:
                        details_dict = {
                            "streaming_url": "%s?device=%s" % (video_item["streamingUrl"].lower(),
                                                               device),
                            "protection_key": video_item["protectionKey"],
                            "protection_schemes": [scheme.lower() \
                                                   for scheme in video_item["protectionSchemes"]]
                        }
                        details.append(details_dict)
        return details

    def get_recs_streaming_details(self):
        """TODO: once details are available adjust parsing of OESP response
        A method authenticates to OESP and retrieves streaming details from the channels data.

        :return: a list of dictionaries, each represents a streaming url and some other details.
        """
        details = []
        self._set_oesp_session()
        url = "%s/networkrecordings" % self.oesp_base_url
        print(url)
        headers = {"x-oesp-token": self.token, "x-oesp-username": self.conf["OESP"]["username"]}

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        response = requests.get(url, headers=headers)
        print((response.status_code, response.reason, response.text))
        data = json.loads(response.text.strip())
        for result_item in data["recordings"]:
            for media_item in result_item["listing"]:
                for video_item in media_item["program"]["videoStreams"]:
                    for device in video_item["assetTypes"]:
                        details_dict = {
                            "streaming_url": "%s?device=%s" % (video_item["streamingUrl"].lower(),
                                                               device),
                            "protection_key": video_item["protectionKey"],
                            "protection_schemes": [scheme.lower() \
                                                   for scheme in video_item["protectionSchemes"]]
                        }
                        details.append(details_dict)
        #print(details)
        return details

    def get_vodsearch_streaming_details(self, search_entry):
        """A method authenticates to OESP and retrieves streaming details from the VOD search data.

        :return: a list of dictionaries, each represents a streaming url and some other details.
        """
        details = []
        self._set_oesp_session()
        url = "%s/search/vod?q=%s" % (self.oesp_base_url, search_entry)
        headers = {"x-oesp-token": self.token, "x-oesp-username": self.conf["OESP"]["username"]}

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        response = requests.get(url, headers=headers)
        print((response.status_code, response.reason, response.text))
        data = json.loads(response.text.strip())
        for result_item in data["results"]:
            for media_item in result_item["mediaItems"]:
                for video_item in media_item["videoStreams"]:
                    for device in video_item["assetTypes"]:
                        details_dict = {
                            "streaming_url": "%s?device=%s" % (video_item["streamingUrl"].lower(),
                                                               device),
                            "protection_key": video_item["protectionKey"],
                            "protection_schemes": video_item["protectionSchemes"]
                        }
                        details.append(details_dict)
        #print(details)
        return details


class Keywords(object):
    """Keywords visible in Robot Framework."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @staticmethod
    def get_channels_streaming_details(lab_name, e2e_conf,
                                       country=None, language=None, device=None):
        """A keyword to request channels entitlements from OESP and return data about video streams.

        :param lab_name: a lab name, a key of E2E_CONF dictionary in
        robot/resources/stages/conf_ENV.py.
        :param e2e_conf: the entire dictionary E2E_CONF stored in
        robot/resources/stages/conf_ENV.py.
        :param country: a country code, e.g. "NL" (default) for Netherlands.
        :param language: a language code, e.g. "nld" (default) for Dutch language.
        :param device: a device code, e.g. "windows", "android", "ios", and "web" (default).

        :return: a list of dictionaries describing video streams.
        .. note:: if ConnectionError exception occurs, return value is [{"error": <error_message>}].
        """
        oesp_obj = OESP(lab_name, e2e_conf, country, language, device)
        try:
            result = oesp_obj.get_channels_streaming_details()
        except (requests.ConnectionError, ValueError) as error:
            result = [{"error": "Can't get streaming urls in %s lab due to %s" % (lab_name, error)}]
        return result

    @staticmethod
    def get_recs_streaming_details(lab_name, e2e_conf, country=None, language=None, device=None):
        """A keyword to request channels entitlements from OESP and return data about video streams.

        :param lab_name: a lab name, a key of E2E_CONF dictionary in
        robot/resources/stages/conf_ENV.py.
        :param e2e_conf: the entire dictionary E2E_CONF stored in
        robot/resources/stages/conf_ENV.py.
        :param country: a country code, e.g. "NL" (default) for Netherlands.
        :param language: a language code, e.g. "nld" (default) for Dutch language.
        :param device: a device code, e.g. "windows", "android", "ios", and "web" (default).

        :return: a list of dictionaries describing video streams.
        .. note:: if ConnectionError exception occurs, return value is [{"error": <error_message>}].
        """
        oesp_obj = OESP(lab_name, e2e_conf, country, language, device)
        try:
            result = oesp_obj.get_recs_streaming_details()
        except (requests.ConnectionError, ValueError) as error:
            result = [{"error": "Can't get streaming urls in %s lab due to %s" % (lab_name, error)}]
        return result

    @staticmethod
    def get_vodsearch_streaming_details(lab_name, e2e_conf, search_entry,
                                        country=None, language=None, device=None):
        """A keyword to request channels entitlements from OESP and return data about video streams.

        :param lab_name: a lab name, a key of E2E_CONF dictionary in
        robot/resources/stages/conf_ENV.py.
        :param e2e_conf: the entire dictionary E2E_CONF stored in
        robot/resources/stages/conf_ENV.py.
        :param search_entry: a string to search for in VOD assets metadata.
        :param country: a country code, e.g. "NL" (default) for Netherlands.
        :param language: a language code, e.g. "nld" (default) for Dutch language.
        :param device: a device code, e.g. "windows", "android", "ios", and "web" (default).

        :return: a list of dictionaries describing video streams.
        .. note:: if ConnectionError exception occurs, return value is [{"error": <error_message>}].
        """
        oesp_obj = OESP(lab_name, e2e_conf, country, language, device)
        try:
            result = oesp_obj.get_vodsearch_streaming_details(search_entry)
        except (requests.ConnectionError, ValueError) as error:
            result = [{"error": "Can't get streaming urls in %s lab due to %s" % (lab_name, error)}]
        return result

    @staticmethod
    def collect_streaming_urls(streams, get_dash=True, get_hss=True, get_hls=True):
        """A keyword to request channels entitlements from OESP and return data about video streams.

        :param streams: a list of dictionaries describing video streams.
        :param get_dash: if True, URLs of DASH manifests will be included, otherwise skipped.
        :param get_hss: if True, URLs of HSS manifests will be included, otherwise skipped.
        :param get_hls: if True, URLs of HLS manifests will be included, otherwise skipped.

        :return: a list of dictionaries, containing descriptions of desired streams only.
        """
        urls = []
        mapping = {"DASH": {"collect": get_dash, "url_part": "dash/", "scheme": "widevine"},
                   "HSS": {"collect": get_hss, "url_part": "ss/", "scheme": "playready"},
                   "HLS": {"collect": get_hls, "url_part": "ls/", "scheme": "fairplay"},
                  }
        for stream in streams:
            for protocol in list(mapping.keys()):
                if mapping[protocol]["collect"]:
                    if mapping[protocol]["url_part"] in stream["streaming_url"] \
                    or mapping[protocol]["scheme"] in stream["protection_schemes"]:
                        urls.append(stream["streaming_url"])
        return urls
