# pylint: disable=protected-access,unused-argument
# Disabled pylint "protected-access" because Robot Framework's listeners
# are implemented as protected methods, and we need to test them directly.
# Disabled pylint "unused-argument" since it's required,
# but internal in mocked functions.
"""Unit tests of ElasticSearch library's components.
Tests use mock module and do not send HTTP requests to real servers.
"""
import datetime
import json
import unittest
try:
    import mock
except ImportError:
    import unittest.mock as mock
import tools
from robotlistener import RobotListener


RF_TIME_PATTERN = "%Y%m%d %H:%M:%S.%f"

ELK_SUITE_RESPONSE_TEMPLATE = """{
  "_index":"debug-testrobot-2017.08.03",
  "_type":"testsuite",
  "_id":"AV2pyFH4BdMq9LJk4djo",
  "_version":1,
  "result":"created",
  "_shards":{"total":2,"successful":1,"failed":0},
  "created":true
}"""

ELK_TEST_RESPONSE_TEMPLATE = """{
  "_index":"debug-testrobot-2017.08.03",
  "_type":"testcase",
  "_id":"AV2pyFHYBdMq9LJk4djn",
  "_version":1,"result":"created",
  "_shards":{"total":2,"successful":1,"failed":0},
  "created":true
}"""

TIME_ZONE_OFFSET_MS = (
    datetime.datetime.utcnow().hour - datetime.datetime.now().hour
) * 3600 * 1000

SUITE_NAME = "OTT.LIVE"
SUITE_LONG_NAME = "Robot.Ott.Live"
SUITE_TAGS = ["SOME_OTHER_TAG", "ANOTHER_TAG"]
SUITE_TIME_START_STR = "20170804 09:38:05.881"
SUITE_TIME_END_STR = "20170804 09:38:07.729"
SUITE_TIME_START_MS = 1501839485881 + TIME_ZONE_OFFSET_MS
SUITE_TIME_END_MS = 1501839487729 + TIME_ZONE_OFFSET_MS

FEATURE = "LIVE"
TOOL = "OTT"
RESULT = "FAIL"
TEST_FAIL_REASON = """There were errors while playing \
http://172.30.133.52/dash/lab3/Index/RTL5_clear/manifest.mpd"""

CPE_ID = "3C36E4-EOSSTB-003356472104"
CPE_VERSION = "None"

TEST_RUN_ID = "20170804093806-968ed964-d36e-cd0d-ab87"
TEST_NAME = "HES111_LIVE_Streaming_DASH_Android_OTT_device_Widevine"
TEST_TAGS = ["FEATURE_LIVE", "TOOL_OTT", "JIRA_HES-121", "SOME_OTHER_TAG", "ANOTHER_TAG"]
TEST_TIME_START_STR = "20170804 09:38:06.114"
TEST_TIME_END_STR = "20170804 09:38:07.698"
TEST_TIME_START_MS = 1501839486114 + TIME_ZONE_OFFSET_MS
TEST_TIME_END_MS = 1501839487698 + TIME_ZONE_OFFSET_MS
TEST_KIBANA_URL_Z_TIME_FROM = "2017-08-03T09:38:06.000Z"
TEST_KIBANA_URL_Z_TIME_TO = "2017-08-05T09:38:07.000Z"

SUITE_KIBANA_URL = """Debug_TestSuite_Results_Dashboard?\
_g=(refreshInterval:(display:Off,pause:!f,value:0),\
time:(from:'2017-08-03T09:38:05.881Z',mode:absolute,to:'2017-08-05T09:38:07.729Z'))\
&_a=(query:(query_string:(analyze_wildcard:!t,\
query:'testRun:%s')))""" % TEST_RUN_ID

TEST_KIBANA_URL = """NO_MORE_INFO\
?_g=(refreshInterval:(display:Off,pause:!f,value:0),\
time:(from:'2017-08-03T09:38:06.000Z',mode:absolute,to:'2017-08-05T09:38:07.000Z'))\
&_a=(query:(query_string:(analyze_wildcard:!t,\
query:'')))"""

ROBOT_START_SUITE = {
    "suites": [],
    "tests": ["HES111_LIVE_Streaming_DASH_Android_OTT_device_Widevine"],
    "doc": "",
    "source": "C:\\_WORK_\\git\\e2e_si_automation\\robot\\ott\\live.txt",
    "totaltests": 1,
    "starttime": "20170804 09:38:05.881",
    "longname": "Robot.Ott.Live",
    "id": "s1-s1-s1",
    "metadata": {}
}

