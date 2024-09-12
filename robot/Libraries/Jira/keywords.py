"""A module to Get Info from Jira using Zephyr API calls"""

# pylint: disable=wrong-import-position
# pylint: disable=wrong-import-order
# pylint: disable=too-few-public-methods
# pylint: disable=too-many-instance-attributes
# pylint: disable=W0102
# pylint: disable=W0702
import os
import sys
import inspect
import datetime
import requests
import json
import time
currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
parentdir = os.path.dirname(currentdir)
sys.path.append(parentdir)
from robot.libraries.BuiltIn import BuiltIn
from Libraries.Common.utils import CaptureResultJson


class JiraGetter(object):
    """A method to Get Data From Jira using Zephyr API calls
    Doc: https://getzephyr.docs.apiary.io/#reference"""

    # Endpoints
    JIRA_HOST = "https://jira.lgi.io"
    ZEPHYR_API_ENDPOINT = "rest/zapi/latest"
    JIRA_API_ENDPOINT = "rest/api/2"
    ZEPHYR_API_HOST = "%s/%s" % (JIRA_HOST, ZEPHYR_API_ENDPOINT)
    JIRA_API_HOST = "%s/%s" % (JIRA_HOST, JIRA_API_ENDPOINT)
    # Authorization
    USER_NAME = "techentautomatedtest"
    API_TOKEN = "dGVjaGVudGF1dG9tYXRlZHRlc3Q6d2UgY2FuIG9ubHkgc2VlIHdoYXQgd2Uga25vdw"
    DEFAULT_HEADERS = {
        "Authorization": "Basic %s" % API_TOKEN,
        "Content-Type": "application/json"}
    DEFAULT_DATA = {}

    def __init__(self):
        self.from_date = datetime.datetime.now().strftime("%d/%b/%y")
        self.to_date = (datetime.datetime.now() + datetime.timedelta(days=1)).strftime("%d/%b/%y")
        self.project_name = os.environ.get("PROJECT_NAME", "HES")
        self.project_id = self.get_project_info()["id"]
        self.build = os.environ.get("BUILD", None)
        self.environment = os.environ.get("ENVIRONMENT", None)
        self.version_label = os.environ.get("VERSION", None)
        if self.version_label:
            self.version_id = self.get_version_id()
        else:
            self.version_id = None
        self.from_date = datetime.datetime.now().strftime("%d/%b/%y")
        self.to_date = (datetime.datetime.now() + datetime.timedelta(days=1)).strftime("%d/%b/%y")
        self.test_cycle_name = os.environ.get("TEST_CYCLE_NAME", None)
        self.use_exist_test_cycle = os.environ.get("USE_EXIST_TEST_CYCLE", None)
        self.test_cycle_id = None

    @staticmethod
    def send_data(url, method="GET", headers=DEFAULT_HEADERS, data=DEFAULT_DATA):
        """A method to make API calls itself"""
        if method == "GET":
            response = requests.get(url, headers=headers)
        if method == "POST":
            response = requests.post(url, headers=headers, data=data)
        if method == "PUT":
            response = requests.put(url, headers=headers, data=data)
        if method == "DELETE":
            response = requests.delete(url, headers=headers)
        if response.status_code not in [200, 201]:
            BuiltIn().log_to_console("URL: %s. Method: %s. Status code: %s. Reason: %s" % (
                url, method, response.status_code, response.reason))
            raise Exception("Unexpected status code. Text: %s" % response.text)
        response_json = response.json()
        return response_json

    def get_filter_info(self, filter_id):
        """A method to get info of filter - Using JIRA_API_HOST
        Ex: https://jira.lgi.io/rest/api/2/filter/100944
        :filter_id filter id to query info
        :return Data returned by filter id query
        """
        url = "%s/filter/%s" % (self.JIRA_API_HOST, filter_id)
        return self.send_data(url=url)

    def get_filter_search_url(self, filter_id):
        """A method to get info of filter
        Ex: https://jira.lgi.io/rest/api/2/filter/100944 and get "searchUrl"  field
        :filter_id filter id to query info and get the filter Search URL
        :return Search URL filter id query (NOTE: Using JIRA API no Zephyr)
        """
        return_value = None
        filter_info = self.get_filter_info(filter_id)
        if "searchUrl" in filter_info:
            return_value = filter_info["searchUrl"]
        return return_value

    def get_query_info_from_filter_id(self, filter_id):
        """A method to get info of the search query of the filter filter
        Ex: https://jira.lgi.io/rest/api/2/filter/100944 and get "searchUrl"  field
        then make a Jira Query to that SearchUrl
        NOTE: Using JIRA API no Zephyr
        :filter_id filter id to query info and get the filter Search URL
        :return Search URL filter ID query info
        """
        search_url = self.get_filter_search_url(filter_id)
        return self.send_data(url=search_url)

    def get_info_from_jql(self, jql):
        """A method to get all info from jql query string"""
        search_url = "%s/search?jql=%s" % (self.JIRA_API_HOST, jql)
        return self.send_data(url=search_url)

    def get_linked_tickets_dict_from_filter_id(self, filter_id):
        """A method to get info of the search query of the filter filter
        Ex: https://jira.lgi.io/rest/api/2/filter/100944 and get "searchUrl"  field
        then make a Jira Query to that SearchUrl
        :filter_id filter id to query info and get the filter Search URL
        :return Dict with all tickets + linked ticket by type
            # https://jira.lgi.io/rest/api/2/filter/100944
            ## extra: # filter: 'HZN4+Automated+E2E+Regression+tests' => project = HES AND labels
            ## in (regression-set, Offshorable, NonOffshorable) AND type = Test
            ## AND "Test Automation" = "Automated test RF"
            ## "jql": "issuefunction in linkedIssuesOf(\"filter = 'HZN4 Automated E2E Regression
            ## tests'\") AND issuetype in (Bug, Defect) AND status not in (Done, Closed, Deferred,
            ## Rejected)",
            ## "searchUrl": "https://jira.lgi.io/rest/api/2/search?jql=issuefunction+in+
            ## linkedIssuesOf(%22filter+%3D+'HZN4+Automated+E2E+Regression+tests'%22)+AND
            ## +issuetype+in+(Bug,+Defect)+AND+status+not+in+(Done,+Closed,+Deferred,+Rejected)",
        """
        query_info = self.get_query_info_from_filter_id(filter_id)
        linked_tickets_dict = self.get_linked_tickets_dict_from_query_info(query_info)
        return linked_tickets_dict

    @staticmethod
    def get_linked_tickets_dict_from_query_info(query_info):
        """A method to create a dict with all the tickets returned + all linked tickets by type
        :query_info Data of the query from Jira
        :return DDict with all tickets + linked ticket by type
        """
        jira_linked = dict()
        # BuiltIn().log_to_console("*** DEBUG: query_info[issues]:\n%s" % query_info["issues"])
        jira_ticket_url = "https://jira.lgi.io/browse/"
        for issue in query_info["issues"]:
            if "key" in issue and "fields" in issue and "issuetype" in issue["fields"]:
                t = issue["key"]
                # BuiltIn().log_to_console("*** DEBUG: t: %s" % t)
                i_fields = issue["fields"]
                # BuiltIn().log_to_console("*** DEBUG: i_fields: \n%s\n" % i_fields)
                if "name" in i_fields["issuetype"]:
                    t_type = i_fields["issuetype"]["name"]
                    # BuiltIn().log_to_console("*** DEBUG: t_type: %s" % t_type)
                    if t_type not in jira_linked:
                        jira_linked[t_type] = dict()
                    jira_linked[t_type][t] = {"jira": t, "url": "%s%s" % (jira_ticket_url, t)}
                    jira_linked[t_type][t]["type"] = t_type
                    # BuiltIn().log_to_console("*** DEBUG: jira_linked: \n%s\n" % jira_linked)
                    try:
                        if "status" in i_fields and "name" in i_fields["status"]:
                            jira_linked[t_type][t]["status"] = i_fields["status"]["name"]
                        if "reporter" in i_fields and i_fields["reporter"] and\
                                "displayName" in i_fields["reporter"]:
                            jira_linked[t_type][t]["reporter"] = \
                                i_fields["reporter"]["displayName"]
                        try:
                            if "assignee" in i_fields and i_fields["assignee"] and\
                                    "displayName" in i_fields["assignee"]:
                                jira_linked[t_type][t]["assignee"] = \
                                    i_fields["assignee"]["displayName"]
                                # BuiltIn().log_to_console("*** DEBUG: jira_linked"
                                #                          "[t_type][t][assignee]: \n%s\n"
                                #                          % jira_linked[t_type][t]["assignee"])
                        except:
                            BuiltIn().log_to_console(
                                "*** ERROR: Getting assignee from %s[fields] ***" % t)
                        if "priority" in i_fields and "name" in i_fields["priority"]:
                            jira_linked[t_type][t]["priority"] = i_fields["priority"]["name"]
                        try:
                            if "summary" in i_fields:
                                jira_linked[t_type][t]["summary"] = i_fields["summary"].\
                                    replace('"', '').replace("'", "").replace("\\n", "").\
                                    replace("\\", "")
                        except:
                            BuiltIn().log_to_console(
                                "*** ERROR: Getting summary from %s[fields] ***" % t)
                        if "project" in i_fields and "key" in i_fields["project"]:
                            jira_linked[t_type][t]["project"] = i_fields["project"]["key"]
                            # jira_linked[t_type][t]["project"] = \
                            # {"name": i_fields["project"]["name"],
                            # "key": i_fields["project"]["key"],
                            #  "id": i_fields["project"]["id"]}
                        try:
                            if "labels" in i_fields:
                                jira_linked[t_type][t]["labels"] = i_fields["labels"]
                        except:
                            BuiltIn().log_to_console(
                                "*** ERROR: Getting Labels from %s[fields] ***" % t)
                    except:
                        BuiltIn().log_to_console("*** ERROR: BASIC DATA FROM t: %s - "
                                                 "i_fields: \n%s\n" % (t, i_fields))
                    try:
                        if "issuelinks" in i_fields:
                            for i_linked in i_fields["issuelinks"]:
                                if "type" in i_linked and "name" in i_linked["type"]:
                                    # "name": "Blocking"
                                    # "outward": "blocks",
                                    if "linked" not in jira_linked[t_type][t]:
                                        jira_linked[t_type][t]["linked"] = dict()
                                    link_type = i_linked["type"]["name"].lower()
                                    if link_type not in jira_linked[t_type][t]["linked"]:
                                        jira_linked[t_type][t]["linked"][link_type] = dict()
                                    if "outwardIssue" in i_linked \
                                            and "key" in i_linked["outwardIssue"]:
                                        linked_t = i_linked["outwardIssue"]["key"]
                                        outward_issue = dict()
                                        if "fields" in i_linked["outwardIssue"]:
                                            outward_fields = i_linked["outwardIssue"]["fields"]
                                            outward_issue["status"] = \
                                                outward_fields["status"]["name"]
                                            outward_issue["priority"] = \
                                                outward_fields["priority"]["name"]
                                            outward_issue["summary"] = \
                                                outward_fields["summary"].\
                                                    replace('"', '').replace("'", "").\
                                                    replace("\\n", "").replace("\\", "")
                                            if "issuetype" in outward_fields and\
                                                    "name" in outward_fields["issuetype"]:
                                                outward_fields["type"] = \
                                                    outward_fields["issuetype"]["name"]
                                        jira_linked[t_type][t]["linked"][link_type][linked_t] = \
                                            outward_issue
                    except:
                        BuiltIn().log_to_console("*** ERROR: issuelinks in i_fields ***")
                else:
                    BuiltIn().log_to_console("*** ERROR: NOT name in i_fields[issuetype] ***")
            else:
                BuiltIn().log_to_console("*** ERROR: NOT key in issue OR  fields in issue OR "
                                         "issuetype in issue[fields]***")

        return jira_linked

    @staticmethod
    def get_linked_tickets_dict_for_one_from_all_tickets_info(all_jira_linked,
                                                              ticket_to_search="HES-7397"):
        """A method to create a dict with all linked tickets for one ticket
        :ticket_to_search Jira ticket to get the linked tickets + type + status
        :return Dict with linked ticket + type + status for the ticket argument
            #   Labels
            #    Sanity_Automation  : If test case is part of the sanity suite
            #    Regression_Automation : If test case is part of the regression suite
            #    API_Automation: If test case is part of the API test suite
            #    Airflow_Automation : If test case is part of the airflow test suite
            #    for tenant:E2ESI_QA_{TEANANT}_{ENV}
            #    eg.   E2ESI_QA_NL_PROD
            #    E2ESI_QA_NL_PREPROD
            #    E2ESI_QA_SUPERSET
            ##  Filter By Labels to be sure the ticket linked is related with the
            ##  environment/lab where testscase is running
        """
        t_linked = dict()
        for ticket_type in list(all_jira_linked.values()):
            for t_key, t in list(ticket_type.items()):
                for link_type in list(t["linked"].values()):
                    if ticket_to_search in link_type:
                        if ticket_to_search not in t_linked:
                            t_linked[ticket_to_search] = dict()
                            t_linked[ticket_to_search]["linked"] = dict()
                        t_copy = dict(t)
                        t_copy.pop("linked") #NOTE: REMOVE THE "linked" from t before assign it
                        t_linked[ticket_to_search]["linked"][t_key] = t_copy
                        if "status" not in t_linked[ticket_to_search] \
                                and "status" in link_type[ticket_to_search]:
                            t_linked[ticket_to_search]["status"] = \
                                link_type[ticket_to_search]["status"]
                        if "priority" not in t_linked[ticket_to_search] \
                                and "priority" in link_type[ticket_to_search]:
                            t_linked[ticket_to_search]["priority"] = \
                                link_type[ticket_to_search]["priority"]
                        if "assignee" not in t_linked[ticket_to_search] \
                                and "assignee" in link_type[ticket_to_search]:
                            t_linked[ticket_to_search]["assignee"] = \
                                link_type[ticket_to_search]["assignee"]
                        if "reporter" not in t_linked[ticket_to_search] \
                                and "reporter" in link_type[ticket_to_search]:
                            t_linked[ticket_to_search]["reporter"] = \
                                link_type[ticket_to_search]["reporter"]
                        if "type" not in t_linked[ticket_to_search] \
                                and "type" in link_type[ticket_to_search]:
                            t_linked[ticket_to_search]["type"] = \
                                link_type[ticket_to_search]["type"]
        return t_linked

    def get_and_save_data_file_with_all_linked_tickets_from_project(self, project_name="HES",
                                                                    file_modif_hours=24):
        """A method to save a dict all linked tickets for project
        :project_name: key name of the project in JIRA
        :file_older_hours: Hours that the file will not be modif
        :return true or false if save is success
        """
        ## project_jira_filter_id will is a dictionary of the Jira Filters Id depends on project
        project_jira_filter_id = {"HES": "100944"}
        if project_name in project_jira_filter_id:
            BuiltIn().log_to_console("\n*** INFO: Project %s - jira_filer_id: %s "
                                     "***" % (project_name, project_jira_filter_id[project_name]))
            data_file_saved = \
                self.get_and_save_data_file_with_all_linked_tickets_from_project_and_filter_id(
                    project_name, project_jira_filter_id[project_name], file_modif_hours)
            BuiltIn().log_to_console("*** DEBUG: data_file_saved %s ***" % data_file_saved)
            return data_file_saved

        BuiltIn().log_to_console("*** ERROR: Project %s - is not on %s "
                                 "***" % (project_name, project_jira_filter_id))
        return False

    def get_and_save_data_file_with_all_linked_tickets_from_project_and_filter_id(
            self, project_name="HES", jira_filter_id="100944", file_modif_hours=24):
        """A method to create a dict with all linked tickets for one ticket
        :jira_filter_id: filter id of Jira from were we get all the data for JIRA API
        :file_older_hours: Hours that the file will not be modif
        :return True or False if Dict with all data queried has been saved or not
        """
        return_bool = False
        try:
            project_linked_deftec_filename = "%s_linked_defects.json" % project_name
            path_to_linked_defects_file = "%s%s" % ("./resources/jira/",
                                                    project_linked_deftec_filename)
            query_jira_file_present = os.path.exists(path_to_linked_defects_file)
            # BuiltIn().log_to_console("*** DEBUG: query_jira_file_present: %s ***"
            #                          % query_jira_file_present)
            file_to_modif = False
            if query_jira_file_present:
                file_to_modif = CaptureResultJson.is_file_older_than_x_hours(
                    path_to_linked_defects_file, file_modif_hours)
            BuiltIn().log_to_console("*** DEBUG: file_to_modif - older_than_%sh: %s ***"
                                     % (file_modif_hours, file_to_modif))
            # We added here the condition if file is older than file_modif_hours var (Default: 24h)
            if not query_jira_file_present or file_to_modif:
                BuiltIn().log_to_console("*** INFO: Making Jira Query (filter_id: %s) "
                                         "& saving data to %s File ***"
                                         % (jira_filter_id, path_to_linked_defects_file))
                query_info = self.get_query_info_from_filter_id(jira_filter_id)
                # CLEAN ALL THE customfield_ On data got from filter query before save file
                for k in list(query_info.keys()):
                    if k.startswith('customfield_'):
                        query_info.pop(k)
                if "issues" in query_info:
                    for issue in query_info["issues"]:
                        for k in list(issue["fields"].keys()):
                            if k.startswith('customfield_'):
                                issue["fields"].pop(k)
                return_bool = CaptureResultJson.save_json_to_file(path_to_linked_defects_file,
                                                                  query_info)
            else:
                BuiltIn().log_to_console("*** WARN: %s modify in last %sh: %s ***"
                                         % (path_to_linked_defects_file, file_modif_hours,
                                            file_to_modif))
        except:
            BuiltIn().log_to_console("*** ERROR: Saving Jira data query in %s_linked_defects.json "
                                     "with jira_filter_id: %s  ***"
                                     % (project_name, jira_filter_id))
        return return_bool

    def get_all_linked_tickets_from_data_file(self, project_name="HES"):
        """A method to create a dict with all linked tickets for one ticket
        :project_name: key name of the project in JIRA
        :return Dict with ALL linked tickets
        """
        linked_tickets_dict = None
        try:
            project_linked_defect_filename = "%s_linked_defects.json" % project_name
            path_to_linked_defects_file = "%s%s" % ("./resources/jira/",
                                                    project_linked_defect_filename)
            # BuiltIn().log_to_console("*** DEBUG: path_to_linked_defects_file: %s "
            #                          " ***" % path_to_linked_defects_file)
            query_jira_file_present = os.path.exists(path_to_linked_defects_file)
            # BuiltIn().log_to_console("*** DEBUG: "
            #                          "File is present?: %s ***" % query_jira_file_present)
            if query_jira_file_present:
                query_info = CaptureResultJson.read_json_from_file(path_to_linked_defects_file)
                # BuiltIn().log_to_console("*** DEBUG: query_info:\n%s\n" % query_info)
                linked_tickets_dict = self.get_linked_tickets_dict_from_query_info(query_info)
                # BuiltIn().log_to_console("*** DEBUG: linked_tickets_dict"
                #                          ":\n%s\n" % linked_tickets_dict)
        except:
            BuiltIn().log_to_console("*** ERROR: get_all_linked_tickets_from_data_file ***")
        return linked_tickets_dict

    def get_linked_tickets_for_one_ticket_from_data_file(self, project_name="HES",
                                                         ticket_to_search="HES-7397"):
        """A method to create a dict with all linked tickets for one ticket
        :project_name
        :ticket_to_search Jira ticket to get the linked tickets + type + status
        :return Dict with linked ticket + type + status for the ticket argument
        """
        t_linked = None
        linked_tickets_dict = self.get_all_linked_tickets_from_data_file(project_name)
        if linked_tickets_dict:
            t_linked = self.get_linked_tickets_dict_for_one_from_all_tickets_info(
                linked_tickets_dict, ticket_to_search)
            # BuiltIn().log_to_console("*** DEBUG: t_linked:\n%s\n\n" % t_linked)
        return t_linked

    def clone_latest_test_cycle(self):
        """A method to clone latst test cycle inside given version (self.version)"""
        if not self.test_cycle_name:
            raise Exception("Please define 'TEST_CYCLE_NAME' environment variable")
        BuiltIn().log_to_console("I'm going to clone latest test cycle ...")
        last_test_cycle_id = self.get_latest_test_cycle()
        self.create_test_cycle(
            name=self.test_cycle_name, cloned_cycle_id=last_test_cycle_id)
        return self.get_latest_test_cycle()

    def set_test_case_execution_status(self, issue_key, status="PASS"):
        """Main method, used to update test results in Jira
        All codes here https://jira.lgi.io/rest/zapi/latest/execution?issueId=629950
        """
        if not self.test_cycle_name or not self.use_exist_test_cycle:
            raise Exception("Please define 'TEST_CYCLE_NAME' and 'USE_EXIST_TEST_CYCLE' "
                            "environment variables")
        status_codes = {
            "PASS": "1",
            "FAIL": "2",
            "WORK IN PROGRESS": "3",
            "NOT TESTED": "6",
            "N/A": "8",
            "SCHEDULED": "-1"
        }
        if self.use_exist_test_cycle == "True":
            self.test_cycle_id = self.get_test_cycle_id()
        else:
            self.test_cycle_name = "%s from %s" % (
                self.test_cycle_name,
                datetime.datetime.now().strftime('%Y-%m-%d %H:%M')
            )
            self.clone_latest_test_cycle()
            self.test_cycle_id = self.get_latest_test_cycle()
            os.environ["USE_EXIST_TEST_CYCLE"] = "True"
            os.environ["TEST_CYCLE_NAME"] = self.test_cycle_name

        issue_id = self.get_issue_id_by_key(issue_key)
        execution_id = self.get_issue_execution_id(issue_id)
        url = "%s/execution/%s/execute" % (self.ZEPHYR_API_HOST, execution_id)
        data = {"status": status_codes[status.upper()]}
        data = json.dumps(data)
        json_result = self.send_data(url=url, data=data, method="PUT")
        print(("Execution result of %s has been updated in Jira" % issue_key))
        return json_result

    def add_issue_to_test_cycle(self, issue_key):
        """A method to add given issue to test cycle (self.test_cycle_id)"""
        if not self.version_id:
            raise Exception("Please define 'VERSION' environment variable")
        data = {
            "issues": [issue_key],
            "versionId": self.version_id,
            "cycleId": self.test_cycle_id,
            "projectId": self.project_id,
            "method": "1",
            "assigneeType": "assignee",
            "assignee": self.USER_NAME
        }
        data = json.dumps(data)
        url = "%s/execution/addTestsToCycle" % self.ZEPHYR_API_HOST
        self.send_data(url=url, data=data, method="POST")
        return True

    def get_test_cycle_info(self):
        """A method to get info of test cycle (self.test_cycle_id)"""
        url = "%s/cycle/%s" % (
            self.ZEPHYR_API_HOST, self.test_cycle_id)
        return self.send_data(url=url)

    def get_test_cycle_id(self):
        """A method to get test cycle id based on test cycle name (self.test_cycle_name)"""
        if not self.test_cycle_name or not self.version_id:
            raise Exception("Please define 'TEST_CYCLE_NAME' and 'VERSION' environment variables")
        cycle_id = ""
        url = "%s/cycle?projectId=%s&versionId=%s" % (
            self.ZEPHYR_API_HOST, self.project_id, self.version_id)
        cycles = self.send_data(url=url)
        for id_key, cycle_details in list(cycles.items()):
            if id_key in ["-1", "recordsCount"]:
                continue
            if self.test_cycle_name == cycle_details["name"]:
                cycle_id = id_key
        return cycle_id

    def get_project_info(self):
        """A method to get info of current project (self.project_name)"""
        url = "%s/project/%s" % (
            self.JIRA_API_HOST, self.project_name)
        return self.send_data(url=url)

    def get_test_cycles(self):
        """A method to get all test cycles inside current version (self.version_id)"""
        if not self.version_id:
            raise Exception("Please define 'VERSION' environment variable")
        url = "%s/cycle?projectId=%s&versionId=%s" % (
            self.ZEPHYR_API_HOST, self.project_id, self.version_id)
        return self.send_data(url=url)

    def get_test_cycle_ids(self):
        """A method to get all test cycles IDs inside current version (self.version_id)"""
        response_json = self.get_test_cycles()
        test_cycles = list(response_json.keys())
        ignore_values = ["recordsCount", "-1"]
        test_cycles = [str(version) for version in test_cycles if str(version) not in ignore_values]
        return test_cycles

    def get_latest_test_cycle(self):
        """A method to get ID of the latest test cycle inside current version (self.version_id)"""
        return sorted(self.get_test_cycle_ids())[-1]

    def create_test_cycle(self, name, cloned_cycle_id=""):
        """A method to create test cycle inside current version (elf.version_id)"""
        cycle = "%s/cycle" % self.ZEPHYR_API_HOST
        if not self.environment or not self.build:
            raise Exception("Please define 'ENVIRONMENT' and 'BUILD' environment variables")
        data = {
            "clonedCycleId": cloned_cycle_id,
            "name": name,
            "build": self.build,
            "environment": self.environment,
            "description": "",
            "startDate": self.from_date,
            "endDate": self.to_date,
            "projectId": self.project_id,
            "versionId": self.version_id
        }
        data = json.dumps(data)
        response_json = self.send_data(url=cycle, method="POST", data=data)
        return response_json

    def get_all_projects(self):
        """A method to get all Jira projects"""
        url = "%s/util/project-list" % self.ZEPHYR_API_HOST
        response_json = self.send_data(url)
        return response_json

    def get_issue_id_by_key(self, issue_key):
        """A method to get issue id based on given issue key (as HES-105 for instance)"""
        search_url = "%s/search?jql=key=%s" % (self.JIRA_API_HOST, issue_key)
        json_response = self.send_data(url=search_url)
        issue_id = json_response["issues"][0]["id"]
        return issue_id

    def get_issue_key_by_id(self, issue_id):
        """A method to get issue key (as HES-105 for instance) based on given issue id"""
        search_url = "%s/search?jql=id=%s" % (self.JIRA_API_HOST, issue_id)
        json_response = self.send_data(url=search_url)
        issue_id = json_response["issues"][0]["key"]
        return issue_id

    def get_issue_execution_id(self, issue_id, add_to_cycle_if_necessary=True):
        """A method to get execution id inside current version (self.version_id) and
        current test cycle (self.test_cycle_id) based on given issue id"""
        issue_key = self.get_issue_key_by_id(issue_id)
        execution_id = ""
        url = "%s/execution?issueId=%s&cycleId=%s" % (
            self.ZEPHYR_API_HOST, issue_id, self.test_cycle_id)
        json_response = self.send_data(url=url)
        if json_response["executions"]:
            execution_id = json_response["executions"][0]["id"]

        if not execution_id and add_to_cycle_if_necessary:
            test_cycle_info = self.get_test_cycle_info()
            test_cycle_name = test_cycle_info["name"]
            test_cycle_release = test_cycle_info["versionName"]
            print(("I'm going to add test %s to test cycle \"%s\" of %s ..." % (
                issue_key, test_cycle_name, test_cycle_release)))
            self.add_issue_to_test_cycle(issue_key)
            time.sleep(5)
            # Recursion is here
            execution_id = self.get_issue_execution_id(issue_id, add_to_cycle_if_necessary=False)
        if not execution_id:
            raise Exception("execution_id was not detected. URL: %s. Issue ID: %s. Cycle ID: %s" % (
                url, issue_id, self.test_cycle_id))
        return execution_id

    def get_all_versions(self):
        """A method to get all versions inside current project (self.project_id)"""
        url = "%s/util/versionBoard-list?projectId=%s" % (
            self.ZEPHYR_API_HOST, self.project_id)
        response_json = self.send_data(url)
        return response_json

    def get_version_id(self, version_type="unreleasedVersions"):
        """A method to get version id inside current project (self.project_id)
        based on version lanel (as R21.03 for instance, stored in self.version_label)"""
        if not self.version_label:
            raise Exception("Please define 'VERSION' environment variable")
        version_id = ""
        versions_response = self.get_all_versions()
        for version in versions_response[version_type]:
            if version["label"] == self.version_label:
                version_id = version["value"]
        return version_id

    def remove_test_cycles_from_particular_version(self, version_id,
                                                   cycle_name_pattern="(auto created)"):
        """A helpfull method to remove "auto created" test cycles under particular version"

        :param version_id: id if the version, like V4.22
        :param cycle_name_pattern: string patter, what exist in every test cycle
        what needs to be removed
        """
        get_url = "%s/cycle?projectId=%s&versionId=%s" % (
            self.ZEPHYR_API_HOST, self.project_id, version_id)
        cycle = self.send_data(get_url)
        executions_ids = list(cycle.keys())
        ids_to_remove = []
        for exec_id in executions_ids:
            if exec_id in ["recordsCount", "-1"]:
                continue
            name = cycle[exec_id]["name"]
            if cycle_name_pattern in name:
                ids_to_remove.append(exec_id)

        for id_to_remove in ids_to_remove:
            remove_url = "%s/cycle/%s" % (self.ZEPHYR_API_HOST, id_to_remove)
            self.send_data(url=remove_url, method="DELETE")
            time.sleep(5)
            print("%s removed" % id_to_remove)
