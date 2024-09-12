"""A module to send data via HTTP POST to ElasticSearch."""

# pylint: disable=wrong-import-position
# pylint: disable=too-few-public-methods
# pylint: disable=too-many-instance-attributes
# pylint: disable=global-statement
import os
import sys
import inspect
import json
import requests
from robot.libraries.BuiltIn import BuiltIn
currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
parentdir = os.path.dirname(currentdir)
sys.path.insert(0, parentdir)
from DataGetter.keywords import Data  # pylint: disable=import-error
import tools  # pylint: disable=import-error

DEBUG_ON = False
ELASTIC = None

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
    "location": "%(location)s",
    "id": {
        "pipeline": "%(id_pipeline)s",
        "job": "%(id_job)s",
        "user": "%(id_user)s",
        "testRun": "%(id_testrun)s",
        "suite": "%(id_suite)s",
        "build": "%(id_build)s",
        "branch": "%(id_branch)s",
        "commit": "%(id_commit)s"
    },
    "url": {
        "log": "%(url_log)s",
        "output": "%(url_output)s",
        "report": "%(url_report)s",
        "screenshot": "%(url_screenshot)s",
        "path": "%(url_path)s",
        "full_log": "%(url_full_log)s",
        "quickreport": "%(url_quickreport)s"
    },
    "failedReasonRobot": "%(failedReasonRobot)s",
    "jiraData": {
        "status": "%(jiraData_status)s",
        "priority": "%(jiraData_priority)s",
        "linkedList": %(jiraData_linkedList)s,
        "linked": %(jiraData_linked)s
    }
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
        global DEBUG_ON  # pylint: disable=global-statement
        global ELASTIC
        if DEBUG_ON or not ELASTIC:
            if DEBUG_ON:
                BuiltIn().log_to_console("*** INFO: Data NOT Ingested To ELASTIC - DEBUG: True ***")
                BuiltIn().log_to_console("NOT ingested JSON: %s" % json_str)
                json_to_send = json.loads(json_str)
                BuiltIn().log_to_console("Data type: %s" % json_to_send['type'])
                if json_to_send['result'] == "FAIL":
                    BuiltIn().log_to_console("** Data failedReasonRobot: %s" %
                                             json_to_send['failedReasonRobot'])
                # BuiltIn().log_to_console("Data ingested is: %s" % json_to_send)
            elif not ELASTIC:
                BuiltIn().log_to_console(
                    "*** INFO: Data NOT Ingested To ELASTIC - ELASTIC: False ***")
            status = True
        else:
            response = requests.post(url, data=json_str, headers=headers)
            if response.status_code not in [200, 201]:
                BuiltIn().log_to_console("_send_data method. Response code %s. Reason %s. "
                                         "JSON was send:\n%s" %
                                         (response.status_code, response.reason, json_str))
            data = json.loads(response.text)
            if "result" in data:
                if "created" in data["result"] \
                        and data["_shards"]["successful"] > 0 \
                        and data["_shards"]["failed"] == 0:
                    status = True
            else:
                print(("ERROR sending data %s to ElasticSearch %s:\n%s"
                       %(json_str, url, response.text)))
            # print("Request sent to ElasticSearch: %s\n%s" % (url, json_str))
            # print("Response from ElasticSearch is: %s %s\n%s" % \
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
            else:  # Default value test
                res_type = "_doc"
        return self._send_data(result_obj.json_str, res_index, res_type)


