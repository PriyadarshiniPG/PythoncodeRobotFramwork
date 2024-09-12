# pylint: disable=W0613
# pylint: disable=unused-argument,invalid-name
# Disabled pylint "unused-argument" complaining on args for mock patches'

"""Unit tests of of Customer Provisioning Microservice tests for HZN 4.

Tests use mock module and do not send real requests to real Customer Provisioning Service.

v0.0.1 - Anuj Teotia: Added unittest:  check_customer_consistency.
"""

import unittest
try:
    import mock
except ImportError:
    import unittest.mock as mock
import socket
import requests
from .keywords import Keywords

CONF = {
    "MICROSERVICES": {
        "OBOQBR": "oboqbr.some_lab.nl.dmdsdp.com",
        }
    }

MOCK_CPS_STATUS = "MOCK_CPS_STATUS"


def mock_requests_get(*args, **kwargs):
    """A Function to create the fake response"""

    req_data = kwargs["params"]['customerId']
    if "cust_id" in req_data:
        response_data = dict(text=MOCK_CPS_STATUS, status_code=200, reason="OK")
    elif "refused" in req_data:
        raise requests.exceptions.ConnectionError("[WinError 10061] No connection could be made " +
                                                  "because the target machine actively refused it")
    elif "failed" in req_data:
        raise socket.gaierror("[Errno 11001] getaddrinfo failed")
    return type("", (), response_data)()

@mock.patch("requests.get", side_effect=mock_requests_get)
def check_customer_consistency(*args):
    """
    Function to mock the check_customer_consistency function.

    :param args: arguments parsed from real function
    :return: mocked response
    """

    conf, country, customer_id = args[:-1]
    return Keywords().check_customer_consistency(conf, country, customer_id)


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None

class TestKeyword_CustomerProvisioningService(TestCaseNameAsDescription):
    """Class contains unit tests of VodService keyword."""

    def test_check_customer_consisteny_ok(self):
        """Test to check successful response for vod structure"""

        response = check_customer_consistency(CONF, "nl", "cust_id")
        self.assertEqual(response.text, MOCK_CPS_STATUS)

    def test_check_customer_consisteny_refused(self):
        """Test to check refused connection for vod structure"""

        response = str(check_customer_consistency(CONF, "nl", "refused").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_check_customer_consisteny_failed(self):
        """Test to check failed connection for vod structure"""

        response = str(check_customer_consistency(CONF, "nl", "failed").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)


def suite_cps_service():
    """Function to make the test suite for unittests"""

    return unittest.makeSuite(TestKeyword_CustomerProvisioningService, "test")


def run_tests():
    """A function to run unit tests (real EPG Service will not be used)."""

    suite = suite_cps_service()
    unittest.TextTestRunner(verbosity=2).run(suite)


if __name__ == "__main__":
    run_tests()
