"""Unit tests of of RENG tests for HZN 4.

Tests use mock module and do not send real requests to real RENG.
v0.0.1 - Ankita Agrawal : added functions test_get_recommendations_ok,
                test_get_recommendations_refused, test_get_recommendations_failed
"""
import unittest
try:
    import mock
except ImportError:
    import unittest.mock as mock
import socket
import requests
from robot.libraries.BuiltIn import BuiltIn
from .keywords import Keywords

CONF = {"RENG": {
    "Node1": {"host": "172.23.69.89", "port": [8080]},
    "Node2": {"host": "172.23.69.92", "port": [8080]},
    "Node3": {"host": "172.23.69.94", "port": [8080]}
}}

RENG_SEARCH_RESPONSE = "RENG_SEARCH_RESPONSE_SUCCESS"

RENG_RECOMMENDATION_RESPONSE = "RENG_RECOMMENDATION_RESPONSE"


def mock_requests_get(*args, **kwargs):  # pylint: disable=W0613
    """A Function to create the fake response"""
    BuiltIn().log_to_console(kwargs)
    cpe_id = args[0]
    if "test1" in cpe_id:
        response_data = dict(text=RENG_SEARCH_RESPONSE, status_code=200, reason="OK")
    elif "test2" in cpe_id:
        response_data = dict(text=RENG_RECOMMENDATION_RESPONSE, status_code=200, reason="OK")
    elif "refused" in cpe_id:
        raise requests.exceptions.ConnectionError("[WinError 10061] No connection could be made " +
                                                  "because the target machine actively refused it")
    elif "failed" in cpe_id:
        raise socket.gaierror("[Errno 11001] getaddrinfo failed")
    return type("", (), response_data)()


@mock.patch("requests.get", side_effect=mock_requests_get)
def reng_search(*args):
    """Function to get search results from RENG
    and validate a 200/OK response
    """

    conf, cpeid, client_type, search_term, max_results, node_name = args[:-1]
    return Keywords().reng_search(conf, cpeid, client_type, search_term, max_results, node_name)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_recommendations_reng(*args):
    """Function to get recommendations from RENG
    and validate a 200/OK response
    """

    conf, cpeid, node_name, start_time, end_time, crid, client_type = args[:-1]
    return Keywords().get_recommendations_reng(conf, cpeid, node_name, start_time,
                                               end_time, crid, client_type)


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


class TestKeyword_Reng(TestCaseNameAsDescription):
    """Class contains unit tests of RENG keyword."""

    def test_reng_search_ok(self):
        """Test to validate passing response for a successful RENG request"""

        response = reng_search(CONF, "test1", "399", "new", "10", "1")
        self.assertEqual(response.text, RENG_SEARCH_RESPONSE)

    def test_reng_search_refused(self):
        """Test to validate passing response for a refused RENG request"""

        response = str(reng_search(CONF, "refused", "399", "new", "10", "1").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_reng_search_failed(self):
        """Test to validate passing response for a failed RENG request"""

        response = str(reng_search(CONF, "failed", "399", "new", "10", "1").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

    def test_get_recommendations_ok(self):
        """Test to validate passing response for a successful RENG RECOMMENDATION request"""

        response = get_recommendations_reng(CONF, "test2", "1", "1537943640", "1537947200",
                                            "crid", "305")
        self.assertEqual(response.text, RENG_RECOMMENDATION_RESPONSE)

    def test_get_recommendations_refused(self):
        """Test to validate passing response for a refused RENG RECOMMENDATION request"""

        response = str(get_recommendations_reng(CONF, "refused", "1", "1537943640", "1537947200",
                                                "crid", "305").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_get_recommendations_failed(self):
        """Test to validate passing response for a failed RENG RECOMMENDATION request"""

        response = str(get_recommendations_reng(CONF, "failed", "1", "1537943640", "1537947200",
                                                "crid", "305").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)


def suite_reng():
    """Function to make the test suite for unittests"""

    return unittest.makeSuite(TestKeyword_Reng, "test")


def run_tests():
    """A function to run unit tests (real RENG Service will not be used)."""

    suite = suite_reng()
    unittest.TextTestRunner(verbosity=2).run(suite)


if __name__ == "__main__":
    run_tests()
