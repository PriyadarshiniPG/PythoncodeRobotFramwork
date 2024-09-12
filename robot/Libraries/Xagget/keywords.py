# -*- coding: utf-8 -*-

# pylint: disable=import-error
# Disabled pylint "import-error" - it was complaining: Unable to import 'robot.api',
# since Robot is not running while pylint is doing its job.
"""Implementation of Xagget library's keywords for Robot Framework.
Script triggers Xagget tests/scenarios and obtains test results.
v0.0.1 - Natallia Savelyeva: XAGGET init lib
v0.0.2 - Fernando Cobos: Adapt it to R4.13 Xagget - v4.24.1
v0.0.3 - Fernando Cobos: Add the Routers to the Recipe - Xagget Path feature supported
v0.0.4 - Vishwanand upadhyay: Added functions to retrieve to document link
        and extract data from them
v0.0.5 - Fernando Cobos: Add config - requiredState: cpeInfo.cpe_version and conf_id_cpe_version
v0.0.6 - Fernando Cobos: Add the routers fuction "executeSinglePathRouter"
v0.0.7 - Fernando Cobos: Add the routers fuction "ensureExecutedRouter"
"""

# pylint: disable=duplicate-code
import time
import json
import random
import requests
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn


RECIPE_TEMPLATE = """{
   "targets": [  
      "and",
      {  
         "functionName": "addTargetWithUUID",
         "options": {  
            "value": {  
               "name": "%(cpe)s"
            }
         },
         "id": "%(target_id)s"
      }
   ],
   "testObjects": [  
      "or",
      [  
         "and",
         %(clear)s
         {  
            "functionName": "%(function_name)s",
            "options": {  
               "value": [  
                  %(test_data)s
               ]
            },
            "id": "%(test_obj_id)s"
         }
      ]
   ],
   "lifeCycleHooks": [  
      "and"
      %(duration)s
   ],
   "routers": [
      "and"
      %(routers)s
   ],
   "config": [  
      "and",
      {  
         "functionName": "setMode",
         "options": {  
            "value": "%(mode)s"
         },
         "id": "%(conf_id)s"
      },
      {
            "functionName": "addRequiredState",
            "options": {
                "value": "cpeInfo.cpe_version"
            },
            "id": "%(conf_id_cpe_version)s"
      }
   ]
}
"""

CLEAR_TEMPLATE = """
      {
        "functionName": "clearAllTestCases",
        "options": {},
        "id": "%(clear_id)s"
      },
"""

DURATION_TEMPLATE = """,
      {  
         "functionName":"runForDuration",
         "options":{  
            "value":"%(duration)s"
         },
         "id": "%(duration_id)s"
      }
"""
#"testStepsInsidePathsRouter"
ROUTERS_TEMPLATE = """,
    {
      "functionName": %(router_function_name)s,
      "options": {%(router_options)s      },
      "id": "%(router_id)s"
    }
"""
#"ids": [
#           "HES-580",
#           "HES-476",
#           "HZN4SI-3125"
#       ],
ROUTER_TESTSTEPSINSIDEPATHSROUTER_TEMPLATE = """
        "value": {
          "ids": [
            %(paths_id_list)s
          ],
          "weightControl": {
            "multiplier": %(multiplier)s,
            "percentage": %(percentage)s
          }
        }
"""

ROUTER_EXECUTESINGLEPATHROUTER_TEMPLATE = """
        "value": {
          "id": %(path_id)s
        }
"""

ROUTER_ENSUREEXECUTEDROUTER_TEMPLATE = """
        "value": {
          "weightControl": {
            "percentage": %(percentage)s,
            "multiplier": %(multiplier)s
          },
          "executionAmountControl": {
            "minimum": %(minimum)s
          },
          "ids": [
            %(paths_id_list)s
          ],
          "shareTargets": %(shareTargets)s
        }
"""

def set_duration_str(duration):
    """A function prepares duration json block according to the template."""
    res_duration = ""
    if duration:
        res_duration = DURATION_TEMPLATE % \
            {"duration": duration, "duration_id": generate_id()}
    return res_duration

