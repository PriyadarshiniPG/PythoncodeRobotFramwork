# pylint: disable=invalid-name
# Disabled pylint "invalid-name" complaining on the keyword 'get_oboqbr_session_review_channel'
# (name length > 30) but shortening the name will affect the sense of what the keyword is doing.
"""Implementation of Session Microservice library's keywords for Robot Framework.
v0.0.2 - Nidhi Tiwari: added keyword get_session_service_info
v0.0.3 - Anuj Teotia: added get_hollow_data method.
"""
import socket
import os
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
                request=type("", (), dict(method=req_method, url=req_url, body=req_body))())
    return type("", (), data)()


class SessionMicroserviceRequests(object):
    """A class to handle requests to Session Microservice through OBOQBR."""

    def __init__(self, lab_conf):
        """The class initializer.
        :param lab_conf: the conf dictionary, containig lab settings.
        """
        self.conf = lab_conf
        self.base_url = "http://%s/session-service" % self.conf["MICROSERVICES"]["OBOQBR"]
        self.lang = self.conf["default_language"]
        try:
            # Use folder name where this file is placed
            # (as Traxis, Fabrix, PurchaseMicroservice, etc) as a tag
            folder_name = os.path.basename(os.path.dirname(os.path.realpath(__file__)))
            BuiltIn().set_test_variable("${ENDPOINT_TAG}", "%s" % folder_name)
        except RobotNotRunningError:
            pass

    def get_session_recording_response(self, customer_id, recording_id):
        """Sends POST request to the session-service to get details of the recorded program.

        :param customer_id: a customer ID, e.g. "d4a54b70-7b42-11e7-bb50-31a18ae14f28_nl".
        :param recording_id: a program ID,
        e.g. "crid:~~2F~~2Fbds.tv~~2F172858925,imi:00100000000CD50D".

        :return: an http response instance.
        """
        if "_" not in customer_id:
            customer_id = "%s_%s" % (customer_id, self.lang)
        url = "%s/session/customers/%s/recordings/%s" % (self.base_url, customer_id, recording_id)
        headers = {
            "x-cus": customer_id
        }
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.post(url, headers=headers)
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send POST %s due to %s" % (url, err)))
            response = failed_response_data("POST", url, None, err)
        return response

    def get_session_replay_response(self, cpe, event):
        """Sends POST request to the session-service to get replay details.

        :param cpe: a CPE ID, e.g. "d4a54b70-7b42-11e7-bb50-31a18ae14f28_nl".
        :param event: an event ID, e.g. "crid:~~2F~~2Fbds.tv~~2F172858925,imi:00100000000CD50D".

        :return: an http response instance.
        """
        url = "%s/session/cpes/%s/replay/events/%s" % (self.base_url, cpe, event)
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.post(url)
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send POST %s due to %s" % (url, err)))
            response = failed_response_data("POST", url, None, err)
        return response

    def get_session_review_channel(self, channel, start):
        """Sends POST request to the session-service to get session data with the streaming details.

        :param channel: a replay channel ID, e.g. "0020".
        :param start: a start time, e.g. "2017-10-19T15:20:42Z".

        :return: an HTTP response instance.
        """
        url = "%s/session/channels/%s?startTime=%s" % (self.base_url, channel, start)
        headers = {"Content-Type": "application/json", "Cache-Control": "no-cache"}
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.post(url, headers=headers)
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send POST %s due to %s" % (url, err)))
            response = failed_response_data("POST", url, None, err)
        return response

    def get_session_service_info(self):
        """A method sends GET request to get the information about session Microservice
        A text of Session Microservice response is a json string.

        :return: an HTTP response instance
        """
        url = "%s/info" % self.base_url
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

    def get_hollow_data(self, channel_id, data_type):
        """This method send GET request to get the hollow data via session service
        :param data_type: Data type e.g. Channel, Content, Event etc.
        :param channel_id: Id of the channel

        :return an HTTP response instance of hollow data in json format.
        """
        url = "%s/hollow-explorer/type" % self.base_url
        parameters = {'type': data_type, 'key': channel_id,
                      'display': 'json'}
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
        return response


class Keywords(object):
    """Keywords visible in Robot Framework."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @staticmethod
    def get_oboqbr_session_review_channel(conf, channel, start):
        """Sends POST request to the session-service to get session data with the streaming details.

        :param conf: a dictionary containing lab configuration settings.
        :param channel: a review channel ID, e.g. "0020".
        :param start: a start time string (in the past, UTC - 30 min, e.g. "2017-10-23T09:19:51Z").

        :return: an HTTP response instance.
        """
        ss_obj = SessionMicroserviceRequests(conf)
        response = ss_obj.get_session_review_channel(channel, start)
        return response

    @staticmethod
    def get_session_recording_response(conf, **kwargs):
        """Sends POST request to the session-service to get details of the recorded program.

        :param conf: a dictionary containing lab configuration settings.
        :param customer_id: a customer ID, e.g. "d4a54b70-7b42-11e7-bb50-31a18ae14f28_nl".
        :param recording_id: a program ID,
        e.g. "crid:~~2F~~2Fbds.tv~~2F172858925,imi:00100000000CD50D".

        :return: an HTTP response instance.
        """
        customer_id = kwargs["customer_id"]
        recording_id = kwargs["recording_id"]
        ss_obj = SessionMicroserviceRequests(conf)
        response = ss_obj.get_session_recording_response(customer_id, recording_id)
        return response

    @staticmethod
    def get_session_replay_response(conf, cpe, event):
        """Sends POST request to the session-service to get replay details.

        :param conf: a dictionary containing lab configuration settings.
        :param cpe: a CPE ID, e.g. "d4a54b70-7b42-11e7-bb50-31a18ae14f28_nl".
        :param event: an event ID, e.g. "crid:~~2F~~2Fbds.tv~~2F172858925,imi:00100000000CD50D".

        :return: an HTTP response instance.
        """
        ss_obj = SessionMicroserviceRequests(conf)
        response = ss_obj.get_session_replay_response(cpe, event)
        return response

    @staticmethod
    def get_session_service_info(conf):
        """Sends request to get information about session-service.

        :param conf: a dictionary containing lab configuration settings.

        :return: an HTTP JSON response instance.
        """
        ss_obj = SessionMicroserviceRequests(conf)
        response = ss_obj.get_session_service_info()
        return response

    @staticmethod
    def get_hollow_data(conf, channel_id, data_type="Channel"):
        """Sends request to get information about hollow data via session-service.
        :param conf: a dictionary containing lab configuration settings.
        :param data_type: Data type e.g. Channel, Content, Event etc.
        :param channel_id: Id of the channel

        :return an HTTP response instance of hollow data in json format.
        """
        ss_obj = SessionMicroserviceRequests(conf)
        response = ss_obj.get_hollow_data(channel_id, data_type)
        return response
