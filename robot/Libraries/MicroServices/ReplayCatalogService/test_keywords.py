"""Unit tests of of Replay Catalog Microservice tests for HZN 4.

Tests use mock module and do not send real requests to real Replay Catalog Service.
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
    "MICROSERVICES" : {
        "OBOQBR": "oboqbr.some_lab.nl.dmdsdp.com"
    }
}


MOCK_REPLAY_CATALOG_PROGRAMS = """
    {
  "promotion": {
    "name": "Recommended by RTL",
    "replayPrograms": [
      {
        "id": "string",
        "name": "string",
        "type": "asset",
        "channelId": "string",
        "providerId": "string",
        "isAdult": true,
        "image": "string",
        "bookmark": {
          "position": 0,
          "duration": 0,
          "eventId": "string"
        }
      }
    ]
  },
  "replayPrograms": [
    {
      "id": "string",
      "name": "string",
      "type": "asset",
      "channelId": "string",
      "providerId": "string",
      "isAdult": true,
      "image": "string",
      "bookmark": {
        "position": 0,
        "duration": 0,
        "eventId": "string"
      }
    }
  ],
  "page": 0,
  "isLastPage": true
}"""


MOCK_REPLAY_CHANNELS = """{
  "replayChannels": [
    {
      "id": "string",
      "name": "string",
      "replayDays": 0,
      "backgroundImage": "string",
      "logo": "string"
    }
  ]
}"""


MOCK_MOST_RELEVANT_INSTANCE = """{
    "mostRelevantInstances": [
    {
      "eventId": "string",
      "tsTvEventId": "string",
      "channelId": "string",
      "eventStartTime": "2020-01-14T17:38:16.409Z",
      "isAdult": true,
      "replayContainsAdult": true,
      "replayMinAge": 0
    }
  ],
  "bookmarkedInstance": {
    "position": 0,
    "duration": 0,
    "eventId": "string"
  }
    }"""

def mock_requests_get(*args, **kwargs):
    """A Function to create a fake response depending on the unit test required"""


    path = kwargs['params']['cityId']
    url = args[0]
    print('****************' + path + '**********************')
    if ("testreplaycatalogprograms" in path) and ('programs' in url):
        response_data = dict(text=MOCK_REPLAY_CATALOG_PROGRAMS, status_code=200, reason="OK")
    elif ("testreplaychannels" in path) and ('channels' in url):
        response_data = dict(text=MOCK_REPLAY_CHANNELS, status_code=200, reason="OK")
    elif ("testmostrelevantinstance" in path) and ('mostrelevantinstance' in url):
        response_data = dict(text=MOCK_MOST_RELEVANT_INSTANCE, status_code=200, reason="OK")
    elif "refused" in path:
        raise requests.exceptions.ConnectionError("[WinError 10061] No connection could be made " +
                                                  "because the target machine actively refused it")
    elif "failed" in path:
        raise socket.gaierror("[Errno 11001] getaddrinfo failed")
    return type("", (), response_data)()


@mock.patch("requests.get", side_effect=mock_requests_get)
def check_get_replay_catalog_programs(*args):
    """
    Function to mock the get_replay_catalog_programs function.

    :param args: arguments parsed from real function
    :return: mocked response
    """
    conf, profile_id, language, city_id, page = args[:-1]
    return Keywords().get_replay_catalog_programs(conf, profile_id, language, city_id, page)


@mock.patch("requests.get", side_effect=mock_requests_get)
def check_get_replay_channels(*args):
    """
    Function to mock the get_replay_channels function.

    :param args: arguments parsed from real function
    :return: mocked response
    """

    conf, language, city_id = args[:-1]
    return Keywords().get_replay_channels(conf, language, city_id)


@mock.patch("requests.get", side_effect=mock_requests_get)
def check_get_most_relevant_instance(*args):
    """
    Function to mock the get_most_relevant_instance function.

    :param args: arguments parsed from real function
    :return: mocked response
    """

    conf, program_id, language, city_id, event_type, channel_id, provider_id, day_start, profile_id, genre_id = args[:-1]
    return Keywords().get_most_relevant_instance(conf, program_id, language, city_id, event_type, channel_id, provider_id, day_start, profile_id, genre_id)


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


class TestKeyword_ReplayCatalogService(TestCaseNameAsDescription):
    """Class contains unit tests of ReplayCatalog Service keyword."""

    def test_get_replay_catalog_programs_success(self):
        """Test to validate passing response to info call"""
        get_replay_catalog_programs_response = check_get_replay_catalog_programs(CONF, "mock_profile_id", "mock_language", "testreplaycatalogprograms", "mock_page")
        self.assertEqual(get_replay_catalog_programs_response.text, MOCK_REPLAY_CATALOG_PROGRAMS)

    def test_get_replay_catalog_programs_failure(self):
        """Test to validate failing response to the get call"""
        response = str(check_get_replay_catalog_programs(CONF, "mock_profile_id", "mock_language", "refused", "mock_page").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_get_replay_catalog_programs_refused(self):
        """Test to validate connection refused response to the get call"""
        response = str(check_get_replay_catalog_programs(CONF, "mock_profile_id", "mock_language", "failed", "mock_page").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

    def test_get_replay_channels_success(self):
        """Test to validate passing response to info call"""
        get_replay_channels_response = check_get_replay_channels(CONF, "mock_language", "testreplaychannels")
        self.assertEqual(get_replay_channels_response.text, MOCK_REPLAY_CHANNELS)

    def test_get_replay_channels_failure(self):
        """Test to validate failing response to the get call"""
        response = str(check_get_replay_channels(CONF, "mock_language", "refused").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_get_replay_channels_refused(self):
        """Test to validate connection refused response to the get call"""
        response = str(check_get_replay_channels(CONF, "mock_language", "failed").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

    def test_get_most_relevant_instance_success(self):
        """Test to validate passing response to get call"""
        get_most_relevant_instance_response = check_get_most_relevant_instance(CONF, "program_id", "mock_language",
                                                                               "testmostrelevantinstance", "mock_event_type", "mock_channel_id", "mock_provider_id", "mock_day_start", "mock_profile_id", "mock_genre_id")
        self.assertEqual(get_most_relevant_instance_response.text, MOCK_MOST_RELEVANT_INSTANCE)

    def test_get_most_relevant_instance_failure(self):
        """Test to validate failing response to get call"""
        response = str(check_get_most_relevant_instance(CONF, "program_id", "mock_language", "refused", "mock_event_type", "mock_channel_id", "mock_provider_id", "mock_day_start", "mock_profile_id", "mock_genre_id").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_get_most_relevant_instance_refused(self):
        """Test to validate connection refused response to the get call"""
        response = str(check_get_most_relevant_instance(CONF, "program_id", "mock_language", "failed", "mock_event_type", "mock_channel_id", "mock_provider_id", "mock_day_start", "mock_profile_id", "mock_genre_id").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

def suite_replaycatalogservice():
    """Function to make the test suite for unittests"""
    return unittest.makeSuite(TestKeyword_ReplayCatalogService, "test")

def run_tests():
    """A function to run unit tests (real ReplayCatalog Service will not be used)."""
    suite = suite_replaycatalogservice()
    unittest.TextTestRunner(verbosity=2).run(suite)

if __name__ == "__main__":
    run_tests()