def set_routers_str(routers):
    """A function prepares routers json block according to the template."""
    res_routers = ""
    if routers:
        for router in routers:
            logger.debug("routers Xagget: %s" % routers)
            res_router_options = ""
            if "testStepsInsidePathsRouter" in router["function"]:
                if "options" in router:
                    res_router_options = ROUTER_TESTSTEPSINSIDEPATHSROUTER_TEMPLATE % \
                        {"paths_id_list": router["options"]["paths_id_list"], \
                         "multiplier": router["options"].get("multiplier", 0), \
                         "percentage": router["options"].get("percentage", 0)}
                else:
                    BuiltIn().log_to_console("\nRouter testStepsInsidePathsRouter - "
                                             "NOT OPTIONS on Element: %s" % router)
            elif "executeSinglePathRouter" in router["function"]:
                if "options" in router:
                    res_router_options = ROUTER_EXECUTESINGLEPATHROUTER_TEMPLATE % \
                                         {"path_id": router["options"]["path_id"]}
                else:
                    BuiltIn().log_to_console("\nRouter executeSinglePathRouter - "
                                             "NOT OPTIONS on Element: %s" % router)
            elif "ensureExecutedRouter" in router["function"]:
                if "options" in router:
                    res_router_options = ROUTER_ENSUREEXECUTEDROUTER_TEMPLATE % \
                        {"paths_id_list": router["options"]["paths_id_list"], \
                         "multiplier": router["options"].get("multiplier", 0), \
                         "percentage": router["options"].get("percentage", 100), \
                         "minimum": router["options"].get("minimum", -1), \
                         "shareTargets":  router["options"].get("shareTargets", "false")}
                else:
                    BuiltIn().log_to_console("\nRouter ensureExecutedRouter - "
                                             "NOT OPTIONS on Element: %s" % router)
            else:
                BuiltIn().log_to_console("\nRouter FUNCTION NOT Supported %s" % router["function"])
            if res_router_options != "":
                res_routers = res_routers + ROUTERS_TEMPLATE % \
                    {"router_function_name": router["function"], \
                     "router_options": res_router_options, "router_id": generate_id()}
            else:
                BuiltIn().log_to_console("\nRouter NOT WELL DEFINE: %s" % routers)
    return res_routers


def generate_id(mask="8-4-4-4-12", chars="abcdef0123456789"):
    """Function generates a string of a given pattern from a given charset.

    :param mask: a pattern of digits (a number of chars) and dashes (separators).
    :param chars: a charset in the form of a string of allowed symbols.

    :return: a string

    :Example:

    >>> generate_id()
    90b023e7-1e47-457f-8d69-1f54e2bbd774
    """
    res = ""
    for size in mask.split("-"):
        res += "-" + ''.join(random.choice(chars) for _ in range(int(size)))
    return res[1:]


