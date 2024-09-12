"""
Panoramix Client module for the interactions with the panoramix
standalone webapp
"""
import os
import time
from io import StringIO
from PIL import Image
from Libraries.Common.HTTPRequests import HTTPRequests
from Libraries.Environment.AbstractAudio import AbstractAudio
from Libraries.Environment.AbstractIRRemote import AbstractIRRemote
from Libraries.Environment.AbstractPDU import AbstractPDU
from Libraries.Environment.AbstractVideo import AbstractVideo
# from Libraries.teststream.video_analyzer import VideoAnalyzer


class PanoramixClient(
        AbstractVideo, AbstractIRRemote, AbstractPDU, AbstractAudio):
    """
    Class holds the methods to interact with the panoramix webapp
    """

    def __init__(self, rack_pc_ip):
        self._base_url = 'http://{}/stb/'.format(rack_pc_ip)
        self._request_lib = HTTPRequests()

    def is_audio_playing(self, audio_selector):
        """
        Check whether the audio is playing or not
        :param audio_selector: audio selector, like hdmi slot number
        :return: True if audio is playing
        """
        url = self._base_url + str(audio_selector) + '/audio/is-playing'
        return self._request_lib.http_get(url).json()

    def get_audio_level(self, audio_selector):
        """
        Get audio level of the current playing audio
        :param audio_selector: audio selector, like hdmi slot number
        :return: Audio level
        """
        url = self._base_url + str(audio_selector) + '/audio/level'
        return self._request_lib.http_get(url).json()

    def get_audio_frequency(self, audio_selector):
        """
        Get audio frequency of the current playing audio
        :param audio_selector: audio selector, like hdmi slot number
        :return: Audio frequency
        """
        url = self._base_url + str(audio_selector) + '/audio/frequency'
        return self._request_lib.http_get(url).json()

    def send_key_ir(self, selector, remote_key):
        """
        Send IR key to the STB
        :param selector: STB slot
        :param remote_key: Remote key
        """
        url = self._base_url + str(selector) + '/ir/send-key/' + \
            str(remote_key)
        self._request_lib.http_get(url)

    def power_on(self, selector, pdu_selector):
        """
        Power On the STB
        :param selector: STB slot
        :param pdu_selector: pdu slot - Ignored,
        handled internally by panoramix app
        """
        url = self._base_url + str(selector) + '/power/on'
        self._request_lib.http_get(url)

    def power_off(self, selector, pdu_selector):
        """
        Power Off the STB
        :param selector: STB slot
        :param pdu_selector: pdu slot - Ignored,
        handled internally by panoramix app
        """
        url = self._base_url + str(selector) + '/power/off'
        self._request_lib.http_get(url)

    def power_cycle(self, selector, pdu_selector):
        """
        Power Cycle the STB
        :param selector: STB slot
        :param pdu_selector: pdu slot - Ignored,
        handled internally by panoramix app
        """
        url = self._base_url + str(selector) + '/power/cycle'
        self._request_lib.http_get(url)

    def get_power_level(self, selector, pdu_selector):
        """
        Get the power outlet consumption level
        :param selector: STB slot
        :param pdu_selector: pdu slot - Ignored,
        handled internally by panoramix app
        :return: Power consumption in watts
        """
        url = self._base_url + str(selector) + '/power/level'
        return self._request_lib.http_get(url).json()

    @staticmethod
    def _get_screenshot_directory(video_selector):
        screen_shot_path = os.path.join(
            os.path.dirname(__file__), '..', '..', 'screenshot',
            'stb{}'.format(video_selector))
        if not os.path.exists(screen_shot_path):
            os.makedirs(screen_shot_path)
        return screen_shot_path

    def get_screenshot(self, video_selector):
        """
        Get the current screen shot of the playing video
        :param video_selector: STB slot
        :return: Path to saved screen shot
        """
        url = self._base_url + str(video_selector) + '/video/screen-shot'
        response = self._request_lib.http_get(url)

        timestamp = time.strftime('%Y-%m-%d_%H-%M-%S')
        screen_shot_name = 'screen_shot_' + timestamp + '.jpg'
        screen_shot_path = os.path.join(
            self._get_screenshot_directory(video_selector),
            screen_shot_name)

        image_data = Image.open(StringIO(response.content))
        image_data.save(screen_shot_path)
        return os.path.abspath(screen_shot_path)

    def is_video_playing(self, video_selector):
        """
        Check whether the video is playing or not
        :param video_selector: STB slot
        :return: True is video is playing
        """
        url = self._base_url + str(video_selector) + '/video/is-playing'
        return self._request_lib.http_get(url).json()

    def is_black_screen(self, video_selector):
        """
        Check whether the video output is black screen or not
        :return: True if video output is black screen
        """
        url = self._base_url + str(video_selector) + \
            '/video/is-black-screen'
        return self._request_lib.http_get(url).json()

    # def compare_screen_to_template(
    #         self, video_selector, template_path,
    #         convert_image_before_compare=False):
    #     """
    #     Compare screen shot to template
    #     :param video_selector: STB slot
    #     :param template_path: reference image path
    #     :param convert_image_before_compare: Convert image before
    #             compare it for better result
    #     :return: Match level from 0.0 (no match) to 1.0 (perfect match)
    #     """
    #     frame_path = self.get_screenshot(video_selector)
    #     frame = InMemoryImage.from_file(frame_path)
    #     template = InMemoryImage.from_file(template_path)
    #     return VideoAnalyzer().compare_images(
    #         frame, template, convert_image_before_compare)
