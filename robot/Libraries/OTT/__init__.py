# pylint: disable=invalid-name
# Disabled "invalid-name" (complaining on not conforming to snake_case naming style for class name).
"""Module checks LIVE and VoD content availability for OTT devices
in the form of Robot Framework keywords.
"""
from .keywords import Keywords


__version__ = "0.0.1"


class OTT(Keywords,):
    """A library for Robot Framework
    to check availability of LIVE and VoD content for OTT devices."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"
