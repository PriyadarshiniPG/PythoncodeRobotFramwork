# pylint: disable=protected-access,unused-argument
# pylint: disable=wrong-import-position
# pylint: disable=too-many-public-methods
# Disabled pylint "protected-access" because Robot Framework's listeners
# are implemented as protected methods, and we need to test them directly.
# Disabled pylint "unused-argument" since it's required,
# but internal in mocked functions.
"""Unit tests of ElasticSearch library's components.
Tests use mock module and do not send HTTP requests to real servers.
"""
import os
import sys
import inspect
import re
import datetime
import json
import unittest
try:
    import mock
except ImportError:
    import unittest.mock as mock
from robot.libraries.BuiltIn import BuiltIn  # pylint: disable=unused-import
currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
parentdir = os.path.dirname(currentdir)
sys.path.append(parentdir)
import tools  # pylint: disable=import-error
from .robotlistener import RobotListener

os.environ["ACTUAL_CPE_BUILD"] = "DCX960__-mon-rel-00.02-079-fe-AL-20190924210000-un000"
os.environ["OBELIX"] = "True"
os.environ["CAPTURE_SCREENSHOT"] = "True"
os.environ["CPE_ID"] = "3C36E4-EOSSTB-003471715205"
os.environ["STB_IP"] = "10.20.30.40"
os.environ["TEST STATUS"] = "None"
USER_ID = "user id 123"
RF_TIME_PATTERN = "%Y%m%d %H:%M:%S.%f"
BUILD_NUMBER = "build 321"
ELK_SUITE_RESPONSE_TEMPLATE = """{
  "_index":"debug-testrobot-2017.08.03",
  "_type":"testsuite",
  "_id":"AV2pyFH4BdMq9LJk4djo",
  "_version":1,
  "result":"created",
  "_shards":{"total":2,"successful":1,"failed":0},
  "created":true
}"""
GIT_COMMIT = "mn56ukjhgr56ujhtr4"
ELK_TEST_RESPONSE_TEMPLATE = """{
  "_index":"debug-testrobot-2017.08.03",
  "_type":"testcase",
  "_id":"AV2pyFHYBdMq9LJk4djn",
  "_version":1,"result":"created",
  "_shards":{"total":2,"successful":1,"failed":0},
  "created":true
}"""
GIT_BRANCH = "dummy-branch-name"
TIME_ZONE_OFFSET_MS = (
    datetime.datetime.utcnow().hour - datetime.datetime.now().hour
) * 3600 * 1000
BUILD_URL = "http://dummy.com:8080/build/12/"
SUITE_NAME = "OTT.LIVE"
SUITE_LONG_NAME = "Robot.Ott.Live"
SUITE_TIME_START_STR = "20170804 09:38:05.881"
SUITE_TIME_END_STR = "20170804 09:38:07.729"
SUITE_TIME_START_MS = 1501839485881 + TIME_ZONE_OFFSET_MS
SUITE_TIME_END_MS = 1501839487729 + TIME_ZONE_OFFSET_MS
JOB_ID = "job id"
FEATURE = "LIVE"
TOOL = "OTT"
RESULT = "FAIL"
TEST_FAIL_REASON = """There were errors while playing \
http://172.30.133.52/dash/lab3/Index/RTL5_clear/manifest.mpd"""
PIPELINE_ID = "PIPELINE_SANITY_183"
CPE_ID = "3C36E4-EOSSTB-003356472104"
CPE_VERSION = "None"
DESCRIPTION = "Dummy test description"
LAB_NAME = "mock"
LOCATION = "some location"
AVG_RESPONSE_TIME = "10.7903"
MAX_RESPONSE_TIME = "18.801"
TEST_RUN_ID = "20170804093806-968ed964-d36e-cd0d-ab87"
TEST_NAME = "HES111_LIVE_Streaming_DASH_Android_OTT_device_Widevine"
TEST_TAGS = ["FEATURE_LIVE", "TOOL_OTT", "JIRA_HES-121", "SOME_OTHER_TAG", "ANOTHER_TAG",
             "TRACK_MOCK_FOR_TRACK"]
EXPECTED_TAGS = []
for tag in TEST_TAGS:
    tag_itself = True
    for mask_to_ignore in ["JIRA", "FEATURE", "TOOL", "TRACK"]:
        if mask_to_ignore in tag:
            tag_itself = False
    if tag_itself:
        EXPECTED_TAGS.append(tag)
