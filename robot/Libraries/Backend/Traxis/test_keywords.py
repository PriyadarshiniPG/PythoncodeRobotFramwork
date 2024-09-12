# pylint: disable=unused-argument
# Disabled pylint "unused-argument" complaining on args for mock patches'

"""Unit tests of Traxis library's keywords for Robot Framework.

Tests use mock module and do not send real requests to real Traxis.
The global function debug() can be used for testing requests to real Traxis.

v0.0.1 - Natallia Savelyeva: Implementation unittest: requests and get recordings
v0.0.2 - Fernando Cobos: Add get_favourite_channels to unittest
v0.0.3 - Fernando Cobos: Add get_profiles to unittest
v0.0.4 - Vishwanand Upadhyay: Add get_tstv_events to unittest
v0.0.5 - Anuj Teotia: Add get_channel_logo to unittest
"""
import json
import unittest
try:
    import mock
except ImportError:
    import unittest.mock as mock
from .keywords import Keywords


CPE_ID = "3C36E4-EOSSTB-003356472104"

LAB_CONF = {
    "MOCK":
        {"SEACHANGE": {"TRAXIS_WEB": {"host": "172.30.94.4", "port": 80, "path": "traxis/web"}}}
}

IMAGE_URL = "https://staticqbr-nl-labe2esi.lab.cdn.dmdsdp.com \
            /image-service/ImagesEPG/EventImages/npo_101.png"

SAMPLE_TRAXIS_RECORDINGS = """{
  "Recordings": {
    "resultCount": 0,
    "Recording": []
  }
}"""

SAMPLE_TRAXIS_CHANNELLISTS = """{
 "ChannelLists": {
  "resultCount": 1,
  "ChannelList": [
    {
     "id": "acea256f-e1eb-48dd-af96-e15eb2e97cdd",
     "Channels": {
       "resultCount": 5,
        "Channel": [
         {
           "id": "0062"
         },
         {
           "id": "0064"
         },
         {
           "id": "0066"
         },
         {
           "id": "0162"
         },
         {
           "id": "0163"
         }
        ]
    },
    "ChannelCount": 5,
    "Name": "FAVORITE:Favorites:3256f840-4d12-11e7-85f5-e5a72ae6734d_nlMasterProfile",
    "ProfileId": "3256f840-4d12-11e7-85f5-e5a72ae6734d_nl~~23MasterProfile",
    "IsPersonal": false,
    "CollectionItemResourceType": "ChannelList"
   }
  ]
 }
}"""

SAMPLE_TRAXIS_PROFILES = """
{
  "Profiles": {
    "resultCount": 1,
    "Profile": [
      {
        "id": "3256f840-4d12-11e7-85f5-e5a72ae6734d_nl~~23MasterProfile",
        "Name": "MyProfile",
        "Language": "nl",
        "CustomData": "..................",
        "Pin": "0000",
        "CollectionItemResourceType": "Profile"
      }
    ]
  }
}"""

SAMPLE_TRAXIS_CHANNEL_MAP = """
{
  "Channels": {
    "resultCount": 1,
    "Channel": [
      {
        "id": "0001",
        "LogicalChannelNumber": 1,
        "IsViewableOnCpe": true,
        "Name": "101",
        "Pictures": {
          "Picture": [
            {
              "Value": "http://oboposter.labe2esi.nl.dmdsdp.com/ImagesEPG/Eventimages/101.png",
              "type": "focused"
            },
            {
              "Value": "http://oboposter.labe2esi.nl.dmdsdp.com/ImagesEPG/Eventimages/101.png",
              "type": "nonfocused"
            }
          ]
        },
        "OnFavorites": false,
        "IsAdult": false,
        "Is3D": false,
        "IsHD": false,
        "Blocked": false,
        "IsAudioOnly": false,
        "Products": {
          "resultCount": 5,
          "Product": [
            {
              "id": "crid:~~2F~~2Feventis.nl~~2F00000000-0000-1000-0008-000100000000"
            },
            {
              "id": "crid:~~2F~~2Feventis.nl~~2F00000000-0000-1000-0008-000100000001"
            },
            {
              "id": "crid:~~2F~~2Feventis.nl~~2F00000000-0000-1000-0008-000100000002"
            },
            {
              "id": "crid:~~2F~~2Feventis.nl~~2F00000000-0000-1000-0008-000999999999"
            },
            {
              "id": "crid:~~2F~~2Fnagra.elk~~2F00000000-0000-0000-0000-000000000009"
            }
          ]
        }
      }
    ]
  }
}
"""

