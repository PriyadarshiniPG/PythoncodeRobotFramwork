# pylint: disable=invalid-name
# Disabled "invalid-name" (complaining on not conforming to snake_case naming style for class name).
"""Module handles connection and requests to servers for E2E tests
in the form of Robot Framework keywords.
"""
from .keywords import Keywords


__version__ = "0.0.1"


class IngestionE2E(Keywords,):
    """A library for Robot Framework to execute E2E tests of VoD ingestion."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"
