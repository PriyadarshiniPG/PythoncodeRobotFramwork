# pylint: disable=W0613
# pylint: disable=unused-argument,invalid-name
# Disabled pylint "unused-argument" complaining on args for mock patches'

"""Unit tests of of Personalization Microservice tests for HZN 4.

Tests use mock module and do not send real requests to real Personalization Service.

v0.0.1 - Anuj Teotia: Added unittest:  get_profile_id.
"""

import unittest
try:
    import mock
except ImportError:
    import unittest.mock as mock
import socket
import json
import requests
from robot.libraries.BuiltIn import BuiltIn
from .keywords import Keywords, PersonalizationServiceRequests

CONF = {
    "MICROSERVICES": {
        "OBOQBR": "oboqbr.some_lab.nl.dmdsdp.com",
        }
    }

MOCK_PROFILE_ID = "2b3b1659-0b7c-430e-8297-0619c868e4a2"

GET_PROFILES_AND_DEVICES_RESPONSE = """{
    "customerId": "ff6e8c50-7635-11e9-9c19-11751cdc1f9c_nl",
    "customerStatus": "ACTIVE",
    "statusModifiedDate": "2019-05-14T10:49:50.592Z",
    "lastModified": "2020-02-21T09:23:35.291Z",
    "pin": "5280",
    "ageLock": 6,
    "dvrPrePadding": 60,
    "dvrPostPadding": 120,
    "countryId": "nl",
    "cityId": 105,
    "isFtiPassed": true,
    "assignedDevices": [
        {
            "deviceId": "3C36E4-EOSSTB-003469693109",
            "customerId": "ff6e8c50-7635-11e9-9c19-11751cdc1f9c_nl",
            "defaultProfileId": "6bcc54db-d2fa-49ff-9002-f88b917cddf0",
            "deviceType": "GATEWAY",
            "platformType": "HORIZON",
            "lastModified": "2020-02-21T11:40:43.735Z",
            "smartCardId": "0000115447",
            "serialNumber": "0000115447",
            "settings": {
                "autoStandby": 1440,
                "standbyMode": "ActiveStandby",
                "aspectRatio": "16:9",
                "hdmiResolution": "4K",
                "isCecEnabled": true,
                "oneTouchViewTurnOffPolicy": true,
                "isTvAutoStartup": true,
                "sdtvDisplayMode": "FullMode",
                "widescreenDisplayMode": "FullScreen",
                "volume": 50,
                "primaryVideoOutput": "HDMI",
                "customData": "[0]",
                "ccDigitalService": "Primary",
                "ccAnalogService": "CC1",
                "deviceFriendlyName": "Mediabox",
                "ccsMessages": [
                    "3C36E4-EOSSTB-003469693109_226"
                ]
            },
            "capabilities": {
                "hasHDD": false
            }
        }
    ],
    "lockedChannels": [],
    "customerOptIns": [
        {
            "lastModified": "2020-01-02T06:34:52.455Z",
            "optInType": "apps",
            "enabled": true
        },
        {
            "lastModified": "2019-05-14T10:49:50.597Z",
            "optInType": "personalization",
            "enabled": true
        },
        {
            "lastModified": "2019-05-14T10:49:50.599Z",
            "optInType": "replay",
            "enabled": true
        }
    ],
    "profiles": [
        {
            "profileId": "6bcc54db-d2fa-49ff-9002-f88b917cddf0",
            "customerId": "ff6e8c50-7635-11e9-9c19-11751cdc1f9c_nl",
            "name": "Shared Profile",
            "shared": true,
            "colour": "GRAY",
            "options": {
                "lang": "en",
                "langModifiedAt": "2019-07-19T09:09:32.623Z",
                "audioLang": "nl",
                "audioLangModifiedAt": "2019-07-05T13:36:18.653Z",
                "subLang": "en",
                "subLangModifiedAt": "2019-07-05T14:11:51.725Z",
                "hardOfHearing": false,
                "hardOfHearingModifiedAt": "2019-05-14T10:49:50.610Z",
                "audioDescription": false,
                "audioDescriptionModifiedAt": "2020-02-21T01:03:18.978Z",
                "showSubtitles": false,
                "showSubtitlesModifiedAt": "2019-07-08T12:50:53.259Z",
                "keyboardMode": "Normal",
                "keyboardModeModifiedAt": "2020-01-16T00:34:46.584Z"
            },
            "jsonOptions": {
                "tipsAndTricks": {
                    "ids": [
                        "MENU_GO_TO_TOP",
                        "FLO_SELECTION",
                        "EPG_DAY_SKIP",
                        "ANOW_MOMENT",
                        "BACK_TO_TV",
                        "PLAY_IMMEDIATELY",
                        "TV_PAIRING",
                        "PULL_VOICE"
                    ],
                    "timestamps": [
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0
                    ]
                },
                "tipsAndTricksModifiedAt": "2020-02-21T11:40:42.509Z"
            },
            "favoriteChannels": ["1", "2"],
            "recentlyUsedApps": [
                "com.libertyglobal.app.netflix",
                "com.libertyglobal.app.youtube"
            ],
            "recentlyUsedSettings": [
                "lockChannels",
                "factoryReset",
                "diagnostics",
                "audioDescription",
                "about",
                "changeConnectionType",
                "changePin",
                "hdmiResolution",
                "personalisation",
                "standByMode",
                "standByTimer",
                "deleteAllRecordings",
                "menuLanguage",
                "subtitleOptions",
                "audioLanguage"
            ],
            "lastModified": "2020-02-21T11:40:42.510Z"
        }
    ]
}"""