SAMPLE_TRAXIS_CHANNEL_LOCATIONS = """
{
  "ChannelLocations": {
    "resultCount": 2,
    "ChannelLocation": [
      {
        "id": "0001",
        "IsViewableOnCpe": true,
        "Locations": {
          "Location": [
            {
              "Value": "tune://schange.com/qam?frequency=314000000&symbol_rate=6875000&modulation=5&fec_inner~0&fec_outer=0&program_number=306"
            }
          ]
        }
      },
      {
        "id": "0003",
        "IsViewableOnCpe": true,
        "Locations": {
          "Location": [
            {
              "Value": "tune://schange.com/qam?frequency=314000000&symbol_rate=6875000&modulation=5&fec_inner~0&fec_outer=0&program_number=310"
            }
          ]
        }
      }
    ]
  }
}
"""

SAMPLE_TRAXIS_TSTV_EVENTS = """<Channel xmlns="urn:eventis:traxisweb:1.0" id="0020">
<TstvEvents resultCount="346">
<TstvEvent id="crid:~~2F~~2Fbds.tv~~2F105114541,imi:fa27180836fd80aab4fb6a6106152cfc"/>
<TstvEvent id="crid:~~2F~~2Fbds.tv~~2F105114549,imi:dc3bf7b2f9d6c7dd65edf8c2eb7eb83d"/>
</TstvEvents>
</Channel>
"""

SAMPLE_TRAXIS_TSTV_EVENTS_COUNT = """<?xml version="1.0" encoding="utf-8"?>
<Channels resultCount="382" xmlns="urn:eventis:traxisweb:1.0">
  <Channel id="0001">
    <TstvEventCount>430</TstvEventCount>
  </Channel>
  <Channel id="0003">
    <TstvEventCount>46</TstvEventCount>
  </Channel>
  <Channel id="0004">
    <TstvEventCount>353</TstvEventCount>
  </Channel>
  <Channel id="0005">
    <TstvEventCount>328</TstvEventCount>
  </Channel>
</Channels>
"""

SAMPLE_TRAXIS_CHANNEL_IDS = "['1']"
SAMPLE_TRAXIS_ALL_EVENTS = """<Channel xmlns="urn:eventis:traxisweb:1.0" id="0020">
<Events resultCount="628">
<Event id="crid:~~2F~~2Fbds.tv~~2F104329167,imi:00100000002B602C"/>
<Event id="crid:~~2F~~2Fbds.tv~~2F104329187,imi:00100000002B604C"/>
<Event id="crid:~~2F~~2Fbds.tv~~2F104329207,imi:00100000002BACF8"/>
<Event id="crid:~~2F~~2Fbds.tv~~2F107571194,imi:00100000002B600D"/>
</Events>
</Channel>
"""

