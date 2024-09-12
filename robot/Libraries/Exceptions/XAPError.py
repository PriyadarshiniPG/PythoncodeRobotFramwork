#!/usr/bin/env python27
"""
Description         Module handling XAP Errors

"""


class XAPError(Exception):
    """
    Base class to throw XAP Errors
    """

    def __init__(self, logger):
        super(XAPError, self).__init__()
        self._logger = logger


class XAPResponseError(XAPError):
    """
    Raised when any error in response comes from XAP
    """

    def __init__(self, json_response, logger):
        super(XAPResponseError, self).__init__(logger)
        self.json_response = json_response
        if self.json_response.status_code == 500 or \
                (self.json_response.status_code in range(200, 300)):
            self.json_response.log_error = "Error in response from XAP: " + \
                                           self.json_response.text
        else:
            self.json_response.log_error = "Error in communication " \
                                           "between consumer and XAP: " \
                                           + self.json_response.text
        self._logger.error(self.json_response.log_error)
        self._logger.error("Error code received in response: "
                           + str(self.json_response.status_code))


class XAPPayloadError(XAPError):
    """
    Raised when any error in Payload comes from XAP
    """

    def __init__(self, logger, error_msg=""):
        super(XAPPayloadError, self).__init__(logger)
        self._logger.error("Error in payload from XAP: " + error_msg)
