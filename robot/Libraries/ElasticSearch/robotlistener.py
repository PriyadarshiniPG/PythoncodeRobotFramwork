# pylint: disable=C0103
# pylint: disable=too-many-instance-attributes
# Disabled pylint "too-many-instance-attributes" - it was complaining on TestSuiteData class and
# always showed same value 11/10 even if I added/removed attributes.
"""Implementation of ElasticSearch library's keywords for Robot Framework.
Test results go to ElasticSearch 'on-the-fly' after each test case if the library is imported.
This is achieved by overriding default listeners of Robot Framework.
Hence, the library cannot be used outside of Robot Framework context.

v0.0.1 - Fernando Cobos: send data to ElasticSearch
v0.0.3 - Natallia Savelyeva: implement robot listeners + adjust sending data
v0.0.4 - Fernando Cobos: Add CPE_ID and CPE_VERSION to Test Suite
v0.0.5 - Fernando Cobos: Rebuild kibana link dashboard and Add CPE_ID, CPE_VERSION to Test Case
v0.0.6 - Fernando Cobos: Add tools to use the tags as Tool field for ELK
v0.0.7 - Fernando Cobos: Add feature field, feature list & tools list, failreason to testSuite
v0.0.8 - Natallia Savelyeva: refactoring + unit tests.
v0.0.9 - Fernando Cobos: Fix Lab paramter name issue (LAB_NAME)
v0.0.10 - Fernando Cobos: Add FEATURE_ & TOOL_  tags
v0.0.11 - Fernando Cobos: Change testSuite to testCase and testCase to testStep
v0.0.12 - Natallia Savelyeva: Send ${TEST_MASSAGE} if ${failedReason} is empty (for test steps) -
          benefit: non-empty failedReason is sent when automation fails.
v0.0.13 - Fernando Cobos: Add TRACK_
v0.0.14 - Fernando Cobos: Remove the KIBANA_HOST and
          KIBANA_PORT + add KIBANA_TEST_STEP_NO_INFO_DASHBOARD
          from the lib - Index Patter will take care of it
v0.0.15 - Fernando Cobos: New parameter "ELK_TYPE_TEST" with default value "e2erobottest",
          used to specify the type for the index. Need it because ELK version
          6.X not support two types.
          REMARK: This new parameter will be only use if "ELK_TYPE_TEST_CASE" parameter
          is not present on the confX.py.
          Also "type" field has been added to the data json to be ingested
v0.0.16 - Fernando Cobos: If the FQDN to Kibana is already on the resultlink We remove it
          because It is going to be manage on the Kibana - Index Patterns - Solving Xagget
          issue - duplicate Ex: "http://odh.obo.appdev.io/kibana/app/kibana#/dashboard/"
v0.0.17 - Eugene Petrash: Add avgResponseTime and maxResponseTime
v0.0.18 - Fernando Cobos: Fix avgResponseTime and maxResponseTime as None
v0.0.19 - Eugene Petrash: Add TAG_FROM_LIB parsing
v0.0.20 - Eugene Petrash: Add url_path parsing and ingestion
v0.0.21 - Fernando Cobos: Add location parsing and ingestion + description
          is updated to use ${DESCRIPTION} if it is present (for testcase and teststep)
v0.0.22 - Anuj Teotia: Fix  mapper_parsing_exception number_format_exception of
          Timing.avgResponseTime and Timing.maxResponseTime
v0.0.23 - Fernando Cobos: Add RF_TIME_PATTERN_TESTRUN for testRun as a prefix
v0.0.24 - Anuj Teotia: Fix TOOL_  tags for mutiple tags
v0.0.25 - Fernando Cobos: We add ELK_AUTH on conf for ES AUTH
v0.0.26 - Fernando Cobos: Replace Tests. to not be ingested on the name
v0.0.27 - Fernando Cobos: Replace Regression. to not be ingested on the name (line 184)
          + Fix Tags for Testcases
v0.0.28 - Bhanu Ramappa: replace backslash + newline characters in failed_reason (line 422)
"""
from abc import ABCMeta, abstractmethod
import json
import requests
from robot.libraries.BuiltIn import BuiltIn
import tools


