# pylint: disable=invalid-name
# Disabled pylint "invalid-name" complaining on the keyword 'get_traxis_profiles_activation_state'
# (name length > 30) but shortening the name will affect the sense of what the keyword is doing.
"""Implementation of Traxis library's keywords for Robot Framework.
v0.0.1 - Natallia Savelyeva: Implementation of lib and get recordings
v0.0.2 - Fernando Cobos: Add get_favourites_channels and add main_url (init)
v0.0.3 - Fernando Cobos: Add get_profiles and get_profiles_customer_id
v0.0.4 - Alex Denison: Add get_epg_channel_map and get_epg_channel_locations
v0.0.5 - Vishwanand Upadhyay: Added get_traxis_version and updated get_channel_ids
v0.0.6 - Vishwanand Upadhyay: Added Keywords get_all_products and get_tstv_events
v0.0.7 - Vishwanand Upadhyay: Added Keyword get_products_by_type
v0.0.8 - Nidhi Tiwari: Added keywords get_all_assets and get_purchased_products
v0.0.9 - Navneet Pandey: Added keyword get_replay_channel_map
v0.0.10- Vasundhara Agrawal: Added keyword filter_events
v0.0.11- Ievgen Petrash: Added keyword get_tstv_events_count
v0.0.12- Anuj Teotia: Added keyword get_channel_logo
"""
import os
import socket
import json
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