EXPECTED_JIRA = ""
for tag in TEST_TAGS:
    if "JIRA_" in tag:
        EXPECTED_JIRA = tag.replace("JIRA_", "")
EXPECTED_FEATURE = ""
for tag in TEST_TAGS:
    if "FEATURE_" in tag:
        EXPECTED_FEATURE = tag.replace("FEATURE_", "")
EXPECTED_TOOL = ""
for tag in TEST_TAGS:
    if "TOOL_" in tag:
        EXPECTED_TOOL = tag.replace("TOOL_", "")
EXPECTED_TRACK = ""
for tag in TEST_TAGS:
    if "TRACK_" in tag:
        EXPECTED_TRACK = tag.replace("TRACK_", "")
TEST_TIME_START_STR = "20170804 09:38:06.114"
TEST_TIME_END_STR = "20170804 09:38:07.698"
TEST_TIME_START_MS = 1501839486114 + TIME_ZONE_OFFSET_MS
TEST_TIME_END_MS = 1501839487698 + TIME_ZONE_OFFSET_MS
TEST_KIBANA_URL_Z_TIME_FROM = "2017-08-03T09:38:06.000Z"
TEST_KIBANA_URL_Z_TIME_TO = "2017-08-05T09:38:07.000Z"
URL_SCREENSHOT = "http://dummy.com:8080/screenshots/789/"
SUITE_KIBANA_URL = """Debug_TestSuite_Results_Dashboard?\
_g=(refreshInterval:(display:Off,pause:!f,value:0),\
time:(from:'2017-08-03T09:38:05.881Z',mode:absolute,to:'2017-08-05T09:38:07.729Z'))\
&_a=(query:(query_string:(analyze_wildcard:!t,\
query:'testRun:%s')))""" % TEST_RUN_ID
URL_PATH = "http://dummy.com:8080/path/789/"
TEST_KIBANA_URL = """NO_MORE_INFO\
?_g=(refreshInterval:(display:Off,pause:!f,value:0),\
time:(from:'2017-08-03T09:38:06.000Z',mode:absolute,to:'2017-08-05T09:38:07.000Z'))\
&_a=(query:(query_string:(analyze_wildcard:!t,\
query:'')))"""
robotError = "any robot error"
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
RACK_SLOT_ID = "97654"
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
PABOT = False
STB_POOL = "STB-1,STB-2"
TEST_DURATION = TEST_TIME_END_MS - TEST_TIME_START_MS
SUITE_DURATION = SUITE_TIME_END_MS - SUITE_TIME_START_MS
ROBOT_START_TEST = {
    "critical": "yes",
    "template": "",
    "starttime": "20170804 09:38:06.114",
    "tags": TEST_TAGS,
    "doc": "",
    "longname": "Robot.Ott.Live.HES111_LIVE_Streaming_DASH_Android_OTT_device_Widevine",
    "id": "s1-s1-s1-t1"
}
JOB_NAME = "job-name"
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
    elif var_name == "DESCRIPTION":
        result = DESCRIPTION
    elif var_name == "LAB_NAME":
        result = LAB_NAME
    elif var_name == "avg_latency":
        result = AVG_RESPONSE_TIME
    elif var_name == "max_latency":
        result = MAX_RESPONSE_TIME
    elif var_name == "LOCATION":
        result = LOCATION
    elif var_name == "PIPELINE_ID":
        result = PIPELINE_ID
    elif var_name == "JOB_ID":
        result = JOB_ID
    elif var_name == "JOB_NAME":
        result = JOB_NAME
    elif var_name == "USER_ID":
        result = USER_ID
    elif var_name == "BUILD_NUMBER":
        result = BUILD_NUMBER
    elif var_name == "GIT_COMMIT":
        result = GIT_COMMIT
    elif var_name == "GIT_BRANCH":
        result = GIT_BRANCH
    elif var_name == "BUILD_URL":
        result = BUILD_URL
    elif var_name == "URL_SCREENSHOT":
        result = URL_SCREENSHOT
    elif var_name == "URL_PATH":
        result = URL_PATH
    elif var_name == "robotError":
        result = robotError
    elif var_name == "RACK_SLOT_ID":
        result = RACK_SLOT_ID
    elif var_name == "PABOT":
        result = PABOT
    elif var_name == "STB_POOL":
        result = STB_POOL
    return result


def mock_generate_id(*args):
    """Function returns predefined test run id."""
    return TEST_RUN_ID