RF_TIME_PATTERN = "%Y%m%d %H:%M:%S.%f"
RF_TIME_PATTERN_TESTRUN = "%Y%m%d%H%M%S"

ELK_TEMPLATE = """
{
    "type": "%(type)s",
    "testCase": "%(testCase)s",
    "testStep":"%(testStep)s",
    "jira": "%(jira)s",
    "description": "%(description)s",
    "lab":"%(lab)s",
    "result": "%(result)s",
    "resultLink": "%(resultLink)s",
    "testRun": "%(testRun)s",
    "track": "%(track)s",
    "feature": "%(feature)s",
    "failedReason": "%(failedReason)s",
    "tags": "%(tags)s",
    "tool":"%(tool)s",
    "cpe": "%(cpe)s",
    "cpeVersion": "%(cpeVersion)s",
    "Timing": {
        "endTime": "%(endTime)s",
        "startTime": "%(startTime)s",
        "duration": "%(duration)s",
        "avgResponseTime": %(avgResponseTime)s,
        "maxResponseTime": %(maxResponseTime)s
    },
    "url_path": "%(url_path)s",
    "location": "%(location)s"
}
"""

KIBANA_DASHBOARD_URL = """%(KIBANA_DASHBOARD_NAME)s?_g=\
(refreshInterval:(display:Off,pause:!f,value:0),\
time:(from:'%(KIBANA_FROM_Z_TIME)s',mode:absolute,to:'%(KIBANA_TO_Z_TIME)s'))\
&_a=(query:(query_string:(analyze_wildcard:!t,query:'%(QUERY)s')))"""


class DataSender(object):
    """A class to send data via HTTP POST to ElasticSearch."""

    def __init__(self, conf):
        self.conf = conf

    def _send_data(self, json_str, res_index, res_type):
        status = False
        date_for_index = tools.time_now_str("%Y.%m.%d")
        if "ELK_AUTH" in self.conf:
            headers = {'Content-Type': 'application/json',
                       'Authorization': 'Basic %s' % self.conf["ELK_AUTH"]}
        else:
            headers = {"Content-Type": "application/json"}
        url = "http://%s:%s/%s-%s/%s" % (self.conf["ELK_HOST"], self.conf["ELK_PORT"],
                                         res_index, date_for_index, res_type)
        #print("Data ingested is: %s" % json.loads(json_str))
        #BuiltIn().log_to_console("Data ingested is: %s" % json.loads(json_str))

        response = requests.post(url, data=json_str, headers=headers)
        if response.status_code not in [200, 201]:
            BuiltIn().log_to_console("_send_data method. Response code %s. Reason %s. "
                                     "JSON was send:\n%s" %
                                     (response.status_code, response.reason, json_str))
        data = json.loads(response.text)
        if "result" in data:
            if "created" in data["result"] \
            and data["_shards"]["successful"] == 1 \
            and data["_shards"]["failed"] == 0:
                status = True
        else:
            print("ERROR sending data %s to ElasticSearch %s:\n%s" % (json_str, url, response.text))
        #print("Request sent to ElasticSearch: %s\n%s" % (url, json_str))
        #print("Response from ElasticSearch is: %s %s\n%s" % \
        #      (response.status_code, response.reason, response.text))
        return status

    def send(self, result_obj):
        """A method detects data type (test suite or test case)
        and sends the results accordingly to ElasticSearch.
        """
        res_index = self.conf["ELK_INDEX_ROBOT"]
        if "ELK_TYPE_TEST_CASE" in self.conf:
            if "tc_name" in result_obj.__dict__:
                res_type = self.conf["ELK_TYPE_TEST_STEP"]
            else:
                res_type = self.conf["ELK_TYPE_TEST_CASE"]
        else:
            if "ELK_TYPE_TEST" in self.conf:
                res_type = self.conf["ELK_TYPE_TEST"]
            else: #Default value test
                res_type = "e2erobottest"
        return self._send_data(result_obj.json_str, res_index, res_type)