class Xagget_Requests(object):
    """Class sends requests to XAGGET web to handle test execution
    and obtain test results from ElasticSearch.
    """

    def __init__(self, conf):
        self.conf = conf
        self.auth = (conf["XAGGET_WEBUI_USER"], conf["XAGGET_WEBUI_PASS"])
        self.sid = None
        self.repo = conf["XAGGET_REPO"]

    def refresh_session(self):
        """Method sets a session by sending GET & POST requests to XAGGET web."""
        self.sid = self.get_sid_value()
        self.set_session(self.sid)

    def get_sid_value(self):
        """Method obtains a session id from XAGGET web by sending GET request."""
        url = "http://%s:%s/socket.io/?EIO=3&transport=polling" % \
            (self.conf["XAGGET_WEBUI_HOST"], self.conf["XAGGET_WEBUI_PORT"])
        response = requests.get(url, auth=self.auth)
        json_str = response.text[response.text.find("{"):-4]
        data = json.loads(json_str)
        return data["sid"]

    def set_session(self, sid):
        """Method sets a session by sending sid value to XAGGET web via POST."""
        headers = {"Cookie": "io=%s" % sid, "Connection": "keep-alive", \
            "Accept-Encoding": "gzip, deflate, sdch", "Accept": "*/*", \
            "Accept-Language": "ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4"}
        data = "16:40/api/test-runs"
        url = "http://%s:%s/socket.io/?EIO=3&transport=polling&sid=%s" % \
            (self.conf["XAGGET_WEBUI_HOST"], self.conf["XAGGET_WEBUI_PORT"], sid)
        response = requests.post(url, data=data, headers=headers, auth=self.auth)
        return response.text

    def submit_recipe(self, json_str, repo):
        """Method submits JSON recipe of XAGGET test by sending a POST request to
        XAGGET web, parses the response text and returns a run_id of the test.

        :param json_str: a string representing JSON data of XAGGET recipe.
        :param repo: a repository name configured in XAGGET's environments.json.

        :return: test run id, returned by XAGGET web.
        """
        repo = self.conf["XAGGET_REPO"] if not repo else repo
        headers = {"Content-Type": "application/json"}
        url = "http://%s:%s/api/test-runs/%s/start" % \
            (self.conf["XAGGET_WEBUI_HOST"], self.conf["XAGGET_WEBUI_PORT"], repo)
        response = requests.post(url, data=json_str, headers=headers, auth=self.auth)
        try:
            run_id = json.loads(response.text)["testRunUUID"]
            logger.debug("XAGGET_TESTRUN_ID: %s" % str(run_id))
        except KeyError:
            BuiltIn().log_to_console(json.loads(response.text)["message"])
        # data_json = json.loads(json_str)
        # logger.debug("XaggetScenario: %s" % data_json["testObjects"][1][1]["options"]["value"][0])
        return run_id

    def get_runs(self, run_id):
        """Method requests XAGGET web to get data of latest test runs, parses
        the response text into a dictionary of all those test runs.

        :param run_id: a run id string of the XAGGET test run.

        :return: a list of latest test runs or empty list if parsing failed.
        """
        self.refresh_session()
        headers = {"Cookie": "io=%s" % self.sid, "Connection": "keep-alive", \
            "Accept-Encoding": "gzip, deflate, sdch", "Accept": "*/*", \
            "Accept-Language": "ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4"}
        data = "16:40/api/test-runs"
        url = "http://%s:%s/socket.io/?EIO=3&transport=polling&sid=%s" % \
            (self.conf["XAGGET_WEBUI_HOST"], self.conf["XAGGET_WEBUI_PORT"], self.sid)
        # Keep it for Debug
        #BuiltIn().log_to_console("\nXagget_get_runs_URL %s " % (url))
        #BuiltIn().log_to_console(
        #    "\nXagget_get_runs_URL: %s"
        #    "\nheaders: %s"
        #    "\nAuth: %s"
        #    % (url, headers, self.auth))
        response = requests.get(url, data=data, headers=headers, auth=self.auth)
        data = response.text
        if response.status_code != 200:
            self.refresh_session()
            return []
        try:
            # Keep it for Debug
            #BuiltIn().log_to_console("\nrun_id: %s" % (run_id))
            #BuiltIn().log_to_console("\ndata: %s" % (data))
            #json_str = data[data.find('["all",')+8:data.find(',{"info"')] #OLD METHOD
            init_search = '{"info":{"uuid":"'+run_id+'"}'
            end_search = "query:'Testrun:"+run_id+"')))"
            json_str = data[data.find(init_search):data.find(end_search) + 57]
            BuiltIn().log_to_console("\nXagget Test Run: %s"
                                     " - Data(get_runs): %s" % (run_id, json_str))
            if run_id not in json_str:
                return []
            struct = json.loads(json_str)
            #BuiltIn().log_to_console("\nstruct: %s"% (struct))
        except ValueError as err:
            BuiltIn().log_to_console("\nExcpetion in get_runs: %s: - status: %s"
                                     " - data: %s" % (err, response.status_code, data))
            print(("\nExcpetion in get_runs: %s: %s %s" % (err, response.status_code, data)))
            struct = []
        return struct

    def get_run(self, run_id):
        """Method requests XAGGET web to get data of latest test runs by calling
        the get_runs() method and obtains a dictionary of the required test run.

        :param run_id: a run id string of the XAGGET test run.

        :return: a dictionary containing data of the requested test run.
        """
        struct = self.get_runs(run_id)
        for item in struct:
            if "testRunUUID" in item and struct[item] == run_id:
                return item
        return []

    def get_tests(self, run_id, retries=0, interval=10):
        """Method sends GET requests to ElasticSearch to obtain test run results.

        :param run_id: a run id string of the XAGGET test run.
        :param retries: maximum number of retries, default is 0 (infinite).
        :param interval: interval in seconds between retries, default is 10.

        :return: a dictionary containing the results of the requested test run.
        """
        cols = ["name", "CPE_ID", "result", "description", "failedReason", \
                "toLogging", "cpe"]
        headers = {"Content-Type": "application/json"}
        data = {"from":0, "size":1000, "_source":cols, "query":{"query_string": \
            {"query": "Testrun : %s AND NOT result:planned" % run_id}}}
        url = "http://%s:%s/xagget_testresults*/testresults/_search?pretty" % \
            (self.conf["XAGGET_ELK_HOST"], self.conf["XAGGET_ELK_PORT"])
        tests_info = None
        i = 1
        while not tests_info:
            response = requests.get(url, data=json.dumps(data), headers=headers)
            struct = json.loads(response.text.encode('utf-8'))
            if struct["hits"]["total"] == len(struct["hits"]["hits"]):
                tests_info = struct
                break
            if i == retries:
                break
            time.sleep(interval)
            i += 1
        return tests_info

    def get_test(self, run_id, name, retries=0, interval=10):
        """Method sends GET requests to ElasticSearch to obtain test results
        by executing get_tests() method and returns a dictionary of one test.

        :param run_id: a run id string of the XAGGET test run.
        :param name: a test name.
        :param retries: maximum number of retries, default is 0 (infinite).
        :param interval: interval in seconds between retries, default is 10.

        :return: a dictionary containing the result of the requested test.
        """
        test_info = None
        i = 1
        while not test_info:
            struct = self.get_tests(run_id, retries, interval)
            for item in struct["hits"]["hits"]:
                test = item["_source"]
                if test["name"] == name:
                    test_info = test
                    break
            if i == retries:
                print("ERROR: Test NOT Found in Elasticsearch")
                break
            time.sleep(interval)
            i += 1
        return test_info


