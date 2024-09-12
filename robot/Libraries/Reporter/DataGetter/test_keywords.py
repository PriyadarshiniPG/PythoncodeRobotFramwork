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
import re
import unittest
try:
    import mock
except ImportError:
    import unittest.mock as mock
from robot.libraries.BuiltIn import BuiltIn  # pylint: disable=unused-import
import tools  # pylint: disable=import-error
from Libraries.Jira.keywords import JiraGetter
from .keywords import Data, TestSuiteData, TestCaseData



os.environ["ACTUAL_CPE_BUILD"] = "DCX960__-mon-rel-00.02-079-fe-AL-20190924210000-un000"


CONF = {
    "MOCK": {
        "ELK_HOST": "127.0.0.1"
    }
}
LISTENER_START_SUITE_ARGS = (
    'Dummy test name',
    {
        'suites': [],
        'tests': ['test 1', 'test 2', 'test 3'],
        'doc': 'Dummy doc string',
        'source': 'path/to/test',
        'totaltests': 3,
        'starttime': '20191203 11:05:14.634',
        'longname': 'Robot.Sprints.Tests.Regression.Dummy test name',
        'id': 's1',
        'metadata': {}
    }
)
LISTENER_START_TEST_ARGS = (
    'test 1',
    {
        'critical': 'yes',
        'template': '',
        'starttime': '20191203 16:09:53.112',
        'tags': ['JIRA_HES-121'],
        'doc': 'Dummy doc',
        'longname': 'Dummy test name.test 1',
        'id': 's1-t1'
    }
)
LISTENER_END_TEST_ARGS = (
    'test 1',
    {
        'status': 'PASS',
        'template': '',
        'tags': ['JIRA_HES-121'],
        'doc': 'Dummy doc',
        'elapsedtime': 52,
        'critical': 'yes',
        'starttime': '20191203 17:39:18.313',
        'longname': 'Dummy test name.test 1',
        'message': '',
        'endtime': '20191203 17:39:18.365',
        'id': 's1-t1'
    }
)
LISTENER_END_SUITE_ARGS = (
    'Dummy test name',
    {
        'status': 'FAIL',
        'suites': [],
        'tests': ['test 1', 'test 2', 'test 3'],
        'statistics': '3 critical tests, 3 passed, 0 failed\n3 tests total, 3 passed, 0 failed',
        'doc': 'Dummy mock description',
        'elapsedtime': 3652,
        'source': 'path/to/test',
        'totaltests': 3,
        'starttime': '20191204 11:24:48.328',
        'longname': 'Dummy test name',
        'message': '',
        'endtime': '20191204 11:24:51.980',
        'id': 's1',
        'metadata': {}
    }
)
CPE_ID = "3C36E4-EOSSTB-003356472104"
CPE_VERSION = "None"
TEST_FAIL_REASON = """There were errors while playing \
http://172.30.133.52/dash/lab3/Index/RTL5_clear/manifest.mpd"""
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
DESCRIPTION = "Dummy test description"
LAB_NAME = "labe2esuperset"
LOCATION = "some location"
AVG_RESPONSE_TIME = "10.7903"
MAX_RESPONSE_TIME = "18.801"
PIPELINE_ID = "PIPELINE_SANITY_183"
JOB_ID = "job id"
JOB_NAME = "job-name"
USER_ID = "user id 123"
BUILD_NUMBER = "build 321"
GIT_COMMIT = "mn56ukjhgr56ujhtr4"
GIT_BRANCH = "dummy-branch-name"
BUILD_URL = "http://dummy.com:8080/build/12/"
URL_SCREENSHOT = "http://dummy.com:8080/screenshots/789/"
URL_PATH = "http://dummy.com:8080/path/789/"
robotError = "any robot error"
RACK_SLOT_ID = "97654"
PABOT = False
STB_POOL = "STB-1,STB-2"
ID_PATTERN = "\d{14}-[abcdef0-9]{8}(-[abcdef0-9]{4}){3}"  # pylint: disable=anomalous-backslash-in-string
TIME_PATTERN = "\d{13}"  # pylint: disable=anomalous-backslash-in-string
JIRA_DATA = {
    'HES-121': {
        'status': 'Done',
        'priority': 'Minor (P3)',
        'linked': {
            'HES-11120': {
                'jira': 'HES-11120',
                'status': 'Draft',
                'reporter': 'Vivek Mishra',
                'url': 'https://jira.lgi.io/browse/HES-11120',
                'labels': ['R4.20', 'Sanity_Automation', "E2ESI_QA_SUPERSET", "E2ESI_QA_LAB"],
                'summary': '[CH PROD]Because you have watched recommendation '
                           'is missing for watched VOD assets ',
                'project': 'HES',
                'assignee': 'Praveen Rao',
                'type': 'Bug',
                'priority': 'Minor (P3)'
            }
        }
    }
}

