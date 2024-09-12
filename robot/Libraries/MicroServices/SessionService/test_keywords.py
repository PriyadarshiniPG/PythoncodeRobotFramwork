# pylint: disable=unused-argument
# Disabled pylint "unused-argument" since it's required,
# but internal in mocked functions.
"""Unit tests of Session Microservice library's keywords for Robot Framework.

Tests use mock module and do not send real requests to real Session Microservice.
The global function debug() can be used for testing requests to real Session Microservice.
"""
import socket
from datetime import datetime
import unittest
try:
    import mock
except ImportError:
    import unittest.mock as mock
import requests
from .keywords import Keywords


CUSTOMER_ID = "3256f840-4d12-11e7-85f5-e5a72ae6734d_nl"
PROGRAM_ID = "crid:~~2F~~2Fbds.tv~~2F172858925,imi:00100000000CD50D"
CPE_ID = "3C36E4-EOSSTB-003356472104"
CHANNEL = "0020"
TIME = "2017-10-23T11:24:16Z"
UNREACHABLE_IP = "100.100.100.100"
UNRESOLVABLE_HOST = "libertyglobal.com"


LAB_CONF = {
    "MOCK": {
        "MICROSERVICES" : {
            "OBOQBR": "127.0.0.1",
        },
        "default_language": "en"
    },
    "UNREACHABLE": {
        "MICROSERVICES": {
            "OBOQBR": UNREACHABLE_IP,
        },
        "default_language": "en"
    },
    "UNRESOLVABLE": {
        "MICROSERVICES": {
            "OBOQBR": UNRESOLVABLE_HOST,
        },
        "default_language": "en"
    },
    "REAL": {
        "MICROSERVICES" : {
            "OBOQBR": "oboqbr.labe2esi.nl.dmdsdp.com",
        },
        "default_language": "en"
    }
}

SEESION_SERVICE_REC_RESPONSE = """{"url": "http://wp7.pod1.dvrrb.labe2esi.nl.dmdsdp.com/sdash/\
crid:~~2F~~2Fbds.tv~~2F263272013,imi:0010000000097A6B_abr/index.mpd/Manifest?device=HEVC-STB",\
"prePaddingTime":600000,"postPaddingTime":1200000,"trickPlayControl":[],"thumbnailServiceUrl":\
"http://thumbnail-service.lab5a.appdev.io/assets/crid:~~2F~~2Fbds.tv~~2F263272013"}"""

SEESION_SERVICE_REPLAY_RESPONSE = """{"url": "http://wp7.pod1.replay.labe2esi.nl.dmdsdp.com/sdash/\
1bbe2ba8-0c0a-4932-b13d-7457f0960143/index.mpd/Manifest?device=DASH", \
"sessionId": "ba56787b-7f60-44b0-86dc-52a547fa6d8a", "prePaddingTime": 60000, \
"postPaddingTime": 60000, "trickPlayControl": [], "thumbnailServiceUrl": "http://thumbnail-service.\
lab5a.appdev.io/assets/crid:~~2F~~2Fbds.tv~~2F172858925,imi:00100000000CD50D"}"""

SEESION_SERVICE_REVIEW_RESPONSE = """{"url": "http://wp23.pod1.review.labe2esi.nl.dmdsdp.com/sdash\
/LIVE$0020/index.mpd/Manifest?start=2017-10-23T11%3A24%3A16Z&end=END&device=DASH", "latency": 0}"""

SESSION_SERVICE_HOLLOW_RESPONSE = "SESSION_SERVICE_HOLLOW_RESPONSE"


