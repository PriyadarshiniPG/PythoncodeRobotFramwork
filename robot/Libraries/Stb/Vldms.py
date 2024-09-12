#!/usr/bin/env python27
# -*- coding: utf-8 -*-
"""
Description         Class definition for Vldms which includes
                    the RMF Session Manager
Reference: https://wikiprojects.upc.biz/display/CTOM/RMF+Session+Manager+API
"""

import re
from datetime import datetime

from Libraries.Common.AppServicesRequestHandler import AppServicesRequestHandler
from robot.libraries.BuiltIn import BuiltIn


class Vldms(object):
    """
    Description: Class to take vldms RMF session manager API calls,
    log in to the STB and send the requests via Curl.
    Ref: https://wikiprojects.upc.biz/display/CTOM/RMF+Session+Manager+API

    First parameter (just after self) must be the IP address of the STB
    in order to make it work with the send_curl_req_ssh_decorator
    """

    def __init__(self, application_service_handler=AppServicesRequestHandler()):
        """
        Initialise.
        :param stb_ip: STB IP Address
        """
        self.as_handler = application_service_handler
        self._sessionmanager_url = "http://127.0.0.1:8081/vldms/sessionmgr"
        # self._get_header = {"Accept": "application/json"}
        self._put_header = {
            "Content-type": "application/json",
            "Accept": "application/json"
        }
        self._timeout = 10

    def _vldms_put_request(self, ip_address, cpe_id, url, body=None,
                           xap=True, raw=False):
        """
        Send put request for given url to CPE
        """
        # headers = {'Content-type': 'application/json', 'Accept': 'text/plain'}
        start_time = datetime.now()
        response = self.as_handler.put(ip_address, cpe_id, url, body, headers=self._put_header,
                                       xap=xap, raw=raw, timeout=self._timeout)
        end_time = datetime.now()
        elapsed = (end_time - start_time).total_seconds() * 1000
        # BuiltIn().set_suite_variable("${LAST_HTTP_TIME}", elapsed)
        return response

    def _vldms_get_request(self, ip_address, cpe_id, url, xap=True):
        """
        Send get request for given url to CPE
        """
        start_time = datetime.now()
        response = self.as_handler.get(ip_address, cpe_id, url, xap=xap,
                                       timeout=self._timeout)
        end_time = datetime.now()
        elapsed = (end_time - start_time).total_seconds() * 1000
        # BuiltIn().set_suite_variable("${LAST_HTTP_TIME}", elapsed)
        return response

    @staticmethod
    def _get_formatted_storage_info(storage_info):
        """
        Take the storage info and format it so we have
        more readable, kb values
        :param storage_info: storage info returned from getStorageInformation
        :return: Formatted storage information
        """
        storage_info_index_0 = storage_info["storageInfo"][0]
        kb_divisor = 1000
        info = dict()
        info["totalSpace"] = (float(
            storage_info_index_0["totalSpace"]) / kb_divisor)
        info["freeSpace"] = (float(
            storage_info_index_0["freeSpace"]) / kb_divisor)
        info["spaceOccupiedByReviewBuffer"] = (float(
            storage_info_index_0["spaceOccupiedByReviewBuffer"]) / kb_divisor)
        return info

    def get_storage_info_via_vldms(self, ip_address, cpe_id, xap=True):
        """
        Gets the storage information via vldms session manager
        :param ip_address: STB IP address
        :return: Disk space, disk free space,
        space occupied by the review buffer in Kb
        """
        url = self._sessionmanager_url + "/recordings/getStorageInformation"
        storage_info = self._vldms_get_request(ip_address, cpe_id, url, xap=xap)

        if "storageInfo" in storage_info and \
                "totalSpace" in storage_info["storageInfo"][0] and \
                "freeSpace" in storage_info["storageInfo"][0] and \
                "spaceOccupiedByReviewBuffer" in \
                storage_info["storageInfo"][0]:
            return self._get_formatted_storage_info(storage_info)

        raise KeyError("Unable to get storage info details")

    def get_disk_free_space_via_vldms(self, ip_address, cpe_id, xap=True):
        """
        Gets the disk free space in Kb
        :param ip_address: STB IP address
        :return: Disk free space in Kb
        """
        storage_info = self.get_storage_info_via_vldms(ip_address, cpe_id, xap=xap)
        return storage_info["freeSpace"]

    def get_tuner_details_via_vldms(self, ip_address, cpe_id, xap=True):
        """
        Get all the details of available tuners via vldms session manager
        :param ip_address: STB IP address
        :return: session information
        """
        url = self._sessionmanager_url + "/getSessionsInfo"
        sessions_info = self._vldms_get_request(ip_address, cpe_id, url, xap=xap)

        if "sessionsInfo" in sessions_info and \
                "sessions" in sessions_info["sessionsInfo"]:
            return sessions_info

        raise KeyError("Unable to get sessions from sessionsInfo")

    def get_total_free_tuners_via_vldms(self, ip_address, cpe_id, xap=True):
        """
        Get the total free available tuners via vldms session manager
        :param ip_address: STB IP address
        :return: total_free_tuners
        """
        response_json = self.get_tuner_details_via_vldms(ip_address, cpe_id, xap=xap)
        tuners = response_json["sessionsInfo"]["sessions"]
        free_tuner_count = 0
        for tuner in tuners:
            if tuner["type"] == "fcc":
                free_tuner_count += 1
        return free_tuner_count

    def get_total_tuners_via_vldms(self, ip_address, cpe_id, xap=True):
        """
        Get the total available tuners via vldms session manager
        :param ip_address: STB IP address
        :return: total_tuners
        """
        response_json = self.get_tuner_details_via_vldms(ip_address, cpe_id, xap=xap)
        tuners = response_json["sessionsInfo"]["sessions"]
        return len(tuners)

    def get_channel_frequency_for_free_tuner_via_vldms(self, ip_address,
                                                       cpe_id, channel_id, xap=True):
        """
        Get the channel frequency from the free tuner using the channel id
        via vldms session manager
        :param ip_address: STB IP address
        :param channel_id: Channel ID
        :return: channel_frequency for the free tuner
        """
        response_json = self.get_tuner_details_via_vldms(ip_address, cpe_id, xap=xap)
        tuners = response_json["sessionsInfo"]["sessions"]
        locator = ""
        for tuner in tuners:
            if tuner["type"] == "fcc" and tuner["refId"] == channel_id:
                locator = tuner["locator"]
                break
        channel_frequency = re.compile(
            "frequency=(.*?)&modulation",
            re.DOTALL | re.IGNORECASE).findall(locator)
        return channel_frequency[0]

    def get_channel_frequency_for_main_tuner_via_vldms(self, ip_address, cpe_id,
                                                       channel_id=None, xap=True):
        """
        Get the channel frequency from the main tuner using the channel id
        via vldms session manager
        :param ip_address: STB IP address
        :param channel_id: Channel ID
        :return: channel_frequency
        """
        response_json = self.get_tuner_details_via_vldms(ip_address, cpe_id, xap=xap)
        tuners = response_json["sessionsInfo"]["sessions"]
        locator = ""
        for tuner in tuners:
            if tuner["type"] == "main":
                if channel_id is None or channel_id == tuner["refId"]:
                    locator = tuner["locator"]
                    break

        end_of_leader = locator.index("frequency=") + len("frequency=")
        start_of_trailer = locator.index("&modulation", end_of_leader)
        channel_frequency = locator[end_of_leader:start_of_trailer]
        return channel_frequency

    def get_main_session_ref_id_via_vldms(self, ip_address, cpe_id, xap=True):
        """
        Get main session ref ID via vldms
        :param ip_address: STB IP address
        :return: Main session ref ID
        """
        tuner_details = self.get_tuner_details_via_vldms(ip_address, cpe_id, xap=xap)
        # BuiltIn().log_to_console("get_main_session_ref_id_via_vldms"
        #                          " - tuner_details: %s \n" % tuner_details)

        sessions = tuner_details['sessionsInfo']['sessions']
        ref_id = None
        for session in sessions:
            if session['type'] == 'main':
                ref_id = session['refId']
                break
        return ref_id

    def open_request_to_play_recording_in_media_streamer_via_vldms(
            self, ip_address, cpe_id, recording_id, recording_url, xap=True):
        """
        Open a request to play the recording in media streamer
        via vldms session manager
        :param ip_address: STB IP address
        :param recording_id: Recording ID
        :param recording_url: Recording locator URL
        :return: Session status as a result of the curl call
        """
        payload = {
            "openRequest": {
                "type": "main",
                "refId": recording_id,
                "locator": recording_url,
                "playerParams": {
                    "showLastFrame": False,
                    "window": "0,0,1280,720",
                    "audPreferred": ",eng,ang;;ac3,ac3plus,mp1;",
                    "timeshiftMode": "disabled",
                    "blocked": False,
                    "subContentType": "vod",
                    "position": 0
                }
            }
        }
        url = self._sessionmanager_url + "/open"
        open_status = self._vldms_put_request(ip_address, cpe_id, url, payload,
                                              xap=xap, raw=False)
        open_status_data = open_status["openStatus"]
        if "openStatus" in open_status and \
                "status" in open_status_data and \
                "sessionId" in open_status_data:
            return open_status

        raise KeyError("Unable to get data from open request reply")

    def close_request_to_player_session_in_media_streamer_via_vldms(
            self, ip_address, cpe_id, session_id, recording_id, xap=True):
        """
        Close request to shut down the player session in media streamer
        via vldms session manager
        :param ip_address: STB IP address
        :param session_id: The session id
        :param recording_id: Recording ID
        :return: The session close status
        """
        payload = {
            "closeRequest": {
                "sessionId": session_id,
                "refId": recording_id,
                "showLastFrame": True
            }
        }
        url = self._sessionmanager_url + "/close"
        close_status = self._vldms_put_request(ip_address, cpe_id, url, payload,
                                               xap=xap, raw=False)

        if "closeStatus" in close_status and \
                "status" in close_status["closeStatus"]:
            return close_status

        raise KeyError("Unable to get data from close request")

    def get_player_session_speed_via_vldms(self, ip_address, cpe_id, ref_id, xap=True):
        """
        Get the player session speed via vldms session manager
        :param ip_address: STB IP address
        :param ref_id: Session reference ID
        :return: The session speed
        """
        payload = {"getSessionPropertyRequest": {
            "refId": ref_id, "properties": ["speed"]}}

        url = self._sessionmanager_url + "/getSessionProperty"
        session_property = self._vldms_put_request(ip_address, cpe_id, url, payload,
                                                   xap=xap, raw=False)

        session_property_data = session_property["sessionProperty"]
        if "sessionProperty" in session_property and \
                "speed" in session_property_data:
            return float(session_property_data["speed"])

        raise KeyError("Unable to get the player speed")

    def get_recording_count_via_vldms(self, ip_address, cpe_id, xap=True):
        """
        Get the recording count via vldms session manager
        :param ip_address: STB IP address
        :return: The recording count
        """
        url = self._sessionmanager_url + "/recordings/getCount"
        recordings_count = self._vldms_get_request(ip_address, cpe_id, url, xap=xap)

        if "recordingsCnt" in recordings_count:
            return int(recordings_count["recordingsCnt"])

        raise KeyError("Unable to get the recordings count")

    def get_player_session_properties_with_ref_id_via_vldms(
            self, ip_address, cpe_id, ref_id, xap=True):
        """
        Get player session properties as listed below
        via vldms session manager
        using the refId property of the session manager
        :param ip_address: STB IP address
        :param ref_id: the value to set for the key property(refId)
        :return: "duration","position" and "speed" properties
        """
        if ref_id is None:
            raise TypeError("ref_id is None")

        payload = {"getSessionPropertyRequest": {
            "refId": ref_id,
            "properties": [
                "duration",
                "position",
                "positionUTC",
                "timeshiftBuffer",
                "speed",
                "timeshiftIsFull"]}}

        url = self._sessionmanager_url + "/getSessionProperty"
        session_property = self._vldms_put_request(ip_address, cpe_id, url, payload,
                                                   xap=xap, raw=False)

        session_property_data = session_property["sessionProperty"]
        if "sessionProperty" in session_property and \
                "duration" in session_property_data \
                and "position" in session_property_data \
                and "speed" in session_property_data:
            speed = float(session_property_data["speed"])
            duration = int(session_property_data["duration"])
            position = int(session_property_data["position"])
            return duration, position, speed

        raise KeyError("Unable to get the player session properties")

    def get_player_session_property_via_vldms(
            self, ip_address, cpe_id, ref_id, property_list, xap=True):
        """
        Get a player session property via vldms session manager
        :param ip_address: STB IP address
        :param ref_id: Session reference ID
        :param property_list: getSessionPropertyRequest properties to retrieve
        :return: Selected property value in the current player session
        """
        payload = {"getSessionPropertyRequest": {
            "refId": ref_id,
            "properties": list(property_list)}}

        url = self._sessionmanager_url + "/getSessionProperty"
        session_property = self._vldms_put_request(ip_address, cpe_id, url, payload,
                                                   xap=xap, raw=False)

        for property_name in property_list:
            if "sessionProperty" not in session_property or \
                    property_name not in session_property["sessionProperty"]:
                raise KeyError("Unable to get the player property {}"
                               .format(property_name))
        return session_property["sessionProperty"]


