# pylint: disable=unused-argument
# Disabled pylint "unused-argument" complaining on args for mock patches'

"""Unit tests of of Purchase Microservice tests for HZN 4.

Tests use mock module and do not send real requests to real EPG Service.
"""
import unittest
import json
import socket
from robot.libraries.BuiltIn import BuiltIn
try:
    import mock
except ImportError:
    import unittest.mock as mock
import requests
from .keywords import Keywords

CONF = {"CPE_ID": "3C36E4-EOSSTB-000000000007",
        "MICROSERVICES": {"OBOQBR": "oboqbr.some_lab.nl.dmdsdp.com"}}

MOCK_PURCHASE_RESPONSE = "MOCK_PURCHASE_RESPONSE"

EXAMPLE_DETAIL_BODY = """
{"instances": 
    [{
        "offers":
            [{
                "offerId": "Example_Offer",
                "price": "Example_Price",
                "id": "Example_Id",
                "type": "Transaction"
            }]
    }]
}
"""


def mock_requests_post(*args, **kwargs):
    """A Function to create the fake response"""
    BuiltIn().log_to_console(args)
    payload_data = json.dumps(kwargs["data"])
    if "test1" in payload_data:
        response_data = dict(text=MOCK_PURCHASE_RESPONSE, status_code=200, reason="OK")
    elif "refused" in payload_data:
        raise requests.exceptions.ConnectionError("[WinError 10061] No connection could be made " +
                                                  "because the target machine actively refused it")
    elif "failed" in payload_data:
        raise socket.gaierror("[Errno 11001] getaddrinfo failed")
    return type("", (), response_data)()

@mock.patch("requests.post", side_effect=mock_requests_post)
def purchase_tvod(*args):
    """A keyword to return the complete EPG index for all services.
    :param conf: config file for labs
    :param country: the country provided by Jenkins
    :param language: the language provided by Jenkins
    """
    conf, customer_id, detail_response, cpe_id = args[:-1]
    return Keywords().purchase_tvod(conf, customer_id, detail_response, cpe_id)


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


class TestKeyword_PurchaseService(TestCaseNameAsDescription):
    """Class contains unit tests of EpgService keyword."""

    def test_purcahse_tvod_ok(self,):
        """Test to check a successful response for tvod purchase"""

        response = purchase_tvod(CONF, "af185620-8931-11e7-8fe6-451f093eda74",
                                 EXAMPLE_DETAIL_BODY, "test1")
        self.assertEqual(response.text, MOCK_PURCHASE_RESPONSE)

    def test_purchase_tvod_refused(self):
        """Test to check refused connection for tvod purchase"""

        response = str(purchase_tvod(CONF, "af185620-8931-11e7-8fe6-451f093eda74",
                                     EXAMPLE_DETAIL_BODY, "refused").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_purchase_tvod_failed(self):
        """Test to check failed connection for tvod purchase"""

        response = str(purchase_tvod(CONF, "af185620-8931-11e7-8fe6-451f093eda74",
                                     EXAMPLE_DETAIL_BODY, "failed").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)


def suite_purchase_service():
    """Function to make the test suite for unittests"""

    return unittest.makeSuite(TestKeyword_PurchaseService, "test")


def run_tests():
    """A function to run unit tests (real EPG Service will not be used)."""

    suite = suite_purchase_service()
    unittest.TextTestRunner(verbosity=2).run(suite)


if __name__ == "__main__":
    run_tests()
