# pylint: disable=unused-argument
# Disabled pylint "unused-argument" complaining on the mock patches

"""Unit tests of Meta_Keywords library's keywords for Robot Framework.

Tests use mock module and do not send real requests to real ITFaker/Traxis.

v0.0.1 - Alex Denison:
v0.0.2 - Vasundhara Agrawal: added functions test_verify_proxy, setup_verify_proxy
v0.0.3 - Vasundhara Agrawal: added unit test for get_crid_ongoing_event
"""
import unittest
try:
    import mock
except ImportError:
    import unittest.mock as mock
import socket
import time
from datetime import datetime, timedelta
import requests
from robot.libraries.BuiltIn import BuiltIn
from .keywords import Keywords


def get_future_time(hours_in_future):
    """The function to generate time with N hours in future"""
    current_time = datetime.now()
    future_time = current_time + timedelta(hours=hours_in_future)
    return time.mktime(future_time.timetuple()) * 1000


LAB_CONF = {
    "SEACHANGE": {
        "TRAXIS_WEB": {
            "host": "127.0.0.0", "port": 80, "path": "traxis/web"
        }
    },
    "VRM": {
        "BS": {
            "host": "172.30.94.34", "ports": [8092]
        },  # [8080, 8081, 8085, 8087, 8088, 8092]'''},
        "DS": {
            "host": "172.30.94.36", "ports": [8083]
        },  # [8083, 8081, 8082, 8083, 8084]},
        "BS1": {
            "host": "172.23.69.86", "ports": [8092]
        },
        "BS2": {
            "host": "172.23.69.87", "ports": [8092]
        },
    },
    "ITFAKER": {
        "host": "127.0.0.1",
        "port": 80,
        "env": "labe2esi"
    }
}
CRID_ID = "crid:~~2F~~2Fbds.tv~~2F45053782"
SAMPLE_CRID_ONGOING = None
RESPONSE_PROXY_AUTHORIZATION = """
{
   "status": 200,
   "message": "OK",
   "description": "AuthorizedChannels=0001|EntitlementTimeout=3000-01-01T00:00:00Z| " \
                  "CustomerId=d9b6c520-7fa7-11e8-bb92-fbc4f8ae7bf1"
}"""
RESPONSE_EVENT_DATA = """{
   "entriesLength": 6,
   "entries": [
      {
         "seasonId": "crid:~~2F~~2Fbds.tv~~2Fs45053782",
         "rating": "0",
         "episode": "747919076",
         "name": "Ranking the Stars",
         "internalId": 3879267,
         "seriesId": "crid:~~2F~~2Fbds.tv~~2F45053782",
         "channelId": "0001",
         "recordable": true,
         "seasonName": "Ranking the Stars",
         "programId": "crid:~~2F~~2Fbds.tv~~2F747919076,imi:0010000000369FDA",
         "version": 0,
         "programGeneric": false,
         "startTime": %s,
         "duration": 2400,
         "seasonNumber": "100000",
         "recordingType": "",
         "id": "3879267"
      },
      {
         "seasonId": "crid:~~2F~~2Fbds.tv~~2F45053782",
         "seriesId": "crid:~~2F~~2Fbds.tv~~2F45053782",
         "episode": "146822269",
         "name": "Ali B op volle toeren",
         "internalId": 3974334,
         "channelId": "0001",
         "recordable": true,
         "seasonName": "Ali B op volle toeren",
         "programId": "crid:~~2F~~2Fbds.tv~~2F146822269,imi:af97f904ad68a20b20d584c3488f7fca656e6df8",
         "version": 0,
         "programGeneric": false,
         "startTime": %s,
         "duration": 2100,
         "seasonNumber": "100000",
         "recordingType": "",
         "id": "3974334"
      },
      {
         "seasonId": "crid:~~2F~~2Fbds.tv~~2F45053782",
         "rating": "0",
         "episode": "33594787",
         "name": "Puberruil",
         "internalId": 3974353,
         "seriesId": "crid:~~2F~~2Fbds.tv~~2F45053782",
         "channelId": "0001",
         "recordable": true,
         "seasonName": "Puberruil Zapp",
         "programId": "crid:~~2F~~2Fbds.tv~~2F33594787,imi:5e8ad45c541bec6bfb5f3931f3d80d2d450fc607",
         "version": 0,
         "programGeneric": false,
         "startTime": %s,
         "duration": 1500,
         "seasonNumber": "100000",
         "recordingType": "",
         "id": "3974353"
      },
      {
         "seasonId": "crid:~~2F~~2Fbds.tv~~2F45053782",
         "rating": "0",
         "episode": "1",
         "name": "Lauren!",
         "internalId": 3974303,
         "seriesId": "crid:~~2F~~2Fbds.tv~~2F45053782",
         "channelId": "0001",
         "recordable": true,
         "seasonName": "Lauren!",
         "programId": "crid:~~2F~~2Fbds.tv~~2F267226644,imi:aa29e2055516f4d3433f1128a337b6f0f86a5af4",
         "version": 0,
         "programGeneric": false,
         "startTime": %s,
         "duration": 2100,
         "recordingType": "",
         "id": "3974303"
      },
      {
         "seasonId": "crid:~~2F~~2Fbds.tv~~2F45053782",
         "seriesId": "crid:~~2F~~2Fbds.tv~~2F45053782",
         "episode": "751390427",
         "name": "Club HUB",
         "internalId": 3974320,
         "channelId": "0001",
         "recordable": true,
         "seasonName": "Club HUB",
         "programId": "crid:~~2F~~2Fbds.tv~~2F751390427,imi:490a67d1ce2060496fa50a8081ecd8a6359d7b4a",
         "version": 0,
         "programGeneric": false,
         "startTime": %s,
         "duration": 2400,
         "recordingType": "",
         "id": "3974320"
      },
      {
         "seasonId": "crid:~~2F~~2Fbds.tv~~2F45053782",
         "rating": "0",
         "episode": "746728484",
         "name": "Proefkonijnen",
         "internalId": 3837247,
         "seriesId": "crid:~~2F~~2Fbds.tv~~2F45053782",
         "channelId": "0001",
         "recordable": true,
         "seasonName": "Proefkonijnen",
         "programId": "crid:~~2F~~2Fbds.tv~~2F746728484,imi:0010000000360280",
         "version": 0,
         "programGeneric": false,
         "startTime": %s,
         "duration": 3000,
         "seasonNumber": "100000",
         "recordingType": "",
         "id": "3837247"
      }
   ]
}""" % (get_future_time(1), get_future_time(2), get_future_time(3),
        get_future_time(4), get_future_time(5), get_future_time(6))
