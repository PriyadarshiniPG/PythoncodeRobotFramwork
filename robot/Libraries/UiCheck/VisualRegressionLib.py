"""
This module provides a class for VisualRegression
"""
from os.path import join
from Libraries.panoramix.in_memory_image import InMemoryImage
from Libraries.Common.AppServicesRequestHandler import AppServicesRequestHandler

# too-few-public-methods - only one method is implemented so far
# pylint: disable=too-few-public-methods


class VisualRegressionLib(object):
    """
    This class provides methods for VisualRegression tests
    """

    def __init__(self, application_service_handler=AppServicesRequestHandler()):
        """
        Constructor, Initialization of application service handler
        :param application_service_handler: Application service handler object
        """
        self.as_handler = application_service_handler

    def get_screenshot_via_xap(self, ip_address, cpe_id, path, name="testfailure.png",
                               width=400, height=320, xap=True, compression_type='none'):
        """
        This method grabs screenshot via xap
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param path: Output folder
        :param xap: Is xap request
        :return: name of screenshot
        """
        payload = self.as_handler.get_screenshot(
            ip_address, cpe_id, 'http://127.0.0.1:8125/screenshot', width, height, xap=xap,
            compression_type=compression_type)
        byte_stream = payload.get('image').get('data')
        if not byte_stream:
            raise ValueError('Byte stream is empty')
        image = InMemoryImage.produce_img(byte_stream)
        screenshot_name = name + '.png'
        image.to_png(join(path, screenshot_name))

        return screenshot_name