class TraxisRequests(object):
    """A class to handle requests to Traxis."""

    def __init__(self, lab_conf, cpe_id=""):
        """The class initializer.

        :param lab_conf: the conf dictionary, containing Traxis settings.
        :param cpe_id: the id of CPE EOS, e.g. "3C36E4-EOSSTB-003356472104".
        """
        self.conf = lab_conf
        print((self.conf))
        self.cpe = cpe_id
        self.main_url = "http://%s:%s/%s/" % \
                        (self.conf["SEACHANGE"]["TRAXIS_WEB"]["host"],
                         self.conf["SEACHANGE"]["TRAXIS_WEB"]["port"],
                         self.conf["SEACHANGE"]["TRAXIS_WEB"]["path"])
        print((self.main_url))
        try:
            # Use folder name where this file is placed
            # (as Traxis, Fabrix, PurchaseMicroservice, etc) as a tag
            folder_name = os.path.basename(os.path.dirname(os.path.realpath(__file__)))
            BuiltIn().set_test_variable("${ENDPOINT_TAG}", "%s" % folder_name)
        except RobotNotRunningError:
            pass

    def get_recordings(self):
        """A method sends GET request to Traxis to obtain data about recordings.

        A text of Traxis response is a json string.

        :return: a dictionary loaded from the Traxis response text.
        """
        url = "%sRecordings?output=json&CpeId=%s" % (self.main_url, self.cpe)
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
        if response.status_code is not None:
            struct = json.loads(response.text)
        else:
            struct = json.loads("{}")
        return struct

    def get_favourites_channels(self):
        """A method sends GET request to Traxis to obtain data about favourite channels.

        A text of Traxis response is a json string.
        :return: a full favourites channels response from Traxis.

        :Example (URL queries):

        channelLists - get id of channelList:
        http://172.30.187.214/traxis/web/channelLists?CpeId=
              3C36E4-EOSSTB-003356472104&output=json

        channelList - with the ID of a channelList get the list of favourite channels:
        http://172.30.187.214/traxis/web/channelList/acea256f-e1eb-48dd-af96-e15eb2e97cdd/
              propset/all?CpeId=3C36E4-EOSSTB-003356472104&output=json

        direct:
        http://172.30.187.214/traxis/web/channelLists/propset/all?CpeId=
              3C36E4-EOSSTB-003356472104&output=json
        """
        url = "%schannelLists/propset/all?CpeId=%s&output=json" % (self.main_url, self.cpe)
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

    def get_profiles(self):
        """A method sends GET request to Traxis to obtain data about profiles.

        A text of Traxis response is a json string.

        :return: a full response with customer profile from Traxis

        :Example:

        CustomerID = struct["Profiles"]["Profile"][0]["id"]
             3256f840-4d12-11e7-85f5-e5a72ae6734d_nl~~23MasterProfile
        """
        url = "%sProfiles/propset/all?CpeId=%s&output=json" % (self.main_url, self.cpe)
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

    def get_profiles_customer_id(self):
        """A method to extract form the Profiles (get_profiles) the CustomerID.

        A text with the CustomerID take from Traxis response is a string.

        :return: a CustomerID value, e.g. 3256f840-4d12-11e7-85f5-e5a72ae6734d,
                 i.e., without "_nl~~23MasterProfile" part.
        """
        response = self.get_profiles()
        if response.status_code == 200:
            json_response = response.json()
            customer_id = json_response['Profiles']['Profile'][0]['id'].split("~")[0]
            return customer_id
        return None

    def get_epg_channel_map(self):
        """A keyword to retreive the channel map from Traxis for the given CPE.

        :param lab_conf: the conf dictionary, containig Traxis settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: channel map response
        """

        url = self.main_url
        headers = {'Content-Type': 'application/xml'}

        body = "<?xml version=\"1.0\" encoding=\"utf-8\" ?>" \
               "<Request xmlns=\"urn:eventis:traxisweb:1.0\">" \
               "<Parameters><Parameter name=\"Output\">JSON</Parameter></Parameters>" \
               "<Identity><CpeId>" + self.cpe + \
               "</CpeId></Identity>" \
                "<RootRelationQuery relationName=\"Channels\">" \
                "<Options>" \
                "<Option type=\"Props\">LogicalChannelNumber,Name,Pictures,IsViewableOnCpe," \
                "OnFavorites,IsAdult,Is3D," \
                "IsHD, Blocked, IsBlockRemovable," \
                "IsPersonalBlockedChannel," \
                "PinChallengeSchedule,PinChallengeDuration,IsAudioOnly," \
                "IsNetworkRecordingAllowed," \
                "NetworkRecordingEntitlementState," \
                "IsNetworkRecordingViewableOnCpe,Products</Option>" \
                "<Option type=\"filter\">IsViewableOnCpe==true</Option>" \
                "<Option type=\"Sort\">LogicalChannelNumber</Option>" \
                "</Options>" \
                "<SubQueries>" \
                "<SubQuery relationName=\"Products\">" \
                "<SubQueryOptions><QueryOption path=\"Products\">" \
                "/Props/EntitlementState</QueryOption></SubQueryOptions>" \
                "</SubQuery>" \
                "</SubQueries>" \
                "</RootRelationQuery>" \
                "</Request>"

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.post(url, data=body, headers=headers)
            if response.status_code != 200:
                BuiltIn().log_to_console("\nTo get EPG channel map we sent POST to %s" % url)
                BuiltIn().log_to_console("Body: \n%s" % body)
                BuiltIn().log_to_console("Headers: \n%s" % headers)
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send POST %s due to %s" % (url, err)))
            response = failed_response_data("POST", url, body, err)
        return response

    def get_epg_channel_locations(self):
        """A keyword to retreive the channel map from Traxis for the given CPE.

        :param lab_conf: the conf dictionary, containig Traxis settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: channel locations response
        """

        url = self.main_url
        headers = {'Content-Type': 'application/xml'}

        body = "<?xml version=\"1.0\" encoding=\"utf-8\" ?>" \
               "<Request xmlns=\"urn:eventis:traxisweb:1.0\">" \
               "<Parameters><Parameter name=\"Output\">JSON</Parameter></Parameters>" \
               "<Identity><CpeId>" + self.cpe + \
               "</CpeId></Identity>" \
               "<RootRelationQuery relationName=\"ChannelLocations\">" \
               "<Options>" \
               "<Option type=\"Props\">IsViewableOnCpe,Locations</Option>" \
                "<Option type=\"filter\">IsViewableOnCpe==true</Option>" \
               "</Options>" \
               "</RootRelationQuery>" \
               "</Request>"

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.post(url, data=body, headers=headers)
            if response.status_code != 200:
                BuiltIn().log_to_console("\nTo get EPG channel locations we sent POST to %s" % url)
                BuiltIn().log_to_console("Body: \n%s" % body)
                BuiltIn().log_to_console("Headers: \n%s" % headers)
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send POST %s due to %s" % (url, err)))
            response = failed_response_data("POST", url, body, err)
        return response

    def get_customer_pin(self):
        """A keyword to retreive the channel map from Traxis for the given CPE.

        :param lab_conf: the conf dictionary, containig Traxis settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: channel locations response
        """
        customerid = self.get_profiles_customer_id()
        url = self.main_url
        headers = {'Content-Type': 'application/xml'}

        body = "<?xml version=\"1.0\" encoding=\"utf-8\" ?>" \
               "<Request xmlns=\"urn:eventis:traxisweb:1.0\">" \
               "<Parameters><Parameter name=\"Output\">JSON</Parameter></Parameters>" \
               "<Identity><CpeId>" + self.cpe + "</CpeId></Identity>" \
               "<ResourceQuery resourceType=\"Customer\" resourceId=\"" + customerid + "\">" \
               "<Options>" \
               "<Option type=\"Props\">MasterPin</Option>" \
               "</Options>" \
               "</ResourceQuery>" \
               "</Request>"

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.post(url, data=body, headers=headers)
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send POST %s due to %s" % (url, err)))
            response = failed_response_data("POST", url, body, err)
        return response

    def set_customer_pin(self, new_pin):
        """A keyword to retreive the channel map from Traxis for the given CPE.

        :param lab_conf: the conf dictionary, containig Traxis settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: channel locations response
        """
        customer_id = self.get_profiles_customer_id()
        url = self.main_url
        headers = {'Content-Type': 'application/xml'}

        body = "<?xml version=\"1.0\" encoding=\"utf-8\" ?>" \
               "<Request xmlns=\"urn:eventis:traxisweb:1.0\">" \
               "<Parameters><Parameter name=\"Output\">JSON</Parameter></Parameters>" \
               "<Identity><CpeId>" + self.cpe + "</CpeId></Identity>" \
               "<ActionQuery resourceType=\"Customer\" \"resourceId=\"" \
               + customer_id + "\" actionName=\"Update\">" \
               "<Arguments>" \
               "<Argument name=\"MasterPin\">" + new_pin + "</Argument>" \
               "</Arguments>" \
               "</ActionQuery>" \
               "</Request>"

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.post(url, data=body, headers=headers)
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send POST %s due to %s" % (url, err)))
            response = failed_response_data("POST", url, body, err)
        return response

    def get_all_channel_ids(self):
        """A function to request all the channels available.

        :return: an HTTP response instance.
        """

        url = "%sChannels" % self.main_url
        return http_send("GET", url)

    def get_version(self):
        """ A function to request traxis version details.

        :return: an HTTP response instance.
        """
        url = self.main_url
        return http_send("GET", url)

    def get_all_products(self):
        """ A function to request all products from traxis.

        :return: an HTTP response instance.
        """
        url = "%sproducts" % self.main_url
        return http_send("GET", url)

    def get_products_by_type(self, prod_type):
        """Request products from traxis based on type, e.g. transaction, subscription

        :param: type of product to be fetched from traxis e.g. transaction, subscription

        :return: an HTTP response instance. response text is xml data
        """
        url = "%sproducts/filter/type==%s" % (self.main_url, prod_type)
        return http_send("GET", url)

    def get_tstv_events(self, channel_ids):
        """ A function to request all tstv events from traxis


        :param: channel_ids: list of all Channel ids from Traxis
        :return: an HTTP response instance.
        """
        channel_ids = channel_ids.replace("]", "").replace("[", "")
        channel_id = random.choice(channel_ids.split(","))
        channel_id = channel_id.strip(" ' ")
        url = "%schannel/%s/props/TstvEvents" % (self.main_url, channel_id.strip())
        return http_send("GET", url)

    def get_tstv_events_count(self):
        """ A function to request count of tstv events for all channels from traxis

        :return: an HTTP response instance.
        """
        url = "%sChannels/props/tstveventcount" % self.main_url
        return http_send("GET", url)

    def get_all_assets(self):
        """A function to extract all the assets.

        :return: an HTTP response instance. response text is xml data
        """
        url = "%s/contents" % self.main_url
        return http_send("GET", url)

    def get_purchased_products(self, cpe_id):
        """A function to get all purchased products for given CPE ID.

        :return: an HTTP response instance. response text is xml data
        """
        url = "%spurchasedproducts/propset/all?cpeid=%s" % (self.main_url, cpe_id)
        return http_send("GET", url)

    def get_all_events(self, channel_ids):
        """ A function to request all events from traxis belonging to a channel id

        :param: channel_ids: list of all Channel ids from Traxis
        :return: an HTTP response instance.
        """
        channels_with_events = []
        for channel_id in channel_ids:
            url = "%schannel/%s/props/events" % (self.main_url, channel_id)
            response = http_send("GET", url)
            if "Events resultCount=" in response.text:
                channels_with_events.append(channel_id)
        channel_id = random.choice(channels_with_events)
        url = "%schannel/%s/props/events" % (self.main_url, channel_id)
        return http_send("GET", url)

    def get_event_details(self, event_id):
        """ A function to request event details from event_id

        :param: event_id: An event id from a specific channel
        e.g. crid:~~2F~~2Fbds.tv~~2F104329167,imi:00100000002B602C
        :return: an HTTP response instance.
        """

        url = "%sevent/%s/propset/all" % (self.main_url, event_id.strip())
        return http_send("GET", url)

    def get_replay_channel_map(self, is_adult):
        """A keyword to retreive the replay channel map from Traxis for the given CPE.

        :param lab_conf: the conf dictionary, containig Traxis settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".
        :param is_adult: True: Return only Adult assets
                        False: Return Non-Adult assets
        :return: replay channel map response
        """

        url = self.main_url
        headers = {'Content-Type': 'application/xml'}
        if is_adult is None:
            body = "<?xml version=\"1.0\" encoding=\"utf-8\" ?>" \
                   "<Request xmlns=\"urn:eventis:traxisweb:1.0\">" \
                   "<Parameters><Parameter name=\"Output\">JSON</Parameter></Parameters>" \
                   "<Identity><CpeId>" + self.cpe + "</CpeId></Identity>" \
                   "<RootRelationQuery relationName=\"Channels\">" \
                   "<Options>" \
                   "<Option type=\"Props\">LogicalChannelNumber,Name</Option>" \
                   "<Option type=\"filter\"  resourceType=\"Channel\">\
                   <![CDATA[TstvEventCount>0]]></Option>" \
                   "<Option type=\"Sort\">LogicalChannelNumber</Option>" \
                   "</Options>" \
                   "</RootRelationQuery>" \
                   "</Request>"
        else:
            body = "<?xml version=\"1.0\" encoding=\"utf-8\" ?>" \
                   "<Request xmlns=\"urn:eventis:traxisweb:1.0\">" \
                   "<Parameters><Parameter name=\"Output\">JSON</Parameter></Parameters>" \
                   "<Identity><CpeId>" + self.cpe + "</CpeId></Identity>" \
                   "<RootRelationQuery relationName=\"Channels\">" \
                   "<Options>" \
                   "<Option type=\"Props\">LogicalChannelNumber,Name</Option>" \
                   "<Option type=\"filter\">IsAdult=={}</Option>" \
                   "<Option type=\"filter\"  resourceType=\"Channel\">\
                   <![CDATA[TstvEventCount>0]]></Option>" \
                   "<Option type=\"Sort\">LogicalChannelNumber</Option>" \
                   "</Options>" \
                   "</RootRelationQuery>" \
                   "</Request>".format(is_adult)
        BuiltIn().log("url={} and body={}".format(url, body))

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.post(url, data=body, headers=headers)
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send POST %s due to %s" % (url, err)))
            response = failed_response_data("POST", url, body, err)
        return response

    @classmethod
    def get_profile_custom_data(cls, profile_response):
        """A function to extract the CustomData field from the customer Profile.

        A text with the CustomerID take from Traxis response is a string.

        :return: a STRING that can be converted to JSON
        """
        json_response = profile_response.json()
        custom_data = json_response["Profiles"]["Profile"][0]["CustomData"]
        # CustomData is a badly formatted JSON string:
        custom_data_fixed = custom_data.replace("/", "")
        return custom_data_fixed

    def filter_events(self, channel_id, start_time, end_time):
        """ A function to filter_events based on start time and end time for a particular channel id
        :param:
            start_time: 2018-05-11T15:00:00
            end_time: 2018-07-11T15:00:00
            channel_id: 0020
        :return: an HTTP response instance.
        """
        url = "%s/channel/%s/events/Filter/" \
              "AvailabilityStart>%s&AvailabilityStart<%s/limit/10/props/AvailabilityStart" \
              % (self.main_url, channel_id, start_time, end_time)
        return http_send("GET", url)

    def get_traxis_channel_lineup(self, cpe):
        """
        Query traxis for channel lineup
        :param cpe_id : unique STB CPE ID
        :return : response from Traxis query for channel lineup
        """
        url = self.main_url + \
            '/Channels/Filter/LogicalChannelNumber' \
            '%3E=0/Props/LogicalChannelNumber,ChannelNumbers,' \
            'Name,IsViewableOnCpe,Pictures,Blocked,OnFavorites,' \
            'Products,IsAdult,IsAudioOnly,Is3D,IsHD,PinChallenge' \
            'Schedule,PinChallengeDuration,UsageRules,SoftLinks,' \
            'Resolution/Sort/LogicalChannelNumber?output=xml&CpeId=' + cpe
        return http_send("GET", url)

