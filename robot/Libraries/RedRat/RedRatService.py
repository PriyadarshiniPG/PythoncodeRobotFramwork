#!/usr/bin/env python37
# -*- coding: utf-8 -*-
"""
Description         Class definition for the Red Rat Service
"""

import sys
import json
import requests
from requests import HTTPError
# from Utils.zephyr_reporter.Keywords.zephyr_api import retry_decorator
from robot.libraries.BuiltIn import BuiltIn

class RedRatService(object):
    @staticmethod
    def _get_http_request(url, headers, parameters):
        """
        http get request
        :param url: The request url
        :return response: The response from the request
        """
        response = requests.get(url, headers=headers, params=parameters, timeout=10)
        if response.status_code != 200:
            raise HTTPError('Status:', response.status_code,
                            'Problem with the request')
        return response

    @staticmethod
    def _put_http_request(url, parameters, headers):
        """
        http get request
        :param url: The request url
        :return response: The response from the request
        """
        response = requests.put(url, data=parameters, headers=headers)
        if response.status_code == 200 or response.status_code == 204:
            return response

        raise HTTPError('Status:', response.status_code,
                        response.reason)

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
        if response.status_code not in [204, 200] :
            raise HTTPError('Status:', response.status_code,
                            'Problem with the post request')
        return response

    def send_red_rat_signal(self, key_code):
        """
        Calls the http method to the connected Red Rat device
        :param key_code: The ir keycode
        :return response: The response from the request
        """
        RED_RAT_ADDRESS = BuiltIn().get_variable_value("${RED_RAT_IR_IP}")
        RED_RAT_PORT = BuiltIn().get_variable_value("${RED_RAT_IR_PORT}")
        RED_RAT_DEVICE = BuiltIn().get_variable_value("${RED_RAT_DEVICE}")
        RED_RAT_DEVICE_OUTPUT_PORT = BuiltIn().get_variable_value("${RED_RAT_DEVICE_OUTPUT_PORT}")
        if RED_RAT_ADDRESS and RED_RAT_PORT and RED_RAT_DEVICE and RED_RAT_DEVICE_OUTPUT_PORT:
            self._service_url = "http://{0}:{1}/api/redrats/{2}/{3}".format(RED_RAT_ADDRESS, RED_RAT_PORT,
                                                                            RED_RAT_DEVICE, RED_RAT_DEVICE_OUTPUT_PORT)
        headers = {'Content-type': 'application/json'}
        body = {'dataset': 'Selene_Samsung', 'signal': key_code }
        response = self._post_http_request(
            self._service_url, body, headers)
        return response
