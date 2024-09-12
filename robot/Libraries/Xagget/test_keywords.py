"""Unit tests of Xagget library's keywords for Robot Framework.

Tests use mock module and do not send HTTP requests to real servers.
The global function debug() can be used for testing real requests.
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
import re
import json
import unittest
try:
    import mock
except ImportError:
    import unittest.mock as mock
from .keywords import Xagget_Requests, Keywords, Elastic_Requests

REPO = "cto_sr51ag"
SCENARIO = "natallia/menu.json"
TEST_NAME = "MENU - focus SEARCH"
CPE_ID = "3C36E4-EOSSTB-003356463905"
RUN_ID = "e0c14c78-0276-4505-9a6b-d6ca0b9f6840"
SID = "E69R5iruhXrs23lsAARs"

CONF_ITC = {
    "XAGGET_WEBUI_HOST": "10.64.13.180",
    "XAGGET_WEBUI_PORT": 80,
    "XAGGET_WEBUI_USER": "vimmink",
    "XAGGET_WEBUI_PASS": "xaggetvi",
    "XAGGET_ELK_HOST": "10.64.13.179",
    "XAGGET_ELK_PORT": 9200,
    "XAGGET_REPO": "cto_sr51ag",
}

CONF_OBO_LAB = {
    "XAGGET_WEBUI_HOST": "172.30.108.11",
    "XAGGET_WEBUI_PORT": 1337,
    "XAGGET_WEBUI_USER": "vimmink",
    "XAGGET_WEBUI_PASS": "xaggetvi",
    "XAGGET_ELK_HOST": "172.30.94.221",
    "XAGGET_ELK_PORT": 9200,
    "XAGGET_REPO": "cto_sr51ag",
}

CONF = {
    "XAGGET_WEBUI_HOST": "127.0.0.1",
    "XAGGET_WEBUI_PORT": 1337,
    "XAGGET_WEBUI_USER": "vimmink",
    "XAGGET_WEBUI_PASS": "xaggetvi",
    "XAGGET_ELK_HOST": "127.0.0.1",
    "XAGGET_ELK_PORT": 9200,
    "XAGGET_REPO": "cto_sr51ag",
    "XAGGET_TEST_RESULT_ELK": "172.30.108.20"
}

SAMPLE_ELK_RESPONSE = """{
  "took" : 8,
  "timed_out" : false,
  "_shards" : {
    "total" : 75,
    "successful" : 75,
    "failed" : 0
  },
  "hits" : {
    "total" : 2,
    "max_score" : 8.702067,
    "hits" : [
      {
        "_index" : "xagget_testresults-staging-v2-2017.06.16-000014",
        "_type" : "testresults",
        "_id" : "AVy_RUp8BdMq9LJkt2_8",
        "_score" : 8.702067,
        "_source" : {
          "result" : "passed",
          "name" : "PLAYER - Compare Time of the player (compare with cache value)",
          "description" : "PLAYER - Compare Time of the player (compare with cache value)",
          "CPE_ID" : "3C36E4-EOSSTB-003356472104",
          "failedReason" : ""
        }
      },
      {
        "_index" : "xagget_testresults-staging-v2-2017.06.16-000014",
        "_type" : "testresults",
        "_id" : "AVy_RUSJBdMq9LJkt2_2",
        "_score" : 8.179424,
        "_source" : {
          "result" : "passed",
          "name" : "PLAYER - Take player current time & save to cache",
          "description" : "PLAYER - Take player current time & save to cache",
          "CPE_ID" : "3C36E4-EOSSTB-003356472104",
          "failedReason" : ""
        }
      }
    ]
  }
}"""

SAMPLE_WEBUI_RESPONSE = '17:40/api/test-runs,1079061:42' + \
'/api/test-runs,["all",[{"info":{"uuid":"e0c14c78-0276-4505-9a6b-d6ca0b9f6840"},' + \
'"testRunUUID":"e0c14c78-0276-4505-9a6b-d6ca0b9f6840",' + \
'"environmentId":"eos-sr51","processState":"stopped","completionState":' + \
'{"firedCount":0,"resultStateCount":{},"startTime":"2017-06-16T15:20:18.622Z",' + \
'"errors":{"fatal":0,"expired":1220},"modifiedAt":"2017-06-17T11:46:25.374Z"},' + \
'"parameters":{"targets":[{"type":"uuid","name":"3C36E4-EOSSTB-003356429203"}],' + \
'"lifecycleChecks":{"duration":["23h"]},"type":"crawl","data":{"storedDispatch":' + \
'{"disabled":false,"name":"CRAWL SR 21 - STB5 LAB OBO","environmentId":' + \
'"lgi-eos-sr21","startRecipe":["and",{"functionName":"addCRON","options":' + \
'{"value":"40 7 * * *"},"id":"1dcc7e6b-d7bb-4347-bed0-961a3e35516a"}],' + \
'"uuid":"27a0f121-eb94-4147-98d8-d95bd91671cb"}}},"monitorUrl":' + \
'"http://10.64.13.179:5601/app/kibana#/dashboard/xagget?_g=(refreshInterval:' + \
'(display:\'30%20seconds\',pause:!t,section:1,value:5000),time:' + \
'(from:\'2017-06-16T15:20:18.622Z\',mode:absolute,to:\'now\'))&_a=(query:' + \
'(query_string:(analyze_wildcard:!t,query:\'Testrun:' + \
'e0c14c78-0276-4505-9a6b-d6ca0b9f6840\')))"},{"info":{"uuid":' + \
'"ce06aac4-8fa8-4e28-8a8d-94762eb57e53"},"testRunUUID":' + \
'"07ca9377-cfbb-49cc-97f0-6687850721e31","environmentId":"lgi-eos-sr21",' + \
'"processState":"stopped","completionState":{"firedCount":1052,"resultStateCount":' + \
'{"skipped":790,"passed":134,"actions-failed":22,"failed":78,"data-failed":21,' + \
'"pre-requirements-failed":2,"data-missing":5},"startTime":' + \
'"2017-06-18T06:00:37.976Z","modifiedAt":"2017-06-19T05:41:08.639Z"},"parameters":' + \
'{"targets":[{"type":"uuid","name":"3C36E4-EOSSTB-003356463905"}],' + \
'"lifecycleChecks":{"duration":["23h"]},"type":"crawl","data":{"storedDispatch":' + \
'{"disabled":null,"name":"CRAWL SR 21 - STB7 LAB UPCLESS","environmentId":' + \
'"lgi-eos-sr21","startRecipe":["and",{"functionName":"addCRON","options":' + \
'{"value":"0 8 * * *"},"id":"4370c743-38c3-4ca6-8cf9-bcc5f7d93a49"}],"uuid":' + \
'"f0b25e66-49e8-4fc4-90cf-9f4280668d4e"}}},"monitorUrl":' + \
'"http://10.64.13.179:5601/app/kibana#/dashboard/xagget?_g=(refreshInterval:' + \
'(display:\'30%20seconds\',pause:!t,section:1,value:5000),time:(from:' + \
'\'2017-06-18T06:00:37.976Z\',mode:absolute,to:\'now\'))&_a=(query:(query_string:' + \
'(analyze_wildcard:!t,query:\'Testrun:ce06aac4-8fa8-4e28-8a8d-94762eb57e53\')))"}]]'

ELASTIC_REQUEST_URL_RESPONSE = """{
    "took": 1525,
    "timed_out": "false",
    "_shards": {
        "total": 186,
        "successful": 186,
        "skipped": 0,
        "failed": 0
    },
    "hits": {
        "total": 2,
        "max_score": 11.043713,
        "hits": [
            {
                "_index": "xagget_testresults-obolab-2019.01.15",
                "_type": "testresults",
                "_id": "q5EaUWgBKSEcE2B1mdiD",
                "_score": 11.043713,
                "_source": {}
            },
            {
                "_index": "xagget_testresults-obolab-2019.01.15",
                "_type": "testresults",
                "_id": "uEwfUWgBDeLwsSD1CPjy",
                "_score": 11.043713,
                "_source": {
                    "url": {
                        "document": "/dump/testresults/document.JSON"
                    }
                }
            }
        ]
    }
}"""

def mock_requests_get(*args, **kwargs):
    """A method imitates sending GET requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    url = args[0]
    headers = kwargs["headers"] if "headers" in kwargs else None
    if url == "http://%s:%s/xagget_testresults*/testresults/_search?pretty" % \
        (CONF["XAGGET_ELK_HOST"], CONF["XAGGET_ELK_PORT"]) and headers:
        response_text = SAMPLE_ELK_RESPONSE
        data = dict(text=response_text, status_code=200, reason="OK")
    elif url == "http://%s:%s/socket.io/?EIO=3&transport=polling" % \
        (CONF["XAGGET_WEBUI_HOST"], CONF["XAGGET_WEBUI_PORT"]):
        response_text = (('{"sid":"%s","upgrades":["websocket"],' % SID) + \
            '"pingInterval":25000,"pingTimeout":60000}2:40')
        data = dict(text=response_text, status_code=200, reason="OK")
    elif url.startswith("http://%s:%s/socket.io/" % \
        (CONF["XAGGET_WEBUI_HOST"], CONF["XAGGET_WEBUI_PORT"])) and headers:
        response_text = SAMPLE_WEBUI_RESPONSE
        data = dict(text=response_text, status_code=200, reason="OK")
    else:
        data = dict(text="", status_code=404, reason="Not Found")
    return type("", (), data)()


