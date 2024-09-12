# pylint: disable=unused-argument
# Disabled pylint "unused-argument" complaining on args for mock patches'

"""Unit tests of XAP library's keywords for Robot Framework.

Tests use mock module and do not execute commands on real STBs.
The global function debug() can be used for testing using real STBs.

Version:
v0.0.1 - Natallia Savelyeva: XAP init lib
v0.0.2 - Fernando Cobos: Use self.conf[MICROSERVICES][OBOQBR]/xap
            as it is a new Microservices
v0.0.3 - Fernando Cobos: Add: getConfigCPE, ProfileId, getCurrentProfile
            UIstate, reboot, osdLang, getPowerState, aspectRatio, hdmiResolution, autoStandby,
            standByMode, ftiState, wifiClientEnabled
"""
import socket
import json
import unittest
try:
    import mock
except ImportError:
    import unittest.mock as mock
import requests
from robot.libraries.BuiltIn import BuiltIn
from .keywords import XAP, Keywords


UNREACHABLE_IP = "100.100.100.100"
UNRESOLVABLE_HOST = "libertyglobal.com"
CPE_ID = "3C36E4-EOSSTB-003356410807"

LAB_CONF = {
    "MOCK": {"MICROSERVICES" : {"OBOQBR": "oboqbr.labe2esuperset.nl.internal",
                                "EPG-SERVICE": "epg.labe2esuperset.nl.dmdsdp.com"}},
    "UNREACHABLE": {"MICROSERVICES" : {"OBOQBR":  UNREACHABLE_IP}},
    "UNRESOLVABLE": {"MICROSERVICES": {"OBOQBR": UNRESOLVABLE_HOST}},
    "REAL": {"MICROSERVICES": {"OBOQBR": "172.30.108.21",
                               "EPG-SERVICE": "epg.labe2esi.nl.dmdsdp.com"}},
    "ITC": {"MICROSERVICES": {"OBOQBR": "10.64.13.180",
                              "EPG-SERVICE": "epg.labe2esi.nl.dmdsdp.com"}}
}


PURCHASE_SRVC_INFO = json.loads("""{"id":"%s-e3ae668e-8ba6-4c97-9228-c41ff9b9a6bb",\
"type":"http","payload":{"APP_DEPLOY_TIME":null,"APP_START_TIME":"2018-01-08T09:53:27Z",\
"APP_BRANCH":"UNKNOWN","APP_NAME":"purchase-service","APP_BUILD_TIME":"2017-10-27T13:18:06Z",\
"APP_VERSION":"0.18.1","APP_REVISION":"d9f584d4464d2396d1a7776461fc33d4c882d623"}}""" % CPE_ID)

PURCHASE_SRVC_HEALTH = json.loads("""{"id":"%s-dc2a4429-0378-4739-a576-902b62a7b5c2",\
"type":"http","payload":{"DBCP2 DataSource: default":{"healthy":true,"timestamp":\
"2018-01-12T13:57:58.644Z"},"deadlocks":{"healthy":true,"timestamp":"2018-01-12T13:57:58.636Z"},\
"traxis":{"healthy":true,"timestamp":"2018-01-12T13:57:58.633Z"}}}""" % CPE_ID)

VOD_SRVC_INFO = json.loads("""{"id":"%s-5d5c9933-39fc-404c-a9bd-9f44aef33be6",\
"type":"http","payload":{"APP_DEPLOY_TIME":null,"APP_START_TIME":"2017-12-29T18:17:07Z",\
"APP_BRANCH":"UNKNOWN","APP_NAME":"vod-service","APP_BUILD_TIME":"2017-11-13T14:34:13Z",\
"APP_VERSION":"2.0.0","APP_REVISION":"396b66057d41b07764694c43b0b695244fd98a84"}}""" % CPE_ID)

