# pylint: disable=W0212
# pylint: disable=W0613

"""Unit tests of Recording Management Microservice tests for HZN 4.

Tests use mock module and do not send real requests to real Recording Management Service.
"""

import unittest
try:
    import mock
except ImportError:
    import unittest.mock as mock
from .RecordingManagementService import RecordingManagementService


DELETE_RECORDING_RESPONSE = 204
GET_RECORDINGS_RESPONSE = 200
POST_RECORDINGS_RESPONSE = 201

MOCKED_RECORDINGS = """
    {
        "startTime": "2020-01-30T21:00:00.000Z",
        "source": "single",
        "endTime": "2020-01-30T23:35:00.000Z",
        "id": "crid:~~2F~~2Fgn.tv~~2F10106695~~2FMV005925180000,imi:53821d46b131854fe6fd5ace1815841bc7fe40b5",
        "prePaddingOffset": 0,
        "postPaddingOffset": 300,
        "channelId": "1470",
        "localRecordingId": "280",
        "originDeviceId": "000378-EOSSTB-003800547402",
        "recStartTime": "2020-01-30T22:46:17.000Z",
        "recEndTime": "2020-01-30T23:40:00.000Z",
        "isAdult": false,
        "containsAdult": false,
        "minimumAge": "18",
        "channelBasedAuthorization": true,
        "resolution": "HD",
        "failureReason": "NOT_IN_REVIEW_BUFFER",
        "recDuration": 2923,
        "recordingType": "LDVR",
        "restrictCpeStreaming": false,
        "cpeId": "000378-EOSSTB-003800547402",
        "recordingState": "partiallyRecorded",
        "restricted": false,
        "title": "Snowpiercer",
        "isContinuous": true,
        "itemType": "single",
        "pinProtected": false
    }
"""

RECORDING_DETAILS = """
    {
        "startTime": "2019-11-05T16:00:00.000Z",
        "source": "single",
        "endTime": "2019-11-05T17:00:00.000Z",
        "id": "crid:~~2F~~2Fgn.tv~~2F10051124~~2FEP016742370016,imi:e554c8af02d3cf20eb0e2cf966f0d0e5c0bd6d8c",
        "prePaddingOffset": 60,
        "postPaddingOffset": 300,
        "channelId": "1732",
        "localRecordingId": "17",
        "originDeviceId": "000378-EOSSTB-003799436807",
        "recStartTime": "2019-11-05T15:59:00.000Z",
        "recEndTime": "2019-11-05T17:05:00.000Z",
        "isAdult": false,
        "containsAdult": false,
        "minimumAge": "12",
        "channelBasedAuthorization": true,
        "resolution": "HD",
        "recDuration": 3600,
        "seasonId": "crid:~~2F~~2Fgn.tv~~2F10012666~~2FSH016742370000",
        "seasonNumber": 2,
        "episodeNumber": 4,
        "recordingType": "LDVR",
        "showName": "Catfish: The TV Show",
        "seasonName": "Catfish: The TV Show",
        "restrictCpeStreaming": false,
        "cpeId": "000378-EOSSTB-003799436807",
        "showId": "crid:~~2F~~2Fgn.tv~~2F9474778~~2FSH016742370000",
        "recordingState": "recorded",
        "restricted": false,
        "title": "Catfish: The TV Show",
        "isContinuous": true,
        "itemType": "single",
        "pinProtected": false,
        "isMostRelevantEpisode": true
    }
"""

ALL_CHANNELS = """[{
    "trickPlayControl": "",
    "channelName": "TV Drenthe",
    "prePaddingOffset": 300,
    "postPaddingOffset": 900,
    "disallowSkipForward": false,
    "disallowFastForward": false,
    "allowPastRecordings": false,
    "allowFutureRecordings": true,
    "retentionLimit": 365,
    "channelId": "NL_000138_019591",
    "isBlackout": false
  },
  {
    "trickPlayControl": "",
    "channelName": "KIJK Almere",
    "prePaddingOffset": 300,
    "postPaddingOffset": 900,
    "disallowSkipForward": false,
    "disallowFastForward": false,
    "allowPastRecordings": false,
    "allowFutureRecordings": true,
    "channelId": "NL_100093_012601",
    "isBlackout": true
  },
  {
    "trickPlayControl": "",
    "channelName": "HISTORY HD",
    "prePaddingOffset": 300,
    "postPaddingOffset": 900,
    "disallowSkipForward": false,
    "disallowFastForward": false,
    "allowPastRecordings": false,
    "allowFutureRecordings": true,
    "retentionLimit": 365,
    "channelId": "NL_000028_019705",
    "isBlackout": false
  }]"""

CHANNEL_DETAILS = """{
  "trickPlayControl": "",
  "channelName": "TV Drenthe",
  "prePaddingOffset": 300,
  "postPaddingOffset": 900,
  "disallowSkipForward": false,
  "disallowFastForward": false,
  "allowPastRecordings": false,
  "allowFutureRecordings": true,
  "retentionLimit": 365,
  "channelId": "NL_000138_019591",
  "isBlackout": false
}"""


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


def mock_requests_get(*args, **kwargs):
    """A method imitates sending get requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    url = args[0]
    if ("show_id" in url) or ("customer_id" in url):
        response_data = dict(text=MOCKED_RECORDINGS, status_code=200, reason="OK", json=lambda x: MOCKED_RECORDINGS)
    elif "event_id" in url:
        response_data = dict(text=RECORDING_DETAILS, status_code=200, reason="OK", json=lambda x: RECORDING_DETAILS)
    elif "channel_id" in url:
        response_data = dict(text=CHANNEL_DETAILS, status_code=200, reason="OK", json=lambda x: CHANNEL_DETAILS)
    elif "channels" in url:
        response_data = dict(text=ALL_CHANNELS, status_code=200, reason="OK", json=lambda x: ALL_CHANNELS)
    return type("", (), response_data)()


def mock_requests_delete(*args, **kwargs):
    """A method imitates sending delete requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    url = args[0]
    if ("delete_event" in url) or ("show" in url) or ("season" in url):
        response_data = dict(text="", status_code=204, reason="OK")
    return type("", (), response_data)()


