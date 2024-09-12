# pylint: disable=invalid-name
# Disabled "invalid-name" (complaining on not conforming to snake_case naming style for class name).
"""Module checks health status of all environment microservices
in the form of Robot Framework keywords.
"""
from .keywords import Keywords


__version__ = "0.0.1"


class OBOQBR(Keywords,):
    """A library for Robot Framework to check health status of all environment microservices."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"
