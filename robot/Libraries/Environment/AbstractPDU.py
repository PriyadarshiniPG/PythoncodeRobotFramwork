#!/usr/bin/env python27
"""
Description : Module containing abstract class for PDU
Author      : Rnagpal.contractor@libertyglobal.com
"""

from abc import ABCMeta, abstractmethod


class AbstractPDU(object, metaclass=ABCMeta):
    """This class provides abstract methods for PDU"""

    @abstractmethod
    def get_power_level(self, selector, pdu_selector):
        """
        Abstract method to get the power levels
        :param selector: STB slot
        :param pdu_selector: pdu slot
        """

    @abstractmethod
    def power_cycle(self, selector, pdu_selector):
        """
        Abstract method to power cycle the box
        :param selector: STB slot
        :param pdu_selector: pdu slot
        """

    @abstractmethod
    def power_off(self, selector, pdu_selector):
        """
        Abstract method to power off the box
        :param selector: STB slot
        :param pdu_selector: pdu slot
        """

    @abstractmethod
    def power_on(self, selector, pdu_selector):
        """
        Abstract method to power on the box
        :param selector: STB slot
        :param pdu_selector: pdu slot
        """
