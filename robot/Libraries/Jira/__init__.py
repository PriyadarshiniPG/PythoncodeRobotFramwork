# pylint: disable=invalid-name
# pylint: disable=too-few-public-methods
# Disabled "invalid-name" (complaining on not conforming to snake_case naming style for class name).
"""A library for Get Data From Jira"""
from .keywords import JiraGetter

__version__ = "0.0.1"

class JiraGetData(JiraGetter,):
    """A library for Get Data From Jira"""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"
