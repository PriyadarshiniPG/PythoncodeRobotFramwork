#!/usr/bin/env python27
"""
Module handling interacting with new Obelix Server
"""
import json
import logging
import os
import re
import time
from io import BytesIO

import requests
from PIL import Image
from requests import HTTPError

from Libraries.Environment.AbstractAudio import AbstractAudio
from Libraries.Environment.AbstractIRRemote import AbstractIRRemote
from Libraries.Environment.AbstractInit import AbstractInit
from Libraries.Environment.AbstractPDU import AbstractPDU
from Libraries.Environment.AbstractVideo import AbstractVideo
# from Libraries.teststream.video_analyzer import VideoAnalyzer

_IR_KEY_MAPPING = {
    'DVR': 'dvr button',
    'INTERACTIVE': 'interactive button',
    'HOME': 'home button',
    'MUTE': 'mute button',
    'ONDEMAND': 'on demand button',
    'PAGEDOWN': 'page down button',
    'PAGEUP': 'page up button',
    'RADIO': 'radio button',
    'UPC': 'UPC button',
    'VOL-': 'volume down button',
    'BACK': 'back button',
    'OK': 'OK button',
    'LEFT': 'arrow left button',
    'UP': 'arrow up button',
    'RIGHT': 'arrow right button',
    'DOWN': 'arrow down button',
    '0': '0 button',
    '1': '1 button',
    '2': '2 button',
    '3': '3 button',
    '4': '4 button',
    '5': '5 button',
    '6': '6 button',
    '7': '7 button',
    '8': '8 button',
    '9': '9 button',
    'POWER': 'power button',
    'RWD': 'rewind button',
    'FRWD': 'forward button',
    'STOP': 'stop button',
    'PLAY': 'play button',
    'PAUSE': 'pause button',
    'REC': 'record button',
    'FFWD': 'NOT-ADDED',
    'CHANNELUP': 'channel up button',
    'CHANNELDOWN': 'channel down button',
    'GUIDE': 'tvguide button',
    'TXT': 'digitext button',
    'MENU': 'NOT-ADDED',
    'LIVETV': 'NOT-ADDED',
    'VOD': 'NOT-ADDED',
    'PVR': 'NOT-ADDED',
    'INFO': 'info button',
    'HELP': 'help button',
    'RED': 'red button',
    'GREEN': 'green button',
    'YELLOW': 'yellow button',
    'BLUE': 'blue button',
}


