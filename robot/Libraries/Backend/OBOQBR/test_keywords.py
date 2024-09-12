"""Unit tests of of Microservices Healthcheck for HZN 4.

Tests use mock module and do not send real requests to real OBOQBR.
The global function debug() can be used for testing requests to real OBOQBR.
"""
import socket
import unittest
import requests

try:
    import mock
except ImportError:
    import unittest.mock as mock
from .keywords import Keywords

UNREACHABLE_IP = "100.100.100.100"
UNRESOLVABLE_HOST = "libertyglobal.com"

LAB_CONF = {
    "MOCK": {
        "MICROSERVICES": {
            "OBOQBR": "127.0.0.1",
        }
    },
    "UNREACHABLE": {
        "MICROSERVICES": {
            "OBOQBR": UNREACHABLE_IP,
        }
    },
    "UNRESOLVABLE": {
        "MICROSERVICES": {
            "OBOQBR": UNRESOLVABLE_HOST,
        }
    },
    "REAL": {
        "MICROSERVICES": {
            "OBOQBR": "oboqbr.labe2esi.nl.dmdsdp.com",
        }
    }
}

MOCK_INFO_SUCCESS = """{
    "APP_DEPLOY_TIME":null,
    "APP_START_TIME":"2017-09-18T05:22:08Z",
    "APP_BRANCH":"UNKNOWN",
    "APP_NAME":"vod-service",
    "APP_BUILD_TIME":"2017-09-14T13:42:48Z",
    "APP_VERSION":"1.13.2",
    "APP_REVISION":"5501f9e5a8b65c8ce79af868dc70985137451bce"
    }"""

MOCK_INFO_FAILURE = "default backend - 404"

MOCK_HEALTH_SUCCESS = """{
    "Server1": {
            "healthy":true,
            "timestamp":"2017-09-18T08:56:49.025Z"
        },
    "Server2": {
            "healthy":true,
            "timestamp":"2017-09-18T08:56:49.022Z"
        },
    "Server3": {
            "healthy":true,
            "timestamp":"2017-09-18T08:56:49.021Z"
        }
    }"""

MOCK_HEALTH_FAILURE = """{
    "Server1": {
            "healthy":true,
            "timestamp":"2017-09-18T08:56:49.025Z"
        },
    "Server2": {
            "healthy":false,
            "timestamp":"2017-09-18T08:56:49.022Z"
        },
    "Server3": {
            "healthy":true,
            "timestamp":"2017-09-18T08:56:49.021Z"
        }
    }"""


def mock_requests_get(*args):
    """A Function to create a fake response depending on the unit test required"""

    path = args[0]
    if "test1" in path:
        response_data = dict(text=MOCK_INFO_SUCCESS, status_code=200, reason="OK")
    elif "test2" in path:
        response_data = dict(text=MOCK_INFO_FAILURE, status_code=404, reason="Not Found")
    elif "test3" in path:
        response_data = dict(text=MOCK_HEALTH_SUCCESS, status_code=200, reason="OK")
    elif "test4" in path:
        response_data = dict(text=MOCK_HEALTH_FAILURE, status_code=200, reason="OK")
    elif "test5" in path:
        raise requests.exceptions.ConnectionError("[WinError 10061] No connection could be made " +
                                                  "because the target machine actively refused it")
    elif "test6" in path:
        raise socket.gaierror("[Errno 11001] getaddrinfo failed")
    elif "test7" in path:
        response_data = dict(text=MOCK_INFO_SUCCESS, status_code=200, reason="OK")
    return type("", (), response_data)()


@mock.patch("requests.get", side_effect=mock_requests_get)
def health_check_info(*args):
    """Function to call the /info section of the service."""
    conf, service_name = args[:-1]
    return Keywords().health_check_info(conf, service_name)


@mock.patch("requests.get", side_effect=mock_requests_get)
def health_check_info_epg_service(*args):
    """Function to call the /info section of the service."""
    conf, service_name = args[:-1]
    return Keywords().health_check_info_epg_service(conf, service_name)


@mock.patch("requests.get", side_effect=mock_requests_get)
def health_check_detail(*args):
    """Function to call the /health-checks section of the service."""
    conf, service_name = args[:-1]
    return Keywords().health_check_detail(conf, service_name)


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


class TestKeyword_Healthcheck(TestCaseNameAsDescription):
    """Class contains unit tests of healthcheck keyword."""

    def test_info_success(self, ):
        """Test to validate passing response to info call"""
        self.assertEqual(health_check_info(LAB_CONF["MOCK"], "test1").text, MOCK_INFO_SUCCESS)

    def test_info_failure(self):
        """Test to validate failing response to info call"""
        self.assertEqual(health_check_info(LAB_CONF["MOCK"], "test2").text, MOCK_INFO_FAILURE)

    def test_detail_success(self):
        """Test to validate passing response to detail call"""
        self.assertEqual(health_check_detail(LAB_CONF["MOCK"], "test3").text, MOCK_HEALTH_SUCCESS)

    def test_detail_failure(self):
        """Test to validate failing response to detail call"""
        self.assertEqual(health_check_detail(LAB_CONF["MOCK"], "test4").text, MOCK_HEALTH_FAILURE)

    def test_detail_unreachable(self):
        """Test to validate an unreachable server for detail call"""
        result = str(health_check_detail(LAB_CONF["MOCK"], "test5").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(result, expected)

    def test_detail_unresolved(self):
        """Test to validate an unresolved server for detail call"""
        result = str(health_check_detail(LAB_CONF["MOCK"], "test6").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(result, expected)

    def test_info_unreachable(self):
        """Test to validate an unreachable server for info call"""
        result = str(health_check_info(LAB_CONF["MOCK"], "test5").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(result, expected)

    def test_info_unresolved(self):
        """Test to validate an unresolved server for info call"""
        result = str(health_check_info(LAB_CONF["MOCK"], "test6").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(result, expected)

    def test_epg_info_success(self):
        """Test to validate passing response to info call"""
        self.assertEqual(MOCK_INFO_SUCCESS \
                         , health_check_info_epg_service(LAB_CONF["MOCK"], "test7").text)


def suite_healthcheck():
    """Function to make the test suite for unittests"""
    return unittest.makeSuite(TestKeyword_Healthcheck, "test")


def run_tests():
    """A function to run unit tests (real OBOQBR will not be used)."""
    suite = suite_healthcheck()
    unittest.TextTestRunner(verbosity=2).run(suite)


if __name__ == "__main__":
    run_tests()