def mock_requests_post(*args, **kwargs):
    """A method imitates sending requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    url = args[0]
    if "session/customers/%s/recordings/%s" % (CUSTOMER_ID, PROGRAM_ID) in url:
        data = dict(text=SEESION_SERVICE_REC_RESPONSE, status_code=200, reason="OK")
    elif "session/cpes/%s/replay/events/%s" % (CPE_ID, PROGRAM_ID) in url:
        data = dict(text=SEESION_SERVICE_REPLAY_RESPONSE, status_code=200, reason="OK")
    elif "session/channels/%s?startTime=%s" % (CHANNEL, TIME) in url:
        data = dict(text=SEESION_SERVICE_REVIEW_RESPONSE, status_code=200, reason="OK")
    elif UNRESOLVABLE_HOST in url:
        raise socket.gaierror("[Errno 11001] getaddrinfo failed")
    elif UNREACHABLE_IP in url:
        raise requests.exceptions.ConnectionError("[WinError 10061] No connection could be made " +
                                                  "because the target machine actively refused it")
    else:
        data = dict(text="", status_code=404, reason="Not Found", headers={})
    return type("", (), data)()


def mock_requests_get(*args, **kwargs):
    """A method imitates sending requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    url = args[0]
    if UNREACHABLE_IP in url:
        raise requests.exceptions.ConnectionError("[WinError 10061] No connection could be made " +
                                                  "because the target machine actively refused it")
    if UNRESOLVABLE_HOST in url:
        raise socket.gaierror("[Errno 11001] getaddrinfo failed")
    if "hollow-explorer/type" in url:
        data = dict(text=SESSION_SERVICE_HOLLOW_RESPONSE, status_code=200, reason="OK")
    else:
        data = dict(text="", status_code=404, reason="Not Found", headers={})
    return type("", (), data)()


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


