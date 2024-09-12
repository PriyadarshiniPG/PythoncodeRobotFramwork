# pylint: disable=unused-argument
# Disabled pylint "unused-argument" complaining on args for mock patches'
# pylint: disable=protected-access
# Disabled pylint "protected-access" complaining to test private methods'

"""Unit tests of of WatchlistService Microservice tests for HZN 4.

Tests use mock module and do not send real requests to real WatchlistService Service.
"""
import sys
import unittest
try:
    import mock
except ImportError:
    import unittest.mock as mock
import json
from robot.libraries.BuiltIn import BuiltIn
from .keywords import Keywords, WatchlistService


GET_WATCHLIST_CONTENT_RESPONSE = {
    "watchlistId":"68dcc014-28cd-48f3-98f9-bce1b2974ea5",
    "name":"mylist",
    "entries":[
        {
            "replayAvailable":True,
            "isReplay":True,
            "channelId":"24_kitchen_4k",
            "earliestBroadcastStartTime":"2020-02-18T15:52:00.000Z",
            "mostRelevantEpisode":"crid:~~2F~~2Fbds.tv~~2F194815144,imi:dc99b7c9dca35b6c0845954ae900a486fcf9852a",
            "seriesId":"crid:~~2F~~2Fbds.tv~~2F334423083",
            "seasonNumber":1,
            "episodeNumber":5,
            "added":"2020-02-11T15:30:37.330Z",
            "id":"crid:~~2F~~2Fbds.tv~~2F194697765,imi:27ca18f53ea620f1fa5d9325f202cff05e192e4a",
            "titleId":"crid:~~2F~~2Fbds.tv~~2F194815144",
            "title":"Winterkost",
            "expirationDate":"2020-03-19T15:52:00.000Z",
            "isExpired":False,
            "isRemoved":False,
            "isAdult":False,
            "isHD":True,
            "isGoPlayable":True,
            "images":[
                {
                    "image":"https://staticqbr-nl-labe2esuperset.lab.cdn.dmdsdp.com/image-service/ImagesEPG/EventImages//194649017.pl.f0f3a8dd0e6a9ef0c50f05679eaedc21bad23621.jpg",
                    "type":"HighResPortrait"
                },
                {
                    "image":"https://staticqbr-nl-labe2esuperset.lab.cdn.dmdsdp.com/image-service/ImagesEPG/EventImages//194649017.p.a023528154a91df16c7f01162d1f04da3689b39c.jpg",
                    "type":"BoxCover"
                },
                {
                    "image":"https://staticqbr-nl-labe2esuperset.lab.cdn.dmdsdp.com/image-service/ImagesEPG/EventImages//194649017.l.4dd684cf97fd5daa11f0696628e72121b3c5bc11.jpg",
                    "type":"HighResLandscape"
                }
            ],
            "duration":840,
            "sortTitle":"Winterkost",
            "viewState":"notWatched",
            "entitlementState":"Entitled",
            "entitlementEnd":"2020-03-19T15:52:00.000Z",
            "listingId":"crid:~~2F~~2Fbds.tv~~2F194815144,imi:dc99b7c9dca35b6c0845954ae900a486fcf9852a",
            "containsAdult":False,
            "type":"Replay"
        },
        {
            "replayAvailable":True,
            "ageRating":0,
            "isReplay":True,
            "channelId":"Nederland_1_HD",
            "earliestBroadcastStartTime":"2020-02-27T04:05:00.000Z",
            "mostRelevantEpisode":"crid:~~2F~~2Fbds.tv~~2F269920189,imi:5b08a350fe29ec9e4f7b5410ca8ba6ff31b4af58",
            "seriesId":"crid:~~2F~~2Fbds.tv~~2Fs36652793",
            "seasonNumber":1,
            "episodeNumber":269920189,
            "added":"2019-09-24T06:10:15.050Z",
            "id":"crid:~~2F~~2Fbds.tv~~2F269920189,imi:680420f27a3609e6644fbe64882a8867c345f5bc",
            "titleId":"crid:~~2F~~2Fbds.tv~~2F269920189",
            "title":"NOS Journaal - 00:00",
            "expirationDate":"2020-03-28T04:05:00.000Z",
            "isExpired":False,
            "isRemoved":False,
            "description":"Nieuws- en actualiteitenprogramma van de NOS.",
            "isAdult":False,
            "isHD":True,
            "isGoPlayable":True,
            "images":[
                {
                    "image":"https://staticqbr-nl-labe2esuperset.lab.cdn.dmdsdp.com/image-service/ImagesEPG/EventImages//36652793.p.a3c01d1ba844a50990a135d5ceed9606f1d49854.jpg",
                    "type":"BoxCover"
                },
                {
                    "image":"https://staticqbr-nl-labe2esuperset.lab.cdn.dmdsdp.com/image-service/ImagesEPG/EventImages//36652793.l.b81df7b24c92d1d91503cfb27b464b5f2df598db.jpg",
                    "type":"HighResLandscape"
                }
            ],
            "duration":2700,
            "sortTitle":"NOS Journaal",
            "viewState":"notWatched",
            "entitlementState":"Entitled",
            "entitlementEnd":"2020-03-28T04:05:00.000Z",
            "listingId":"crid:~~2F~~2Fbds.tv~~2F269920189,imi:5b08a350fe29ec9e4f7b5410ca8ba6ff31b4af58",
            "containsAdult":False,
            "type":"Replay"
        },
        {
            "replayAvailable":True,
            "isReplay":True,
            "channelId":"ZDF_HD",
            "earliestBroadcastStartTime":"2020-02-08T03:10:00.000Z",
            "mostRelevantEpisode":"crid:~~2F~~2Fbds.tv~~2F358734976,imi:68b6791a793671560d85999fa2ed64ec67cda96f",
            "seriesId":"crid:~~2F~~2Fbds.tv~~2F47475719",
            "seasonNumber":4,
            "episodeNumber":358734976,
            "added":"2019-09-20T05:54:56.761Z",
            "id":"crid:~~2F~~2Fbds.tv~~2F284570063,imi:dfd66dcda4e7cd679b391b36622db732939bb41a",
            "titleId":"crid:~~2F~~2Fbds.tv~~2F358734976",
            "title":"Line of Duty",
            "expirationDate":"2020-03-09T03:10:00.000Z",
            "isExpired":False,
            "isRemoved":False,
            "description":"Britse misdaadserie met Martin Compston en Vicky McClure.",
            "isAdult":False,
            "isHD":True,
            "isGoPlayable":True,
            "images":[
                {
                    "image":"https://staticqbr-nl-labe2esuperset.lab.cdn.dmdsdp.com/image-service/ImagesEPG/EventImages//245830176.pl.cef30c4548ffb37de37543f4c814abe085f3b90f.jpg",
                    "type":"HighResPortrait"
                },
                {
                    "image":"https://staticqbr-nl-labe2esuperset.lab.cdn.dmdsdp.com/image-service/ImagesEPG/EventImages//245830176.p.30b46734b14df99d03ef39d5f0c3a74b2e377983.jpg",
                    "type":"BoxCover"
                },
                {
                    "image":"https://staticqbr-nl-labe2esuperset.lab.cdn.dmdsdp.com/image-service/ImagesEPG/EventImages//245830176.l.a1e8fbb31c20d497a3425a77170b677fa17dfd36.jpg",
                    "type":"HighResLandscape"
                }
            ],
            "duration":3600,
            "year":"20122020",
            "sortTitle":"Line of Duty",
            "viewState":"notWatched",
            "entitlementState":"Entitled",
            "entitlementEnd":"2020-03-09T03:10:00.000Z",
            "listingId":"crid:~~2F~~2Fbds.tv~~2F358734976,imi:68b6791a793671560d85999fa2ed64ec67cda96f",
            "yearOfProductionStart":2012,
            "yearOfProductionEnd":2020,
            "containsAdult":False,
            "type":"Replay"
        },
        {
            "replayAvailable":True,
            "ageRating":12,
            "isReplay":True,
            "channelId":"NatGeo_HD",
            "earliestBroadcastStartTime":"2020-02-27T03:22:00.000Z",
            "mostRelevantEpisode":"crid:~~2F~~2Fbds.tv~~2F198831661,imi:ee40f86b96a783dba76ce9da3ab2db5f71c56b7f",
            "seriesId":"crid:~~2F~~2Fbds.tv~~2F6408263",
            "seasonNumber":15,
            "episodeNumber":4,
            "added":"2019-08-28T16:01:20.248Z",
            "id":"crid:~~2F~~2Fbds.tv~~2F262862386,imi:ad28f1a7c22a80ecf313c0eb66bb0d8b56d2004d",
            "titleId":"crid:~~2F~~2Fbds.tv~~2F198831661",
            "title":"Air Crash Investigation",
            "expirationDate":"2020-03-28T03:22:00.000Z",
            "isExpired":False,
            "isRemoved":False,
            "description":"Documentary series investigating aviation disasters and near-crashes.",
            "isAdult":False,
            "isHD":True,
            "isGoPlayable":True,
            "images":[
                {
                    "image":"https://staticqbr-nl-labe2esuperset.lab.cdn.dmdsdp.com/image-service/ImagesEPG/EventImages//198831659.pl.5886e00dc43ade0b9f966e0555b072f775d6d604.jpg",
                    "type":"HighResPortrait"
                },
                {
                    "image":"https://staticqbr-nl-labe2esuperset.lab.cdn.dmdsdp.com/image-service/ImagesEPG/EventImages//198831659.p.b250b06d151eb941f3fec8f1658b23994b3ae275.jpg",
                    "type":"BoxCover"
                },
                {
                    "image":"https://staticqbr-nl-labe2esuperset.lab.cdn.dmdsdp.com/image-service/ImagesEPG/EventImages//198831659.l.f0bdd1ac864aec8781a1c872de39fa809f4f8b69.jpg",
                    "type":"HighResLandscape"
                }
            ],
            "duration":3060,
            "year":"20032020",
            "sortTitle":"Air Crash Investigation",
            "groupParentalRating":"12",
            "viewState":"notWatched",
            "entitlementState":"NotEntitled",
            "listingId":"crid:~~2F~~2Fbds.tv~~2F198831661,imi:ee40f86b96a783dba76ce9da3ab2db5f71c56b7f",
            "yearOfProductionStart":2003,
            "yearOfProductionEnd":2020,
            "containsAdult":False,
            "type":"Replay"
        },
        {
            "added":"2020-02-11T15:30:54.140Z",
            "id":"crid:~~2F~~2Fecx.perf.e2e-si.lgi.com~~2F1562-28-weeks-later",
            "title":"28 Weeks Later",
            "isExpired":False,
            "isRemoved":True,
            "isAdult":False,
            "viewedState":"partially-watched",
            "viewState":"partiallyWatched",
            "bookmark":3,
            "type":"Asset"
        },
        {
            "isReplay":False,
            "earliestBroadcastStartTime":"2020-02-27T14:45:32.359Z",
            "seriesId":"crid:~~2F~~2Fbds.tv~~2F333424014",
            "seasonNumber":2019,
            "episodeNumber":1,
            "added":"2019-09-19T07:12:11.206Z",
            "id":"crid:~~2F~~2Fbds.tv~~2F332684187,imi:6780e55a29925ec25db4c19ced5bcc28b89e467c",
            "titleId":"crid:~~2F~~2Fbds.tv~~2F331450605",
            "title":"Homage",
            "isExpired":True,
            "isRemoved":True,
            "isAdult":False,
            "isHD":False,
            "isGoPlayable":True,
            "images":[
                {
                    "image":"https://staticqbr-nl-labe2esuperset.lab.cdn.dmdsdp.com/image-service/ImagesEPG/EventImages//333424260.p.c01eca2692b11dada9225e9fdd2e997ad503df4f.jpg",
                    "type":"BoxCover"
                },
                {
                    "image":"https://staticqbr-nl-labe2esuperset.lab.cdn.dmdsdp.com/image-service/ImagesEPG/EventImages//333424260.l.66f6ecb75d376b9b0134a4d1b3bf9a27b52fc2fe.jpg",
                    "type":"HighResLandscape"
                }
            ],
            "duration":0,
            "sortTitle":"Homage: The Unconventionals",
            "groupParentalRating":"0",
            "viewState":"notWatched",
            "containsAdult":False,
            "type":"Replay"
        },
        {
            "added":"2019-09-12T08:37:02.219Z",
            "id":"crid:~~2F~~2Fecx.e2e-si.lgi.com~~2F284053-thor-ragnarok",
            "title":"Thor: Ragnarok",
            "isExpired":False,
            "isRemoved":True,
            "isAdult":False,
            "viewedState":"fully-watched",
            "viewState":"fullyWatched",
            "bookmark":634,
            "type":"Asset"
        }
    ],
    "totalResults":7
}


