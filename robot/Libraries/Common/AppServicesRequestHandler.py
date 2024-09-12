#!/usr/bin/env python27
"""
Module handling the application services calls to the STB with
or without XAP server
"""
import re
import json
from requests.exceptions import Timeout, ConnectionError
from Libraries.Common.XAPViaMQTT import XAPViaMQTT
from Libraries.Common.HTTPRequests import HTTPRequests
# from Libraries.Common.SSHLib import SSHLib


class AppServicesRequestHandler(object):
    """
    Module handling the application services calls to the STB with
    or without XAP server
    """

    def __init__(self, requests_via_xap=None):
        """
        Constructor
        :param requests_via_xap:
        """
        if requests_via_xap:
            self.requests_via_xap = requests_via_xap
        else:
            self.requests_via_xap = XAPViaMQTT()
        self.direct_requests = HTTPRequests()

    @staticmethod
    def _replace_local_host_with_stb_ip(url, ip_address):
        """
        Replace the localhost address with the STB IP
        :param url: URL to be replaced
        :param ip_address: destination address
        :return: URL replaced localhost to STB IP
        """
        return re.sub('(://127.0.0.1:)|(://localhost:)',
                      '://' + ip_address + ':', url)

    @staticmethod
    def _disable_the_firewall(ip_address):
        """
        Disable firewall restrictions
        :param ip_address: destination address
        """

        print(("AppServicesRequestHandler: method: _disable_the_firewall, argument: %s" % ip_address))
        # ssh = SSHLib()
        # ssh_handle = ssh.open_connection(ip_address)
        # ssh.login(ip_address, ssh_handle)
        # ssh.execute_command(
        #     ip_address, ssh_handle, '/usr/sbin/iptables -P INPUT ACCEPT')
        # ssh.execute_command(
        #     ip_address, ssh_handle, '/usr/sbin/iptables -P OUTPUT ACCEPT')
        # ssh.execute_command(
        #     ip_address, ssh_handle, '/usr/sbin/iptables -P FORWARD ACCEPT')
        # ssh.execute_command(
        #     ip_address, ssh_handle, '/usr/sbin/iptables -F')
        # ssh.close_connection(ip_address, ssh_handle)

    def get(self, ip_address, cpe_id, url, is_json=True, xap=True,
            params=None, **kwargs):
        """
        GET request to an application service
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param url: The request url
        :param is_json: is_json
        :param xap: Is xap request
        :param params: params
        :param kwargs: keyword arguments
        :return: json response
        """
        if xap:
            response = self.requests_via_xap.get_via_xap(
                cpe_id, url, is_json=is_json)
        else:
            url = self._replace_local_host_with_stb_ip(url, ip_address)
            try:
                response = self.direct_requests.http_get(
                    url, params=params, **kwargs)
            except (Timeout, ConnectionError):
                self._disable_the_firewall(ip_address)
                response = self.direct_requests.http_get(
                    url, params=params, **kwargs)
            response = _verify_response(response)

        return response

    def put(self, ip_address, cpe_id, url, body, headers, xap=True, raw=False,
            **kwargs):
        """
        PUT request to an application service
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param url: The request url
        :param body: request body
        :param headers: request headers
        :param xap: Is xap request
        :param raw: True/False
        :param kwargs: keyword arguments
        :return: json response
        """
        if xap:
            response = self.requests_via_xap.put_via_xap(
                cpe_id, url, body, headers, raw=raw)
        else:
            url = self._replace_local_host_with_stb_ip(url, ip_address)
            if raw:
                json_data = body
            else:
                json_data = json.dumps(body)
            try:
                response = self.direct_requests.http_put(
                    url, data=json_data, headers=headers, **kwargs)
            except (Timeout, ConnectionError):
                self._disable_the_firewall(ip_address)
                response = self.direct_requests.http_put(
                    url, data=json_data, headers=headers, **kwargs)
            response = _verify_response(response)

        return response

    def post(self, ip_address, cpe_id, url, body=None, headers=None, xap=True,
             **kwargs):
        """
        POST request to an application service
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param url: The request url
        :param body: request body
        :param headers: request headers
        :param xap: Is xap request
        :param kwargs: keyword arguments
        :return: json response
        """
        if xap:
            response = self.requests_via_xap.post_via_xap(
                cpe_id, url, body, headers)
        else:
            url = self._replace_local_host_with_stb_ip(url, ip_address)
            json_data = json.dumps(body)
            try:
                response = self.direct_requests.http_post(
                    url, data=json_data, headers=headers, **kwargs)
            except (Timeout, ConnectionError):
                self._disable_the_firewall(ip_address)
                response = self.direct_requests.http_post(
                    url, data=json_data, headers=headers, **kwargs)
            response = _verify_response(response)

        return response

    def delete(self, ip_address, cpe_id, url, headers, xap=True, body=None,
               **kwargs):
        """
        DELETE request to an application service
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param url: The request url
        :param headers: request headers
        :param xap: Is xap request
        :param body: request body
        :param kwargs: keyword arguments
        :return: json response
        """
        if xap:
            response = self.requests_via_xap.delete_via_xap(
                cpe_id, url, headers)
        else:
            url = self._replace_local_host_with_stb_ip(url, ip_address)
            json_data = json.dumps(body)
            try:
                response = self.direct_requests.http_delete(
                    url, data=json_data, headers=headers, **kwargs)
            except (Timeout, ConnectionError):
                self._disable_the_firewall(ip_address)
                response = self.direct_requests.http_delete(
                    url, data=json_data, headers=headers, **kwargs)
            response = _verify_response(response)

        return response

    def get_screenshot(self, ip_address, cpe_id, url, width, height, xap=True,
                       compression_type='none'):
        """
        Get screen shot of the STB
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param url: The request url
        :param headers: request headers
        :param xap: Is xap request
        :return:
        """
        if xap:
            response = self.requests_via_xap.post_ss_via_xap(cpe_id, width,
                                                             height, compression_type)
        else:
            response = self.get(ip_address, cpe_id, url, xap=False, timeout=10)

        return response


def _verify_response(response):
    json_response = None
    if response.text:
        json_response = response.json()
    return json_response
