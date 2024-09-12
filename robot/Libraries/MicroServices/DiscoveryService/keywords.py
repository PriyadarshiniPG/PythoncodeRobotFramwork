"""Implementation of Discovery Microservice for HZN 4
v0.0.2 Nidhi Tiwari: Added keyword get_discovery_service_info
v0.0.3 Anuj Teotia: Added keyword get_event_detail
v0.0.4 Ankita Agrawal: Added keyword get_recommendations
v0.0.5 Anuj Teotia: Modified all the functions for profile Id.
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


class DiscoveryServiceRequests(object):
    """Class handling all functions relating
    to making health check requests
    """

    def __init__(self, conf, client_type=None, customer_id=None, profile_id=None):
        """"Class initializer.
        :param conf: config file for labs
        :param client_type: the client type for requests
        :param customer_id: customerId recovered from EDS database
        """
        host = conf["MICROSERVICES"]["OBOQBR"]
        self.base_path = "http://%s/discovery-service" % host
        self.client_type = client_type
        self.country = conf["country"]
        self.customer_id = customer_id
        self.profile_id = profile_id
        try:
            # Use folder name where this file is placed
            # (as Traxis, Fabrix, PurchaseMicroservice, etc) as a tag
            folder_name = os.path.basename(os.path.dirname(os.path.realpath(__file__)))
            BuiltIn().set_test_variable("${ENDPOINT_TAG}", "%s" % folder_name)
        except RobotNotRunningError:
            pass

    def get_search_results(self, search_term, max_results):
        """"A function to build and send the search request
        :param search_term: the search term for requests - To be provided by Jenkins
        :param max_results: the maximum results to return
        """
        url = "%s/v1/search/contents" % self.base_path
        parameters = {'clientType': self.client_type, 'searchTerm': search_term,
                      'customerId': self.customer_id, 'profileId': self.profile_id,
                      'startResults': 0, 'maxResults': max_results,
                      'includeNotEntitled': True, 'queryLanguage': 'en'}
        BuiltIn().log("Url is : {}".format(url))
        BuiltIn().log("Parameters are : {}".format(parameters))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url, params=parameters)
            if response.status_code != 200:
                BuiltIn().log_to_console("To get_search_results we send GET to %s\n"
                                         "Response code is: %s\nReason is: %s" %
                                         (url, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

    def get_discovery_service_info(self):
        """A method sends GET request to get the information about Discovery Microservice
        A text of Discovery Microservice response is a json string.

        :return: a dictionary loaded from the Discovery Microservice response text,
        response object and url
        """
        url = "%s/info" % (self.base_path)

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
        return  response

    def get_event_detail(self, crid_id):
        """A method sends GET request to fetch
        event detail page information about Discovery Microservice
        A text of Discovery Microservice response is a json string.

        :return: a dictionary loaded from the Discovery Microservice response text,
        response object and url
        """
        url = "%s/v1/eventDetail" % (self.base_path)
        parameters = {'profileId': self.profile_id, 'customerId': self.customer_id,
                      'language': 'en', 'country': self.country, 'seriesId': crid_id}
        BuiltIn().log("url={} and parameters={}".format(url, parameters))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url, params=parameters)
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return  response

    def get_recommendations(self, resource_id, start_time, end_time, resource_content_source_id):
        """A method sends GET request to fetch
            recommendations from Discovery Microservice
            A text of Discovery Microservice response is a json string.

            :return: a dictionary loaded from the Discovery Microservice response text,
            response object and url
        """
        url = "%s/v1/recommendations/more-like-this?" \
              "customerId=%s&profileId=%s&contentSourceId=%d" \
              "&filterTimeWindowStart=%s" \
              "&filterTimeWindowEnd=%s&resourceContentSourceId=%d" \
              "&clientType=%s&resourceId=%s" \
              "&maxResults=6&includeNotEntitled=false&isReplayOrCatchup=false" \
              % (self.base_path, self.customer_id, self.profile_id, resource_content_source_id,
                 start_time, end_time, resource_content_source_id, self.client_type, resource_id)
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
    def get_search_results(conf, client_type, customer_id, profile_id, search_term, max_results):
        """A keyword to return the results for the specified searchterm.
        :param conf: config file for labs
        :param client_type: 399
        :param customer_id: customerId recovered from EDS DB
        :param profile_id: profile_id from personalization service.
        :param search_term: string to search for
        :param max_results: maximum number of results to return
        """
        ds_obj = DiscoveryServiceRequests(conf, client_type, customer_id, profile_id)
        response = ds_obj.get_search_results(search_term, max_results)
        return response

    @staticmethod
    def get_discovery_service_info(lab_conf):
        """A method sends GET request to get information about Discovery Microservice
         A text of Discovery Microservice response is a json string.
        :param lab_conf: the conf dictionary, containing Discovery Microservice settings.
        :return: a dictionary loaded from the Discovery Microservice Information.
        """
        return DiscoveryServiceRequests(lab_conf).get_discovery_service_info()

    @staticmethod
    def get_event_detail(lab_conf, client_type, customer_id, profile_id, crid_id):
        """A method sends GET request to get information about Discovery Microservice
         A text of Discovery Microservice response is a json string.
        :param lab_conf: the conf dictionary, containing Discovery Microservice settings.
        :param customer_id: customerId from traxis
        :param profile_id: profileId from personalization service
        :return: a dictionary loaded from the Discovery Microservice Information.
        """
        ds_obj = DiscoveryServiceRequests(lab_conf, client_type, customer_id, profile_id)
        response = ds_obj.get_event_detail(crid_id)
        return response

    @staticmethod
    def get_recommendations(lab_conf, client_type, customer_id, profile_id, resource_id,
                            start_time, end_time, resource_content_source_id=1):
        """A method sends GET request to get information about Discovery Microservice
         A text of Discovery Microservice response is a json string.
        :param
            lab_conf: the conf dictionary,
            customer_id: the customer id,
            resource_id: resource id of event,
            start_time: start time of event,
            end_time: end time of event
        :return: a dictionary loaded from the Discovery Microservice Information.
        """
        ds_obj = DiscoveryServiceRequests(lab_conf, client_type, customer_id, profile_id)
        response = ds_obj.get_recommendations(resource_id, start_time, end_time,
                                              resource_content_source_id)
        return response
