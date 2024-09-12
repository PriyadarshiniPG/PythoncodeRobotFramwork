"""Implementation of Microservices Healthcheck for HZN 4"""
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
                request=type("", (), dict(method=req_method, url=req_url, body=req_body))()
               )
    return type("", (), data)()


class OBOQBR_Requests(object):
    """Class handling all functions relating
    to making health check requests
    """

    def __init__(self, conf):
        """Class initializer

        :param conf: a dictionary with lab settings
        """
        self.endpoint = conf["MICROSERVICES"]["OBOQBR"]
        try:
            # Use folder name where this file is placed
            # (as Traxis, Fabrix, PurchaseMicroservice, etc) as a tag
            folder_name = os.path.basename(os.path.dirname(os.path.realpath(__file__)))
            BuiltIn().set_test_variable("${ENDPOINT_TAG}", "%s" % folder_name)
        except RobotNotRunningError:
            pass

    def health_check_info(self, service_name):
        """A method to call the /info section of the service.

        :param service_name: a human-friendly service name, e.g. "Customer Provisioning Service".

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        url = "http://%s/%s/info" % (self.endpoint, service_name.lower().replace(" ", "-"))

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url)
            if response.status_code != 200:
                BuiltIn().log_to_console("To get OBOQBR health check info we send GET to %s . "
                                         "Status code %s . Reason %s" %
                                         (url, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

    def health_check_info_epg_service(self, service_name):
        """A method to call the /info section of the service.

        :param service_name: a human-friendly service name, e.g. "Customer Provisioning Service".

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        url = "http://%s/%s/info" % (self.endpoint, service_name.lower().replace(" ", "-"))
        BuiltIn().log("url : {}".format(url))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url)
            if response.status_code != 200:
                BuiltIn().log_to_console("To get OBOQBR health check info for %s we send GET \
                                        to %s. Status code %s . Reason %s" %
                                         (service_name, url, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

    def health_check_detail(self, service_name):
        """Function to call the /health-checks section of the service.

        :param conf: a dictionary containing lab configuration settings.
        :param service_name: a human-friendly service name, e.g. "Customer Provisioning Service".

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        url = "http://%s/%s/health-checks" % (self.endpoint, service_name.lower().replace(" ", "-"))

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url)
            if response.status_code != 200:
                BuiltIn().log_to_console("To get OBOQBR health check details we send GET to %s . "
                                         "Status code %s . Reason %s" %
                                         (url, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

    def get_customer_collection_request(self, customer_id):
        """Function to get all the collection of a customer

         :param conf: a dictionary containing lab configuration settings.
         :param customer_id: customer id.

         :return: result of requests.get() or failed_response_data() if request failed.
         """
        url = "http://%s/recording-service/customers/%s/collection?language=en" % (self.endpoint,
                                                                                   customer_id)

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url)
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response


class Keywords(object):
    """"Keywords visible in Robot Framework"""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @staticmethod
    def health_check_info(conf, service_name):
        """A keyword check the health status of all microservices servers.
        :param conf: a dictionary containing lab configuration settings.
        :param service_name: a human-friendly service name, e.g. "Customer Provisioning Service".

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        return OBOQBR_Requests(conf).health_check_info(service_name)

    @staticmethod
    def health_check_info_epg_service(conf, service_name):
        """A keyword check the health status of all microservices servers.
        :param conf: a dictionary containing lab configuration settings.
        :param service_name: a human-friendly service name, e.g. "Customer Provisioning Service".

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        return OBOQBR_Requests(conf).health_check_info_epg_service(service_name)

    @staticmethod
    def health_check_detail(conf, service_name):
        """A Keyword to validate the test result returned from health_check
        :param conf: a dictionary containing lab configuration settings.
        :param service_name: a human-friendly service name, e.g. "Customer Provisioning Service".

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        return OBOQBR_Requests(conf).health_check_detail(service_name)

    @staticmethod
    def get_customer_collection(conf, customer_id):
        """A Keyword to return the collection of a customer
        :param conf: a dictionary containing lab configuration settings.
        :param customer_id: a customer ID

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        return OBOQBR_Requests(conf).get_customer_collection_request(customer_id)
