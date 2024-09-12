# pylint: disable=unused-argument
# Disabled pylint "unused-argument" complaining on args for mock patches'

"""Unit tests of of VRM Microservice tests for HZN 4.

Tests use mock module and do not send real requests to real EPG Service.
"""
import unittest
try:
    import mock
except ImportError:
    import unittest.mock as mock
from .keywords import Keywords


CONF = {
    "VRM": {
        "BS": {
            "host": "172.30.94.34", "ports": [8092]
        },#[8080, 8081, 8085, 8087, 8088, 8092]'''},
        "DS": {
            "host": "172.30.94.36", "ports": [8083]
        },#[8083, 8081, 8082, 8083, 8084]},
        "BS1": {
            "host": "172.23.69.86", "ports": [8092]
        },
        "BS2": {
            "host": "172.23.69.87", "ports": [8092]
        },
    }
}

MOCK_RECORDINGS = """"{
   "count": 35,
   "entriesLength": 3,
   "entriesStartIndex": 0,
   "entriesPageSize": 3,
   "entries": [
      {
         "id": "dde55210-3123-11e8-89d2-5da7394f4e63_nl",
         "disabled": false,
         "quota": 900000,
         "occupied": 0
      },
      {
         "id": "10519780-1bea-11e8-b5c8-3dee278b0148_nl",
         "disabled": false,
         "quota": 360000,
         "occupied": 0
      },
      {
         "id": "ec062e20-3013-11e8-b83d-414357e09304_nl",
         "disabled": false,
         "quota": 900000,
         "occupied": 0
      }
   ]
}"""

MOCK_RECORDING_VIP = """{
   "count": 1,
   "entriesLength": 1,
   "entriesStartIndex": 0,
   "entriesPageSize": 500,
   "entries": [
      {
         "assetId": "14127625",
         "name": "Socutera",
         "startTime": "1528210440000",
         "status": "completed",
         "eventId": "crid:~~2F~~2Fbds.tv~~2F291749229,imi:0010000000375985",
         "programId": "crid:~~2F~~2Fbds.tv~~2F291749229,imi:0010000000375985"
      }
   ]
}"""


def mock_requests_get(*args, **kwargs):
    """A Function to create the fake response"""
    url = args[0]
    print(url)
    if "scheduler/web/User" in url:
        response_data = dict(text=MOCK_RECORDINGS, status_code=200, reason="OK")
    elif "scheduler/web/Record" in url:
        response_data = dict(text=MOCK_RECORDING_VIP, status_code=200, reason="OK")
    elif "BS1" in url:
        response_data = dict(text=MOCK_RECORDING_VIP, status_code=200, reason="OK")
    return type("", (), response_data)()


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_recordings(*args):
    """A method returns the response of get recordings request.

        A text of VRM response is a json string.

        :return: response of get recordings request for all users or for a specific user.
    """
    conf, customer_id, columns = args[:-1]
    return Keywords().get_recordings(conf, customer_id=customer_id, columns=columns)

@mock.patch("requests.get", side_effect=mock_requests_get)
def get_recordings_all_vip(*args):
    """A method returns the response of get recordings all vip request.

        A text of VRM response is a json string.

        :return: response of get recordings request for all users or for a specific user.
    """
    conf, customer_id, columns = args[:-1]
    return Keywords().get_recordings_all_vip(conf, customer_id=customer_id, columns=columns)

@mock.patch("requests.get", side_effect=mock_requests_get)
def get_recordings_all_bs1(*args):
    """A method returns the response of get recordings all vip request.

        A text of VRM response is a json string.

        :return: response of get recordings request for all users or for a specific user.
    """
    conf, customer_id, columns = args[:-1]
    return Keywords().get_recordings_all_bs1(conf, customer_id=customer_id, columns=columns)

class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


class TestKeyword_VRMService(TestCaseNameAsDescription):
    """Class contains unit tests of EpgService keyword."""

    def test_get_recordings(self):
        """Test to validate a get event detail call"""
        response = get_recordings(CONF, "3276ca00-658d-11e8-bfb3-fff89f615bf3_nl", "id,quota")
        self.assertEqual(response.text, MOCK_RECORDINGS)

    def test_get_recordings_all_vip(self):
        """Test to validate a get event detail call"""
        response = get_recordings_all_vip(
            CONF, "3276ca00-658d-11e8-bfb3-fff89f615bf3_nl", "assetid")
        self.assertEqual(response.text, MOCK_RECORDING_VIP)

    def test_get_recordings_all_bs1(self):
        """Test to validate a get event detail call"""
        response = get_recordings_all_bs1(
            CONF, "3276ca00-658d-11e8-bfb3-fff89f615bf3_nl", "assetid")
        self.assertEqual(response.text, MOCK_RECORDING_VIP)

def suite_vrmservice():
    """Function to make the test suite for unittests"""

    return unittest.makeSuite(TestKeyword_VRMService, "test")


def run_tests():
    """A function to run unit tests (real EPG Service will not be used)."""

    suite = suite_vrmservice()
    unittest.TextTestRunner(verbosity=2).run(suite)


if __name__ == "__main__":
    run_tests()
