#!/usr/bin/env python27
"""
Description         Class definition for the Watchlist Service
Reference: https://wikiprojects.upc.biz/display/SPARK/
Watchlist+Service+-+API+v1
"""
import urllib.parse
import sys
import requests
from requests import HTTPError
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError

# from Utils.zephyr_reporter.modules.zephyr_api import retry_decorator, \
#     REQ_TIMEOUT


class WatchlistService(object):
    """
    Reference: https://wikiprojects.upc.biz/display/SPARK/
    Watchlist+Service+-+API+v1
    """

    def __init__(self):
        """
        Initialise.
        """
        lab_name = None
        try:
            lab_name = BuiltIn().get_variable_value("${LAB_NAME}")
        except RobotNotRunningError:
            pass
        if lab_name:
            self._micro_service_url = BuiltIn().get_variable_value(
                "${E2E_CONF['"+lab_name+"']['MICROSERVICES']['OBOQBR']}")
            if not self._micro_service_url:
                BuiltIn().log_to_console(
                    "ERROR: : E2E_CONF[%s]['MICROSERVICES']['OBOQBR'] dont exist \n" % lab_name)
                sys.exit()
        else:
            BuiltIn().log_to_console("WARN: LAB_NAME is empty - LAB_NAME:%s" % lab_name)
            self._micro_service_url = "ERROR: No LAB_NAME Specify"
        self._watchlist_service_url = "http://"+self._micro_service_url+"/watchlist-service/"

    @staticmethod
    def _get_http_request(url, headers, parameters):
        response = requests.get(
            url, headers=headers, params=parameters, timeout=1000)   ##REQ_TIMEOUT)
        if response.status_code != 200:
            raise HTTPError('Status:', response.status_code,
                            'Problem with the request')
        return response

    def get_watchlist_content(self, profile_id, customer_id, language, cpe_id):
        """
        Gets the watchlist content
        :param profile_id: The profile id string
        :param customer_id: current active customer profile
        :param language: setup the language
        :param cpe_id: The cpe id string
        :return Watchlist content
        """
        url = '{}v1/watchlists/profile/{}'.format(self._watchlist_service_url, profile_id)
        parameters = {'sort': 'ADDED', 'order': 'DESC', 'smart': 'true', 'language': language,
                      'md': 'EXTENDED', 'sharedProfile': 'false'}
        headers = {'accept': 'application/json',
                   'X-cus': customer_id,
                   'X-Dev': cpe_id}
        return self._get_http_request(url, headers, parameters).json()

    def delete_watchlist_events(self, profile_id, customer_id):
        """Sends DELETE request to "watchlist-service" to delete a watchlist events

        :param profile_id: The profile id string
        :param customer_id: current active customer profile

        :return: an HTTP response instance.
        """
        url = '{}v1/watchlists/profile/{}' \
              ''.format(self._watchlist_service_url, profile_id)
        headers = {'accept': 'application/json',
                   'X-cus': customer_id}
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        response = requests.delete(url, headers=headers)
        if response.status_code != 204:
            BuiltIn().log_to_console("To delete_recording we send DELETE to %s\n"
                                     "Status code: %s. Reason: %s\n"
                                     % (url, response.status_code, response.reason))
        return response

    def add_vod_watchlist_event(self, watchlist_id, customer_id, crid, title):
        """Sends POST request to "watchlist-service" to add a VOD watchlist events

        :param watchlist_id: The watchlist id string
        :param customer_id: current active customer profile
        :param crid: crid for a VOD event
        :param title: title for the VOD event

        :return: an HTTP response instance.
        """
        url = '{}v1/watchlists/{}/entries?sharedProfile=true' \
              ''.format(self._watchlist_service_url, watchlist_id)
        headers = {'accept': 'application/json',
                   'X-cus': customer_id}
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass
        data = {
            "id": crid,
            "title": title,
            "showId": None,
            "type": "Asset"
        }
        response = requests.post(url, json=data, headers=headers)
        if response.status_code != 204:
            BuiltIn().log_to_console("To add watchlist we send POST to %s\n"
                                     "Status code: %s. Reason: %s\n"
                                     % (url, response.status_code, response.reason))
        return response


class Keywords(object):
    """"Keywords visible in Robot Framework"""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @staticmethod
    def get_watchlist_content(profile_id, customer_id, language, cpe_id):
        """Keyword-wraper to call WatchlistService().get_watchlist_content from RF"""
        return WatchlistService().get_watchlist_content(profile_id, customer_id, language, cpe_id)

    @staticmethod
    def delete_watchlist_events(profile_id, customer_id):
        """Keyword-wraper to call WatchlistService().delete_watchlist_events from RF"""
        return WatchlistService().delete_watchlist_events(profile_id, customer_id)

    @staticmethod
    def add_vod_watchlist_event(watchlist_id, customer_id, crid, title):
        """Keyword-wraper to call WatchlistService().add_vod_watchlist_event"""
        return WatchlistService().add_vod_watchlist_event(watchlist_id, customer_id, crid, title)