def mock_requests_post(*args, **kwargs):
    """A method imitates sending POST requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    url = args[0]
    headers = kwargs["headers"] if "headers" in kwargs else None
    if url == "http://%s:%s/socket.io/?EIO=3&transport=polling&sid=%s" % \
        (CONF["XAGGET_WEBUI_HOST"], CONF["XAGGET_WEBUI_PORT"], SID) and headers:
        data = dict(text="ok", status_code=200, reason="OK")
    elif url == "http://%s:%s/api/test-runs/%s/start" % \
        (CONF["XAGGET_WEBUI_HOST"], CONF["XAGGET_WEBUI_PORT"], REPO) and headers:
        response_text = '{"testRunUUID":"%s"}' % RUN_ID
        data = dict(text=response_text, status_code=200, reason="OK")
    elif url == "http://%s:%s/xagget_testresult*/_search?" % (CONF["XAGGET_ELK_HOST"],\
                                                              CONF["XAGGET_ELK_PORT"]):
        data = dict(text=ELASTIC_REQUEST_URL_RESPONSE, status_code=200, reason="OK")
    else:
        data = dict(text="", status_code=404, reason="Not Found")
    return type("", (), data)()


@mock.patch("requests.post", side_effect=mock_requests_post)
@mock.patch("requests.get", side_effect=mock_requests_get)
def run_keyword_by_name(name, *args):
    """A function calls Keywords()' method by its name and returns its results."""
    kwd = Keywords()
    return getattr(kwd, name)(*args)


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


