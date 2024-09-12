"""Implementation of Customer Provisioning Microservice for HZN 4
v0.0.1 - Anuj Teotia :  Added function check_consistency
"""
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


class CustomerProvisioningServiceRequests(object):
    """Class handling all functions relating
    to making Customer Provisioning Service requests
    """

    def __init__(self, conf, country, customer_id):
        """"Class initializer.
        :param conf: config file for labs
        :param country: the country provided by Jenkins
        :param customer_id: the customer Id returned from Traxis
        """
        self.basepath = "http://{}/customer-provisioning-service"\
            .format(conf["MICROSERVICES"]["OBOQBR"])
        self.country = country
        self.customer_id = customer_id
        try:
            # Use folder name where this file is placed
            # (as Traxis, Fabrix, PurchaseMicroservice, etc) as a tag
            folder_name = os.path.basename(os.path.dirname(os.path.realpath(__file__)))
            BuiltIn().set_test_variable("${ENDPOINT_TAG}", "%s" % folder_name)
        except RobotNotRunningError:
            pass

    def check_customer_consistency(self):
        """A function to return the VOD structure.
        :return: result of requests.get() or failed_response_data() if request failed.
        """
        url = "{}/cps/checkConsistency".format(self.basepath)
        parameters = {'countryId': self.country, 'customerId': self.customer_id}
        BuiltIn().log("Url={} and Parameters={}".format(url, parameters))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url, params=parameters)
            if response.status_code != 200:
                BuiltIn().log_to_console("Send GET to %s?countryId=%s&customerId=%s"
                                         "Status code: %s, Reason: %s"
                                         % (url, self.country, self.customer_id,
                                            response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

class Keywords(object):
    """"Keywords visible in Robot Framework"""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @staticmethod
    def check_customer_consistency(conf, country, customer_id):
        """A keyword to return the VOD structure.
        :param conf: config file for labs
        :param country: the country provided by Jenkins
        :param customer_id: the customer Id for CPE

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        vs_obj = CustomerProvisioningServiceRequests(conf, country, customer_id)
        response = vs_obj.check_customer_consistency()
        return response