class TestSuiteData(object):
    """A class to prepare requests to send test suite results to ElasticSearch."""

    def __init__(self, data_obj):
        self.data = data_obj
        self.time = self.data.suite.time
        self.kibana_url = ""

    def make_url_kibana(self, conf):
        """Prepare a Kibana URL according to the template."""
        kibana_start = self.time["start"] - conf["KIBANA_DASHBOARD_TIME"]
        kibana_end = self.time["end"] + conf["KIBANA_DASHBOARD_TIME"]
        url_kibana = KIBANA_DASHBOARD_URL % {
            "KIBANA_DASHBOARD_NAME": conf["KIBANA_TEST_STEP_DASHBOARD"],
            "KIBANA_FROM_Z_TIME": tools.epoch_ms_to_z_time(kibana_start),
            "KIBANA_TO_Z_TIME": tools.epoch_ms_to_z_time(kibana_end),
            "QUERY": "testRun:%s" % self.data.suite.test_run_id
        }
        self.kibana_url = url_kibana
        return url_kibana

    def make_json(self):
        """A method to prepare json object what will be send to Elastic search as result"""
        conf = self.data.conf
        # Prepare a json string according to the suite result template.
        if self.data.suite.avgResponseTime is None or self.data.suite.avgResponseTime == "":
            self.data.suite.avgResponseTime = '""'
        if self.data.suite.maxResponseTime is None or self.data.suite.maxResponseTime == "":
            self.data.suite.maxResponseTime = '""'
        if self.data.suite.failed_tests and self.data.suite.result == "FAIL":
            self.data.suite.failed_reason = tools.prepare_string_for_json(
                self.data.suite.failed_tests[0])
        json_str = ELK_TEMPLATE % {
            # Force type to testcase and testStep field as empty
            "type": "testcase", "testStep": "",
            "testRun": self.data.suite.test_run_id, "testCase": self.data.suite.ts_name,
            "description": self.data.suite.description, "jira": self.data.suite.jira[0],
            "lab": self.data.suite.lab,
            "tags": "-".join(str(_t).replace(" ", "_") for _t in sorted(self.data.suite.ts_tags)),
            "result": self.data.suite.result, "feature": self.data.suite.feature,
            "duration": str(self.time["end"] - self.time["start"]),
            "cpe": self.data.suite.cpe["id"], "track": self.data.suite.track,
            "cpeVersion": self.data.suite.cpe["version"],
            "tool": ("-".join(str(_t).replace(" ", "_") for _t in
                              sorted(self.data.suite.tools_list))).replace(",", "-"),
            "startTime": str(self.time["start"]), "endTime": str(self.time["end"]),
            "resultLink": self.make_url_kibana(conf),
            "failedReason": self.data.suite.failed_reason,
            "avgResponseTime": self.data.suite.avgResponseTime,
            "maxResponseTime": self.data.suite.maxResponseTime,
            "location": self.data.suite.location,
            "id_pipeline": self.data.suite.id_pipeline,
            "id_job": self.data.suite.id_job,
            "id_suite": self.data.suite.id_suite,
            "id_user": self.data.suite.id_user,
            "id_testrun": self.data.suite.id_testrun,
            "id_build": self.data.suite.id_build,
            "id_commit": self.data.suite.id_commit,
            "id_branch": self.data.suite.id_branch,
            "url_output": self.data.suite.url_output,
            "url_log": self.data.suite.url_log,
            "url_report": self.data.suite.url_report,
            "url_screenshot": self.data.suite.url_screenshot,
            "url_path": self.data.suite.url_path,
            "failedReasonRobot": self.data.suite.failed_reason_robot,
            "url_full_log": self.data.suite.url_full_log,
            "url_quickreport": self.data.suite.url_quickreport,
            "jiraData_status": self.data.suite.jira_data_status,
            "jiraData_priority": self.data.suite.jira_data_priority,
            "jiraData_linkedList": tools.prepare_array_dict_for_json_string(
                self.data.suite.jira_data_linked_list),
            "jiraData_linked": tools.prepare_array_dict_for_json_string(
                self.data.suite.jira_data_linked)
        }
        json_str = json_str.replace("u'", "'").replace("\n", "").replace("\\xa0", " ").strip()
        ## results_path will be use on the save and delete for results files
        results_path = "execution_artifacts/results/"
        ### THIS IS MI MUST TO KNOW IF IT IS LOCAL RUN OR E2EROBOT Jenkins Run
        if self.data.suite.url_build == "" and self.data.suite.pabot:
            BuiltIn().log_to_console("*** INFO: LOCALRUN - Running Pabot in LOCAL "
                                     "- Because Build URL is EMPTY and Pabot True ***")
            pabot_local_run = True
        else:
            pabot_local_run = False
        try:
            suite_file_present = os.path.exists("%s%s" % (results_path, "Suite.json"))
            # BuiltIn().log_to_console("\n*** DEBUG: File results/Suite.json Exist: (bool):"
            #                          "%s ***\n" % suite_file_present)
            if "GENERATE_RESULT_AND_HTML_REPORTS" in self.data.suite.ts_name:
                BuiltIn().log_to_console("\n*** DEBUG: Running GENERATE_RESULT_"
                                         "AND_HTML_REPORTS ***\n")
            if not suite_file_present:
                BuiltIn().log_to_console("\n*** INFO: CREATING results/Suite.json File as "
                                         "suite_file_present: %s"
                                         " - It should ONLY BE PRINTED ONE TIME"
                                         " ***\n" % suite_file_present)
                self.data.suite.result_json_file = dict()
                self.data.suite.result_json_file["labName"] = self.data.suite.lab
                # TODO - Include Kibana URL for the SUITE using id_suite
                # suite_data["kibanaLink"] = "TODO"
                global ELASTIC
                self.data.suite.result_json_file["elastic"] = ELASTIC
                self.data.suite.result_json_file["id"] = dict()
                self.data.suite.result_json_file["id"]["pipeline"] = self.data.suite.id_pipeline
                self.data.suite.result_json_file["id"]["suite"] = self.data.suite.id_suite
                self.data.suite.result_json_file["id"]["build"] = self.data.suite.id_build
                self.data.suite.result_json_file["id"]["commit"] = self.data.suite.id_commit
                self.data.suite.result_json_file["url"] = dict()
            # START: NOTE: Those Vars are not reliable on Pabot Run so not saved if run with Pabot
            #     BuiltIn().log_to_console("\n*** DEBUG: PABOT enable: %s *** \n" % self.pabot)
                self.data.suite.result_json_file["pabot"] = self.data.suite.pabot
                if not self.data.suite.pabot:
                    self.data.suite.result_json_file["url"]["log"] = self.data.suite.url_log
                    self.data.suite.result_json_file["cpeId"] = self.data.suite.cpe["id"]
                    self.data.suite.result_json_file["buildName"] = self.data.suite.cpe["version"]
                    self.data.suite.result_json_file["rackSlotId"] = tools.get_var_value(
                        "RACK_SLOT_ID")
                else:
                    if pabot_local_run:
                        self.data.suite.result_json_file["localRun"] = pabot_local_run
                        self.data.suite.url_full_log = "../log.html"
                    self.data.suite.result_json_file["url"]["log"] = self.data.suite.url_full_log
                    self.data.suite.result_json_file["stb_pool"] = \
                        self.data.suite.stb_pool.split(",")
            # END: NOTE: Those Vars are not reliable for Pabot Runs, not saved if run with Pabot

            # START: Saving general Suite data on execution_artifacts/results/Suite.json
                try:
                    tools.persist_data_result_json(
                        "%sSuite.json" % results_path, self.data.suite.result_json_file)
                except ValueError:
                    BuiltIn().log_to_console("\n*** ERROR: TestSuiteData - "
                                             "SAVING SUITE GENERAL DATA TO FILE "
                                             "***\n%s\n" % ValueError)
            else:
                BuiltIn().log_to_console("\n*** DEBUG: Suite.json already created - "
                                         "No Action Need ***")
            # END: Saving general Suite data on execution_artifacts/results/Suite.json

            ### Creating the test_case_data ###
            self.data.test.result_json_file = dict()
            self.data.test.result_json_file["status"] = self.data.suite.result
            self.data.test.result_json_file["name"] = self.data.suite.ts_name
            self.data.test.result_json_file["testRun"] = self.data.suite.test_run_id
            self.data.test.result_json_file["description"] = self.data.suite.description
            self.data.test.result_json_file["feature"] = self.data.suite.feature
            self.data.test.result_json_file["jira"] = self.data.suite.jira[0]
            self.data.test.result_json_file["track"] = self.data.suite.track
            self.data.test.result_json_file["execution_time"] = self.data.suite.time["end"] - \
                                                    self.data.suite.time["start"]
            self.data.test.result_json_file["testStepsList"] = self.data.suite.test_step_list
            self.data.test.result_json_file["tags"] = \
                "-".join(str(_t).replace(" ", "_") for _t in sorted(self.data.suite.ts_tags))
            self.data.test.result_json_file["cpeId"] = self.data.suite.cpe["id"]
            self.data.test.result_json_file["buildName"] = self.data.suite.cpe["version"]
            self.data.test.result_json_file["rackSlotId"] = tools.get_var_value("RACK_SLOT_ID")
            self.data.test.result_json_file["jiraData"] = {
                "status": self.data.suite.jira_data_status,
                "priority": self.data.suite.jira_data_status,
                "linkedList": self.data.suite.jira_data_linked_list,
                "linked": self.data.suite.jira_data_linked
            }
            self.data.test.result_json_file["url"] = dict()
         # TODO - Include Kibana URL for the Testscase using TestRun
         # TODO - ( Not really need it JIRA ticket,Pipeline ID, Suite ID)
            # LOCAL RUN
            if pabot_local_run:
                self.data.suite.url_log = "../pabot_results/%s/%s" \
                                     % (str(self.data.suite.original_ts_name)
                                        .replace(" ", "%20").replace("Regression.", ""),
                                        "stdout.txt")
            self.data.test.result_json_file["url"]["log"] = self.data.suite.url_log
            if self.data.suite.pabot:
                # Ex: robot\pabot_results\APP.HES-849 apps behaviour of contextual mainmenu\.txt
                BuiltIn().log_to_console("*** INFO: Test Cases Pabot Results Files Paths: %s ***"
                                         % self.data.suite.url_log.replace("stdout.txt", ""))
                self.data.test.result_json_file["url"]["stderr"] = \
                    self.data.suite.url_log.replace("stdout.txt", "stderr.txt")
        except ValueError:
            BuiltIn().log_to_console("\n*** ERROR: OCCURRED in Basic Execution"
                                     " data of RESULT_JSON_DICT: ***\n%s\n" % ValueError)
    ### SAVE results file for each TestCase file inside:
    ### execution_artifacts/results/{JIRA OR ts_name}.json
        try:
            if self.data.suite.jira is None:
                BuiltIn().log_to_console("\n*** WARN: OCCURRED JIRA_ TAG IS EMPTY"
                                         " self.data.suite.jira: ***\n%s\n" %
                                         self.data.suite.jira[0])
                tools.persist_data_result_json("%s%s.json" % (
                    results_path, self.data.suite.ts_name), self.data.test.result_json_file)
            else:
                tools.persist_data_result_json("%s%s.json" % (
                    results_path, self.data.suite.jira[0]), self.data.test.result_json_file)
        except ValueError:
            BuiltIn().log_to_console("\n\n*** ERROR: TestSuiteData -"
                                     " SAVING TESTCASE RESULT TO FILE"
                                     " ***\n%s\n" % ValueError)
     ### END: SAVE results file for each TestCase file inside:
     ### execution_artifacts/results/{JIRA OR ts_name}.json

        return json_str


