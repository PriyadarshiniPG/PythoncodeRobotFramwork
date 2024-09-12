# pylint: disable=unused-argument
# Disabled pylint "unused-argument" complaining on args for mock patches'
"""Unit tests of Recording Microservice library's keywords for Robot Framework.

Tests use mock module and do not send real requests to real Recording Microservice.
The global function debug() can be used for testing requests to real Recording Microservice.

v0.0.1 - Fernando Cobos: Implementation unittest: requests and get customers recordings
v0.0.2 - Fernando Cobos: Add unittest:  get customers bookings
v0.0.3 - Anuj Teotia: Add unittest:  cancel_recording,
         get_details_of_recording and get_simple_recordings_full_response.
v0.0.4 - Anuj Teotia: Add unittest:  schedule_recording_show,
         get_list_of_episodes_season, get_list_of_episodes_show,
         set_bookmark_single_recording and set_view_state_single_recording.
v0.0.5 - Anuj Teotia: Add unittest: get_recorded_recordings
v0.0.6 - Ankita Agrawal : Add unittest: delete_booking
v0.0.7 - Vishwa : Updated Unittest : Updated methods get_recorded_recordings and
         get_details_of_recording
"""
import json
import unittest
try:
    import mock
except ImportError:
    import unittest.mock as mock
from .keywords import Keywords, RecordingMicroserviceRequests  # pylint: disable=E0401


# CPE_ID = "3C36E4-EOSSTB-003356472104"
CUSTOMER_ID = "3256f840-4d12-11e7-85f5-e5a72ae6734d_nl"
CRED_ID = "crid:~~2F~~2Flgi.tv~~2Fb8827264-6ff6-41ea-8426-0569d3642d34,imi:001000000024596A"
IS_ADULT = False
LIMIT = 10
# IS_ADULT = "True"

LAB_CONF = {
    "MOCK": {
        # ***** LANGUAGE CONFIG *****
        "default_language": "en",
        # ****** MICROSERVICES CONFIG  ******
        "MICROSERVICES" : {
            "OBOQBR": "oboqbr.some_lab.nl.dmdsdp.com",
        },
    },
    "REAL": {
        # ****** MICROSERVICES CONFIG  ******
        "MICROSERVICES" : {
            "OBOQBR": "oboqbr.labe2esi.nl.dmdsdp.com",
        },
        "default_language": "en",
    }
}

SAMPLE_RECORDINGS = """{
"total":5,"data":[{"startTime":"2017-08-10T00:10:00.000Z",
"duration":600,"lockState":"unlocked","privateCopy":false,
"id":"crid:~~2F~~2Flgi.tv~~2Fb8827264-6ff6-41ea-8426-0569d3642d34,imi:001000000024596A",
"type":"single","title":"index: 1, lang: NL, age: unknown","channelId":"9156",
"recordingState":"recorded","viewState":"notWatched","pinProtected":false},
{"title":"Star Haber","channelId":"1191","type":"show","seasons":[],"noOfEpisodes":4,
"mostRelevantEpisode":{"startTime":"2017-08-09T23:50:00.000Z",
"endTime":"2017-08-10T00:50:00.000Z","seasonNumber":674894459,
"episodeNumber":674894459,"duration":3600,"recordingState":"recorded",
"viewState":"notWatched","pinProtected":false,
"id":"crid:~~2F~~2Fbds.tv~~2F674894459,imi:0010000000212AC0"},
"id":"crid:~~2F~~2Fbds.tv~~2Fs50587725"},{"startTime":"2017-08-09T14:00:00.000Z",
"duration":1800,"lockState":"unlocked","privateCopy":false,
"id":"crid:~~2F~~2Fbds.tv~~2F5334264,imi:0010000000211CDE",
"type":"single","title":"King of Queens","episodeNumber":13,"seasonNumber":5,
"channelId":"0163","recordingState":"recorded","viewState":"notWatched",
"pinProtected":false,"showId":"crid:~~2F~~2Fbds.tv~~2F6404373",
"episodeTitle":"Attention Deficit"},{"startTime":"2017-08-08T22:30:00.000Z",
"duration":3000,"lockState":"unlocked","privateCopy":false,
"id":"crid:~~2F~~2Fbds.tv~~2F251269009,imi:001000000020DBD5",
"type":"single","title":"Powerboat P1 USA 2017","channelId":"0141","recordingState":"recorded",
"viewState":"notWatched","pinProtected":false,"episodeTitle":"St Cloud, Minnesota"},
{"startTime":"2017-08-08T21:30:00.000Z","duration":1980,
"lockState":"unlocked","privateCopy":false,
"id":"crid:~~2F~~2Fbds.tv~~2F257787821,imi:0010000000212E03","type":"single",
"title":"FOX Sports Vandaag","episodeNumber":257787821,"seasonNumber":257787821,
"channelId":"0031","recordingState":"recorded","viewState":"notWatched",
"pinProtected":false,"showId":"crid:~~2F~~2Fbds.tv~~2Fs176531859"}],
"size":5,"quota":{"quota":360000,"occupied":17580}}
"""

