# pylint: disable=invalid-name
#!/usr/bin/env python27
# -*- coding: utf-8 -*-
"""
Description         Class definition for RMS
Reference: https://wikiprojects.upc.biz/display/SPARK/
E2E+SA+LDVR+Recording+Management+Service+API
"""

import sys
import json
import urllib.parse
import requests
from requests import HTTPError
# from Utils.zephyr_reporter.Keywords.zephyr_api import retry_decorator
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError

# Following pylint warnings were disabled for these classes
# R0904 - Too many public methods - we want as many test cases as possible
# W0212 - Access to protected member - we want to test private methods
# C0111 - Missing docstring - we don't want to document each test case
# C0103 - Invalid name - we want as descriptive test names as possible
# pylint: disable=C0111,W0212,R0904,C0103,C0326,W0613,R0903,E0202


class RecordingManagementService(object):    #It was RMS
    """
    Reference: https://wikiprojects.upc.biz/display/SPARK/
                E2E+SA+LDVR+Recording+Management+Service+API
    """
    def __init__(self):
        """
        Initialise.
        """
        lab_name = BuiltIn().get_variable_value("${LAB_NAME}")
        if lab_name:
            self._micro_service_url = BuiltIn().get_variable_value(
                "${E2E_CONF['"+lab_name+"']['MICROSERVICES']['OBOQBR']}")
            if self._micro_service_url is None:
                BuiltIn().log_to_console(
                    "ERROR: : E2E_CONF[%s]['MICROSERVICES']['OBOQBR'] dont exist \n" % lab_name)
                sys.exit()
        else:
            BuiltIn().log_to_console("WARN: LAB_NAME is empty - LAB_NAME:%s" % lab_name)
            self._micro_service_url = "ERROR: No LAB_NAME Specify"
        self._rms_ip = "http://"+self._micro_service_url+"/recording-management-service/"

    @staticmethod
    def _get_http_request(url):
        """
        http get request
        :param url: The request url
        :return response: The response from the request
        """
        response = requests.get(url, timeout=10)
        if response.status_code != 200:
            raise HTTPError('Status:', response.status_code,
                            'Problem with the request')
        return response

    @staticmethod
    def _delete_http_request(url, data=None, headers=None):
        """
        http delete request
        :param url: The request url
        :return response: The response from the request
        """
        response = requests.delete(url, data=data, headers=headers, timeout=10)
        if response.status_code != 204:
            raise HTTPError('Status:', response.status_code,
                            'Problem with the request')
        return response

    @staticmethod
    def _post_http_request(url, data, headers):
        """
        Send post request for given url to CPE
        """
        response = requests.post(url, data=data, headers=headers, timeout=10)
        if response.status_code != 201:
            raise HTTPError('Status:', response.status_code,
                            'Problem with the request')
        return response

    # @retry_decorator
    def get_rms_recordings_via_cs(self, customer_id):
        """
        Query RMS for a list of recordings
        :param customer_id: The customer id string
        :return response: The response from the request
        """
        req_url = self._rms_ip + 'customers/' + customer_id + '/recordings/'

        response = self._get_http_request(req_url).json()
        return response

    def get_recordings_with_filters_via_rms(self, customer_id, lang, cpe_id=None, show_id=None, season_id=None,
                                            channel_id=None, recording_state=None, most_relevant_episode_for=None):
        """This method sends GET request to get details of recording with given parameters
                :param
                    customer_id              : the customer id, e.g. 200284095_gb
                    cpe_id                   : the cpe id, e.g. 3C36E4-EOSSTB-003854325804
                    show_id                  : the show id(accept show ids separated by comma),
                    season_id                : the season id(accept season ids separated by comma),
                    channel_id               : the channel id of the recording,
                    recording_state          : the states of recording(takes values as recorded, partially recorded, etc)
                    mostRelevantEpisodeFor   : most relevant episode of either recordings or bookings
                    lang                     : current language of the CPE
                :return: an HTTP response instance
                """
        req_url = "%scustomers/%s/recordings?language=%s&cpeId=%s&mostRelevantEpisodeFor=%s" \
                  "&isAdult=false&recordingStates=%s&showIds=%s&seasonIds=%s" \
                  "&channelIds=%s&collapsing=false&sort=episode&limit=2147483647" \
                  % (self._rms_ip, customer_id, lang, cpe_id, most_relevant_episode_for,
                     recording_state, show_id, season_id, channel_id)
        response = self._get_http_request(req_url).json()
        return response

    def delete_single_local_recording(self, customer_id, cpe_id, event_id):
        """This method sends DELETE request to delete recording with given event id for the given cpe
               :param
                   customer_id              : the customer id, e.g. 200284095_gb
                   cpe_id                   : the cpe id, e.g. 3C36E4-EOSSTB-003854325804
                   event_id                 : event id of the event to be deleted
               :return: an HTTP response instance
               """
        req_url = "%scustomers/%s/cpes/%s/recordings/%s" \
                  % (self._rms_ip, customer_id, cpe_id, event_id)
        response = self._delete_http_request(req_url)
        return response

    def schedule_single_ndvr_recording_via_rms(self, customer_id, event_id):
        """Sends POST request to "recording-management-service" to schedule a single recording
        for the given event of the given customer.
        :param
            customer_id : the customer id, e.g. "9770976_nl"
            event_id    : a program ID, e.g. "crid:~~2F~~2Fbds.tv~~2F172858925,imi:00100000000CD50D".
        :return: an HTTP response instance.
        """
        url = "%scustomers/%s/recordings/single" % (self._rms_ip, customer_id)
        data = json.dumps({"eventId": event_id, "pinProtected": False, "retentionLimit": 1})
        headers = {'Content-type': 'application/json'}
        BuiltIn().log("Url={} and parameters={}".format(url, data))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass
        response = self._post_http_request(url, data, headers)
        return response

    def delete_single_ndvr_recording(self, customer_id, event_id):
        """This method sends DELETE request to delete npvr recording with given event id
               :param
                   customer_id              : the customer id, e.g. 200284095_gb
                   cpe_id                   : the cpe id, e.g. 3C36E4-EOSSTB-003854325804
                   event_id                 : event id of the event to be deleted
               :return: an HTTP response instance
               """
        req_url = "%scustomers/%s/recordings/single/%s" \
                  % (self._rms_ip, customer_id, event_id)
        response = self._delete_http_request(req_url)
        return response

    def schedule_ndvr_show_recording_via_rms(self, customer_id, event_id):
        """Sends POST request to "recording-management-service" to schedule a show
        for the given event of the given customer
        :param
            customer_id : the customer id, e.g. "9770976_nl"
            event_id    : a program ID, e.g. "crid:~~2F~~2Fbds.tv~~2F172858925,imi:00100000000CD50D"
        :return: an HTTP response instance
        """
        url = "%scustomers/%s/recordings/show" % (self._rms_ip, customer_id)
        data = json.dumps({"eventId": event_id, "pinProtected": False, "retentionLimit": 1})
        headers = {'Content-type': 'application/json'}
        BuiltIn().log("Url={} and parameters={}".format(url, data))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass
        response = self._post_http_request(url, data, headers)
        return response

    def get_recording_details_via_rms(self, customer_id, event_id):
        """Sends GET request to "recording-management-service" to get details of the recording event
                :param
                    customer_id : the customer id, e.g. "9770976_nl"
                    event_id    : a program ID, e.g. "crid:~~2F~~2Fbds.tv~~2F172858925,imi:00100000000CD50D"
                :return: an HTTP response instance
                """
        req_url = "%scustomers/%s/recordings/%s" \
                  % (self._rms_ip, customer_id, event_id)
        response = self._get_http_request(req_url).json()
        return response

    def get_all_channels_via_rms(self):
        """Sends GET request to "recording-management-service" to get all channels
                    :return: an HTTP response instance
                    """
        req_url = "%schannels" % self._rms_ip
        response = self._get_http_request(req_url).json()
        return response

    def get_details_of_given_channel_via_rms(self, channel_id):
        """Sends GET request to "recording-management-service" to get details of the given channel
                :param
                    channel_id : the channel id, e.g. "NL_000019_019671"
                :return: an HTTP response instance
                """
        req_url = "%schannels/%s" % (self._rms_ip, channel_id)
        response = self._get_http_request(req_url).json()
        return response

    def delete_season_recordings_or_bookings(self, customer_id, season_id, channel_id, recordings_kind):
        """This method sends DELETE request to delete all recordings/bookings with given season id
                       :param
                           customer_id              : the customer id, e.g. 200284095_gb
                           season_id                : the id of the season that needs to be deleted,
                                                      e.g. crid:~~2F~~2Fbds.tv~~2F172858925
                           channel_id               : the channel id, e.g. "1730"
                       :return: an HTTP response instance
                       """
        url = "%scustomers/%s/recordings/season/%s" \
            % (self._rms_ip, customer_id, season_id)
        data = json.dumps({"channelId": channel_id, "recordingsKind": recordings_kind})
        headers = {'Content-type': 'application/json'}
        BuiltIn().log("Url={} and parameters={}".format(url, data))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass
        response = self._delete_http_request(url, data, headers)
        return response

    def delete_show_recordings_or_bookings(self, customer_id, show_id, channel_id, recordings_kind):
        """This method sends DELETE request to delete all recording/bookings with given show id
                       :param
                           customer_id              : the customer id, e.g. 200284095_gb
                           show_id                  : the id of the show that needs to be deleted,
                                                      e.g. crid:~~2F~~2Fbds.tv~~2F172858925
                           channel_id               : the channel id, e.g. "1730"
                       :return: an HTTP response instance
                       """
        url = "%scustomers/%s/recordings/show/%s" \
              % (self._rms_ip, customer_id, show_id)
        data = json.dumps({"channelId": channel_id, "recordingsKind": recordings_kind})
        headers = {'Content-type': 'application/json'}
        BuiltIn().log("Url={} and parameters={}".format(url, data))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass
        response = self._delete_http_request(url, data, headers)
        return response