ROBOT_END_SUITE = {
    "status": "FAIL",
    "suites": [],
    "tests": ["HES111_LIVE_Streaming_DASH_Android_OTT_device_Widevine"],
    "statistics": "1 critical test, 0 passed, 1 failed\n1 test total, 0 passed, 1 failed",
    "doc": "",
    "elapsedtime": 1839,
    "source": "C:\\_WORK_\\git\\e2e_si_automation\\robot\\ott\\live.txt",
    "totaltests": 1,
    "starttime": "20170804 09:38:05.881",
    "longname": "Robot.Ott.Live",
    "message": "",
    "endtime": "20170804 09:38:07.729",
    "id": "s1-s1-s1",
    "metadata": {}
}

ROBOT_START_TEST = {
    "critical": "yes",
    "template": "",
    "starttime": "20170804 09:38:06.114",
    "tags": TEST_TAGS,
    "doc": "",
    "longname": "Robot.Ott.Live.HES111_LIVE_Streaming_DASH_Android_OTT_device_Widevine",
    "id": "s1-s1-s1-t1"
}

ROBOT_END_TEST = {
    "status": "FAIL",
    "template": "",
    "tags": TEST_TAGS,
    "doc": "",
    "elapsedtime": 1562,
    "critical": "yes",
    "starttime": "20170804 09:38:06.114",
    "longname": "Robot.Ott.Live.HES111_LIVE_Streaming_DASH_Android_OTT_device_Widevine",
    "message": "There were errors while playing " + \
               "http://172.30.133.52/dash/lab3/Index/RTL5_clear/manifest.mpd",
    "endtime": "20170804 09:38:07.698",
    "id": "s1-s1-s1-t1"}

CONF = {
    "LAB 5A Upcless": {
        "CPE_ID": CPE_ID,
        "ELK_HOST": "10.64.13.179",
        "ELK_PORT": "9200",
        "ELK_INDEX_ROBOT": "debug-testrobot",
        "ELK_TYPE_TEST_CASE": "testcase",
        "ELK_TYPE_TEST_STEP": "teststep",
        "LAB_NAME": "LAB 5A Upcless",
        "KIBANA_HOST": "10.64.13.179",
        "KIBANA_PORT": "5601",
        "KIBANA_TEST_STEP_DASHBOARD": "Debug_TestSuite_Results_Dashboard",
        "KIBANA_TEST_STEP_NO_INFO_DASHBOARD": "NO_MORE_INFO",
        "KIBANA_DASHBOARD_TIME": 86400000,
    },
    "MOCK": {
        "CPE_ID": CPE_ID,
        "ELK_HOST": "127.0.0.1",
        "ELK_PORT": "9200",
        "ELK_INDEX_ROBOT": "debug-testrobot",
        "ELK_TYPE_TEST_CASE": "testcase",
        "ELK_TYPE_TEST_STEP": "teststep",
        "LAB_NAME": "MOCK",
        "KIBANA_HOST": "127.0.0.1",
        "KIBANA_PORT": "5601",
        "KIBANA_TEST_STEP_DASHBOARD": "Debug_TestSuite_Results_Dashboard",
        "KIBANA_TEST_STEP_NO_INFO_DASHBOARD": "NO_MORE_INFO",
        "KIBANA_DASHBOARD_TIME": 86400000,
    }
}


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