class TestData(object):
    """Abstract class to handle Manifest."""
    __metaclass__ = ABCMeta

    def __init__(self):
        self.description = None
        self.time = {"start": None, "end": None}
        self.result = None
        self.json_str = None
        self.kibana_url = None
        self.jira = None

    @abstractmethod
    def make_url_kibana(self, conf):
        """A method to construct URL to Kibana views."""
        pass  # pylint: disable=W0107

    @abstractmethod
    def make_json(self, conf):
        """A method to construct a json string to POST data to ElasticSearch."""
        pass  # pylint: disable=W0107


class TestSuiteData(TestData):
    """A class to prepare requests to send test suite results to ElasticSearch."""

    def __init__(self, run_id, name):
        super(TestSuiteData, self).__init__()
        self.test_run_id = run_id
        self.tools_list = []         # list of unique tools used by tests
        print("Test Case name: %s" % str(name))
        self.ts_name = name\
            .replace("Robot.", "")\
            .replace("Sprints.", "")\
            .replace(" ", "_")\
            .replace("Tests.", "")\
            .replace("Regression.", "")\
            .upper()
        if "CTO_SR" in self.ts_name:
            self.ts_name = self.ts_name.split('.', 1)[-1]
        self.feature = None
        self.track = None
        self.jira = None
        self.cpe = {"id": None, "version": None}
        self.failed_tests = []
        self.ts_tags = []
        self.avgResponseTime = ""
        self.maxResponseTime = ""
        self.url_path = ""
        self.location = ""

    def make_url_kibana(self, conf):
        """Prepare a Kibana URL according to the template."""
        kibana_start = self.time["start"] - conf["KIBANA_DASHBOARD_TIME"]
        kibana_end = self.time["end"] + conf["KIBANA_DASHBOARD_TIME"]
        url_kibana = KIBANA_DASHBOARD_URL % {
            "KIBANA_DASHBOARD_NAME": conf["KIBANA_TEST_STEP_DASHBOARD"],
            "KIBANA_FROM_Z_TIME": tools.epoch_ms_to_z_time(kibana_start),
            "KIBANA_TO_Z_TIME": tools.epoch_ms_to_z_time(kibana_end),
            "QUERY": "testRun:%s" % self.test_run_id
        }
        self.kibana_url = url_kibana
        return url_kibana

    def make_json(self, conf):
        """Prepare a json string according to the suite result template."""
        if self.avgResponseTime is None:
            self.avgResponseTime = '""'
        if self.maxResponseTime is None:
            self.maxResponseTime = '""'
        if self.url_path is None:
            self.url_path = ""
        if self.location is None:
            self.location = ""
        json_str = ELK_TEMPLATE % {
            # Force type to testcase and testStep field as empty
            "type": "testcase", "testStep": "",
            "testRun": self.test_run_id, "testCase": self.ts_name,
            "description": self.description, "jira": self.jira,
            "lab": tools.get_lab_name(),
            "tags": "-".join(str(_t).replace(" ", "_") for _t in sorted(self.ts_tags)),
            "result": self.result, "feature": self.feature,
            "duration": str(self.time["end"] - self.time["start"]),
            "cpe": self.cpe["id"], "track": self.track,
            "cpeVersion": self.cpe["version"],
            "tool": ("-".join(str(_t).replace(" ", "_") for _t in
                              sorted(self.tools_list))).replace(",", "-"),
            "startTime": str(self.time["start"]), "endTime": str(self.time["end"]),
            "resultLink": self.make_url_kibana(conf),
            "failedReason": " - ".join(str(_t).replace('"', '').replace("'", "") \
                                       for _t in sorted(self.failed_tests)),
            "avgResponseTime": self.avgResponseTime,
            "maxResponseTime": self.maxResponseTime,
            "url_path": self.url_path,
            "location": self.location
        }
        json_str = json_str.replace("u'", "'").replace("\n", "")
        return json_str


