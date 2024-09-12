"""Implementation of VRM library's keywords for Robot Framework.
v0.0.1 - Vishwanand Upadhyay: Implementation of lib
v0.0.2 - Natallia Savelyeva: Refactoring and extension of the lib
v0.0.3 - Nidhi Tiwari: Added keyword get_recordings_all_vip, get_recordings_all_bs1
         and get_recordings_all_bs2
v0.0.4 - Anuj Teotia: Made changes in keywords get_recordings,
         get_recordings_all_vip, get_recordings_all_bs1
         and get_recordings_all_bs2 to use them Robot and
         created unit test cases in test_keywords file.
"""
import os
import random
import socket
import urllib.parse
import json
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


def http_send(method, url, data=None, headers=None):
    """Send HTTP GET/POST request and use try-except block for any error handling

    :param method: an HTTP method, e.g. "POST".
    :param url: a url used to send the request.
    :param data: a string of data sent (if any).
    :param headers: header to be sent with the request.

    :return: an HTTP response instance.
    """
    try:
        BuiltIn().set_test_variable("${URL_PATH}", "%s" % urllib.parse.urlparse(url).path)
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


class VRM(object):
    """A class to handle requests to VRM."""

    def __init__(self, lab_conf):
        """The class initializer.

        :param lab_conf: the conf dictionary, containing VRM settings.
        """
        self.conf = lab_conf
        try:
            # Use folder name where this file is placed
            # (as Traxis, Fabrix, PurchaseMicroservice, etc) as a tag
            folder_name = os.path.basename(os.path.dirname(os.path.realpath(__file__)))
            BuiltIn().set_test_variable("${ENDPOINT_TAG}", "%s" % folder_name)
        except RobotNotRunningError:
            pass


    def get_recordings(self, customer_id=None, columns=None):
        """A method returns the response of get recordings request.

        A text of VRM response is a json string.

        :return: response of get recordings request for all users or for a specific user.
        """
        host = self.conf["VRM"]["BS"]["host"]
        port = random.choice(self.conf["VRM"]["BS"]["ports"])
        user = "&userId=%s" % customer_id if customer_id else ""
        columns = "&fields=%s" % columns if columns else ""
        params = "schema=1.0&entries=true&count=true%s%s&form=json" % (user, columns)
        url = "http://%s:%s/scheduler/web/User/read?%s" % (host, port, params)
        response = http_send("GET", url)
        if response.status_code != 200:
            BuiltIn().log_to_console("To get_recordings we sent GET to %s . "
                                     "Status code %s. Reason %s" %
                                     (url, response.status_code, response.reason))
        return response

    def get_recordings_by_status(self, customer_id=None, status=None):
        """A method sends the GET request to get recordings as per the status (scheduled,
        cancelled, ongoing and completed).
        for a specific customer

        :param customer_id: the id of CUSTOMER ID, e.g. "3256f840-4d12-11e7-85f5-e5a72ae6734d_nl".
        :param status: Recording status, e.g. scheduled,cancelled,ongoing and completed

        :return: an HTTP response instance.
        """
        host = self.conf["VRM"]["BS"]["host"]
        port = random.choice(self.conf["VRM"]["BS"]["ports"])
        user = "&userId=%s" % customer_id
        params = "schema=2.0%s" % user
        url = "http://%s:%s/scheduler/web/Record/read?%s&byStatus=%s" % (host, port, params, status)
        response = http_send("GET", url)
        if response.status_code != 200:
            BuiltIn().log_to_console("To get_recordings_by_status we sent GET to %s . "
                                     "Status code %s. Reason %s" %
                                     (url, response.status_code, response.reason))
        return response

    def get_events_request(self, channel_ids):
        """A method to return the response of get events by channel ID requests for VRM

        A text of VRM response is a json string.

        :param channel_ids: List of All Channel Ids retrived from Traxis.e.g. 001,002,003

        :return: events for different channel ids.
        """
        host = self.conf["VRM"]["DS"]["host"]
        port = random.choice(self.conf["VRM"]["DS"]["ports"])
        channels_with_entries = []
        for channel in channel_ids.split(","):
            channel = channel.strip(" ' ")
            url = "http://%s:%s/epg/data/Event?schema=1.0&byChannelId=%s" % (host, port, channel)
            response = http_send("GET", url)
            if int(response.json()["entriesLength"]) > 0:
                channels_with_entries.append(channel)
        # BuiltIn().log_to_console(channels_with_entries)
        if channels_with_entries:
            channel_id = random.choice(channels_with_entries)
            url = "http://%s:%s/epg/data/Event?schema=1.0&byChannelId=%s" % (host, port, channel_id)
            response = http_send("GET", url)
            if response.status_code != 200:
                BuiltIn().log_to_console("To get_events_request we sent GET to %s . "
                                         "Status code %s. Reason %s" %
                                         (url, response.status_code, response.reason))
            result = response
        else:
            raise Exception("There are no channels with entries")
        return result

    def get_recordings_all_vip(self, customer_id=None, columns=None):
        """A method returns the response of get recordings request through VIP(Virtual IP).
        A text of VRM response is a json string.

        :param cpe_id: the id of CPE EOS, e.g. "3C36E4-EOSSTB-003356472104".
        :param columns: a string of comma-separated fields names, e.g.assetId,eventId,
               startTime,name,status

        :return: an HTTP response instance.

        """
        host = self.conf["VRM"]["BS"]["host"]
        port = random.choice(self.conf["VRM"]["BS"]["ports"])
        user = "&userId=%s" % customer_id if customer_id else ""
        columns = "&fields=%s" % columns if columns else ""
        params = "schema=1.0%s&entries=true&count=true%s&form=json" % (user, columns)
        url = "http://%s:%s/scheduler/web/Record/read?%s" % (host, port, params)
        response = http_send("GET", url)
        if response.status_code != 200:
            BuiltIn().log_to_console("To get_recordings_all_vip we sent GET to %s . "
                                     "Status code %s. Reason %s" %
                                     (url, response.status_code, response.reason))
        return response

    def get_recordings_all_bs1(self, customer_id=None, columns=None):
        """A method returns the response of get recordings request through BS1.
        A text of VRM response is a json string.

        :param cpe_id: the id of CPE EOS, e.g. "3C36E4-EOSSTB-003356472104".
        :param columns: a string of comma-separated fields names, e.g.assetId,eventId,
               startTime,name,status

        :return: an HTTP response instance.
        """
        host = self.conf["VRM"]["BS1"]["host"]
        port = random.choice(self.conf["VRM"]["BS1"]["ports"])
        user = "&userId=%s" % customer_id if customer_id else ""
        columns = "&fields=%s" %columns if columns else ""
        params = "schema=1.0%s&entries=true&count=true%s&form=json" % (user, columns)
        url = "http://%s:%s/scheduler/web/Record/read?%s" % (host, port, params)
        response = http_send("GET", url)
        if response.status_code != 200:
            BuiltIn().log_to_console("To get_recordings_all_bs1 we sent GET to %s . "
                                     "Status code %s. Reason %s" %
                                     (url, response.status_code, response.reason))
        return response

    def get_recordings_all_bs2(self, customer_id=None, columns=None):
        """A method returns the response of get recordings request through BS2.
        A text of VRM response is a json string.

        :param cpe_id: the id of CPE EOS, e.g. "3C36E4-EOSSTB-003356472104".
        :param columns: a string of comma-separated fields names, e.g.assetId,eventId,
               startTime,name,status

        :return: an HTTP response instance.
        """
        host = self.conf["VRM"]["BS2"]["host"]
        port = random.choice(self.conf["VRM"]["BS2"]["ports"])
        user = "&userId=%s" % customer_id if customer_id else ""
        columns = "&fields=%s" % columns if columns else ""
        params = "schema=1.0%s&entries=true&count=true%s&form=json" % (user, columns)
        url = "http://%s:%s/scheduler/web/Record/read?%s" % (host, port, params)
        response = http_send("GET", url)
        if response.status_code != 200:
            BuiltIn().log_to_console("To get_recordings_all_bs2 we sent GET to %s . "
                                     "Status code %s. Reason %s" %
                                     (url, response.status_code, response.reason))
        return response

    def get_random_event(self, channelId):
        """A method returns the random event details from VRM through DS.
        A text of VRM response is a json string.
        :param channelId: any channel id , e.g. "CNBC".
        :return: an HTTP response instance.
        """
        host = self.conf["VRM"]["DS"]["host"]
        port = random.choice(self.conf["VRM"]["DS"]["ports"])
        url = "http://%s:%s/epg/data/Event" % (host, port)
        parameters = {
            "schema": "1.0",
            "byChannelId": channelId
        }
        response = requests.get(url, params=parameters)
        dict_res = json.loads(response.text, encoding="utf-8")
        list_of_events = dict_res["entries"]
        return random.choice(list_of_events)


