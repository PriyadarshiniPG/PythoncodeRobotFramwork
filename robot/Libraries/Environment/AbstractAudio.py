#!/usr/bin/env python27
# pylint: disable=invalid-name
"""
Description : Module containing abstract class for Audio analysis
Author      : Rnagpal.contractor@libertyglobal.com
"""

from abc import ABCMeta, abstractmethod


class AbstractAudio(object, metaclass=ABCMeta):
    """
    Module containing abstract methods for Audio Analysis
    """

    @abstractmethod
    def get_audio_level(self, audio_selector):
        """
        Abstract method to get audio frequency
        :param audio_selector: audio selector, like hdmi slot number
        """


    @abstractmethod
    def is_audio_playing(self, audio_selector):
        """
        Abstract method to check if audio is playing
        :param audio_selector: audio selector, like hdmi slot number
        """
