# pylint: disable=invalid-name
# pylint: disable=too-few-public-methods
# Disabled "invalid-name" (complaining on not conforming to snake_case naming style for class name).
"""Module sends results to ElasticSearch every time test suite/case is completed."""
from .robotlistener import RobotListener


__version__ = "0.0.1"


class Jira(RobotListener,):
    """A library for Robot Framework to send test results to ElasticSearch.
    This is done "on-the-fly", i.e. after each test case gets completed.
    """
    ROBOT_LIBRARY_SCOPE = "GLOBAL"