class Run(object):
    """Class to trigger XAGGET test and get the results of the test run."""

    def __init__(self):
        """The class initializer.

        Repository name should be configured in XAGGET's environments.json file.
        """
        self.repo = None
        self.recipe = None


    def run(self, conf, retries=0, interval=10):
        """Method submits JSON recipe to XAGGET web, waits until the test run
        gets completed (finished or aborted), and returns test run details
        in the form of a dictionary.

        :param conf: a dictionary of XAGGET settings (host, port, etc.).
        :param retries: maximum number of retries, default is 0 (infinite).
        :param interval: interval in seconds between retries, default is 10.

        :return: a dictionary containing the result of the XAGGET test run.
        """
        obj = Xagget_Requests(conf)
        run_id = obj.submit_recipe(self.recipe, self.repo)
        logger.debug("Xagget run_id: %s" % run_id)
        BuiltIn().log_to_console("\nXAGGET_TESTRUN_ID: %s" % run_id)
        run_info = None
        completed = ["stopped", "killed", "failed-to-start"]
        i = 1
        while not run_info:
            time.sleep(interval)
            item = obj.get_runs(run_id)
            if "processState" in item:
                BuiltIn().log_to_console(
                    "Xagget Test Run status "
                    "(item[processState]): %s" % (item["processState"]))
            if "completionState" in item:
                BuiltIn().log_to_console(
                    "Xagget Test Run status "
                    "(item[completionState]): %s \nFiredCount : %s"
                    % (item["completionState"]["resultStateCount"],
                       item["completionState"]["firedCount"]))
            if ("processState" in item and item["processState"] in completed): #\
            #or ("completionState" in item \
            #    and ("error" in item["completionState"] \
            #        or "errors" in item["completionState"])):
                run_info = item
            if i == retries:
                break
            i += 1
        return run_info