LINKED_TICKETS_DICT = {
    'Bug': {
        'HES-10121': {
            'jira': 'HES-10121',
            'status': 'Grooming',
            'project': 'HES',
            'reporter': 'Vishwanand Upadhyay',
            'url': 'https://jira.lgi.io/browse/HES-10121',
            'labels': ['E2ESI_QA_GB', 'PROD', 'R4.18', 'Sanity', "E2ESI_QA_SUPERSET"],
            'summary': '[Prod GB] Trickplay - FF/FR is not seamless on Replay Assets',
            'priority': 'Medium',
            'assignee': 'Mervyn Medlyn',
            'type': 'Bug',
            'linked': {
                'tested': {
                    'HES-467': {
                        'status': 'Done',
                        'priority': 'Minor (P3)',
                        'summary': 'Replay TV - Trick-play modes'
                    }
                }
            }
        },
        'HES-121': {
            'jira': 'HES-121',
            'status': 'Draft',
            'project': 'HES',
            'reporter': 'Vivek Mishra',
            'url': 'https://jira.lgi.io/browse/HES-121',
            'labels': ['E2ESI_QA_CH_PROD', 'R4.20', 'Sanity_Automation'],
            'summary': '[CH PROD]Because you have watched recommendation '
                       'is missing for watched VOD assets ',
            'priority': 'Minor (P3)',
            'assignee': 'Praveen Rao',
            'type': 'Bug',
            'linked': {
                'blocking': {
                    'HES-7397': {
                        'status': 'Done',
                        'priority': 'Minor (P3)',
                        'summary': 'VOD : Verify recommendation for watched VOD assets  '}
                }
            }
        }
    }
}

def mock_robot_get_var_value(*args):
    """Function returns predefined value as keyword "Get Variable Value" would do."""
    result = None
    var_name = args[0]
    if var_name == "CPE_ID":
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
    elif var_name == "CAPTURE_SCREENSHOT":
        result = False
    return result


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
            text = "some text"
            data = dict(text=text, status_code=200, reason="OK")
    return type("", (), data)()


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


