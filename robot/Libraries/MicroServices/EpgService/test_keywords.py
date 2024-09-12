"""Unit tests of of EPG Microservice tests for HZN 4.

Tests use mock module and do not send real requests to real EPG Service.
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
    "MOCK": {
        "MICROSERVICES" : {
            "EPG-SERVICE": "127.0.0.1",
        }
    },
    "MICROSERVICES" : {
        "OBOQBR": "oboqbr.some_lab.nl.dmdsdp.com"
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


MOCK_INDEX_SUCCESS = """{
   "time": 1505347200,
   "durationSeconds": 1814400,
   "defaultSegmentDurationSeconds": 86400,
   "entries":    [
            {
         "channelIds": ["0130"],
         "segments":          [
            "052b3d36cdb35a8b8cd21e7c4e40c084",
            "3cea16191cc9560d82570cbd564a3f8d",
            "9d040d88c458541487d55dd5045ba7d7",
            "f25c92b6bf8f58c5bd3f20c856dc7af9",
            "946155b2519652da8da0ca6ad9c457da",
            "f36eaa212828580993e0562ad3b9e86a",
            "c2d2dd17713152ad9b1493b4c04ece53",
            "d9c4bf6fe95e5f7895f319cd6d5ca136",
            "b7c8f667c7315ec5bb6d8ca1af111772",
            "eab2e3ede10d575db56ed36b742b30d9",
            "f098e891cab1586b8948cedbc29bd60f",
            "11e20b0a3a0355fa9786d9dcdff94275",
            "81d1ee7a87855ec6b175086372a17a99",
            "5de42fcfe8a156e8a2fda74edaaa0bd0",
            "c8148c2d509a5d99b0a521d6e5bde3e8",
            "8a62d078235c5b18ba86ee9811862211",
            "36ac8c1893c95614891bbf38fa4d1f60",
            "698360db4c305564a7323708a1f976ca",
            "a03eddd3f8d854eba403318229d6190a",
            "a52f6bcfa8745ec18795c93230dda77d",
            "d4003507673e54ecbdc0c6a442df9a88"
         ]
      },
            {
         "channelIds": ["0131"],
         "segments":          [
            "e717ecd0721f5b618c8ddc5457f29d14",
            "d72182d55f83598ab0ad1e1d542bed6c",
            "0f11ccb2abe952bc9e0c8778bfe68c49",
            "2876524280b95705840c0f698d88f74a",
            "a8e43b4f6e3d5d308438c7deb2c1ecc0",
            "ca263ce8ae85579fbbb99c5eceb87d09",
            "516e8dd27d59536a85cd65bc6a55b46f",
            "1c73b088d29459e39488482216c46397",
            "fb99ead1fe0753b2b04ab1b0c09fa890",
            "ed2fadfaac7f52db93ee132a8529938b",
            "d6f020d9d6dd5a659b52a20b9f9dc504",
            "8a77b04cba7f5d3ebeb349a4ed90ea4e",
            "259284c50cb9582b843dc149e8f9a84a",
            "30efaf10283e5e54be54f7a9c24bb465",
            "41849d29d4b75330a0f3d6f306bdd83a",
            "7ba185b1b0e556409387fe74df83d67b",
            "a7ea208585145410ad69ab81ce84cdbc",
            "4c965e71983759599a6096cd7ab9d60b",
            "d138e07fd3475e15a971ed11500a1a3d",
            "0ae146a5afa75cc4af17650b63052081",
            "37b1ea7904e250d19fd20b303d495dc0"
         ]
      }
    ]
}"""


MOCK_INDEX_FAILURE = """{
   "time": 1505347200,
   "durationSeconds": 1814400,
   "defaultSegmentDurationSeconds": 86400,
   "entries":    [
            {
         "channelIds": ["0130"],
         "segments":          [
            "052b3d36cdb35a8b8cd21e7c4e40c084",
            "3cea16191cc9560d82570cbd564a3f8d",
            "9d040d88c458541487d55dd5045ba7d7",
            "f25c92b6bf8f58c5bd3f20c856dc7af9",
            "946155b2519652da8da0ca6ad9c457da",
            "f36eaa212828580993e0562ad3b9e86a",
            "c2d2dd17713152ad9b1493b4c04ece53",
            "d9c4bf6fe95e5f7895f319cd6d5ca136",
            "b7c8f667c7315ec5bb6d8ca1af111772",
            "eab2e3ede10d575db56ed36b742b30d9",
            "f098e891cab1586b8948cedbc29bd60f",
            "11e20b0a3a0355fa9786d9dcdff94275",
            "81d1ee7a87855ec6b175086372a17a99",
            "5de42fcfe8a156e8a2fda74edaaa0bd0",
            "c8148c2d509a5d99b0a521d6e5bde3e8",
            "8a62d078235c5b18ba86ee9811862211",
            "36ac8c1893c95614891bbf38fa4d1f60",
            "698360db4c305564a7323708a1f976ca",
            "a03eddd3f8d854eba403318229d6190a",
            "a52f6bcfa8745ec18795c93230dda77d",
            "d4003507673e54ecbdc0c6a442df9a88"
         ]
      },
            {
         "channelIds": ["0131"],
         "segments":          [
            "e717ecd0721f5b618c8ddc5457f29d14",
            "d72182d55f83598ab0ad1e1d542bed6c",
            "0f11ccb2abe952bc9e0c8778bfe68c49",
            "2876524280b95705840c0f698d88f74a",
            "a8e43b4f6e3d5d308438c7deb2c1ecc0",
            "ca263ce8ae85579fbbb99c5eceb87d09",
            "516e8dd27d59536a85cd65bc6a55b46f",
            "ed2fadfaac7f52db93ee132a8529938b",
            "d6f020d9d6dd5a659b52a20b9f9dc504",
            "8a77b04cba7f5d3ebeb349a4ed90ea4e",
            "259284c50cb9582b843dc149e8f9a84a",
            "30efaf10283e5e54be54f7a9c24bb465",
            "41849d29d4b75330a0f3d6f306bdd83a",
            "7ba185b1b0e556409387fe74df83d67b",
            "a7ea208585145410ad69ab81ce84cdbc",
            "4c965e71983759599a6096cd7ab9d60b",
            "d138e07fd3475e15a971ed11500a1a3d",
            "0ae146a5afa75cc4af17650b63052081",
            "37b1ea7904e250d19fd20b303d495dc0"
         ]
      }
    ]
}"""


MOCK_SEGMENT_SUCCESS = """{
   "time": 1506470400,
   "duration": 86400,
   "entries": [   {
      "channelId": "0007",
      "events":       [
                  {
            "id": "crid:~~2F~~2Fbds.tv~~2F686953100,imi:00100000000963C3",
            "title": "ATV Ana Haber Bulteni",
            "startTime": 1506467400,
            "endTime": 1506472200,
            "seriesId": "crid:~~2F~~2Fbds.tv~~2Fs44353892",
            "episodeNumber": 686953100,
            "shortDescription": "Nieuwsprogramma.",
            "longDescription": "Nieuwsprogramma.",
            "wall": "http://oboposter.labe2esi.nl.dmdsdp.com/ImagesEPG/EventImages/44353892.l.d9c1557c6ecaad925064b29c7e49cf9518383ed1.jpg",
            "poster": "http://oboposter.labe2esi.nl.dmdsdp.com/ImagesEPG/EventImages/44353892.pl.1f4617bedfee64c8b55b055e49b0251d9271cea4.jpg",
            "genres": ["News"],
            "hasReplayTV": false
         },
                  {
            "id": "crid:~~2F~~2Fbds.tv~~2F686953101,imi:00100000000963C9",
            "title": "Yahsi Cazibe",
            "startTime": 1506472200,
            "endTime": 1506481200,
            "seriesId": "crid:~~2F~~2Fbds.tv~~2Fs44355611",
            "episodeNumber": 686953101,
            "shortDescription": "Dramaserie. Het verhaal van Azerbaijani Cazibe.",
            "longDescription": "Dramaserie. Het verhaal van Azerbaijani Cazibe.",
            "actors":             [
               "Hakan Yilmaz",
               "Aslihan Gurbuz",
               "Peker Acikalin"
            ],
            "wall": "http://oboposter.labe2esi.nl.dmdsdp.com/ImagesEPG/EventImages/44355611.l.525c92b726ac7d51bdfdcdf18acfb45ac5022d50.jpg",
            "poster": "http://oboposter.labe2esi.nl.dmdsdp.com/ImagesEPG/EventImages/44355611.pl.ec653c1d6d02845521baafcda954ac4d51682979.jpg",
            "genres": ["Drama Series"],
            "hasReplayTV": false
         }
      ]
   }]
}"""


MOCK_SEGMENT_FAILURE = """{
   "time": 1506470400,
   "duration": 86400,
   "entries": [   {
      "channelId": "0007",
      "events":       [
      ]
   }]
}"""


def mock_requests_get(*args):
    """A Function to create a fake response depending on the unit test required"""

    path = args[0]
    # print("path %s" % path)
    if "testindexvalid" in path:
        response_data = dict(text=MOCK_INDEX_SUCCESS, status_code=200, reason="OK")
    elif "info" in path:
        response_data = dict(text=MOCK_INFO_SUCCESS, status_code=200, reason="OK")
    elif "testindexinvalid" in path:
        response_data = dict(text=MOCK_INDEX_FAILURE, status_code=200, reason="OK")
    elif "testsegmentvalid" in path:
        response_data = dict(text=MOCK_SEGMENT_SUCCESS, status_code=200, reason="OK")
    elif "testsegmentinvalid" in path:
        response_data = dict(text=MOCK_SEGMENT_FAILURE, status_code=200, reason="OK")
    elif "404Error" in path:
        response_data = dict(text="default backend - 404", status_code=404, reason="Not Found")
    elif "refused" in path:
        raise requests.exceptions.ConnectionError("[WinError 10061] No connection could be made " +
                                                  "because the target machine actively refused it")
    elif "failed" in path:
        raise socket.gaierror("[Errno 11001] getaddrinfo failed")
    return type("", (), response_data)()


@mock.patch("requests.get", side_effect=mock_requests_get)
def health_check_info(*args):
    """Function to call the /info section of the service."""
    conf, country, language = args[:-1]
    return Keywords().health_check_info(conf, country, language)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_epg_index(*args):
    """A keyword to return the complete EPG index for all services.
    :param conf: config file for labs
    :param country: the country provided by Jenkins
    :param language: the language provided by Jenkins
    """

    conf, country, language = args[:-1]
    return Keywords().get_epg_index(conf, country, language)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_epg_segment(*args):
    """A keyword to return the complete EPG index for all services.
    :param conf: config file for labs
    :param country: the country provided by Jenkins
    :param language: the language provided by Jenkins
    :param segment_hash: single segment hash from EPG index
    """

    conf, country, language, segment_hash = args[:-1]
    return Keywords().get_epg_segment(conf, country, language, segment_hash)


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


class TestKeyword_EpgService(TestCaseNameAsDescription):
    """Class contains unit tests of EpgService keyword."""

    def test_info_success(self):
        """Test to validate passing response to info call"""
        health_check_info_response = health_check_info(CONF, "test1", "info")
        self.assertEqual(health_check_info_response.text, MOCK_INFO_SUCCESS)

    def test_index_valid(self):
        """Test to check with a valid index response"""
        epg_index_response = get_epg_index(CONF, "test1", "testindexvalid")
        self.assertEqual(epg_index_response.text, MOCK_INDEX_SUCCESS)

    def test_index_invalid(self):
        """Test to check with an invalid index response - insufficient segments in second entry"""
        epg_index_response = get_epg_index(CONF, "test2", "testindexinvalid")
        self.assertEqual(epg_index_response.text, MOCK_INDEX_FAILURE)

    def test_segment_valid(self):
        """Test to check with a valid segment response"""
        epg_segment_response = get_epg_segment(CONF, "test3", "testsegmentvalid", "segment")
        self.assertEqual(epg_segment_response.text, MOCK_SEGMENT_SUCCESS)

    def test_segment_invalid(self):
        """Test to check with an invalid segment response - empty event list"""
        epg_segment_response = get_epg_segment(CONF, "test4",
                                               "testsegmentinvalid", "segment")
        self.assertEqual(epg_segment_response.text, MOCK_SEGMENT_FAILURE)

    def test_index_404(self):
        """Test to check with a 404 index response"""
        epg_index_response = get_epg_index(CONF, "test5", "404Error")
        self.assertEqual(epg_index_response.text, "default backend - 404")

    def test_segment_404(self):
        """Test to check with a 404 segment response"""
        epg_segment_response = get_epg_segment(CONF, "test6", "404Error", "segment")
        self.assertEqual(epg_segment_response.text, "default backend - 404")

    def test_segment_unreachable(self):
        """Test to validate an unreachable server for detail call"""
        epg_segment_response = str(get_epg_segment(CONF, "test7",
                                                   "refused", "segment").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(epg_segment_response, expected)

    def test_segment_unresolved(self):
        """Test to validate an unresolved server for detail call"""
        epg_segment_response = str(get_epg_segment(CONF, "test8",
                                                   "failed", "segment").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(epg_segment_response, expected)

    def test_index_unreachable(self):
        """Test to validate an unreachable server for info call"""
        epg_index_response = str(get_epg_index(CONF, "test9", "refused").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(epg_index_response, expected)

    def test_index_unresolved(self):
        """Test to validate an unresolved server for info call"""
        epg_index_response = str(get_epg_index(CONF, "test10", "failed").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(epg_index_response, expected)


def suite_epgservice():
    """Function to make the test suite for unittests"""
    return unittest.makeSuite(TestKeyword_EpgService, "test")


def run_tests():
    """A function to run unit tests (real EPG Service will not be used)."""
    suite = suite_epgservice()
    unittest.TextTestRunner(verbosity=2).run(suite)


if __name__ == "__main__":
    run_tests()
