#!/usr/bin/env python27
"""
Module handling sending remote keys over application services
"""
import time

from Libraries.Stb.keymap import KEY_MAP
from Libraries.Common.AppServicesRequestHandler import AppServicesRequestHandler

# pylint: disable=R0913,no-self-use


class IPRemote(object):
    """
    Methods and variables related with sending cpe keys over
    application service
    """

    def __init__(self, application_service_handler=AppServicesRequestHandler()):
        """
        Constructor, Initialization of application service handler
        :param application_service_handler: Application service handler object
        """
        self.as_handler = application_service_handler

    def send_key_event_via_as(
            self, ip_address, cpe_id, key, keystate, xap=True):
        """
        Send a Remote Control key event
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param key: One of the keys
        :param keystate: State of the key
        :param xap: Is xap request
        :return: JSON response of request
        """

        url = 'http://127.0.0.1:10014/keyinjector/emulateuserevent/' \
              + key + '/' + keystate
        return self.as_handler.get(
            ip_address, cpe_id, url, xap=xap, stream=True, timeout=10)

    def send_key_via_as(
            self, ip_address, cpe_id, remote_key, delay=0.1, xap=True):
        """
        Emulates user action to send a key aka press a button
        Default delay is set to 200 milliseconds
        key should be given from the keyMapping Dictionary
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param remote_key: Remote key
        :param delay: delay
        :param xap: Is xap request
        :return: boolean
        """
        if remote_key.isdigit():
            for key in remote_key:
                self.send_key_event_via_as(
                    ip_address, cpe_id, KEY_MAP[key], '8300', xap=xap)
                time.sleep(float(delay))
        else:
            self.send_key_event_via_as(
                ip_address, cpe_id, KEY_MAP[remote_key], '8300', xap=xap)
        return True

    def send_long_key_press_via_as(
            self, ip_address, cpe_id, remote_key, duration, xap=True):
        """
        Emulates the user action of press and hold a key during a certain
        time (in seconds) aka long press
        keys should be given from the IP_keyMapping Dictionary
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param remote_key: Remote key
        :param duration: long key press duration
        :param xap: Is xap request
        :return: boolean
        """
        duration = float(duration)
        actual_time = time.time()
        time_with_delay = actual_time + duration

        self.send_key_event_via_as(ip_address, cpe_id, KEY_MAP[remote_key],
                                   '8000', xap=xap)
        try:
            while time.time() <= time_with_delay:
                self.send_key_event_via_as(
                    ip_address, cpe_id, KEY_MAP[remote_key], '8200', xap=xap)
        except RuntimeError:
            pass

        self.send_key_event_via_as(ip_address, cpe_id, KEY_MAP[remote_key],
                                   '8100', xap=xap)
        return True

    def send_key_sequence_event_via_as(
            self, ip_address, cpe_id, sequence, xap=True):
        """
        Send a Remote Control sequence key event
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param sequence: keys Sequence
        :param xap: Is xap request
        :return: JSON response of request
        """
        headers = {"Content-type": "application/json"}
        url = 'http://127.0.0.1:10014/keyinjector/emulateuserevent'
        return self.as_handler.post(
            ip_address, cpe_id, url, body=sequence, headers=headers, xap=xap)

    def send_key_sequence_via_as(
            self, ip_address, cpe_id, keys_array, keystate=8300,
            payload="source=2", delay=1000, xap=True):
        """
        Emulates user action to send sequence of key aka press a button
        Default delay is set to 200 milliseconds
        key should be given from the keyMapping Dictionary
        How to use it - example:
            ${keys_to_send}    Create List    MENU    GUIDE    BACK
            send key sequence via as    ${STB_IP}    ${CPE_ID}    ${keys_to_send}
        Examples:
        {"sequence":[{"key":"c0","state":"8300","payload":"source=2","delay":100},
        {"key":"8d","state":"8300","payload":"source=2","delay":100}]}
        Characters On KeyBoard - TODO - SENT STRING DIRECTLY
        {"sequence":[{"key":"61","state":"8000","payload":"source=4","delay":100},
        {"key":"61","state":"8000","payload":"source=4","delay":100}]}
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param keys_array: Array of Remote keys
        :param keystate: state of the key 8000, 8100, 8200 or 8300. By default 8300
                   Key state (8000 - DOWN, 8200 - REPEAT, 8100 - UP)
        :param payload: source=2 or source=4 (for letters on keyword), by default source=2
        :param delay: Delay after the key in the given state injected before next injection
        :param xap: Is xap request
        :return: boolean
        """
        keys_sequence_array = []
        for key in keys_array:
            if str(key) in KEY_MAP:
                key = KEY_MAP[str(key)]
            key_sequence_json = {
                'key': key,
                'state': str(keystate),
                'payload': payload,
                'delay': delay
            }
            keys_sequence_array.append(key_sequence_json)
        sequence = {'sequence': keys_sequence_array}
        self.send_key_sequence_event_via_as(ip_address, cpe_id, sequence, xap=xap)
        return True

    def send_key_multiple_times_via_as(
            self, ip_address, cpe_id, times, key, keystate=8300,
            payload="source=2", delay=1000, xap=True):
        """
        Emulates user action to send a sequence of key aka press a button
        Default delay is set to 200 milliseconds
        key should be given from the keyMapping Dictionary
        How to use it - example:
            send key multiple times via as    ${STB_IP}    ${CPE_ID}    10    BACK

        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param keys_array: Array of Remote keys
        :param keystate: state of the key 8000, 8100, 8200 or 8300. By default 8300
                   Key state (8000 - DOWN, 8200 - REPEAT, 8100 - UP)
        :param payload: source=2 or source=4 (for letters on keyword), by default source=2
        :param delay: Delay after the key in the given state injected before next injection
        :param xap: Is xap request
        :return: boolean
        """
        i = 0
        keys_array = []
        while i < int(times):
            keys_array.append(key)
            i += 1
        result = self.send_key_sequence_via_as(ip_address, cpe_id, keys_array, keystate=keystate,
                                               payload=payload, delay=delay, xap=xap)
        return result
