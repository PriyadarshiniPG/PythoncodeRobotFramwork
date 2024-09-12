# pylint: disable=invalid-name
# Disabled "invalid-name" (complaining on not conforming to snake_case naming style for class name).
"""Module handles requests to Fabrix in the form of Robot Framework keywords."""
from .keywords import Keywords


__version__ = "0.0.1"


class Fabrix(Keywords,):
    """A library for Robot Framework to request data from Fabrix."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"
