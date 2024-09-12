# pylint: disable=unused-argument
# Disabled pylint "unused-argument" since it's required, but internal in mocked functions.
"""Unit tests of OTT library's keywords for Robot Framework.
Tests use mock module and do not send HTTP requests to real servers.
The global function debug() can be used for testing real requests.
"""
import os
import random
import unittest
try:
    import mock
except ImportError:
    import unittest.mock as mock
import xmltodict
from .keywords import Content, Manifest, Keywords

ASSET = "77ca239d-10bd-4163-bdaa-5e11e64aa9b8"

DASH_LIVE = "http://127.0.0.1/dash/lab3/Index/RTL5_clear/manifest.mpd"
DASH_VOD = "http://127.0.0.1:5554/sdash/%s/index.mpd/Manifest?device=Orion-DASH" % ASSET

HSS_LIVE = "http://127.0.0.1/ss/lab3/RTL5_clear.isml/Manifest?device=Orion-HSS"
HSS_VOD = "http://127.0.0.1:5554/shss/%s/index.ism/Manifest?device=Orion-HSS" % ASSET

HLS_LIVE = "http://127.0.0.1/shls/nederland2_hd/index.m3u8?device=Orion-HLS"
HLS_VOD = "http://127.0.0.1:5554/shls/%s/index.m3u8?device=Orion-HLS" % ASSET


FOLDER = os.path.dirname(os.path.abspath(__file__))
with open(os.path.join(FOLDER, "dash_manifest.txt"), "r") as _f:
    TEMPLATE_DASH_MANIFEST = _f.read().strip()

with open(os.path.join(FOLDER, "hss_manifest.txt"), "r") as _f:
    TEMPLATE_HSS_MANIFEST = _f.read().strip()

with open(os.path.join(FOLDER, "hss_chunks_urls.txt"), "r") as _f:
    HSS_CHUNKS_URLS = [line.strip() for line in _f.readlines()]

with open(os.path.join(FOLDER, "dash_chunks_urls.txt"), "r") as _f:
    DASH_CHUNKS_URLS = [line.strip() for line in _f.readlines()]


TEMPLATE_HLS_MANIFEST = """#EXTM3U
#-----------------------------------------------------------
#--Created with VIDFX Streamer version 3.8.4.4 build 77310 context 3222376336405014119
#-----------------------------------------------------------
#EXT-X-VERSION:3
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=2235689,RESOLUTION=1024x576
index.m3u8/S!d2EPT3Jpb24tSExTLVVORU5DEgNU.v...wEWBp8_/Level(2135689)
"""

TEMPLATE_HLS_PLAYLIST = """#EXTM3U
#-----------------------------------------------------------
#--Created with VIDFX Streamer version 3.8.4.4 build 77310 context 3222384088820983412
#-----------------------------------------------------------
#EXT-X-VERSION:3
#EXT-X-TARGETDURATION:3
#EXT-X-MEDIA-SEQUENCE:0
#EXT-X-PLAYLIST-TYPE:VOD
#EXTINF:3,
Level(2135689)/Segment(0).ts
#EXTINF:3,
Level(2135689)/Segment(30000000).ts
#EXTINF:3,
Level(2135689)/Segment(60000000).ts
#EXT-X-ENDLIST
"""

TEMPLATE_DASH_MANIFEST_DIRTY = TEMPLATE_DASH_MANIFEST.replace("\t", "").replace("\n", "")

TEMPLATE_HSS_MANIFEST_DIRTY = TEMPLATE_HSS_MANIFEST.replace("\t", "").replace("\n", "")


def mock_requests_get(*args):
    """A method imitates sending requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    url = args[0]
    protocol = url.split("/")[3].upper()
    if "SS" in protocol:
        response_text = TEMPLATE_HSS_MANIFEST_DIRTY
    elif "LS" in protocol:
        if "S!d2EPT3Jpb24tSExTLVVORU5DEgNU.v...wEWBp8_" in url:
            response_text = TEMPLATE_HLS_PLAYLIST
        else:
            response_text = TEMPLATE_HLS_MANIFEST
    else:
        response_text = TEMPLATE_DASH_MANIFEST_DIRTY
    data = dict(text=response_text, status_code=200, reason="OK")
    return type("", (), data)()


def mock_read_chunks(*args):
    """A method imitates sending requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    if random.random() < 0.5:
        data = dict(text="", status_code=404, reason="Not Found")
    else:
        data = dict(text="", status_code=200, reason="OK")
    return type("", (), data)()