@mock.patch("requests.post", side_effect=mock_requests_post)
@mock.patch.object(tools, "generate_id", side_effect=mock_generate_id)
@mock.patch.object(tools, "get_conf", side_effect=mock_robot_get_conf)
@mock.patch.object(tools, "get_var_value", side_effect=mock_robot_get_var_value)
@mock.patch.object(tools, "set_suite_var", side_effect=lambda x, y: None)
def run_all_listeners(*args):
    """Function executes all Robot Framework listeners once, in the right order."""
    rl_obj = RobotListener()
    rl_obj._start_suite("Live", ROBOT_START_SUITE)
    rl_obj.data.suite.test_run_id = TEST_RUN_ID
    rl_obj._start_test(TEST_NAME, ROBOT_START_TEST)
    rl_obj._end_test(TEST_NAME, ROBOT_END_TEST)
    rl_obj._end_suite("Live", ROBOT_END_SUITE)
    return rl_obj


class TestSender_SendSuiteResults(TestCaseNameAsDescription):
    """Class contains unit tests of check_now() keyword."""

    @classmethod
    def setUpClass(cls):
        cls.rl_obj = run_all_listeners()
        cls.suite_json = json.loads(cls.rl_obj.data.suite.json_str)

    @classmethod
    def tearDownClass(cls):
        pass

    def test_send_sute_results_ok(self):
        """Check status of sending test suite results."""
        self.assertTrue(self.rl_obj.sender_status["suite"])

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
        self.assertEqual(self.suite_json["tags"], "-".join(sorted(EXPECTED_TAGS)))

    def test_check_suite_json_result(self):
        """Check Suite status is correct in suite json data."""
        self.assertEqual(self.suite_json["result"], RESULT)

    def test_check_suite_json_reason(self):
        """Check suite failed reason is correct in suite json data."""
        self.assertTrue(self.suite_json["failedReason"] in [TEST_NAME + " - " + TEST_FAIL_REASON])

    def test_check_suite_json_cpe_id(self):
        """Check CPE id is correct in suite json data."""
        self.assertEqual(self.suite_json["cpe"], CPE_ID)

    def test_check_suite_json_track(self):
        """Check track is correct in suite json data."""
        self.assertEqual(self.suite_json["track"], "MOCK_FOR_TRACK")

    def test_check_suite_json_cpe_version(self):
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
        result_link = str(self.suite_json["resultLink"])
        pattern = "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{1,3}Z"  # pylint: disable=anomalous-backslash-in-string
        expected_dates = re.findall(pattern, SUITE_KIBANA_URL)
        actual_dates = re.findall(pattern, result_link)
        for date in expected_dates:
            self.assertTrue(re.match(pattern, date), msg="Wrong expected_dates")
        for date in actual_dates:
            self.assertTrue(re.match(pattern, date), msg="Wrong actual_dates")
        expected_link_parts = \
            self._split_result_url(SUITE_KIBANA_URL, expected_dates)
        actual_link_parts = \
            self._split_result_url(result_link, actual_dates)
        self.assertEqual(expected_link_parts, actual_link_parts)

    @staticmethod
    def _split_result_url(link, dates):
        from_date = dates[0]
        to_date = dates[1]
        link_first_part = link.split(from_date)[0]
        link_middle_part = link.split(from_date)[1].split(to_date)[0]
        link_last_part = link.split(to_date)[1]
        return link_first_part, link_middle_part, link_last_part

    def test_check_suite_kibana_board(self):
        """Check correct Kibana Dashboard is in Suite Kibana URL."""
        kibana_board = "Debug_TestSuite_Results_Dashboard"
        part = "%s" % kibana_board
        self.assertTrue(self.rl_obj.test_suite_data_to_send.kibana_url.startswith(part))

    def test_check_suite_json_type(self):
        """Check type is correct in suite json data."""
        self.assertEqual(self.suite_json["type"], "testcase")

    def test_check_suite_json_testStep(self):
        """Check testStep is correct in suite json data."""
        self.assertEqual(self.suite_json["testStep"], "")

    def test_check_suite_json_description(self):
        """Check description is correct in suite json data."""
        self.assertEqual(self.suite_json["description"], DESCRIPTION)

    def test_check_suite_json_lab(self):
        """Check lab is correct in suite json data."""
        self.assertEqual(self.suite_json["lab"], "lab" + LAB_NAME)

    def test_check_suite_json_tool(self):
        """Check lab is correct in suite json data."""
        self.assertEqual(self.suite_json["tool"], TOOL)

    def test_check_suite_json_avgResponseTime(self):
        """Check avgResponseTime is correct in suite json data."""
        self.assertEqual(self.suite_json["Timing"]["avgResponseTime"], float(AVG_RESPONSE_TIME))

    def test_check_suite_json_maxResponseTime(self):
        """Check maxResponseTime is correct in suite json data."""
        self.assertEqual(self.suite_json["Timing"]["maxResponseTime"], float(MAX_RESPONSE_TIME))

    def test_check_suite_json_location(self):
        """Check location is correct in suite json data."""
        self.assertEqual(self.suite_json["location"], LOCATION)

    def test_check_suite_json_id_pipeline(self):
        """Check id_pipeline is correct in suite json data."""
        self.assertEqual(self.suite_json["id"]["pipeline"], PIPELINE_ID)

    def test_check_suite_json_id_suite(self):
        """Check id_suite is correct in suite json data."""
        pattern = "(\d{14}-){2}[abcdef0-9]{8}(-[abcdef0-9]{4}){3}"    # pylint: disable=anomalous-backslash-in-string
        self.assertTrue(
            re.match(pattern, self.suite_json["id"]["suite"])
        )

    def test_check_suite_json_id_user(self):
        """Check id_user is correct in suite json data."""
        self.assertEqual(self.suite_json["id"]["user"], USER_ID)

    def test_check_suite_json_id_testrun(self):
        """Check id_suite is correct in suite json data."""
        pattern = "(\d{14}-){2}[abcdef0-9]{8}(-[abcdef0-9]{4}){3}"    # pylint: disable=anomalous-backslash-in-string
        self.assertTrue(
            re.match(pattern, self.suite_json["id"]["testRun"])
        )

    def test_check_suite_json_id_build(self):
        """Check id_build is correct in suite json data."""
        self.assertEqual(self.suite_json["id"]["build"], BUILD_NUMBER)

    def test_check_suite_json_id_commit(self):
        """Check id_commit is correct in suite json data."""
        self.assertEqual(self.suite_json["id"]["commit"], GIT_COMMIT)

    def test_check_suite_json_id_branch(self):
        """Check id_branch is correct in suite json data."""
        self.assertEqual(self.suite_json["id"]["branch"], GIT_BRANCH)

    def test_check_suite_json_url_output(self):
        """Check url_output is correct in suite json data."""
        self.assertEqual(self.suite_json["url"]["output"], BUILD_URL + "robot/report/output.xml")

    def test_check_suite_json_url_log(self):
        """Check url_log is correct in suite json data."""
        self.assertEqual(self.suite_json["url"]["log"], BUILD_URL + "robot/report/log.html")

    def test_check_suite_json_url_report(self):
        """Check url_report is correct in suite json data."""
        self.assertEqual(self.suite_json["url"]["report"], BUILD_URL + "robot/report/report.html")

    def test_check_suite_json_url_screenshot(self):
        """Check url_screenshot is correct in suite json data."""
        self.assertEqual(self.suite_json["url"]["screenshot"], URL_SCREENSHOT)

    def test_check_suite_json_url_path(self):
        """Check url_screenshot is correct in suite json data."""
        self.assertEqual(self.suite_json["url"]["path"], URL_PATH)

    def test_check_suite_json_failedReasonRobot(self):
        """Check failedReasonRobot is correct in suite json data."""
        self.assertEqual(self.suite_json["failedReasonRobot"], robotError)

    def test_check_suite_json_url_full_log(self):
        """Check full_log is correct in suite json data."""
        self.assertEqual(self.suite_json["url"]["full_log"], "")

    def test_check_suite_json_url_quickreport(self):
        """Check quickreport is correct in suite json data."""
        self.assertEqual(
            self.suite_json["url"]["quickreport"],
            BUILD_URL + 'artifact/e2e_si_automation/robot/execution_artifacts/quickreport.html')

    def test_check_suite_json_jiraData_status(self):
        """Check status is correct in suite json data."""
        self.assertEqual(self.suite_json["jiraData"]["status"], "")

    def test_check_suite_json_jiraData_priority(self):
        """Check priority is correct in suite json data."""
        self.assertEqual(self.suite_json["jiraData"]["priority"], "")

    def test_check_suite_json_jiraData_linkedList(self):
        """Check linkedList is correct in suite json data."""
        self.assertEqual(self.suite_json["jiraData"]["linkedList"], ["None"])

    def test_check_suite_json_jiraData_linked(self):
        """Check linked is correct in suite json data."""
        self.assertEqual(self.suite_json["jiraData"]["linked"], [])

    def test_check_data_suite_result_json_file_labName(self):
        """Check labName is correct in self.data.suite.result_json_file ."""
        self.assertEqual(self.rl_obj.data.suite.result_json_file["labName"], "lab" + LAB_NAME)

    def test_check_data_suite_result_json_file_localRun(self):
        """Check localRun is correct in self.data.suite.result_json_file ."""
        self.assertRaises(KeyError, lambda: self.rl_obj.data.suite.result_json_file["localRun"])

    def test_check_data_suite_result_json_file_elastic(self):
        """Check elastic is correct in self.data.suite.result_json_file ."""
        self.assertFalse(self.rl_obj.data.suite.result_json_file["elastic"])

    def test_check_data_suite_result_json_file_id_pipeline(self):
        """Check id_pipeline is correct in self.data.suite.result_json_file ."""
        self.assertEqual(self.rl_obj.data.suite.result_json_file["id"]["pipeline"], PIPELINE_ID)

    def test_check_data_suite_result_json_file_id_suite(self):
        """Check id_suite is correct in self.data.suite.result_json_file ."""
        pattern = "(\d{14}-){2}[abcdef0-9]{8}(-[abcdef0-9]{4}){3}"    # pylint: disable=anomalous-backslash-in-string
        self.assertTrue(
            re.match(pattern, self.rl_obj.data.suite.result_json_file["id"]["suite"])
        )

    def test_check_data_suite_result_json_file_id_build(self):
        """Check id_build is correct in self.data.suite.result_json_file ."""
        self.assertEqual(self.rl_obj.data.suite.result_json_file["id"]["build"], BUILD_NUMBER)

    def test_check_data_suite_result_json_file_id_commit(self):
        """Check id_commit is correct in self.data.suite.result_json_file ."""
        self.assertEqual(self.rl_obj.data.suite.result_json_file["id"]["commit"], GIT_COMMIT)

    def test_check_data_suite_result_json_file_url_log(self):
        """Check url_log is correct in self.data.suite.result_json_file ."""
        self.assertEqual(
            self.rl_obj.data.suite.result_json_file["url"]["log"],
            BUILD_URL + "robot/report/log.html")

    def test_check_data_suite_result_json_file_pabot(self):
        """Check pabot is correct in self.data.suite.result_json_file ."""
        self.assertFalse(self.rl_obj.data.suite.result_json_file["pabot"])

    def test_check_data_suite_result_json_file_cpeId(self):
        """Check cpeId is correct in self.data.suite.result_json_file ."""
        self.assertEqual(self.rl_obj.data.suite.result_json_file["cpeId"], CPE_ID)

    def test_check_data_suite_result_json_file_buildName(self):
        """Check buildName is correct in self.data.suite.result_json_file ."""
        self.assertEqual(self.rl_obj.data.suite.result_json_file["buildName"], None)

    def test_check_data_suite_result_json_file_rackSlotId(self):
        """Check rackSlotId is correct in self.data.suite.result_json_file ."""
        self.assertEqual(self.rl_obj.data.suite.result_json_file["rackSlotId"], RACK_SLOT_ID)

    def test_check_data_suite_result_json_file_stb_pool(self):
        """Check rackSlotId is correct in self.data.suite.result_json_file ."""
        self.assertRaises(KeyError, lambda: self.rl_obj.data.suite.result_json_file["stb_pool"])

    def test_check_data_test_result_json_file_status(self):
        """Check status is correct in self.data.test.result_json_file ."""
        self.assertEqual(self.rl_obj.data.test.result_json_file["status"], "FAIL")

    def test_check_data_test_result_json_file_name(self):
        """Check name is correct in self.data.test.result_json_file ."""
        self.assertEqual(self.rl_obj.data.test.result_json_file["name"], SUITE_NAME)

    def test_check_data_test_result_json_file_testRun(self):
        """Check testRun is correct in self.data.test.result_json_file ."""
        pattern = "\d{14}-[abcdef0-9]{8}(-[abcdef0-9]{4}){3}"    # pylint: disable=anomalous-backslash-in-string
        self.assertTrue(
            re.match(pattern, self.rl_obj.data.test.result_json_file["testRun"])
        )

    def test_check_data_test_result_json_file_description(self):
        """Check description is correct in self.data.test.result_json_file ."""
        self.assertEqual(self.rl_obj.data.test.result_json_file["description"], DESCRIPTION)

    def test_check_data_test_result_json_file_feature(self):
        """Check feature is correct in self.data.test.result_json_file ."""
        self.assertEqual(self.rl_obj.data.test.result_json_file["feature"], FEATURE)

    def test_check_data_test_result_json_file_jira(self):
        """Check jira is correct in self.data.test.result_json_file ."""
        self.assertEqual(self.rl_obj.data.test.result_json_file["jira"], EXPECTED_JIRA)

    def test_check_data_test_result_json_file_track(self):
        """Check track is correct in self.data.test.result_json_file ."""
        self.assertEqual(self.rl_obj.data.test.result_json_file["track"], EXPECTED_TRACK)

    def test_check_data_test_result_json_file_execution_time(self):
        """Check execution_time is correct in self.data.test.result_json_file ."""
        self.assertEqual(
            self.rl_obj.data.test.result_json_file["execution_time"], int(SUITE_DURATION))

    def test_check_data_test_result_json_file_testStepsList_failedReason(self):
        """Check testStepsList_failedReason is correct in self.data.test.result_json_file ."""
        self.assertEqual(
            self.rl_obj.data.test.result_json_file["testStepsList"][0]["failedReason"],
            TEST_FAIL_REASON
        )

    def test_check_data_test_result_json_file_testStepsList_robotError(self):
        """Check testStepsList_robotError is correct in self.data.test.result_json_file ."""
        self.assertEqual(
            self.rl_obj.data.test.result_json_file["testStepsList"][0]["robotError"],
            robotError
        )

    def test_check_data_test_result_json_file_testStepsList_name(self):
        """Check testStepsList_name is correct in self.data.test.result_json_file ."""
        self.assertEqual(
            self.rl_obj.data.test.result_json_file["testStepsList"][0]["name"],
            TEST_NAME
        )

    def test_check_data_test_result_json_file_testStepsList_tool(self):
        """Check testStepsList_tool is correct in self.data.test.result_json_file ."""
        self.assertEqual(
            self.rl_obj.data.test.result_json_file["testStepsList"][0]["tool"],
            TOOL
        )

    def test_check_data_test_result_json_file_testStepsList_tags(self):
        """Check testStepsList_tags is correct in self.data.test.result_json_file ."""
        self.assertEqual(
            self.rl_obj.data.test.result_json_file["testStepsList"][0]["tags"],
            EXPECTED_TAGS
        )

    def test_check_data_test_result_json_file_tags(self):
        """Check tags is correct in self.data.test.result_json_file ."""
        self.assertEqual(
            self.rl_obj.data.test.result_json_file["tags"], "-".join(sorted(EXPECTED_TAGS)))

    def test_check_data_test_result_json_file_cpeId(self):
        """Check cpeId is correct in self.data.test.result_json_file ."""
        self.assertEqual(
            self.rl_obj.data.test.result_json_file["cpeId"], CPE_ID)

    def test_check_data_test_result_json_file_buildName(self):
        """Check buildName is correct in self.data.test.result_json_file ."""
        self.assertEqual(
            self.rl_obj.data.test.result_json_file["buildName"], None)

    def test_check_data_test_result_json_file_rackSlotId(self):
        """Check rackSlotId is correct in self.data.test.result_json_file ."""
        self.assertEqual(
            self.rl_obj.data.test.result_json_file["rackSlotId"], RACK_SLOT_ID)

    def test_check_data_test_result_json_file_jiraData(self):
        """Check jiraData is correct in self.data.test.result_json_file ."""
        self.assertEqual(self.rl_obj.data.test.result_json_file["jiraData"]["status"], "")
        self.assertEqual(self.rl_obj.data.test.result_json_file["jiraData"]["priority"], "")
        self.assertEqual(self.rl_obj.data.test.result_json_file["jiraData"]["linkedList"], ["None"])
        self.assertEqual(self.rl_obj.data.test.result_json_file["jiraData"]["linked"], [])

    def test_check_data_test_result_json_file_url_stdout(self):
        """Check url_stdout is correct in self.data.test.result_json_file ."""
        self.assertTrue(
            isinstance(self.rl_obj.data.test.result_json_file["url"], dict))

    def test_suite_data_attributes_len(self, *args):
        """Check lenght of attributes of data.suite object."""
        attributes = []
        for attribute in dir(self.rl_obj.data.suite):
            if not attribute.startswith("__") and not attribute.endswith("__"):
                attributes.append(attribute)
        self.assertEqual(len(attributes), 49)