SAMPLE_BOOKINGS = """{
"total":2,"data":[{"id":"crid:~~2F~~2Fbds.tv~~2F257821096,imi:0010000000227F1E",
"title":"Photographers","type":"single","channelId":"0138",
"showId":"crid:~~2F~~2Fbds.tv~~2Fs48441358","startTime":"2017-08-11T14:30:00.000Z",
"endTime":"2017-08-11T15:00:00.000Z","episodeNumber":257821096,"seasonNumber":257821096,
"episodeTitle":"Best of"},{"id":"crid:~~2F~~2Fbds.tv~~2Fs50587725","title":"Star Haber",
"type":"show","channelId":"1191","noOfEpisodes":26,
"mostRelevantEpisode":{"startTime":"2017-08-11T15:00:00.000Z","endTime":"2017-08-11T16:00:00.000Z",
"seasonNumber":674894484,"episodeNumber":674894484,"duration":3600,"recordingState":"planned",
"viewState":"notWatched","pinProtected":false,
"id":"crid:~~2F~~2Fbds.tv~~2F674894484,imi:001000000021A1AC"}}],
"size":2,"quota":{"quota":360000,"occupied":13140}}
"""
SAMPLE_RECORDING_STATE = """{
    "total": 94,
    "data": [
        {
            "eventId": "crid:~~2F~~2Fbds.tv~~2F723723054,imi:001000000024E3DC",
            "recordingState": "failed",
            "source": "show",
            "startTime": "2018-02-28T12:30:00.000Z",
            "endTime": "2018-02-28T13:00:00.000Z",
            "showId": "crid:~~2F~~2Fbds.tv~~2Fs44575722",
            "channelId": "0131",
            "isPinProtected": false
        },
        {
            "eventId": "crid:~~2F~~2Fbds.tv~~2F725353504,imi:00100000002629AA",
            "recordingState": "failed",
            "source": "show",
            "startTime": "2018-03-08T18:30:00.000Z",
            "endTime": "2018-03-08T18:45:00.000Z",
            "showId": "crid:~~2F~~2Fbds.tv~~2Fs6120723",
            "channelId": "0131",
            "isPinProtected": false
        }
    ],
    "size": 94
}"""

SAMPLE_CANCEL_RECORDING = "Recording Cancelled"