MOCK_FAKER_RESPONSE = """
{
   "status": 200,
   "message": "OK",
   "description":    {
      "cityId": "02001",
      "suspended": true,
      "budgetDetails": {},
      "cpes": {"3C36E4-EOSSTB-400000000002": 
      {
         "smartcardId": "400000000200",
         "disabled": false,
         "downstreamError": false
      }
      },
      "products": {
         "9": {
            "beginDate": "2017-09-28T07:37:56.085Z",
            "endDate": "2037-12-01T10:00:00.000Z",
            "name": "",
            "linkedCrids": {}
         }
      },
      "downstreamError": false,
      "customerId": "FAKECUSTOMERID"
   }
}"""

MOCK_TRAXIS_PROFILE = """
{
  "Profiles": {
    "resultCount": 1,
    "Profile": [
      {
        "id": "FAKER_PROFILE_ID",
        "Name": "MyProfile",
        "Language": "nl",
        "CustomData": "..................",
        "Pin": "0000",
        "CollectionItemResourceType": "Profile"
      }
    ]
  }
}"""

def mock_requests_post(*args, **kwargs):
    """A Function to create the fake response"""
    BuiltIn().log_to_console(args)
    request_body = kwargs['data']
    if "test1" in request_body:
        response_data = dict(text=MOCK_FAKER_RESPONSE, status_code=200, reason="OK")
    elif "refused" in request_body:
        raise requests.exceptions.ConnectionError("[WinError 10061] No connection could be made " +
                                                  "because the target machine actively refused it")
    elif "failed" in request_body:
        raise socket.gaierror("[Errno 11001] getaddrinfo failed")
    return type("", (), response_data)()


def mock_requests_get(*args, **kwargs):
    """A Function to create the fake response"""
    BuiltIn().log_to_console(kwargs)
    url = args[0]
    if "test2" in url:
        response_data = dict(text=MOCK_TRAXIS_PROFILE, status_code=200, reason="OK")
    elif "refused" in url:
        raise requests.exceptions.ConnectionError("[WinError 10061] No connection could be made " +
                                                  "because the target machine actively refused it")
    elif "failed" in url:
        raise socket.gaierror("[Errno 11001] getaddrinfo failed")
    elif "Event" in url:
        response_data = dict(text=RESPONSE_EVENT_DATA, status_code=200, reason="OK")
    elif "test3" in url:
        response_data = dict(text=RESPONSE_PROXY_AUTHORIZATION, status_code=200, reason="OK")
    return type("", (), response_data)()