AVAILABLE_GENRES = """[
    {
        "image": "action",
        "name": "Action",
        "termIds": [
            "14@1",
            "10@1",
            "9@1"
        ],
        "features": [
            "action",
            "action adventure",
            "sci-fi action",
            "sci-fi action",
            "drama action"
        ]
    },
    {
        "image": "comedy",
        "name": "Comedy",
        "termIds": [
            "4@0",
            "14@24",
            "14@28",
            "14@7",
            "14@9",
            "37@0",
            "47@0",
            "179@0"
        ],
        "features": [
            "comedy",
            "comedy drama",
            "sitcom",
            "comedy sketch",
            "bollywood comedy",
            "workplace comedy",
            "crime comedy"
        ]
    },
    {
        "image": "drama",
        "name": "Drama",
        "termIds": [
            "14@14",
            "14@26",
            "14@31",
            "36@0",
            "38@0",
            "9@5",
            "9@8",
            "10@7"
        ],
        "features": [
            "drama",
            "comedy drama",
            "historical drama",
            "thriller drama",
            "crime drama"
        ]
    },
    {
        "image": "romance",
        "name": "Romance",
        "termIds": [
            "14@27",
            "10@9",
            "14@27",
            "14@33",
            "45@0",
            "9@10"
        ],
        "features": [
            "romance",
            "romantic comedy",
            "romantic drama"
        ]
    },
    {
        "image": "thrillers",
        "name": "Thrillers",
        "termIds": [
            "14@34",
            "14@34",
            "48@0",
            "9@13",
            "10@11"
        ],
        "features": [
            "thriller",
            "action thriller",
            "crime thriller"
        ]
    },
    {
        "image": "sports",
        "name": "Sports",
        "termIds": [
            "27@0",
            "27@0",
            "27@38",
            "27@34",
            "27@12",
            "27@104",
            "27@58"
        ],
        "features": [
            "sports",
            "sports documentary",
            "professional football",
            "english premiership football"
        ]
    },
    {
        "image": "news-and-info",
        "name": "News & Info",
        "termIds": [
            "22@0"
        ],
        "features": [
            "news",
            "business news",
            "news magazine"
        ]
    },
    {
        "image": "kids",
        "name": "Kids",
        "termIds": [
            "3@0",
            "14@8",
            "3@1",
            "3@2",
            "3@3",
            "3@4",
            "3@5"
        ],
        "features": [
            "children’s family",
            "children’s",
            "children’s cartoon",
            "children’s adventure",
            "children’s factual",
            "children’s educational",
            "children’s factual",
            "children's action",
            "children's animation",
            "children's family",
            "schoolkids",
            "preschoolers",
            "children's preschool"
        ]
    },
    {
        "image": "game-shows",
        "name": "(Game) Shows",
        "termIds": [
            "3@8",
            "15@0"
        ],
        "features": [
            "entertainment game show"
        ]
    },
    {
        "image": "culture-and-music",
        "name": "Culture & Music",
        "termIds": [
            "21@0"
        ],
        "features": [
            "concert",
            "live music"
        ]
    },
    {
        "image": "reality",
        "name": "Reality",
        "termIds": [
            "8@10"
        ],
        "features": [
            "factual reality entertainment",
            "reality docusoap",
            "reality show"
        ]
    },
    {
        "image": "travel",
        "name": "Travel",
        "termIds": [
            "30@0"
        ],
        "features": [
            "travel"
        ]
    }
]"""