MOCK_RECORDING_DETAILS = """{
"leadGuardTime": 0,
"bookingOffset": 904,
"lockState": "unlocked",
"endTime": "2018-06-07T17:30:00.000Z",
"duration": 96,
"startTime": "2018-06-07T17:00:00.000Z",
"source": "single",
"channelId": "0131",
"recordingState": "partiallyRecorded",
"id": "crid:~~2F~~2Fbds.tv~~2F747229020,imi:0010000000372718",
"type": "single",
"pinProtected": false,
"technicalDuration": 96,
"title": "Global",
"viewState": "notWatched",
"bookmark": 0,
"genres": [
  "nieuws"
],
"directors": [],
"shortSynopsis": "Matthew Amroliwala geeft uitleg bij het dagelijkse nieuws. \
Met reportages van BBC-correspondenten en vanuit de World's Newsroom in Londen.",
"episodeTitle": "Global with Matthew Amroliwala",
"showId": "crid:~~2F~~2Fbds.tv~~2Fs125193320",
"synopsis": "Matthew Amroliwala geeft uitleg bij het dagelijkse nieuws. \
Met reportages van BBC-correspondenten en vanuit de World's Newsroom in Londen.",
"background": {
"url": "https://staticqbr-nl-labe2esi.lab.cdn.dmdsdp.com/image-service/ImagesEPG/\
EventImages/125193320.l.fd9d5a14d47c3b3b0527b8b6f638efe18e1c1ba5.jpg",
"type": "HighResLandscape"
},
"poster": {
"url": "https://staticqbr-nl-labe2esi.lab.cdn.dmdsdp.com/image-service/ImagesEPG/\
EventImages/125193320.p.77e09a9f573485da97d3d70f8fda929cf6fb721b.jpg",
"type": "BoxCover"
},
"cast": [],
"countriesOfOrigin": [],
"isAdult": false
}"""

MOCK_SIMPLE_RECORDING = """{
"total": 2,
"data": [
  {
"recordingId": "crid:~~2F~~2Fbds.tv~~2F291956489,imi:01eadcf3e4159b919cb8db52c04cb1ec396218e9",
"recordingState": "recorded",
"viewState": "notWatched",
"seriesId": "crid:~~2F~~2Fbds.tv~~2F283412100",
"title": "crid:~~2F~~2Fbds.tv~~2F291956489"
},
  {
"recordingId": "crid:~~2F~~2Fbds.tv~~2F747229020,imi:0010000000372718",
"recordingState": "recorded",
"viewState": "notWatched",
"seriesId": "crid:~~2F~~2Fbds.tv~~2Fs125193320",
"title": "crid:~~2F~~2Fbds.tv~~2F747229020"
}
],
}"""

SAMPLE_RECORDED_RECORDINGS = """{
  "total": 1,
  "data": [
    {
      "lockState": "unlocked",
      "privateCopy": false,
      "startTime": "2018-08-03T03:15:00.000Z",
      "duration": 2700,
      "endTime": "2018-08-03T04:00:00.000Z",
      "id": "crid:~~2F~~2Fbds.tv~~2F205009224,imi:91fcc8f24489ff5d524958704a7cf0d3091e885b",
      "type": "single",
      "source": "single",
      "viewState": "notWatched",
      "channelId": "0020",
      "recordingState": "recorded",
      "title": "Moonshiners",
      "technicalDuration": 2700,
      "pinProtected": false,
      "expirationDate": "2018-08-04T03:15:00.000Z",
      "episodeNumber": 11,
      "seasonNumber": 5,
      "poster": {
        "url": "https://staticqbr-nl-labe2esi.lab.cdn.dmdsdp.com/image-service/ImagesEPG/EventImages/200357926.pl.6998a184b1c0fd2234c65b9d7ea3d3a1176ad563.jpg",
        "type": "HighResPortrait"
      },
      "episodeTitle": "Cherry Bounce",
      "showId": "crid:~~2F~~2Fbds.tv~~2F49699815"
    }
  ],
  "size": 1,
  "quota": {
    "quota": 7200000,
    "occupied": 14068
  }
}"""


SCHEDULE_RECORDING_SHOW = "Schedule Recording Show"

LIST_OF_EPISODE_SEASON = "LIST_OF_EPISODE_SEASON"

LIST_OF_EPISODE_SHOW = "LIST_OF_EPISODE_SHOW"

SET_BOOKMARK_SINGLE_RECORDING = "SET_BOOKMARK_SINGLE_RECORDING"

SET_VIEW_STATE_SINGLE_RECORDING = "SET_VIEW_STATE_SINGLE_RECORDING"