def mock_requests_post(*args, **kwargs):
    """A method imitates sending GET requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    url = args[0]
    headers = kwargs["headers"] if "headers" in kwargs else None
    data = dict(text="", status_code=404, reason="Not Found")
    if url.startswith("http://127.0.0.1:9200/debug-testrobot-") and headers:
        if url.endswith("testcase"):
            text = ELK_SUITE_RESPONSE_TEMPLATE
            data = dict(text=text, status_code=200, reason="OK")
        elif url.endswith("teststep"):
            text = ELK_TEST_RESPONSE_TEMPLATE
            data = dict(text=text, status_code=200, reason="OK")
    return type("", (), data)()


def mock_robot_get_conf(*args):
    """Function returns predefined CONF as keyword "Get Variables" would do."""
    return CONF["MOCK"]


def mock_robot_get_var_value(*args):
    """Function returns predefined value as keyword "Get Variable Value" would do."""
    result = None
    var_name = args[0]
    if var_name == "resultLink":
        result = TEST_KIBANA_URL
    elif var_name == "CPE_ID":
        result = CPE_ID
    elif var_name == "CPE_VERSION":
        result = None
    elif var_name == "failedReason":
        result = TEST_FAIL_REASON
    elif var_name == "TEST_TAGS":
        result = TEST_TAGS
    return result


def mock_generate_id(*args):
    """Function returns predefined test run id."""
    return TEST_RUN_ID


@mock.patch("requests.post", side_effect=mock_requests_post)
@mock.patch.object(tools, "generate_id", side_effect=mock_generate_id)
@mock.patch.object(tools, "get_conf", side_effect=mock_robot_get_conf)
@mock.patch.object(tools, "get_lab_name", return_value="labe2esi")
@mock.patch.object(tools, "get_var_value", side_effect=mock_robot_get_var_value)
@mock.patch.object(tools, "set_suite_var", side_effect=lambda x, y: None)
def run_all_listeners(*args):
    """Function executes all Robot Framework listeners once, in the right order."""
    rl_obj = RobotListener()
    rl_obj._start_suite("Live", ROBOT_START_SUITE)
    rl_obj.suite.test_run_id = TEST_RUN_ID
    rl_obj._start_test(TEST_NAME, ROBOT_START_TEST)
    rl_obj._end_test(TEST_NAME, ROBOT_END_TEST)
    rl_obj._end_suite("Live", ROBOT_END_SUITE)
    return rl_obj


class TestSender_SendSuiteResults(TestCaseNameAsDescription):
    """Class contains unit tests of check_now() keyword."""

    @classmethod
    def setUpClass(cls):
        cls.rl_obj = run_all_listeners()
        cls.suite_json = json.loads(cls.rl_obj.suite.json_str)

    @classmethod
    def tearDownClass(cls):
        pass

    def test_send_sute_results_ok(self):
        """Check status of sending test suite results."""
        self.assertTrue(self.rl_obj.sent["suite"])

    def test_check_suite_json_data(self):
        """Check status of sending suite results."""
        self.assertTrue(isinstance(self.suite_json, dict))

    def test_check_suite_json_ts_name(self):
        """Check Test Suite name is correct in suite json data."""
        self.assertEqual(self.suite_json["testCase"], SUITE_NAME)

    def test_check_suite_json_feature(self):
        """Check Feature is correct in suite json data."""
        self.assertEqual(self.suite_json["feature"], FEATURE)

    def test_check_suite_json_run_id(self):
        """Check TestRunId is correct in suite json data."""
        self.assertTrue(self.suite_json["testRun"].startswith(TEST_RUN_ID))

    def test_check_suite_json_tags(self):
        """Check Suite tag is correct in suite json data."""
        self.assertEqual(self.suite_json["tags"], "ANOTHER_TAG-SOME_OTHER_TAG")

    def test_check_suite_json_result(self):
        """Check Suite status is correct in suite json data."""
        self.assertEqual(self.suite_json["result"], RESULT)

    def test_check_suite_json_reason(self):
        """Check suite failed reason is correct in suite json data."""
        self.assertTrue(self.suite_json["failedReason"] in [TEST_NAME])

    def test_check_suite_json_cpe_id(self):
        """Check CPE id is correct in suite json data."""
        self.assertEqual(self.suite_json["cpe"], CPE_ID)

    def test_check_suite_json_cpe_v(self):
        """Check CPE version is correct in suite json data."""
        self.assertEqual(self.suite_json["cpeVersion"], CPE_VERSION)

    def test_check_suite_json_start(self):
        """Check Suite start time is correct in suite json data."""
        self.assertEqual(self.suite_json["Timing"]["startTime"].encode("utf-8"),
                         str(SUITE_TIME_START_MS).encode("utf-8"))

    def test_check_suite_json_end(self):
        """Check Suite end time is correct in suite json data."""
        self.assertEqual(self.suite_json["Timing"]["endTime"].encode("utf-8"),
                         str(SUITE_TIME_END_MS).encode("utf-8"))

    def test_check_suite_json_duration(self):
        """Check Suite duration is correct in suite json data."""
        duration = SUITE_TIME_END_MS - SUITE_TIME_START_MS
        self.assertEqual(self.suite_json["Timing"]["duration"], str(duration))

    def test_check_suite_json_link(self):
        """Check Suite result link (URL to Kibana) is correct in json data."""
        self.assertEqual(self.suite_json["resultLink"], SUITE_KIBANA_URL)

    def test_check_suite_kibana_board(self):
        """Check correct Kibana Dashboard is in Suite Kibana URL."""
        kibana_board = "Debug_TestSuite_Results_Dashboard"
        part = "%s" % kibana_board
        self.assertTrue(self.rl_obj.suite.kibana_url.startswith(part))


class TestSender_SendTestResults(TestSender_SendSuiteResults):
    """Class contains unit tests of check_now() keyword."""

    @classmethod
    def setUpClass(cls):
        super(TestSender_SendTestResults).__init__(cls)
        cls.test_json = json.loads(cls.rl_obj.test.json_str)

    @classmethod
    def tearDownClass(cls):
        pass

    def test_send_test_results_ok(self):
        """Check status of sending test case results."""
        self.assertTrue(self.rl_obj.sent["test"])

    def test_check_test_json_data(self):
        """TODO: Check status of sending suite results."""
        self.assertTrue(isinstance(self.test_json, dict))

    def test_check_test_json_ts_name(self):
        """Check Test Suite name is correct in test json data."""
        self.assertEqual(self.test_json["testCase"], SUITE_NAME)

    def test_check_test_json_tc_name(self):
        """Check Test Case name is correct in test json data."""
        self.assertEqual(self.test_json["testStep"], TEST_NAME)

    def test_check_test_json_feature(self):
        """Check Feature is correct in test json data."""
        self.assertEqual(self.test_json["feature"], FEATURE)

    def test_check_test_json_tool(self):
        """Check Tool is correct in json data."""
        self.assertEqual(self.test_json["tool"], TOOL)

    def test_check_test_json_run_id(self):
        """Check TestRunId is correct in test json data."""
        self.assertTrue(self.test_json["testRun"].startswith(TEST_RUN_ID))

    def test_check_test_json_tags(self):
        """Check Test tag is correct in test json data. The rule is:
        all tags prefixed with "TOOL_", "FEATURE_" and "JIRA_" are removed from the tags list;
        remaining tags are concatenated using "-" sparator;
        if a tag has a space in its name, it will be replaced with "_".
        """
        self.assertEqual(self.test_json["tags"], "ANOTHER_TAG-SOME_OTHER_TAG")

    def test_check_test_json_result(self):
        """Check Test status is correct in test json data."""
        self.assertEqual(self.test_json["result"], RESULT)

    def test_check_test_json_reason(self):
        """Check test failed reason is correct in test json data."""
        self.assertEqual(self.test_json["failedReason"], TEST_FAIL_REASON)

    def test_check_test_json_cpe_id(self):
        """Check CPE id is correct in test json data."""
        self.assertEqual(self.suite_json["cpe"], CPE_ID)

    def test_check_test_json_cpe_v(self):
        """Check CPE version is correct in test json data."""
        self.assertEqual(self.suite_json["cpeVersion"], CPE_VERSION)

    def test_check_test_json_start(self):
        """Check Test start time is correct in test json data."""
        self.assertEqual(self.test_json["Timing"]["startTime"].encode("utf-8"),
                         str(TEST_TIME_START_MS).encode("utf-8"))

    def test_check_test_json_end(self):
        """Check Test end time is correct in test json data."""
        self.assertEqual(self.test_json["Timing"]["endTime"].encode("utf-8"),
                         str(TEST_TIME_END_MS).encode("utf-8"))

    def test_check_test_json_duration(self):
        """Check Test duration is correct in test json data."""
        duration = TEST_TIME_END_MS - TEST_TIME_START_MS
        self.assertEqual(self.test_json["Timing"]["duration"], str(duration))

    def test_check_test_json_link(self):
        """Check Suite result link (URL to Kibana) is correct in json data."""
        self.assertEqual(self.test_json["resultLink"], TEST_KIBANA_URL)

    def test_check_test_kibana_board(self):
        """Check correct Kibana Dashboard is in Suite Kibana URL."""
        kibana_board = "NO_MORE_INFO"
        part = "%s" % kibana_board
        self.assertTrue(self.test_json["resultLink"].startswith(part))
        self.assertTrue(not self.rl_obj.test.kibana_url)


def suite_send_ts_to_elk():
    """A function builds a test suite for check_cpe_status() keyword."""
    return unittest.makeSuite(TestSender_SendSuiteResults, "test")


def suite_send_tc_to_elk():
    """A function builds a test suite for check_cpe_status() keyword."""
    return unittest.makeSuite(TestSender_SendTestResults, "test")


def run_tests():
    """A function runs unit tests; HTTP requests will not go to real servers."""
    suites = [
        suite_send_ts_to_elk(),
        suite_send_tc_to_elk(),
    ]
    for suite in suites:
        unittest.TextTestRunner(verbosity=2).run(suite)


if __name__ == "__main__":
    run_tests()
