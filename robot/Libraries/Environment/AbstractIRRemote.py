#!/usr/bin/env python27
# pylint:disable=too-few-public-methods,invalid-name
"""
Description : Module containing abstract class for IRRemote
Author      : Rnagpal.contractor@libertyglobal.com
"""
from abc import ABCMeta, abstractmethod


class AbstractIRRemote(object, metaclass=ABCMeta):
    """This class provides abstract methods for IR Remote"""

    @abstractmethod
    def send_key_ir(self, selector, remote_key):
        """
        Abstract method to send the IR keys
        :param selector: STB slot
        :param remote_key: remote key code to send
        """