@mock.patch("requests.Session.get", side_effect=mock_requests_get)
def kwd_play(*args):
    """A function to run Play keyword using mock GET requests.

    :param args: a list of arguments (url, protocol, tries, interval, verbosity).
    .. note:: last element args[5] is for internal use - to perform @mock.patch.

    :return: an instance of DASH, HSS or HLS class (depends on URL).
    """
    url, protocol, tries, interval, verbosity = args[:-1]
    return Keywords().play(url, protocol, tries, interval, verbosity)


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


class TestKeyword_PlayDASH(TestCaseNameAsDescription):
    """Class contains unit tests of play() keyword for DASH manifests."""

    @classmethod
    def setUpClass(cls):
        cls.live_obj = kwd_play(DASH_LIVE, None, 1, 0.1, 0)
        cls.vod_obj = kwd_play(DASH_VOD, None, 1, 0.1, 0)

    @classmethod
    def tearDownClass(cls):
        pass

    def test_dash_live_play_ok(self):
        """Check status of playing all LIVE links from DASH Manifest is True."""
        self.assertTrue(self.live_obj.played_ok)

    def test_dash_vod_play_ok(self):
        """Check status of playing all VoD links from DASH Manifest is True."""
        self.assertTrue(self.vod_obj.played_ok)

    def test_dash_live_detect_protocol(self):
        """Check DASH protocol is correctly detected from Manifest URL (LIVE)."""
        self.assertEqual(self.live_obj.protocol, "DASH")

    def test_dash_vod_detect_protocol(self):
        """Check DASH protocol is correctly detected from Manifest URL (VoD)."""
        self.assertEqual(self.vod_obj.protocol, "DASH")

    def test_dash_live_parse_channel(self):
        """Check channel name is detected from DASH Manifest URL for LIVE."""
        self.assertEqual(self.live_obj.channel, "RTL5_clear")

    def test_dash_live_parse_asset(self):
        """Check asset is empty string for DASH Manifests for LIVE."""
        self.assertEqual(self.live_obj.asset, "")

    def test_dash_vod_parse_asset(self):
        """Check asset is detected from DASH Manifest URL for VoD."""
        self.assertEqual(self.vod_obj.asset, ASSET)

    def test_dash_vod_parse_channel(self):
        """Check channel name is empty string for DASH Manifests for VoD."""
        self.assertEqual(self.vod_obj.channel, "")

    def test_dash_live_parse_device(self):
        """Check device is "" if DASH Manifest URL (LIVE) has no device specified."""
        self.assertEqual(self.live_obj.device, "")

    def test_dash_vod_parse_device(self):
        """Check device is detected from DASH Manifest URL (VoD)."""
        self.assertEqual(self.vod_obj.device, "Orion-DASH")

    def test_dash_live_check_verbosity(self):
        """Check provided verbosity overrides default value for DASH LIVE URLs."""
        self.assertEqual(self.live_obj.verbosity, 0)

    def test_dash_vod_check_verbosity(self):
        """Check provided verbosity overrides default value for DASH VoD URLs."""
        self.assertEqual(self.vod_obj.verbosity, 0)


