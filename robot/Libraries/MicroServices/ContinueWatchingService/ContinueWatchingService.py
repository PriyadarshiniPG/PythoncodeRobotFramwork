# pylint: disable=invalid-name
#!/usr/bin/env python27
# -*- coding: utf-8 -*-
"""
Description         Class definition for CWS
Reference: https://wikiprojects.upc.biz/display/SPARK
/Continue+Watching+Service+API+specification
"""

import sys
import requests
from requests import HTTPError
from robot.libraries.BuiltIn import BuiltIn
# from Utils.zephyr_reporter.modules.zephyr_api import retry_decorator

# Following pylint warnings were disabled for these classes
# R0904 - Too many public methods - we want as many test cases as possible
# W0212 - Access to protected member - we want to test private methods
# C0111 - Missing docstring - we don't want to document each test case
# C0103 - Invalid name - we want as descriptive test names as possible
# pylint: disable=C0111,W0212,R0904,C0103,C0326,W0613,R0903,E0202, invalid-name


class ContinueWatchingService(object):    #IT WAS cws
    """
    Reference: https://wikiprojects.upc.biz/display/SPARK
    /Continue+Watching+Service+API+specification
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
        self._cws_ip = "http://"+self._micro_service_url+"/continue-watching-service/"

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
                            'Problem with the get request')
        return response

    @staticmethod
    def _post_http_request(url, data, headers):
        """
        http post request
        :param url: The request url
        :param data: The body content in json format
        :param data: The request header values
        :return response: The response from the request
        """
        response = requests.post(url, json=data, headers=headers, timeout=10)
        if response.status_code != 204:
            raise HTTPError('Status:', response.status_code,
                            'Problem with the post request')
        return response

    # @retry_decorator
    def get_continue_watching_list(self, profile_id):
        """
        Query CWS for a list of continue watching items
        :param profile_id: The customer id string
        :return response: The response from the request
        """
        req_url = \
            self._cws_ip + 'profiles/' + profile_id + '/continue-watching/'
        response = self._get_http_request(req_url).json()
        return response

    # @retry_decorator
    def delete_item_from_cw_list_using_title_id(self, profile_id, title_id):
        """
        Deletes continue watching item from continue watching list
        using given title_id
        :param profile_id: The profile id string
        :param title_id: The title id of continue watching item
        :return response: The response from the request
        """
        req_url = \
            self._cws_ip + 'profiles/' + profile_id + \
            '/continue-watching/delete'
        headers = {'Content-type': 'application/json'}
        body = {'titleIds': [title_id]}
        response = self._post_http_request(
            req_url, body, headers)
        return response

    # @retry_decorator
    def delete_item_from_cw_list_using_show_id(self, profile_id, show_id):
        """
        Deletes continue watching item from continue watching list
        using given show_id
        :param profile_id: The profile id string
        :param show_id: The show id of continue watching item
        :return response: The response from the request
        """
        req_url = \
            self._cws_ip + 'profiles/' + profile_id + \
            '/continue-watching/delete'
        headers = {'Content-type': 'application/json'}
        body = {'showIds': [show_id]}
        response = self._post_http_request(
            req_url, body, headers)
        return response

    # @retry_decorator
    def delete_all_items_from_continue_watching_list(self, profile_id):
        """
        Delete all continue watching items from continue watching list
        for the given profile id
        :param profile_id: The profile id string
        """
        cw_list = self.get_continue_watching_list(profile_id)
        for item in cw_list:
            title_id = item['titleId']
            self.delete_item_from_cw_list_using_title_id(
                profile_id, title_id)
