#!/usr/bin/env python27
# pylint: disable=invalid-name
"""
Description : Module containing abstract class for
              initialization of environment
Author      : Rnagpal.contractor@libertyglobal.com
"""

from abc import ABCMeta, abstractmethod


class AbstractInit(object, metaclass=ABCMeta):
    """This class provides abstract methods for setup and teardown
    of A/V analysis environment"""

    @abstractmethod
    def connect(self, selector):
        """
        Abstract method to connect to A/V analysing tool
        :param selector: STB slot
        """

    @abstractmethod
    def disconnect(self, selector):
        """
        Abstract method to disconnect to A/V analysing tool
        :param selector: STB slot
        """