class Keywords(object):
    """Keywords visible in Robot Framework."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @staticmethod
    def get_recordings(lab_conf, **kwargs):
        """A keyword to obtain request for VRM.

        :param lab_conf: the conf dictionary, containing VRM settings.

        :return: response of get recordings request for all users or for a specific user.
        """
        return VRM(lab_conf).get_recordings(**kwargs)

    @staticmethod
    def get_recordings_by_status(lab_conf, customer_id, status):
        """A keyword to obtain request for VRM.

        :param lab_conf: the conf dictionary, containing VRM details.
        :param customer_id: the id of CUSTOMER ID, e.g. "3256f840-4d12-11e7-85f5-e5a72ae6734d_nl".
        :param status: Recording status, e.g. scheduled,cancelled,ongoing and completed

        :return: an HTTP response instance.
        """
        return VRM(lab_conf).get_recordings_by_status(customer_id, status)


    @staticmethod
    def get_events_request(lab_conf, channel_ids):
        """A keyword to obtain request for VRM.

        :param lab_conf: the conf dictionary, containing VRM settings.
        :param channel_ids: List of All Channel Ids retrived from Traxis.e.g. 001,002,003

        :return: response of get request events by channel id.
        """
        return VRM(lab_conf).get_events_request(channel_ids)

    @staticmethod
    def get_recordings_all_vip(lab_conf, **kwargs):
        """A keyword to get all recordings through VIP(Virtual IP).

        :param lab_conf: the conf dictionary, containing VRM settings.

        :return: an HTTP response instance.
        """
        return VRM(lab_conf).get_recordings_all_vip(**kwargs)

    @staticmethod
    def get_recordings_all_bs1(lab_conf, **kwargs):
        """ keyword to get all recordings through BS1.

        :param lab_conf: the conf dictionary, containing VRM settings.

        :return: an HTTP response instance.
        """
        return VRM(lab_conf).get_recordings_all_bs1(**kwargs)


    @staticmethod
    def get_recordings_all_bs2(lab_conf, **kwargs):
        """ keyword to get all recordings through BS2.

        :param lab_conf: the conf dictionary, containing VRM settings.

        :return: an HTTP response instance.
        """
        return VRM(lab_conf).get_recordings_all_bs2(**kwargs)

    @staticmethod
    def get_random_event(lab_conf, channelId):
        """ keyword to get random event by passing channelId.

        :param lab_conf: the conf dictionary, containing VRM settings.
        :channelId: channel id for which event will be returned.

        :return: an JSON response instance.
        """
        return VRM(lab_conf).get_random_event(channelId)