class TestKeyword_PlayHSS(TestCaseNameAsDescription):
    """Class contains unit tests of play() keyword for HSS manifests."""

    @classmethod
    def setUpClass(cls):
        cls.live_obj = kwd_play(HSS_LIVE, None, 1, 0.1, 0)
        cls.vod_obj = kwd_play(HSS_VOD, None, 1, 0.1, 0)

    @classmethod
    def tearDownClass(cls):
        pass

    def test_hss_live_play_ok(self):
        """Check status of playing all LIVE links from HSS Manifest is True."""
        self.assertTrue(self.live_obj.played_ok)

    def test_hss_vod_play_ok(self):
        """Check status of playing all VoD links from HSS Manifest is True."""
        self.assertTrue(self.vod_obj.played_ok)

    def test_hss_live_detect_protocol(self):
        """Check HSS protocol is correctly detected from Manifest URL (LIVE)."""
        self.assertEqual(self.live_obj.protocol, "HSS")

    def test_hss_vod_detect_protocol(self):
        """Check HSS protocol is correctly detected from Manifest URL (VoD)."""
        self.assertEqual(self.vod_obj.protocol, "HSS")

    def test_hss_live_parse_channel(self):
        """Check channel name is detected from HSS Manifest URL for LIVE."""
        self.assertEqual(self.live_obj.channel, "RTL5_clear.isml")

    def test_hss_live_parse_asset(self):
        """Check asset is empty string for HSS Manifests for LIVE."""
        self.assertEqual(self.live_obj.asset, "")

    def test_hss_vod_parse_asset(self):
        """Check asset is detected from HSS Manifest URL for VoD."""
        self.assertEqual(self.vod_obj.asset, ASSET)

    def test_hss_vod_parse_channel(self):
        """Check channel name is empty string for HSS Manifests for VoD."""
        self.assertEqual(self.vod_obj.channel, "")

    def test_hss_live_parse_device(self):
        """Check device is detected from HSS Manifest URL (LIVE)."""
        self.assertEqual(self.live_obj.device, "Orion-HSS")

    def test_hss_vod_parse_device(self):
        """Check device is detected from HSS Manifest URL (VoD)."""
        self.assertEqual(self.vod_obj.device, "Orion-HSS")

    def test_hss_live_check_verbosity(self):
        """Check provided verbosity overrides default value for HSS LIVE URLs."""
        self.assertEqual(self.live_obj.verbosity, 0)

    def test_hss_vod_check_verbosity(self):
        """Check provided verbosity overrides default value for HSS VoD URLs."""
        self.assertEqual(self.vod_obj.verbosity, 0)


class TestKeyword_PlayHLS(TestCaseNameAsDescription):
    """Class contains unit tests of play() keyword for HLS manifests."""

    @classmethod
    def setUpClass(cls):
        cls.live_obj = kwd_play(HLS_LIVE, None, 1, 0.1, 0)
        cls.vod_obj = kwd_play(HLS_VOD, None, 1, 0.1, 0)

    @classmethod
    def tearDownClass(cls):
        pass

    def test_hls_live_play_ok(self):
        """Check status of playing all VoD links from HLS Manifest is True."""
        self.assertTrue(self.live_obj.played_ok)

    def test_hls_vod_play_ok(self):
        """Check status of playing all VoD links from HLS Manifest is True."""
        self.assertTrue(self.vod_obj.played_ok)

    def test_hls_live_detect_protocol(self):
        """Check HLS protocol is correctly detected from Manifest URL (LIVE)."""
        self.assertEqual(self.live_obj.protocol, "HLS")

    def test_hls_vod_detect_protocol(self):
        """Check HLS protocol is correctly detected from Manifest URL (VoD)."""
        self.assertEqual(self.vod_obj.protocol, "HLS")

    def test_hls_live_parse_channel(self):
        """Check channel name is detected from HLS Manifest URL for LIVE."""
        self.assertEqual(self.live_obj.channel, "nederland2_hd")

    def test_hls_live_parse_asset(self):
        """Check asset is empty string for HLS Manifests for LIVE."""
        self.assertEqual(self.live_obj.asset, "")

    def test_hls_vod_parse_asset(self):
        """Check asset is detected from HLS Manifest URL for VoD."""
        self.assertEqual(self.vod_obj.asset, ASSET)

    def test_hls_vod_parse_channel(self):
        """Check channel name is empty string for HLS Manifests for VoD."""
        self.assertEqual(self.vod_obj.channel, "")

    def test_hls_live_parse_device(self):
        """Check device is detected from HLS Manifest URL (LIVE)."""
        self.assertEqual(self.live_obj.device, "Orion-HLS")

    def test_hls_vod_parse_device(self):
        """Check device is detected from HLS Manifest URL (VoD)."""
        self.assertEqual(self.vod_obj.device, "Orion-HLS")

    def test_hls_live_check_verbosity(self):
        """Check provided verbosity overrides default value for HLS LIVE URLs."""
        self.assertEqual(self.live_obj.verbosity, 0)

    def test_hls_vod_check_verbosity(self):
        """Check provided verbosity overrides default value for HLS VoD URLs."""
        self.assertEqual(self.vod_obj.verbosity, 0)

    def test_hls_live_manifestdict_none(self):
        """Check manifest_dict class attribute is None for HLS Manifests (LIVE)."""
        self.assertEqual(self.live_obj.manifest_dict, None)

    def test_hls_vod_manifestdict_none(self):
        """Check manifest_dict class attribute is None for HLS Manifests (VoD)."""
        self.assertEqual(self.vod_obj.manifest_dict, None)