SAMPLE = {
    "RECORDINGS": SAMPLE_RECORDINGS,
    "BOOKINGS": SAMPLE_BOOKINGS,
    "STATE": SAMPLE_RECORDING_STATE,
    "CANCEL": SAMPLE_CANCEL_RECORDING,
    "DETAILS":MOCK_RECORDING_DETAILS,
    "SIMPLE": MOCK_SIMPLE_RECORDING,
    "SEASONS": LIST_OF_EPISODE_SEASON,
    "SHOWS" : LIST_OF_EPISODE_SHOW,
    "BOOKMARK" : SET_BOOKMARK_SINGLE_RECORDING,
    "VIEW-STATE" : SET_VIEW_STATE_SINGLE_RECORDING,
    "RECORDED_RECORDINGS" : SAMPLE_RECORDED_RECORDINGS
}

DELETE_BOOKING_RESPONSE = 204

def mock_requests_get(*args, **kwargs):
    """A method imitates sending requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    url = args[0]
    test_name = url.split("/")[-1]
    isAdult = False # pylint: disable=C0103
    if "isAdult" in test_name:
        isAdult = True  # pylint: disable=C0103
    if "?" in test_name:
        test_name = test_name[:test_name.find("?")]
    elif url.split("/")[-3] == "details":
        test_name = url.split("/")[-3]
    elif url.split("/")[-2] == "simple":
        test_name = url.split("/")[-2]
    test_name = test_name.upper()
    if test_name in list(SAMPLE.keys()):
        if isAdult is True and test_name == "RECORDINGS":
            test_name = "RECORDED_"+test_name
        data = dict(text=SAMPLE[test_name], status_code=200, reason="OK")
    else:
        data = dict(text="", status_code=404, reason="Not Found")
    return type("", (), data)()


def mock_requests_put(*args, **kwargs): # pylint: disable=W0613
    """A method imitates sending requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    url = args[0]
    test_name = url.split("/")[-1]
    if "imi" in test_name:
        test_name = url.split("/")[-2]
    test_name = test_name.upper()
    if test_name in list(SAMPLE.keys()):
        data = dict(text=SAMPLE[test_name], status_code=200, reason="OK")
    else:
        data = dict(text="", status_code=404, reason="Not Found")
    return type("", (), data)()


def mock_requests_post(*args, **kwargs): # pylint: disable=W0613
    """A method imitates sending requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    data = kwargs["data"]
    if "show" in data:
        response_data = dict(text=SCHEDULE_RECORDING_SHOW, status_code=200, reason="OK")
    return type("", (), response_data)()

def mock_requests_delete(*args, **kwargs): # pylint: disable=W0613
    """A method imitates sending requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    url = args[0]
    if "eventId_delete" in url:
        response_data = dict(text="", status_code=204, reason="OK")
    return type("", (), response_data)()

class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


class Test_RecordingMicroserviceRequests(TestCaseNameAsDescription):
    """Class contains unit tests of parsing Recording Microservice response text."""

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_customers_recordings(self, _mock_get):
        """Positive unit test of parsing successful Recording Microservice response text."""
        obj = RecordingMicroserviceRequests(LAB_CONF["MOCK"], CUSTOMER_ID)
        result = obj.get_customers_recordings()
        self.assertEqual(result, json.loads(SAMPLE_RECORDINGS))


class TestKeyword_GetRecordingMicroserviceRecordings(TestCaseNameAsDescription):
    """Class contains unit tests of get_recording_microservice_customers_recordings() keyword."""

    @classmethod
    def setUpClass(cls):
        cls.kwd = Keywords()

    @classmethod
    def tearDownClass(cls):
        pass

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_customers_recordings(self, _mock_get):
        """Positive unit test of get_recording_microservice_customers_recordings() keyword."""
        result = self.kwd.get_customers_recordings(LAB_CONF["MOCK"], CUSTOMER_ID)
        self.assertEqual(result, json.loads(SAMPLE_RECORDINGS))