VOD_SRVC_HEALTH = json.loads("""{"id":"%s-ee7592a3-a1a1-4bb7-84d3-4127e959c183","type":"http",\
"payload":{"deadlocks":{"healthy":true,"timestamp":"2018-01-15T09:37:30.035Z"},\
"mes":{"healthy":true,"timestamp":"2018-01-15T09:37:30.026Z"},\
"reng":{"healthy":true,"timestamp":"2018-01-15T09:37:30.026Z"},\
"traxis":{"healthy":true,"timestamp":"2018-01-15T09:37:30.026Z"}}}""" % CPE_ID)

DISCOVERY_SRVC_INFO = json.loads("""{"id":"%s-2b24c633-71c4-4042-9826-6031f33571df",\
"type":"http","payload":{"APP_DEPLOY_TIME":null,"APP_START_TIME":"2017-12-29T18:16:46Z",\
"APP_BRANCH":"master","APP_NAME":"discovery-service","APP_BUILD_TIME":"2017-11-23T17:01:17Z",\
"APP_VERSION":"0.21.2","APP_REVISION":"2464322e031cbc137d1badb7a4649135fb5b45d6"}}""" % CPE_ID)

DISCOVERY_SRVC_HEALTH = json.loads("""{"id":"%s-d6c45c9d-3d4f-4372-987a-4e6fa0de00ae",\
"type":"http","payload":{"Reng":{"healthy":true,"timestamp":"2018-01-15T09:51:27.352+0000"},\
"Traxis":{"healthy":true,"timestamp":"2018-01-15T09:51:27.352+0000"},\
"deadlocks":{"healthy":true,"timestamp":"2018-01-15T09:51:27.352+0000"}}}""" % CPE_ID)

SESSION_SRVC_INFO = json.loads("""{"id":"%s-bddd6fbb-5d7a-4ddb-8201-573d17a90779",\
"type":"http","payload":{"APP_DEPLOY_TIME":null,"APP_START_TIME":"2018-01-08T13:14:39Z",\
"APP_BRANCH":"master","APP_NAME":"session-service","APP_BUILD_TIME":"2017-11-15T15:41:01Z",\
"APP_VERSION":"0.15.7","APP_REVISION":"c3e715af3e951881c520ae8ae587da13896af711"}}""" % CPE_ID)

SESSION_SRVC_HEALTH = json.loads("""{"id":"3%s-67f75375-426a-4897-9dc8-8b31f19d2666","type":"http",\
"payload":{"MagIdentity":{"healthy":true,"timestamp":"2018-01-18T07:52:43.050Z"},\
"MagMetadata":{"healthy":true,"timestamp":"2018-01-18T07:52:43.050Z"},\
"Traxis":{"healthy":true,"timestamp":"2018-01-18T07:52:43.049Z"},\
"VRM":{"healthy":true,"timestamp":"2018-01-18T07:52:43.049Z"},\
"deadlocks":{"healthy":true,"timestamp":"2018-01-18T07:52:43.051Z"}}}""" % CPE_ID)

RECORDING_SRVC_INFO = json.loads("""{"id":"%s-7d158659-d861-4750-8ba5-51c9c0a12ec8",\
"type":"http","payload":{"APP_DEPLOY_TIME":null,"APP_START_TIME":"2018-01-18T03:06:43Z",\
"APP_BRANCH":"UNKNOWN","APP_NAME":"recording-service","APP_BUILD_TIME":"2017-11-10T07:18:36Z",\
"APP_VERSION":"0.34.0","APP_REVISION":"feed95848baf51222ef65ebcc8fb81c5a99cd111"}}""" % CPE_ID)

