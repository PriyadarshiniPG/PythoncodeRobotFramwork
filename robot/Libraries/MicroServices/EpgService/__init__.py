# pylint: disable=invalid-name
# Disabled "invalid-name" (complaining on not conforming to snake_case naming style for class name).
"""Module checks behaviour of EPG Microservice in the form of Robot Framework keywords."""
from .keywords import Keywords


__version__ = "0.0.1"


class EpgService(Keywords,):
    """A library for Robot Framework to check the behaviour of EPG Microservice microservice."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"
