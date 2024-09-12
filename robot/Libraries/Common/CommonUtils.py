# Disable "Catching too general exception"
# pylint: disable=W0703
"""
Utility keywords
"""
import base64
import re
from collections import deque
from datetime import datetime
from xmlrpc.client import Binary
import socket
import requests
from robot.libraries.BuiltIn import BuiltIn
from PIL import Image


class CommonUtils(object):
    """
    Class implementing common utility keywords
    """
    # pylint: disable=too-few-public-methods,no-self-use
    def __init__(self):
        pass

    # def get_remote_library_git_hash(self):
    #     """
    #     :return: git hash that current working tree is based on
    #     """
    #     git_tools = GitTools(__file__)
    #     dirty_mark = '' if git_tools.is_clean() else ', but modified'
    #     return git_tools.get_hash() + dirty_mark

    def get_time_interval(self, start_time, end_time):
        """
        :return: event duration between start and end time of an event
        """

        start_time = start_time.strip()
        end_time = end_time.strip()

        start_time = datetime.strptime(start_time, "%H:%M")
        end_time = datetime.strptime(end_time, "%H:%M")
        event_duration = end_time - start_time
        event_duration = str(event_duration)
        if (event_duration.find(',') != -1 or
                event_duration.find('-1') != -1):
            split_string = event_duration.split(',')
            event_duration = (split_string[1]).strip()
        return event_duration

    @staticmethod
    def get_file_from_remote_library(file_path):
        """
        Return base64 encoded binary file to the pabot client
        :param file_path: File path to send
        """
        with open(file_path, 'rb') as binary_file:
            return Binary(base64.b64encode(binary_file.read()))

    @staticmethod
    def validate_detailpage_poster(url):
        """validate_detailpage_poster method"""
        try:
            response = requests.get(url)
            if response.status_code != 200:
                BuiltIn().log_to_console("\nPoster is Unavailable")
            if not response.content[:4] == b'\xff\xd8\xff\xe0':
                return False
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            return False
        return response

    @staticmethod
    def black_image_detection(path):
        """validate whether the image in path is a black screen or not"""
        try:
            im = Image.open(path, 'r')
        except Exception:
            print("Wrong path given")
            return False
        pix_val = list(im.getdata())
        pix_val_list = [x for sets in pix_val for x in sets]
        mean_pix_val = sum(pix_val_list)/len(pix_val_list)
        if mean_pix_val > 1:
            return False
        return True
#*************************CPE PERFORMANCE**************************************
    @staticmethod
    def compare_event_time(time1, time2):
        """compare two times in format hh:mm
        return 1 if time1 > time2, return 0 if both are equal
        return -1 if time1 < time2
        Note: Time compensation for midnight will be on time1"""
        #Extract time in valid format
        time1 = re.findall("[0-2][0-9]\:[0-5][0-9]", time1)[0]
        time2 = re.findall("[0-2][0-9]\:[0-5][0-9]", time2)[0]
        # convert both times to minutes
        time1 = time1.split(":")
        # Adjust time if hour value is 00 to compensate midnight time difference
        if time1[0] == "00":
            time1[0] = "24"
        time1 = int(time1[0])*60 + int(time1[1])
        time2 = time2.split(":")
        time2 = int(time2[0]) * 60 + int(time2[1])

        if time1 > time2:
            return 1
        elif time1 == time2:
            return 0
        else:
            return -1

    @staticmethod
    def rotate_list(list_object, position):
        """Rotates the given list by the specified positions
        Ex: rotate_list [1  2  3],  -1
        Returns [2  3  1]"""
        list_object = deque(list_object)
        list_object.rotate(int(position))
        return list(list_object)