RECORDING_SRVC_HEALTH = json.loads("""{"id":"%s-39c86936-ee13-408f-a460-790c80705ed6",\
"type":"http","payload":{"MQTT":{"healthy":true,"timestamp":"2018-01-18T08:20:40.541Z"},\
"Nokia Enhanced API":{"healthy":true,"timestamp":"2018-01-18T08:20:40.542Z"},"Nokia VRM":\
{"healthy":true,"timestamp":"2018-01-18T08:20:40.542Z"},"RENG":{"healthy":true,"timestamp":\
"2018-01-18T08:20:40.543Z"},"Traxis":{"healthy":true,"timestamp":"2018-01-18T08:20:40.542Z"},\
"deadlocks":{"healthy":true,"timestamp":"2018-01-18T08:20:40.546Z"}}}""" % CPE_ID)

EPG_SRVC_INFO = json.loads("""{"id":"%s-9219e280-bbe1-46f1-9eb5-dd6f3e34670f",\
"type":"http","payload":{"APP_DEPLOY_TIME":null,"APP_END_TIME":"2018-01-19T09:53:06Z",\
"APP_START_TIME":"2017-12-29T18:16:33Z","APP_BRANCH":"UNKNOWN","APP_NAME":"epg-packager",\
"APP_BUILD_TIME":"2017-10-30T15:01:51Z","APP_VERSION":"1.1.35",\
"APP_REVISION":"f5a052e0db24dbdac116d3a4472acb7bd68490ec"}}""" % CPE_ID)

ENABLE_TESTTOOLS = json.loads("""{"id":"%s-fadc80cb-76ce-4610-bc51-cc19426a6452",\
"type":"http","payload":null}""" % CPE_ID)

CONF_CPE = json.loads("""{"country":"be","timezone":"Europe/Brussels",\
"ssdpUuid":"677b0466-9ef8-4e6d-8c77-457c55aea2ab","id":"%s","oui":"3C36E4",\
"modelName":"DCX960","hwVersion":"ARRIS-DCX960-MPA+","serialNumber":"003356410807",\
"chipid":"00000101020025CC","buildVersion": "00.01-057-ah","productClass":"EOSSTB",\
"asVersion":"4.14_62_20181212210000_master_eos_sprint57","appVersion":"4.14_62_20181212210000_master_eos_sprint57",\
"firmwareVersion":"DCX960__-mon-rel-00.01-057-ah-AL-20181212210000-un000",\
"imageName":"DCX960__-mon-rel-00.01-057-ah-AL-20181212210000-un000",\
"netflixEsn":"LGBEEN3OM100000000000000000000000000071543","ethernetMacAddress":"BC:64:4B:F7:E9:E7",\
"wirelessMacAddress":"BC:64:4B:F7:E9:E8","caProject":"021101","caCakVersion":"D-BVIAC-AGJBW-NAKBP",\
"caPrmVersion":"","caSerialNumber": "28 6152 3313 26","caNUID": "30 1588 9061 63",\
"caChipsetType":"05 4525 9616 13","caChipsetRev":"B1","caParingSaId":8,\
"caCscMaxIndex":""}""" % CPE_ID)

PROFILE_ID = """3f4885e0-8b42-11e8-86a4-a7547cdce0b1_nl~~23MasterProfile"""

CURRENT_PROFILE = json.loads("""{"id":"%s-8eb4-42f1-a436-84a50e5c6f41","name":"Shared Profile",\
"isShared":true,"color":"GRAY"}""" % CPE_ID)

