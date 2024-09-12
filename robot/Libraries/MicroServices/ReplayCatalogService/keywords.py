"""
Implementation of Replay Catalog Microservice library's keywords for Robot Framework.

v0.0.1 - Anuj Teotia: Initial Replay Catalog Microservice library.
v0.0.2 - Anuj Teotia: added get_replay_catalog_programs method.
v0.0.3 - Anuj Teotia: Added get_replay_channels method.
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
                request=type("", (), dict(method=req_method, url=req_url, body=req_body))())
    return type("", (), data)()


class ReplayCatalogServiceRequests(object):
    """A class to handle requests to Replay Catalog Microservice."""

    def __init__(self, lab_conf):
        """The class initializer.

        :param lab_conf: the conf dictionary, containig Microservice settings.
        """
        self.conf = lab_conf
        self.main_url = "http://%s" % self.conf["MICROSERVICES"]["OBOQBR"]

        try:
            # Use folder name where this file is placed
            folder_name = os.path.basename(os.path.dirname(os.path.realpath(__file__)))
            BuiltIn().set_test_variable("${ENDPOINT_TAG}", "%s" % folder_name)
        except RobotNotRunningError:
            pass

    def get_replay_catalog_programs(self, profile_id, language, city_id, page):
        """A method sends GET request to Replay Catalog Microservice to obtain
            data about programs.
        :param profile_id: the profile id of the customer.
        :param language: language for replay catalog e.g. "en".
        :param city_id: city Id for the customer.
        :param: page: page number on which you want to find the asset.

        :return: a dictionary loaded from the Replay Catalog Microservice response text.
        """
        url = "%s/replay-catalog-service/programs" % self.main_url
        parameters = {'language': language, 'cityId': city_id,
                      'profileId': profile_id, 'maxRes': "4K",
                      'sort': "popularity", "page": page}
        BuiltIn().log("Url={} and Parameters={}".format(url, parameters))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass
        try:
            response = requests.get(url, params=parameters)
            if response.status_code != 200:
                BuiltIn().log_to_console("To get_replay_catalog_programs we send GET to %s\n"
                                         "parameters: %s. Status code: %s. Reason: %s\n"
                                         % (url, parameters, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

    def get_replay_channels(self, language, city_id):
        """A method sends GET request to Replay Catalog Microservice to obtain
            data about programs.
        :param language: language for replay catalog e.g. "en".
        :param city_id: city Id for the customer.

        :return: a dictionary loaded from the Replay Catalog Microservice response text.
        """
        url = "%s/replay-catalog-service/channels" % self.main_url
        parameters = {'language': language, 'cityId': city_id,
                      'maxRes': "4K"}
        BuiltIn().log("Url={} and Parameters={}".format(url, parameters))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass
        try:
            response = requests.get(url, params=parameters)
            if response.status_code != 200:
                BuiltIn().log_to_console("To get_replay_catalog_programs we send GET to %s\n"
                                         "parameters: %s. Status code: %s. Reason: %s\n"
                                         % (url, parameters, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

    def get_most_relevant_instance(self, program_id, language, city_id, event_type,
                                   channel_id, provider_id, day_start, profile_id, genre_id):
        """A method to GET the most relevant instance for the program_id passed
        :param language: language for replay catalog e.g. "en".
        :param city_id: city Id for the customer.
        :param language: language for replay catalog e.g. "en".
        :param program_id: event id
        :param city_id: city Id for the customer.
        :param event_type: type of an asset e.g. "show".
        :param channel_id: channel id in which the event is played
        :param provider_id: providerId
        :param day_start: dayStart
        :param profile_id: the profile id string to get the most relevant instance
        :param genre_id: id of a genre

        :return: a dictionary loaded from a response text returned by Replay Catalog Microservice.
        """
        url = "%s/replay-catalog-service/mostrelevantinstance" % self.main_url
        parameters = {'programId': program_id, 'type': event_type, 'language': language,
                      'cityId': city_id, 'maxRes': "4K", 'channelId': channel_id,
                      'providerId': provider_id, 'dayStart': day_start,
                      'profileId': profile_id, 'genreId': genre_id}
        BuiltIn().log("Url={} and Parameters={}".format(url, parameters))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass
        try:
            response = requests.get(url, params=parameters)
            if response.status_code != 200:
                BuiltIn().log_to_console("To get_replay_catalog_programs we send GET to %s\n"
                                         "parameters: %s. Status code: %s. Reason: %s\n"
                                         % (url, parameters, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response



class Keywords(object):
    """Keywords visible in Robot Framework."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @staticmethod
    def get_replay_catalog_programs(lab_conf, profile_id, language, city_id, page):
        """A keyword to obtain replay programs from Replay Catalog Microservice
            for given profile id.

        :param lab_conf: the conf dictionary, containing Microservice settings.
        :param profile_id: the profile id of the customer.
        :param language: language for replay catalog e.g. "en".
        :param city_id: city Id for the customer.
        :param page: page number on which you want to find the asset.

        :return: a dictionary loaded from a response text returned by Replay Catalog Microservice.
        """
        rcs_obj = ReplayCatalogServiceRequests(lab_conf)
        result = rcs_obj.get_replay_catalog_programs(profile_id, language, city_id, page)
        return result

    @staticmethod
    def get_replay_channels(lab_conf, language, city_id):
        """A keyword to obtain replay programs from Replay Catalog Microservice
            for given profile id.

        :param lab_conf: the conf dictionary, containing Microservice settings.
        :param language: language for replay catalog e.g. "en".
        :param city_id: city Id for the customer.

        :return: a dictionary loaded from a response text returned by Replay Catalog Microservice.
        """
        rcs_obj = ReplayCatalogServiceRequests(lab_conf)
        result = rcs_obj.get_replay_channels(language, city_id)
        return result

    @staticmethod
    def get_most_relevant_instance(lab_conf, program_id, language, city_id, event_type,
                                   channel_id=None, provider_id=None, day_start=None,
                                   profile_id=None, genre_id=None):
        """A keyword to obtain replay programs from Replay Catalog Microservice
            for given profile id.

        :param lab_conf: the conf dictionary, containing Microservice settings.
        :param language: language for replay catalog e.g. "en".
        :param program_id: event id
        :param city_id: city Id for the customer.
        :param event_type: type of an asset e.g. "show".
        :param channel_id: channel id in which the event is played
        :param provider_id: providerId
        :param day_start: dayStart
        :param profile_id: the profile id string to get the most relevant instance
        :param genre_id: id of a genre

        :return: a dictionary loaded from a response text returned by Replay Catalog Microservice.
        """
        rcs_obj = ReplayCatalogServiceRequests(lab_conf)
        result = rcs_obj.get_most_relevant_instance(program_id, language, city_id, event_type,
                                                    channel_id, provider_id,
                                                    day_start, profile_id, genre_id)
        return result