class GetStartSuiteData(TestCaseNameAsDescription):
    """Class contains unit tests of get_start_suite_data() method."""

    @classmethod
    @mock.patch.object(tools, "get_conf", return_value=CONF["MOCK"])
    @mock.patch.object(tools, "get_var_value", side_effect=mock_robot_get_var_value)
    @mock.patch.object(tools, "set_suite_var", side_effect=lambda x, y: None)
    def setUpClass(cls, *args):  # pylint: disable=arguments-differ
        cls.data = Data()
        cls.data.get_start_suite_data(LISTENER_START_SUITE_ARGS)

    @classmethod
    def tearDownClass(cls):
        pass

    def test_data_check_init(self, *args):
        """Check Data class attributes"""
        self.assertEqual(self.data.conf, CONF["MOCK"])
        self.assertIsInstance(self.data.suite, TestSuiteData)
        self.assertEqual(self.data.test, None)

    def test_suite_data_test_run_id(self, *args):
        """Check test_run_id attribute of TestSuiteData class."""
        self.assertTrue(re.match(ID_PATTERN, self.data.suite.test_run_id))

    def test_suite_data_tools_list(self, *args):
        """Check tools_list attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.tools_list, [])

    def test_suite_data_original_ts_name(self, *args):
        """Check original_ts_name attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.original_ts_name, "Regression.Dummy test name")

    def test_suite_data_ts_name(self, *args):
        """Check ts_name attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.ts_name, "DUMMY_TEST_NAME")

    def test_suite_data_feature(self, *args):
        """Check feature attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.feature, None)

    def test_suite_data_track(self, *args):
        """Check track attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.track, None)

    def test_suite_data_jira(self, *args):
        """Check jira attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.jira, [])

    def test_suite_data_cpe(self, *args):
        """Check cpe attribute of TestSuiteData class."""
        self.assertEqual(sorted(self.data.suite.cpe.keys()), ["id", "version"])
        self.assertEqual(self.data.suite.cpe["id"], None)
        self.assertEqual(self.data.suite.cpe["version"], None)

    def test_suite_data_failed_reason(self, *args):
        """Check failed_reason attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.failed_reason, "")

    def test_suite_data_failed_tests(self, *args):
        """Check failed_tests attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.failed_tests, [])

    def test_suite_data_ts_tags(self, *args):
        """Check ts_tags attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.ts_tags, [])

    def test_suite_data_avgResponseTime(self, *args):
        """Check avgResponseTime attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.avgResponseTime, "")

    def test_suite_data_maxResponseTime(self, *args):
        """Check maxResponseTime attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.maxResponseTime, "")

    def test_suite_data_url_path(self, *args):
        """Check url_path attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.url_path, "")

    def test_suite_data_location(self, *args):
        """Check location attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.location, "")

    def test_suite_data_id_pipeline(self, *args):
        """Check id_pipeline attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.id_pipeline, PIPELINE_ID)

    def test_suite_data_id_suite(self, *args):
        """Check id_suite attribute of TestSuiteData class."""
        self.assertTrue(re.match(ID_PATTERN, self.data.suite.id_suite))

    def test_suite_data_id_user(self, *args):
        """Check id_user attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.id_user, USER_ID)

    def test_suite_data_id_testrun(self, *args):
        """Check id_testrun attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.id_testrun, self.data.suite.test_run_id)

    def test_suite_data_id_build(self, *args):
        """Check id_build attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.id_build, BUILD_NUMBER)

    def test_suite_data_id_commit(self, *args):
        """Check id_commit attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.id_commit, GIT_COMMIT)

    def test_suite_data_id_branch(self, *args):
        """Check id_branch attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.id_branch, GIT_BRANCH)

    def test_suite_data_url_build(self, *args):
        """Check url_build attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.url_build, BUILD_URL)

    def test_suite_data_url_output(self, *args):
        """Check url_output attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.url_output, BUILD_URL + "robot/report/output.xml")

    def test_suite_data_url_log(self, *args):
        """Check url_log attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.url_log, BUILD_URL + "robot/report/log.html")

    def test_suite_data_url_report(self, *args):
        """Check url_report attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.url_report, BUILD_URL + "robot/report/report.html")

    def test_suite_data_url_screenshot(self, *args):
        """Check url_screenshot attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.url_screenshot, URL_SCREENSHOT)

    def test_suite_data_failed_reason_robot(self, *args):
        """Check failed_reason_robot attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.failed_reason_robot, "")

    def test_suite_data_test_step_list(self, *args):
        """Check test_step_list attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.test_step_list, [])

    def test_suite_data_stb_pool(self, *args):
        """Check stb_pool attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.stb_pool, STB_POOL)

    def test_suite_data_pabot(self, *args):
        """Check pabot attribute of TestSuiteData class."""
        self.assertFalse(self.data.suite.pabot)

    def test_suite_data_result(self, *args):
        """Check result attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.result, "")

    def test_suite_data_description(self, *args):
        """Check description attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.description, "")

    def test_suite_data_result_json_file(self, *args):
        """Check result_json_file attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.result_json_file, None)

    def test_suite_data_url_full_log(self, *args):
        """Check url_full_log attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.url_full_log, "")

    def test_suite_data_lab(self, *args):
        """Check lab attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.lab, LAB_NAME)

    def test_suite_data_jira_data_status(self, *args):
        """Check jira_data_status attribute of TestSuiteData class."""
        self.assertEqual(
            self.data.suite.jira_data_status, "")

    def test_suite_data_jira_data_priority(self, *args):
        """Check jira_data_priority attribute of TestSuiteData class."""
        self.assertEqual(
            self.data.suite.jira_data_priority, "")

    def test_suite_data_jira_data_linked_list(self, *args):
        """Check jira_data_linked_list attribute of TestSuiteData class."""
        self.assertEqual(
            self.data.suite.jira_data_linked_list, []
        )

    def test_suite_data_jira_data_linked(self, *args):
        """Check jira_data_linked attribute of TestSuiteData class."""
        self.assertEqual(
            self.data.suite.jira_data_linked, []
        )

    def test_suite_data_url_quickreport(self, *args):
        """Check url_quickreport attribute of TestSuiteData class."""
        self.assertEqual(
            self.data.suite.url_quickreport,
            BUILD_URL + "artifact/e2e_si_automation/robot/execution_artifacts/quickreport.html")

    def test_suite_data_repository(self, *args):
        """Check repository attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.repository, "e2e_si_automation")

    def test_suite_data_environment(self, *args):
        """Check environment attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.environment, "lab")

    def test_suite_data_tenant(self, *args):
        """Check tenant attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.tenant, LAB_NAME.replace("lab", "").
                         replace("e2esuperset", "superset"))

    def test_suite_data_jira_data_all_linked(self, *args):
        """Check jira_data_all_linked attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.jira_data_all_linked, {})

    def test_suite_data_jiragetter(self, *args):
        """Check jiragetter attribute of TestSuiteData class."""
        self.assertIsInstance(self.data.suite.jiragetter, JiraGetter)

    def test_get_start_suite_data_id_job(self, *args):
        """Check id_job attribute from get_start_suite_data method."""
        self.assertEqual(self.data.suite.id_job, JOB_NAME)

    def test_get_start_suite_data_time(self, *args):
        """Check time attribute from get_start_suite_data method."""
        self.assertEqual(list(self.data.suite.time.keys()), ["start", "end"])
        self.assertTrue(re.match(TIME_PATTERN, str(self.data.suite.time["start"])))
        self.assertEqual(self.data.suite.time["end"], None)

    def test_suite_data_attributes_len(self, *args):
        """Check lenght of attributes of TestSuiteData class."""
        attributes = []
        for attribute in dir(self.data.suite):
            if not attribute.startswith("__") and not attribute.endswith("__"):
                attributes.append(attribute)
        self.assertEqual(len(attributes), 48)


