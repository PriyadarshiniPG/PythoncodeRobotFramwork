"""
Module contains class to grab video frame from file
"""

import cv2

from Libraries.panoramix.in_memory_image import InMemoryImage


class VideoFromFileGrabber(object):
    """
    Class contains method to grab video frame from file
    """

    # pylint: disable=too-few-public-methods

    @staticmethod
    def grab_frame(selector, resolution=None):
        """
        Grabs single frame from file

        :param resolution: requested resolution of image, or None for default
        :return: image object
        """
        # no-member - cv2 module bug
        # pylint: disable=no-member
        image = InMemoryImage.from_file(selector)
        if resolution is not None:
            image = cv2.resize(image.image, (resolution[0], resolution[1]))
        return image