class Scenario(Run):
    """Class runs XAGGET Scenario from the repository on the given CPE (EOS)."""

    def __init__(self, repo, scenario, cpe_id, duration=None, routers=None, \
                 function_name="filterOnScenarios", mode="sequential"):
        super(Scenario, self).__init__()
        self.repo = repo
        self.scenario = scenario
        self.duration = set_duration_str(duration)
        self.routers = set_routers_str(routers)
        self.recipe = RECIPE_TEMPLATE % {"test_data": '"%s"' % scenario, \
            "function_name": function_name, "mode": mode, "clear": "", \
            "target_id": generate_id(), "test_obj_id": generate_id(), \
            "conf_id": generate_id(), "conf_id_cpe_version": generate_id(), "cpe": cpe_id, \
            "duration": self.duration, "routers": self.routers}
        # Debug to print the RECIPE ingested on Xagget
        BuiltIn().log_to_console("\nXAGGET TESTRUN RECIPE:\n%s\n" % (self.recipe))


class Test(Run):
    """Class triggers XAGGET Test from the repository on the given CPE (EOS)."""

    def __init__(self, repo, full_name, cpe_id, duration=None, routers=None, mode="sequential"):
        super(Test, self).__init__()
        self.repo = repo
        self.full_name = full_name
        self.duration = set_duration_str(duration)
        self.routers = set_routers_str(routers)
        self.recipe = RECIPE_TEMPLATE % {"test_data": '"%s"' % full_name, \
            "function_name": "filterTestCasesByName", "mode": mode, \
            "target_id": generate_id(), "test_obj_id": generate_id(), \
            "conf_id": generate_id(), "conf_id_cpe_version": generate_id(), "cpe": cpe_id, \
            "duration": "", "clear": "", "routers": self.routers}


class RawJSON(Run):
    """Class submits JSON data as an XAGGET test and runs it on the CPE (EOS)."""

    def __init__(self, json_str, cpe_id, duration=None, routers=None, mode="sequential"):
        super(RawJSON, self).__init__()
        self.json_str = json_str
        self.duration = set_duration_str(duration)
        self.routers = set_routers_str(routers)
        self.recipe = RECIPE_TEMPLATE % {"test_data": json_str, \
            "function_name": "addSingleTestStepViaJSON", "mode": mode, \
            "target_id": generate_id(), "test_obj_id": generate_id(), \
            "conf_id": generate_id(), "conf_id_cpe_version": generate_id(), \
            "cpe": cpe_id, "duration": "", \
            "clear": CLEAR_TEMPLATE % {"clear_id": generate_id()}, "routers": self.routers}


class CRAWL(Run):
    """Class runs all tests from a repository in CRAWL mode on the CPE (EOS)."""

    def __init__(self, repo, cpe_id, duration, routers=None):
        super(CRAWL, self).__init__()
        self.repo = repo
        self.cpe = cpe_id
        self.duration = set_duration_str(duration)
        self.routers = set_routers_str(routers)
        self.recipe = self._make_recipe_for_crawl()

    def _make_recipe_for_crawl(self):
        json_str = RECIPE_TEMPLATE % {"mode": "CRAWL", "test_data": "", "clear": "", \
            "function_name": "", "test_obj_id": "", "duration": self.duration, \
            "target_id": generate_id(), "conf_id": generate_id(), \
            "conf_id_cpe_version": generate_id(), "cpe": self.cpe, \
            "routers": self.routers}
        data = json.loads(json_str)
        del data["testObjects"][1][1]
        json_str = json.dumps(data)
        return json_str

