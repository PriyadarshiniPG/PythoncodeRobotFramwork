# pylint: disable=invalid-name
# Disabled "invalid-name" (complaining on not conforming to snake_case naming style for class name).
"""Module checks behaviour of RENG recommendation engine
in the form of Robot Framework keywords.
"""
from .keywords import Keywords


__version__ = "0.0.1"


class RENG(Keywords,):
    """A library for Robot Framework to check behaviour of RENG."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"
