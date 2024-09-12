"""Implementation of XAP library's keywords for Robot Framework.
Version:
v0.0.1 - Natallia Savelyeva: XAP init lib
v0.0.2 - Fernando Cobos: Use self.conf[MICROSERVICES][OBOQBR]/xap
            as it is a new Microservices
v0.0.3 - Fernando Cobos: Add: getConfigCPE, ProfileId, getCurrentProfile
            UIstate, reboot, osdLang, getPowerState, aspectRatio, hdmiResolution, autoStandby,
            standByMode, ftiState, wifiClientEnabled
            + check_xap_call_result

v0.0.3 - Vishwanand Upadhyay: Added method sendStand by command
"""
import socket
import json
import requests
from robot.libraries.BuiltIn import BuiltIn


class XAP(object):
    """A class to run commands on STB using XAP."""

    def __init__(self, lab_conf, cpe_id):
        """The class initializer.

        :param lab_conf: the conf dictionary, containig Traxis settings.
        :param cpe_id: the id of CPE EOS, e.g. "3C36E4-EOSSTB-003356472104".
        """
        self.conf = lab_conf
        #BuiltIn().log_to_console("LAB CONF: %s" % (self.conf))
        self.cpe = cpe_id
        self.main_url = "http://%s/xap" % (self.conf["MICROSERVICES"]["OBOQBR"])

    def http(self, url, method="GET", data=None):
        """A method executes HTTP request from the given STB.

        The same can be achieved manually via curl like this (172.30.108.21 is a XAP host):
        $ curl -X POST -v http://172.30.108.21/http -d '{"cpeId":"3C36E4-EOSSTB-003356410807",\
        "brokerUrl":"","method":"GET","url":"http://127.0.0.1:81/mapng/vod-service/info",\
        "json":true,"body":""}' -H 'Content-Type: application/json;charset=UTF-8'

        See also: https://bitbucket.upc.biz/projects/CHA/repos/xap/browse.

        :param url: a URL to be sent from an STB.
        :param method: an HTTP method, "GET" or "POST".
        :param data: a string to be sent in a body of an HTTP request, leave default for "GET".
        :param headers: a dictionary of HTTP headers to be sent.

        :return: a 3-tuple (code:int, reason:str, body:dict) of an HTTP result returned.
        """
        result = (None, "", "")
        headers = {"Content-Type": "application/json;charset=UTF-8"}
        xap_url = "%s/http" % self.main_url
        xap_data = {"method": method, "url": url, "body": data or "",
                    "cpeId": self.cpe, "json": True, "brokerUrl": ""}
        try:
            response = requests.post(xap_url, data=json.dumps(xap_data), headers=headers, timeout=5)
            try:
                response_json = response.json()
            except ValueError:
                raise Exception("The response doesn't contain JSON. "
                                "Response status code is {code}, response reason is '{reason}'.\n"
                                "url = {url}\ndata={data}\nheaders={headers}"
                                .format(code=response.status_code,
                                        reason=response.reason,
                                        url=xap_url,
                                        data=xap_data,
                                        headers=headers))
            result = (response.status_code, response.reason, response_json)
        except (requests.exceptions.ConnectionError, socket.gaierror, socket.error) as err:
            print(("Could not send HTTP %s request %s due to %s" % (method, url, err)))
        return result