class Test_Requests(TestCaseNameAsDescription):
    """Class contains unit tests of parsing Xagget and ElasticSearch responses."""

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_sid(self, _mock_get):
        """Check sid value is parsed from response text correctly."""
        sid_value = Xagget_Requests(CONF).get_sid_value()
        self.assertEqual(sid_value, SID)

    @mock.patch("requests.post", side_effect=mock_requests_post)
    def test_set_session(self, _mock_post):
        """Check setting session request is successful ("ok" returned)."""
        response_text = Xagget_Requests(CONF).set_session(SID)
        self.assertEqual(response_text, "ok")

    @mock.patch("requests.post", side_effect=mock_requests_post)
    def test_submit_recipe(self, _mock_post):
        """Check recipe is submitted successfully (test run id is returned)."""
        data = {
            "name": "Test - Press MENU button on Remote",
            "description": "MENU screen is open",
            "weight": 10,
            "tags": ["natallia", "playground", "MENU"],
            "actions": [
                "pressButton('MENU', 3000)"
            ],
            "checks": [
                {"name": "readUI([{item:'header.title',check:{read:'MENU'}}])"}
            ]
        }
        json_str = json.dumps(data)
        test_run_id = Xagget_Requests(CONF).submit_recipe(json_str, REPO)
        self.assertEqual(test_run_id, RUN_ID)

    @mock.patch("requests.post", side_effect=mock_requests_post)
    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_runs(self, _mock_get, _mock_post):
        """Check test runs data are correctly parsed into dictionary."""
        runs_dict = Xagget_Requests(CONF).get_runs(RUN_ID)
        init_search = '{"info":{"uuid":"' + RUN_ID + '"}'
        end_search = "query:'Testrun:" + RUN_ID + "')))"
        json_str = SAMPLE_WEBUI_RESPONSE[SAMPLE_WEBUI_RESPONSE.find(init_search): \
                                         SAMPLE_WEBUI_RESPONSE.find(end_search) + 57]
        self.assertEqual(runs_dict, json.loads(json_str))

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_get_tests(self, _mock_get):
        """Check test results data are correctly parsed into dictionary."""
        tests_dict = Xagget_Requests(CONF).get_tests(RUN_ID)
        self.assertEqual(tests_dict, json.loads(SAMPLE_ELK_RESPONSE))

    @mock.patch("requests.post", side_effect=mock_requests_post)
    def test_elastic_url_request(self, _mock_post):
        """Check elastic request is successful ("ok" returned)."""
        url = Elastic_Requests(CONF).get_test_result_url_from_elastic(RUN_ID, TEST_NAME)
        self.assertEqual(url, "http://172.30.108.20/dump/testresults/document.JSON")