UISTATE = json.loads("""{"VIDEO_LAYER":{},"APPLICATION_LAYER":{"id":"body","textValue":"",\
"position":{"x":0,"y":0,"width":1920,"height":1080},"textStyle":{"color":"#ffffffff"},\
"visible":true,"opacity":255,"children":[{"viewState":{},"textValue":"","position":{"x":0,"y":0,\
"width":0,"height":0},"textStyle":{"color":"#ffffffff"},"visible":true,"opacity":255,\
"children":[{"id":"fatalErrorBackground","textValue":"","position":{"x":0,"y":0,"width":1920,\
"height":1080},"textStyle":{"color":"#ffffffff"},"background":{"image":"","color":"#101010ff"},\
"visible":true,"opacity":255,"children":[{"id":"fatalErrorOuterContainer","textValue":"",\
"position":{"x":0,"y":0,"width":1920,"height":1080},"textStyle":{"color":"#ffffffff"},\
"visible":true,"opacity":255,"children":[{"id":"fatalErrorErrorIcon","textValue":")",\
"iconKeys":"WARN_TRIANGLE","position":{"x":143,"y":147,"width":104,"height":104},\
"textStyle":{"color":"#ffffffff"},\
"visible":true,"opacity":255,"children":[],"tags":[]},{"id":"fatalErrorTitle",\
"textValue":"Sorry,youcan'twatchTVatthemoment.CS1160","position":{"x":338,"y":133,"width":1500,\
"height":180},\
"textStyle":{"color":"#ffffffff"},"visible":true,"opacity":255,"children":[],"tags":[]},\
{"id":"fatalErrorInnerContainer","textValue":"","position":{"x":338,"y":133,"width":1200,\
"height":1080},\
"textStyle":{"color":"#ffffffff"},"visible":true,"opacity":255,\
"children":[{"id":"fatalErrorMessage",\
"textValue":"Yourchannelsunavailable.We'llresolvethisproblemassoonaspossible.Pleasetryagainlater",\
"position":{"x":338,"y":369,"width":1200,"height":91},"textStyle":{"color":"#b6b6baff"},\
"visible":true,"opacity":255,\
"children":[],"tags":[]},{"id":"fatalErrorButtonsContainer","textValue":"","position":{"x":338,\
"y":520,"width":1200,\
"height":1080},"textStyle":{"color":"#ffffffff"},"visible":true,"opacity":255,\
"children":[{"id":"fatalErrorButton1",\
"textValue":"","position":{"x":338,"y":520,"width":761,"height":81},"textStyle":{"color":"#e9e9eaff"},\
"visible":true,\
"opacity":255,"children":[],"tags":[]},{"id":"fatalErrorButton2","textValue":"",\
"position":{"x":338,"y":631,"width":761,"height":81},"textStyle":{"color":"#e9e9eaff"},\
"visible":true,"opacity":255,"children":[],"tags":[]},{"id":"fatalErrorButton3",\
"textValue":"","position":{"x":338,"y":742,"width":761,"height":81},\
"textStyle":{"color":"#e9e9eaff"},\
"visible":true,"opacity":255,"children":[],"tags":[]}],"tags":[]}],"tags":[]}],\
"tags":[]}],"tags":[]}],"tags":[]}],\
"tags":[]},"HEADER_LAYER":{},"OVERLAY_LAYER":{},"CURRENT_POPUP_LAYER":{},"ERROR_POPUP_LAYER":{},\
"VOICE_POPUP_LAYER":{},"TIPS_LAYER":{},"TOAST_LAYER":{}}""")

REBOOT = """OperationSuccessful"""

ASPECT_RADIO = json.loads("""{"id":"%s-2415261c-548c-4d29-b92e-75af2a81933a",\
"type":"http","payload":"16:9"}""" % CPE_ID)

OSD_LANG = json.loads("""{"id":"%s-2415261c-548c-4d29-b92e-75af2a81933a",\
"type":"http","payload":"16:9"}""" % CPE_ID)

POWER_STATE = json.loads("""{"id":"%s-e8a81761-0403-4a7a-a28e-a8f21312ae8a","type":"http",\
"payload":{"currentState":"ActiveStandby","stateSource":"Reboot"}}""" % CPE_ID)

HDMI_RESOUTION = """HDMI_RESOUTION"""

AUTO_STAND_BY = """AUTO_STAND_BY"""

STAND_BY_MODE = """STAND_BY_MODE"""

FTI_STATE = """FTI_STATE"""

WIFI_CLIENT_ENABLE = """WIFI_CLIENT_ENABLE"""

SEND_STANDBY = """SEND_STANDBY"""