class Keywords(object):
    """Keywords visible in Robot Framework."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @staticmethod
    def check_xap_call_result(result, name):
        """A keyword to execute a purchase service info call from the given CPE.

        :param result: Result of the XAP call.
        :param name: Name of the XAP call.

        :return: check_result(check_status, payload)
        """
        #(200, 'OK', {u'type': u'http',
        # u'id': u'3C36E4-EOSSTB-003469693109-62fa223f-85b8-418d-9de7-ab21b87985b4',
        #           u'payload': {u'error': {u'code': u'ECONNRESET'}}})
        check_status = False
        payload = "FAILED"
        if len(result) == 3:
            check_status_code = result[0]
            if check_status_code == 200:
                check_status = True
                #check_status_message = result[1]
                data = result[2]
                if isinstance(data, dict):
                    if "payload" in data:
                        payload = data["payload"]
                        if isinstance(payload, dict):
                            if "error" in payload:
                                BuiltIn().log_to_console("\nERROR Checking XAP call return - " \
                                                "payload contains error on call: %s" % (name))
                                check_status = False
                else:
                    payload = data
            else:
                BuiltIn().log_to_console("\nERROR Checking XAP call return-status code NOT 200" \
                                         "on call: %s" % (name))
                print(("\nERROR Checking XAP call return-status code NOT 200 on call:%s" % (name)))
        else:
            BuiltIn().log_to_console("\nERROR Checking XAP call return - "
                                     "Length of XAP call return is less than 3 "\
                                     "on call: %s" % (name))
            print(("\nERROR Checking XAP call return-Length of XAP call return is less than 3 " \
             "on call: %s" % (name)))
        check_result = (check_status, payload)
        return check_result

    @staticmethod
    def call_purchase_service_info(lab_conf, cpe_id):
        """A keyword to execute a purchase service info call from the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://127.0.0.1:81/purchase-service/purchase-service/info"
        return XAP(lab_conf, cpe_id).http(url)

    @staticmethod
    def call_purchase_service_health(lab_conf, cpe_id):
        """A  keyword to execute a purchase service helthchecks call from the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://127.0.0.1:81/purchase-service/purchase-service/health-checks"
        return XAP(lab_conf, cpe_id).http(url)

    @staticmethod
    def call_vod_service_info(lab_conf, cpe_id):
        """A keyword to execute a VOD service info call from the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://127.0.0.1:81/mapng/vod-service/info"
        return XAP(lab_conf, cpe_id).http(url)

    @staticmethod
    def call_vod_service_health(lab_conf, cpe_id):
        """A  keyword to execute a VOD service helthchecks call from the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://127.0.0.1:81/mapng/vod-service/health-checks"
        return XAP(lab_conf, cpe_id).http(url)

    @staticmethod
    def call_discovery_service_info(lab_conf, cpe_id):
        """A keyword to execute a discovery service info call from the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://127.0.0.1:81/discovery-service/discovery-service/info"
        return XAP(lab_conf, cpe_id).http(url)

    @staticmethod
    def call_discovery_service_health(lab_conf, cpe_id):
        """A  keyword to execute a discovery service helthchecks call from the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://127.0.0.1:81/discovery-service/discovery-service/health-checks"
        return XAP(lab_conf, cpe_id).http(url)

    @staticmethod
    def call_session_service_info(lab_conf, cpe_id):
        """A keyword to execute a session service info call from the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://127.0.0.1:81/session-service/session-service/info"
        return XAP(lab_conf, cpe_id).http(url)

    @staticmethod
    def call_session_service_health(lab_conf, cpe_id):
        """A  keyword to execute a session service helthchecks call from the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://127.0.0.1:81/session-service/session-service/health-checks"
        return XAP(lab_conf, cpe_id).http(url)

    @staticmethod
    def call_recording_service_info(lab_conf, cpe_id):
        """A keyword to execute a recording service info call from the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://127.0.0.1:81/recording-service/recording-service/info"
        return XAP(lab_conf, cpe_id).http(url)

    @staticmethod
    def call_recording_service_health(lab_conf, cpe_id):
        """A  keyword to execute a recording service helthchecks call from the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://127.0.0.1:81/recording-service/recording-service/health-checks"
        return XAP(lab_conf, cpe_id).http(url)

    @staticmethod
    def call_epg_service_info(lab_conf, cpe_id):
        """A keyword to execute a epg service info call from the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://%s/info" % lab_conf["MICROSERVICES"]["EPG-SERVICE"]
        return XAP(lab_conf, cpe_id).http(url)

    @staticmethod
    def call_epg_service_index(lab_conf, cpe_id, country, language):
        """A keyword to execute a epg service index call from the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://%s/%s/%s/events/segments/index" % (lab_conf["MICROSERVICES"]["EPG-SERVICE"],
                                                         country, language)
        return XAP(lab_conf, cpe_id).http(url)

    @staticmethod
    def call_epg_service_segment(lab_conf, cpe_id, country, language, segment):
        """A keyword to execute a epg service segment call from the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://%s/%s/%s/events/segments/%s" % (lab_conf["MICROSERVICES"]["EPG-SERVICE"],
                                                      country, language, segment)
        return XAP(lab_conf, cpe_id).http(url)

    @staticmethod
    def enable_test_tools(lab_conf, cpe_id):
        """A keyword to enable test tools from the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://localhost:10014/settings/setSetting/cpe.uiTestTools"
        return XAP(lab_conf, cpe_id).http(url, "PUT", "true")

    @staticmethod
    def get_config_cpe(lab_conf, cpe_id):
        """A keyword to get Config from the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".
        :argument It NOT needs the cpe.uiTestTools to be enable

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://localhost:10014/configuration/getConfig/cpe"
        return XAP(lab_conf, cpe_id).http(url, "GET", "")

    @staticmethod
    def profile_id(lab_conf, cpe_id):
        """A keyword to get ProfileId from the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".
        :argument It needs the cpe.uiTestTools to be enable

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://localhost:8125/v2/config/ProfileId"
        return XAP(lab_conf, cpe_id).http(url, "GET", "")

    @staticmethod
    def get_current_profile(lab_conf, cpe_id):
        """A keyword to get Current Profile from the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".
        :argument It NOT needs the cpe.uiTestTools to be enable

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://localhost:10014/auth/getCurrentProfile"
        return XAP(lab_conf, cpe_id).http(url, "PUT", "")

    @staticmethod
    def ui_state(lab_conf, cpe_id):
        """A keyword to get UIstate V2 from the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".
        :argument It needs the cpe.uiTestTools to be enable

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://localhost:8125/v2/state"
        return XAP(lab_conf, cpe_id).http(url, "GET", "")

    @staticmethod
    def reboot(lab_conf, cpe_id):
        """A keyword to reboot the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".
        :argument It NOT needs the cpe.uiTestTools to be enable

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://localhost:10014/power-manager/reboot"
        return XAP(lab_conf, cpe_id).http(url, "POST", "")

    @staticmethod
    def osd_lang(lab_conf, cpe_id):
        """A keyword to get osdLang from the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".
        :argument It needs the cpe.uiTestTools to be enable

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://localhost:10014/settings/getSetting/profile.osdLang"
        return XAP(lab_conf, cpe_id).http(url, "GET", "")

    @staticmethod
    def get_power_state(lab_conf, cpe_id):
        """A keyword to get getPowerState from the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".
        :argument It needs the cpe.uiTestTools to be enable

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://localhost:10014/power-manager/getPowerState"
        return XAP(lab_conf, cpe_id).http(url, "GET", "")

