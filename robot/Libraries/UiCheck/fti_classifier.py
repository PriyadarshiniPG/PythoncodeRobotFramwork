"""
Module containing methods to recognize First Time Install screens.
"""

import os
from enum import Enum


class FtiState(Enum):
    """Enums specifying First Time Install screens"""

    # pylint: disable=too-few-public-methods
    WELCOME_INITIAL = 5
    RCU_PAIRING = 10
    RCU_PAIRING_SUCCESS = 15
    COUNTRY_SEL_INITIAL = 20
    COUNTRY_SEL_NL = 30
    LANGUAGE_SEL_INITIAL_NL = 40
    LANGUAGE_SEL_NL_EN = 50
    NETWORK_MEDIA_SEL_EN = 60
    PERSONALIZATION_SEL_EN = 80
    PERSONALIZATION_SEL_EN_AGAIN = 90
    PERSONALIZATION_SEL_EN_ACTIVATE = 100
    PERSONALIZATION_SEL_EN_SKIP = 110
    WIFI_OPTIONS = 120
    SAVED_WIFI = 130
    PLEASE_WAIT_STATE = 135
    SC1002 = 140
    PREFERENCE_SEL_NL_INITIAL = 145
    PREFERENCE_SEL_NL_EN = 150
    INTERNET_OPTION_ETHERNET = 155
    INTERNET_OPTION_WIFI = 160
    COUNTRY_SEL_BE = 165
    LANGUAGE_SEL_INITIAL_BE = 170
    LANGUAGE_SEL_BE_EN = 175
    COUNTRY_SEL_CL = 180
    LANGUAGE_SEL_INITIAL_CL = 185
    LANGUAGE_SEL_CL_EN = 190
    WARNING = 195
    NO_SIGNAL = 200
    LANGUAGE_SEL_TRANS_NL_EN = 205
    COUNTRY_SEL_INITIAL_DOTS = 210
    INSTALLATION_COMPLETION = 215
    SOFTWARE_DOWNLOAD_STATE = 230
    SOFTWARE_INSTALLATION_STATE = 235
    LANGUAGE_SEL_INITIAL = 240
    RCU_PAIRING_REQUEST = 241
    RCU_PAIRING_TIPS_SCREEN = 242
    RECOMMENDATIONS = 245
    ACTIVATE_RECOMMENDATIONS_EN = 250


class FtiClassifier(object):
    """FtiClassifier class"""

    # no-member  quick-fix for opencv import errors
    # pylint: disable=no-member,too-many-arguments

    def __init__(self, video_capture_engine):
        self.video_capture_engine = video_capture_engine

    @staticmethod
    def get_template_path(state, platform='DCX960', resolution='1080'):
        """
        Get path of template image for given state
        :param state: requested state
        :param platform: platform of the STB
        :param resolution: resolution of the screenshot
        :return: path to image file
        """
        filename = state.name.lower() + ".png"
        # workaround:
        # Template_temp is used for current images which differs
        # from intended version.
        filepath = os.path.join(os.path.dirname(__file__),
                                "template", platform, resolution, filename)
        return filepath

    def is_fti_state(self, video_selector, state, min_state_match=0.96,
                     convert_image_before_compare=False,
                     platform='DCX960', resolution='1080'):
        """
        Test if on the screen is given state
        :param video_selector: HDMI slot
        :param state: state to test
        :param min_state_match: Minimum FTI state match value,
                Match level from 0.0 (no match) to 1.0 (perfect match)
        :param convert_image_before_compare: Convert images before
                comparing it
        :param platform: platform of the STB
        :param resolution: resolution of the screenshot
        :return: Boolean
        """
        if isinstance(state, str):
            state = FtiState[state]

        match = self.video_capture_engine.compare_screen_to_template(
            video_selector,
            self.get_template_path(state, platform, resolution),
            convert_image_before_compare)
        return match >= float(min_state_match)