@mock.patch("requests.post", side_effect=mock_requests_post)
def setup_faker_customer(*args):
    """Function to call the /info section of the service
    and validate a 200/OK response
    """

    conf, cpeid = args[:-1]
    return Keywords().get_faker_customer(conf, cpeid)


@mock.patch("requests.get", side_effect=mock_requests_get)
def setup_traxis_customer(*args):
    """Function to call the /info section of the service
    and validate a 200/OK response
    """

    conf, cpeid = args[:-1]
    return Keywords().get_traxis_customer(conf, cpeid)


@mock.patch("requests.get", side_effect=mock_requests_get)
def setup_crid_id(*args):
    """Function to call events by channel ID requests for VRM
    and validate a 200/OK response
    """
    lab_conf, channel_id, crid_type, is_recordable, is_future = args[:-1]
    return Keywords().get_crid_id(lab_conf, channel_id, crid_type, is_recordable, is_future)


@mock.patch("requests.get", side_effect=mock_requests_get)
def setup_verify_proxy(*args):
    """Function to verify proxy authorization for a channel
        """
    lab_conf, cpe_id, channel_id = args[:-1]
    return Keywords().verify_proxy_authorization(lab_conf, cpe_id, channel_id)


@mock.patch("requests.get", side_effect=mock_requests_get)
def setup_crid_id_ongoing(*args):
    """Function to call events by channel ID requests for VRM
    and validate a 200/OK response
    """
    lab_conf, channel_id, crid_type, is_recordable = args[:-1]
    return Keywords().get_crid_ongoing_event(lab_conf, channel_id, crid_type,
                                             is_recordable)


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


class TestKeyword_Meta(TestCaseNameAsDescription):
    """Class contains unit tests of healthcheck keyword."""

    def test_it_faker_success(self, ):
        """Test to validate passing response for a successful IT Faker request"""
        response = setup_faker_customer(LAB_CONF, "test1").text
        self.assertEqual(response, MOCK_FAKER_RESPONSE)

    def test_it_faker_refused(self, ):
        """Test to validate passing response for a refused IT Faker request"""
        response = str(setup_faker_customer(LAB_CONF, "refused").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_it_faker_failed(self, ):
        """Test to validate passing response for an unresolved IT Faker request"""
        response = str(setup_faker_customer(LAB_CONF, "failed").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

    def test_traxis_success(self, ):
        """Test to validate passing response for a successful Traxis request"""
        response = setup_traxis_customer(LAB_CONF, "test2").text
        self.assertEqual(response, MOCK_TRAXIS_PROFILE)

    def test_traxis_refused(self, ):
        """Test to validate passing response for a refused Traxis request"""
        response = str(setup_traxis_customer(LAB_CONF, "refused").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_traxis_failed(self, ):
        """Test to validate passing response for an unresolved Traxis request"""
        response = str(setup_traxis_customer(LAB_CONF, "failed").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

    def test_get_crid_id(self, ):
        """Function to call events by channel ID requests for VRM
            and validate a 200/OK response
            """
        response = setup_crid_id(LAB_CONF, ['ANT0001', 'AVEN002'], "seriesId", True, False)
        self.assertEqual(response[1], SAMPLE_CRID_ONGOING)

    def test_verify_proxy(self, ):
        """Function to verify proxy authorization for a channel
        """
        response = setup_verify_proxy(LAB_CONF, "test3", "0001").text
        self.assertEqual(response, RESPONSE_PROXY_AUTHORIZATION)

    def test_get_crid_ongoing_event(self, ):
        """Function to call events by channel ID requests for VRM
            and validate a 200/OK response
            """
        response = setup_crid_id_ongoing(LAB_CONF, ['ANT0001', 'AVEN002'], "programId", True)
        self.assertEqual(response, SAMPLE_CRID_ONGOING)


def suite_meta():
    """Function to make the test suite for unittests"""

    return unittest.makeSuite(TestKeyword_Meta, "test")


def run_tests():
    """A function to run unit tests (real OBOQBR will not be used)."""

    suite = suite_meta()
    unittest.TextTestRunner(verbosity=2).run(suite)


if __name__ == "__main__":
    run_tests()