##############################################################################
###################### localhost:10014/settings/getSetting####################
##############################################################################

    @staticmethod
    def aspect_ratio(lab_conf, cpe_id):
        """A keyword to get aspectRatio from the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".
        :argument It NOT needs the cpe.uiTestTools to be enable

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://localhost:10014/settings/getSetting/cpe.aspectRatio"
        return XAP(lab_conf, cpe_id).http(url, "GET", "")

    @staticmethod
    def get_hdmi_resolution(lab_conf, cpe_id):
        """A keyword to get hdmiResolution from the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".
        :argument It NOT needs the cpe.uiTestTools to be enable

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://localhost:10014/settings/getSetting/cpe.hdmiResolution"
        result = XAP(lab_conf, cpe_id).http(url, "GET", "")
        return result[2]["payload"] #pylint: disable=E1126

    @staticmethod
    def auto_standby(lab_conf, cpe_id):
        """A keyword to get autoStandby from the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".
        :argument It NOT needs the cpe.uiTestTools to be enable

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://localhost:10014/settings/getSetting/cpe.autoStandby"
        return XAP(lab_conf, cpe_id).http(url, "GET", "")

    @staticmethod
    def stand_by_mode(lab_conf, cpe_id):
        """A keyword to get standByMode from the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".
        :argument It NOT needs the cpe.uiTestTools to be enable

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://localhost:10014/settings/getSetting/cpe.standByMode"
        return XAP(lab_conf, cpe_id).http(url, "GET", "")

    @staticmethod
    def fti_state(lab_conf, cpe_id):
        """A keyword to get ftiState from the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".
        :argument It NOT needs the cpe.uiTestTools to be enable

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://localhost:10014/settings/getSetting/cpe.ftiState"
        return XAP(lab_conf, cpe_id).http(url, "GET", "")

    @staticmethod
    def wifi_client_enabled(lab_conf, cpe_id):
        """A keyword to get wifiClientEnabled from the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".
        :argument It NOT needs the cpe.uiTestTools to be enable

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://localhost:10014/settings/getSetting/cpe.wifiClientEnabled"
        return XAP(lab_conf, cpe_id).http(url, "GET", "")

    @staticmethod
    def send_standby(lab_conf, cpe_id):
        """A keyword to send standby command for the given CPE.

        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".
        :argument It NOT needs the cpe.uiTestTools to be enable

        :return: a 3-tuple (code, reason, body) of an HTTP response returned.
        """
        url = "http://localhost:10014/keyinjector/emulateuserevent/80/8000/source=2"
        return XAP(lab_conf, cpe_id).http(url, "GET", "")

    @staticmethod
    def get_list_of_apps(lab_conf, cpe_id):
        """
        returns the list of apps present in the cpe
        :param lab_conf: the conf dictionary, containing lab settings.
        :param cpe_id: STB ID
        :return: list of apps
        """
        url = 'http://localhost:8125/apps'
        return XAP(lab_conf, cpe_id).http(url, "GET", "")