class TestSender_SendTestResults(TestSender_SendSuiteResults):
    """Class contains unit tests of check_now() keyword."""

    @classmethod
    def setUpClass(cls):
        super(TestSender_SendTestResults).__init__(cls)
        cls.test_json = json.loads(cls.rl_obj.data.test.json_str)

    @classmethod
    def tearDownClass(cls):
        pass

    def test_send_test_results_ok(self):
        """Check status of sending test case results."""
        self.assertTrue(self.rl_obj.sender_status["test"])

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
        self.assertEqual(self.test_json["Timing"]["duration"], str(TEST_DURATION))

    def test_check_test_json_link(self):
        """Check Suite result link (URL to Kibana) is correct in json data."""
        result_link = str(self.test_json["resultLink"])
        pattern = "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{1,3}Z"  # pylint: disable=anomalous-backslash-in-string
        expected_dates = re.findall(pattern, TEST_KIBANA_URL)
        actual_dates = re.findall(pattern, result_link)
        for date in expected_dates:
            self.assertTrue(re.match(pattern, date), msg="Wrong expected_dates")
        for date in actual_dates:
            self.assertTrue(re.match(pattern, date), msg="Wrong actual_dates")
        expected_link_parts = \
            self._split_result_url(TEST_KIBANA_URL, expected_dates)
        actual_link_parts = \
            self._split_result_url(result_link, actual_dates)
        self.assertEqual(expected_link_parts, actual_link_parts)

    @staticmethod
    def _split_result_url(link, dates):
        from_date = dates[0]
        to_date = dates[1]
        link_first_part = link.split(from_date)[0]
        link_middle_part = link.split(from_date)[1].split(to_date)[0]
        link_last_part = link.split(to_date)[1]
        return link_first_part, link_middle_part, link_last_part

    def test_check_test_kibana_board(self):
        """Check correct Kibana Dashboard is in Suite Kibana URL."""
        kibana_board = "NO_MORE_INFO"
        part = "%s" % kibana_board
        self.assertTrue(self.test_json["resultLink"].startswith(part))
        self.assertTrue(not self.rl_obj.test_case_data_to_send.kibana_url)

    def test_check_test_json_description(self):
        """Check Test description is correct in test json data."""
        self.assertEqual(self.test_json["description"], str(DESCRIPTION))

    def test_check_test_json_type(self):
        """Check Test type is correct in test json data."""
        self.assertEqual(self.test_json["type"], "teststep")

    def test_check_test_json_lab(self):
        """Check Test lab is correct in test json data."""
        self.assertEqual(self.test_json["lab"], "lab" + LAB_NAME)

    def test_check_test_json_track(self):
        """Check Test track is correct in test json data."""
        self.assertEqual(self.test_json["track"], "MOCK_FOR_TRACK")

    def test_check_test_json_avgResponseTime(self):
        """Check Test avgResponseTime is correct in test json data."""
        self.assertEqual(self.test_json["Timing"]["avgResponseTime"], float(AVG_RESPONSE_TIME))

    def test_check_test_json_maxResponseTime(self):
        """Check Test maxResponseTime is correct in test json data."""
        self.assertEqual(self.test_json["Timing"]["maxResponseTime"], float(MAX_RESPONSE_TIME))

    def test_check_test_json_location(self):
        """Check Test location is correct in test json data."""
        self.assertEqual(self.test_json["location"], LOCATION)

    def test_check_test_json_id_pipeline(self):
        """Check Test id_pipeline is correct in test json data."""
        self.assertEqual(self.test_json["id"]["pipeline"], PIPELINE_ID)

    def test_check_test_json_id_job(self):
        """Check Test id_job is correct in test json data."""
        self.assertEqual(self.test_json["id"]["job"], JOB_NAME)

    def test_check_test_json_id_suite(self):
        """Check Test id_suite is correct in test json data."""
        pattern = "(\d{14}-){2}[abcdef0-9]{8}(-[abcdef0-9]{4}){3}"    # pylint: disable=anomalous-backslash-in-string
        self.assertTrue(
            re.match(pattern, self.test_json["id"]["suite"])
        )

    def test_check_test_json_id_testRun(self):
        """Check Test id_testRun is correct in test json data."""
        pattern = "(\d{14}-){2}[abcdef0-9]{8}(-[abcdef0-9]{4}){3}"    # pylint: disable=anomalous-backslash-in-string
        self.assertTrue(
            re.match(pattern, self.test_json["id"]["testRun"])
        )

    def test_check_test_json_id_user(self):
        """Check Test id_user is correct in test json data."""
        self.assertEqual(self.test_json["id"]["user"], USER_ID)

    def test_check_test_json_id_commit(self):
        """Check Test id_commit is correct in test json data."""
        self.assertEqual(self.test_json["id"]["commit"], GIT_COMMIT)

    def test_check_test_json_id_branch(self):
        """Check Test id_branch is correct in test json data."""
        self.assertEqual(self.test_json["id"]["branch"], GIT_BRANCH)

    def test_check_test_json_url_output(self):
        """Check Test url_output is correct in test json data."""
        self.assertEqual(self.test_json["url"]["output"], BUILD_URL + "robot/report/output.xml")

    def test_check_test_json_url_log(self):
        """Check Test url_log is correct in test json data."""
        self.assertEqual(self.test_json["url"]["log"], BUILD_URL + "robot/report/log.html")

    def test_check_test_json_url_report(self):
        """Check Test url_report is correct in test json data."""
        self.assertEqual(self.test_json["url"]["report"], BUILD_URL + "robot/report/report.html")

    def test_check_test_json_url_screenshot(self):
        """Check Test url_screenshot is correct in test json data."""
        self.assertEqual(self.test_json["url"]["screenshot"], URL_SCREENSHOT)

    def test_check_test_json_url_path(self):
        """Check Test url_path is correct in test json data."""
        self.assertEqual(self.test_json["url"]["path"], URL_PATH)

    def test_check_test_json_failedReasonRobot(self):
        """Check Test failedReasonRobot is correct in test json data."""
        self.assertEqual(self.test_json["failedReasonRobot"], robotError)

    def test_check_test_json_url_full_log(self):
        """Check full_log is correct in suite json data."""
        self.assertEqual(self.test_json["url"]["full_log"], "")

    def test_check_test_json_url_quickreport(self):
        """Check quickreport is correct in suite json data."""
        self.assertEqual(
            self.test_json["url"]["quickreport"],
            BUILD_URL + 'artifact/e2e_si_automation/robot/execution_artifacts/quickreport.html')

    def test_check_test_json_jiraData_status(self):
        """Check status is correct in suite json data."""
        self.assertEqual(self.test_json["jiraData"]["status"], "")

    def test_check_test_json_jiraData_priority(self):
        """Check priority is correct in suite json data."""
        self.assertEqual(self.test_json["jiraData"]["priority"], "")

    def test_check_test_json_jiraData_linkedList(self):
        """Check linkedList is correct in suite json data."""
        self.assertEqual(self.test_json["jiraData"]["linkedList"], ["None"])

    def test_check_test_json_jiraData_linked(self):
        """Check linked is correct in suite json data."""
        self.assertEqual(self.test_json["jiraData"]["linked"], [])

    def test_check_test_details_failedReason(self):
        """Check Test failedReason is correct in test_details."""
        self.assertEqual(self.rl_obj.data.suite.test_step_list[0]["failedReason"], TEST_FAIL_REASON)

    def test_check_test_details_robotError(self):
        """Check Test robotError is correct in test json data."""
        self.assertEqual(self.rl_obj.data.suite.test_step_list[0]["robotError"], robotError)

    def test_check_test_details_status(self):
        """Check Test status is correct in test_details."""
        self.assertEqual(self.rl_obj.data.suite.test_step_list[0]["status"], "FAIL")

    def test_check_test_details_name(self):
        """Check Test name is correct in test_details."""
        self.assertEqual(self.rl_obj.data.suite.test_step_list[0]["name"], TEST_NAME)

    def test_check_test_details_tool(self):
        """Check Test tool is correct in test_details."""
        self.assertEqual(self.rl_obj.data.suite.test_step_list[0]["tool"], TOOL)

    def test_check_test_details_screenshot_url(self):
        """Check Test screenshot_url is correct in test_details."""
        self.assertEqual(self.rl_obj.data.suite.test_step_list[0]["screenshot_url"], URL_SCREENSHOT)

    def test_check_test_details_tags(self):
        """Check Test tags is correct in test_details."""
        self.assertEqual(self.rl_obj.data.suite.test_step_list[0]["tags"], EXPECTED_TAGS)

    def test_data_attributes_len(self, *args):
        """Check lenght of attributes of data.test object."""
        attributes = []
        for attribute in dir(self.rl_obj.data.test):
            if not attribute.startswith("__") and not attribute.endswith("__"):
                attributes.append(attribute)
        self.assertEqual(len(attributes), 15)


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
