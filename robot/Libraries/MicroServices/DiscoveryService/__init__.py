# pylint: disable=invalid-name
# Disabled "invalid-name" (complaining on not conforming to snake_case naming style for class name).
"""Module checks behaviour of Discovery microservice
in the form of Robot Framework keywords.
"""
from .keywords import Keywords


__version__ = "0.0.1"


class DiscoveryService(Keywords,):
    """A library for Robot Framework to check behaviour of Discovery microservice."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"
