# pylint: disable=unused-argument
# Disabled pylint "unused-argument" since it's required,
# but internal in mocked functions.
"""Unit tests of Fabrix library's keywords for Robot Framework.

Tests use mock module and do not send real requests to real Fabrix.
The global function debug() can be used for testing requests to real Fabrix.
"""
import re
import unittest
try:
    import mock
except ImportError:
    import unittest.mock as mock
from .keywords import Keywords, Assets

PATTERN_ID = r"[0-9a-f\-]{36}"

ASSETS = """<?xml version="1.0" encoding="UTF-8"?>
<search_vod_assets_reply>
	<total_results>2287</total_results>
	<assets>
		<asset>
			<id>83d21f7e-3b59-4bbb-9073-f0622c44b016</id>
			<name>sd 1xAud 1xSub 01:15 Susa 2010/Arrivo</name>
			<state>2</state>
			<type>1</type>
			<duration>PT01H15M25.360S</duration>
			<total_size>2127030774</total_size>
			<request_time>2015-01-29T12:33:36Z</request_time>
			<ready_time>2015-01-29T12:38:58Z</ready_time>
			<initiator>3D</initiator>
			<is_ad>false</is_ad>
		</asset>
		<asset>
			<id>15bee40d-0646-477b-8461-6a17f2c13cba</id>
			<name>
sd 3xAud 3xSub 00:05 Sintel 2010 V14 @00:05:13:12/Arrivo
			</name>
			<state>2</state>
			<type>1</type>
			<duration>PT05M00S</duration>
			<total_size>164877430</total_size>
			<request_time>2015-01-29T12:35:28Z</request_time>
			<ready_time>2015-01-29T12:35:53Z</ready_time>
			<initiator>3D</initiator>
			<is_ad>false</is_ad>
		</asset>
	</assets>
</search_vod_assets_reply>"""

PROPERTIES = """<?xml version="1.0" encoding="UTF-8"?>
<view_asset_properties>
	<id>80f3e0ddc1134c240e24f11bc762eda1_ec80816b362f47f54c637f2ad253deb4</id>
	<name>crid://schange.com/1001/ts0000_20170815_115252pt</name>
	<state>2</state>
	<type>2</type>
	<duration>PT26S</duration>
	<total_size>14577664</total_size>
	<close_caption>false</close_caption>
	<request_time>2017-08-16T20:20:27Z</request_time>
	<ready_time>2017-08-16T20:20:31Z</ready_time>
	<initiator>airflow</initiator>
	<playout_profile/>
	<is_ad>false</is_ad>
	<package_type>0</package_type>
	<is_encrypted>false</is_encrypted>
	<path>/obo_manage/Countries/E2ESI/FromAirflow/\
crid~~3A~~2F~~2Fog.libertyglobal.com~~2F1001~~2Fts0000_20170815_115252pt/\
80f3e0ddc1134c240e24f11bc762eda1_ec80816b362f47f54c637f2ad253deb4</path>
	<video_data>
		<type>2</type>
		<hres>720</hres>
		<vres>288</vres>
		<bw>1797280</bw>
		<random_access_points>14</random_access_points>
		<max_gop_size>100</max_gop_size>
		<frame_rate>25.00</frame_rate>
		<id>1</id>
		<avg_es_bw>1500469</avg_es_bw>
		<avg_ts_bw>1579094</avg_ts_bw>
	</video_data>
	<video_data>
		<type>2</type>
		<hres>720</hres>
		<vres>1080</vres>
		<bw>4363104</bw>
		<random_access_points>15</random_access_points>
		<max_gop_size>50</max_gop_size>
		<frame_rate>25.00</frame_rate>
		<id>2</id>
		<avg_es_bw>2040215</avg_es_bw>
		<avg_ts_bw>2073423</avg_ts_bw>
	</video_data>
	<audio_data>
		<audio_type>5</audio_type>
		<lang_code>000000</lang_code>
		<bw>128000</bw>
		<pid>221</pid>
	</audio_data>
	<pod>MTlab_vod-ogn</pod>
</view_asset_properties>
"""

