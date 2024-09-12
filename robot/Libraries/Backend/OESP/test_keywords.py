"""Unit tests of ACS library's keywords for Robot Framework.

Tests use mock module and do not send HTTP requests to real servers.
The global function debug() can be used for testing real requests.
"""
import os
import unittest
try:
    import mock
except ImportError:
    import unittest.mock as mock
from .keywords import Keywords


LABS_CONF = {
    "labe2esi": {
        "OESP": {"username": "test0", "password": "password",
                 "country": "NL", "language": "nld", "device": "web"},
    },
    "lab3b": {
        "OESP": {"username": "wipronl01", "password": "wipro1234",
                 "country": "NL", "language": "nld", "device": "web"},
    },
    "Mock": {
        "OESP": {"username": "abc", "password": "def",
                 "country": "NL", "language": "nld", "device": "web"},
    }
}


def mock_requests(*args, **kwargs):
    """A method imitates sending HTTP requests to a server - it analyzes url,
    and returns predefined data (response text, status code and response reason value).

    :return: an instance of the anonymous class representing response data.
    """
    url = args[0]
    headers = kwargs["headers"] if "headers" in kwargs else None
    response_file_name = None
    if headers:
        if "channels" in url:
            response_file_name = "oesp_response_channels.txt"
        elif "search/vod" in url:
            response_file_name = "oesp_response_vod_search.txt"
        elif "session" in url:
            response_file_name = "oesp_response_session.txt"
    if response_file_name:
        folder = os.path.dirname(os.path.abspath(__file__))
        with open(os.path.join(folder, response_file_name), "r+") as _f:
            json_text = _f.read()
        result = dict(text=json_text, status_code=200, reason="OK")
    else:
        result = dict(text="", status_code=404, reason="Not Found")
    return type("", (), result)()


def run_keyword_by_name(name, *args):
    """A function calls Keywords()' method by its name and returns its results, in real."""
    return getattr(Keywords(), name)(*args)


@mock.patch("requests.post", side_effect=mock_requests)
@mock.patch("requests.get", side_effect=mock_requests)
def run_mock_keyword_by_name(name, *args):
    """A function calls Keywords()' method by its name and returns its results; imitation (mock)."""
    return run_keyword_by_name(name, *args[:-2])


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


class TestKeyword_StreamingChannels(TestCaseNameAsDescription):
    """Class contains unit tests of get_channels_streaming_details() keyword."""

    @classmethod
    def setUpClass(cls):
        args = ["Mock", LABS_CONF]
        cls.result = run_mock_keyword_by_name("get_channels_streaming_details", *args)

    @classmethod
    def tearDownClass(cls):
        pass

    def test_verify_result_structure(self):
        """Check the structure of the value returned by the keyword."""
        self.assertTrue(isinstance(self.result, list))
        for item in self.result:
            self.assertTrue(isinstance(item, dict))
            self.assertEqual(len(list(item.keys())), 3)
            self.assertTrue("streaming_url" in item)
            self.assertTrue("protection_key" in item)
            self.assertTrue("protection_schemes" in item)


class TestKeyword_StreamingVOD(TestCaseNameAsDescription):
    """Class contains unit tests of get_vodsearch_streaming_details() keyword."""

    @classmethod
    def setUpClass(cls):
        args = ["Mock", LABS_CONF, "foo"]
        cls.result = run_mock_keyword_by_name("get_vodsearch_streaming_details", *args)

    @classmethod
    def tearDown(cls):
        pass

    def test_verify_result_structure(self):
        """Check the structure of the value returned by the keyword."""
        self.assertTrue(isinstance(self.result, list))
        for item in self.result:
            self.assertTrue(isinstance(item, dict))
            self.assertEqual(len(list(item.keys())), 3)
            self.assertTrue("streaming_url" in item)
            self.assertTrue("protection_key" in item)
            self.assertTrue("protection_schemes" in item)


def suite_channels_streamings():
    """A function builds a test suite for get_channels_streaming_details() keyword."""
    return unittest.makeSuite(TestKeyword_StreamingChannels, "test")


def suite_vodsearch_streamings():
    """A function builds a test suite for get_vodsearch_streaming_details() keyword."""
    return unittest.makeSuite(TestKeyword_StreamingVOD, "test")


def run_tests():
    """A function runs unit tests; HTTP requests will not go to real servers."""
    suites = [
        suite_channels_streamings(),
        suite_vodsearch_streamings(),
    ]
    for suite in suites:
        unittest.TextTestRunner(verbosity=2).run(suite)


def debug(num, lab="labe2esi"):
    """A function to send real HTTP requests to real OESP,
    or mock ACS requests will be send if lab value is set to "Mock".

    :param num: an integer number of action to be performed (available: 1-2).
    :param lab: a lab name ("lab3b", "Mock" are available names).

    :return: the return value of selected keyword.
    """
    kwds = {
        "get_channels_streaming_details": [lab, LABS_CONF],
        "get_vodsearch_streaming_details": [lab, LABS_CONF, "the"],
        "get_recs_streaming_details": [lab, LABS_CONF],
    }
    if not (isinstance(num, int) and num in list(range(1, 1+len(list(kwds.keys()))))):
        num = 1
    kwd = list(sorted(kwds.keys()))[num-1]
    print(("\nRunning keyword '%s'..." % kwd))
    print(("Keyword '%s' completed and returned:\n%s" % (kwd, run_keyword_by_name(kwd, *kwds[kwd]))))


if __name__ == "__main__":
    #for i in list(range(1, 4)):
    #    try:
    #        debug(i)
    #    except KeyError as err:
    #        print("KeyError: %s" % err)
    #    print("*" * 100)
    run_tests()
