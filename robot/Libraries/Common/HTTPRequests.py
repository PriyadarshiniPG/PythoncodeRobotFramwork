"""
This module provides a class for making HTTP requests
"""

import requests

from Libraries.Common.utils import DefaultRequestFactory

# pylint: disable=unused-argument

class HTTPRequests(object):
    """
    This class provides methods for debugging
    """

    def __init__(self, default_request_factory=DefaultRequestFactory()):
        self.default_request = default_request_factory

    def http_get(self, url, params=None, **kwargs):
        """
        Send get request for given url and returns response.
        Raises exception in case of connection error or response code != 200
        """
        response = self.default_request.get(url, params, **kwargs)
        return HTTPRequests._verify_response(response, 'get', url)

    def http_post(self, url, data=None, **kwargs):
        """
        Send post request for given url and returns response.
        Raises exception in case of connection error or response code != 200
        """
        response = self.default_request.post(url, data, **kwargs)
        return HTTPRequests._verify_response(response, 'post', url)

    def http_put(self, url, data=None, **kwargs):
        """
        Send put request for given url and returns response.
        Raises exception in case of connection error or response code != 200
        """
        response = self.default_request.put(url, data, **kwargs)
        return HTTPRequests._verify_response(response, 'put', url)

    def http_delete(self, url, **kwargs):
        """
        Send delete request for given url and returns response.
        Raises exception in case of connection error or response code != 200
        """
        response = self.default_request.delete(url, **kwargs)
        return HTTPRequests._verify_response(response, 'delete', url)

    @staticmethod
    def _verify_response(response, request_type, request_url):
        """
        Verify the response of the request and return the result
        :param response:
        :param request_type:
        :param request_url:
        :return: Given response
        """
        if response.status_code != 200:
            raise requests.HTTPError(
                "Unexpected {0}-request '{1}' response status code '{2}'."
                " Expected 200. Full Response: {3}"
                .format(request_type, request_url,
                        response.status_code, response.text))
        return response
