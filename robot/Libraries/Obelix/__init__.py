# pylint: disable=C0103
# Disable pylint "invalid-name" check
"""Module checks behaviour of Obelix
in the form of Robot Framework keywords.
"""
from .keywords import Keywords

__version__ = "0.0.1"

class Obelix(Keywords,):
    """A library for Robot Framework to check behaviour of Obelix."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"
