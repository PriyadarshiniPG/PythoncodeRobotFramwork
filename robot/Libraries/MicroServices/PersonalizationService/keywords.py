# pylint: disable=W0703
# pylint: disable=W0102
"""Implementation of Personalization Microservice for HZN 4
v0.0.1 - Anuj Teotia :  Added function get_profile_id
v0.0.2 - Fernando Cobos :  ONEMT Integration: Added function
         reset_recently_used_apps_via_personalization_service
         + Keyword: get_pin_via_personalization_service,
         get_favourite_channels_via_personalization_service,
         get_available_profiles_name_via_personalization_service,
         reset_recently_used_apps_via_personalization_service
         Not UNIT Tests created yet - keywords NOT tested
v0.0.3 - Shilpa Thorat : Added function get_available_genres
         UNIT Tests not created yet.
v0.0.4 - Anuj Teotia : Added get_customer_information_by_device_id function
         and refactored existing functions for customer Id
"""
import json
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


class PersonalizationServiceRequests(object):
    """Class handling all functions relating
    to making Personalization Service requests
    """
    def __init__(self, conf):
        """"Class initializer.
        :param conf: config file for labs
        """
        self.base_path = "http://{}/personalization-service"\
            .format(conf["MICROSERVICES"]["OBOQBR"])
        try:
            # Use folder name where this file is placed
            # (as Traxis, Fabrix, PurchaseMicroservice, etc) as a tag
            folder_name = os.path.basename(os.path.dirname(os.path.realpath(__file__)))
            BuiltIn().set_suite_variable("${ENDPOINT_TAG}", "%s" % folder_name)
        except RobotNotRunningError as err:
            BuiltIn().log("Exception message: %s - Ignoring and continue" % err)

    def get_profile_id(self, customer_id):
        """A function to return the profile Id.
        :param customer_id : customer id for the device
        :return: result of requests.get() or failed_response_data() if request failed.
        """
        url = "{}/v1/customer/{}/profiles".format(self.base_path, customer_id)
        headers = {'accept': "application/json", 'X-cus': customer_id}
        BuiltIn().log("Url={} and headers={}".format(url, headers))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError as err:
            BuiltIn().log("Exception message: %s - Ignoring and continue" % err)
        try:
            response = requests.get(url, headers=headers)
            if response.status_code != 200:
                BuiltIn().log_to_console("Send GET to %s Status code: %s, Reason: %s"
                                         % (url, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

    def get_profiles_and_devices(self, customer_id):
        """A function to return the profile Id.
        :param customer_id : customer id for the device
        :return: result of requests.get() or failed_response_data() if request failed.
        """
        url = "{}/v1/customer/{}?with=profiles,devices".format(self.base_path, customer_id)
        headers = {'accept': "application/json", 'X-cus': customer_id}
        BuiltIn().log("Url={} and headers={}".format(url, headers))
        try:
            BuiltIn().set_suite_variable("${URL_PATH}", "%s" %
                                         urllib.parse.urlparse(url).path)
        except RobotNotRunningError as err:
            BuiltIn().log("Exception message: %s - Ignoring and continue" % err)
        try:
            response = requests.get(url, headers=headers)
            if response.status_code != 200:
                BuiltIn().log_to_console("Send GET to %s Status code: %s, Reason: %s"
                                         % (url, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

    def reset_recently_used_apps_via_personalization_service(self, customer_id, profile_id):
        """Resets the recently used applications using personalization service
        :param customer_id : customer id for the device
        :param profile_id : profile id for the customer
        :return: result of requests.put() or failed_response_data() if request failed.
        """
        url = "{}/v1/customer/{}/profiles/{}".format(self.base_path, customer_id, profile_id)
        headers = {'accept': "application/json", 'X-cus': customer_id}
        body = {'recentlyUsedApps': []}
        BuiltIn().log("Url={} and headers={} and body={}".format(url, headers, body))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError as err:
            BuiltIn().log("Exception message: %s - Ignoring and continue" % err)

        try:
            response = requests.put(url, json=body, headers=headers)
            # TODO - Check why status code 204 and not 200
            if response.status_code != 204:
                BuiltIn().log_to_console("Send PUT to %s Status code: %s, Reason: %s"
                                         % (url, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send PUT %s due to %s" % (url, err)))
            response = failed_response_data("PUT", url, body, err)
        return response

    def get_available_genres(self, language):
        """Retrieves available genres for selected language using personalization service
        :return: result of requests.get() or failed_response_data() if request failed.
        """
        url = "{}/v2/commons/availableGenres?language={}".format(self.base_path, language)
        headers = {'accept': "application/json", 'charset': "utf-8"}
        BuiltIn().log("Url={} and headers={}".format(url, headers))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError as err:
            BuiltIn().log("Exception message: %s - Ignoring and continue" % err)

        try:
            response = requests.get(url, headers=headers)
            if response.status_code != 200:
                BuiltIn().log_to_console("Send GET to %s Status code: %s, Reason: %s"
                                         % (url, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

    def get_customer_information_by_device_id(self, cpe_id):
        """A function to retrieve customer information by device Id.
        :param cpe_id: device Id
        :return: result of requests.get() or failed_response_data() if request failed.
        """
        url = "{}/v1/customer".format(self.base_path)
        headers = {'accept': "application/json"}
        parameters = {'byDeviceId': cpe_id}
        BuiltIn().log("Url={}, headers={} and parameters={}".format(url, headers, parameters))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError as err:
            BuiltIn().log("Exception message: %s - Ignoring and continue" % err)
        try:
            response = requests.get(url, params=parameters, headers=headers)
            if response.status_code != 200:
                BuiltIn().log_to_console("Send GET to %s Status code: %s, Reason: %s"
                                         % (url, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

    def create_profile(self, customer_id, profile_name, profile_color, personal_lineup=[]):
        """A function to create a profile for a specific customer(customer_id).
        :param customer_id : Customer id of the customer.
        :param profile_name : name of the new profile
        :param profile_color : color of the new profile
        :return: profile id of the newly created profile or failed_response_data() if request failed.
        """
        url = "{}/v1/customer/{}/profiles".format(self.base_path, customer_id)
        headers = {'Content-type': 'application/json', 'X-cus': customer_id}
        data = {"name": profile_name, "colour": profile_color, "favoriteChannels": personal_lineup}
        json_data = json.dumps(data)
        BuiltIn().log("Url={}, headers={} and data={}".format(url, headers, data))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError as err:
            BuiltIn().log("Exception message: %s - Ignoring and continue" % err)
        try:
            response = requests.post(url, data=json_data, headers=headers)
            if response.status_code != 200:
                BuiltIn().log_to_console("Send POST to %s Status code: %s, Reason: %s"
                                         % (url, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send POST %s due to %s" % (url, err)))
            response = failed_response_data("POST", url, None, err)
        return response


class Keywords(object):
    """"Keywords visible in Robot Framework"""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @staticmethod
    def get_profile_id(conf, customer_id):
        """A keyword to return the VOD structure.
        :param conf: config file for labs
        :param customer_id: the customer Id for CPE
        :return: result of requests.get() or failed_response_data() if request failed.
        """
        ps_obj = PersonalizationServiceRequests(conf)
        response = ps_obj.get_profile_id(customer_id)
        return response

    @staticmethod
    def get_pin_via_personalization_service(conf, customer_id):
        """
        Get STB PIN via personalization service
        :param conf: config file for labs
        :param customer_id: the customer Id for CPE
        :return: customer profile names from personalization service
        """
        ps_obj = PersonalizationServiceRequests(conf)
        customer_cpe_profile = ps_obj.get_profiles_and_devices(customer_id)
        customer_cpe_profile_json = json.loads(customer_cpe_profile.text)
        # BuiltIn().log_to_console("get_pin_via_personalization_service"
        #                          " - customer_cpe_profile: JSON %s \n" %
        #                          customer_cpe_profile_json)
        return customer_cpe_profile_json['pin']

    @staticmethod
    def get_favourite_channels_via_personalization_service(conf, customer_id, profile_name):
        """
        Get the list of favourite channels for the specified profile name
        :param conf: config file for labs
        :param customer_id: the customer Id for CPE
        :param profile_name: The name of the profile
        :return: customer profile names from personalization service
        """
        ps_obj = PersonalizationServiceRequests(conf)
        customer_cpe_profile = ps_obj.get_profiles_and_devices(customer_id)
        customer_cpe_profile_json = json.loads(customer_cpe_profile.text)
        for profile in customer_cpe_profile_json['profiles']:
            if profile['name'] == profile_name:
                return profile['favoriteChannels']

        raise KeyError(
            'Unable to find {} in the list of profiles'.format(profile_name))

    @staticmethod
    def get_available_profiles_name_via_personalization_service(conf, customer_id):
        """
        Get the list of available profiles name on STB
        :param conf: config file for labs
        :param customer_id: the customer Id for CPE
        :return: customer profile names from personalization service
        """
        ps_obj = PersonalizationServiceRequests(conf)
        customer_cpe_profile = ps_obj.get_profiles_and_devices(customer_id)
        customer_cpe_profile_json = json.loads(customer_cpe_profile.text)
        profile_name_list = []
        for profile in customer_cpe_profile_json["profiles"]:
            profile_name_list.append(profile["name"])
        return profile_name_list

    @staticmethod
    def reset_recently_used_apps_via_personalization_service(conf, customer_id, profile_id):
        """Resets the recently used applications using personalization service
        :param conf: config file for labs
        :param customer_id: the customer Id for CPE
        :param profile_id : profile id for the customer
        :return: result of requests.put() or failed_response_data() if request failed.
        """
        ps_obj = PersonalizationServiceRequests(conf)
        response = ps_obj.reset_recently_used_apps_via_personalization_service(customer_id,
                                                                               profile_id)
        return json.loads(response.text)

    @staticmethod
    def get_cityid_via_personalization_service(conf, customer_id):
        """
        Get STB PIN via personalization service
        :param conf: config file for labs
        :param customer_id: the customer Id for CPE
        :return: customer profile names from personalization service
        """
        ps_obj = PersonalizationServiceRequests(conf)
        customer_cpe_profile = ps_obj.get_profiles_and_devices(customer_id)
        customer_cpe_profile_json = json.loads(customer_cpe_profile.text)
        # BuiltIn().log_to_console("get_pin_via_personalization_service"
        #                          " - customer_cpe_profile: JSON %s \n" %
        #                          customer_cpe_profile_json)
        return customer_cpe_profile_json['cityId']

    @staticmethod
    def get_profile_details_via_personalization_service(conf, customer_id):
        """
        Get the available profile details on STB
        :param conf: config file for labs
        :param customer_id: the customer Id for CPE
        :return: customer profile details from personalization service
        """
        ps_obj = PersonalizationServiceRequests(conf)
        customer_cpe_profile = ps_obj.get_profiles_and_devices(customer_id)
        customer_cpe_profile_json = json.loads(customer_cpe_profile.text)
        return customer_cpe_profile_json

    @staticmethod
    def get_available_genres(conf, language):
        """
        Get the list of available genres for selected language name
        :param conf: config file for labs
        :param language: the language provided by Jenkins
        :return: genre names available from personalization service
        """
        ps_obj = PersonalizationServiceRequests(conf)
        profile_genres = ps_obj.get_available_genres(language)
        profile_genres_json = json.loads(profile_genres.text)
        genre_name_list = []
        for genres in profile_genres_json:
            genre_name_list.append(genres["name"])
        return genre_name_list

    @staticmethod
    def get_customer_information_by_device_id(conf, cpe_id):
        """A function to retrieve customer information by device Id.
        :param conf: config file for labs
        :param cpe_id: device Id
        :return: result of requests.get() or failed_response_data() if request failed.
        """
        ps_obj = PersonalizationServiceRequests(conf)
        response = ps_obj.get_customer_information_by_device_id(cpe_id)
        return response

    @staticmethod
    def create_profile(conf, customer_id, profile_name, profile_color, personal_lineup=[]):
        """A function to create a profile via customer id.
        :param conf: config file for labs
        :param customer_id : Customer id of the customer.
        :param profile_name : name of the new profile
        :param profile_color : color of the new profile
        :return: profile id of the newly created profile or failed_response_data() if request failed.
        """
        ps_obj = PersonalizationServiceRequests(conf)
        response = ps_obj.create_profile(customer_id, profile_name, profile_color, personal_lineup)
        return response
    