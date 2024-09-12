"""
Class for in-memory frame data manipulation
"""

import urllib.request
import urllib.parse
import urllib.error

import cv2
import numpy as np

# no-member  quick-fix for opencv import errors
# pylint: disable=no-member


class InMemoryImage(object):
    """
    Represents image
    """

    _CV_IMWRITE_JPEG_QUALITY = 1
    _CV_IMWRITE_PNG_COMPRESSION = 16

    def __init__(self):
        self.image = None

    @staticmethod
    def from_cv2image(image):
        """
        Initialize from cv2 image
        :param image: cv2 image
        :return: this class object
        """
        result = InMemoryImage()
        result.image = image
        return result

    @staticmethod
    def from_file(path):
        """
        Loads image from file
        :param path: path to file
        :return: InMemoryImage object
        """
        image = cv2.imread(path)
        if image is None:
            raise IOError("Failed to read an image")
        result = InMemoryImage()
        result.image = image
        return result

    @staticmethod
    def from_url(path):
        """
        Loads image from URL
        :param path: file URL
        :return: InMemoryImage object
        """
        req = urllib.request.urlopen(path)
        if req.code != 200:
            raise IOError("Unexpected HTTP response code: '{0}'"
                          .format(req.code))
        arr = np.asarray(bytearray(req.read()), dtype=np.uint8)
        image = cv2.imdecode(arr, -1)
        req.close()
        if image is None:
            raise IOError("Failed to read an image")
        result = InMemoryImage()
        result.image = image
        return result

    @staticmethod
    def produce_img(byte_stream):
        """
        Reads the byte stream and returns the image object
        :param byte_stream: byte Stream
        :return: InMemoryImage object
        """
        arr = np.asarray(bytearray(byte_stream), dtype=np.uint8)
        image = cv2.imdecode(arr, -1)
        if image is None:
            raise IOError("Failed to read an image")

        result_image = InMemoryImage()
        result_image.image = image
        return result_image

    def to_png(self, path, compression=3):
        """
        Writes image to file
        :param path: path to file, extension should be .png
        :param compression: from 0 to 9, higher value means
        a smaller size, longer compression time
        """
        if self.image is None:
            raise ValueError("Image is not set")
        if not path.endswith('.png'):
            raise ValueError('Missing or unexpected path extension')
        cv2.imwrite(path, self.image,
                    [self._CV_IMWRITE_PNG_COMPRESSION, compression])

    def to_jpg(self, path, quality=95):
        """
        Writes image to file
        :param path: path to file, extension should be .jpg or .jpeg
        :param quality: image quality from 0  to 100 (higher is better)
        """
        if self.image is None:
            raise ValueError("Image is not set")
        if not (path.endswith('.jpg') or path.endswith('.jpeg')):
            raise ValueError('Missing or unexpected path extension')
        cv2.imwrite(path, self.image,
                    [self._CV_IMWRITE_JPEG_QUALITY, quality])

    def is_equal(self, other):
        """
        Check if contents of images are equal
        :param other: other InMemoryLike object
        :return: True if equal, else False
        """
        if self.image.shape != other.image.shape:
            return False
        for row_inx in range(self.image.shape[0]):
            row_s = self.image[row_inx]
            row_t = other.image[row_inx]
            for col_inx in range(self.image.shape[1]):
                pix_s = row_s[col_inx]
                pix_t = row_t[col_inx]
                if (pix_s != pix_t).any():
                    return False
        return True
