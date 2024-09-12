"""Implementation of RENG for HZN 4
v0.0.2 Nidhi Tiwari: Added keyword reng_search
v0.0.3 Ankita Agrawal: Added keyword get_recommendations_reng
"""
import os
import socket
import random
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


def http_send(method, url, data=None, headers=None, params=None):
    """Send HTTP GET/POST request and use try-except block for any error handling

    :param method: an HTTP method, e.g. "POST".
    :param url: a url used to send the request.
    :param data: a string of data sent (if any).
    :param headers: header to be sent with the request.
    :param params: list of parameters to be sent with request if any.

    :return: an HTTP response instance.
    """
    try:
        BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                    urllib.parse.urlparse(url).path)
    except RobotNotRunningError:
        pass

    try:
        if method == "GET":
            response = requests.get(url, headers=headers, params=params)
        elif method == "POST":
            response = requests.post(url, data=data, headers=headers, params=params)
    except (requests.exceptions.ConnectionError, socket.gaierror) as err:
        print(("Could not send %s %s due to %s" % (method, url, err)))
        response = failed_response_data("GET", url, None, err)
    return response


class RengRequests(object):
    """Class handling all functions relating
    to making RENG requests
    """

    def __init__(self, lab_conf, customer_id=None, client_type=None,
                 search_term=None, max_results=None):
        """The class initializer.

        :param lab_conf: the conf dictionary, containing RENG settings.
        :param client_type: the client type for requests
        :param customer_id: customerId recovered from conf file
        :param search_term: the search term for requests - To be provided by Jenkins
        :param max_results: the maximum results to return
        """
        self.conf = lab_conf
        self.customer_id = customer_id
        self.client_type = client_type
        self.search_term = search_term
        self.max_result = max_results
        try:
            # Use folder name where this file is placed
            # (as Traxis, Fabrix, PurchaseMicroservice, etc) as a tag
            folder_name = os.path.basename(os.path.dirname(os.path.realpath(__file__)))
            BuiltIn().set_test_variable("${ENDPOINT_TAG}", "%s" % folder_name)
        except RobotNotRunningError:
            pass

    def reng_search(self, node_name):
        """A method returns the response of search term from RENG  from different nodes.
        :param node_name: RENG Node
        :return: A text of RENG response is a json string.
        """

        node = "Node%s" % node_name
        host = self.conf["RENG"][node]["host"]
        port = random.choice(self.conf["RENG"][node]["port"])
        subscriberid = "%s%%23MasterProfile" % self.customer_id
        url = "http://%s:%s/RE/REController.do?contentSourceId=1&contentSourceId=2&" \
              "contentSourceId=101&contentSourceId=3&clientType=%s&method=lgiAdaptiveSearch&" \
              "subscriberId=%s&term=%s&startResults=0&maxResults=%s&applyMarketingBias=true&" \
              "filterVodAvailableNow=true&queryLanguage=en&" \
              % (host, port, self.client_type, subscriberid, self.search_term, self.max_result)
        response = http_send("GET", url)
        if response.status_code != 200:
            BuiltIn().log_to_console("To reng_search we send GET to %s\n"
                                     "Status code: %s. Reason: %s" %
                                     (url, response.status_code, response.reason))
        return response

    def reng_search_vip(self, node_name):
        """A method returns the response of search term from RENG  from different nodes.
        :param node_name: RENG Node
        :return: A text of RENG response is a json string.
        """

        node = "Node%s" % node_name
        host = self.conf["RENG"][node]["host"]
        port = random.choice(self.conf["RENG"][node]["port"])
        subscriberid = "%s%%23MasterProfile" % self.customer_id
        url = "http://%s:%s/RE/REController.do?method=lgiAdaptiveSearch&" \
              "clientType=%s&contentSourceId=2&subscriberId=%s&" \
              "term=%s&applyMarketingBias=false&startResults=0&" \
              "maxResults=%s&sortMode=preferences HTTP/1.1" \
              % (host, port, self.client_type, subscriberid, self.search_term, self.max_result)
        response = http_send("GET", url)
        if response.status_code != 200:
            BuiltIn().log_to_console("To reng_search_vip we send GET to %s\n"
                                     "Status code: %s. Reason: %s" %
                                     (url, response.status_code, response.reason))
        return response

    def get_recommendations_reng(self, node_name, start_time, end_time, crid):
        """A method returns the response of search term from RENG  from different nodes.
        :param node_name: RENG Node
        :param start_time: current epoch time
        :param end_time: end epoch time
        :param crid: event crid
        :return: A text of RENG response is a json string.
        """
        node = "Node%s" % node_name
        host = self.conf["RENG"][node]["host"]
        port = random.choice(self.conf["RENG"][node]["port"])
        subscriberid = "%s%%23MasterProfile" % self.customer_id
        content_id = "%5B1%5Dcrid%3A%2F%2Fbds.tv%"
        formatted_crid = crid[crid.find(".tv~~")+5:crid.find(",")]
        formatted_crid = content_id + formatted_crid
        url = "http://%s:%s/RE/REController.do?contentSourceId=1&contentSourceId=2&" \
              "clientType=%s&method=getRelatedContentRecommendation&" \
              "subscriberId=%s&contentItemId=%s" \
              "&numRecommendations=6&filterTimeWindow=%s&filterTimeWindow=%s&" \
              "applyMarketingBias=false&" \
              "filterVodAvailableNow=true" \
              % (host, port, self.client_type, subscriberid, formatted_crid, start_time, end_time)
        response = http_send("GET", url)
        if response.status_code != 200:
            BuiltIn().log_to_console("To reng_search we send GET to %s\n"
                                     "Status code: %s. Reason: %s" %
                                     (url, response.status_code, response.reason))
        return response


class Keywords(object):
    """"Keywords visible in Robot Framework"""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @staticmethod
    def reng_search(conf, customer_id, client_type, search_term, max_results, node_name):
        """A keyword to return the results for the specified searchterm.
        :param conf: config file for labs
        :param client_type: 399
        :param customer_id: customerId of customer
        :param search_term: string to search for
        :param max_results: maximum number of results to return
        :param node_name: RENG Node
        """

        reng_obj = RengRequests(conf, customer_id, client_type, search_term, max_results)
        response = reng_obj.reng_search(node_name)
        return response

    @staticmethod
    def reng_search_vip(conf, customer_id, client_type, search_term, max_results, node_name):
        """A keyword to return the results for the specified searchterm.
        :param conf: config file for labs
        :param client_type: 399
        :param customer_id: customerId of customer
        :param search_term: string to search for
        :param max_results: maximum number of results to return
        :param node_name: RENG Node
        """

        reng_obj = RengRequests(conf, customer_id, client_type, search_term, max_results)
        response = reng_obj.reng_search_vip(node_name)
        return response

    @staticmethod
    def get_recommendations_reng(conf, customer_id, node_name, start_time, end_time,
                                 crid, client_type):
        """A keyword to return the results for the specified searchterm.
        :param conf: config file for labs
        :param client_type: 305
        :param customer_id: customerId of customer
        :param start_time: current epoch time
        :param end_time: end epoch time
        :param crid: event crid
        :param node_name: RENG Node
        """

        reng_obj = RengRequests(conf, customer_id, client_type)
        response = reng_obj.get_recommendations_reng(node_name, start_time, end_time, crid)
        return response
