#!/usr/bin/env python27
# pylint:disable=too-few-public-methods,invalid-name
"""
Description : Module containing abstract class for Video analysis
Author      : Rnagpal.contractor@libertyglobal.com
"""

from abc import ABCMeta, abstractmethod


class AbstractVideo(object, metaclass=ABCMeta):
    """This class contains the abstract methods for Video analysis"""

    @abstractmethod
    def get_screenshot(self, video_selector):
        """
        Abstract method to get the screenshot
        :param video_selector: STB slot
        """

    @abstractmethod
    def is_video_playing(self, video_selector):
        """
        Abstract method to check if video is playing
        :param video_selector: STB slot
        """

    @abstractmethod
    def is_black_screen(self, video_selector):
        """
        Abstract method to detect the blackscreen
        :param video_selector: STB slot
        """
