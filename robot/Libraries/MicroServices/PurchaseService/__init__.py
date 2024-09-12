# pylint: disable=invalid-name
# Disabled "invalid-name" (complaining on not conforming to snake_case naming style for class name).
"""Module checks behaviour of Purchase Microservice in the form of Robot Framework keywords."""
from .keywords import Keywords


__version__ = "0.0.1"


class PurchaseService(Keywords,):
    """A library for Robot Framework to check the behaviour of Purchase Microservice."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"