def mock_requests_post(*args, **kwargs):
    """A method imitates sending post requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    headers = kwargs["headers"] if "headers" in kwargs else None
    data = kwargs["data"] if "data" in kwargs else None
    if "schedule_event" in data and headers:
        response_data = dict(text="", status_code=201, reason="OK")
    return type("", (), response_data)()


class TestKeywordRecordingManagementService(TestCaseNameAsDescription):
    """Class contains unit tests of delete_single_local_recording() keyword."""

    @classmethod
    def setUpClass(cls):
        with mock.patch.object(RecordingManagementService, "__init__", lambda x: None):
            cls.rms = RecordingManagementService()
            cls.rms._rms_ip = "mock_url/"

    @classmethod
    def tearDownClass(cls):
        del cls.rms

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_rms_recordings_via_cs(self, _mock_get):
        """Positive unit test of get_rms_recordings_via_cs() keyword."""
        with mock.patch.object(RecordingManagementService, "__init__", lambda x: None):
            self.rms = RecordingManagementService()
            self.rms._rms_ip = "mock_url"
        response = self.rms.get_rms_recordings_via_cs("customer_id")
        self.assertEqual(response, MOCKED_RECORDINGS)

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_recordings_with_filters_via_rms(self, _mock_get):
        """Positive unit test of get_recordings_with_filters_via_rms() keyword."""
        response = self.rms.get_recordings_with_filters_via_rms("200285962_gb", "3C36E4-EOSSTB-003854325804", "en",
                                                                "show_id")
        self.assertEqual(response, MOCKED_RECORDINGS)

    @mock.patch("requests.delete", side_effect=mock_requests_delete)
    def test_delete_single_local_recording(self, _mock_delete):
        """Positive unit test of delete_single_local_recording keyword."""
        response = self.rms.delete_single_local_recording("200285962_gb", "3C36E4-EOSSTB-003854325804", "delete_event")
        self.assertEqual(response.status_code, DELETE_RECORDING_RESPONSE)

    @mock.patch("requests.post", side_effect=mock_requests_post)
    def test_schedule_single_ndvr_recording_via_rms(self, _mock_post):
        """Positive unit test of schedule_single_ndvr_recording_via_rms keyword."""
        response = self.rms.schedule_single_ndvr_recording_via_rms("9770976_nl", "schedule_event")
        self.assertEqual(response.status_code, POST_RECORDINGS_RESPONSE)

    @mock.patch("requests.delete", side_effect=mock_requests_delete)
    def test_delete_single_ndvr_recording(self, _mock_delete):
        """Positive unit test of delete_single_ndvr_recording keyword."""
        response = self.rms.delete_single_ndvr_recording("200285962_gb", "delete_event")
        self.assertEqual(response.status_code, DELETE_RECORDING_RESPONSE)

    @mock.patch("requests.post", side_effect=mock_requests_post)
    def test_schedule_ndvr_show_recording_via_rms(self, _mock_post):
        """Positive unit test of schedule_ndvr_show_recording_via_rms keyword."""
        response = self.rms.schedule_ndvr_show_recording_via_rms("9770976_nl", "schedule_event")
        self.assertEqual(response.status_code, POST_RECORDINGS_RESPONSE)

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_recording_details_via_rms(self, _mock_get):
        """Positive unit test of get_recording_details_via_rms() keyword."""
        response = self.rms.get_recording_details_via_rms("200285962_gb", "event_id")
        self.assertEqual(response, RECORDING_DETAILS)

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_all_channels_via_rms(self, _mock_get):
        """Positive unit test of get_all_channels_via_rms() keyword."""
        response = self.rms.get_all_channels_via_rms()
        self.assertEqual(response, ALL_CHANNELS)

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_details_of_given_channel_via_rms(self, _mock_get):
        """Positive unit test of get_details_of_given_channel_via_rms() keyword."""
        response = self.rms.get_details_of_given_channel_via_rms("channel_id")
        self.assertEqual(response, CHANNEL_DETAILS)

    @mock.patch("requests.delete", side_effect=mock_requests_delete)
    def test_delete_season_recordings_or_bookings(self, _mock_delete):
        """Positive unit test of delete_season_recordings_or_bookings keyword."""
        response = self.rms.delete_season_recordings_or_bookings("200285962_gb", "event_id", "channel_id", "recordings")
        self.assertEqual(response.status_code, DELETE_RECORDING_RESPONSE)

    @mock.patch("requests.delete", side_effect=mock_requests_delete)
    def test_delete_show_recordings_or_bookings(self, _mock_delete):
        """Positive unit test of delete_show_recordings_or_bookings keyword."""
        response = self.rms.delete_show_recordings_or_bookings("200285962_gb", "event_id", "channel_id", "bookings")
        self.assertEqual(response.status_code, DELETE_RECORDING_RESPONSE)


def suite_recording_management_service():
    """This function builds a test suite for Recording Management Service keywords."""
    return unittest.makeSuite(TestKeywordRecordingManagementService, "test")


def run_tests():
    """A function to run unit tests for Recording Management Service."""
    suites = [
        suite_recording_management_service()
    ]
    for suite in suites:
        unittest.TextTestRunner(verbosity=2).run(suite)


if __name__ == "__main__":
    run_tests()
