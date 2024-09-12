# pylint: disable=protected-access,unused-argument
# pylint: disable=wrong-import-position
# pylint: disable=wrong-import-order
# pylint: disable=too-many-public-methods
# pylint: disable=global-statement
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
import unittest
try:
    import mock
except ImportError:
    import unittest.mock as mock
from .robotlistener import RobotListener
from robot.libraries.BuiltIn import BuiltIn  # pylint: disable=unused-import
currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
parentdir = os.path.dirname(currentdir)
lib_dir = os.path.dirname(parentdir)
robot_dir = os.path.dirname(lib_dir)
sys.path.append(robot_dir)
sys.path.append(parentdir)
import tools  # pylint: disable=import-error
from DataGetter.keywords import Data  # pylint: disable=import-error
from Libraries.Jira.keywords import JiraGetter


CPE_ID = "3C36E4-EOSSTB-003356472104"
CONF = {
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
GET_DATA_RESULT = None
SET_TEST_CASE_EXACUTION_STATUS = None


def mock_get_data(*args):
    """Easy mock method to check that methods like _start_suite or _end_test was called.
    Mock will call this method when certain RobotListener's method will be called and
    change of global variable will indicate success result
    """
    global GET_DATA_RESULT
    GET_DATA_RESULT = "Correct"


def mock_set_test_case_execution_status(issue_key, status, *args):
    """Easy mock method to check that method 'jiragetter.set_test_case_execution_status'
    has been called. Mock will call this method and
    change of global variable will indicate success result
    """
    global SET_TEST_CASE_EXACUTION_STATUS
    SET_TEST_CASE_EXACUTION_STATUS = "Done"


def mock_robot_get_conf(*args):
    """Function returns predefined CONF as keyword "Get Variables" would do."""
    return CONF["MOCK"]


@mock.patch.object(tools, "get_conf", side_effect=mock_robot_get_conf)
def mock_create_listener(*args):
    """Simple method to create instance of RobotListener class with the necessary mocking"""
    return RobotListener()


class MockSuite(object):
    """Dummy class to create suite object with necessary properties"""
    def __init__(self):
        self.jira = []
        self.jiragetter = JiraGetter()
        self.result = None

    def get_result(self):
        """Dummy method for pylint"""
        return self.result


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


class StartSuite(TestCaseNameAsDescription):
    """Class contains unit tests of _start_suite() keyword."""

    @classmethod
    def setUpClass(cls):
        cls.robot_listener = mock_create_listener()

    @classmethod
    def tearDownClass(cls):
        pass

    def test_check_init(self):
        """Test to check propertiesfrom __init__ of RobotListener class"""
        self.assertIsInstance(self.robot_listener.data, Data)

    @mock.patch.object(Data, "get_start_suite_data", side_effect=mock_get_data)
    def test_check_get_start_suite_data_called(self, *args):
        """Check status of sending test suite results."""
        self.robot_listener._start_suite()
        global GET_DATA_RESULT
        self.assertIs(GET_DATA_RESULT, "Correct")
        GET_DATA_RESULT = None


class StartTest(StartSuite):
    """Class contains unit tests of _start_test() keyword."""

    @classmethod
    def setUpClass(cls):
        pass

    @classmethod
    def tearDownClass(cls):
        pass

    @mock.patch.object(Data, "get_start_test_data", side_effect=mock_get_data)
    def test_check_get_start_test_data_called(self, *args):
        """Check status of sending test suite results."""
        self.robot_listener._start_test()
        global GET_DATA_RESULT
        self.assertIs(GET_DATA_RESULT, "Correct")
        GET_DATA_RESULT = None


class EndTest(StartTest):
    """Class contains unit tests of _end_test() keyword."""

    @classmethod
    def setUpClass(cls):
        pass

    @classmethod
    def tearDownClass(cls):
        pass

    @mock.patch.object(Data, "get_end_test_data", side_effect=mock_get_data)
    def test_check_get_end_test_data_called(self, *args):
        """Check status of sending test suite results."""
        self.robot_listener._end_test()
        global GET_DATA_RESULT
        self.assertIs(GET_DATA_RESULT, "Correct")
        GET_DATA_RESULT = None


class EndSuite(EndTest):
    """Class contains unit tests of _end_suite() keyword."""

    @classmethod
    def setUpClass(cls):
        pass

    @classmethod
    def tearDownClass(cls):
        pass

    @mock.patch.object(Data, "get_end_suite_data", side_effect=mock_get_data)
    @mock.patch.object(
        JiraGetter, "set_test_case_execution_status",
        side_effect=mock_set_test_case_execution_status
    )
    def test_check_get_end_suite_data_called(self, *args):
        """Check status of sending test suite results."""
        self.robot_listener.data.suite = MockSuite()
        self.robot_listener.data.suite.jira = ["HES-111", "HES-222"]
        self.robot_listener._end_suite()
        global GET_DATA_RESULT
        global SET_TEST_CASE_EXACUTION_STATUS
        self.assertIs(GET_DATA_RESULT, "Correct")
        self.assertIs(SET_TEST_CASE_EXACUTION_STATUS, "Done")
        GET_DATA_RESULT = None
        SET_TEST_CASE_EXACUTION_STATUS = None


def make_suite(class_instance):
    """A function builds a test suite"""
    return unittest.makeSuite(class_instance, "test")


def run_tests():
    """A function runs unit tests; HTTP requests will not go to real servers."""
    suites = [
        make_suite(StartSuite),
        make_suite(StartTest),
        make_suite(EndTest),
        make_suite(EndSuite),
    ]
    for suite in suites:
        unittest.TextTestRunner(verbosity=2).run(suite)


if __name__ == "__main__":
    run_tests()
