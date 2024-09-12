# pylint: disable=invalid-name
# Disabled "invalid-name" (complaining on not conforming to snake_case naming style for class name).
"""Module handles requests to Recording Microservice in the form of Robot Framework keywords."""
from .keywords import Keywords  # pylint: disable=E0401


__version__ = "0.0.1"


class RecordingService(Keywords,): # pylint: disable=R0903
    """A library for Robot Framework to request data from Recording Microservice."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"
