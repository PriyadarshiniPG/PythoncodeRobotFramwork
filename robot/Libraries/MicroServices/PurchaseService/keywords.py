"""Implementation of Purchase Microservice for HZN 4
v0.0.2 Nidhi Tiwari: Added keyword get_purchase_service_health_check,
       get_purchase_service_info and get_entitlements
"""

import os
import json
import socket
import urllib.parse
import requests
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError
from requests import HTTPError
from Libraries.general.keywords import Keywords as general

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
                request=type("", (), dict(method=req_method, url=req_url, body=req_body))()
               )
    return type("", (), data)()


class PurchaseServiceRequests(object):
    """Class handling all functions relating to making VOD Service requests."""

    def __init__(self, conf, customer_id=None):
        """"Class initializer.

        :param conf: config file for labs.
        :param customer_id: the customer Id returned from IT Faker.
        """
        self.base_path = "http://%s/purchase-service" % conf["MICROSERVICES"]["OBOQBR"]
        self.customer_id = customer_id
        self.cpe = conf["CPE_ID"]
        try:
            # Use folder name where this file is placed
            # (as Traxis, Fabrix, PurchaseMicroservice, etc) as a tag
            folder_name = os.path.basename(os.path.dirname(os.path.realpath(__file__)))
            BuiltIn().set_test_variable("${ENDPOINT_TAG}", "%s" % folder_name)
        except RobotNotRunningError:
            pass

    @staticmethod
    def _get_http_request(url, headers=None, parameters=None):
        """
        http get request
        :param url: The request url
        :return response: The response from the request
        """
        headers = general.update_microservice_headers(headers)
        response = requests.get(url, headers=headers, params=parameters, timeout=10)
        if response.status_code in [200, 204]:
            return response

        raise HTTPError('Status:', response.status_code,
                        response.reason)

    @staticmethod
    def _post_http_request(url, headers=None, parameters=None):
        """
        http get request
        :param url: The request url
        :return response: The response from the request
        """
        headers = general.update_microservice_headers(headers)
        response = requests.post(url, data=parameters, headers=headers)
        if response.status_code in [200, 204]:
            return response

        raise HTTPError('Status:', response.status_code,
                        response.reason)

    def purchase_tvod(self, detail_response_text, cpe_id):
        """A function to purchase a TVOD asset.
        :param
            detail_response_text: assetDetail response body from VOD Service.
            cpe_id: cpe id used
        """
        json_response = json.loads(detail_response_text)
        url = "%s/customers/%s/purchase" % (self.base_path, self.customer_id)
        headers = {'dev-X': cpe_id, 'content-type': 'application/json'}
        try:
            offers_list = json_response['instances'][0]['offers']
        except KeyError:
            raise KeyError("Can't purchase the asset")
        payload = {"offerId": "",
                   "price": "",
                   "deviceId": cpe_id,
                   "productId": ""}
        for offer in offers_list:
            if offer["type"] == "Transaction":
                payload = json.dumps({"offerId": offer['offerId'],
                                      "price": offer['price'],
                                      "deviceId": cpe_id,
                                      "productId": offer['id']})
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = self._post_http_request(url, headers=headers, parameters=payload)
            if response.status_code != 200:
                BuiltIn().log_to_console("To purchase_tvod we send POST to %s .\nData:\n%s"
                                         "\nHeaders:\n%s\nStatus code: %s\nReason %s.\nText: %s"
                                         % (url, payload, headers,
                                            response.status_code, response.reason, response.text))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send POST %s due to %s" % (url, err)))
            response = failed_response_data("POST", url, None, err)
        return response

    def get_purchase_service_health(self):
        """A method sends GET request to get the health status of Purchase Microservice
        A text of Purchase Microservice response is a json string.

        :return: an HTTP response instance in JSON.
        """
        url = "%s/health-checks" % self.base_path
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url)
            if response.status_code != 200:
                BuiltIn().log_to_console("To get_purchase_service_health we send GET to %s"
                                         "\nStatus code: %s . Reason %s"
                                         % (url, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

    def get_purchase_service_info(self):
        """A method sends GET request to get the information about Purchase Microservice
        A text of Purchase Microservice response is a json string.

        :return:an HTTP response instance in JSON.
        """
        url = "%s/info" % self.base_path
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url)
            if response.status_code != 200:
                BuiltIn().log_to_console("To get_purchase_service_info we send GET to %s"
                                         "\nStatus code: %s . Reason %s"
                                         % (url, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

    def get_entitlements(self, customer_id):
        """A method get the list of entitlements from purchase service for a valid customer.
        A text of Purchase Microservice response is a json string.
        :param customer_id: customer Id like 'ecfe90d0-e575-11e7-a6bf-755914bd09e0_nl'.
        :return: an HTTP response instance in JSON.
        """

        url = "%s/v2/customers/%s/entitlements/" % (self.base_path, customer_id)
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = self._get_http_request(url)
            if response.status_code != 200:
                BuiltIn().log_to_console("To get_entitlements we send GET to %s\nStatus code: %s ."
                                         "Reason %s"
                                         % (url, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response


class Keywords(object):
    """"Keywords visible in Robot Framework"""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @staticmethod
    def purchase_tvod(conf, customer_id, detail_response, cpe_id):
        """Keyword for purchasing TVOD asset."""
        ps_obj = PurchaseServiceRequests(conf, customer_id)
        response = ps_obj.purchase_tvod(detail_response, cpe_id)
        return response

    @staticmethod
    def get_purchase_service_health(lab_conf):
        """A method sends GET request to get the health status of Purchase Microservice
        A text of Purchase Microservice response is a json string.

        :return: an HTTP response instance in JSON.
        """
        return PurchaseServiceRequests(lab_conf).get_purchase_service_health()

    @staticmethod
    def get_purchase_service_info(lab_conf):
        """A method sends GET request to get the information about Purchase Microservice
        A text of Purchase Microservice response is a json string.

        :return:an HTTP response instance in JSON.
        """
        return PurchaseServiceRequests(lab_conf).get_purchase_service_info()

    @staticmethod
    def get_entitlements(lab_conf, **kwargs):
        """A method get the list of entitlements from purchase service for a valid customer.
        A text of Purchase Microservice response is a json string.
        :param customer_id: customer Id like 'ecfe90d0-e575-11e7-a6bf-755914bd09e0_nl'.
        :return: an HTTP response instance in JSON.
        """
        return PurchaseServiceRequests(lab_conf).get_entitlements(**kwargs)