class TestCaseData(TestData):
    """A class to prepare requests to send test case result to ElasticSearch."""

    def __init__(self, suite_obj, name, tags):
        super(TestCaseData, self).__init__()
        self.suite_obj = suite_obj
        self.tc_name = name
        self.tool = None
        self.failed_reason = None
        self.suite_obj.cpe["id"] = tools.get_var_value("CPE_ID")
        self.tc_tags = list(tags)
        self.avgResponseTime = ""
        self.maxResponseTime = ""
        self.url_path = ""
        self.location = ""
        for tag in tags:
            if "JIRA" in tag:
                self.suite_obj.jira = tag.replace("JIRA_", "")
                self.tc_tags.remove(tag)
            elif "FEATURE" in tag:
                self.suite_obj.feature = tag.replace("FEATURE_", "")
                self.tc_tags.remove(tag)
            elif "TOOL" in tag:
                if self.tool:
                    self.tool += ",%s" % (str(tag.replace("TOOL_", "")))
                else:
                    self.tool = tag.replace("TOOL_", "")
                self.tc_tags.remove(tag)
            elif "TRACK" in tag:
                self.suite_obj.track = tag.replace("TRACK_", "")
                self.tc_tags.remove(tag)

    def make_url_kibana(self, conf):
        """Prepare a Kibana URL according to the template."""
        kibana_start = self.time["start"] - conf["KIBANA_DASHBOARD_TIME"]
        kibana_end = self.time["end"] + conf["KIBANA_DASHBOARD_TIME"]
        kibana_query = ""
        kibana_board = conf["KIBANA_TEST_STEP_NO_INFO_DASHBOARD"]
        url_kibana = KIBANA_DASHBOARD_URL % {
            "KIBANA_DASHBOARD_NAME": kibana_board,
            "KIBANA_FROM_Z_TIME": tools.epoch_ms_to_z_time(kibana_start),
            "KIBANA_TO_Z_TIME": tools.epoch_ms_to_z_time(kibana_end),
            "QUERY": kibana_query
        }
        self.kibana_url = url_kibana
        return url_kibana

    def make_json(self, conf):
        """Prepare a json string according to the test case result template."""
        result_link = tools.get_var_value("resultLink") or self.make_url_kibana(conf)
        if "/app/kibana#/dashboard/" in result_link:
            print("XAGGET_RESULT_LINK: %s" % str(result_link))
            result_link = result_link[result_link.find("/app/kibana#/dashboard/")+23:\
                                      len(result_link)]
        self.suite_obj.cpe["version"] = tools.get_var_value("CPE_VERSION")
        if self.avgResponseTime is None:
            self.avgResponseTime = '""'
        if self.maxResponseTime is None:
            self.maxResponseTime = '""'
        if self.url_path is None:
            self.url_path = ""
        if self.location is None:
            self.location = ""
        json_str = ELK_TEMPLATE % {
            # Force type to teststep
            "type": "teststep",
            "testCase": self.suite_obj.ts_name, "testStep": self.tc_name,
            "description": self.description, "jira": self.suite_obj.jira,
            "feature": self.suite_obj.feature, "tool": self.tool,
            "testRun": self.suite_obj.test_run_id,
            "tags": "-".join(str(_t).replace(" ", "_") for _t in sorted(self.tc_tags)),
            "lab": tools.get_lab_name(),
            "result": self.result, "resultLink": result_link,
            "failedReason": self.failed_reason,
            "cpe": self.suite_obj.cpe["id"],
            "cpeVersion": self.suite_obj.cpe["version"],
            "duration": str(self.time["end"] - self.time["start"]),
            "startTime": self.time["start"], "endTime": self.time["end"],
            "track": self.suite_obj.track,
            "avgResponseTime": self.avgResponseTime,
            "maxResponseTime": self.maxResponseTime,
            "url_path": self.url_path,
            "location": self.location
        }
        json_str = json_str.replace("u'", "'").replace("\n", "")
        return json_str


