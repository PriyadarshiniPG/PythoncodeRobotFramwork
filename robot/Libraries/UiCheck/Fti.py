"""
First Time Install related keywords
"""
import threading
import time

from Libraries.UiCheck.fti_classifier import FtiState


# pylint: disable=too-many-arguments


class Fti(object):
    """
    Class exposing keywords for FTI dialog.
    """
    _thread = 'thread'
    _result = 'result'

    def __init__(self, fti_classifier_classobj):
        self._fti_classifier = fti_classifier_classobj
        self._threads = {}

    def _wait_for_state_in_a_thread(
            self, video_selector, target_args, target_kwargs):
        if video_selector in self._threads:
            thread = self._threads[video_selector][self._thread]
            if thread.isAlive():
                thread.join()
        thread = threading.Thread(
            target=self._wait_for_state, args=target_args,
            kwargs=target_kwargs, name=video_selector)
        self._threads[video_selector] = {
            self._thread: thread,
            self._result: []
        }
        thread.start()

    def _wait_for_state(
            self, video_selector, state, timeout, period, min_fti_match=0.90,
            convert_image_before_compare=False,
            platform='DCX960', resolution='1080'):
        """
        Wait until given FtiState is displayed.
        :param video_selector: HDMI slot
        :param state: FtiState
        :param timeout: waiting for state timeout (in seconds)
        :param period: period for checking screen
        :param min_fti_match: Minimum fti match value
                Match level from 0.0 (no match) to 1.0 (perfect match)
        :param convert_image_before_compare: Convert images before comparing it
        :param platform: platform of the STB
        :param resolution: resolution of the screenshot
        """
        return_value = False
        must_end = time.time() + int(timeout)
        while time.time() < must_end:
            if self._fti_classifier.is_fti_state(
                    video_selector, state, min_fti_match,
                    convert_image_before_compare,
                    platform, resolution):
                return_value = True
                break
            time.sleep(float(period))
        self._threads[video_selector][self._result].insert(0, return_value)

    def is_fti_thread_finished(self, video_selector):
        """
        Returns a boolean depicting whether FTI thread is finished or not
        :param video_selector: HDMI slot
        :return: boolean
        """
        return not self._threads[video_selector][self._thread].isAlive()

    def get_fti_thread_result(self, video_selector):
        """
        Returns FTI thread result as boolean depicting whether given FTI screen
        was shown
        :param video_selector: HDMI slot
        :return: boolean
        """
        return self._threads[video_selector][self._result][0]

    def wait_for_fti_country_selection_caption(
            self, video_selector, timeout=300, period=1.0,
            platform='DCX960', resolution='1080'):
        """
        Wait until country selection init captionscreen is displayed.
        :param video_selector: HDMI slot
        :param timeout: waiting for country selection timeout (in seconds)
        :param period: period for checking screen
        :param platform: platform of the STB
        :param resolution: resolution of the screenshot
        :return: true if country selection screen will be shown before timeout,
        otherwise false.
        """
        self._wait_for_state_in_a_thread(
            video_selector,
            target_args=(
                video_selector, FtiState.COUNTRY_SEL_INITIAL, timeout, period),
            target_kwargs={'platform': platform, 'resolution': resolution}
        )

    def wait_for_fti_country_selection_progress_dot(
            self, video_selector, timeout=300, period=1.0,
            platform='DCX960', resolution='1080'):
        """
        Wait until country selection init captionscreen is displayed.
        :param video_selector: HDMI slot
        :param timeout: waiting for country selection timeout (in seconds)
        :param period: period for checking screen
        :param platform: platform of the STB
        :param resolution: resolution of the screenshot
        :return: true if country selection screen will be shown before timeout,
        otherwise false.
        """
        self._wait_for_state_in_a_thread(
            video_selector,
            target_args=(
                video_selector, FtiState.COUNTRY_SEL_INITIAL, timeout, period),
            target_kwargs={'platform': platform, 'resolution': resolution}
        )

    def wait_for_fti_language_selection(
            self, video_selector, state='LANGUAGE_SEL_INITIAL_BE',
            timeout=30, period=1.0,
            platform='DCX960', resolution='1080'):
        """
        Wait until language selection init screen is displayed until timeout.
        :param video_selector: HDMI slot
        :param state: default fti screen looking for
        :param timeout: waiting for language selection timeout (in seconds)
        :param period: period for checking screen
        :param platform: platform of the STB
        :param resolution: resolution of the screenshot
        :return: true if language selection screen will be shown before
        timeout, otherwise false.
        """
        self._wait_for_state_in_a_thread(
            video_selector,
            target_args=(
                video_selector, getattr(FtiState, state), timeout, period),
            target_kwargs={'platform': platform, 'resolution': resolution}
        )

    def wait_for_welcome_screen(self, video_selector, timeout=30, period=1.0,
                                platform='DCX960', resolution='1080'):
        """
        Wait until welcome screen is displayed until timeout.
        :param video_selector: HDMI slot
        :param timeout: waiting for welcome screen timeout (in seconds)
        :param period: period for checking screen
        :param platform: platform of the STB
        :param resolution: resolution of the screenshot
        :return: true if welcome screen will be shown before
        timeout, otherwise false.
        """
        convert_image_before_compare = True
        if platform in ['EOS1008C', 'SMT-G7400', 'SMT-G7401']:
            convert_image_before_compare = False
        self._wait_for_state_in_a_thread(
            video_selector,
            target_args=(
                video_selector, FtiState.WELCOME_INITIAL, timeout, period),
            target_kwargs={
                'min_fti_match': 0.80,
                'convert_image_before_compare': convert_image_before_compare,
                'platform': platform, 'resolution': resolution
            }
        )

    def wait_for_no_signal_screen(
            self, video_selector, timeout=30, period=1.0,
            platform='DCX960', resolution='1080'):
        """
        Wait until no signal screen is displayed until timeout.
        :param video_selector: HDMI slot
        :param timeout: waiting for no signal screen timeout (in seconds)
        :param period: period for checking screen
        :param platform: platform of the STB
        :param resolution: resolution of the screenshot
        :return: true if no signal screen will be shown before
        timeout, otherwise false.
        """
        self._wait_for_state_in_a_thread(
            video_selector,
            target_args=(
                video_selector, FtiState.NO_SIGNAL, timeout, period),
            target_kwargs={'platform': platform, 'resolution': resolution}
        )

    def wait_for_please_wait_screen(
            self, video_selector, timeout=30, period=1.0,
            platform='DCX960', resolution='1080'):
        """
        Wait until Please Wait screen is displayed until timeout.
        :param video_selector: HDMI slot
        :param timeout: waiting for Please Wait screen (in seconds)
        :param period: period for checking screen
        :param platform: platform of the STB
        :param resolution: resolution of the screenshot
        :return: true if Please Wait screen will be shown before
        timeout, otherwise false.
        """
        convert_image_before_compare = True
        if platform in ['SMT-G7400', 'SMT-G7401']:
            convert_image_before_compare = False
        self._wait_for_state_in_a_thread(
            video_selector,
            target_args=(
                video_selector, FtiState.PLEASE_WAIT_STATE, timeout, period),
            target_kwargs={
                'min_fti_match': 0.80,
                'convert_image_before_compare': convert_image_before_compare,
                'platform': platform, 'resolution': resolution}
        )

    def wait_for_fti_network_selection(
            self, video_selector,
            state='NETWORK_MEDIA_SEL_EN',
            timeout=300, period=1.0,
            platform='DCX960', resolution='1080'):
        """
        Wait until network selection init screen is displayed until timeout.
        :param video_selector: HDMI slot
        :param state: default fti screen looking for
        :param timeout: waiting for network selection timeout (in seconds)
        :param period: period for checking screen
        :param platform: platform of the STB
        :param resolution: resolution of the screenshot
        :return: true if network selection screen will be shown before timeout,
        otherwise false.
        """
        self._wait_for_state_in_a_thread(
            video_selector,
            target_args=(
                video_selector, getattr(FtiState, state), timeout, period),
            target_kwargs={'platform': platform, 'resolution': resolution}
        )

    def wait_for_fti_personalization(
            self, video_selector, state='PERSONALIZATION_SEL_EN',
            timeout=300, period=1.0,
            platform='DCX960', resolution='1080'):
        """
        Wait until personalization init screen is displayed until timeout.
        :param video_selector: HDMI slot
        :param state: FTI state to wait for
        :param timeout: waiting for personalization timeout (in seconds)
        :param period: period for checking screen
        :param platform: platform of the STB
        :param resolution: resolution of the screenshot
        :return: true if personalization screen will be shown before timeout,
        otherwise false.
        """
        self._wait_for_state_in_a_thread(
            video_selector,
            target_args=(
                video_selector, getattr(FtiState, state), timeout, period),
            target_kwargs={'platform': platform, 'resolution': resolution}
        )

    def wait_for_fti_rcu_pairing(
            self, video_selector, timeout=150, period=1.0,
            platform='DCX960', resolution='1080'):
        """
        Wait until RCU paring screen is displayed until timeout.
        :param video_selector: HDMI slot
        :param timeout: waiting for personalization timeout (in seconds)
        :param period: period for checking screen
        :param platform: platform of the STB
        :param resolution: resolution of the screenshot
        :return: true if RCU pairing screen will be shown before timeout,
        otherwise false.
        """
        self._wait_for_state_in_a_thread(
            video_selector,
            target_args=(
                video_selector, FtiState.RCU_PAIRING, timeout, period),
            target_kwargs={'platform': platform, 'resolution': resolution}
        )

    def wait_for_fti_rcu_success(
            self, video_selector, timeout=150, period=1.0):
        """
        Wait until RCU paring success screen is displayed until timeout.
        :param video_selector: HDMI slot
        :param timeout: waiting for success screen timeout (in seconds)
        :param period: period for checking screen
        :return: true if RCU pairing success screen will be shown
        before timeout, otherwise false.
        """
        self._wait_for_state_in_a_thread(
            video_selector,
            target_args=(
                video_selector, FtiState.RCU_PAIRING_SUCCESS, timeout, period),
            target_kwargs={}
        )

    def wait_for_fti_wifi_options(
            self, video_selector, timeout=150, period=1.0):
        """
        Wait until WiFi options screen is displayed until timeout.
        :param video_selector: HDMI slot
        :param timeout: waiting for success screen timeout (in seconds)
        :param period: period for checking screen
        :return: true if WiFi options screen will be shown before timeout,
        otherwise false.
        """
        self._wait_for_state_in_a_thread(
            video_selector,
            target_args=(
                video_selector, FtiState.WIFI_OPTIONS, timeout, period),
            target_kwargs={}
        )

    def wait_for_fti_completion_screen(
            self, video_selector, state='INSTALLATION_COMPLETION',
            timeout=240, period=1.0, platform='DCX960', resolution='1080'):
        """
        Wait until installation completion screen is displayed until timeout.
        :param video_selector: HDMI slot
        :param state: default fti screen looking for
        :param timeout: waiting for installation completion screen in seconds
        :param period: period for checking screen
        :param platform: STB platform
        :param resolution: STB video resolution
        :return: true if installation completion screen shown before timeout,
        otherwise false.
        """
        self._wait_for_state_in_a_thread(
            video_selector,
            target_args=(
                video_selector, getattr(FtiState, state), timeout, period),
            target_kwargs={'platform': platform, 'resolution': resolution}
        )

    def wait_for_download_screen(
            self, video_selector, timeout=30, period=1.0,
            platform='DCX960', resolution='1080'):
        """
        Wait until software download screen is displayed until timeout.
        :param video_selector: HDMI slot
        :param timeout: waiting for no signal screen timeout (in seconds)
        :param period: period for checking screen
        :param platform: platform of the STB
        :param resolution: resolution of the screenshot
        :return: true if software download screen will be shown before
        timeout, otherwise false.
        """
        self._wait_for_state_in_a_thread(
            video_selector,
            target_args=(
                video_selector, FtiState.SOFTWARE_DOWNLOAD_STATE, timeout,
                period),
            target_kwargs={'platform': platform, 'resolution': resolution}
        )

    def wait_for_installation_screen(
            self, video_selector, timeout=30, period=1.0,
            platform='DCX960', resolution='1080'):
        """
        Wait until software installation screen is displayed until timeout.
        :param video_selector: HDMI slot
        :param timeout: waiting for no signal screen timeout (in seconds)
        :param period: period for checking screen
        :param platform: platform of the STB
        :param resolution: resolution of the screenshot
        :return: true if software installation screen will be shown before
        timeout, otherwise false.
        """
        self._wait_for_state_in_a_thread(
            video_selector,
            target_args=(
                video_selector, FtiState.SOFTWARE_INSTALLATION_STATE, timeout,
                period),
            target_kwargs={'platform': platform, 'resolution': resolution}
        )
