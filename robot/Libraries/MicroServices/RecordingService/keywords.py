# pylint: disable=invalid-name, W0703
# Disabled pylint "invalid-name" complaining on some keywords (name length > 30),
# but shortening the name will affect the sense of what the keyword is doing.
"""Implementation of Recording Microservice library's keywords for Robot Framework.
v0.0.1 - Fernando Cobos: Initial Recording Microservice library's
v0.0.2 - Fernando Cobos: add Keyword get_customers_bookings
v0.0.3 - Natallia Savelyeva: added keywords to schedule and delete recordings.
v0.0.4 - Vishwanand Upadhyay: added keywords get_quota, get_simple_recordings_discovery,
         get_recording_service_info, get_contextual_recordings, get_simple_recordings.
v0.0.5 - Vishwanand Upadhyay: added keyword get_customer_collections
v0.0.6 - Nidhi Tiwari: Added keywords get_recording_service_health_check
         and get_recorded_recording_data
v0.0.7 - Anuj Teotia : added keyword get_details_of_recording and
         get_simple_recordings_full_response
v0.0.8 - Anuj Teotia: Added keyword cancel_recording
v0.0.9 - Anuj Teotia : added keyword schedule_recording_show,
         get_list_of_episodes_season, get_list_of_episodes_show,
         set_bookmark_single_recording, set_view_state_single_recording
v0.0.10 - Anuj Teotia : added keyword get_recorded_recordings
v0.0.11 - Ankita Agrawal : added keyword delete_booking
v0.0.12 - Vishwa : Updated methods get_recorded_recordings and get_details_of_recording
"""
import os
import socket
import json
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


def http_send(method, url, data=None, headers=None):
    """Send HTTP GET/POST request and use try-except block for any error handling

    :param method: an HTTP method, e.g. "POST".
    :param url: a url used to send the request.
    :param data: a string of data sent (if any).
    :param headers: header to be sent with the request.

    :return: an HTTP response instance.
    """
    try:
        BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                    urllib.parse.urlparse(url).path)
    except RobotNotRunningError:
        pass

    try:
        if method == "GET":
            response = requests.get(url, headers=headers)
        elif method == "POST":
            response = requests.post(url, data=data, headers=headers)
    except (requests.exceptions.ConnectionError, socket.gaierror) as err:
        print(("Could not send %s %s due to %s" % (method, url, err)))
        response = failed_response_data("GET", url, None, err)
    return response


