# pylint: disable=invalid-name
# Disabled "invalid-name" (complaining on not conforming to snake_case naming style for class name).
"""Module keeps supporting keywords to deal with microservices."""
from .keywords import Keywords


__version__ = "0.0.1"


class MetaKeywords(Keywords,):
    """A library for Robot Framework to keep supporting keywords to deal with microservices."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"