CUSTOMER_INFORMATION_BY_DEVICE_ID = """
{"customerId":"d28d9ca0-762e-11e9-9c19-11751cdc1f9c_nl","customerStatus":"ACTIVE",
"statusModifiedDate":"2019-05-14T09:58:28.890Z","lastModified":"2020-02-11T14:07:02.070Z",
"pin":"0000","ageLock":6,"dvrPrePadding":60,"dvrPostPadding":120,"countryId":"nl","cityId":105,
"isFtiPassed":true,"lockedChannels":[],"customerOptIns":[{"lastModified":"2019-10-10T09:57:26.514Z",
"optInType":"apps","enabled":true},{"lastModified":"2019-05-14T09:58:28.899Z",
"optInType":"personalization","enabled":true},{"lastModified":"2019-05-14T09:58:28.902Z",
"optInType":"replay","enabled":true}]}"""

CREATED_PROFILE = """{
    "profileId": "5068764c-56ba-4d5b-8cfb-7f266683d501"
}"""

def mock_requests_get(*args, **kwargs):
    """A Function to create the fake response"""
    url = args[0]
    # BuiltIn().log_to_console(url)
    headers = kwargs['headers']
    # BuiltIn().log_to_console(headers)
    customer_id = headers.get('X-cus', None)
    # BuiltIn().log_to_console(customer_id)
    params = kwargs.get('params', None)
    # BuiltIn().log_to_console(customer_id)
    if "/customer/" in url and "/profiles" in url:
        # "get_profile_id" requests
        if "dummy_id" in customer_id:
            response_data = dict(text=MOCK_PROFILE_ID, status_code=200, reason="OK")
        elif "profiles" in url and "404" in customer_id:
            response_data = dict(text="", status_code=404, reason="Not found")
        elif "refused" in customer_id:
            raise requests.exceptions.ConnectionError("[WinError 10061] No connection could be made " +
                                                      "because the target machine actively refused it")
        elif "failed" in customer_id:
            raise socket.gaierror("[Errno 11001] getaddrinfo failed")
    elif "/customer/" in url and "?with=profiles,devices" in url:
        # "get_profiles_and_devices" request
        if "dummy_id" in customer_id:
            response_data = dict(text=GET_PROFILES_AND_DEVICES_RESPONSE, status_code=200, reason="OK")
        if "unexpected" in customer_id:
            response_data = dict(text="", status_code=404, reason="Unexpected customer_id")
    elif "/v2/commons/availableGenres" in url:
        # "get_available_genres" request
        if "?language=en" in url:
            response_data = dict(text=AVAILABLE_GENRES, status_code=200, reason="OK")
        elif "?language=not_200" in url:
            response_data = dict(text="", status_code=404, reason="Not found")
    elif "/v1/customer" and params:
        # "get_customer_information_by_device_id" request
        if params["byDeviceId"] == "dummy_cpe_id":
            response_data = dict(text=CUSTOMER_INFORMATION_BY_DEVICE_ID, status_code=200, reason="OK")
        elif params["byDeviceId"] == "not_200":
            response_data = dict(text="", status_code=404, reason="Not found")
    return type("", (), response_data)()

def mock_requests_put(*args, **kwargs):
    """A Function to create the fake response"""
    url = args[0]
    headers = kwargs['headers']
    json_data = kwargs.get('json', None)
    # BuiltIn().log_to_console(url)
    customer_id = headers.get('X-cus', None)
    if "/v1/customer/" in url and "/profiles/" in url and json_data:
        if "recentlyUsedApps" in json_data:
        # "reset_recently_used_apps_via_personalization_service" requests
            if "dummy_customer_id" in customer_id:
                response_data = dict(text="{}", status_code=204, reason="No Content")
            if "not_200" in customer_id:
                response_data = dict(text="", status_code=404, reason="Not Found")

    return type("", (), response_data)()

def mock_requests_post(*args, **kwargs):
    """A Function to create the fake response"""
    url = args[0]
    headers = kwargs['headers']
    json_data = kwargs.get('data', None)
    # BuiltIn().log_to_console(url)
    customer_id = headers.get('X-cus', None)
    if "/v1/customer/" in url and "/profiles" in url and json_data:
        if "name" in json_data and "colour" in json_data and "favoriteChannels":
        # "create_profile" requests
            if "dummy_customer_id" in customer_id:
                response_data = dict(text=CREATED_PROFILE, status_code=200, reason="OK")
            if "not_200" in customer_id:
                response_data = dict(text="", status_code=404, reason="Not Found")

    return type("", (), response_data)()


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


