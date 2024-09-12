"""
This module provides a class for debugging
"""
import cv2

from Libraries.Common.utils import LogArtifactStore
from Libraries.panoramix.in_memory_image import InMemoryImage
from Libraries.Common.AppServicesRequestHandler import AppServicesRequestHandler

# too-few-public-methods - only one method is implemented so far
# pylint: disable=too-few-public-methods


class DebugTools(object):
    """
    This class provides methods for debugging
    """

    def __init__(self, application_service_handler=AppServicesRequestHandler()):
        """
        Constructor, Initialization of application service handler
        :param application_service_handler: Application service handler object
        """
        self._as_handler = application_service_handler
        self._log_store = LogArtifactStore()

    def get_screenshot_by_debug_tools(self, ip_address, cpe_id,
                                      resolution=None, width=400, height=320, xap=True):
        """
        This method grabs screenshot using STB's debug tools
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param resolution: resolution of the screenshot
        :param xap: Is xap request
        :return: path to the created screenshot
        """
        # no-member - cv2 module bug
        # pylint: disable=no-member,len-as-condition
        payload = self._as_handler.get_screenshot(
            ip_address, cpe_id, 'http://127.0.0.1:8125/screenshot', width, height, xap=xap)
        byte_stream = payload.get('image').get('data')
        if len(byte_stream) == 0:
            raise ValueError('Byte stream is empty')
        image = InMemoryImage.produce_img(byte_stream)
        if resolution is not None:
            image.image = cv2.resize(
                image.image, (resolution[0], resolution[1]))
        path = self._log_store.new_path('', 'dbg_scrn', 'png')
        image.to_png(path)
        return path