SAMPLE_TRAXIS_EVENTS_DETAILS = """<Event xmlns="urn:eventis:traxisweb:1.0" \
id="crid:~~2F~~2Fbds.tv~~2F104329167,imi:00100000002B602C">
<Channels resultCount="1">
<Channel id="0020"/>
</Channels>
<ChannelCount>1</ChannelCount>
<ProductCount>0</ProductCount>
<Titles resultCount="1">
<Title id="crid:~~2F~~2Fbds.tv~~2F104329167"/>
</Titles>
<TitleCount>1</TitleCount>
<TstvContentCount>0</TstvContentCount>
<TstvEventCount>0</TstvEventCount>
<TitleId>crid:~~2F~~2Fbds.tv~~2F104329167</TitleId>
<ChannelId>0020</ChannelId>
<Duration>PT25M</Duration>
<DurationInSeconds>1500</DurationInSeconds>
<HasTstv>false</HasTstv>
<TSTVRecordingBlackout>false</TSTVRecordingBlackout>
<HorizontalSize>1280</HorizontalSize>
<VerticalSize>720</VerticalSize>
<IsHD>false</IsHD>
<Is3D>false</Is3D>
<Resolution>Undefined</Resolution>
<DynamicRange>SDR</DynamicRange>
<OriginalResolution>Undefined</OriginalResolution>
<OriginalDynamicRange>SDR</OriginalDynamicRange>
<Aliases>
<Alias type="objectid" organization="RBM" authority="RBM" encoding="text">350735189997</Alias>
<Alias type="IngestedIMI" organization="eventis" authority="eventis" encoding="text">imi:735189997</Alias>
</Aliases>
<AvailabilityStart>2018-04-04T04:00:00Z</AvailabilityStart>
<AvailabilityEnd>2018-04-04T04:25:00Z</AvailabilityEnd>
<IsAvailable>false</IsAvailable>
<NetworkRecordingLicense/>
<NetworkRecordingBlackout>false</NetworkRecordingBlackout>
</Event>"""

SAMPLE_REPLAY_CHANNEL_MAP = """
{
    "Channels": {
        "resultCount": 2,
        "Channel": [
            {
                "id": "4572",
                "Name": "Ziggo Sport Select"
            },
            {
                "id": "4514",
                "Name": "Ketnet"
            }
        ]
    }
}
"""

SAMPLE_FILTER_EVENTS = """
<?xml version="1.0" encoding="utf-8"?>
<Events resultCount="10" xmlns="urn:eventis:traxisweb:1.0">
    <Event id="crid:~~2F~~2Fbds.tv~~2F7042258,imi:e4d39649ed174531f344f5e918502bf3bfda019e">
        <AvailabilityStart>2018-07-08T09:30:00Z</AvailabilityStart>
    </Event>
    <Event id="crid:~~2F~~2Fbds.tv~~2F227839213,imi:a93152abd9e00bc65699108e54f06344316dd5e6">
        <AvailabilityStart>2018-07-08T10:25:00Z</AvailabilityStart>
    </Event>
    <Event id="crid:~~2F~~2Fbds.tv~~2F50382852,imi:fb4fc29240562d98e6f2587669a55eea7b53ac2a">
        <AvailabilityStart>2018-07-08T11:25:00Z</AvailabilityStart>
    </Event>
    <Event id="crid:~~2F~~2Fbds.tv~~2F265784351,imi:9c99252994bd7ef166b44aa5da9faf9e067d6e55">
        <AvailabilityStart>2018-07-08T12:25:00Z</AvailabilityStart>
    </Event>
    <Event id="crid:~~2F~~2Fbds.tv~~2F290309500,imi:cb8f6e45f3749a1fdb27609b0918856477f4d738">
        <AvailabilityStart>2018-07-08T13:25:00Z</AvailabilityStart>
    </Event>
    <Event id="crid:~~2F~~2Fbds.tv~~2F162874182,imi:c7cf8893bbbb899c9c76ac449142e86ead807d02">
        <AvailabilityStart>2018-07-08T14:20:00Z</AvailabilityStart>
    </Event>
    <Event id="crid:~~2F~~2Fbds.tv~~2F276043169,imi:5aed31a1f8ce19afac00b3d7b37790c5cf92bcd2">
        <AvailabilityStart>2018-07-08T15:15:00Z</AvailabilityStart>
    </Event>
    <Event id="crid:~~2F~~2Fbds.tv~~2F290198132,imi:e38b8bd2ab5567936a9e06f20106f7b51c90028c">
        <AvailabilityStart>2018-07-08T16:10:00Z</AvailabilityStart>
    </Event>
    <Event id="crid:~~2F~~2Fbds.tv~~2F285680418,imi:f0a22d5b32b7621df94bcf7bdc8c96288219d759">
        <AvailabilityStart>2018-07-08T17:05:00Z</AvailabilityStart>
    </Event>
    <Event id="crid:~~2F~~2Fbds.tv~~2F281624675,imi:c3005fd1a5a97414b793da2d72b9aa4a7ecc5b10">
        <AvailabilityStart>2018-07-08T18:00:00Z</AvailabilityStart>
    </Event>
</Events>
"""