def mock_requests_get(*args, **kwargs):
    """A Function to create the fake response for a GET request"""
    # BuiltIn().log_to_console(args)
    url = args[0]
    # BuiltIn().log_to_console(url)
    if len(args) > 1:
        headers = args[1]
    else:
        headers = kwargs.get("headers", None)
    # BuiltIn().log_to_console(headers)

    mocked_json_data = None
    def mocked_json(*args):
        return mocked_json_data

    if "/v1/watchlists/profile/" in url:
        if headers.get("X-cus", None) == "dummy_customer_id":
            mocked_json_data = GET_WATCHLIST_CONTENT_RESPONSE
            response_data = dict(
                json=mocked_json,
                status_code=200, reason="OK",
                text=json.dumps(GET_WATCHLIST_CONTENT_RESPONSE)
            )
        elif headers.get("X-cus", None) == "not_200":
            mocked_json_data = ""
            response_data = dict(
                json=mocked_json,
                status_code=404, reason="Not found",
                text=json.dumps(GET_WATCHLIST_CONTENT_RESPONSE)
            )
    return type("", (), response_data)()


def mock_requests_delete(*args, **kwargs):
    """A Function to create the fake response for a DELETE request"""
    # BuiltIn().log_to_console(args)
    url = args[0]
    # BuiltIn().log_to_console(url)
    if len(args) > 1:
        headers = args[1]
    else:
        headers = kwargs.get("headers", None)
    # BuiltIn().log_to_console(headers)

    if "/v1/watchlists/profile/" in url:
        if headers.get("X-cus", None) == "dummy_customer_id":
            response_data = dict(
                status_code=204, reason="No content", text=""
            )
        elif headers.get("X-cus", None) == "not_200":
            response_data = dict(
                status_code=404, reason="Not found", text=""
            )
    return type("", (), response_data)()


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