@mock.patch("requests.post", side_effect=mock_requests_post)
class TestKeyword_GetSessionReviewChannel(TestCaseNameAsDescription):
    """Class contains unit tests of get_oboqbr_session_review_channel() keyword."""

    def test_review_response_ok(self, _mock_post):
        """Positive unit test of get_oboqbr_session_review_channel() keyword."""
        http_response = Keywords().get_oboqbr_session_review_channel(LAB_CONF["MOCK"],
                                                                     CHANNEL, TIME)
        self.assertEqual(http_response.status_code, 200)
        self.assertEqual(http_response.reason, "OK")
        self.assertEqual(http_response.text, SEESION_SERVICE_REVIEW_RESPONSE)

    def test_review_response_con_refus(self, _mock_post):
        """Negative unit test of get_oboqbr_session_review_channel() keyword: connection refused."""
        response = str(Keywords().get_oboqbr_session_review_channel(LAB_CONF["UNREACHABLE"],
                                                                    CHANNEL, UNREACHABLE_IP).error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_review_response_dns_error(self, _mock_post):
        """Negative unit test of get_oboqbr_session_review_channel() keyword: DNS failure."""
        response = str(Keywords().get_oboqbr_session_review_channel
                       (LAB_CONF["UNRESOLVABLE"], CHANNEL, UNRESOLVABLE_HOST).error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)


@mock.patch("requests.post", side_effect=mock_requests_post)
class TestKeyword_GetSessionRecording(TestCaseNameAsDescription):
    """Class contains unit tests of get_session_recording_response() keyword."""

    def test_rec_response_ok(self, _mock_post):
        """Positive unit test of get_session_recording_response() keyword."""
        dictionary = {
            "customer_id": CUSTOMER_ID,
            "recording_id": PROGRAM_ID
        }
        http_response = Keywords().get_session_recording_response(LAB_CONF["MOCK"], **dictionary)
        self.assertEqual(http_response.status_code, 200)
        self.assertEqual(http_response.reason, "OK")
        self.assertEqual(http_response.text, SEESION_SERVICE_REC_RESPONSE)

    def test_rec_response_con_refus(self, _mock_post):
        """Negative unit test of get_session_recording_response() keyword: connection refused."""
        dictionary = {
            "customer_id": CUSTOMER_ID,
            "recording_id": UNREACHABLE_IP
        }
        response = str(Keywords().get_session_recording_response(
            LAB_CONF["UNREACHABLE"], **dictionary).error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_rec_response_dns_error(self, _mock_post):
        """Negative unit test of get_session_recording_response() keyword: DNS failure."""
        dictionary = {
            "customer_id": CUSTOMER_ID,
            "recording_id": UNRESOLVABLE_HOST
        }
        response = str(Keywords().get_session_recording_response(
            LAB_CONF["UNRESOLVABLE"], **dictionary).error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)


@mock.patch("requests.post", side_effect=mock_requests_post)
class TestKeyword_GetSessionReplay(TestCaseNameAsDescription):
    """Class contains unit tests of get_session_recording_response() keyword."""

    def test_replay_response_ok(self, _mock_post):
        """Positive unit test of get_session_replay_response() keyword."""
        http_response = Keywords().get_session_replay_response(LAB_CONF["MOCK"], CPE_ID, PROGRAM_ID)
        self.assertEqual(http_response.status_code, 200)
        self.assertEqual(http_response.reason, "OK")
        self.assertEqual(http_response.text, SEESION_SERVICE_REPLAY_RESPONSE)

    def test_replay_response_con_refus(self, _mock_post):
        """Negative unit test of get_session_replay_response() keyword: connection refused."""
        response = str(Keywords().get_session_replay_response
                       (LAB_CONF["UNREACHABLE"], CPE_ID, UNREACHABLE_IP).error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_replay_response_dns_error(self, _mock_post):
        """Negative unit test of get_session_replay_response() keyword: DNS failure."""
        response = str(Keywords().get_session_replay_response
                       (LAB_CONF["UNRESOLVABLE"], CPE_ID, UNRESOLVABLE_HOST).error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)


@mock.patch("requests.get", side_effect=mock_requests_get)
class TestKeyword_GetHollowData(TestCaseNameAsDescription):
    """Class contains unit tests of get_hollow_data() keyword."""

    def test_get_hollow_data_ok(self, _mock_get):
        """Positive unit test of get_hollow_data() keyword."""
        http_response = Keywords().get_hollow_data(LAB_CONF["MOCK"], CHANNEL)
        self.assertEqual(http_response.status_code, 200)
        self.assertEqual(http_response.reason, "OK")
        self.assertEqual(http_response.text, SESSION_SERVICE_HOLLOW_RESPONSE)

    def test_get_hollow_data_con_refus(self, _mock_get):
        """Negative unit test of get_hollow_data() keyword: connection refused."""
        response = str(Keywords().get_hollow_data(LAB_CONF["UNREACHABLE"],
                                                  UNREACHABLE_IP).error)
        # expected_url = "http://%s/session-service/hollow-explorer/type" % UNREACHABLE_IP
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_replay_response_dns_error(self, _mock_post):
        """Negative unit test of get_hollow_data() keyword: DNS failure."""
        response = str(Keywords().get_hollow_data(LAB_CONF["UNRESOLVABLE"],
                                                  UNRESOLVABLE_HOST).error)
        # expected_url = "http://%s/session-service/hollow-explorer/type" % UNRESOLVABLE_HOST
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)


def suite_kwd_review_channel():
    """A function builds a test suite for get_customers_recordings() keyword."""
    return unittest.makeSuite(TestKeyword_GetSessionReviewChannel, "test")


def suite_kwd_recording():
    """A function builds a test suite for get_customers_recordings() keyword."""
    return unittest.makeSuite(TestKeyword_GetSessionRecording, "test")


def suite_kwd_replay():
    """A function builds a test suite for get_session_replay_response() keyword."""
    return unittest.makeSuite(TestKeyword_GetSessionReplay, "test")


def suite_kwd_hollow_data():
    """A function builds a test suite for get_session_replay_response() keyword."""
    return unittest.makeSuite(TestKeyword_GetHollowData, "test")


def run_tests():
    """A function to run unit tests (real Recording MicroService will not be used)."""
    suites = [
        suite_kwd_review_channel(),
        suite_kwd_recording(),
        suite_kwd_replay(),
        suite_kwd_hollow_data()
    ]
    for suite in suites:
        unittest.TextTestRunner(verbosity=2).run(suite)


def debug():
    """A function to get http response from real Session Microservice in the "lab5A UPCless" lab."""
    utc_time_str = str(datetime.utcnow()).replace(" ", "T")[:19] + "Z"
    result = Keywords().get_oboqbr_session_review_channel(LAB_CONF["REAL"], CHANNEL, utc_time_str)
    print(result)


if __name__ == "__main__":
    # debug()
    run_tests()
