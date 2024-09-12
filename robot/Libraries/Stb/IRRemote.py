#!/usr/bin/env python27
# pylint: disable=invalid-name,too-few-public-methods
"""
Description         Module handling sending keys over IR
"""
import requests
from requests import HTTPError

from Libraries.Environment.AbstractIRRemote import AbstractIRRemote

IR_KEYMAPPING = {
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


class IRRemote(AbstractIRRemote):
    """"
    Methods and variables related with sending cpe keys over IP
    Note: ObelixHD.connect() must be invoked before use, but c-tor()
    """

    def __init__(self, rack_pc_ip):
        self._rack_pc_ip = rack_pc_ip

    def send_key_ir(self, selector, remote_key):
        """"
        Emulates user action to send a key aka press a button
        on a given cpe over IR
        key should be given from the IR_keyMapping Dictionary

        Examples:
        send key ir  0
        send key ir  CHANNELUP
        :param selector: STB slot
        :param remote_key: remote key code to send
        """
        headers = {'content-type': 'text/xml'}
        url = 'http://{0}/TestBox{1}/Handset/'.format(
            self._rack_pc_ip, selector)
        xml_string = """<?xml version="1.0"?>
        <ScripterHandsetCommand
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        Command="{0}" RepeatCount="0" />
        """.format(IR_KEYMAPPING[remote_key])
        response = requests.post(
            url, data=xml_string, headers=headers, timeout=20)
        if response.status_code != 200:
            raise HTTPError('Sending IR key failed')