HDMI_RESOUTION = {'type': 'http',
                  'id': '3C36E4-EOSSTB-003469707008-1ae4d719-288d-40d6-a61e-be18624cd08b',
                  'payload': 'FromTv'}

URL_MAPPING = {
    "purchase-service/purchase-service/info": PURCHASE_SRVC_INFO,
    "purchase-service/purchase-service/health-checks": PURCHASE_SRVC_HEALTH,
    "mapng/vod-service/info": VOD_SRVC_INFO,
    "mapng/vod-service/health-checks": VOD_SRVC_HEALTH,
    "discovery-service/discovery-service/info": DISCOVERY_SRVC_INFO,
    "discovery-service/discovery-service/health-checks": DISCOVERY_SRVC_HEALTH,
    "session-service/session-service/info": SESSION_SRVC_INFO,
    "session-service/session-service/health-checks": SESSION_SRVC_HEALTH,
    "recording-service/recording-service/info": RECORDING_SRVC_INFO,
    "recording-service/recording-service/health-checks": RECORDING_SRVC_HEALTH,
    "epg.": EPG_SRVC_INFO,
    "settings/setSetting/cpe.uiTestTools": ENABLE_TESTTOOLS,
    "configuration/getConfig/cpe": CONF_CPE,
    "v2/config/ProfileId": PROFILE_ID,
    "auth/getCurrentProfile": CURRENT_PROFILE,
    "v2/state": UISTATE,
    "power-manager/reboot": REBOOT,
    "settings/getSetting/cpe.aspectRatio": ASPECT_RADIO,
    "settings/getSetting/profile.osdLang": OSD_LANG,
    "power-manager/getPowerState": POWER_STATE,
    "settings/getSetting/cpe.hdmiResolution": HDMI_RESOUTION,
    "settings/getSetting/cpe.autoStandby": AUTO_STAND_BY,
    "settings/getSetting/cpe.standByMode": STAND_BY_MODE,
    "settings/getSetting/cpe.ftiState": FTI_STATE,
    "settings/getSetting/cpe.wifiClientEnabled": WIFI_CLIENT_ENABLE,
    "keyinjector/emulateuserevent/80/8000/source=2":SEND_STANDBY
}


def mock_http(*args, **kwargs):
    """A function to mock HTTP requests."""

    url = args[0]
    raise_request = ""
    BuiltIn().log_to_console("URL: %s" % url)
    xap_data = kwargs["data"]
    data = dict(json=lambda x: "", status_code=404, reason="Not Found", headers={})
    if UNREACHABLE_IP in url:
        raise_request = "UNREACHABLE_IP"
    elif UNRESOLVABLE_HOST in url:
        raise_request = "UNRESOLVABLE_HOST"
    elif "http" in url:
        BuiltIn().log_to_console("xap_data: %s" % xap_data)
        for key, value in sorted(list(URL_MAPPING.items())):
            BuiltIn().log_to_console("key: %s" % key)
            if key in xap_data:
                BuiltIn().log_to_console(3)
                data = dict(json=mock.Mock(return_value=value), status_code=200, reason="OK")
                break
    if raise_request == "UNREACHABLE_IP":
        raise requests.exceptions.ConnectionError("[WinError 10061] No connection could be made " +
                                                  "because the target machine actively refused it")
    if raise_request == "UNRESOLVABLE_HOST":
        raise socket.gaierror("[Errno 11001] getaddrinfo failed")

    return type("", (), data)()


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