SAMPLE_IMAGE_HEADER_RESPONSE = """
{'Content-Length': '7504', 'Access-Control-Allow-Headers': 'Accept,Accept-Charset, \
    Accept-Encoding,Accept-Language,Access-Control-Allow-Credentials, \
    Access-Control-Allow-Methods,Access-Control-Allow-Origin, \
    Access-Control-Expose-Headers,Access-Control-Max-Age, \
    Access-Control-Request-Headers,Access-Control-Request-Method, \
    Authorization,Cache-Control,Connection,Content-Encoding, \
    Content-Length,Content-Type,DNT,Date,Expires,Host,If-Modified-Since, \
    Keep-Alive,Origin,Referer,Server,TokenIssueTime, \
    Transfer-Encoding,User-Agent,Vary,X-CustomHeader,X-Forwarded-For, \
    X-Forwarded-Host,X-Forwarded-Server,X-Requested-With,password, \
    username,x-request-id,x-ratelimit-app,x-auth-id,x-auth-key, \
    x-guest-token,X-Real-IP,X-HTTP-Method-Override,x-oesp-username, \
    x-oesp-token,x-cus,X-Client-Id,X-Device-Code,X-Language-Code', \
    'X-Cache': 'MISS from i.cdn.upclabs.com, HIT from d.cdn.upclabs.com', \
    'Age': '3334', 'Access-Control-Allow-Credentials': 'true', \
    'x-request-id': '0c42ed59e97b9fb7279b1bb666afaa32', \
    'Server': 'nginx/1.13.12', 'Via': '1.1 i.cdn.upclabs.com:80 \
    (pcd/45.0.530357.530357 (2018-02-13 09:21:22 UTC)), 1.1 d.cdn.upclabs.com:443 \
    (pcd/45.0.530357.530357 (2018-02-13 09:21:22 UTC))', 'Cache-Control': \
    'max-age=172800, public', 'Date': 'Mon, 20 Aug 2018 12:08:58 GMT', \
    'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Methods': \
    'GET, POST, PUT, OPTIONS, DELETE, HEAD, PATCH', 'Content-Type': 'image/png'}
"""

def mock_requests_get(*args, **kwargs):
    """A method imitates sending requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    url = args[0]
    if "test1" in url:
        response_body = SAMPLE_TRAXIS_RECORDINGS
        code = 200
        reason = "OK"
    elif "test2" in url:
        response_body = SAMPLE_TRAXIS_RECORDINGS
        code = 200
        reason = "OK"
    elif "test3" in url:
        response_body = SAMPLE_TRAXIS_CHANNELLISTS
        code = 200
        reason = "OK"
    elif "test4" in url:
        response_body = SAMPLE_TRAXIS_PROFILES
        code = 200
        reason = "OK"
    elif "TstvEvents" in url:
        response_body = SAMPLE_TRAXIS_TSTV_EVENTS
        code = 200
        reason = "OK"
    elif "tstveventcount" in url:
        response_body = SAMPLE_TRAXIS_TSTV_EVENTS_COUNT
        code = 200
        reason = "OK"
    elif "events" in url and "test" not in url:
        response_body = SAMPLE_TRAXIS_ALL_EVENTS
        code = 200
        reason = "OK"
    elif "test7" in url:
        response_body = SAMPLE_TRAXIS_EVENTS_DETAILS
        code = 200
        reason = "OK"
    elif "test9" in url:
        response_body = SAMPLE_FILTER_EVENTS
        code = 200
        reason = "OK"
    elif "?w=0&h=0" in url:
        response_body = SAMPLE_IMAGE_HEADER_RESPONSE
        code = 200
        reason = "OK"
    response_data = dict(text=response_body, status_code=code, reason=reason)
    return type("", (), response_data)()


def mock_requests_post(*args, **kwargs):
    """A method imitates sending requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    data = kwargs["data"]
    if "test5" in data:
        response_body = SAMPLE_TRAXIS_CHANNEL_MAP
        code = 200
        reason = "OK"
    elif "test6" in data:
        response_body = SAMPLE_TRAXIS_CHANNEL_LOCATIONS
        code = 200
        reason = "OK"
    elif "test7" in data:
        response_body = SAMPLE_REPLAY_CHANNEL_MAP
        code = 200
        reason = "OK"
    response_data = dict(text=response_body, status_code=code, reason=reason)
    return type("", (), response_data)()


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None

