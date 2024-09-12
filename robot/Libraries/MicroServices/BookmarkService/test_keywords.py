# pylint: disable=W0632
# pylint: disable=W0212
# pylint: disable=W0612
# pylint: disable=W0613
# pylint: disable-msg=too-many-locals
"""Unit tests of of bookmark service tests for HZN 4.

Tests use mock module and do not send real requests to real bookmark service.

v0.0.1 - Anuj Teotia: Added unittests for :  get_profile_bookmarks_via_cs,
        delete_profile_bookmarks_via_cs, set_profile_bookmarks_via_cs.
"""

import unittest
try:
    import mock
except ImportError:
    import unittest.mock as mock
import socket
from unittest.mock import patch
import requests
from .BookmarkService import BookmarkService

CONF = {
    "MICROSERVICES": {
        "OBOQBR": "oboqbr.some_lab.nl.dmdsdp.com",
        }
    }
BMS_IP = "http://oboqbr.some_lab.nl.internal/bookmark-service/"
DELETE_BOOKMARKS_RESPONSE = 204
SET_BOOKMARKS_RESPONSE = 200
GET_PROFILE_BOOKMARK_RESPONSE = """
[{
    "contentId": "crid:~~2F~~2Fbds.tv~~2F350858993,imi:26796cb3b7fbe7bc5ce9696278b9db76f65efa36",
    "position": "1098",
    "contentType": "replay",
    "viewedState": "partially-watched",
    "viewState": "partiallyWatched",
    "timestamp": "2020-01-15T04:27:00.052Z",
    "isAdult": "False"
}, {
    "contentId": "crid:~~2F~~2Fbds.tv~~2F201671073,imi:91a101e8def23716ad3544d47698edf9179f82c1",
    "position": "947",
    "contentType": "replay",
    "viewedState": "partially-watched",
    "viewState": "partiallyWatched",
    "timestamp": "2020-01-15T00:27:21.814Z",
    "isAdult": "False"
}]
"""


def mock_requests_get(*args, **kwargs):
    """A Function to create the fake response"""
    url = args[0]
    if "bookmark_replay" in url:
        response_data = dict(text=GET_PROFILE_BOOKMARK_RESPONSE, status_code=200, reason="OK")
    elif "refused" in url:
        raise requests.exceptions.ConnectionError("[WinError 10061] No connection could be made " +
                                                  "because the target machine actively refused it")
    elif "failed" in url:
        raise socket.gaierror("[Errno 11001] getaddrinfo failed")
    return type("", (), response_data)()


def mock_requests_delete(*args, **kwargs):
    """A method imitates sending requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    url = args[0]
    if "delete_bookmarks" in url:
        response_data = dict(text="", status_code=204, reason="OK")
    return type("", (), response_data)()


def mock_requests_put(*args, **kwargs):
    """A method imitates sending PUT requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    url = args[0]
    if "set_bookmarks" in url:
        response_data = dict(text="", status_code=200, reason="OK")
    return type("", (), response_data)()


@mock.patch("requests.get", side_effect=mock_requests_get)
def check_get_profile_bookmarks_via_cs(*args):
    """
    Function to mock the get_continue_watching_list function.

    :param args: arguments parsed from real function
    :return: mocked response
    """

    conf, profile_id, content_type, return_json = args[:-1]
    with patch.object(BookmarkService, "__init__", lambda x: None):
        obj = BookmarkService()
        obj.lab_name = "MOCK_LAB"
        obj._bookmark_service_url = BMS_IP
        return obj.get_profile_bookmarks_via_cs(profile_id, content_type, return_json)


@mock.patch("requests.delete", side_effect=mock_requests_delete)
def check_test_delete_profile_bookmarks_via_cs(*args):
    """
    Function to mock the delete_profile_bookmarks_via_cs function.

    :param args: arguments parsed from real function
    :return: mocked response
    """
    conf, profile_id = args[:-1]
    with patch.object(BookmarkService, "__init__", lambda x: None):
        obj = BookmarkService()
        obj.lab_name = "MOCK_LAB"
        obj._bookmark_service_url = BMS_IP
        return obj.delete_profile_bookmarks_via_cs(profile_id)


@mock.patch("requests.put", side_effect=mock_requests_put)
def check_set_profile_bookmarks_via_cs(*args):
    """
    Function to mock the set_profile_bookmarks_via_cs function.

    :param args: arguments parsed from real function
    :return: mocked response
    """
    conf, profile_id, content_id, customer_id, cpe_id, bookmark_position,\
    asset_duration, content_type, season_id, show_id, episode_number,\
    season_number, is_adult, minimum_age, deletion_date, channel_id = args[:-1]
    with patch.object(BookmarkService, "__init__", lambda x: None):
        obj = BookmarkService()
        obj.lab_name = "MOCK_LAB"
        obj._bookmark_service_url = BMS_IP
        return obj.set_profile_bookmarks_via_cs(profile_id, content_id, customer_id,
                                                cpe_id, bookmark_position, asset_duration,
                                                content_type, season_id, show_id,
                                                episode_number, season_number,
                                                is_adult, minimum_age, deletion_date, channel_id)


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


class TestKeywordBookmarkService(TestCaseNameAsDescription):
    """Class contains unit tests of bookmark service keyword."""

    def test_get_profile_bookmarks_via_cs_ok(self):
        """Test to check successful response for getting bookmarks"""

        response = check_get_profile_bookmarks_via_cs(CONF, "profile_id", "bookmark_replay", False)
        self.assertEqual(response.text, GET_PROFILE_BOOKMARK_RESPONSE)

    def test_get_continue_watching_list_refused(self):
        """Test to check refused connection for getting bookmarks"""
        with self.assertRaises(Exception) as err_obj:
            check_get_profile_bookmarks_via_cs(CONF, "profile_id", "refused", False)
        err_msg = err_obj.exception
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(expected, str(err_msg))

    def test_get_continue_watching_list_failed(self):
        """Test to check failed connection for getting bookmarks"""
        with self.assertRaises(Exception) as err_obj:
            check_get_profile_bookmarks_via_cs(CONF, "profile_id", "failed", False)
        err_msg = err_obj.exception
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(expected, str(err_msg))

    def test_delete_profile_bookmarks_via_cs_ok(self):
        """Test to check successful response for deleting bookmarks"""

        response = check_test_delete_profile_bookmarks_via_cs(CONF, "delete_bookmarks")
        self.assertEqual(response.status_code, DELETE_BOOKMARKS_RESPONSE)

    def test_set_profile_bookmarks_via_cs_ok(self):
        """Test to check successful response for deleting bookmarks"""

        response = check_set_profile_bookmarks_via_cs\
            (CONF, "set_bookmarks", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
        self.assertEqual(response.status_code, SET_BOOKMARKS_RESPONSE)


def suite_cws_service():
    """Function to make the test suite for unittests"""

    return unittest.makeSuite(TestKeywordBookmarkService, "test")


def run_tests():
    """A function to run unit tests (real EPG Service will not be used)."""

    suite = suite_cws_service()
    unittest.TextTestRunner(verbosity=2).run(suite)


if __name__ == "__main__":
    run_tests()
