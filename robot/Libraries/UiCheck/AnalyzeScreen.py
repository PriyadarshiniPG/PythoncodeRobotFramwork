"""
Module containing methods to recognize templates on the screen.
"""

import csv
import os

import pyocr
import pyocr.builders
from PIL import Image
from enum import Enum


class Templates(Enum):
    """
    Screen comparison templates
    """
    RECORDING_PLAY_FROM_START_POPUP = 1
    RECORDING_PLAY_FROM_START_BUTTON = 2
    TELE_TEXT = 3
    WATCH_LIVE_TV_POPUP = 4
    WATCH_LIVE_TV_SELECTED = 5


class AnalyzeScreen(object):
    """
    Class for detecting template on the screens.
    """

    # pylint: disable=too-few-public-methods,C0103

    def __init__(self, panoramix, channelprop_name='channelList.csv'):
        self.panoramix = panoramix
        self.channellist = dict()
        if channelprop_name is not None:
            channelpropfile = os.path.join(os.path.dirname(__file__),
                                           'template', channelprop_name)
            try:
                with open(channelpropfile, 'r') as file_p:
                    reader = csv.reader(file_p, delimiter='|')
                    for row in reader:
                        if row[0] not in self.channellist.keys():
                            self.channellist[row[0]] = row
            except IOError:
                raise IOError("Open {0} failed".format(channelpropfile))

    def is_checkbox_on_the_screen(self, video_selector):
        """
        Test if on the screen is selected check box.
        :param video_selector: HDMI slot
        :return: True if matches, otherwise False
        """
        template_path = os.path.join(os.path.dirname(__file__),
                                     'template', 'checkbox.png')
        match = self.panoramix.compare_screen_to_template(
            video_selector, template_path)
        return match > 0.98

    def define_current_tuned_screen(self, channel_id):
        """
        Retrieve current tuned channel's expected viewing properties
        :return: string defining the screen output type...
        """
        if channel_id not in self.channellist.keys():
            return "NOTFOUND", channel_id, False
        row = self.channellist[channel_id]
        return "FOUND", row[0], row[1]

    @staticmethod
    def read_characters_from_frame(frame_path):
        """
        Get the screenshot and read the characters
        :param frame_path: The path of the image to analyze
        :return: the characters found in the screenshot
        """
        tools = pyocr.get_available_tools()
        if not tools:
            raise Exception("No OCR tool found")
        tool = tools[0]
        recognized_characters = tool.image_to_string(
            Image.open(frame_path),
            lang='eng', builder=pyocr.builders.TextBuilder())
        return str(recognized_characters)

    @staticmethod
    def _get_template_path(template):
        template_path = os.path.join(os.path.dirname(__file__), 'template',
                                     template.name.lower() + '.png')
        if not os.path.isfile(template_path):
            raise IOError("Template is not available for " + template.name)
        return template_path

    def _perform_template_match(self, video_selector, template):
        template_path = self._get_template_path(
            template)
        match_value = self.panoramix.compare_screen_to_template(
            video_selector, template_path)
        return match_value >= 0.90

    def is_recording_play_from_start_popup(self, video_selector):
        """
        Check the STB is showing the play from start popup to play
        the recording
        :param video_selector: HDMI slot
        :return: True if box showing play from start popup
        """
        return self._perform_template_match(
            video_selector, Templates.RECORDING_PLAY_FROM_START_POPUP)

    def is_recording_play_from_start_button(self, video_selector):
        """
        Check the STB is showing the play from start button shown
        :param video_selector: HDMI slot
        :return: True if box showing play from start button
        """
        return self._perform_template_match(
            video_selector, Templates.RECORDING_PLAY_FROM_START_BUTTON)

    def is_teletext_seen(self, video_selector):
        """
        Check the STB is showing the teletext on the screen
        :param video_selector: HDMI slot
        :return: True if box showing the teletext on the screen
        """
        return self._perform_template_match(
            video_selector, Templates.TELE_TEXT)

    def is_youtube_launched(self, video_selector):
        """
        Check the STB is showing YouTube app is launched
        :param video_selector: HDMI slot
        :return: True if box showing the YouTube is launched
        """
        template1_path = os.path.join(os.path.dirname(__file__),
                                      'template',
                                      'YouTube_opened_template1.png')
        match1 = self.panoramix.compare_screen_to_template(
            video_selector, template1_path)
        if match1 > 0.98:
            return True
        template2_path = os.path.join(os.path.dirname(__file__),
                                      'template',
                                      'YouTube_opened_template2.png')
        match2 = self.panoramix.compare_screen_to_template(
            video_selector, template2_path, False)
        return match2 > 0.98

    def is_youtube_exit_screen_cancel_highlighted(self, video_selector):
        """
        Check STB is showing YouTube app exit screen Cancel option highlighted
        :param video_selector: HDMI slot
        :return: True if box showing the YouTube exit Cancel is highlighted
        """
        template_path = \
            os.path.join(os.path.dirname(__file__),
                         'template',
                         'YouTube_exit_screen_cancel_highlighted.png')
        match = self.panoramix.compare_screen_to_template(
            video_selector, template_path)
        return match > 0.98

    def is_youtube_exit_screen_exit_highlighted(self, video_selector):
        """
        Check the STB is showing YouTube Exit option highlighted
        :param video_selector: HDMI slot
        :return: True if box showing the YouTube Exit option highlighted
        """
        template_path = \
            os.path.join(os.path.dirname(__file__),
                         'template',
                         'YouTube_exit_screen_exit_highlighted.png')
        match = self.panoramix.compare_screen_to_template(
            video_selector, template_path)
        return match > 0.98

    def is_watch_live_tv_popup(self, video_selector):
        """
        Check the STB is showing Watch Live TV popup
        :param video_selector: HDMI slot
        :return: True if box showing Watch Live TV popup
        """
        return self._perform_template_match(
            video_selector, Templates.WATCH_LIVE_TV_POPUP)

    def is_watch_live_tv_selected(self, video_selector):
        """
        Check if Watch Live TV popup button is selected
        :param video_selector: HDMI slot
        :return: True if Watch Live TV popup button is selected
        """
        return self._perform_template_match(
            video_selector, Templates.WATCH_LIVE_TV_SELECTED)

    def is_template_present_on_screen(self, video_selector, template_name):
        """
        Check if the given template file is present on
        the current screen.
        :param video_selector: HDMI slot
        :param template_name: name of the file for the template
        :return: True if template is present
        """
        template_path = \
            os.path.join(os.path.dirname(__file__),
                         'template', '{0}.png'.format(template_name))
        match = self.panoramix.compare_screen_to_template(
            video_selector, template_path)
        return match > 0.98