@mock.patch("requests.get", side_effect=mock_requests_get)
def get_traxis_recordings(*args):
    """Mocked Traxis recording call"""

    lab_conf, cpe_id = args[:-1]
    return Keywords().get_traxis_recordings(lab_conf, cpe_id)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_traxis_favourite_channels(*args):
    """Mocked Traxis Favourite Channels call"""

    lab_conf, cpe_id = args[:-1]
    return Keywords().get_traxis_favourites_channels(lab_conf, cpe_id)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_traxis_profiles(*args):
    """Mocked Traxis profiles call"""

    lab_conf, cpe_id = args[:-1]
    return Keywords().get_traxis_profiles(lab_conf, cpe_id)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_tstv_events(*args):
    """Mocked Traxis get tstv events call"""

    lab_conf, channel_ids = args[:-1]
    return Keywords().get_tstv_events(lab_conf, channel_ids)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_tstv_events_count(*args):
    """Mocked Traxis get tstv events count call"""

    lab_conf, = args[:-1]
    return Keywords().get_tstv_events_count(lab_conf)


@mock.patch("requests.post", side_effect=mock_requests_post)
def get_epg_channel_map(*args):
    """Mocked Traxis channel map call"""

    lab_conf, cpe_id = args[:-1]
    return Keywords().get_epg_channel_map(lab_conf, cpe_id)


@mock.patch("requests.post", side_effect=mock_requests_post)
def get_epg_channel_locations(*args):
    """Mocked Traxis Channel Locations call"""

    lab_conf, cpe_id = args[:-1]
    return Keywords().get_epg_channel_locations(lab_conf, cpe_id)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_all_events(*args):
    """Mocked Traxis get all events """

    lab_conf, channel_ids = args[:-1]
    return Keywords().get_all_events(lab_conf, channel_ids)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_event_details(*args):
    """Mocked Traxis get event details """

    lab_conf, event_id = args[:-1]
    return Keywords().get_event_details(lab_conf, event_id)

@mock.patch("requests.post", side_effect=mock_requests_post)
def get_replay_channel_map(*args):
    """Mocked Traxis Replay Channel Map call"""

    lab_conf, cpe_id = args[:-1]
    return Keywords().get_replay_channel_map(lab_conf, cpe_id)

@mock.patch("requests.get", side_effect=mock_requests_get)
def filter_events(*args):
    """Mocked Traxis Filter Events call"""
    lab_conf, channel_id, start_time, end_time = args[:-1]
    return Keywords().filter_events(lab_conf, channel_id, start_time, end_time)

@mock.patch("requests.get", side_effect=mock_requests_get)
def get_channel_logo(*args):
    """Mocked Traxis Get Channel Logo call"""
    logo_url = args[:-1]
    return Keywords().get_channel_logo(logo_url)

