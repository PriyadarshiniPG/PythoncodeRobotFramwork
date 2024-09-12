"""A module to update tests results in Jira using Zephyr API calls"""

# pylint: disable=wrong-import-position
# pylint: disable=wrong-import-order
# pylint: disable=too-few-public-methods
# pylint: disable=too-many-instance-attributes
# pylint: disable=W0102
import os
import inspect
import sys
from robot.libraries.BuiltIn import BuiltIn  # pylint: disable=unused-import
currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
parentdir = os.path.dirname(currentdir)
sys.path.append(parentdir)
from DataGetter.keywords import Data  # pylint: disable=import-error


class RobotListener(object):
    """A class overrides default Robot Framework listeners."""
    ROBOT_LISTENER_API_VERSION = 2
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self):
        setattr(self, "ROBOT_LIBRARY_LISTENER", self)
        self.data = Data()

    def _start_suite(self, *args):
        """A method what will be runned automaticaly by RF when test suite will be started"""
        self.data.get_start_suite_data(args)
        # print(self.data.suite.__dict__)

    def _start_test(self, *args):
        """A method what will be runned automaticaly by RF when test case will be started"""
        self.data.get_start_test_data(args)
        # print(self.data.test.__dict__)

    def _end_test(self, *args):
        """A method what will be runned automaticaly by RF when test case will be done"""
        self.data.get_end_test_data(args)
        # print(self.data.test.__dict__)

    def _end_suite(self, *args):
        """A method what will be runned automaticaly by RF when test suite will be done"""
        self.data.get_end_suite_data(args)
        # print(self.data.suite.__dict__)
        # cycle_id = self.sender.clone_latest_test_cycle()
        # time.sleep(5)
        for jira_ticket in self.data.suite.jira:
            self.data.suite.jiragetter.set_test_case_execution_status(
                issue_key=jira_ticket,
                status=self.data.suite.result
            )