class GetStartTestData(GetStartSuiteData):
    """Class contains unit tests of get_start_suite_data() method."""

    @classmethod
    @mock.patch.object(tools, "get_var_value", side_effect=mock_robot_get_var_value)
    @mock.patch.object(
        JiraGetter, "get_all_linked_tickets_from_data_file", return_value=LINKED_TICKETS_DICT)
    @mock.patch.object(
        JiraGetter, "get_linked_tickets_dict_for_one_from_all_tickets_info", return_value=JIRA_DATA)
    def setUpClass(cls, *args):
        cls.data.get_start_test_data(LISTENER_START_TEST_ARGS)

    @classmethod
    def tearDownClass(cls):
        pass

    def test_data_check_init(self, *args):
        """Check Data class attributes"""
        self.assertEqual(self.data.conf, CONF["MOCK"])
        self.assertIsInstance(self.data.suite, TestSuiteData)
        self.assertIsInstance(self.data.test, TestCaseData)

    def test_suite_data_cpe(self, *args):
        """Check cpe attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.cpe["id"], CPE_ID)

    def test_suite_data_feature(self, *args):
        """Check feature attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.feature, EXPECTED_FEATURE)

    def test_suite_data_jira(self, *args):
        """Check jira attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.jira, [EXPECTED_JIRA])

    def test_suite_data_jira_data_all_linked(self, *args):
        """Check jira_data_all_linked attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.jira_data_all_linked, LINKED_TICKETS_DICT)

    def test_suite_data_track(self, *args):
        """Check track attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.track, EXPECTED_TRACK)

    def test_suite_data_ts_tags(self, *args):
        """Check ts_tags attribute from get_start_test_data method."""
        self.assertEqual(self.data.suite.ts_tags, EXPECTED_TAGS)

    def test_case_data_suite_obj(self, *args):
        """Check suite_obj attribute of TestCaseData class."""
        self.assertEqual(self.data.test.suite_obj, self.data.suite)

    def test_case_data_tc_name(self, *args):
        """Check tc_name attribute of TestCaseData class."""
        self.assertEqual(self.data.test.tc_name, LISTENER_START_TEST_ARGS[0])

    def test_case_data_tool(self, *args):
        """Check tool attribute of TestCaseData class."""
        self.assertEqual(self.data.test.tool, EXPECTED_TOOL)

    def test_case_data_failed_reason(self, *args):
        """Check failed_reason attribute of TestCaseData class."""
        self.assertEqual(self.data.test.failed_reason, None)

    def test_case_data_failed_reason_robot(self, *args):
        """Check failed_reason_robot attribute of TestCaseData class."""
        self.assertEqual(self.data.test.failed_reason_robot, "")

    def test_case_data_tc_tags(self, *args):
        """Check tc_tags attribute of TestCaseData class."""
        self.assertEqual(self.data.test.tc_tags, EXPECTED_TAGS)

    def test_case_data_avgResponseTime(self, *args):
        """Check avgResponseTime attribute of TestCaseData class."""
        self.assertEqual(self.data.test.avgResponseTime, "")

    def test_case_data_maxResponseTime(self, *args):
        """Check avgResponseTime attribute of TestCaseData class."""
        self.assertEqual(self.data.test.maxResponseTime, "")

    def test_case_data_url_path(self, *args):
        """Check url_path attribute of TestCaseData class."""
        self.assertEqual(self.data.test.url_path, "")

    def test_case_data_location(self, *args):
        """Check location attribute of TestCaseData class."""
        self.assertEqual(self.data.test.location, "")

    def test_case_data_description(self, *args):
        """Check description attribute of TestCaseData class."""
        self.assertEqual(self.data.test.description, "")

    def test_case_data_result(self, *args):
        """Check result attribute of TestCaseData class."""
        self.assertEqual(self.data.test.result, "")

    def test_case_data_result_json_file(self, *args):
        """Check result_json_file attribute of TestCaseData class."""
        self.assertEqual(self.data.test.result_json_file, None)

    def test_suite_data_jira_data_status(self, *args):
        """Check jira_data_status attribute of TestSuiteData class."""
        self.assertEqual(
            self.data.suite.jira_data_status,
            JIRA_DATA[EXPECTED_JIRA]["status"])

    def test_suite_data_jira_data_priority(self, *args):
        """Check jira_data_priority attribute of TestSuiteData class."""
        linked_ticket = list(JIRA_DATA[EXPECTED_JIRA]["linked"].keys())[0]
        self.assertEqual(
            self.data.suite.jira_data_priority,
            JIRA_DATA[EXPECTED_JIRA]["linked"][linked_ticket]["priority"])

    def test_suite_data_jira_data_linked_list(self, *args):
        """Check jira_data_linked_list attribute of TestSuiteData class."""
        self.assertEqual(
            self.data.suite.jira_data_linked_list,
            list(JIRA_DATA[EXPECTED_JIRA]["linked"].keys())
        )

    def test_suite_data_jira_data_linked(self, *args):
        """Check jira_data_linked attribute of TestSuiteData class."""
        linked_ticket = list(JIRA_DATA[EXPECTED_JIRA]["linked"].keys())[0]
        self.assertEqual(
            self.data.suite.jira_data_linked,
            [JIRA_DATA[EXPECTED_JIRA]["linked"][linked_ticket]]
        )

    def test_case_data_attributes_len(self, *args):
        """Check lenght of attributes of TestSuiteData class."""
        attributes = []
        for attribute in dir(self.data.test):
            if not attribute.startswith("__") and not attribute.endswith("__"):
                attributes.append(attribute)
        self.assertEqual(len(attributes), 14)


class GetEndTestData(GetStartTestData):
    """Class contains unit tests of get_start_suite_data() method."""

    @classmethod
    @mock.patch.object(tools, "get_var_value", side_effect=mock_robot_get_var_value)
    @mock.patch.object(tools, "get_robot_or_env_var_value", side_effect=mock_robot_get_var_value)
    def setUpClass(cls, *args):
        cls.data.get_end_test_data(LISTENER_END_TEST_ARGS)

    @classmethod
    def tearDownClass(cls):
        pass

    def test_case_data_avgResponseTime(self, *args):
        """Check avgResponseTime attribute of TestCaseData class."""
        self.assertEqual(self.data.test.avgResponseTime, AVG_RESPONSE_TIME)

    def test_case_data_description(self, *args):
        """Check description attribute of TestCaseData class."""
        self.assertEqual(self.data.test.description, LISTENER_END_TEST_ARGS[1]["doc"])

    def test_case_data_location(self, *args):
        """Check location attribute of TestCaseData class."""
        self.assertEqual(self.data.test.location, LOCATION)

    def test_case_data_maxResponseTime(self, *args):
        """Check avgResponseTime attribute of TestCaseData class."""
        self.assertEqual(self.data.test.maxResponseTime, MAX_RESPONSE_TIME)

    def test_case_data_result(self, *args):
        """Check result attribute of TestCaseData class."""
        self.assertEqual(self.data.test.result, LISTENER_END_TEST_ARGS[1]["status"])

    def test_case_data_url_path(self, *args):
        """Check url_path attribute of TestCaseData class."""
        self.assertEqual(self.data.test.url_path, URL_PATH)

    def test_suite_data_tools_list(self, *args):
        """Check tools_list attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.tools_list, [EXPECTED_TOOL])

    def test_case_data_attributes_len(self, *args):
        """Check lenght of attributes of TestSuiteData class."""
        attributes = []
        for attribute in dir(self.data.test):
            if not attribute.startswith("__") and not attribute.endswith("__"):
                attributes.append(attribute)
        self.assertEqual(len(attributes), 14)