class Keywords(object):
    """Keywords visible in Robot Framework."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @staticmethod
    def get_traxis_recordings(lab_conf, cpe_id):
        """A keyword to obtain recordings from Traxis for the given CPE.

        :param lab_conf: the conf dictionary, containig Traxis settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: a python non-altered text of Traxis response - a json string.
        """
        return TraxisRequests(lab_conf, cpe_id).get_recordings()

    @staticmethod
    def get_traxis_favourites_channels(lab_conf, cpe_id):
        """A keyword to obtain favourites channels from Traxis for the given CPE.

        :param lab_conf: the conf dictionary, containig Traxis settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: a python non-altered text of Traxis response - a json string.
        """
        return TraxisRequests(lab_conf, cpe_id).get_favourites_channels()

    @staticmethod
    def get_traxis_profiles(lab_conf, cpe_id):
        """A keyword to obtain profiles from Traxis for the given CPE.

        :param lab_conf: the conf dictionary, containig Traxis settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: a python non-altered text of Traxis response - a json string.
        """
        return TraxisRequests(lab_conf, cpe_id).get_profiles()

    @staticmethod
    def get_traxis_profiles_customer_id(lab_conf, cpe_id):
        """A keyword to obtain the customer ID from Traxis for the given CPE.

        :param lab_conf: the conf dictionary, containig Traxis settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: a CustomerId value - a string from get_traxis_profiles.
        """
        return TraxisRequests(lab_conf, cpe_id).get_profiles_customer_id()

    @staticmethod
    def get_traxis_customer_pin(lab_conf, cpe_id):
        """A keyword to obtain the Master PIN from Traxis for the given CPE.

        :param lab_conf: the conf dictionary, containig Traxis settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: a response containing the customer PIN.
        """
        return TraxisRequests(lab_conf, cpe_id).get_customer_pin()

    @staticmethod
    def set_traxis_customer_pin(lab_conf, cpe_id, newpin):
        """A keyword to obtain the Master PIN from Traxis for the given CPE.

        :param lab_conf: the conf dictionary, containig Traxis settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: a response containing the customer PIN.
        """
        return TraxisRequests(lab_conf, cpe_id).set_customer_pin(newpin)

    @staticmethod
    def get_profile_custom_data(lab_conf, cpe_id, profile_response):  # pylint: disable=E1121
        """A keyword to obtain the customer ID from Traxis for the given CPE.

        :param lab_conf: the conf dictionary, containig Traxis settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".
        :param profile_response

        :return: a Boolean value of "isSuspended" [False = customer is active] \
                 - a string from get_traxis_profiles.
        """
        return TraxisRequests(lab_conf, cpe_id).get_profile_custom_data(profile_response)

    @staticmethod
    def get_epg_channel_map(lab_conf, cpe_id):
        """A keyword to retreive the channel map from Traxis for the given CPE.

        :param lab_conf: the conf dictionary, containig Traxis settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: channel map response
        """

        return TraxisRequests(lab_conf, cpe_id).get_epg_channel_map()

    @staticmethod
    def get_epg_channel_locations(lab_conf, cpe_id):
        """A keyword to retreive the channel map from Traxis for the given CPE.

        :param lab_conf: the conf dictionary, containig Traxis settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: channel locations response
        """

        return TraxisRequests(lab_conf, cpe_id).get_epg_channel_locations()

    @staticmethod
    def get_channel_ids(lab_conf):
        """A keyword to retreive all list of channel IDs

        :param lab_conf: the conf dictionary, containig Traxis details.

        :return: an HTTP response instance.
        """
        return TraxisRequests(lab_conf).get_all_channel_ids()

    @staticmethod
    def get_traxis_version(lab_conf):
        """A keyword to retreive traxis version info

        :param lab_conf: the conf dictionary, containing Traxis details.

        :return: an HTTP response instance.
        """
        return TraxisRequests(lab_conf).get_version()

    @staticmethod
    def get_all_products(lab_conf):
        """A keyword to retreive all products from traxis

        :param lab_conf: the conf dictionary, containing Traxis details.

        :return: an HTTP response instance.
        """
        return TraxisRequests(lab_conf).get_all_products()

    @staticmethod
    def get_products_by_type(lab_conf, prod_type=None):
        """Retreive all products from traxis based on type e.g. transaction, subscription

        :param lab_conf: the conf dictionary, containing Traxis details.
        :param prod_type: type of product to be fetched from Traxis e.g. transaction, subscription

        :return: an HTTP response instance.
        """
        return TraxisRequests(lab_conf).get_products_by_type(prod_type)

    @staticmethod
    def get_tstv_events(lab_conf, channel_ids):
        """A keyword to obtain request for VRM.

        :param lab_conf: the conf dictionary, containing VRM settings.
        :param channel_ids: List of All Channel Ids retrived from Traxis.e.g. 001,002,003

        :return: an HTTP response instance.
        """
        return TraxisRequests(lab_conf).get_tstv_events(channel_ids)

    @staticmethod
    def get_tstv_events_count(lab_conf):
        """A keyword to request count of tstv events for all channels from traxis

        :param lab_conf: the conf dictionary, containing VRM settings.

        :return: an HTTP response instance.
        """
        return TraxisRequests(lab_conf).get_tstv_events_count()

    @staticmethod
    def get_all_assets(lab_conf):
        """A function to extract all the assets

        :param lab_conf: the conf dictionary, containing Traxis settings.
        :return: all asset list response in XML.
        """
        return TraxisRequests(lab_conf).get_all_assets()

    @staticmethod
    def get_purchased_products(lab_conf, cpe_id):
        """A function to extract all the assets

        :param lab_conf: the conf dictionary, containing Traxis settings.
        :return: all purchased products response in XML.
        """
        return TraxisRequests(lab_conf).get_purchased_products(cpe_id)

    @staticmethod
    def get_all_events(lab_conf, channel_ids):
        """A keyword to obtain request for Traxis.

        :param lab_conf: the conf dictionary, containing Traxis settings.
        :param channel_ids: List of All Channel Ids retrived from Traxis.e.g. 001,002,003

        :return: an HTTP response instance.
        """
        return TraxisRequests(lab_conf).get_all_events(channel_ids)

    @staticmethod
    def get_event_details(lab_conf, event_id):
        """A keyword to obtain request for Traxis.

        :param lab_conf: the conf dictionary, containing Traxis settings.
        :param: event_id: An event id from a specific channel
        e.g : crid:~~2F~~2Fbds.tv~~2F104329167,imi:00100000002B602C

        :return: an HTTP response instance.
        """
        return TraxisRequests(lab_conf).get_event_details(event_id)

    @staticmethod
    def get_replay_channel_map(lab_conf, cpe_id, is_adult=None):
        """A keyword to obtain request for Traxis.

        :param lab_conf: the conf dictionary, containig Traxis settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".
        :param is_adult: True: Return only Adult assets
                        False: Return Non-Adult assets

        :return: an HTTP response instance.
        """
        return TraxisRequests(lab_conf, cpe_id).get_replay_channel_map(is_adult)

    @staticmethod
    def filter_events(lab_conf, channel_id, start_time, end_time):
        """A keyword to obtain request for Traxis.

        :param lab_conf: the conf dictionary, containing Traxis settings.
        :param: channel_id: channel id for a specific channel
        :param: start_time: start time for filter
        :param: end_time: end time for filter

        :return: an HTTP response instance.
        """
        return TraxisRequests(lab_conf).filter_events(channel_id, start_time, end_time)

    @staticmethod
    def get_channel_logo(logo_url):
        """ A function to fetch channel logo by given url for a particular channel id
            :param:
                logo_url: https://staticqbr-nl-labe2esi.lab.cdn.dmdsdp.com/image-service \
                            /ImagesEPG/EventImages/npo_101.png
            :return: an HTTP response instance.
        """
        url = "%s?w=0&h=0" % logo_url
        response = requests.get(url, stream=True)
        return response

    @staticmethod
    def get_traxis_channel_lineup(lab_conf, cpe_id):
        """ A function to fetch get_traxis_channel_lineup for a particular cpe
            :param: lab_conf
            :return: an HTTP response instance.
        """
        return TraxisRequests(lab_conf).get_traxis_channel_lineup(cpe_id)