class TestKeyword_GetRecordingMicroserviceBookings(TestCaseNameAsDescription):
    """Class contains unit tests of get_recording_microservice_customers_bookings() keyword."""

    @classmethod
    def setUpClass(cls):
        cls.kwd = Keywords()

    @classmethod
    def tearDownClass(cls):
        pass

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_customers_bookings(self, _mock_get):
        """Positive unit test of get_recording_microservice_customers_bookings() keyword."""
        result = self.kwd.get_customers_bookings(LAB_CONF["MOCK"], CUSTOMER_ID, IS_ADULT)
        self.assertEqual(result, json.loads(SAMPLE_BOOKINGS))

class TestKeyword_GetRecordingMicroserviceRecordingsState(TestCaseNameAsDescription):
    """Class contains unit tests of get_recording_state_for_events() keyword."""

    @classmethod
    def setUpClass(cls):
        cls.kwd = Keywords()

    @classmethod
    def tearDownClass(cls):
        pass

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_recording_state_for_events(self, _mock_get):
        """Positive unit test of get_recording_state_for_events() keyword."""
        result = self.kwd.get_recording_state_for_events(LAB_CONF["MOCK"], CUSTOMER_ID, "mock_cpe_id")
        self.assertEqual(result.text, SAMPLE_RECORDING_STATE)

class TestKeyword_CancelRecordings(TestCaseNameAsDescription):
    """Class contains unit tests of cancel_recording() keyword."""

    @classmethod
    def setUpClass(cls):
        cls.kwd = Keywords()

    @classmethod
    def tearDownClass(cls):
        pass

    @mock.patch("requests.put", side_effect=mock_requests_put)
    def test_cancel_recordings(self, _mock_put):
        """Positive unit test of get_recording_state_for_events() keyword."""
        result = self.kwd.cancel_recording(LAB_CONF["MOCK"], CUSTOMER_ID, CRED_ID)
        self.assertEqual(result.text, SAMPLE_CANCEL_RECORDING)

class TestKeyword_GetDetailsOfRecording(TestCaseNameAsDescription):
    """Class contains unit tests of cancel_recording() keyword."""

    @classmethod
    def setUpClass(cls):
        cls.kwd = Keywords()

    @classmethod
    def tearDownClass(cls):
        pass


    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_details_of_recording(self, _mock_get):
        """Positive unit test of get_recording_state_for_events() keyword."""
        result = self.kwd.get_details_of_recording(LAB_CONF["MOCK"], CUSTOMER_ID, CRED_ID, "language", "mock_cpe_id")
        self.assertEqual(result.text, MOCK_RECORDING_DETAILS)

class TestKeyword_GetSimpleRecordingFullResponse(TestCaseNameAsDescription):
    """Class contains unit tests of cancel_recording() keyword."""

    @classmethod
    def setUpClass(cls):
        cls.kwd = Keywords()

    @classmethod
    def tearDownClass(cls):
        pass

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_details_of_recording(self, _mock_get):
        """Positive unit test of get_recording_state_for_events() keyword."""
        result = self.kwd.get_simple_recordings_full_response(LAB_CONF["MOCK"], CUSTOMER_ID)
        self.assertEqual(result.text, MOCK_SIMPLE_RECORDING)

class TestKeyword_GetScheduleRecordingShow(TestCaseNameAsDescription):
    """Class contains unit tests of schedule_recording_show() keyword."""

    @classmethod
    def setUpClass(cls):
        cls.kwd = Keywords()

    @classmethod
    def tearDownClass(cls):
        pass

    @mock.patch("requests.post", side_effect=mock_requests_post)
    def test_schedule_recording_show(self, _mock_post):
        """Positive unit test of schedule_recording_show() keyword."""
        result = self.kwd.schedule_recording_show(LAB_CONF["MOCK"], "cust", "event", "show")
        self.assertEqual(result.text, SCHEDULE_RECORDING_SHOW)