class Test_XAP_http(TestCaseNameAsDescription):
    """Class contains unit tests of XAP http method."""

    @mock.patch("requests.post", side_effect=mock_http)
    def test_get_response_200(self, *args):
        """Check returned result of XAP.http() method for successful responses from XAP."""
        url = "http://127.0.0.1:81/purchase-service/purchase-service/info"
        result = XAP(LAB_CONF["MOCK"], CPE_ID).http(url)
        self.assertEqual(result, (200, "OK", PURCHASE_SRVC_INFO))

    @mock.patch("requests.post", side_effect=mock_http)
    def test_get_response_404(self, *args):
        """Check returned result of XAP.http() method for unsuccessful responses from XAP."""
        result = XAP(LAB_CONF["MOCK"], CPE_ID).http("http://nowhere.com/noservice")
        self.assertEqual(result, (404, "Not Found", ""))

    @mock.patch("requests.post", side_effect=mock_http)
    def test_get_response_unreachable(self, *args):
        """Check returned result of XAP.http() method if XAP host is unreachable."""
        result = XAP(LAB_CONF["UNREACHABLE"], CPE_ID).http("http://unreachable.com/noservice")
        self.assertEqual(result, (None, "", ""))

    @mock.patch("requests.post", side_effect=mock_http)
    def test_get_response_unresolvable(self, *args):
        """Check returned result of XAP.http() method if XAP endpoint is unresolvable."""
        result = XAP(LAB_CONF["UNRESOLVABLE"], CPE_ID).http("http://unresolvable.com/noservice")
        self.assertEqual(result, (None, "", ""))


