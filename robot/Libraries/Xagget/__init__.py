# pylint: disable=invalid-name
# Disabled "invalid-name" (complaining on not conforming to snake_case naming style for class name).
"""Module handles requests to Xagget in the form of Robot Framework keywords."""
from .keywords import Keywords


__version__ = "0.0.1"


class Xagget(Keywords,):
    """A library for Robot Framework to use XAGGET API for test runs."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"
