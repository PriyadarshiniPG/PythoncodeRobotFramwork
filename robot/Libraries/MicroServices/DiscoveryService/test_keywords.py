# pylint: disable=unused-argument
# Disabled pylint "unused-argument" complaining on args for mock patches'

"""Unit tests of of Discovery Microservice tests for HZN 4.

Tests use mock module and do not send real requests to real EPG Service.
v0.0.1 - Ankita Agrawal: added functions test_get_recommendations
v0.0.2 - Anuj Teotia: modified all the unit tests to adapt profile Id.
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

CONF = {
    "MICROSERVICES": {
        "OBOQBR": "oboqbr.some_lab.nl.dmdsdp.com",
    },
    "country": "nl"
}

MOCK_EVENT_DETAILS = """"{
   "eventId": "imi:001000000037676B",
   "contentType": "linear",
   "channelId": "0001",
   "titleCrid": "crid:~~2F~~2Fbds.tv~~2F748291842",
   "broadcastDate": "2018-06-08T19:50:00Z",
   "channel": []
}"""

MOCK_SEARCH_10_RESULTS = """[
  {
    "contentSource": "1",
    "name": "New Day",
    "channelId": "0134",
    "eventId": "crid:~~2F~~2Fbds.tv~~2F262727861,imi:00100000000953DB",
    "availabilityStart": "2017-09-26T10:00:00Z",
    "availabilityEnd": "2017-09-26T11:00:00Z",
    "durationInSeconds": 3600,
    "associatedPicture": "http://oboposter.labe2esi.nl.dmdsdp.com/ImagesEPG/EventImages/116944788.p.5e7b1494ac3c29849312c34aa0592cf5337a5a42.jpg",
    "series": {
      "seriesId": "crid:~~2F~~2Fbds.tv~~2Fs116944788",
      "episodeNumber": 262727861,
      "numberOfEpisodeTitles": 18,
      "seasonName": "New Day"
    },
    "isReplay": false
  },
  {
    "contentSource": "1",
    "name": "New Blood",
    "channelId": "8315",
    "eventId": "crid:~~2F~~2Fbds.tv~~2F212617737,imi:001000000009482A",
    "availabilityStart": "2017-09-25T19:00:00Z",
    "availabilityEnd": "2017-09-25T20:15:00Z",
    "durationInSeconds": 4500,
    "associatedPicture": "http://oboposter.labe2esi.nl.dmdsdp.com/ImagesEPG/EventImages/212136241.p.9c94e4eb4c257e28203463e2a6c65ddaebebff8b.jpg",
    "series": {
      "seriesId": "crid:~~2F~~2Fbds.tv~~2F212136241",
      "episodeName": "Case 3, Part 2",
      "episodeNumber": 7,
      "expectedNumberOfEpisodes": 7,
      "numberOfEpisodeTitles": 4,
      "seasonName": "New Blood"
    },
    "isReplay": false
  },
  {
    "contentSource": "1",
    "name": "New Tricks",
    "channelId": "8315",
    "eventId": "crid:~~2F~~2Fbds.tv~~2F17953338,imi:00100000000A2B0B",
    "availabilityStart": "2017-10-01T04:00:00Z",
    "availabilityEnd": "2017-10-01T04:50:00Z",
    "durationInSeconds": 3000,
    "associatedPicture": "http://oboposter.labe2esi.nl.dmdsdp.com/ImagesEPG/EventImages/17329973.p.3af9ee95a2b0d8e840bd3225d5e7218bcc3b9e10.jpg",
    "series": {
      "seriesId": "crid:~~2F~~2Fbds.tv~~2F17329973",
      "episodeName": "Meat Is Murder",
      "episodeNumber": 8,
      "expectedNumberOfEpisodes": 8,
      "numberOfEpisodeTitles": 8,
      "seasonName": "Series 6",
      "seasonNumber": 6,
      "seriesName": "New Tricks",
      "parentSeriesId": "crid:~~2F~~2Fbds.tv~~2F6286611"
    },
    "isReplay": false
  },
  {
    "contentSource": "1",
    "name": "Brave New Girls",
    "channelId": "0157",
    "eventId": "crid:~~2F~~2Fbds.tv~~2F132354212,imi:001000000009FEBF",
    "availabilityStart": "2017-09-27T18:47:00Z",
    "availabilityEnd": "2017-09-27T19:18:00Z",
    "durationInSeconds": 1860,
    "associatedPicture": "http://oboposter.labe2esi.nl.dmdsdp.com/ImagesEPG/EventImages/132349821.p.35af09eefba3443d908a678421d193ae5051b145.jpg",
    "series": {
      "seriesId": "crid:~~2F~~2Fbds.tv~~2Fs132349821",
      "episodeNumber": 4,
      "numberOfEpisodeTitles": 4,
      "seasonName": "Brave New Girls"
    },
    "isReplay": false
  },
  {
    "contentSource": "1",
    "name": "New Age of Terror",
    "channelId": "0045",
    "eventId": "crid:~~2F~~2Fbds.tv~~2F264377599,imi:00100000000AA962",
    "availabilityStart": "2017-10-04T12:00:00Z",
    "availabilityEnd": "2017-10-04T14:00:00Z",
    "durationInSeconds": 7200,
    "associatedPicture": "http://oboposter.labe2esi.nl.dmdsdp.com/ImagesEPG/EventImages/20563118948.p.jpg",
    "series": {
      "seriesId": "crid:~~2F~~2Fbds.tv~~2F263152947",
      "episodeName": "War Without End - Part 2",
      "episodeNumber": 2,
      "numberOfEpisodeTitles": 2,
      "seasonName": "New Age of Terror"
    },
    "isReplay": false
  },
  {
    "contentSource": "1",
    "name": "New Morning Live",
    "channelId": "0224",
    "eventId": "crid:~~2F~~2Fbds.tv~~2F7384935,imi:0010000000094413",
    "availabilityStart": "2017-09-24T16:17:00Z",
    "availabilityEnd": "2017-09-24T17:29:00Z",
    "durationInSeconds": 4320,
    "associatedPicture": "http://oboposter.labe2esi.nl.dmdsdp.com/ImagesEPG/EventImages/47337559.p.cdccf1eee094e2a82f137431c5ec776c9a443620.jpg",
    "series": {
      "seriesId": "crid:~~2F~~2Fbds.tv~~2Fs47337559",
      "episodeName": "Larry Carlton",
      "episodeNumber": 7384935,
      "numberOfEpisodeTitles": 18,
      "seasonName": "New Morning Live"
    },
    "isReplay": false
  },
  {
    "contentSource": "2",
    "name": "NCIS: New Orleans",
    "contentId": "crid:~~2F~~2Fbds.tv~~2F241355588,imi:1a77b12fc1dee19360a12a1dc17f9c33",
    "titleId": "crid:~~2F~~2Fbds.tv~~2F241355588",
    "minimumAge": "12",
    "bookmark": "0",
    "eventId": "crid:~~2F~~2Fbds.tv~~2F241355588,imi:00100000000A8278",
    "durationInSeconds": 4440,
    "associatedPicture": "http://oboposter.labe2esi.nl.dmdsdp.com/ImagesEPG/EventImages/233889276.p.9f12cab829397626142d2d61fc7a471af2764b57.jpg",
    "availabilityStart": "2017-09-21T19:30:00Z",
    "availabilityEnd": "2017-09-21T20:30:00Z",
    "product": {
      "availabilityStart": "2017-06-01T00:00:00Z",
      "availabilityEnd": "3000-01-01T00:00:00Z",
      "entitlementState": "NotEntitled",
      "currency": "EUR",
      "channelId": "0096"
    },
    "series": {
      "seriesId": "crid:~~2F~~2Fbds.tv~~2F233889276",
      "episodeName": "Let Ir Ride",
      "episodeNumber": 11,
      "expectedNumberOfEpisodes": 24,
      "numberOfEpisodeTitles": 4,
      "seasonName": "Series 3",
      "seasonNumber": 3,
      "expectedNumberOfSeasons": 3,
      "seriesName": "NCIS New Orleans",
      "parentSeriesId": "crid:~~2F~~2Fbds.tv~~2F190603658"
    },
    "isReplay": true,
    "isViewedCompletely": false
  },
  {
    "contentSource": "1",
    "name": "Street Outlaws: New Orleans",
    "channelId": "0020",
    "eventId": "crid:~~2F~~2Fbds.tv~~2F261866498,imi:001000000009F875",
    "availabilityStart": "2017-09-23T21:00:00Z",
    "availabilityEnd": "2017-09-23T22:00:00Z",
    "durationInSeconds": 3600,
    "associatedPicture": "http://oboposter.labe2esi.nl.dmdsdp.com/ImagesEPG/EventImages/257232466.p.2eb13cde671a61e34d08e2eb570f1bae31c6a30c.jpg",
    "series": {
      "seriesId": "crid:~~2F~~2Fbds.tv~~2F257232466",
      "episodeName": "Back In Black",
      "episodeNumber": 7,
      "numberOfEpisodeTitles": 4,
      "seasonName": "Series 2",
      "seasonNumber": 2,
      "seriesName": "Street Outlaws: New Orleans",
      "parentSeriesId": "crid:~~2F~~2Fbds.tv~~2F257232464"
    },
    "isReplay": true
  },
  {
    "contentSource": "2",
    "name": "Street Outlaws: New Orleans",
    "contentId": "crid:~~2F~~2Fbds.tv~~2F260116579,imi:925334f7f9df8d764e48b87559a85e3b",
    "titleId": "crid:~~2F~~2Fbds.tv~~2F260116579",
    "bookmark": "0",
    "eventId": "crid:~~2F~~2Fbds.tv~~2F260116579,imi:0010000000085246",
    "durationInSeconds": 3300,
    "associatedPicture": "http://oboposter.labe2esi.nl.dmdsdp.com/ImagesEPG/EventImages/257232466.p.2eb13cde671a61e34d08e2eb570f1bae31c6a30c.jpg",
    "availabilityStart": "2017-09-15T15:10:00Z",
    "availabilityEnd": "2017-09-15T16:05:00Z",
    "product": {
      "availabilityStart": "2017-06-01T00:00:00Z",
      "availabilityEnd": "3000-01-01T00:00:00Z",
      "entitlementState": "NotEntitled",
      "currency": "EUR",
      "channelId": "0020"
    },
    "series": {
      "seriesId": "crid:~~2F~~2Fbds.tv~~2F257232466",
      "episodeName": "Moneytalks",
      "episodeNumber": 5,
      "numberOfEpisodeTitles": 4,
      "seasonName": "Series 2",
      "seasonNumber": 2,
      "seriesName": "Street Outlaws: New Orleans",
      "parentSeriesId": "crid:~~2F~~2Fbds.tv~~2F257232464"
    },
    "isReplay": true,
    "isViewedCompletely": false
  },
  {
    "contentSource": "1",
    "name": "The Detectives Club: New Orleans",
    "channelId": "8452",
    "eventId": "crid:~~2F~~2Fbds.tv~~2F243245406,imi:0010000000094981",
    "availabilityStart": "2017-09-23T13:15:00Z",
    "availabilityEnd": "2017-09-23T14:10:00Z",
    "durationInSeconds": 3300,
    "associatedPicture": "http://oboposter.labe2esi.nl.dmdsdp.com/ImagesEPG/EventImages/239991574.p.a61840aebf6c016b0800fcd157b07eaedfbef40a.jpg",
    "series": {
      "seriesId": "crid:~~2F~~2Fbds.tv~~2F239991574",
      "episodeName": "A Deal with the Devil",
      "episodeNumber": 1,
      "numberOfEpisodeTitles": 3,
      "seasonName": "The Detectives Club: New Orleans"
    },
    "isReplay": false
  }
]"""


MOCK_SEARCH_NONE = """[]"""

MOCK_RECOMMENDATIONS = """MOCK_RECOMMENDATIONS"""

def mock_requests_get(*args, **kwargs):
    """A Function to create the fake response"""
    BuiltIn().log_to_console(args)
    url = args[0]
    search_term = ""
    try:
        search_term = kwargs['params']['searchTerm']
    except KeyError:
        print(search_term)
    if "test1" in search_term:
        response_data = dict(text=MOCK_SEARCH_NONE, status_code=200, reason="OK")
    elif "test2" in search_term:
        response_data = dict(text=MOCK_SEARCH_10_RESULTS, status_code=200, reason="OK")
    elif "test3" in url:
        response_data = dict(text=MOCK_RECOMMENDATIONS, status_code=200, reason="OK")
    elif "404Error" in search_term:
        response_data = dict(text="default backend - 404", status_code=404, reason="Not Found")
    elif "refused" in search_term:
        raise requests.exceptions.ConnectionError("[WinError 10061] No connection could be made " +
                                                  "because the target machine actively refused it")
    elif "failed" in search_term:
        raise socket.gaierror("[Errno 11001] getaddrinfo failed")
    elif "seriesId" in kwargs['params']:
        response_data = dict(text=MOCK_EVENT_DETAILS, status_code=200, reason="OK")
    return type("", (), response_data)()


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_search_results(*args):
    """A keyword to return the complete EPG index for all services.
    :param conf: config file for labs
    :param country: the country provided by Jenkins
    :param language: the language provided by Jenkins
    """
    conf, client_type, customer_id, profile_id, search_term, max_results = args[:-1]
    return Keywords().get_search_results(conf, client_type, customer_id, profile_id,
                                         search_term, max_results)

@mock.patch("requests.get", side_effect=mock_requests_get)
def get_event_detail(*args):
    """A keyword to return event details.
    :param conf: config file for labs
    :param country: the country provided by Jenkins
    :param language: the language provided by Jenkins
    """
    conf, client_type, customer_id, profile_id, crid_id = args[:-1]
    return Keywords().get_event_detail(conf, client_type, customer_id, profile_id, crid_id)

@mock.patch("requests.get", side_effect=mock_requests_get)
def get_recommendations(*args):
    """A keyword to return recommendations for an event.
    """
    conf, customer_id, profile_id, client_type, resource_id, start_time, \
        end_time, resource_content_source_id = args[:-1]
    return Keywords().get_recommendations(conf, client_type, customer_id, profile_id, resource_id,
                                          start_time, end_time, resource_content_source_id)


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


class TestKeyword_DiscoveryService(TestCaseNameAsDescription):
    """Class contains unit tests of EpgService keyword."""

    def test_empty_results(self,):
        """Test to check with a valid index response"""
        response = get_search_results(CONF, 399, "af185620-8931-11e7-8fe6-451f093eda74",
                                      "profile_id", "test1", 10)
        self.assertEqual(response.text, MOCK_SEARCH_NONE)

    def test_ten_results(self,):
        """Test to check with a valid index response"""
        response = get_search_results(CONF, 399, "af185620-8931-11e7-8fe6-451f093eda74",
                                      "profile_id", "test2", 10)
        self.assertEqual(response.text, MOCK_SEARCH_10_RESULTS)

    def test_404_error(self, ):
        """Test to check with a valid index response"""
        response = get_search_results(CONF, 399, "af185620-8931-11e7-8fe6-451f093eda74",
                                      "profile_id", "404Error", 10)
        self.assertEqual(response.text, "default backend - 404")

    def test_unreachable(self):
        """Test to validate an unreachable server for detail call"""
        response = str(get_search_results(CONF, 399, "af185620-8931-11e7-8fe6-451f093eda74",
                                          "profile_id", "refused", 10).error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_unresolved(self):
        """Test to validate an unresolved server for detail call"""
        response = str(get_search_results(CONF, 399, "af185620-8931-11e7-8fe6-451f093eda74",
                                          "profile_id", "failed", 10).error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

    def test_get_event_detail(self):
        """Test to validate a get event detail call"""
        response = get_event_detail(CONF, "client_type", "3276ca00-658d-11e8-bfb3-fff89f615bf3_nl",
                                    "profile_id", "crid:~~2F~~2Fbds.tv~~2F45053782")
        self.assertEqual(response.text, MOCK_EVENT_DETAILS)

    def test_get_recommendations(self):
        """Test to validate a get event detail call"""
        response = get_recommendations(CONF, "test3", "305", "profile_id", "crid",
                                       "1537943640", "1537947200", 3)
        self.assertEqual(response.text, MOCK_RECOMMENDATIONS)

def suite_discoveryservice():
    """Function to make the test suite for unittests"""

    return unittest.makeSuite(TestKeyword_DiscoveryService, "test")


def run_tests():
    """A function to run unit tests (real EPG Service will not be used)."""

    suite = suite_discoveryservice()
    unittest.TextTestRunner(verbosity=2).run(suite)


if __name__ == "__main__":
    run_tests()
