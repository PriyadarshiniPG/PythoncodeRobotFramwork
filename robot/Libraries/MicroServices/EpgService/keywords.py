"""Implementation of EPG Microservices for HZN 4"""
import os
import socket
import urllib.parse
import requests
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError

def failed_response_data(req_method, req_url, req_body, error):
    """A function returns an instance similar to the http response.
    "Similar" means it has some attributes of the http response instance used in Robot test cases.
    This function should be used to guarantee even if we could not connect to the server,
    we still have the attributes of the http response to verify (they just will have None values),
    so the results will go to ElasticSearch properly.

    :param req_method: an HTTP method, e.g. "POST".
    :param req_url: a url used to send the request.
    :param req_body: a string of data sent (if any).
    :param error: an error message caught by try-except block.

    :return: an instance of an anonymous class.
    """
    data = dict(text=None, status_code=None, reason=None, json=lambda arg: None, error=error,
                request=type("", (), dict(method=req_method, url=req_url, body=req_body))())
    return type("", (), data)()


class EpgServiceRequests(object):
    """Class handling all functions relating
    to making health check requests
    """

    def __init__(self, conf, country, language):
        """"Class initialiser
        :param conf: config file for labs
        :param country: the country provided by Jenkins
        :param language: the language provided by Jenkins
        """
        host = conf["MICROSERVICES"]["OBOQBR"]
        self.base_path = "http://%s/epg-service" % host
        self.path = "%s/%s/%s/events/segments" % (self.base_path, country, language)
        try:
            # Use folder name where this file is placed
            # (as Traxis, Fabrix, PurchaseMicroservice, etc) as a tag
            folder_name = os.path.basename(os.path.dirname(os.path.realpath(__file__)))
            BuiltIn().set_test_variable("${ENDPOINT_TAG}", "%s" % folder_name)
        except RobotNotRunningError:
            pass

    def health_check_info(self):
        """A method to call the /info section of the service.

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        url = self.base_path + "/info"

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url)
            if response.status_code != 200:
                BuiltIn().log_to_console("To get EPG health check info we send GET to %s . "
                                         "Status code %s . Reason %s" %
                                         (url, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

    def get_epg_index(self):
        """Function to call the EPG service for the epg index"""

        url = self.path + "/index"

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url)
            if response.status_code != 200:
                BuiltIn().log_to_console("To get EPG index we send GET to %s . "
                                         "Status code %s . Reason %s" %
                                         (url, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

    def get_epg_segment(self, segment_hash):
        """Function to call the EPG service for a specific segment hash"""

        url = self.path + "/" + segment_hash

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url)
            if response.status_code != 200:
                BuiltIn().log_to_console("To get EPG segment we send GET to %s . "
                                         "Status code %s . Reason %s" %
                                         (url, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

    def _get_segments_for_channel(self, channel_id):
        """
        This method is responsible for getting segments for the channel id from
        EPG Service
        :param channel_id: channel id as a string, i.e. 0130
        """
        segments_index = self.get_epg_index()
        segments_index = segments_index.json()
        found_segments = None
        for entry in segments_index['entries']:
            if channel_id in entry['channelIds']:
                found_segments = entry['segments']
                break
        if not found_segments:
            raise ValueError(
                'No segments found for given channel id {}'.format(channel_id))
        return found_segments

    def _get_events_details(self, channel_id):
        """
        This method is responsible for getting one channel id events details from
        EPG Service
        :param channel_id: channel id as a string, i.e. 0130
        """
        hash_list = self._get_segments_for_channel(channel_id)
        events_details = []
        for segment_hash in hash_list:
            event_details = self.get_epg_segment(segment_hash)
            event_details = event_details.json()
            events_details.append(event_details)
        return events_details

    def get_event_details_from_epg_service(
            self, event_id, event_start_time, channel_id):
        """
        This method is responsible for getting event details from
        EPG Service
        :param event_id: event id, i.e.
        crid:~~2F~~2Fbds.tv~~2F233779046,imi:001000000059DCF0
        :param event_start_time: event start time as epoch
        :param channel_id: channel id as a string, i.e. 0130
        :param country_code: country code, i.e. be, nl
        :param language_code: language code, i.e. en, nl
        """

        epoch_time = event_start_time
        events_details = self._get_events_details(channel_id)
        found_event = None
        for entry in events_details:
            for event in entry['entries'][0]['events']:
                if event['id'] == event_id and \
                        event['startTime'] == epoch_time:
                    found_event = event
                    break
            if found_event:
                break
        if not found_event:
            raise ValueError(
                'No event data found for given event in EPG service. '
                'Event id {}'.format(event_id))
        return found_event

def create_hash_list(index_response):
    """A function to create a single list of all segment hashes
    for 7 days in past and 14 days ahead"""

    hash_list = []
    json_response = index_response.json()
    for key in json_response["entries"]:
        for element in key["segments"]:
            hash_list.append(element)
    return hash_list


class Keywords(object):
    """"Keywords visible in Robot Framework"""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @staticmethod
    def health_check_info(conf, country, language):
        """A keyword check the health status of all microservices servers.
        :param conf: a dictionary containing lab configuration settings.
        :param country: country code.
        :param: language: language in which data needs to be returned.

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        return EpgServiceRequests(conf, country, language).health_check_info()

    @staticmethod
    def get_epg_index(conf, country, language):
        """A keyword to return the complete EPG index for all services.
        :param conf: config file for labs
        :param country: the country provided by Jenkins
        :param language: the language provided by Jenkins
        """
        return EpgServiceRequests(conf, country, language).get_epg_index()

    @staticmethod
    def get_epg_segment(conf, country, language, segmenthash):
        """A keyword to return the data from a single EPG segment.
        :param conf: config file for labs
        :param country: the country provided by Jenkins
        :param language: the language provided by Jenkins
        :param segmenthash: single segment hash from EPG index
        """
        return EpgServiceRequests(conf, country, language).get_epg_segment(segmenthash)

    @staticmethod
    def create_hash_list(index_response):
        """A Keyword to create a list of EPG segment hashes for 7 days in past and 14 days ahead.
        To be used with the response of get_epg_index
        :param index_response: the response of get_epg_index
        """
        return create_hash_list(index_response)

    @staticmethod
    def get_event_details_from_epg_service(conf, country,
                                           language, event_id, event_start_time, channel_id):
        """A keyword to return the data from a single EPG event.
        :param conf: config file for labs
        :param country: the country provided by Jenkins
        :param language: the language provided by Jenkins
        :param event_id: single event id
        :param event_start_time: single event start time
        :param channel_id: channel id of the channel
        """
        return EpgServiceRequests(conf, country, language).\
            get_event_details_from_epg_service(event_id, event_start_time, channel_id)