class RecordingMicroserviceRequests(object):
    """A class to handle requests to Recording Microservice."""

    def __init__(self, lab_conf, customer_id=""):
        """The class initializer.

        :param lab_conf: the conf dictionary, containig Microservice settings.
        :param customer_id: the id of CUSTOMER ID, e.g. "3256f840-4d12-11e7-85f5-e5a72ae6734d_nl".
        """
        try:
            self.conf = lab_conf
            self.main_url = "http://%s" % self.conf["MICROSERVICES"]["OBOQBR"]
            self.lang = self.conf["default_language"]
            if customer_id != "" and "_" not in customer_id:
                self.customer_id = "%s_%s" % (customer_id, self.lang)
            else:
                self.customer_id = customer_id
            self.valid_response_codes = [200, 201]

            # Use folder name where this file is placed
            # (as Traxis, Fabrix, PurchaseMicroservice, etc) as a tag
            folder_name = os.path.basename(os.path.dirname(os.path.realpath(__file__)))
            BuiltIn().set_test_variable("${ENDPOINT_TAG}", "%s" % folder_name)
        except Exception as err:
            BuiltIn().log("Exception message: %s - Ignoring and continue" % err.args[0])

    def get_customers_recordings(self):
        """A method sends GET request to Recording Microservice to obtain data about recordings.
        A text of Recording Microservice response is a json string.

        :return: a dictionary loaded from the Recording Microservice response text.
        """
        url = "%s/recording-service/customers/%s/recordings" % (self.main_url, self.customer_id)

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
        struct = json.loads(response.text)
        return struct

    def get_customers_contextual_recordings(self):
        """A method sends GET request to Recording Microservice
        to obtain data about contextual recordings.
        A text of Recording Microservice response is a json string.

        :return: an HTTP response instance.
        """
        url = "%s/recording-service/customers/%s/recordings/contextual" % (self.main_url,
                                                                           self.customer_id)
        response = http_send("GET", url)
        if response.status_code != 200:
            BuiltIn().log_to_console("To get_customers_contextual_recordings we send GET to %s\n"
                                     "Status code: %s. Reason: %s\n"
                                     % (url, response.status_code, response.reason))
        return response

    def get_simple_recordings(self):
        """A method sends GET request to Recording Microservice
        to obtain data about simple recordings.
        A text of Recording Microservice response is a json string.

        :return: an HTTP response instance.
        """
        url = "%s/recording-service/customers/%s/recordings/simple" % (self.main_url,
                                                                       self.customer_id)
        response = http_send("GET", url)
        if response.status_code != 200:
            BuiltIn().log_to_console("To get_simple_recordings we send GET to %s\nStatus code: %s. "
                                     "Reason: %s\n"
                                     % (url, response.status_code, response.reason))
        struct = json.loads(response.text)
        return struct

    def get_simple_recordings_discovery(self):
        """A method sends GET request to Recording Microservice
        to obtain data about simple recordings(discovery).
        A text of Recording Microservice response is a json string.

        :return: an HTTP response instance.
        """
        url = "%s/recording-service/discovery-service/customers/%s/recordings/simple" % \
              (self.main_url, self.customer_id)
        response = http_send("GET", url)
        if response.status_code != 200:
            BuiltIn().log_to_console("To get_simple_recordings_discovery we send GET to %s\n"
                                     "Status code: %s. Reason: %s\n"
                                     % (url, response.status_code, response.reason))
        return response

    def get_customers_bookings(self, is_adult):
        """A method sends GET request to Recording Microservice to obtain data about bookings.
        A text of Recording Microservice response is a json string.
        See also https://wikiprojects.upc.biz/display/HZN4/Tech-Note%3A+VRM+new+API

        :return: a dictionary loaded from the Recording Microservice response text.
        """
        url = "%s/recording-service/customers/%s/bookings?isAdult=%s" % \
              (self.main_url, self.customer_id, is_adult)
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        response = requests.get(url)
        if response.status_code != 200:
            BuiltIn().log_to_console("To get_customers_bookings we send GET to %s\n"
                                     "Status code: %s. Reason: %s\n"
                                     % (url, response.status_code, response.reason))
        struct = json.loads(response.text)
        return struct

    def execute_get_customers_bookings(self, is_adult):
        """A method sends GET request to Recording Microservice to obtain data about bookings.
        A text of Recording Microservice response is a json string.

        :return: :return: an HTTP response instance.
        """
        url = "%s/recording-service/customers/%s/bookings?isAdult=%s" % \
              (self.main_url, self.customer_id, is_adult)
        response = http_send("GET", url)
        if response.status_code != 200:
            BuiltIn().log_to_console("To execute_get_customers_bookings we send GET to %s\n"
                                     "Status code: %s. Reason: %s\n"
                                     % (url, response.status_code, response.reason))
        return response

    def schedule_recording_show(self, event_id, channel_id):
        """Sends POST request to "recording-service" to schedule a recording
        of the given event for the given customer.

        :param event_id: a program ID, e.g. "crid:~~2F~~2Fbds.tv~~2F172858925,imi:00100000000CD50D".

        :return: an HTTP response instance.
        """
        url = "%s/recording-service/customers/%s/bookings/show" % (self.main_url,
                                                                   self.customer_id)
        data = json.dumps({"eventId": event_id,
                           "channelId": channel_id, "pinProtected": False, "retentionLimit": 1})
        headers = {"Content-Type": "application/json"}
        BuiltIn().log("Url={} and parameters={}".format(url, data))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        response = requests.post(url, data=data, headers=headers)
        if response.status_code not in self.valid_response_codes:
            BuiltIn().log_to_console("To schedule_recording_show we send POST to %s\n"
                                     "Data:\n%s\nHeaders:\n%s\n\n"
                                     "Status code: %s. Reason: %s\n"
                                     % (url, data, headers, response.status_code, response.reason))
        return response

    def schedule_recording(self, event_id):
        """Sends POST request to "recording-service" to schedule a recording
        of the given event for the given customer.

        :param event_id: a program ID, e.g. "crid:~~2F~~2Fbds.tv~~2F172858925,imi:00100000000CD50D".

        :return: an HTTP response instance.
        """
        url = "%s/recording-service/customers/%s/bookings/single" % (self.main_url,
                                                                     self.customer_id)
        data = json.dumps({"eventId": event_id, "pinProtected": False, "retentionLimit": 1})
        headers = {"Content-Type": "application/json"}
        BuiltIn().log("Url={} and parameters={}".format(url, data))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        response = requests.post(url, data=data, headers=headers)
        if response.status_code not in self.valid_response_codes:
            BuiltIn().log_to_console("To schedule_recording we send POST to %s\n"
                                     "Data:\n%s\nHeaders:\n%s\n\n"
                                     "Status code: %s. Reason: %s\n"
                                     % (url, data, headers, response.status_code, response.reason))
        return response

    def delete_recording(self, event_id):
        """Sends POST request to "recording-service" to schedule a recording
        of the given event for the given customer.

        :param event_id: a program ID, e.g. "crid:~~2F~~2Fbds.tv~~2F172858925,imi:00100000000CD50D".

        :return: an HTTP response instance.
        """
        url = "%s/recording-service/customers/%s/recordings/single/%s" \
              % (self.main_url, self.customer_id, event_id)
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except Exception as err:
            BuiltIn().log("Exception message: %s - Ignoring and continue" %  err.args[0])
        try:
            response = requests.delete(url)
            if response.status_code != 204:
                BuiltIn().log_to_console("To delete_recording we send DELETE to %s\n"
                                         "Status code: %s. Reason: %s\n"
                                         % (url, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send DELETE %s due to %s" % (url, err)))
            response = failed_response_data("DELETE", url, None, err)
        return response

    def get_recording_service_info(self):
        """A method sends GET request to Recording Microservice to obtain recordings service info.

        :return: an HTTP response instance.
        """
        url = "%s/recording-service/info" % self.main_url
        response = http_send("GET", url)
        if response.status_code != 200:
            BuiltIn().log_to_console("To get_recording_service_info we send GET to %s\n"
                                     "Status code: %s. Reason: %s\n"
                                     % (url, response.status_code, response.reason))
        return response

    def get_customers_quota(self):
        """A method sends GET request to Recording Microservice
        to obtain data about customer's quota.
        A text of Recording Microservice response is a json string.

        :return: an HTTP response instance.
        """
        url = "%s/recording-service/customers/%s/quota" % (self.main_url, self.customer_id)
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except Exception as err:
            BuiltIn().log("Exception message: %s - Ignoring and continue" %  err.args[0])

        response = requests.get(url)
        if response.status_code != 200:
            BuiltIn().log_to_console("To get_customers_quota we send GET to %s\n"
                                     "Status code: %s. Reason: %s\n"
                                     % (url, response.status_code, response.reason))
        return response

    def get_customer_collections(self):
        """A method sends GET request to Recording Microservice
        to obtain data about customer's collections.

         :return: an HTTP response instance.

         :TODO : Take language input dynamically
         """
        url = "%s/recording-service/customers/%s/collection?language=en" % (self.main_url,
                                                                            self.customer_id)
        response = http_send("GET", url)
        if response.status_code != 200:
            BuiltIn().log_to_console("To get_customer_collections we send GET to %s\n"
                                     "Status code: %s. Reason: %s\n"
                                     % (url, response.status_code, response.reason))
        return response

    def get_recording_service_health_check(self):
        """A method sends GET request to Recording Microservice to obtain data about heath
        status of MQTT, Nokia Enhanced API, Nokia VRM, RENG, Traxis and deadlocks.
        A text of Recording Microservice response is a json string.

        :return: An HTTP response instance returned from the Recording Microservice with JSON test
        """
        url = "%s/recording-service/health-checks" % (self.main_url)
        response = http_send("GET", url)
        if response.status_code != 200:
            BuiltIn().log_to_console("To get_recording_service_health_check we send GET to %s\n"
                                     "Status code: %s. Reason: %s\n"
                                     % (url, response.status_code, response.reason))
        return response

    def get_recorded_recording_data(self):
        """A method sends GET request to get recorded data from recording service
        for a valid customer.A text of Recording Microservice response
         is a json string.

        :return:An HTTP response instance returned from the Recording Microservice with JSON test
        """
        url = "%s/recording-service/customers/%s/recordings" % (self.main_url, self.customer_id)
        response = http_send("GET", url)
        if response.status_code != 200:
            BuiltIn().log_to_console("To get_recorded_recording_data we send GET to %s\n"
                                     "Status code: %s. Reason: %s\n"
                                     % (url, response.status_code, response.reason))
        return response

    def get_recording_state_for_events(self, cpe_id):
        """A method sends GET request to get state of recorded data from recording service
        for a valid customer.A text of Recording Microservice response
         is a json string.
        :param cpe_id : cpe id of the box
        :return:An HTTP response instance returned from the Recording Microservice with JSON test
        """
        url = "%s/recording-service/customers/%s/recordings/state" \
              % (self.main_url, self.customer_id)
        headers = {"Content-Type": "application/json", "X-Cus": self.customer_id, "X-Dev": cpe_id}
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        response = requests.get(url, headers=headers)
        if response.status_code != 200:
            BuiltIn().log_to_console("To get_recording_state_for_events we send GET to %s\n"
                                     "Status code: %s. Reason: %s\n"
                                     % (url, response.status_code, response.reason))
        return response

    def cancel_recording(self, crid_id):
        """Sends PUT request to "recording-service" to cancel a recording
        of the given event for the given customer.

        :param crid_id: a crid ID, e.g. "crid:~~2F~~2Fbds.tv~~2F172858925,imi:00100000000CD50D".

        :return: an HTTP response instance.
        """
        url = "%s/recording-service/customers/%s/recordings/single/cancel/%s" \
              % (self.main_url, self.customer_id, crid_id)
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        response = requests.put(url)
        if response.status_code != 204:
            BuiltIn().log_to_console("To cancel_recording we send PUT to %s\n"
                                     "Status code: %s. Reason: %s\n"
                                     % (url, response.status_code, response.reason))
        return response

    def get_details_of_recording(self, crid_id, language, cpe_id):
        """Sends GET request to "recording-service" to fetch recording details
        for the given customer and cred id

        :param crid_id: a crid ID, e.g. "crid:~~2F~~2Fbds.tv~~2F265800992,imi:001000000036FD55".
        :param cpe_id : cpe id of the box

        :return: an HTTP response instance.
        """
        url = "%s/recording-service/customers/%s/details/single/%s" \
              % (self.main_url, self.customer_id, crid_id)
        parameters = {'language': language}
        headers = {"Content-Type": "application/json", "X-Cus": self.customer_id, "X-Dev": cpe_id}
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        response = requests.get(url, params=parameters, headers=headers)
        if response.status_code != 200:
            BuiltIn().log_to_console("To get_details_of_recording we send GET to %s\n"
                                     "Status code: %s. Reason: %s\n"
                                     % (url, response.status_code, response.reason))
        return response

    def get_simple_recordings_full_response(self):
        """A method sends GET request to Recording Microservice
        to obtain data about simple recordings.
        A text of Recording Microservice response is a json string.

        :return: an HTTP response instance.
        """
        url = "%s/recording-service/customers/%s/recordings/simple" % (self.main_url,
                                                                       self.customer_id)
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        response = requests.get(url)
        if response.status_code != 200:
            BuiltIn().log_to_console("To get_simple_recordings_full_response we send GET to %s\n"
                                     "Status code: %s. Reason: %s\n"
                                     % (url, response.status_code, response.reason))
        return response

    def get_list_of_episodes_season(self, profile_id, season_id, language, source, limit, offset):
        """A method sends GET request to Recording Microservice
        to obtain list of episodes for a season.
        A text of Recording Microservice response is a json string.

        :return: an HTTP response instance.
        :param profile_id: profile identifier
        :param season_id: season identifier
        :param source: recording/booking
        :param language: language required
        :param offset: Used in paging, means how many entities should be skipped
        :param limit: number of assets to be returned
        """
        url = "%s/recording-service/customers/%s/episodes/seasons/%s?" \
              "profileId=%s&language=%s&isAdult=false&source=%s&limit=%s&offset=%s" \
              % (self.main_url, self.customer_id, season_id, profile_id, language, source, limit, offset)
        BuiltIn().log("Url is : {}".format(url))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        response = requests.get(url)
        if response.status_code != 200:
            BuiltIn().log_to_console("To get_list_of_episodes_season we send GET to %s\n"
                                     "Status code: %s. Reason: %s\n"
                                     % (url, response.status_code, response.reason))
        return response

    def get_list_of_episodes_show(self, profile_id, show_id, channel_id, language, source, cpe_id, limit, offset):
        """A method sends GET request to Recording Microservice
        to obtain list of episodes for a show.
        A text of Recording Microservice response is a json string.

        :param show_id: show identifier
        :param profile_id: profile identifier
        :param source: recording/booking
        :param language: language required
        :param channel_id: channel identifier
        :param offset: Used in paging, means how many entities should be skipped
        :param limit: number of assets to be returned
        :param cpe_id : cpe id of the box
        :return: an HTTP response instance.
        """
        url = "%s/recording-service/customers/%s/episodes/shows/%s?" \
              "profileId=%s&isAdult=false&source=%s&language=%s&offset=%s&limit=%s&channelId=%s" \
              % (self.main_url, self.customer_id, show_id, profile_id, source, language, offset, limit, channel_id)
        headers = {"Content-Type": "application/json", "X-Cus": self.customer_id, "X-Dev": cpe_id}
        BuiltIn().log("Url is : {}".format(url))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        response = requests.get(url, headers=headers)
        if response.status_code != 200:
            BuiltIn().log_to_console("To get_list_of_episodes_show we send GET to %s\n"
                                     "Status code: %s. Reason: %s\n"
                                     % (url, response.status_code, response.reason))
        return response

    def set_bookmark_single_recording(self, recording_id):
        """Sends POST request to "recording-service" to bookmark a recording
            of the given recording id for the given customer.
            :param recording_id: a recording ID,
            e.g. "crid:~~2F~~2Fbds.tv~~2F292574356,imi:6ebc7e067e0035a0e610fcee8a14d6fdf22019de".
            :return: an HTTP response instance.
            """
        url = "%s/recording-service/customers/%s/recordings/single/%s/bookmark" \
              % (self.main_url, self.customer_id, recording_id)
        data = json.dumps({"position": 0, "timestamp": 0})
        headers = {"Content-Type": "application/json"}
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        response = requests.put(url, data=data, headers=headers)
        if response.status_code != 200:
            BuiltIn().log_to_console("To set_bookmark_single_recording we send PUT to %s\n"
                                     "Data:\n%s\nHeaders:\n%s\n\n"
                                     "Status code: %s. Reason: %s\n"
                                     % (url, data, headers, response.status_code, response.reason))
        return response

    def set_view_state_single_recording(self, recording_id):
        """Sends POST request to "recording-service" to bookmark a recording
            of the given recording id for the given customer.
            :param recording_id: a recording ID,
            e.g. "crid:~~2F~~2Fbds.tv~~2F292574356,imi:6ebc7e067e0035a0e610fcee8a14d6fdf22019de".
            :return: an HTTP response instance.
            """
        url = "%s/recording-service/customers/%s/recordings/single/%s/view-state" \
              % (self.main_url, self.customer_id, recording_id)
        data = json.dumps({"viewState": "notWatched"})
        headers = {"Content-Type": "application/json"}
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        response = requests.put(url, data=data, headers=headers)
        if response.status_code != 200:
            BuiltIn().log_to_console("To set_view_state_single_recording we send PUT to %s\n"
                                     "Data:\n%s\nHeaders:\n%s\n\n"
                                     "Status code: %s. Reason: %s\n"
                                     % (url, data, headers, response.status_code, response.reason))
        return response

    def delete_all_recordings(self):
        """A method sends DELETE request to Recording Microservice
        to delete all recordings.
        A text of Recording Microservice response is a json string.

        :return: an HTTP response instance.
        """
        url = "%s/recording-service/customers/%s" % (self.main_url, self.customer_id)
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        response = requests.delete(url)
        if response.status_code != 200:
            BuiltIn().log_to_console("To delete_all_recordings we send DELETE to %s\n"
                                     "Status code: %s. Reason: %s\n"
                                     % (url, response.status_code, response.reason))
        return response

    def delete_all_recorded_recordings(self):
        """A method sends DELETE request to Recording Microservice
        to delete all recorded recordings.
        A text of Recording Microservice response is a json string.

        :return: an HTTP response instance.
        """
        url = "%s/recording-service/customers/%s/recordings" % (self.main_url, self.customer_id)
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        response = requests.delete(url)
        if response.status_code != 204:
            BuiltIn().log_to_console("To delete_all_recorded_recordings we send DELETE to %s\n"
                                     "Status code: %s. Reason: %s\n"
                                     % (url, response.status_code, response.reason))
        return response

    def delete_all_planned_recordings(self):
        """A method sends DELETE request to Recording Microservice
        to delete all planned recordings.
        A text of Recording Microservice response is a json string.

        :return: an HTTP response instance.
        """
        url = "%s/recording-service/customers/%s/bookings" % (self.main_url, self.customer_id)
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        response = requests.delete(url)
        if response.status_code != 204:
            BuiltIn().log_to_console("To delete_all_planned_recordings we send DELETE to %s\n"
                                     "Status code: %s. Reason: %s\n"
                                     % (url, response.status_code, response.reason))
        return response

    def get_recorded_recordings(self, language, profile_id, is_adult, limit, sort, sort_order, cpe_id):
        """A method sends GET request to get recorded data from recording service
        for a valid customer.A text of Recording Microservice response
         is a json string.

        :param is_adult: a boolean.
        :param sort: a boolean.
        :param profile_id: profile identifier
        :param limit:no:of recordings to be fetched
        :param cpe_id : cpe id of the box
        :param sort: for sorting the result
        :param sort_order: asc or desc order of sorting
        :return:An HTTP response instance returned from the Recording Microservice with JSON test
        """
        url = "%s/recording-service/customers/%s/recordings?isAdult=%s&limit=%s&" \
              "sort=%s&sortOrder=%s&language=%s&profileId=%s" % \
              (self.main_url, self.customer_id, is_adult, limit, sort, sort_order, language, profile_id)
        headers = {"Content-Type": "application/json", "X-Cus": self.customer_id, "X-Dev": cpe_id}
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except Exception as err:
            BuiltIn().log("Exception message: %s - Ignoring and continue" % err.args[0])

        response = requests.get(url, headers=headers)
        if response.status_code != 200:
            BuiltIn().log_to_console("To get_recorded_recordings we send GET to %s\n"
                                     "Status code: %s. Reason: %s\n"
                                     % (url, response.status_code, response.reason))
        return response

    def delete_booking(self, type_of_recording, event_id):
        """Sends DELETE request to "recording-service" to delete a single booking
        of the given event for the given customer.

        :param
            event_id: a program ID, e.g. "crid:~~2F~~2Fbds.tv~~2F172858925,imi:00100000000CD50D".
            type_of_recording: type of recording eg. single/show
        :return: an HTTP response instance.
        """
        url = "%s/recording-service/customers/%s/bookings/%s/%s" \
              % (self.main_url, self.customer_id, type_of_recording, event_id)
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        response = requests.delete(url)
        if response.status_code != 200:
            BuiltIn().log_to_console("To delete booking we send DELETE to %s\n"
                                     "Status code: %s. Reason: %s\n"
                                     % (url, response.status_code, response.reason))
        return response


class Keywords(object):
    """Keywords visible in Robot Framework."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @staticmethod
    def get_customers_recordings(lab_conf, customer_id):
        """A keyword to obtain recordings from Recording Microservice for the given CUSTOMER ID.

        :param lab_conf: the conf dictionary, containig Microservice settings.
        :param customer_id: e.g. "3256f840-4d12-11e7-85f5-e5a72ae6734d_nl".

        :return: a dictionary loaded from a response text returned by Recording Microservice.
        """
        rs_obj = RecordingMicroserviceRequests(lab_conf, customer_id)
        result = rs_obj.get_customers_recordings()
        return result

    @staticmethod
    def get_customers_bookings(lab_conf, customer_id, adult=False):
        """A keyword to obtain bookings from Recording Microservice for the given CUSTOMER ID.

        :param lab_conf: the conf dictionary, containing Microservice settings.
        :param customer_id: e.g. "3256f840-4d12-11e7-85f5-e5a72ae6734d_nl".
        :param adult: a boolean.

        :return: an HTTP response instance.
        """
        rs_obj = RecordingMicroserviceRequests(lab_conf, customer_id)
        result = rs_obj.get_customers_bookings(adult)
        return result

    @staticmethod
    def schedule_recording_show(lab_conf, customer_id, event_id, channel_id):
        """Sends POST request to "recording-service" to schedule a recording
        of the given event for the given customer.

        :param lab_conf: a dictionary containing lab configuration settings.
        :param customer_id: a customer ID, e.g. "d4a54b70-7b42-11e7-bb50-31a18ae14f28_nl".
        :param event_id: a program ID, e.g. "crid:~~2F~~2Fbds.tv~~2F172858925,imi:00100000000CD50D".

        :return: an HTTP response instance.
        """
        rs_obj = RecordingMicroserviceRequests(lab_conf, customer_id)
        response = rs_obj.schedule_recording_show(event_id, channel_id)
        return response

    @staticmethod
    def schedule_recording(lab_conf, customer_id, event_id):
        """Sends POST request to "recording-service" to schedule a recording
        of the given event for the given customer.

        :param lab_conf: a dictionary containing lab configuration settings.
        :param customer_id: a customer ID, e.g. "d4a54b70-7b42-11e7-bb50-31a18ae14f28_nl".
        :param event_id: a program ID, e.g. "crid:~~2F~~2Fbds.tv~~2F172858925,imi:00100000000CD50D".

        :return: an HTTP response instance.
        """
        rs_obj = RecordingMicroserviceRequests(lab_conf, customer_id)
        response = rs_obj.schedule_recording(event_id)
        return response

    @staticmethod
    def delete_recording(lab_conf, customer_id, event_id):
        """Sends POST request to "recording-service" to schedule a recording
        of the given event for the given customer.

        :param lab_conf: a dictionary containing lab configuration settings.
        :param customer_id: a customer ID, e.g. "d4a54b70-7b42-11e7-bb50-31a18ae14f28_nl".
        :param event_id: a program ID, e.g. "crid:~~2F~~2Fbds.tv~~2F172858925,imi:00100000000CD50D".

        :return: an HTTP response instance.
        """
        rs_obj = RecordingMicroserviceRequests(lab_conf, customer_id)
        response = rs_obj.delete_recording(event_id)
        return response

    @staticmethod
    def get_contextual_recordings(lab_conf, customer_id):
        """A keyword to obtain contextual recordings from Recording Microservice
        for the given CUSTOMER ID.

        :param lab_conf: the conf dictionary, containing Microservice settings.
        :param customer_id: e.g. "3256f840-4d12-11e7-85f5-e5a72ae6734d_nl".

        :return: an HTTP response instance.
        """
        rmr_obj = RecordingMicroserviceRequests(lab_conf, customer_id)
        return rmr_obj.get_customers_contextual_recordings()

    @staticmethod
    def get_simple_recordings(lab_conf, customer_id):
        """A keyword to obtain simple recordings from Recording Microservice
        for the given CUSTOMER ID.

        :param lab_conf: the conf dictionary, containing Microservice settings.
        :param customer_id: e.g. "3256f840-4d12-11e7-85f5-e5a72ae6734d_nl".

        :return: an HTTP response instance.
        """
        rmr_obj = RecordingMicroserviceRequests(lab_conf, customer_id)
        return rmr_obj.get_simple_recordings()

    @staticmethod
    def get_recording_service_info(lab_conf):
        """A keyword to obtain recording service info from Recording Microservice .

        :param lab_conf: the conf dictionary, containing Recording Microservice details.

        :return: an HTTP response instance.
        """
        return RecordingMicroserviceRequests(lab_conf).get_recording_service_info()

    @staticmethod
    def get_simple_recordings_discovery(lab_conf, customer_id):
        """A keyword to obtain simple recordings(discovery) from Recording Microservice
        for the given CUSTOMER ID.

        :param lab_conf: the conf dictionary, containing Microservice settings.
        :param customer_id: e.g. "3256f840-4d12-11e7-85f5-e5a72ae6734d_nl".

        :return: an HTTP response instance.
        """
        rmr_obj = RecordingMicroserviceRequests(lab_conf, customer_id)
        return rmr_obj.get_simple_recordings_discovery()

    @staticmethod
    def get_quota(lab_conf, customer_id):
        """A keyword to obtain quota of recordings from Recording Microservice
        for the given CUSTOMER ID.

        :param lab_conf: the conf dictionary, containing Microservice settings.
        :param customer_id: e.g. "3256f840-4d12-11e7-85f5-e5a72ae6734d_nl".

        :return: an HTTP response instance.
        """
        rmr_obj = RecordingMicroserviceRequests(lab_conf, customer_id)
        return rmr_obj.get_customers_quota()

    @staticmethod
    def execute_get_customers_bookings(lab_conf, customer_id, adult=False):
        """A keyword to obtain bookings from Recording Microservice for the given CUSTOMER ID.

        :param lab_conf: the conf dictionary, containing Microservice settings.
        :param customer_id: e.g. "3256f840-4d12-11e7-85f5-e5a72ae6734d_nl".
        :param adult: a boolean.

        :return: an HTTP response instance.
        """
        rmr_obj = RecordingMicroserviceRequests(lab_conf, customer_id)
        return rmr_obj.execute_get_customers_bookings(adult)

    @staticmethod
    def get_customer_collections(lab_conf, customer_id):
        """A keyword to obtain all collections from Recording Microservice
        for the given CUSTOMER ID.

        :param lab_conf: the conf dictionary, containing Microservice settings.
        :param customer_id: e.g. "3256f840-4d12-11e7-85f5-e5a72ae6734d_nl".

        :return: an HTTP response instance.
        """
        rmr_obj = RecordingMicroserviceRequests(lab_conf, customer_id)
        return rmr_obj.get_customer_collections()

    @staticmethod
    def get_recording_service_health_check(lab_conf):
        """A keyword to obtain obtain data about heath status of MQTT,
        Nokia Enhanced API, Nokia VRM, RENG, Traxis and deadlocks.
        :param lab_conf: the conf dictionary, containing Microservice settings.

        :return: an HTTP response instance.
        """
        rs_obj = RecordingMicroserviceRequests(lab_conf)
        response = rs_obj.get_recording_service_health_check()
        return response

    @staticmethod
    def get_recorded_recording_data(lab_conf, customer_id):
        """A keyword to obtain recorded data from recording service for a valid customer.
        :param lab_conf: the conf dictionary, containing Microservice settings.
        :param customer_id: e.g. "3256f840-4d12-11e7-85f5-e5a72ae6734d_nl".

        :return: an HTTP response instance.
        """
        rs_obj = RecordingMicroserviceRequests(lab_conf, customer_id)
        response = rs_obj.get_recorded_recording_data()
        return response

    @staticmethod
    def get_recording_state_for_events(lab_conf, customer_id, cpe_id):
        """A keyword to obtain state of recorded data from recording service for a valid customer.
        :param lab_conf: the conf dictionary, containing Microservice settings.
        :param customer_id: e.g. "3256f840-4d12-11e7-85f5-e5a72ae6734d_nl".
        :param cpe_id : cpe id of the box

        :return: an HTTP response instance.
        """
        rs_obj = RecordingMicroserviceRequests(lab_conf, customer_id)
        response = rs_obj.get_recording_state_for_events(cpe_id)
        return response

    @staticmethod
    def cancel_recording(lab_conf, customer_id, crid_id):
        """Sends PUT request to "recording-service" to cancel a recording
        of the given event for the given customer.

        :param lab_conf: a dictionary containing lab configuration settings.
        :param customer_id: a customer ID, e.g. "d4a54b70-7b42-11e7-bb50-31a18ae14f28_nl".
        :param crid_id: a crid ID, e.g. "crid:~~2F~~2Fbds.tv~~2F172858925,imi:00100000000CD50D".

        :return: an HTTP response instance.
        """
        rs_obj = RecordingMicroserviceRequests(lab_conf, customer_id)
        response = rs_obj.cancel_recording(crid_id)
        return response

    @staticmethod
    def get_details_of_recording(lab_conf, customer_id, recording_id, language, cpe_id):
        """Sends PUT request to "recording-service" to cancel a recording
        of the given event for the given customer.

        :param lab_conf: a dictionary containing lab configuration settings.
        :param customer_id: a customer ID, e.g. "d4a54b70-7b42-11e7-bb50-31a18ae14f28_nl".
        :param recording_id: a crid ID, e.g. "crid:~~2F~~2Fbds.tv~~2F172858925,imi:00100000000CD50D".
        :param language: language

        :return: an HTTP response instance.
        """

        rs_obj = RecordingMicroserviceRequests(lab_conf, customer_id)
        response = rs_obj.get_details_of_recording(recording_id, language, cpe_id)
        return response

    @staticmethod
    def get_simple_recordings_full_response(lab_conf, customer_id):
        """A keyword to obtain simple recordings from Recording Microservice
        for the given CUSTOMER ID.

        :param lab_conf: the conf dictionary, containing Microservice settings.
        :param customer_id: e.g. "3256f840-4d12-11e7-85f5-e5a72ae6734d_nl".

        :return: an HTTP response instance.
        """
        rmr_obj = RecordingMicroserviceRequests(lab_conf, customer_id)
        return rmr_obj.get_simple_recordings_full_response()

    @staticmethod
    def get_list_of_episodes_season(lab_conf, customer_id, profile_id, season_id,
                                    language, source, limit=10, offset=0):
        """A keyword to obtain simple recordings from Recording Microservice
        for the given CUSTOMER ID.language, source limit, offset)

        :param lab_conf: the conf dictionary, containing Microservice settings.
        :param customer_id: e.g. "3256f840-4d12-11e7-85f5-e5a72ae6734d_nl".
        :param season_id: season identifier
        :param profile_id: profile identifier
        :param source: recording/booking
        :param language: language required
        :param offset: Used in paging, means how many entities should be skipped
        :param limit: number of assets to be returned
        :return: an HTTP response instance.
        """
        rmr_obj = RecordingMicroserviceRequests(lab_conf, customer_id)
        return rmr_obj.get_list_of_episodes_season(profile_id, season_id, language, source, limit, offset)

    @staticmethod
    def get_list_of_episodes_show(lab_conf, customer_id, profile_id, show_id, channel_id,
                                  language, source, cpe_id, limit=10, offset=0):
        """A keyword to obtain simple recordings from Recording Microservice
        for the given CUSTOMER ID.

        :param lab_conf: the conf dictionary, containing Microservice settings.
        :param customer_id: e.g. "3256f840-4d12-11e7-85f5-e5a72ae6734d_nl".
        :param show_id: show identifier
        :param profile_id: profile identifier
        :param source: recording/booking
        :param language: language required
        :param channel_id: channel identifier
        :param offset: Used in paging, means how many entities should be skipped
        :param limit: number of assets to be returned
        :param cpe_id : cpe id of the box
        :return: an HTTP response instance.
        """
        rmr_obj = RecordingMicroserviceRequests(lab_conf, customer_id)
        return rmr_obj.get_list_of_episodes_show(profile_id, show_id, channel_id, language, source, cpe_id, limit, offset)

    @staticmethod
    def set_bookmark_single_recording(lab_conf, customer_id, recording_id):
        """A keyword to obtain simple recordings from Recording Microservice
        for the given CUSTOMER ID.

        :param lab_conf: the conf dictionary, containing Microservice settings.
        :param customer_id: e.g. "3256f840-4d12-11e7-85f5-e5a72ae6734d_nl".

        :return: an HTTP response instance.
        """
        rmr_obj = RecordingMicroserviceRequests(lab_conf, customer_id)
        return rmr_obj.set_bookmark_single_recording(recording_id)

    @staticmethod
    def set_view_state_single_recording(lab_conf, customer_id, recording_id):
        """A keyword to obtain simple recordings from Recording Microservice
        for the given CUSTOMER ID.

        :param lab_conf: the conf dictionary, containing Microservice settings.
        :param customer_id: e.g. "3256f840-4d12-11e7-85f5-e5a72ae6734d_nl".

        :return: an HTTP response instance.
        """
        rmr_obj = RecordingMicroserviceRequests(lab_conf, customer_id)
        return rmr_obj.set_view_state_single_recording(recording_id)

    @staticmethod
    def delete_all_recorded_recordings(lab_conf, customer_id):
        """A keyword to delete recorded recordings from Recording Microservice
        for the given CUSTOMER ID.

        :param lab_conf: the conf dictionary, containing Microservice settings.
        :param customer_id: e.g. "3256f840-4d12-11e7-85f5-e5a72ae6734d_nl".

        :return: an HTTP response instance.
        """
        rmr_obj = RecordingMicroserviceRequests(lab_conf, customer_id)
        return rmr_obj.delete_all_recorded_recordings()

    @staticmethod
    def delete_all_planned_recordings(lab_conf, customer_id):
        """A keyword to delete planned recordings from Recording Microservice
        for the given CUSTOMER ID.

        :param lab_conf: the conf dictionary, containing Microservice settings.
        :param customer_id: e.g. "3256f840-4d12-11e7-85f5-e5a72ae6734d_nl".

        :return: an HTTP response instance.
        """
        rmr_obj = RecordingMicroserviceRequests(lab_conf, customer_id)
        return rmr_obj.delete_all_planned_recordings()

    @staticmethod
    def delete_all_recordings(lab_conf, customer_id):
        """A keyword to delete all recordings from Recording Microservice
        for the given CUSTOMER ID.

        :param lab_conf: the conf dictionary, containing Microservice settings.
        :param customer_id: e.g. "3256f840-4d12-11e7-85f5-e5a72ae6734d_nl".

        :return: an HTTP response instance.
        """
        rmr_obj = RecordingMicroserviceRequests(lab_conf, customer_id)
        return rmr_obj.delete_all_recordings()

    @staticmethod
    def get_recorded_recordings(lab_conf, customer_id, language, profile_id, adult=False,
                                limit=10, sort='time', sort_order='desc', cpe_id=None):
        """A keyword to obtain recorded data from recording service for a valid customer.
        :param lab_conf: the conf dictionary, containing Microservice settings.
        :param customer_id: e.g. "3256f840-4d12-11e7-85f5-e5a72ae6734d_nl".
        :param is_adult: a boolean.
        :param sort: for sorting the result
        :param sort_order: asc or desc order of sorting
        :param profile_id: profile identifier
        :param limit:no:of recordings to be fetched
        :param cpe_id : cpe id of the box
        :return: an HTTP response instance.
        """
        rs_obj = RecordingMicroserviceRequests(lab_conf, customer_id)
        response = rs_obj.get_recorded_recordings(language, profile_id, adult, limit, sort, sort_order, cpe_id)
        return response

    @staticmethod
    def delete_booking(lab_conf, customer_id, type_of_recording, event_id):
        """Sends DELETE request to "recording-service" to delete a single booking
        of the given event for the given customer.

        :param
            lab_conf: a dictionary containing lab configuration settings.
            customer_id: a customer ID, e.g. "d4a54b70-7b42-11e7-bb50-31a18ae14f28_nl".
            type_of_recording: type of recording e.g. single/show.
            event_id: a program ID, e.g. "crid:~~2F~~2Fbds.tv~~2F172858925,imi:00100000000CD50D".

        :return: an HTTP response instance.
        """
        rs_obj = RecordingMicroserviceRequests(lab_conf, customer_id)
        response = rs_obj.delete_booking(type_of_recording, event_id)
        return response
