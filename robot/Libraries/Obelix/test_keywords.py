# pylint: disable=unused-argument
# Disabled pylint "unused-argument" complaining on args for mock patches'

"""Unit tests of Obelix library's keywords for Robot Framework.

Tests use mock module and do not send real requests to real Obelix.
The global function debug() can be used for testing requests to real Obelix.

v0.0.1 - Riddam Jain: Implementation unittest:
    requests and Obelix API details-
    added test_connect,
    test_disconnect,
    test_pass_command,
    test_black_screen,
    test_image_comparison,
    test_ocr_extract,
    test_image_text,
    test_moving_video,test_standby
"""
import unittest
import json
try:
    import mock
except ImportError:
    import unittest.mock as mock
from .keywords import Keywords

CPE_ID = "3C36E4-EOSSTB-003356472104"
USER = "Horizon 4"
MACHINE = "TEST MACHINE"
COMMAND = "ok button"
LAB_CONF = {
    "MOCK": {
        "host":"10.64.12.154",
        "slot":"1",
        "pin": "0000",
        "cpeid":"3C36E4-EOSSTB-003359049404"
    }
}

SAMPLE_OBELIX_CONNECT = """{
    "Response": "Success",
    "Message": "Success",
    "Session": "9870fba0-f9fe-4406-a463-759f335788b1"
}"""

SAMPLE_OBELIX_DISCONNECT = """{
    "Response": "Success",
    "Message": "Success"
}"""

SAMPLE_OBELIX_REMOTE_COMMANDS = """<ObelixServerResponse \
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" \
xmlns:xsd="http://www.w3.org/2001/XMLSchema" \
RequestResponse="Success" ResponseMessage="Success" />"""

SAMPLE_OBELIX_OCR = """{
    "activity": "ocr",
    "status": "Success",
    "judgment": "passed",
    "message": "Q TV GUIDE ON DEMAND MY TV APPS"
}"""

SAMPLE_OBELIX_MOVING_VIDEO = """{
    "activity": "movingvideo",
    "status": "Success",
    "judgment": "passed",
    "session": "68f5af5d-f610-4017-8593-c5eeeeb91bf1",
    "message": "Moving Video has been detected in 4 Frames. Screenshots can be found in the session folder"
}"""

SAMPLE_OBELIX_IMAGE_COMPARISON = """{
    "activity": "comparison",
    "status": "Success",
    "judgment": "passed",
    "message": "Match found for reference image"
}"""

SAMPLE_OBELIX_STANDBY = """{
    "activity": "standby",
    "status": "Success",
    "judgment": "passed",
    "session": "9a279569-22fb-4a1d-8b91-d1012820f3b8",
    "message": "CPE - standby mode."
}"""

SAMPLE_OBELIX_BLACKSCREEN = """{
    "activity": "blackscreen",
    "status": "Success",
    "judgment": "passed",
    "session": "88b5903f-6973-4b00-bf74-d5f9bf6b22fb",
    "message": "Blackscreen detected"
}"""


def mock_requests_get(*args, **kwargs):
    """A method imitates sending requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    url = args[0]
    response_body = None
    if USER and MACHINE in url:
        response_body = SAMPLE_OBELIX_CONNECT
        code = 200
        reason = "OK"
    elif USER in url:
        response_body = SAMPLE_OBELIX_DISCONNECT
        code = 200
        reason = "OK"
    elif COMMAND in url:
        response_body = SAMPLE_OBELIX_REMOTE_COMMANDS
        code = 200
        reason = "OK"
    response_data = dict(text=response_body, status_code=code, reason=reason)
    return type("", (), response_data)()

def mock_requests_post(*args, **kwargs):
    """A method imitates sending requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    data = kwargs["data"]
    if "blackscreen" in data:
        response_body = SAMPLE_OBELIX_BLACKSCREEN
        code = 200
        reason = "OK"
    elif "comparison" in data:
        response_body = SAMPLE_OBELIX_IMAGE_COMPARISON
        code = 200
        reason = "OK"
    elif "ocr" in data:
        response_body = SAMPLE_OBELIX_OCR
        code = 200
        reason = "OK"
    elif "standby" in data:
        response_body = SAMPLE_OBELIX_STANDBY
        code = 200
        reason = "OK"
    elif "movingvideo" in data:
        response_body = SAMPLE_OBELIX_MOVING_VIDEO
        code = 200
        reason = "OK"
    response_data = dict(text=response_body, status_code=code, reason=reason)
    return type("", (), response_data)()


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None

@mock.patch("requests.get", side_effect=mock_requests_get)
def get_obelix_connect(*args):
    """Mocked obelix connect call"""

    lab_conf, user, machine = args[:-1]
    obelix_ip = lab_conf["host"]
    slot = lab_conf["slot"]
    return Keywords().connect(obelix_ip, slot, user, machine)

@mock.patch("requests.get", side_effect=mock_requests_get)
def get_obelix_disconnect(*args):
    """Mocked obelix disconnect call"""

    lab_conf, user = args[:-1]
    obelix_ip = lab_conf["host"]
    slot = lab_conf["slot"]
    return Keywords().disconnect(obelix_ip, slot, user)