class TestKeyword_GetListOfEpisodeSeason(TestCaseNameAsDescription):
    """Class contains unit tests of get_list_of_episodes_season() keyword."""

    @classmethod
    def setUpClass(cls):
        cls.kwd = Keywords()

    @classmethod
    def tearDownClass(cls):
        pass

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_list_of_episodes_season(self, _mock_get):
        """Positive unit test of get_list_of_episodes_season() keyword."""
        result = self.kwd.get_list_of_episodes_season(LAB_CONF["MOCK"], "cust", "profile", "seasons",
                                                      "language", "source")
        self.assertEqual(result.text, LIST_OF_EPISODE_SEASON)

class TestKeyword_GetListOfEpisodeShow(TestCaseNameAsDescription):
    """Class contains unit tests of get_list_of_episodes_show() keyword."""

    @classmethod
    def setUpClass(cls):
        cls.kwd = Keywords()

    @classmethod
    def tearDownClass(cls):
        pass

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_get_list_of_episodes_show(self, _mock_get):
        """Positive unit test of get_get_list_of_episodes_show() keyword."""
        result = self.kwd.get_list_of_episodes_show(LAB_CONF["MOCK"], "cust", "profile", "shows", "channel",
                                                    "language", "source", "mock_cpe_id")
        self.assertEqual(result.text, LIST_OF_EPISODE_SHOW)

class TestKeyword_SetBookmarkSingleRecording(TestCaseNameAsDescription):
    """Class contains unit tests of set_bookmark_single_recording() keyword."""

    @classmethod
    def setUpClass(cls):
        cls.kwd = Keywords()

    @classmethod
    def tearDownClass(cls):
        pass

    @mock.patch("requests.put", side_effect=mock_requests_put)
    def test_set_bookmark_single_recording(self, _mock_put):
        """Positive unit test of set_bookmark_single_recording() keyword."""
        result = self.kwd.set_bookmark_single_recording(LAB_CONF["MOCK"], "cust", "recId")
        self.assertEqual(result.text, SET_BOOKMARK_SINGLE_RECORDING)

class TestKeyword_SetViewStateSingleRecording(TestCaseNameAsDescription):
    """Class contains unit tests of set_view_state_single_recording() keyword."""

    @classmethod
    def setUpClass(cls):
        cls.kwd = Keywords()

    @classmethod
    def tearDownClass(cls):
        pass

    @mock.patch("requests.put", side_effect=mock_requests_put)
    def test_set_view_state_single_recording(self, _mock_put):
        """Positive unit test of set_view_state_single_recording() keyword."""
        result = self.kwd.set_view_state_single_recording(LAB_CONF["MOCK"], "cust", "recordId")
        self.assertEqual(result.text, SET_VIEW_STATE_SINGLE_RECORDING)


class TestKeyword_GetRecordedRecordings(TestCaseNameAsDescription):
    """Class contains unit tests of get_recorded_recordings() keyword."""

    @classmethod
    def setUpClass(cls):
        cls.kwd = Keywords()

    @classmethod
    def tearDownClass(cls):
        pass

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_recorded_recordings(self, _mock_get):
        """Positive unit test of get_recorded_recordings() keyword."""
        result = self.kwd.get_recorded_recordings(LAB_CONF["MOCK"], CUSTOMER_ID, "profile", IS_ADULT, LIMIT, "mock_cpe_id")
        struct = json.loads(result.text)
        self.assertEqual(struct, json.loads(SAMPLE_RECORDED_RECORDINGS))

class TestKeyword_DeleteBooking(TestCaseNameAsDescription):
    """Class contains unit tests of set_bookmark_single_recording() keyword."""

    @classmethod
    def setUpClass(cls):
        cls.kwd = Keywords()

    @classmethod
    def tearDownClass(cls):
        pass

    @mock.patch("requests.delete", side_effect=mock_requests_delete)
    def test_delete_booking(self, _mock_put):
        """Positive unit test of delete_booking keyword."""
        result = self.kwd.delete_booking(LAB_CONF["MOCK"], "cust", "single", "eventId_delete")
        self.assertEqual(result.status_code, DELETE_BOOKING_RESPONSE)

def suite_recs_m_service_requests():
    """A function builds a test suite for methods of Recording_Microservice_Requests() class."""
    return unittest.makeSuite(Test_RecordingMicroserviceRequests, "test")


