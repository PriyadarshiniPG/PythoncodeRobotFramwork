#!/usr/bin/env python27
"""
Description         Module handling interacting with Obelix HD video
Author:				ropaul@libertyglobal.com
"""
import os
import time

import requests

from Libraries.Environment.AbstractInit import AbstractInit
from Libraries.Environment.AbstractVideo import AbstractVideo
# from Libraries.teststream.video_analyzer import VideoAnalyzer


# too-many-boolean-expressions -> use of multiple or/and required
# instead of breaking it into nested if-else
# pylint: disable=too-many-boolean-expressions


class ObelixHDVideo(AbstractVideo):
    """
    Class for Obelix HD Video component
    Note: ObelixHD.connect() must be invoked before use, but c-tor()
    """

    def __init__(self, rack_pc_ip):
        self._rack_pc_ip = rack_pc_ip

    def get_screenshot(self, video_selector):
        """
        Method to get screenshot
        :param video_selector: STB slot
        :return: path to taken screenshot
        """
        timestamp = str(time.strftime('%Y-%m-%d_%H-%M-%S'))
        url = 'http://{0}/TestBox{1}/ScreenShot/'.format(
            self._rack_pc_ip, video_selector)
        response = requests.get(url)

        screenshot_path = os.path.join(
            os.getcwd(), 'screenshot', 'stb' + str(video_selector))

        if not os.path.exists(screenshot_path):
            os.makedirs(screenshot_path)
        screenshot_name = 'Screenshot_' + timestamp + '.png'
        screenshot_path = os.path.join(screenshot_path, screenshot_name)
        with open(screenshot_path, 'wb') as output_file:
            output_file.write(response.content)
        return os.path.abspath(screenshot_path)

    def is_video_playing(self, video_selector):
        """
        Method to check video playing or not
        Return True if video play detected
        Return False if video frozen or still screen like black screen
        :param video_selector: STB slot
        """
        headers = {'content-type': 'application/json'}
        url = 'http://{0}/TestBox{1}/MovingVideoDetection/'.format(
            self._rack_pc_ip, video_selector)
        body_string = """{
            "command": "fullMovingVideoDetection",
            "durationInSeconds": 5,
            "percentageDeviation": 5}"""

        response = requests.post(
            url, data=body_string, headers=headers, timeout=20)
        if "true" in response.text:
            result = True
        if "false" in response.text:
            result = False
        return result

    def is_black_screen(self, video_selector):
        """
        Method to check black screen or not
        Return True if black screen detected
        Return False if video playing
        :param video_selector: STB slot
        """
        headers = {'content-type': 'application/json'}
        url = 'http://{0}/TestBox{1}/BlackScreenDetection/'.format(
            self._rack_pc_ip, video_selector)
        body_string = """{
            "command": "fullBlackScreenDetection",
            "durationInSeconds": 5,
            "percentageDeviation": 10}"""
        response = requests.post(
            url, data=body_string, headers=headers, timeout=20)
        if "true" in response.text:
            result = True
        if "false" in response.text:
            result = False
        return result

    # def compare_screen_to_template(
    #         self, video_selector, template_path,
    #         convert_image_before_compare=False):
    #     """
    #     Compare screen shot to template
    #     :param video_selector: HDMI slot
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


class ObelixHD(AbstractInit):
    """
        Main class for Obelix HD Rack
    """

    def __init__(self, rack_config):
        self._rack_pc_ip = rack_config['RACK_PC_IP']
        self._red_rat_ir_ip = rack_config['RED_RAT_IR_IP']

    def connect(self, selector):
        """
        Establish obelix connection.
        Applicable for newer version
        :param selector: STB slot
        """
        url_obelix = "http://{0}/TestBox{1}/Connect/".format(
            self._rack_pc_ip, selector)
        headers = {'content-type': 'text/xml'}
        body = """<?xml version="1.0" encoding="utf-8"?>
        <ScripterConnectRequest xmlns:xsi="http://www.w3.org/
        2001/XMLSchema-instance" \
        xmlns:xsd="http://www.w3.org/2001/XMLSchema" \
        UserName="cpesi" UserMachine="testPC">
        <HandsetDetails HandsetType="d4a" SimulatorType="irnetbox" \
        SimulatorLocation="{0}" SimulatorSlot="{1}" />
        </ScripterConnectRequest>""".format(
            self._red_rat_ir_ip, selector)
        response = requests.post(url_obelix, data=body,
                                 headers=headers,
                                 timeout=10)

        responsetext = str(response.content)
        if "RequestResponse=\"accepted\"" in responsetext:
            print("Obelix Connection Success")
        # If its already checked out
        elif "Unable to connect to this test space" + \
                " because it is already checked out" in \
                responsetext:
            print("Obelix Connection Success")
        else:
            raise Exception("Obelix Connect")

    def disconnect(self, selector):
        """
        Disconnect obelix connection.Applicable for newer version
        :param selector: STB slot
        """
        url_obelix = "http://{0}/TestBox{1}/Disconnect/".format(
            self._rack_pc_ip, selector)
        headers = {'content-type': 'text/xml'}
        body = """<?xml version="1.0" encoding="utf-8"?> \
        <ScripterDisconnectRequest xmlns:xsi="http://www.w3.org/
        2001/XMLSchema-instance" \
        xmlns:xsd="http://www.w3.org/2001/XMLSchema" \
        UserName="cpesi" UserMachine="testPC"></ScripterDisconnectRequest>"""
        response = requests.post(
            url_obelix, data=body, headers=headers, timeout=10)
        responsetext = str(response.content)
        if "RequestResponse=\"accepted\"" in responsetext:
            print("Obelix Disconnect Success")
        else:
            raise Exception("Obelix Disconnect Failed")