class ObelixClient(AbstractInit, AbstractVideo, AbstractIRRemote,
                   AbstractPDU, AbstractAudio):
    """
    Class for Obelix Client component
    """

    def __init__(self, rack_pc_ip):
        self._rack_pc_ip = rack_pc_ip
        self._machine_name = os.environ.get('COMPUTERNAME')
        self._user_name = os.environ.get('USERNAME')
        self._sessions = {}

    def get_audio_level(self, audio_selector):
        """
        Method to get audio level
        :param audio_selector: audio selector, like hdmi slot number
        :return: integer with audio level
        """
        audio_level_request_url = 'http://{0}/TestSpace/{1}/Audio/Level/'. \
            format(self._rack_pc_ip, audio_selector)
        response = requests.get(audio_level_request_url)
        status_code = 'status code: {0}'.format(response.status_code)
        logging.info(status_code)
        if response.status_code != 200:
            if response.status_code == 504:
                return 0
            raise HTTPError('Audio measurement failed with status {0}'
                            .format(response.status_code))
        data = response.text
        audio_val = re.findall('-*\\d+', data)
        return int(audio_val[0])

    def is_audio_playing(self, audio_selector):
        """
        Method to check if audio is playing
        :param audio_selector: audio selector, like hdmi slot number
        :return: boolean indicating whether audio is playing
        """
        audio_level = self.get_audio_level(audio_selector)
        if audio_level < 0:
            return True
        return False

    @staticmethod
    def get_server_type(rack_pc_ip):
        """
            Fetching server version
        """
        url_server = 'http://{0}/Obelix/Guru/?message=version' \
            .format(rack_pc_ip)
        response = requests.get(url_server, timeout=5)
        status_code = 'status code: {0}'.format(response.status_code)
        logging.info(status_code)
        if response.status_code == 200:
            if '\"version\"' in response.text:
                result = 'Mondrian'
        elif response.status_code == 404:
            if '\"HTTP Error 404\"' or \
                    'Could not get any response' in response.text:
                result = 'Legacy'
        else:
            raise HTTPError('Invalid Response received with status {0}'
                            .format(response.status_code))
        return result

    def connect(self, selector):
        """
        Establish obelix connection.
        Applicable for newer version
        :param selector: STB slot
        """
        url_obelix = "http://{0}/TestSpace/{1}/Connect/? \
            user={2}&machine={3}". \
            format(self._rack_pc_ip, selector,
                   self._user_name, self._machine_name)
        response = requests.get(url_obelix, timeout=20)
        status_code = 'status code: {0}'.format(response.status_code)
        logging.info(status_code)
        response_body = json.loads(response.text)
        if response.status_code == 200:
            self._sessions[selector] = response_body['Session']
            logging.info('Obelix Connection Success')
        else:
            if response.status_code in (400, 403):
                message = response_body['Message']
                logging.info(message)
            raise HTTPError('Obelix Connection Failed with status {0}'
                            .format(response.status_code))

    def disconnect(self, selector):
        """
        Disconnect obelix connection.Applicable for newer version
        :param selector: STB slot
        """
        session_key = self._sessions[selector]
        url_obelix = "http://{0}/TestSpace/{1}/Disconnect/?" \
                     "user={2}&sessionKey={3}". \
            format(self._rack_pc_ip, selector,
                   self._user_name, session_key)
        response = requests.get(url_obelix, timeout=20)
        status_code = 'status code: {0}'.format(response.status_code)
        logging.info(status_code)
        response_body = json.loads(response.text)
        if response.status_code == 200:
            logging.info('Obelix Disconnect Success')
        else:
            if response.status_code in (400, 401, 403):
                message = response_body['Message']
                logging.info(message)
            raise HTTPError('Obelix Disconnect Failed with status {0}'
                            .format(response.status_code))

    def get_power_level(self, selector, pdu_selector):
        """
        Function to get power level
        :param selector: STB slot
        :param pdu_selector: pdu slot
        """
        raise NotImplementedError('Not implemented yet in Obelix4')

    def power_cycle(self, selector, pdu_selector):
        """
        Method to power cycle
        :param selector: STB slot
        :param pdu_selector: pdu slot - Ignored, selector is used
        """
        self._power_operation_rest(selector, 'PowerCycle')

    def _power_operation_rest(self, selector, power_state):
        """
        Function to do power operation for rest pdu
        :param selector: STB slot
        :param power_state: power state for obelix
        """
        session_key = self._sessions[selector]
        rack_pc_url = \
            'http://{0}/TestSpace/{1}/Power/Set/?state={2}' \
            '&sessionKey={3}'.format(
                self._rack_pc_ip, selector, power_state, session_key)
        pdu_req = requests.get(rack_pc_url, timeout=20)
        status_code = 'status code: {0}'.format(pdu_req.status_code)
        logging.info(status_code)
        if pdu_req.status_code != 200:
            if pdu_req.status_code in (400, 401, 403):
                message = re.findall(r'ResponseMessage=\"(.+?)\"',
                                     pdu_req.text)[0]
                logging.info(message)
            elif pdu_req.status_code == 429:
                logging.info('Too many request, '
                             'client should resend the request')
            raise HTTPError('{0} failed with status {1}'
                            .format(power_state, pdu_req.status_code))

    def send_key_ir(self, selector, remote_key):
        """"
        Emulates user action to send a key aka press a button
        on a given cpe over IR
        key should be given from the _IR_KEY_MAPPING Dictionary

        Examples:
        send key ir  0
        send key ir  CHANNELUP
        :param selector: STB slot
        :param remote_key: remote key code to send
        """
        session_key = self._sessions[selector]
        url = \
            'http://{0}/TestSpace/{1}/Handset/Send/?cmd={2}' \
            '&sessionKey={3}'.format(
                self._rack_pc_ip, selector,
                _IR_KEY_MAPPING[remote_key], session_key)
        response = requests.get(url, timeout=20)
        status_code = 'status code: {0}'.format(response.status_code)
        logging.info(status_code)
        if response.status_code != 200:
            if response.status_code in (400, 401, 403):
                message = re.findall(r'ResponseMessage=\"(.+?)\"',
                                     response.text)[0]
                logging.info(message)
            raise HTTPError('Sending IR key failed with status {0}'
                            .format(response.status_code))

    def get_screenshot(self, video_selector):
        """
        Function to get screenshot
        :param video_selector: STB slot
        :return: path to taken screenshot
        """
        timestamp = time.strftime('%Y-%m-%d_%H-%M-%S')
        url = 'http://{0}/TestSpace/{1}/ScreenShot/' \
            .format(self._rack_pc_ip, video_selector)
        response = requests.get(url, timeout=20)
        status_code = 'status code: {0}'.format(response.status_code)
        logging.info(status_code)
        if response.status_code not in (200, 504):
            raise HTTPError('Getting screenshot failed with status {0}'
                            .format(response.status_code))
        screenshot_path = os.path.join(
            os.getcwd(), 'screenshot', 'stb' + str(video_selector))
        if not os.path.exists(screenshot_path):
            os.makedirs(screenshot_path)
        screenshot_name = 'Screenshot_' + timestamp + '.png'
        screenshot_path = os.path.join(screenshot_path, screenshot_name)
        logging.info(screenshot_path)

        image_data = response.content
        if response.status_code == 504:
            current_path = os.path.realpath(__file__)
            current_path = current_path.rsplit("\\", 2)[0]
            template_name = 'StandByObelix.png'
            temp_image = os.path.join(
                current_path, 'UiCheck', 'template', template_name)
            with open(temp_image, 'rb') as reference_file:
                image_data = reference_file.read()

        # getting the size of the image and then resizing it and saving
        image_data = Image.open(BytesIO(image_data))
        image_width = image_data.size[0]

        if image_width != 1920:
            image_data = image_data.resize((1920, 1080), Image.ANTIALIAS)
        image_data.save(screenshot_path)
        return os.path.abspath(screenshot_path)

    def is_video_playing(self, video_selector):
        """
        Function to check video playing or not
        Return True if video play detected
        Return False if video frozen or still screen like black screen
        :param video_selector: STB slot
        """
        headers = {'content-type': 'application/json'}
        url = 'http://{0}/TestSpace/{1}/Scripter/Testing/Video/'. \
            format(self._rack_pc_ip, video_selector)
        data = {'command': 'movingvideo',
                'judgement': 'or',
                'duration': '5',
                'percentageDeviation': '3'}
        json_data = json.dumps(data)
        response = requests.post(url, data=json_data,
                                 headers=headers, timeout=20)
        response_body = json.loads(response.text)
        status_code = 'status code: {0}'.format(response.status_code)
        logging.info(status_code)
        if response.status_code == 200:
            if '\"passed\"' in response.text:
                result = True
            elif '\"failed\"' in response.text:
                if '504' in response_body['message']:
                    logging.info('Cannot process request, '
                                 'STB in stand by mode.')
                result = False
        else:
            raise HTTPError('Invalid Response received with status {0}'
                            .format(response.status_code))
        return result

    def is_black_screen(self, video_selector):
        """
        Function to check black screen or not
        Return True if black screen detected
        Return False if video playing
        :param video_selector: STB slot
        """
        headers = {'content-type': 'application/json'}
        url = 'http://{0}/TestSpace/{1}/Scripter/SVC/Blackscreen/'. \
            format(self._rack_pc_ip, video_selector)
        data = {'command': 'blackscreen',
                'judgement': 'and',
                'percentageDeviation': '3'}
        json_data = json.dumps(data)
        response = requests.post(url, data=json_data,
                                 headers=headers, timeout=20)
        status_code = 'status code: {0}'.format(response.status_code)
        logging.info(status_code)
        if response.status_code == 200:
            if '\"passed\"' in response.text:
                result = True
            elif '\"failed\"' in response.text:
                result = False
        else:
            if response.status_code == 504:
                logging.info('Cannot process request, '
                             'STB in stand by mode.')
                result = False
            raise HTTPError('Invalid Response received with status {0}'
                            .format(response.status_code))
        return result

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
    #     return VideoAnalyzer().compare_images(frame, template,
    #                                           convert_image_before_compare)

    def power_off(self, selector, pdu_selector):
        """
        Method to power off
        :param selector: STB slot
        :param pdu_selector: pdu slot - Ignored, selector is used
        """
        self._power_operation_rest(selector, 'PowerOff')

    def power_on(self, selector, pdu_selector):
        """
        Method to power on
        :param selector: STB slot
        :param pdu_selector: pdu slot - Ignored, selector is used
        """
        self._power_operation_rest(selector, 'PowerOn')