class TestKeyword_RunXaggetScenario(TestCaseNameAsDescription):
    """Class contains unit tests of run_xagget_scenario() keyword."""

    @classmethod
    def setUpClass(cls):
        args = [CONF, REPO, SCENARIO, CPE_ID]
        cls.result = run_keyword_by_name("run_xagget_scenario", *args)

    @classmethod
    def tearDownClass(cls):
        pass

    def test_run_id_returned(self):
        """Check run_xagget_scenario() keyword works: test run id is returned."""
        pattern = "[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}"
        result = re.match(pattern, self.result["testRunUUID"])
        self.assertTrue(result)


class TestKeyword_RunXaggetTest(TestCaseNameAsDescription):
    """Class contains unit tests of run_xagget_test() keyword."""

    @classmethod
    def setUpClass(cls):
        full_name = "%s::%s" % (SCENARIO, TEST_NAME)
        args = [CONF, REPO, full_name, CPE_ID]
        cls.result = run_keyword_by_name("run_xagget_test", *args)

    @classmethod
    def tearDownClass(cls):
        pass

    def test_run_id_returned(self):
        """Check run_xagget_test() keyword works: test run id is returned."""
        pattern = "[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}"
        result = re.match(pattern, self.result["testRunUUID"])
        self.assertTrue(result)


class TestKeyword_RunXaggetRawJSON(TestCaseNameAsDescription):
    """Class contains unit tests of run_xagget_raw_json() keyword."""

    @classmethod
    def setUpClass(cls):
        data = {
            "name": "Test - Press MENU button on Remote",
            "description": "MENU screen is open",
            "weight": 10,
            "tags": ["natallia", "playground", "MENU"],
            "actions": [
                "pressButton('MENU', 3000)"
            ],
            "checks": [
                {"name": "readUI([{item:'header.title',check:{read:'MENU'}}])"}
            ]
        }
        json_str = json.dumps(data)
        args = [CONF, json_str, CPE_ID]
        cls.result = run_keyword_by_name("run_xagget_raw_json", *args)

    @classmethod
    def tearDownClass(cls):
        pass

    def test_run_id_returned(self):
        """Check run_xagget_raw_json() keyword works: test run id is returned."""
        pattern = "[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}"
        result = re.match(pattern, self.result["testRunUUID"])
        self.assertTrue(result)


class TestKeyword_RunXaggetCRAWL(TestCaseNameAsDescription):
    """Class contains unit tests of run_xagget_crawl() keyword."""

    @classmethod
    def setUpClass(cls):
        args = [CONF, REPO, CPE_ID, "10s"]
        cls.result = run_keyword_by_name("run_xagget_crawl", *args)

    @classmethod
    def tearDownClass(cls):
        pass

    def test_run_id_returned(self):
        """Check run_xagget_crawl() keyword works: test run id is returned."""
        pattern = "[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}"
        result = re.match(pattern, self.result["testRunUUID"])
        self.assertTrue(result)


def suite_run_xagget_scenario():
    """A function builds a test suite for run_xagget_scenario() keyword."""
    return unittest.makeSuite(TestKeyword_RunXaggetScenario, "test")

def suite_run_xagget_test():
    """A function builds a test suite for run_xagget_test() keyword."""
    return unittest.makeSuite(TestKeyword_RunXaggetTest, "test")

def suite_run_xagget_raw_json():
    """A function builds a test suite for run_xagget_raw_json() keyword."""
    return unittest.makeSuite(TestKeyword_RunXaggetRawJSON, "test")

def suite_run_xagget_crawl():
    """A function builds a test suite for run_xagget_crawl() keyword."""
    return unittest.makeSuite(TestKeyword_RunXaggetCRAWL, "test")

def suite_xagget_requests():
    """A function builds a test suite for Xagget_Requests() class."""
    return unittest.makeSuite(Test_Requests, "test")


def run_tests():
    """A function to run unit tests; HTTP requests will not go to real servers."""
    suites = [
        suite_xagget_requests(),
        suite_run_xagget_scenario(),
        suite_run_xagget_test(),
        suite_run_xagget_raw_json(),
        suite_run_xagget_crawl()
    ]
    for suite in suites:
        unittest.TextTestRunner(verbosity=2).run(suite)


if __name__ == "__main__":
    run_tests()