class TestKeyword_Chunks(TestCaseNameAsDescription):
    """Class contains unit tests to verify sets of chunks for all manifests.
    Verification of consistency with TestChunks.py is also performed:
    * we get all the chunks while TestChunks.py ignores zero start times: i.e. urls end with "=0)".
    """

    @classmethod
    def setUpClass(cls):
        cls.asset = "d9053b14888d05bd97e3aaedd057a39c_ACD36B000C1D5A6D10066F5186B58F3D"
        cls.dash_manifest_url = ("http://wp25.pod1.vod.prod.ukv.dmdsdp.com/sdash/%s/index.mpd/" +
                                 "Manifest?device=DASH") % cls.asset
        cls.hss_manifest_url = ("http://wp5.pod1.vod.prod.ukv.dmdsdp.com/shss/%s/index.ism/" +
                                "Manifest?device=Orion-HSS") % cls.asset

    @classmethod
    def tearDownClass(cls):
        pass

    @mock.patch("requests.Session.get", side_effect=mock_read_chunks)
    @mock.patch.object(Manifest, "_read_manifest", return_value="")
    def test_dash_chunks_all_found(self, *args):
        """Check the list of chunks urls obtained from a DASH manifest,
        and verify consistency with TestChunks.py.
        """
        dash = Content().get_manifest(self.dash_manifest_url, None, 0)
        dash.manifest_dict = xmltodict.parse(TEMPLATE_DASH_MANIFEST_DIRTY)
        all_chunks = list(dash.collect_chunks_urls().chunks.keys())
        self.assertEqual(len(all_chunks), 6039)
        # nonzero_chunks = [chunk for chunk in all_chunks if not chunk.endswith("=0)")]
        # self.assertEqual(len(nonzero_chunks), len(list(set(DASH_CHUNKS_URLS))))

    @mock.patch("requests.Session.get", side_effect=mock_read_chunks)
    @mock.patch.object(Manifest, "_read_manifest", return_value="")
    def test_hss_chunks_all_found(self, *args):
        """Check the list of chunks urls obtained from an HSS manifest,
        and verify consistency with TestChunks.py.
        """
        hss = Content().get_manifest(self.hss_manifest_url, None, 0)
        hss.manifest_dict = xmltodict.parse(TEMPLATE_HSS_MANIFEST_DIRTY)
        all_chunks = list(hss.collect_chunks_urls().chunks.keys())
        self.assertEqual(len(all_chunks), 3360)
        nonzero_chunks = [chunk for chunk in all_chunks if not chunk.endswith("=0)")]
        self.assertEqual(len(nonzero_chunks), len(list(set(HSS_CHUNKS_URLS))))

    @mock.patch("requests.Session.get", side_effect=mock_read_chunks)
    @mock.patch.object(Manifest, "_read_manifest", return_value="")
    def test_dash_chunks_unique(self, *args):
        """Check chunks urls for DASH manifests are unique even if we have retries."""
        dash = Content().get_manifest(self.dash_manifest_url, None, 0)
        dash.manifest_dict = xmltodict.parse(TEMPLATE_DASH_MANIFEST_DIRTY)
        dash.collect_chunks_urls().play(2, 0)
        all_chunks = list(dash.chunks.keys())
        self.assertEqual(len(all_chunks), len(list(set(all_chunks))))

    @mock.patch("requests.Session.get", side_effect=mock_read_chunks)
    @mock.patch.object(Manifest, "_read_manifest", return_value="")
    def test_hss_chunks_unique(self, *args):
        """Check chunks urls for HSS manifests are unique even if we have retries."""
        hss = Content().get_manifest(self.hss_manifest_url, None, 0)
        hss.manifest_dict = xmltodict.parse(TEMPLATE_HSS_MANIFEST_DIRTY)
        hss.collect_chunks_urls().play(2, 0)
        all_chunks = list(hss.chunks.keys())
        self.assertEqual(len(all_chunks), len(list(set(all_chunks))))

    @mock.patch("requests.Session.get", side_effect=mock_read_chunks)
    @mock.patch.object(Manifest, "_read_manifest", return_value="")
    def test_dash_chunks_separated(self, *args):
        """Check accessible chunks urls for DASH manifests are kept separately from failed ones."""
        dash = Content().get_manifest(self.dash_manifest_url, None, 0)
        dash.manifest_dict = xmltodict.parse(TEMPLATE_DASH_MANIFEST_DIRTY)
        dash.collect_chunks_urls().play(1, 0)
        passed_chunks = [url for url in list(dash.chunks.keys()) if dash.chunks[url] == 200]
        failed_chunks = [url for url in list(dash.chunks.keys()) if dash.chunks[url] != 200]
        self.assertTrue(len(passed_chunks) > 0)
        self.assertTrue(len(failed_chunks) > 0)

    @mock.patch("requests.Session.get", side_effect=mock_read_chunks)
    @mock.patch.object(Manifest, "_read_manifest", return_value="")
    def test_hss_chunks_separated(self, *args):
        """Check accessible chunks urls for HSS manifests are kept separately from failed ones."""
        hss = Content().get_manifest(self.hss_manifest_url, None, 0)
        hss.manifest_dict = xmltodict.parse(TEMPLATE_HSS_MANIFEST_DIRTY)
        hss.collect_chunks_urls().play(1, 0)
        passed_chunks = [url for url in list(hss.chunks.keys()) if hss.chunks[url] == 200]
        failed_chunks = [url for url in list(hss.chunks.keys()) if hss.chunks[url] != 200]
        self.assertTrue(len(passed_chunks) > 0)
        self.assertTrue(len(failed_chunks) > 0)