class GetEndSuiteData(GetEndTestData):
    """Class contains unit tests of get_start_suite_data() method."""

    @classmethod
    @mock.patch.object(tools, "get_var_value", side_effect=mock_robot_get_var_value)
    @mock.patch.object(tools, "get_robot_or_env_var_value", side_effect=mock_robot_get_var_value)
    def setUpClass(cls, *args):
        cls.data.get_end_suite_data(LISTENER_END_SUITE_ARGS)

    @classmethod
    def tearDownClass(cls):
        pass

    def test_get_start_suite_data_time(self, *args):
        """Check time attribute from get_start_suite_data method."""
        self.assertTrue(re.match(TIME_PATTERN, str(self.data.suite.time["end"])))

    def test_suite_data_avgResponseTime(self, *args):
        """Check avgResponseTime attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.avgResponseTime, AVG_RESPONSE_TIME)

    def test_suite_data_maxResponseTime(self, *args):
        """Check maxResponseTime attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.maxResponseTime, MAX_RESPONSE_TIME)

    def test_suite_data_description(self, *args):
        """Check description attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.description, LISTENER_END_SUITE_ARGS[1]["doc"])

    def test_suite_data_location(self, *args):
        """Check location attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.location, LOCATION)

    def test_suite_data_result(self, *args):
        """Check result attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.result, LISTENER_END_SUITE_ARGS[1]["status"])

    def test_suite_data_url_path(self, *args):
        """Check url_path attribute of TestSuiteData class."""
        self.assertEqual(self.data.suite.url_path, self.data.test.url_path)

    def test_suite_data_attributes_len(self, *args):
        """Check lenght of attributes of TestSuiteData class."""
        attributes = []
        for attribute in dir(self.data.suite):
            if not attribute.startswith("__") and not attribute.endswith("__"):
                attributes.append(attribute)
        self.assertEqual(len(attributes), 48)


def make_suite(class_name):
    """A function builds a test suite for a given class."""
    return unittest.makeSuite(class_name, "test")


def run_tests():
    """A function runs unit tests; HTTP requests will not go to real servers."""
    suites = [
        make_suite(GetStartSuiteData),
        make_suite(GetStartTestData),
        make_suite(GetEndTestData),
        make_suite(GetEndSuiteData)
    ]
    for suite in suites:
        unittest.TextTestRunner(verbosity=2).run(suite)


if __name__ == "__main__":
    run_tests()