def suite_kwd_customers_recordings():
    """A function builds a test suite for get_customers_recordings() keyword."""
    return unittest.makeSuite(TestKeyword_GetRecordingMicroserviceRecordings, "test")


def suite_kwd_customers_bookings():
    """A function builds a test suite for get_customers_bookings() keyword."""
    return unittest.makeSuite(TestKeyword_GetRecordingMicroserviceBookings, "test")


def suite_kwd_customers_recordings_state():
    """A function builds a test suite for get_customers_recordings() keyword."""
    return unittest.makeSuite(TestKeyword_GetRecordingMicroserviceRecordingsState, "test")

def suite_kwd_cancel_recording():
    """A function builds a test suite for cancel_recording() keyword."""
    return unittest.makeSuite(TestKeyword_CancelRecordings, "test")

def suite_kwd_get_details_of_recording():
    """A function builds a test suite for cancel_recording() keyword."""
    return unittest.makeSuite(TestKeyword_GetDetailsOfRecording, "test")

def suite_kwd_get_simple_recordings_full_response():
    """A function builds a test suite for cancel_recording() keyword."""
    return unittest.makeSuite(TestKeyword_GetSimpleRecordingFullResponse, "test")

def suite_kwd_schedule_recording_show():
    """A function builds a test suite for methods of Recording_Microservice_Requests() class."""
    return unittest.makeSuite(TestKeyword_GetScheduleRecordingShow, "test")

def suite_kwd_get_list_of_episodes_season():
    """A function builds a test suite for get_list_of_episodes_season() keyword."""
    return unittest.makeSuite(TestKeyword_GetListOfEpisodeSeason, "test")

def suite_kwd_get_list_of_episodes_show():
    """A function builds a test suite for get_list_of_episodes_show() keyword."""
    return unittest.makeSuite(TestKeyword_GetListOfEpisodeShow, "test")

def suite_kwd_set_bookmark_single_recording():
    """A function builds a test suite for set_bookmark_single_recording() keyword."""
    return unittest.makeSuite(TestKeyword_SetBookmarkSingleRecording, "test")

def suite_kwd_set_view_state_single_recording():
    """A function builds a test suite for set_view_state_single_recording() keyword."""
    return unittest.makeSuite(TestKeyword_SetViewStateSingleRecording, "test")

def suite_kwd_get_recorded_recordings():
    """A function builds a test suite for get_recorded_recordings() keyword."""
    return unittest.makeSuite(TestKeyword_GetRecordedRecordings, "test")

def suite_kwd_delete_booking():
    """A function builds a test suite for get_recorded_recordings() keyword."""
    return unittest.makeSuite(TestKeyword_DeleteBooking, "test")

def run_tests():
    """A function to run unit tests (real Recording MicroService will not be used)."""
    suites = [
        suite_recs_m_service_requests(),
        suite_kwd_customers_recordings(),
        suite_kwd_customers_bookings(),
        suite_kwd_customers_recordings_state(),
        suite_kwd_cancel_recording(),
        suite_kwd_get_details_of_recording(),
        suite_kwd_get_simple_recordings_full_response(),
        suite_kwd_schedule_recording_show(),
        suite_kwd_get_list_of_episodes_season(),
        suite_kwd_get_list_of_episodes_show(),
        suite_kwd_set_bookmark_single_recording(),
        suite_kwd_set_view_state_single_recording(),
        suite_kwd_get_recorded_recordings(),
        suite_kwd_delete_booking()
    ]
    for suite in suites:
        unittest.TextTestRunner(verbosity=2).run(suite)


def debug():
    """A function to get customers' recordings and bookings from real Recording Microservice
    in the "lab5A UPCless" lab."""
    print((Keywords().get_customers_recordings(LAB_CONF["REAL"], CUSTOMER_ID)))
    print((Keywords().get_customers_bookings(LAB_CONF["REAL"], CUSTOMER_ID, IS_ADULT)))


if __name__ == "__main__":
    # debug()
    run_tests()
