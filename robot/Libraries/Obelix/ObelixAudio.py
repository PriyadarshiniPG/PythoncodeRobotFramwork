#!/usr/bin/env python27
"""
Module handling interacting with Obelix Audio
"""

import json
import xml.etree.ElementTree as ET

import requests
from requests import HTTPError

from Libraries.Environment.AbstractAudio import AbstractAudio


class ObelixAudio(AbstractAudio):
    """
    Class for Obelix Audio component
    Note: ObelixHD.connect() must be invoked before use, but c-tor()
    """

    def __init__(self, rack_config):
        self._rack_pc_ip = rack_config['RACK_PC_IP']
        self._rack_type = rack_config['RACK_TYPE']

    def get_audio_level(self, audio_selector):
        """
        Method to get audio level
        :param audio_selector: audio selector, like hdmi slot number
        :return: integer with audio level
        """
        if self._rack_type == 'HD':
            audio_level = self._get_hd_audio_level(audio_selector)
        elif self._rack_type == 'SD' or self._rack_type:
            audio_level = self._get_sd_audio_level(audio_selector)
        else:
            raise ValueError('Wrong value of Obelix audio type')

        return audio_level

    def _get_hd_audio_level(self, audio_selector):
        audio_level_request_url = \
            "http://{0}/TestBox{1}/AudioDetection/".format(
                self._rack_pc_ip, audio_selector)
        body = {"command": "measurefreqencyband"}
        response = requests.post(
            audio_level_request_url, json=body, timeout=60)
        if response.status_code != 200:
            raise HTTPError("Audio measurement failed")
        data = json.loads(response.text)
        return int(data["audiolevel"])

    def is_audio_playing(self, audio_selector):
        """
        Method to check if audio is playing
        :param audio_selector: audio selector, like hdmi slot number
        :return: boolean indicating whether audio is playing
        """
        audio_level = self.get_audio_level(audio_selector)
        return bool(audio_level >= 20)

    def _get_sd_audio_level(self, audio_selector):
        headers = {'content-type': 'text/xml'}
        url = \
            'http://{0}/TestBox{1}/TestSpace/'.format(
                self._rack_pc_ip, audio_selector)
        xml_string = \
            """<?xml version="1.0"?>
            <AudioMeasureMent>
            <Command>Get level</Command>
            </AudioMeasureMent>"""
        response = requests.post(
            url, data=xml_string, headers=headers, timeout=60)
        xml_response = response.text.decode()
        root = ET.fromstring(xml_response)
        for child in root:
            if child.tag == 'Audio':
                returnval = child.attrib
                break
        if returnval:
            return int(returnval['Level'])

        raise Exception("returnval was not found")