class TestKeywords_XAP_http(TestCaseNameAsDescription):
    """Class contains unit tests of XAP keywords visible in Robot Framework."""

    @mock.patch("requests.post", side_effect=mock_http)
    def test_purchase_service_info(self, *args):
        """Check result of XAP.http() method executed for the info call of purchase service."""
        result = Keywords().call_purchase_service_info(LAB_CONF["MOCK"], CPE_ID)
        self.assertEqual(result, (200, "OK", PURCHASE_SRVC_INFO))

    @mock.patch("requests.post", side_effect=mock_http)
    def test_purchase_service_health(self, *args):
        """Check result of XAP.http() method executed for healthcheck call of purchase service."""
        result = Keywords().call_purchase_service_health(LAB_CONF["MOCK"], CPE_ID)
        self.assertEqual(result, (200, "OK", PURCHASE_SRVC_HEALTH))

    @mock.patch("requests.post", side_effect=mock_http)
    def test_vod_service_info(self, *args):
        """Check result of XAP.http() method executed for the info call of VOD service."""
        result = Keywords().call_vod_service_info(LAB_CONF["MOCK"], CPE_ID)
        self.assertEqual(result, (200, "OK", VOD_SRVC_INFO))

    @mock.patch("requests.post", side_effect=mock_http)
    def test_vod_service_health(self, *args):
        """Check result of XAP.http() method executed for healthcheck call of VOD service."""
        result = Keywords().call_vod_service_health(LAB_CONF["MOCK"], CPE_ID)
        self.assertEqual(result, (200, "OK", VOD_SRVC_HEALTH))

    @mock.patch("requests.post", side_effect=mock_http)
    def test_discovery_service_info(self, *args):
        """Check result of XAP.http() method executed for the info call of discovery service."""
        result = Keywords().call_discovery_service_info(LAB_CONF["MOCK"], CPE_ID)
        self.assertEqual(result, (200, "OK", DISCOVERY_SRVC_INFO))

    @mock.patch("requests.post", side_effect=mock_http)
    def test_discovery_service_health(self, *args):
        """Check result of XAP.http() method executed for healthcheck call of discovery service."""
        result = Keywords().call_discovery_service_health(LAB_CONF["MOCK"], CPE_ID)
        self.assertEqual(result, (200, "OK", DISCOVERY_SRVC_HEALTH))

    @mock.patch("requests.post", side_effect=mock_http)
    def test_session_service_info(self, *args):
        """Check result of XAP.http() method executed for the info call of session service."""
        result = Keywords().call_session_service_info(LAB_CONF["MOCK"], CPE_ID)
        self.assertEqual(result, (200, "OK", SESSION_SRVC_INFO))

    @mock.patch("requests.post", side_effect=mock_http)
    def test_session_service_health(self, *args):
        """Check result of XAP.http() method executed for healthcheck call of session service."""
        result = Keywords().call_session_service_health(LAB_CONF["MOCK"], CPE_ID)
        self.assertEqual(result, (200, "OK", SESSION_SRVC_HEALTH))

    @mock.patch("requests.post", side_effect=mock_http)
    def test_recording_service_info(self, *args):
        """Check result of XAP.http() method executed for the info call of recording service."""
        result = Keywords().call_recording_service_info(LAB_CONF["MOCK"], CPE_ID)
        self.assertEqual(result, (200, "OK", RECORDING_SRVC_INFO))

    @mock.patch("requests.post", side_effect=mock_http)
    def test_recording_service_health(self, *args):
        """Check result of XAP.http() method executed for healthcheck call of recording service."""
        result = Keywords().call_recording_service_health(LAB_CONF["MOCK"], CPE_ID)
        self.assertEqual(result, (200, "OK", RECORDING_SRVC_HEALTH))

    @mock.patch("requests.post", side_effect=mock_http)
    def test_epg_service_info(self, *args):
        """Check result of XAP.http() method executed for the info call of epg service."""
        result = Keywords().call_epg_service_info(LAB_CONF["MOCK"], CPE_ID)
        self.assertEqual(result, (200, "OK", EPG_SRVC_INFO))

    @mock.patch("requests.post", side_effect=mock_http)
    def test_enable_test_tools(self, *args):
        """Check result of XAP.http() method executed for enable test tools on CPE."""
        result = Keywords().enable_test_tools(LAB_CONF["MOCK"], CPE_ID)
        self.assertEqual(result, (200, "OK", ENABLE_TESTTOOLS))

    @mock.patch("requests.post", side_effect=mock_http)
    def test_get_config_cpe(self, *args):
        """Check result of XAP.http() method executed for get Config CPE on CPE."""
        result = Keywords().get_config_cpe(LAB_CONF["MOCK"], CPE_ID)
        self.assertEqual(result, (200, "OK", CONF_CPE))

    @mock.patch("requests.post", side_effect=mock_http)
    def test_profile_id(self, *args):
        """Check result of XAP.http() method executed for get profileId on CPE."""
        result = Keywords().profile_id(LAB_CONF["MOCK"], CPE_ID)
        self.assertEqual(result, (200, "OK", PROFILE_ID))

    @mock.patch("requests.post", side_effect=mock_http)
    def test_get_current_profile(self, *args):
        """Check result of XAP.http() method executed for get CurrentProfile on CPE."""
        result = Keywords().get_current_profile(LAB_CONF["MOCK"], CPE_ID)
        self.assertEqual(result, (200, "OK", CURRENT_PROFILE))

    @mock.patch("requests.post", side_effect=mock_http)
    def test_ui_state(self, *args):
        """Check result of XAP.http() method executed for get UI State on CPE."""
        result = Keywords().ui_state(LAB_CONF["MOCK"], CPE_ID)
        self.assertEqual(result, (200, "OK", UISTATE))

    @mock.patch("requests.post", side_effect=mock_http)
    def test_reboot(self, *args):
        """Check result of XAP.http() method executed for reboot CPE."""
        result = Keywords().reboot(LAB_CONF["MOCK"], CPE_ID)
        self.assertEqual(result, (200, "OK", REBOOT))

    @mock.patch("requests.post", side_effect=mock_http)
    def test_aspect_ratio(self, *args):
        """Check result of XAP.http() method executed for get aspectRatio on CPE."""
        result = Keywords().aspect_ratio(LAB_CONF["MOCK"], CPE_ID)
        self.assertEqual(result, (200, "OK", ASPECT_RADIO))

    @mock.patch("requests.post", side_effect=mock_http)
    def test_osd_lang(self, *args):
        """Check result of XAP.http() method executed for get osdLang on CPE."""
        result = Keywords().osd_lang(LAB_CONF["MOCK"], CPE_ID)
        self.assertEqual(result, (200, "OK", OSD_LANG))

    @mock.patch("requests.post", side_effect=mock_http)
    def test_get_power_state(self, *args):
        """Check result of XAP.http() method executed for get getPowerState on CPE."""
        result = Keywords().get_power_state(LAB_CONF["MOCK"], CPE_ID)
        self.assertEqual(result, (200, "OK", POWER_STATE))

    @mock.patch("requests.post", side_effect=mock_http)
    def test_get_hdmi_resolution(self, *args):
        """Check result of XAP.http() method executed for get hdmiResolution on CPE."""
        result = Keywords().get_hdmi_resolution(LAB_CONF["MOCK"], CPE_ID)
        self.assertEqual(result, "FromTv")

    @mock.patch("requests.post", side_effect=mock_http)
    def test_auto_stand_by(self, *args):
        """Check result of XAP.http() method executed for get autoStandby on CPE."""
        result = Keywords().auto_standby(LAB_CONF["MOCK"], CPE_ID)
        self.assertEqual(result, (200, "OK", AUTO_STAND_BY))

    @mock.patch("requests.post", side_effect=mock_http)
    def test_stand_by_mode(self, *args):
        """Check result of XAP.http() method executed for get standByMode on CPE."""
        result = Keywords().stand_by_mode(LAB_CONF["MOCK"], CPE_ID)
        self.assertEqual(result, (200, "OK", STAND_BY_MODE))

    @mock.patch("requests.post", side_effect=mock_http)
    def test_fti_state(self, *args):
        """Check result of XAP.http() method executed for get ftiState on CPE."""
        result = Keywords().fti_state(LAB_CONF["MOCK"], CPE_ID)
        self.assertEqual(result, (200, "OK", FTI_STATE))

    @mock.patch("requests.post", side_effect=mock_http)
    def test_wifi_client_enabled(self, *args):
        """Check result of XAP.http() method executed for get wifiClientEnabled on CPE."""
        result = Keywords().wifi_client_enabled(LAB_CONF["MOCK"], CPE_ID)
        self.assertEqual(result, (200, "OK", WIFI_CLIENT_ENABLE))

    @mock.patch("requests.post", side_effect=mock_http)
    def test_send_stand_by(self, *args):
        """Check result of XAP.http() method executed for send Standby command on CPE."""
        result = Keywords().send_standby(LAB_CONF["MOCK"], CPE_ID)
        self.assertEqual(result, (200, "OK", SEND_STANDBY))