class TestCaseData(object):
    """A class to prepare requests to send test case result to ElasticSearch."""

    def __init__(self, data_obj):
        self.data = data_obj
        self.time = self.data.test.time
        self.kibana_url = ""

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

    def make_json(self):
        """A method to prepare json object what will be send to Elastic search as result"""
        conf = self.data.conf
        # Prepare a json string according to the test case result template.
        result_link = tools.get_var_value("resultLink") or self.make_url_kibana(conf)
        if "/app/kibana#/dashboard/" in result_link:
            print(("XAGGET_RESULT_LINK: %s" % str(result_link)))
            result_link = result_link[result_link.find("/app/kibana#/dashboard/") + 23:
                                      len(result_link)]
        self.data.suite.cpe["version"] = tools.get_var_value("CPE_VERSION")
        if self.data.test.avgResponseTime is None or self.data.test.avgResponseTime == "":
            self.data.test.avgResponseTime = '""'
        if self.data.test.maxResponseTime is None or self.data.test.maxResponseTime == "":
            self.data.test.maxResponseTime = '""'
        json_str = ELK_TEMPLATE % {
            # Force type to teststep
            "type": "teststep",
            "testCase": self.data.suite.ts_name, "testStep": self.data.test.tc_name,
            "description": self.data.test.description, "jira": self.data.suite.jira[0],
            "feature": self.data.suite.feature, "tool": self.data.test.tool,
            "testRun": self.data.suite.test_run_id,
            "tags": "-".join(str(_t).replace(" ", "_") for _t in sorted(self.data.test.tc_tags)),
            "lab": self.data.suite.lab,
            "result": self.data.test.result, "resultLink": result_link,
            "failedReason": self.data.test.failed_reason,
            "cpe": self.data.suite.cpe["id"],
            "cpeVersion": self.data.suite.cpe["version"],
            "duration": str(self.data.test.time["end"] - self.data.test.time["start"]),
            "startTime": self.data.test.time["start"], "endTime": self.data.test.time["end"],
            "track": self.data.suite.track,
            "avgResponseTime": self.data.test.avgResponseTime,
            "maxResponseTime": self.data.test.maxResponseTime,
            "location": self.data.test.location,
            "id_pipeline": self.data.suite.id_pipeline,
            "id_job": self.data.suite.id_job,
            "id_suite": self.data.suite.id_suite,
            "id_user": self.data.suite.id_user,
            "id_testrun": self.data.suite.id_testrun,
            "id_build": self.data.suite.id_build,
            "id_commit": self.data.suite.id_commit,
            "id_branch": self.data.suite.id_branch,
            "url_output": self.data.suite.url_output,
            "url_log": self.data.suite.url_log,
            "url_report": self.data.suite.url_report,
            "url_screenshot": self.data.suite.url_screenshot,
            "url_path": self.data.test.url_path,
            "failedReasonRobot": self.data.test.failed_reason_robot,
            "url_full_log": self.data.suite.url_full_log,
            "url_quickreport": self.data.suite.url_quickreport,
            "jiraData_status": self.data.suite.jira_data_status,
            "jiraData_priority": self.data.suite.jira_data_priority,
            "jiraData_linkedList": tools.prepare_array_dict_for_json_string(
                self.data.suite.jira_data_linked_list),
            "jiraData_linked": tools.prepare_array_dict_for_json_string(
                self.data.suite.jira_data_linked)
        }
        json_str = json_str.replace("u'", "'").replace("\n", "").replace("\\xa0", " ").strip()
        try:
            test_details = dict()
            test_details["failedReason"] = tools.prepare_string_for_json(
                self.data.test.failed_reason)
            # BuiltIn().log_to_console("\nrobotError: \n%s\n" % tools.get_var_value("robotError"))
            test_details["robotError"] = tools.prepare_string_for_json(
                tools.get_var_value("robotError"))
            # BuiltIn().log_to_console("\ntest_details[robotError]: \n%s\n" %
            #                          test_details["robotError"])
            test_details["status"] = tools.prepare_string_for_json(self.data.test.result)
            test_details["name"] = tools.prepare_string_for_json(self.data.test.tc_name)
            test_details["tool"] = self.data.test.tool
            test_details["description"] = tools.prepare_string_for_json(self.data.test.description)
            test_details["screenshot_url"] = self.data.suite.url_screenshot
            test_details["tags"] = self.data.test.tc_tags
            self.data.suite.test_step_list.append(test_details)
        except ValueError:
            BuiltIn().log_to_console("\n*** ERROR: While "
                                     "adding test_details to data.suite.test_step_list ***"
                                     "\n%s\n" % ValueError)
        return json_str


