"""Keywords file to hold generic keywords that are not test
specific but are required for test setup
v0.0.2 - Anuj Teotia: Added keyword get_crid_id
v0.0.3 - Vasundhara Agrawal: Added function verify_proxy_authorization
v0.0.4 - Ankita Agrawal: Added function epoch_converter & get_current_time
v0.0.5 - Vasundhara Agrawal: Added function get_crid_ongoing_event
"""

import socket
import json
import random
import datetime
import time
import urllib.parse
import requests
from lxml import etree
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError
import pytz

FAKER_TEMPLATE_BASIC = """
{
  "environment": "%(lab)s",
  "cpeId": "%(cpe)s"
}
"""


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


class IT_Faker_Requests(object):
    """DOCSTRING"""

    def __init__(self, lab_conf, cpe_id):
        """The class initializer.

        :param lab_conf: the conf dictionary, containig ITFaker settings.
        :param cpe_id: the id of CPE EOS, e.g. "3C36E4-EOSSTB-003356472104".
        """
        self.conf = lab_conf
        self.cpe = cpe_id
        self.main_url = "http://%s:%s" % \
                        (self.conf["ITFAKER"]["host"], self.conf["ITFAKER"]["port"])
        try:
            BuiltIn().set_test_variable("${ENDPOINT_TAG}", "ITFaker")
        except RobotNotRunningError:
            pass

    def get_customer(self):
        """A method sends GET request to ITFaker to obtain data about recordings.
        A text of ITFaker response is a json string.

        :return: a dictionary loaded from the ITFaker response text.

        curl -H "Content-Type: application/json" -X POST -d '{"environment": "lab5a","cpeId":
             "3C36E4-EOSSTB-003356472104"}' http://172.30.182.30:8000/getCustomer

        customerId = struct["description"]["customerId"]
        """
        headers = {"Content-type": "application/json"}
        url = "%s/getCustomer" % self.main_url
        data = FAKER_TEMPLATE_BASIC % {"cpe": self.cpe, "lab": self.conf["ITFAKER"]["env"]}

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.post(url, data=data, headers=headers)
            if response.status_code != 200:
                BuiltIn().log_to_console("To get_customer we send POST to %s\nData:\n%s"
                                         "\nHeaders:\n%s\nCode status: %sReason: %s"
                                         % (url, data, headers,
                                            response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send POST %s due to %s" % (url, err)))
            response = failed_response_data("POST", url, data, err)
        return response


class Traxis_Requests(object):
    """A class to handle requests to Traxis."""

    def __init__(self, lab_conf, cpe_id):
        """The class initializer.

        :param lab_conf: the conf dictionary, containig Traxis settings.
        :param cpe_id: the id of CPE EOS, e.g. "3C36E4-EOSSTB-003356472104".
        """
        self.conf = lab_conf
        self.cpe = cpe_id
        self.main_url = "http://%s:%s/%s/" % \
                        (self.conf["SEACHANGE"]["TRAXIS_WEB"]["host"],
                         self.conf["SEACHANGE"]["TRAXIS_WEB"]["port"],
                         self.conf["SEACHANGE"]["TRAXIS_WEB"]["path"])
        try:
            BuiltIn().set_test_variable("${ENDPOINT_TAG}", "Traxis")
        except RobotNotRunningError:
            pass

    def get_profiles(self):
        """A method sends GET request to Traxis to obtain data about profiles.

        A text of Traxis response is a json string.

        :return: a dictionary loaded from the Traxis response text.

        :Example:

        CustomerID = struct["Profiles"]["Profile"][0]["id"]
             3256f840-4d12-11e7-85f5-e5a72ae6734d_nl~~23MasterProfile
        """
        url = self.main_url + "Profiles/propset/all?CpeId=%s&output=json" % (self.cpe)

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url)
            if response.status_code != 200:
                BuiltIn().log_to_console("To get_profiles we send GET to %s\nCode status: %s. "
                                         "Reason: %s" %
                                         (url, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

    def verify_proxy_authorization(self, channel_id):
        """A method sends GET request to Traxis
        to verify whether Proxy5o2 is authorized for a channel

        A text of Traxis response is a json string.

        :return: a Traxis response text.

        :Example: channel_id = eg. 0001
        """
        main_url = "http://%s:%s/" % \
                   (self.conf["SEACHANGE"]["TRAXIS_WEB"]["host"],
                    self.conf["SEACHANGE"]["TRAXIS_WEB"]["port"])
        url = main_url + "Proxy5o2/IsAuthorizedForChannel.traxis?ChannelId=%s&StbId=%s" \
              % (channel_id, self.cpe)

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url)
            if response.status_code != 200:
                BuiltIn().log_to_console("To verify_proxy_authorization we send GET to %s\n"
                                         "Code status: %s. "
                                         "Reason: %s\nText: %s" %
                                         (url, response.status_code, response.reason,
                                          response.text))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response


class Vrm_Requests(object):
    """A class to handle requests to VRM."""

    def __init__(self, lab_conf):
        """The class initializer.

        :param lab_conf: the conf dictionary, containing VRM settings.

        """
        self.conf = lab_conf
        self.main_url = "http://%s:%s" % \
                        (self.conf["VRM"]["DS"]["host"],
                         random.choice(self.conf["VRM"]["DS"]["ports"]))
        try:
            BuiltIn().set_test_variable("${TAG_FROM_LIB}", "VRM")
        except RobotNotRunningError:
            pass

    def get_crid_id(self, channel_ids, crid_type, is_recordable=True, is_future=True,
                    entries_length=2000):
        """A method to return the response of get events by channel ID requests for VRM

        A text of VRM response is a json string.
         :param channel_ids: List of all the replay channels available with the traxis.
         :param crid_type: To get Crid for Series/Season/Program (programId,seasonId,seriesId)
         :param is_recordable: is_recordable=True event is recordable else not recordable.
         :param is_future: This parameter will check whether it is future or past event.
                is_future=True(future event)
         :param entries_length: To define number of entries for channel. By default it is 500
         :return: valid crid id for given channel number.
         """
        crid_id = None
        vrm_registered_channel = False
        channel_id = ""
        random.shuffle(channel_ids)
        for channel in channel_ids:
            url = "%s/epg/data/Event?schema=1.0&byChannelId=%s&entriesPageSize=%s"\
                  % (self.main_url, channel, entries_length)
            BuiltIn().log("Url={}".format(url))
            try:
                response = requests.get(url)
                if response.status_code != 200:
                    BuiltIn().log_to_console("To get events we send GET to %s\n"
                                             "Code status: %s. "
                                             "Reason: %s\nText: %s" %
                                             (url, response.status_code, response.reason,
                                              response.text))
            except (requests.exceptions.ConnectionError, socket.gaierror) as err:
                raise requests.exceptions.ConnectionError("Could not send GET %s due to %s" %
                                                          (url, err))
            response_data = json.loads(response.text)
            try:
                if int(response_data["entriesLength"]) > 0:
                    vrm_registered_channel = True
                    for i in range(0, response_data['entriesLength']-1):
                        recordable = response_data['entries'][i]['recordable']
                        if is_recordable != recordable:
                            continue
                        if is_future:
                            start_time = response_data['entries'][i]['startTime'] / 1000
                            current_time = Keywords().get_current_epoch_time()
                            five_minute_after_current = current_time + 5 * 60 * 1000
                            if start_time > five_minute_after_current:
                                try:
                                    crid_id = response_data['entries'][i][crid_type]
                                    channel_id = channel
                                    break
                                except KeyError:
                                    raise KeyError("This crid id is not valid as: ", crid_type)
                            else:
                                continue
                    if crid_id is not None:
                        break
                else:
                    continue
            except KeyError:
                raise KeyError("There are not entries available for the events on channel : {}"
                               .format(channel))
        if not vrm_registered_channel:
            raise Exception("No Channel is registered with VRM")
        return channel_id, crid_id


class Keywords(object):
    """Keywords visible in Robot Framework."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @staticmethod
    def get_traxis_customer(lab_conf, cpe_id):
        """A keyword to obtain the customer ID from Traxis for the given CPE.

        :param lab_conf: the conf dictionary, containig Traxis settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: a CustomerId value - a string from get_traxis_profiles.
        """
        return Traxis_Requests(lab_conf, cpe_id).get_profiles()

    @staticmethod
    def get_faker_customer(lab_conf, cpe_id):
        """A keyword to obtain recordings from ITFaker for the given CPE.

        :param lab_conf: the conf dictionary, containig ITFaker settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: Customer ID as a string.
        """

        return IT_Faker_Requests(lab_conf, cpe_id).get_customer()

    @staticmethod
    def validate_xml_response_data(response, schema):
        """A Keyword to validate response data matching with the schema

        :param : response : response object of an API call
        :param : schema : shcema against which reponse data needs to be validated
        """
        schema_root = etree.XML(schema)
        schema = etree.XMLSchema(schema_root)
        text = response.text.replace('encoding="utf-8"', '')
        xml_doc = etree.fromstring(text)
        result = schema.validate(xml_doc)
        return result

    @staticmethod
    def get_crid_id(lab_conf, channel_id, crid_type, is_recordable=True, is_future=True,
                    entries_length=2000):
        """A method to return the response of get events by channel ID requests for VRM

        A text of VRM response is a json string.
         :param lab_conf: the conf dictionary, containig VRM settings.
         :param channel_id: Replay channel for recording.
         :param is_recordable: is_recordable=True event is recordable else not recordable.
         :param is_future: This parameter will check whether it is future or past event.
                is_future=True(future event)
         :param crid_type: To get Crid for Series/Season/Program (programId,seasonId,seriesId)
         :param entries_length: To define number of entries for channel. By default it is 500
         :return: valid crid id for given channel number.
         """
        vrm_object = Vrm_Requests(lab_conf)
        response = vrm_object.get_crid_id(channel_id, crid_type, is_recordable, is_future,
                                          entries_length)
        return response

    @staticmethod
    def get_crid_ongoing_event(lab_conf, channel_ids, crid_type, is_recordable=True,
                               entries_length=2000):
        """A method to return the response of get ongoing events by channel ID requests for VRM

        A text of VRM response is a json string.
         :param lab_conf: the conf dictionary, containig VRM settings.
         :param channel_id: Replay channel for recording.
         :param is_recordable: is_recordable=True event is recordable else not recordable.
         :param crid_type: To get Crid for Series/Season/Program (programId,seasonId,seriesId)
         :param entries_length: To define number of entries for channel. By default it is 500
         :return: valid crid id for given channel number.
         """
        try:
            BuiltIn().set_test_variable("${TAG_FROM_LIB}", "VRM")
        except RobotNotRunningError:
            pass
        host = lab_conf["VRM"]["DS"]["host"]
        port = random.choice(lab_conf["VRM"]["DS"]["ports"])
        crid_id = None
        vrm_registered_channel = False
        random.shuffle(channel_ids)
        for channel in channel_ids:
            url = "http://%s:%s/epg/data/Event?schema=1.0&byChannelId=%s&entriesPageSize=%s" \
                  % (host, port, channel, entries_length)
            BuiltIn().log("Url={}".format(url))
            try:
                response = requests.get(url)
                if response.status_code != 200:
                    BuiltIn().log_to_console("To get events we send GET to %s\n"
                                             "Code status: %s. "
                                             "Reason: %s\nText: %s" %
                                             (url, response.status_code, response.reason,
                                              response.text))
            except (requests.exceptions.ConnectionError, socket.gaierror) as err:
                raise requests.exceptions.ConnectionError("Could not send GET %s due to %s" %
                                                          (url, err))
            response_data = json.loads(response.text)
            if int(response_data["entriesLength"]) > 0:
                vrm_registered_channel = True
                response_data = json.loads(response.text)
                for entry in range(0, response_data['entriesLength'] - 1):
                    recordable = response_data['entries'][entry]['recordable']
                    if is_recordable != recordable:
                        continue
                    start_time = response_data['entries'][entry]['startTime'] / 1000
                    duration = response_data['entries'][entry]['duration']
                    end_time = start_time + duration
                    current_time = Keywords().get_current_epoch_time()
                    if start_time < current_time < end_time:
                        try:
                            crid_id = response_data['entries'][entry][crid_type]
                            break
                        except KeyError:
                            print(("This crid is not valid as : ", crid_type))
                    else:
                        continue
                if crid_id is not None:
                    break
            else:
                continue
        if not vrm_registered_channel:
            raise Exception("No Channel is registered with VRM")
        return crid_id

    @staticmethod
    def verify_proxy_authorization(lab_conf, cpe_id, channel_id):
        """A keyword to obtain recordings from ITFaker for the given CPE.

        :param lab_conf: the conf dictionary, containig ITFaker settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".
        :param channel_id: the id of channel, e.g. 0001.

        :return: Traxis Response.
        """

        return Traxis_Requests(lab_conf, cpe_id).verify_proxy_authorization(channel_id)

    @staticmethod
    def epoch_converter(date_time):
        """A method to return the given date time in epoch format

        :param date_time: date time object
        :return: Converted Epoch time
        """
        epoch = int(time.mktime(date_time.timetuple()))
        return epoch

    @staticmethod
    def get_current_time():
        """A method to find the current time of the system in Amsterdam timezone

        :return: current time of the system
        """
        timezone = pytz.timezone('Europe/Amsterdam')
        current_time = datetime.datetime.now(tz=timezone)
        return current_time

    @staticmethod
    def get_current_epoch_time():
        """A method to get current timestamp in EPOCH format

        :return: timestamp, integer
        """
        return int((datetime.datetime.utcnow() - datetime.datetime(1970, 1, 1)).total_seconds())