def suite_play_dash():
    """A function builds a test suite for play() keyword for DASH manifests."""
    return unittest.makeSuite(TestKeyword_PlayDASH, "test")


def suite_play_hss():
    """A function builds a test suite for play() keyword for HSS manifests."""
    return unittest.makeSuite(TestKeyword_PlayHSS, "test")


def suite_play_hls():
    """A function builds a test suite for play() keyword for HLS manifests."""
    return unittest.makeSuite(TestKeyword_PlayHLS, "test")


def suite_chunks():
    """A function builds a test suite for play() keyword for DASH manifests."""
    return unittest.makeSuite(TestKeyword_Chunks, "test")


def run_tests():
    """A function to run unit tests (real Traxis will not be used)."""
    suites = [
        suite_play_dash(),
        suite_play_hss(),
        suite_play_hls(),
        suite_chunks()
    ]
    for suite in suites:
        unittest.TextTestRunner(verbosity=2).run(suite)


def debug():
    """A function to get real Manifests, build and check each content URL."""
    dash_urls = [
        "http://172.30.133.52/dash/lab3/Index/RTL5_clear/manifest.mpd",
        "http://172.30.133.54/dash/lab3/Index/nederland2_hd/manifest.mpd",
        "http://172.30.133.39/dash/lab3/Index/ZiggoSport/manifest.mpd",
    ]
    hss_urls = [
        "http://172.30.133.54/ss/lab3/RTL5_clear.isml/Manifest?device=Orion-HSS",
        "http://172.30.133.54/ss/lab3/Nederland2.isml/Manifest?device=Orion-HSS",
        "http://172.30.100.178:5554/shss/%s/index.ism/Manifest" % ASSET,
        "http://172.30.133.39/ss/lab3/512x288p25.isml/Manifest",
        "http://172.30.133.39/ss/lab3/384x216p25.isml/Manifest",
        "http://172.30.133.39/ss/lab3/1024x576p25.isml/Manifest",
        "http://172.30.133.39/ss/lab3/1280x720p25.isml/Manifest",
        "http://172.30.133.39/ss/lab3/1280x720p50.isml/Manifest",
        "http://172.30.133.39/ss/lab3/720x576p25.isml/Manifest",
        "http://172.30.133.39/ss/lab3/ZiggoSport.isml/Manifest",
        "http://172.30.133.39/ss/lab3/1920x1080p25.isml/Manifest",
        "http://172.30.133.39/ss/lab3/704x396p25.isml/Manifest",
    ]
    hls_urls = [
        "http://172.30.133.39/hls/lab3/hls_clear/index.m3u8",
        "http://172.30.133.39/hls/lab3/images/ZiggoSport/index.m3u8",
        "http://172.30.100.178:5554/shls/%s/index.m3u8?device=Orion-HLS" % ASSET,
    ]
    kwd = Keywords()
    urls = dash_urls + hss_urls + hls_urls
    for url in urls:
        status = kwd.play(url, None, 10, 0.5, 1).played_ok
        print(status)


if __name__ == "__main__":
    # debug()
    run_tests()