class WatchlistServiceTests(TestCaseNameAsDescription):
    """Class contains unit tests of WatchlistService keyword."""

    @classmethod
    def setUpClass(cls):
        """Suite setup"""
        cls.keywords = Keywords()
        cls.watchlist_service = WatchlistService()
        cls.basic_url = "http://dummy.fqdn.nl/watchlist-service"

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_http_request(self, *args):
        """Unit test for '_get_http_request' method """
        profile_id = "dummy_profile_id"
        customer_id = "dummy_customer_id"
        language = "en"
        cpe_id = "dummy_cpe_id"
        url = '%s/v1/watchlists/profile/%s' % (self.basic_url, profile_id)
        parameters = {'sort': 'ADDED', 'order': 'DESC', 'smart': 'true',
                      'language': language, 'md': 'EXTENDED', 'sharedProfile': 'false'}
        headers = {'accept': 'application/json', 'X-cus': customer_id, 'X-Dev': cpe_id}
        response_json = self.watchlist_service._get_http_request(url, headers, parameters)
        self.assertEqual(response_json.json(), GET_WATCHLIST_CONTENT_RESPONSE)

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_http_request_not_200_response(self, *args):
        """Unit test for '_get_http_request' method """
        profile_id = "dummy_profile_id"
        customer_id = "not_200"
        language = "en"
        cpe_id = "dummy_cpe_id"
        url = '%s/v1/watchlists/profile/%s' % (self.basic_url, profile_id)
        parameters = {'sort': 'ADDED', 'order': 'DESC', 'smart': 'true',
                      'language': language, 'md': 'EXTENDED', 'sharedProfile': 'false'}
        headers = {'accept': 'application/json', 'X-cus': customer_id, 'X-Dev': cpe_id}
        exception_message = "[Errno Status:] 404: 'Problem with the request'"
        with self.assertRaises(Exception) as err_obj:
            self.watchlist_service._get_http_request(url, headers, parameters)
        err_msg = err_obj.exception
        self.assertEqual(str(err_msg), exception_message)

    @mock.patch.object(BuiltIn, "get_variable_value", side_effect=["dummy_lab_name", "/dummy/url"])
    @mock.patch.object(BuiltIn, "log_to_console", side_effect=print)
    @mock.patch.object(WatchlistService, "_get_http_request", side_effect=mock_requests_get)
    def test_get_watchlist_content(self, mocked__get_http_request, mocked_log_to_console, *args):
        """Unit test for 'get_watchlist_content' keyword"""
        profile_id = "dummy_profile_id"
        customer_id = "dummy_customer_id"
        language = "en"
        cpe_id = "dummy_cpe_id"
        expected_url = '%s/v1/watchlists/profile/%s' % (self.basic_url, profile_id)
        expected_parameters = {'sort': 'ADDED', 'order': 'DESC', 'smart': 'true',
                               'language': language, 'md': 'EXTENDED', 'sharedProfile': 'false'}
        expected_headers = {'accept': 'application/json', 'X-cus': customer_id, 'X-Dev': cpe_id}
        response_json = self.keywords.get_watchlist_content(
            profile_id, customer_id, language, cpe_id)
        mocked__get_http_request.asset_called_with(
            expected_url, expected_headers, expected_parameters
        )
        mocked_log_to_console.assert_not_called()
        self.assertEqual(response_json, GET_WATCHLIST_CONTENT_RESPONSE)

    @mock.patch.object(sys, "exit")
    @mock.patch.object(BuiltIn, "get_variable_value", side_effect=["dummy_lab_name", "", None])
    @mock.patch.object(BuiltIn, "log_to_console", side_effect=print)
    @mock.patch.object(WatchlistService, "_get_http_request", side_effect=mock_requests_get)
    def test_get_watchlist_content_none_micro_service_url(
            self, mocked__get_http_request, mocked_log_to_console, *args):
        """Unit test for 'get_watchlist_content' keyword"""
        profile_id = "dummy_profile_id"
        customer_id = "dummy_customer_id"
        language = "en"
        cpe_id = "dummy_cpe_id"
        response_json = self.keywords.get_watchlist_content(
            profile_id, customer_id, language, cpe_id)
        expected_messages = [
            "ERROR: : E2E_CONF[dummy_lab_name]['MICROSERVICES']['OBOQBR'] dont exist \n"
        ]
        actual_messages = []
        for loged_message in mocked_log_to_console.call_args_list:
            actual_messages.append(loged_message.args[0])
        self.assertEqual(sorted(expected_messages), sorted(actual_messages))
        self.assertEqual(response_json, GET_WATCHLIST_CONTENT_RESPONSE)

    @mock.patch.object(BuiltIn, "get_variable_value", side_effect=["dummy_lab_name", "dummy.fqdn.nl"])
    @mock.patch("requests.delete", side_effect=mock_requests_delete)
    def test_delete_watchlist_events(self, mocked_requests_delete, mocked_get_variable_value, *args):
        """Unit test for 'delete_watchlist_events' keyword"""
        profile_id = "dummy_profile_id"
        customer_id = "dummy_customer_id"
        expected_url = '%s/v1/watchlists/profile/%s' % (self.basic_url, profile_id)
        expected_headers = {'accept': 'application/json', 'X-cus': customer_id}
        response = self.keywords.delete_watchlist_events(profile_id, customer_id)
        self.assertEqual(response.status_code, 204)
        self.assertEqual(response.reason, "No content")
        self.assertEqual(response.text, "")
        mocked_requests_delete.assert_called_with(expected_url, headers=expected_headers)

    @mock.patch.object(BuiltIn, "get_variable_value", side_effect=["dummy_lab_name", "dummy.fqdn.nl"])
    @mock.patch.object(BuiltIn, "log_to_console", side_effect=print)
    @mock.patch("requests.delete", side_effect=mock_requests_delete)
    def test_delete_watchlist_events_not_200_response(
            self, mocked_requests_delete, mocked_log_to_console, mocked_get_variable_value, *args):
        """Unit test for 'delete_watchlist_events' keyword"""
        profile_id = "dummy_profile_id"
        customer_id = "not_200"
        expected_url = '%s/v1/watchlists/profile/%s' % (self.basic_url, profile_id)
        response = self.keywords.delete_watchlist_events(profile_id, customer_id)
        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.reason, "Not found")
        self.assertEqual(response.text, "")
        expected_messages = [
            "To delete_recording we send DELETE to %s\nStatus code: %s. Reason: %s\n" % (
                expected_url, response.status_code, response.reason
            )
        ]
        actual_messages = []
        for loged_message in mocked_log_to_console.call_args_list:
            actual_messages.append(loged_message.args[0])
        self.assertEqual(sorted(expected_messages), sorted(actual_messages))


def suite_watchlist_service():
    """Function to make the test suite for unittests"""

    return unittest.makeSuite(WatchlistServiceTests, "test")


def run_tests():
    """A function to run unit tests (real Watchlist Service will not be used)."""
    suite = suite_watchlist_service()
    unittest.TextTestRunner(verbosity=2).run(suite)


if __name__ == "__main__":
    run_tests()
