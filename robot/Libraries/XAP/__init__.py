# pylint: disable=invalid-name
# Disabled "invalid-name" (complaining on not conforming to snake_case naming style for class name).
"""Module allows to run commands from an STB in the form of Robot Framework keywords."""
from .keywords import Keywords


__version__ = "0.0.1"


class XAP(Keywords,):
    """A library for Robot Framework to execute commands from STB."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"
