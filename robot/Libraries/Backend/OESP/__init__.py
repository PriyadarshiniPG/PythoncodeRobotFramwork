# pylint: disable=invalid-name
# Disabled "invalid-name" (complaining on not conforming to snake_case naming style for class name).
"""Module handles requests to OESP in the form of Robot Framework keywords."""
from .keywords import Keywords


__version__ = "0.0.1"


class OESP(Keywords,):
    """A library for Robot Framework to use OESP API to manage STBs."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"