class RobotListener(object):
    """A class overrides default Robot Framework listeners."""
    ROBOT_LISTENER_API_VERSION = 2
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self):
        setattr(self, "ROBOT_LIBRARY_LISTENER", self)
        self.data = Data()
        self.test_case_data_to_send = None
        self.test_suite_data_to_send = None
        self.sender_status = {"suite": None, "test": None}

    def _start_suite(self, *args):
        """A method what will be runned automaticaly by RF when test suite will be started"""
        self.data.get_start_suite_data(args)
        # print(self.data.suite.__dict__)

    def _start_test(self, *args):
        """A method what will be runned automaticaly by RF when test case will be started"""
        global ELASTIC
        if ELASTIC is None:
            ELASTIC = tools.get_var_value("ELASTIC")
            if ELASTIC == "":
                BuiltIn().log_to_console("\n*** WARN: ELASTIC Variable is Empty "
                                         "but Data will be Ingested by default ***")
                ELASTIC = True
            else:
                ELASTIC = tools.str_to_bool(ELASTIC)
            # BuiltIn().log_to_console("\nElasticSearch Ingestion: %s" % ELASTIC)
        self.data.get_start_test_data(args)
        # print(self.data.test.__dict__)

    def _end_test(self, *args):
        """A method what will be runned automaticaly by RF when test case will be done"""
        self.data.get_end_test_data(args)
        # print(self.data.test.__dict__)
        self.test_case_data_to_send = TestCaseData(self.data)
        self.data.test.json_str = self.test_case_data_to_send.make_json()
        # print(self.data.test.json_str)
        self.sender_status["test"] = DataSender(self.data.conf).send(self.data.test)

    def _end_suite(self, *args):
        """A method what will be runned automaticaly by RF when test suite will be done"""
        self.data.get_end_suite_data(args)
        # print(self.data.suite.__dict__)
        self.test_suite_data_to_send = TestSuiteData(self.data)
        self.data.suite.json_str = self.test_suite_data_to_send.make_json()
        # print(self.data.suite.json_str)
        self.sender_status["suite"] = DataSender(self.data.conf).send(self.data.suite)
        # print(self.suite.json_str)
        # print(self.sender_status)