RECORDINGS = """<?xml version="1.0" encoding="UTF-8"?>
<SearchRecordingsReply TotalResults="9003">
	<Recording ShowingID="5f1be012-63e6-42fa-8539-8e7291e582c3" HomeID="NPVR" Channel="Replay_42_HD" StartTime="2017-07-21T13:05:00Z" EndTime="2017-07-21T13:45:00Z" NowRecording="false" Progress="100">
		<CBRDetails Size="1668787200" Duration="PT39M58.960S" State="3"/>
	</Recording>
	<Recording ShowingID="7b8c369a-0cfb-4b48-b42b-d644bb952876" HomeID="NPVR" Channel="Nick_Jr" StartTime="2017-07-21T13:05:00Z" EndTime="2017-07-21T13:45:00Z" NowRecording="false" Progress="100">
		<CBRDetails Size="770883072" Duration="PT39M59.360S" State="3"/>
	</Recording>
</SearchRecordingsReply>"""


def mock_requests_get(*args):
    """A method imitates sending requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    url = args[0]
    status_code, reason = 200, "OK"
    if "recordings" in url:
        response_text = RECORDINGS
    elif "assets" in url:
        response_text = ASSETS
    elif "properties" in url:
        response_text = PROPERTIES
    else:
        response_text, status_code, reason = "", 404, "Not Found"
    data = dict(text=response_text, status_code=status_code, reason=reason)
    return type("", (), data)()


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_assets(*args):
    """A function to return a predefined response from Fabrix using mock module.

    :param _mock_get: is required for internal use - to perform @mock.patch.
    :param args: a list of arguments (host, port, min_duration, limit).

    :return: a list of asset ids.
    """
    host, port, min_duration, max_duration, limit = args[:-1]
    return Keywords().get_assets(host, port, min_duration, max_duration, limit)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_recordings(*args):
    """A function to return a predefined response from Fabrix using mock module.

    :param _mock_get: is required for internal use - to perform @mock.patch.
    :param args: a list of arguments (host, port, min_duration, limit).

    :return: a list of recordings ids.
    """
    host, port, min_duration, limit = args[:-1]
    return Keywords().get_recordings(host, port, min_duration, limit)


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


class TestKeyword_GetAssets(TestCaseNameAsDescription):
    """Class contains unit tests of get_assets() keyword."""

    @classmethod
    def setUpClass(cls):
        cls.assets = get_assets("127.0.0.1", 5929, 300, 4800, 2)

    @classmethod
    def tearDownClass(cls):
        pass

    def test_assets_count(self):
        """Check the number of collected assets."""
        self.assertEqual(len(self.assets), 2)

    def test_assets_ids_match_mask(self):
        """Check collected assets' ids."""
        for asset in self.assets:
            id_matches_pattern = bool(re.match(PATTERN_ID, asset))
            self.assertTrue(id_matches_pattern)

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_asset_properties(self, *args):
        """Check parsing Fabrix response of VoD asset properties."""
        asset = "80f3e0ddc1134c240e24f11bc762eda1_ec80816b362f47f54c637f2ad253deb4"
        data = Assets("127.0.0.1", 5929).read_asset_properties(asset)
        self.assertEqual(data["id"], asset)


class TestKeyword_GetRecordings(TestCaseNameAsDescription):
    """Class contains unit tests of get_recordings() keyword."""

    @classmethod
    def setUpClass(cls):
        cls.recordings = get_recordings("127.0.0.1", 5929, 300, 2)

    @classmethod
    def tearDownClass(cls):
        pass

    def test_recordings_count(self):
        """Check the number of collected recordings."""
        self.assertEqual(len(self.recordings), 2)

    def test_recordings_ids_match_mask(self):
        """Check collected recordings' ids."""
        for rec in self.recordings:
            id_matches_pattern = bool(re.match(PATTERN_ID, rec))
            self.assertTrue(id_matches_pattern)


def suite_assets():
    """A function builds a test suite for get_assets() keyword."""
    return unittest.makeSuite(TestKeyword_GetAssets, "test")


def suite_recordings():
    """A function builds a test suite for get_recordings() keyword."""
    return unittest.makeSuite(TestKeyword_GetRecordings, "test")


def run_tests():
    """A function to run unit tests (real Traxis will not be used)."""
    suites = [
        suite_assets(),
        suite_recordings()
    ]
    for suite in suites:
        unittest.TextTestRunner(verbosity=2).run(suite)


def debug():
    """A function to get VoD assets and recordings from real Fabrix."""
    asset = "80f3e0ddc1134c240e24f11bc762eda1_ec80816b362f47f54c637f2ad253deb4"
    properties = Assets("172.30.107.84", 5929).read_asset_properties(asset)
    print(properties)

    assets = Keywords().get_assets("172.30.100.113", 5929)
    print(assets)

    recordings = Keywords().get_recordings("172.30.100.113", 5929, get_abr=False)
    print(recordings)


if __name__ == "__main__":
    # debug()
    run_tests()