@mock.patch("requests.get", side_effect=mock_requests_get)
def get_obelix_pass_command(*args):
    """Mocked obelix pass command call"""

    lab_conf, command = args[:-1]
    obelix_ip = lab_conf["host"]
    slot = lab_conf["slot"]
    return Keywords().pass_command(obelix_ip, slot, command)

@mock.patch("requests.post", side_effect=mock_requests_post)
def get_obelix_check_standby(*args):
    """Mocked obelix standby call"""

    lab_conf = args[0]
    obelix_ip = lab_conf["host"]
    slot = lab_conf["slot"]
    return Keywords().check_standby(obelix_ip, slot)

@mock.patch("requests.post", side_effect=mock_requests_post)
def get_obelix_moving_video_detection(*args):
    """Mocked obelix moving video detection call"""

    lab_conf, deviation, samplerate = args[:-1]
    obelix_ip = lab_conf["host"]
    slot = lab_conf["slot"]
    return Keywords().moving_video_detection(obelix_ip, slot, deviation, samplerate)

@mock.patch("requests.post", side_effect=mock_requests_post)
def get_obelix_ocr_extract(*args):
    """Mocked obelix ocr extract call"""

    lab_conf, x_size, y_size, widthx, heighty, rescale, contrast, threshold, dilate = args[:-1]
    return Keywords().ocr_extract(lab_conf, x_size, y_size, widthx,
                                  heighty, rescale, contrast, threshold, dilate)

@mock.patch("requests.post", side_effect=mock_requests_post)
def get_obelix_image_text(*args):
    """Mocked obelix complete image text call"""

    lab_conf, rescale, contrast, threshold, dilate = args[:-1]
    return Keywords().get_image_text(lab_conf, rescale, contrast, threshold, dilate)

@mock.patch("requests.post", side_effect=mock_requests_post)
def get_obelix_image_comparison(*args):
    """Mocked obelix image comparison call"""

    lab_conf, deviation, x_size, y_size, width, height, filename = args[:-1]
    obelix_ip = lab_conf["host"]
    slot = lab_conf["slot"]
    return Keywords().image_comparison(obelix_ip, slot, deviation, x_size,
                                       y_size, width, height, filename)

@mock.patch("requests.post", side_effect=mock_requests_post)
def get_obelix_black_screen(*args):
    """Mocked obelix black screen call"""

    lab_conf, deviation, deltax, deltay, width, height = args[:-1]
    return Keywords().black_screen_detection(lab_conf, deviation, deltax, deltay, width, height)



class TestKeyword_Obelix(TestCaseNameAsDescription):
    """Class contains unit tests of Obelix keywords."""

    def test_connect(self):
        """Positive unit test of parsing successful Obelix response text."""
        test = get_obelix_connect(LAB_CONF["MOCK"], USER, MACHINE)
        self.assertEqual(test, True)

    def test_disconnect(self):
        """Positive unit test of parsing successful Obelix response text."""
        test = get_obelix_disconnect(LAB_CONF["MOCK"], USER)
        self.assertEqual(test, True)

    def test_pass_command(self):
        """Positive unit test of parsing successful Obelix response text."""
        test = get_obelix_pass_command(LAB_CONF["MOCK"], COMMAND)
        self.assertEqual(test, True)

    def test_black_screen(self):
        """Positive unit test of parsing successful Obelix response text."""
        test = get_obelix_black_screen(LAB_CONF["MOCK"], "10", "100", "200",
                                       "300", "300")
        self.assertEqual(test, True)

    def test_image_comparison(self):
        """Positive unit test of parsing successful Obelix response text."""
        test = get_obelix_image_comparison(LAB_CONF["MOCK"], "10", "100",
                                           "200", "300", "300", "abc.jpeg")
        self.assertEqual(test, True)

    def test_ocr_extract(self):
        """Positive unit test of parsing successful Obelix response text."""
        test = get_obelix_ocr_extract(LAB_CONF["MOCK"], "100", "200", "200", "200",
                                      "2,2", "170", "", "0,50")
        self.assertEqual(test.decode("utf-8"),
                         json.loads(SAMPLE_OBELIX_OCR).get('message'))

    def test_image_text(self):
        """Positive unit test of parsing successful Obelix response text."""
        test = get_obelix_image_text(LAB_CONF["MOCK"], "2,2", "170", "", "0,50")
        self.assertEqual(test,
                         json.loads(SAMPLE_OBELIX_OCR).get('message'))

    def test_standby(self):
        """Positive unit test of parsing successful Obelix response text."""
        test = get_obelix_check_standby(LAB_CONF["MOCK"])
        self.assertEqual(test, True)

    def test_moving_video(self):
        """Positive unit test of parsing successful Obelix response text."""
        test = get_obelix_moving_video_detection(LAB_CONF["MOCK"], "2", "500")
        self.assertEqual(test, True)


def suite_obelixserver():
    """Function to make the test suite for unittests"""

    return unittest.makeSuite(TestKeyword_Obelix, "test")


def run_tests():
    """A function to run unit tests (real Obelix Service will not be used)."""

    suite = suite_obelixserver()
    unittest.TextTestRunner(verbosity=2).run(suite)


if __name__ == "__main__":
    run_tests()