class Elastic_Requests(object):
    """Class contains functions to execute elastic requests"""

    def __init__(self, conf):
        self.conf = conf
        self.elastic_host = conf["XAGGET_ELK_HOST"]
        self.elastic_port = conf["XAGGET_ELK_PORT"]
        self.test_result_host = conf["XAGGET_TEST_RESULT_ELK"]

    def get_test_result_url_from_elastic(self, testrunid, teststepname):
        """A keyword to obtain results of a test run from ElasticSearch.

                :param testRunID: the id of a test run returned by XAGGET.
                :param testStepName: test step name for which document url is required

                :return: a dictionary containing the results of the requested test run.
                """
        url = "http://%s:%s/xagget_testresult*/_search?" % (self.elastic_host, self.elastic_port)
        headers = {"Content-Type": "application/json"}
        payload = {
            "_source":  ["url.document"],
            "query": {
                "bool": {
                    "must": [
                        {
                            "match_phrase": {
                                "name": {
                                    "query": "%s" % teststepname
                                }
                            }
                        },
                        {
                            "match_phrase": {
                                "Testrun": {
                                    "query": "%s" % testrunid   #pylint: disable=R0801
                                }
                            }
                        }
                    ]
                }
            }
        }

        response = requests.post(url, data=json.dumps(payload), headers=headers)
        test_result = json.loads(response.text)["hits"]["hits"]
        document_url = ""
        try:
            document_url = test_result[0]["_source"]["url"]["document"]
        except KeyError:
            document_url = test_result[1]["_source"]["url"]["document"]
        except IndexError:
            time.sleep(60)
            self.get_test_result_url_from_elastic(testrunid, teststepname)
        except Exception as error: #pylint: disable=W0703
            BuiltIn().log_to_console("Error in Fetching Test Result URL :%s" % test_result)
            BuiltIn().log_to_console(error)

        final_url = "http://%s%s" % (self.test_result_host, document_url)
        return final_url


    def get_result_detail_based_on_key(self, documenturl, key="data"):
        """A keyword to get detail from result document based on the key.

               :param documenturl: document url from elastic.
               :param key: key for which details to fetched from the test result.

               :return: detail from result document based on the key.
               """
        BuiltIn().log_to_console(self.test_result_host)
        url = documenturl
        response = requests.get(url)
        document_data = json.loads(response.text)["result"][key]
        return document_data