class PersonalizationServiceTests(TestCaseNameAsDescription):
    """Class contains unit tests of PersonalizationService keyword."""

    @classmethod
    def setUpClass(cls):
        cls.keywords = Keywords()
        cls.conf = CONF
        cls.personalization_service_requests = PersonalizationServiceRequests(cls.conf)
        cls.base_url = "http://oboqbr.some_lab.nl.dmdsdp.com/personalization-service"

    @classmethod
    def tearDownClass(cls):
        pass

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_profile_id_ok(self, mocked_requests_get, *args):
        """Test to check successful response for profile Id"""
        customer_id = "dummy_id"
        expected_url = '%s/v1/customer/%s/profiles' % (self.base_url, customer_id)
        response = self.keywords.get_profile_id(self.conf, customer_id)
        self.assertEqual(response.text, MOCK_PROFILE_ID)
        mocked_requests_get.assert_called_with(
            expected_url, headers={'accept': 'application/json', 'X-cus': customer_id}
        )

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_profile_id_refused(self, mocked_requests_get, *args):
        """Test to check refused connection for profile Id"""
        customer_id = "refused"
        expected_url = '%s/v1/customer/%s/profiles' % (self.base_url, customer_id)
        response = self.keywords.get_profile_id(self.conf, customer_id)
        expected_error = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(str(response.error), expected_error)
        mocked_requests_get.assert_called_with(
            expected_url, headers={'accept': 'application/json', 'X-cus': customer_id}
        )

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_profile_id_failed(self, mocked_requests_get, *args):
        """Test to check failed connection for profile Id"""
        customer_id = "failed"
        expected_url = '%s/v1/customer/%s/profiles' % (self.base_url, customer_id)
        response = self.keywords.get_profile_id(self.conf, customer_id)
        expected_error = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(str(response.error), expected_error)
        mocked_requests_get.assert_called_with(
            expected_url, headers={'accept': 'application/json', 'X-cus': customer_id}
        )

    @mock.patch.object(BuiltIn, "log_to_console", side_effect=print)
    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_profile_id_404(self, mocked_requests_get, mocked_log_to_console, *args):
        """Test to check 'get_profile_id' method"""
        customer_id = "404"
        expected_url = '%s/v1/customer/%s/profiles' % (self.base_url, customer_id)
        response = self.keywords.get_profile_id(self.conf, customer_id)
        self.assertFalse(response.text)
        self.assertEqual(response.status_code, int(customer_id))
        self.assertEqual(response.reason, "Not found")
        mocked_requests_get.assert_called_with(
            expected_url, headers={'accept': 'application/json', 'X-cus': customer_id}
        )
        mocked_log_to_console.assert_called_with(
            "Send GET to %s Status code: 404, Reason: Not found" % expected_url
        )

    @mock.patch.object(BuiltIn, "log", side_effect=print)
    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_profiles_and_devices(self, mocked_requests_get, mocked_log, *args):
        """Test to check 'get_profiles_and_devices' method"""
        customer_id = "dummy_id"
        expected_url = '%s/v1/customer/%s?with=profiles,devices' % (self.base_url, customer_id)
        response = self.personalization_service_requests.get_profiles_and_devices(customer_id)
        expected_messages = [
            "Url=%s and headers={'accept': 'application/json', 'X-cus': '%s'}" % (
                expected_url, customer_id),
            "Exception message: Cannot access execution context - Ignoring and continue"
        ]
        actual_messages = []
        for loged_message in mocked_log.call_args_list:
            actual_messages.append(loged_message.args[0])
        self.assertEqual(sorted(expected_messages), sorted(actual_messages))
        self.assertEqual(response.text, GET_PROFILES_AND_DEVICES_RESPONSE)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.reason, "OK")
        mocked_requests_get.assert_called_with(
            expected_url, headers={'accept': 'application/json', 'X-cus': customer_id}
        )

    @mock.patch.object(BuiltIn, "log_to_console", side_effect=print)
    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_profiles_and_devices_unexpected_response_code(
            self, mocked_requests_get, mocked_log_to_console, *args):
        """Test to check 'get_profiles_and_devices' method"""
        customer_id = "unexpected"
        expected_url = '%s/v1/customer/%s?with=profiles,devices' % (self.base_url, customer_id)
        response = self.personalization_service_requests.get_profiles_and_devices(customer_id)
        expected_messages = [
            "Send GET to %s Status code: 404, Reason: Unexpected customer_id" % expected_url
        ]
        actual_messages = []
        for loged_message in mocked_log_to_console.call_args_list:
            actual_messages.append(loged_message.args[0])
        self.assertEqual(sorted(expected_messages), sorted(actual_messages))
        self.assertEqual(response.text, "")
        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.reason, "Unexpected customer_id")
        mocked_requests_get.assert_called_with(
            expected_url, headers={'accept': 'application/json', 'X-cus': customer_id}
        )

    @mock.patch("builtins.print", side_effect=print)
    @mock.patch("requests.get", side_effect=requests.exceptions.ConnectionError)
    def test_get_profiles_and_devices_response_exception(
            self, mocked_requests_get, mocked_log_to_console, *args):
        """Test to check 'get_profiles_and_devices' method"""
        customer_id = "unexpected"
        expected_url = '%s/v1/customer/%s?with=profiles,devices' % (self.base_url, customer_id)
        response = self.personalization_service_requests.get_profiles_and_devices(customer_id)
        expected_messages = [
            "Could not send GET %s due to " % expected_url
        ]
        actual_messages = []
        for loged_message in mocked_log_to_console.call_args_list:
            actual_messages.append(loged_message.args[0])
        self.assertEqual(sorted(expected_messages), sorted(actual_messages))
        self.assertEqual(response.text, None)
        self.assertEqual(response.status_code, None)
        self.assertEqual(response.reason, None)
        mocked_requests_get.assert_called_with(
            expected_url, headers={'accept': 'application/json', 'X-cus': customer_id}
        )

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_pin_via_personalization_service(self, *args):
        """Test to check 'get_pin_via_personalization_service' method"""
        customer_id = "dummy_id"
        pin = self.keywords.get_pin_via_personalization_service(self.conf, customer_id)
        self.assertEqual(pin, "5280")

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_favourite_channels_via_personalization_service(self, *args):
        """Test to check 'get_favourite_channels_via_personalization_service' method"""
        customer_id = "dummy_id"
        profile_name = "Shared Profile"
        favorite_channels = self.keywords.get_favourite_channels_via_personalization_service(
            self.conf, customer_id, profile_name)
        self.assertEqual(favorite_channels, ["1", "2"])

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_favourite_channels_via_personalization_service_exception(self, *args):
        """Test to check 'get_favourite_channels_via_personalization_service' method"""
        customer_id = "dummy_id"
        profile_name = "Wrong Profile"
        with self.assertRaises(Exception) as err_obj:
            self.keywords.get_favourite_channels_via_personalization_service(
                self.conf, customer_id, profile_name)
        err_msg = err_obj.exception
        self.assertEqual(
            str(err_msg).replace("'", ""),
            "Unable to find %s in the list of profiles" % profile_name
        )

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_available_profiles_name_via_personalization_service(self, *args):
        """Test to check 'get_available_profiles_name_via_personalization_service' method"""
        customer_id = "dummy_id"
        profile_name_list = self.keywords.get_available_profiles_name_via_personalization_service(
            self.conf, customer_id)
        self.assertEqual(profile_name_list, ['Shared Profile'])

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_cityid_via_personalization_service(self, *args):
        """Test to check 'get_cityid_via_personalization_service' method"""
        customer_id = "dummy_id"
        cityId = self.keywords.get_cityid_via_personalization_service(
            self.conf, customer_id)
        self.assertEqual(cityId, 105)

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_profile_details_via_personalization_service(self, *args):
        """Test to check 'get_profile_details_via_personalization_service' method"""
        customer_id = "dummy_id"
        customer_cpe_profile_json = self.keywords.get_profile_details_via_personalization_service(
            self.conf, customer_id)
        self.assertEqual(customer_cpe_profile_json, json.loads(GET_PROFILES_AND_DEVICES_RESPONSE))

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_available_genres(self, *args):
        """Test to check 'get_available_genres' method"""
        language = "en"
        response = self.personalization_service_requests.get_available_genres(
            language)
        self.assertEqual(response.text, AVAILABLE_GENRES)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.reason, "OK")

    @mock.patch.object(BuiltIn, "log_to_console", side_effect=print)
    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_available_genres_not_200_response(
            self, mocked_requests_get, mocked_log_to_console, *args):
        """Test to check 'get_available_genres' method"""
        language = "not_200"
        expected_url = "%s/v2/commons/availableGenres?language=%s" % (self.base_url, language)
        expected_headers = {'accept': 'application/json', 'charset': 'utf-8'}
        response = self.personalization_service_requests.get_available_genres(
            language)
        self.assertFalse(response.text)
        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.reason, "Not found")
        mocked_requests_get.assert_called_with(expected_url, headers=expected_headers)
        mocked_log_to_console.assert_called_with(
            "Send GET to %s Status code: %s, Reason: %s" % (
                expected_url, response.status_code, response.reason
            )
        )

    @mock.patch("builtins.print", side_effect=print)
    @mock.patch("requests.get", side_effect=requests.exceptions.ConnectionError)
    def test_get_available_genres_exception(
            self, mocked_requests_get, mocked_log_to_console, *args):
        """Test to check 'get_available_genres' method"""
        language = "en"
        expected_url = "%s/v2/commons/availableGenres?language=%s" % (self.base_url, language)
        expected_headers = {'accept': 'application/json', 'charset': 'utf-8'}
        response = self.personalization_service_requests.get_available_genres(language)
        expected_messages = [
            "Could not send GET %s due to " % expected_url
        ]
        actual_messages = []
        for loged_message in mocked_log_to_console.call_args_list:
            actual_messages.append(loged_message.args[0])
        self.assertEqual(sorted(expected_messages), sorted(actual_messages))
        self.assertEqual(response.text, None)
        self.assertEqual(response.status_code, None)
        self.assertEqual(response.reason, None)
        mocked_requests_get.assert_called_with(
            expected_url, headers=expected_headers
        )

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_available_genres_keyword(self, *args):
        """Test to check 'get_available_genres' method"""
        language = "en"
        genre_name_list = self.keywords.get_available_genres(
            self.conf, language)
        expected_genre_name_list = [
            'Action', 'Comedy', 'Drama', 'Romance', 'Thrillers',
            'Sports', 'News & Info', 'Kids', '(Game) Shows',
            'Culture & Music', 'Reality', 'Travel'
        ]
        self.assertEqual(genre_name_list, expected_genre_name_list)


        customer_id = "dummy_id"
        customer_cpe_profile_json = self.keywords.get_profile_details_via_personalization_service(
            self.conf, customer_id)
        self.assertEqual(customer_cpe_profile_json, json.loads(GET_PROFILES_AND_DEVICES_RESPONSE))

    @mock.patch.object(BuiltIn, "log", side_effect=print)
    @mock.patch("requests.put", side_effect=mock_requests_put)
    def test_reset_recently_used_apps_via_personalization_service(
            self, mocked_requests_put, mocked_log, *args):
        """Test to check 'reset_recently_used_apps_via_personalization_service' method"""
        customer_id = "dummy_customer_id"
        profile_id = "dummy_profile_id"
        expected_url = "%s/v1/customer/%s/profiles/%s" % (self.base_url, customer_id, profile_id)
        expected_headers = {'accept': "application/json", 'X-cus': customer_id}
        expected_body = {'recentlyUsedApps': []}
        response = self.personalization_service_requests.\
            reset_recently_used_apps_via_personalization_service(customer_id, profile_id)
        self.assertEqual(response.text, "{}")
        self.assertEqual(response.status_code, 204)
        self.assertEqual(response.reason, "No Content")
        mocked_requests_put.assert_called_with(
            expected_url, json=expected_body, headers=expected_headers)
        expected_messages = [
            "Url=%s and headers=%s and body=%s" % (expected_url, expected_headers, expected_body),
            "Exception message: Cannot access execution context - Ignoring and continue"
        ]
        actual_messages = []
        for loged_message in mocked_log.call_args_list:
            actual_messages.append(loged_message.args[0])
        self.assertEqual(sorted(expected_messages), sorted(actual_messages))

    @mock.patch.object(BuiltIn, "log_to_console", side_effect=print)
    @mock.patch("requests.put", side_effect=mock_requests_put)
    def test_reset_recently_used_apps_via_personalization_service_not_200_response(
            self, mocked_requests_put, mocked_log_to_console, *args):
        """Test to check 'reset_recently_used_apps_via_personalization_service' method"""
        customer_id = "not_200"
        profile_id = "dummy_profile_id"
        expected_url = "%s/v1/customer/%s/profiles/%s" % (self.base_url, customer_id, profile_id)
        response = self.personalization_service_requests.\
            reset_recently_used_apps_via_personalization_service(customer_id, profile_id)
        self.assertEqual(response.text, "")
        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.reason, "Not Found")
        expected_messages = [
            "Send PUT to %s Status code: %s, Reason: %s" % (
                expected_url, response.status_code, response.reason)
        ]
        actual_messages = []
        for loged_message in mocked_log_to_console.call_args_list:
            actual_messages.append(loged_message.args[0])
        self.assertEqual(sorted(expected_messages), sorted(actual_messages))

    @mock.patch("builtins.print", side_effect=print)
    @mock.patch("requests.put", side_effect=requests.exceptions.ConnectionError)
    def test_reset_recently_used_apps_via_personalization_service_exception(
            self, mocked_requests_put, mocked_print, *args):
        """Test to check 'reset_recently_used_apps_via_personalization_service' method"""
        customer_id = "not_200"
        profile_id = "dummy_profile_id"
        expected_url = "%s/v1/customer/%s/profiles/%s" % (self.base_url, customer_id, profile_id)
        response = self.personalization_service_requests.\
            reset_recently_used_apps_via_personalization_service(customer_id, profile_id)
        self.assertEqual(response.text, None)
        self.assertEqual(response.status_code, None)
        self.assertEqual(response.reason, None)
        expected_messages = [
            "Could not send PUT %s due to " % expected_url
        ]
        actual_messages = []
        for loged_message in mocked_print.call_args_list:
            actual_messages.append(loged_message.args[0])
        self.assertEqual(sorted(expected_messages), sorted(actual_messages))

    @mock.patch("requests.put", side_effect=mock_requests_put)
    def test_reset_recently_used_apps_via_personalization_service_keyword(self, *args):
        """Test to check 'reset_recently_used_apps_via_personalization_service' method"""
        customer_id = "dummy_customer_id"
        profile_id = "dummy_profile_id"
        result = self.keywords.reset_recently_used_apps_via_personalization_service(
            self.conf, customer_id, profile_id)
        self.assertEqual(result, {})

    @mock.patch.object(BuiltIn, "log", side_effect=print)
    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_customer_information_by_device_id(self, mocked_requests_get, mocked_log, *args):
        """Test to check 'get_customer_information_by_device_id' method"""
        cpe_id = "dummy_cpe_id"
        expected_url = "%s/v1/customer" % self.base_url
        expected_headers = {'accept': "application/json"}
        expected_parameters = {'byDeviceId': cpe_id}
        response = self.personalization_service_requests.\
            get_customer_information_by_device_id(cpe_id)
        self.assertEqual(response.text, CUSTOMER_INFORMATION_BY_DEVICE_ID)
        expected_messages = [
            "Url=%s, headers=%s and parameters=%s" % (
                expected_url, expected_headers, expected_parameters),
            "Exception message: Cannot access execution context - Ignoring and continue"
        ]
        actual_messages = []
        for loged_message in mocked_log.call_args_list:
            actual_messages.append(loged_message.args[0])
        self.assertEqual(sorted(expected_messages), sorted(actual_messages))

    @mock.patch.object(BuiltIn, "log_to_console", side_effect=print)
    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_customer_information_by_device_id_not_200_response(
            self, mocked_requests_get, mocked_log_to_console, *args):
        """Test to check 'get_customer_information_by_device_id' method"""
        cpe_id = "not_200"
        expected_url = "%s/v1/customer" % self.base_url
        response = self.personalization_service_requests.\
            get_customer_information_by_device_id(cpe_id)
        self.assertEqual(response.text, "")
        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.reason, "Not found")
        expected_messages = [
            "Send GET to %s Status code: %s, Reason: %s" % (
                expected_url, response.status_code, response.reason
            )
        ]
        actual_messages = []
        for loged_message in mocked_log_to_console.call_args_list:
            actual_messages.append(loged_message.args[0])
        self.assertEqual(sorted(expected_messages), sorted(actual_messages))

    @mock.patch("builtins.print", side_effect=print)
    @mock.patch("requests.get", side_effect=requests.exceptions.ConnectionError)
    def test_get_customer_information_by_device_id_exception(
            self, mocked_requests_get, mocked_log_to_console, *args):
        """Test to check 'get_customer_information_by_device_id' method"""
        cpe_id = "dummy_cpe_id"
        expected_url = "%s/v1/customer" % self.base_url
        response = self.personalization_service_requests.\
            get_customer_information_by_device_id(cpe_id)
        self.assertEqual(response.text, None)
        self.assertEqual(response.status_code, None)
        self.assertEqual(response.reason, None)
        expected_messages = [
            "Could not send GET %s due to " % expected_url
        ]
        actual_messages = []
        for loged_message in mocked_log_to_console.call_args_list:
            actual_messages.append(loged_message.args[0])
        self.assertEqual(sorted(expected_messages), sorted(actual_messages))

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_customer_information_by_device_id_keyword(self, *args):
        """Test to check 'get_customer_information_by_device_id' method"""
        cpe_id = "dummy_cpe_id"
        response = self.keywords.get_customer_information_by_device_id(self.conf, cpe_id)
        self.assertEqual(response.text, CUSTOMER_INFORMATION_BY_DEVICE_ID)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.reason, "OK")

    @mock.patch.object(BuiltIn, "log", side_effect=print)
    @mock.patch("requests.post", side_effect=mock_requests_post)
    def test_create_profile(self, mocked_requests_get, mocked_log, *args):
        """Test to check 'create_profile' method"""
        customer_id = "dummy_customer_id"
        expected_url = "%s/v1/customer/%s/profiles" % (self.base_url, customer_id)
        profile_name = "dummy_profile_name"
        profile_color = "BLUE"
        personal_lineup = []
        expected_headers = {'Content-type': 'application/json', 'X-cus': customer_id}
        expected_data = {"name": profile_name, "colour": profile_color,
                         "favoriteChannels": personal_lineup}
        response = self.personalization_service_requests.create_profile(
            customer_id, profile_name, profile_color, personal_lineup
        )
        self.assertEqual(response.text, CREATED_PROFILE)
        expected_messages = [
            "Url=%s, headers=%s and data=%s" % (expected_url, expected_headers, expected_data),
            "Exception message: Cannot access execution context - Ignoring and continue"
        ]
        actual_messages = []
        for loged_message in mocked_log.call_args_list:
            actual_messages.append(loged_message.args[0])
        self.assertEqual(sorted(expected_messages), sorted(actual_messages))
        mocked_requests_get.assert_called_with(
            expected_url, data=json.dumps(expected_data), headers=expected_headers
        )


    @mock.patch.object(BuiltIn, "log_to_console", side_effect=print)
    @mock.patch("requests.post", side_effect=mock_requests_post)
    def test_create_profile_not_200_response(
            self, mocked_requests_get, mocked_log_to_console, *args):
        """Test to check 'create_profile' method"""
        customer_id = "not_200"
        expected_url = "%s/v1/customer/%s/profiles" % (self.base_url, customer_id)
        profile_name = "dummy_profile_name"
        profile_color = "BLUE"
        personal_lineup = []
        response = self.personalization_service_requests.create_profile(
            customer_id, profile_name, profile_color, personal_lineup
        )
        self.assertEqual(response.text, "")
        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.reason, "Not Found")
        expected_messages = [
            "Send POST to %s Status code: %s, Reason: %s" % (
                expected_url, response.status_code, response.reason
            )
        ]
        actual_messages = []
        for loged_message in mocked_log_to_console.call_args_list:
            actual_messages.append(loged_message.args[0])
        self.assertEqual(sorted(expected_messages), sorted(actual_messages))

    @mock.patch("builtins.print", side_effect=print)
    @mock.patch("requests.post", side_effect=requests.exceptions.ConnectionError)
    def test_create_profile_exception(self, mocked_requests_get, mocked_log_to_console, *args):
        """Test to check 'create_profile' method"""
        customer_id = "dummy_customer_id"
        expected_url = "%s/v1/customer/%s/profiles" % (self.base_url, customer_id)
        profile_name = "dummy_profile_name"
        profile_color = "BLUE"
        personal_lineup = []
        response = self.personalization_service_requests.create_profile(
            customer_id, profile_name, profile_color, personal_lineup
        )
        self.assertEqual(response.text, None)
        self.assertEqual(response.status_code, None)
        self.assertEqual(response.reason, None)
        expected_messages = [
            "Could not send POST %s due to " % expected_url
        ]
        actual_messages = []
        for loged_message in mocked_log_to_console.call_args_list:
            actual_messages.append(loged_message.args[0])
        self.assertEqual(sorted(expected_messages), sorted(actual_messages))

    @mock.patch("requests.post", side_effect=mock_requests_post)
    def test_create_profile_keyword(self, *args):
        """Test to check 'create_profile' method"""
        customer_id = "dummy_customer_id"
        profile_name = "dummy_profile_name"
        profile_color = "BLUE"
        personal_lineup = []
        response = self.keywords.create_profile(
            self.conf, customer_id, profile_name, profile_color, personal_lineup
        )
        self.assertEqual(response.text, CREATED_PROFILE)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.reason, "OK")



def suite_personalization_service():
    """Function to make the test suite for unittests"""

    return unittest.makeSuite(PersonalizationServiceTests, "test")


def run_tests():
    """A function to run unit tests (real Personalization Service will not be used)."""
    suite = suite_personalization_service()
    unittest.TextTestRunner(verbosity=2).run(suite)


if __name__ == "__main__":
    run_tests()