def suite_xap_http():
    """A function builds a test suite for TraxisRequests() class methods."""
    return unittest.makeSuite(Test_XAP_http, "test")


def suite_keywords_xap_http():
    """A function builds a test suite for TraxisRequests() class methods."""
    return unittest.makeSuite(TestKeywords_XAP_http, "test")


def run_tests():
    """A function to run unit tests (real Traxis will not be used)."""
    suites = [
        suite_xap_http(),
        suite_keywords_xap_http()
    ]
    for suite in suites:
        unittest.TextTestRunner(verbosity=2).run(suite)


def debug():
    """A function to get recordings from real Traxis in "lab5A UPCless" lab."""
    result = Keywords().call_epg_service_index(LAB_CONF["REAL"], CPE_ID, 'be', 'nl')
    # result = Keywords().enable_test_tools(LAB_CONF["ITC"], CPE_ID)
    # print result
    #encoded = result[2]["payload"]["error"]["body"].encode('utf8')
    #import zlib, gzip, StringIO
    #decoded = gzip.GzipFile(fileobj=StringIO.StringIO(encoded)).read()
    #decoded = zlib.decompress(encoded, zlib.MAX_WBITS | 16)  # gzip
    #decoded = zlib.decompress(encoded, zlib.MAX_WBITS)      # deflate
    #decoded = zlib.decompress(encoded, -zlib.MAX_WBITS)     # zlib
    return result


if __name__ == "__main__":
    # debug()
    run_tests()