class Keywords(object):
    """Keywords visible in Robot Framework."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @staticmethod
    def get_tests_results(conf, run_id, retries=0, interval=10):
        """A keyword to obtain results of a test run from ElasticSearch.

        :param conf: a dictionary with configuration settings (host, port, etc.).
        :param run_id: the id of a test run returned by XAGGET.
        :param retries: maximum number of retries, default is 0 (infinite).
        :param interval: interval in seconds between retries, default is 10.

        :return: a dictionary containing the results of the requested test run.
        """
        return Xagget_Requests(conf).get_tests(run_id, retries, interval)

    @staticmethod
    def get_test_result(conf, run_id, name="no-name", retries=0, interval=10):
        """A keyword to obtain the result of a test case in the test run.

        :param conf: a dictionary with configuration settings (host, port, etc.).
        :param run_id: the id of a test run returned by XAGGET.
        :param name: a test name, default is 'no-name' if raw JSON was submitted.
        :param retries: maximum number of retries, default is 0 (infinite).
        :param interval: interval in seconds between retries, default is 10.

        :return: a dictionary containing the result of the requested test.
        """
        return Xagget_Requests(conf).get_test(run_id, name, retries, interval)

    @staticmethod
    def run_xagget_scenario(conf, repo, scenario, cpe_id, duration=None, \
                            routers=None, function_name="filterOnScenarios", mode="sequential", \
                            retries=0, interval=10):
        """A keyword to trigger XAGGET scenario and obtain test results.

        :param conf: a dictionary with configuration settings (host, port, etc.).
        :param repo: a repository name configured in XAGGET's environments.json.
        :param scenario: a full scenario name, e.g. "fernando/EPG/EPG.json".
        :param cpe_id: the id of CPE EOS, e.g. "3C36E4-EOSSTB-003356472104".
        :param duration: test duration - None for sequential or string for CRAWL.
        :param routers: Dict with the routers, default None
        :param function_name="filterOnScenarios" it can be also "filterTestCasesByName"
        :param mode: mode of test execution - "sequential" (default) or "CRAWL".
        :param retries: maximum number of retries, default is 0 (infinite).
        :param interval: interval in seconds between retries, default is 10.

        :return: a dictionary containing the test run details.
        """
        logger.debug("Running Xagget Scenario: %s" % scenario)
        sc_obj = Scenario(repo, scenario, cpe_id, duration, routers, function_name, \
                          mode)
        return sc_obj.run(conf, retries, interval)

    @staticmethod
    def run_xagget_test(conf, repo, full_name, cpe_id, duration=None, \
                        routers=None, mode="sequential", retries=0, interval=10):
        """A keyword to trigger a particular XAGGET test and obtain test result.

        :param conf: a dictionary with configuration settings (host, port, etc.).
        :param repo: a repository name configured in XAGGET's environments.json.
        :param full_name: a test name, e.g. "natallia/menu.json::MENU - focus SEARCH".
        :param cpe_id: the id of CPE EOS, e.g. "3C36E4-EOSSTB-003356472104".
        :param duration: test duration - None for sequential or string for CRAWL.
        :param routers: Dict with the routers, default None
        :param mode: mode of test execution - "sequential" (default) or "CRAWL".
        :param retries: maximum number of retries, default is 0 (infinite).
        :param interval: interval in seconds between retries, default is 10.

        :return: a dictionary containing the test run details.
        """
        tc_obj = Test(repo, full_name, cpe_id, duration, routers, mode)
        return tc_obj.run(conf, retries, interval)

    @staticmethod
    def run_xagget_raw_json(conf, json_str, cpe_id, duration=None, \
                            routers=None, mode="sequential", retries=0, interval=10):
        """A keyword to execute JSON data as an XAGGET test and obtain results.

        :param conf: a dictionary with configuration settings (host, port, etc.).
        :param json_str: a JSON string of an XAGGET test or scenario.
        :param cpe_id: the id of CPE EOS, e.g. "3C36E4-EOSSTB-003356472104".
        :param duration: test duration - None for sequential or string for CRAWL.
        :param mode: mode of test execution - "sequential" (default) or "CRAWL".
        :param retries: maximum number of retries, default is 0 (infinite).
        :param interval: interval in seconds between retries, default is 10.

        :return: a dictionary containing the test run details.
        """
        rj_obj = RawJSON(json_str, cpe_id, duration, routers, mode)
        return rj_obj.run(conf, retries, interval)

    @staticmethod
    def run_xagget_crawl(conf, repo, cpe_id, duration, routers=None, retries=0, interval=10):
        """A keyword to run all tests from an XAGGET repo and obtain test results.

        :param conf: a dictionary with configuration settings (host, port, etc.).
        :param repo: a repository name configured in XAGGET's environments.json.
        :param cpe_id: the id of CPE EOS, e.g. "3C36E4-EOSSTB-003356472104".
        :param duration: a string representime time, e.g. "5m" or "23h".
        :param retries: maximum number of retries, default is 0 (infinite).
        :param interval: interval in seconds between retries, default is 10.

        :return: a dictionary containing the test run details.
        """
        crawl_obj = CRAWL(repo, cpe_id, duration, routers)
        return crawl_obj.run(conf, retries, interval)

    @staticmethod
    def get_test_result_url_from_elastic(conf, testrunid, teststepname):
        """A keyword to obtain results of a test run from ElasticSearch.

                :param testRunID: the id of a test run returned by XAGGET.
                :param testStepName: test step name for which document url is required

                :return: a dictionary containing the results of the requested test run.
                """
        return Elastic_Requests(conf).get_test_result_url_from_elastic(testrunid, teststepname)

    @staticmethod
    def get_result_detail_based_on_key(conf, documenturl, key="data"):
        """A keyword to get detail from result document based on the key.

               :param documenturl: document url from elastic.
               :param key: key for which details to fetched from the test result.

               :return: detail from result document based on the key.
               """
        return Elastic_Requests(conf).get_result_detail_based_on_key(documenturl, key)