class TestKeyword_Traxis(TestCaseNameAsDescription):
    """Class contains unit tests of Traxis keywords."""

    def test_get_response(self):
        """Positive unit test of parsing successful Traxis response text."""
        self.assertEqual(get_traxis_recordings(LAB_CONF["MOCK"], "test1"),
                         json.loads(SAMPLE_TRAXIS_RECORDINGS))

    def test_get_recordings(self):
        """Positive unit test of Traxis recordings call"""
        self.assertEqual(get_traxis_recordings(LAB_CONF["MOCK"], "test2"),
                         json.loads(SAMPLE_TRAXIS_RECORDINGS))

    def test_get_favourite_channels(self):
        """Positive unit test of get_traxis_favourites_channels"""
        self.assertEqual(json.loads(get_traxis_favourite_channels(LAB_CONF["MOCK"], "test3").text),
                         json.loads(SAMPLE_TRAXIS_CHANNELLISTS))

    def test_get_profiles(self):
        """Positive unit test of get_traxis_profiles()"""
        self.assertEqual(json.loads(get_traxis_profiles(LAB_CONF["MOCK"], "test4").text),
                         json.loads(SAMPLE_TRAXIS_PROFILES))

    def test_epg_channel_map(self):
        """Positive unit test of get_epg_channel_map"""
        test = get_epg_channel_map(LAB_CONF["MOCK"], "test5")
        self.assertEqual(json.loads(test.text),
                         json.loads(SAMPLE_TRAXIS_CHANNEL_MAP))

    def test_epg_channel_locations(self):
        """Positive unit test of get_epg_channel_locations"""
        test = get_epg_channel_locations(LAB_CONF["MOCK"], "test6")
        self.assertEqual(json.loads(test.text),
                         json.loads(SAMPLE_TRAXIS_CHANNEL_LOCATIONS))

    def test_get_tstv_events(self):
        """"Positive unit test of get_tstv_events"""
        test = get_tstv_events(LAB_CONF["MOCK"], SAMPLE_TRAXIS_CHANNEL_IDS)
        self.assertEqual(test.text, SAMPLE_TRAXIS_TSTV_EVENTS)

    def test_get_tstv_events_count(self):
        """"Positive unit test of get_tstv_events"""
        test = get_tstv_events_count(LAB_CONF["MOCK"])
        self.assertEqual(test.status_code, 200)
        self.assertEqual(test.reason, "OK")
        self.assertEqual(test.text, SAMPLE_TRAXIS_TSTV_EVENTS_COUNT)

    def test_get_all_events(self):
        """"Positive unit test of get_all_events"""
        test = get_all_events(LAB_CONF["MOCK"], SAMPLE_TRAXIS_CHANNEL_IDS)
        self.assertEqual(test.text, SAMPLE_TRAXIS_ALL_EVENTS)

    def test_get_event_details(self):
        """"Positive unit test of get_event_details"""
        test = get_event_details(LAB_CONF["MOCK"], "test7")
        self.assertEqual(test.text, SAMPLE_TRAXIS_EVENTS_DETAILS)

    def test_replay_channel_map(self):
        """Positive unit test of test_replay_channel_map"""
        test = get_replay_channel_map(LAB_CONF["MOCK"], "test7")
        self.assertEqual(json.loads(test.text),
                         json.loads(SAMPLE_REPLAY_CHANNEL_MAP))

    def test_filter_events(self):
        """Positive unit test of test_filter_events"""
        test = filter_events(LAB_CONF["MOCK"], "test9",
                             "2018-05-11T15:00:00", "2018-07-11T15:00:00")
        self.assertEqual(test.text,
                         SAMPLE_FILTER_EVENTS)

    def test_get_channel_logo(self):
        """Positive unit test of test_filter_events"""
        test = get_channel_logo(IMAGE_URL)
        self.assertEqual(test.text, SAMPLE_IMAGE_HEADER_RESPONSE)


def suite_traxis():
    """A function builds a test suite for TraxisRequests() class methods."""
    return unittest.makeSuite(TestKeyword_Traxis, "test")


def run_tests():
    """A function to run unit tests (real Traxis will not be used)."""
    suite = suite_traxis()
    unittest.TextTestRunner(verbosity=2).run(suite)


def debug():
    """A function to get recordings from real Traxis in "lab5A UPCless" lab."""
    print((Keywords().get_traxis_recordings(LAB_CONF["REAL"], CPE_ID)))
    print((Keywords().get_traxis_favourites_channels(LAB_CONF["REAL"], CPE_ID)))
    print((Keywords().get_traxis_profiles(LAB_CONF["REAL"], CPE_ID)))
    print((Keywords().get_traxis_profiles_customer_id(LAB_CONF["REAL"], CPE_ID)))


if __name__ == "__main__":
    # debug()
    run_tests()