class RobotListener(object):
    """A class overrides default Robot Framework listeners."""
    ROBOT_LISTENER_API_VERSION = 2
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self):
        setattr(self, "ROBOT_LIBRARY_LISTENER", self)
        self.conf = tools.get_conf()
        self.failed_tests = []  # list of failed tests is failed reason of test suite
        self.suite = None
        self.test = None
        self.sent = {"suite": None, "test": None}

    def _update_suite_failed_reason(self, result, tc_name):
        """Method adds failed test case name to the list of failed tests."""
        if result == "FAIL" and tc_name not in self.failed_tests:
            self.failed_tests.append(tc_name)

    def _update_suite_tools(self, tool):
        """Method adds a tool to the set of suite tools."""
        if tool not in self.suite.tools_list:
            self.suite.tools_list.append(tool)

    def _start_suite(self, *args):  # *args = name, attrs
        attrs = args[1]
        run_id = tools.generate_id("8-4-4-4")
        test_run_id = "%s-%s" % (tools.time_now_str(RF_TIME_PATTERN_TESTRUN), run_id)
        print("TEST_RUN_ID: %s" % test_run_id)
        tools.set_suite_var("TEST_RUN_ID", test_run_id)
        self.suite = TestSuiteData(test_run_id, attrs["longname"])
        self.suite.time["start"] = tools.time_ms(attrs["starttime"], RF_TIME_PATTERN)
        #print("\nStart Suite args: %s\n" % str(args))

    def _end_suite(self, *args):  # *args = name, attrs
        attrs = args[1]
        self.suite.time["end"] = tools.time_ms(attrs["endtime"], RF_TIME_PATTERN)
        self.suite.avgResponseTime = tools.get_var_value("avg_latency")
        self.suite.maxResponseTime = tools.get_var_value("max_latency")
        self.suite.location = tools.get_var_value("LOCATION")
        self.suite.result = attrs["status"]
        if attrs["doc"]:
            self.suite.description = attrs["doc"]
        else:
            self.suite.description = tools.get_var_value("DESCRIPTION") \
                if tools.get_var_value("DESCRIPTION") else ""
        self.suite.failed_tests = self.failed_tests
        self.suite.json_str = self.suite.make_json(self.conf)
        self.sent["suite"] = DataSender(self.conf).send(self.suite)
        # print(self.suite.json_str)
        #print("\nEnd Suite args: %s\n" % str(args))

    def _start_test(self, *args):  # *args = name, attrs
        name = args[0]
        attrs = args[1]
        self.test = TestCaseData(self.suite, name, tools.get_var_value("TEST_TAGS"))
        self.test.time["start"] = tools.time_ms(attrs["starttime"], RF_TIME_PATTERN)
        self.suite.ts_tags.extend(x for x in self.test.tc_tags if x not in self.suite.ts_tags)
        #print("\nStart Test args: %s\n" % str(args))

    def _end_test(self, *args):  # *args = name, attrs
        attrs = args[1]
        self.test.result = attrs["status"]
        if attrs["doc"]:
            self.test.description = attrs["doc"]
        else:
            self.test.description = tools.get_var_value("DESCRIPTION") \
                if tools.get_var_value("DESCRIPTION") else ""
        self.test.time["end"] = tools.time_ms(attrs["endtime"], RF_TIME_PATTERN)
        self.test.avgResponseTime = tools.get_var_value("avg_latency")
        self.test.maxResponseTime = tools.get_var_value("max_latency")
        endpoint_tag = tools.get_var_value("ENDPOINT_TAG")
        if endpoint_tag:
            self.test.tc_tags.append(endpoint_tag)
        url_path = tools.get_var_value("URL_PATH")
        if url_path:
            self.test.url_path = url_path
        location = tools.get_var_value("LOCATION")
        if location:
            self.test.location = location
        if self.test.result == "FAIL":
            failed_reason = str(tools.get_var_value("failedReason")) \
                            or tools.get_var_value("TEST_MESSAGE")
            self.test.failed_reason = failed_reason.replace('"', '')\
                .replace("'", "").replace("\\n", "").replace("\\", "")
        self._update_suite_failed_reason(self.test.result, self.test.tc_name)
        self.test.json_str = self.test.make_json(self.conf)
        self._update_suite_tools(self.test.tool)
        self.sent["test"] = DataSender(self.conf).send(self.test)
        #print("\nEnd Test args: %s\n" % str(args))

    def print_details(self):
        """Print self details."""
        print("self.failed_tests: %s" % self.failed_tests)
        print("self.suite: %s" % self.suite.__dict__)
        print("self.test: %s" % self.test.__dict__)
        print("self.conf: %s" % self.conf)
