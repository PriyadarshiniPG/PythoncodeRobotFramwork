# -*- coding: utf-8 -*-
"""Unit tests of ACS library's keywords for Robot Framework.

Tests use mock module and do not send HTTP requests to real servers.
The global function debug() can be used for testing real requests.
"""
import os
import unittest
try:
    import mock
except ImportError:
    import unittest.mock as mock
from .keywords import Keywords


CPE_ID = "3C36E4-EOSSTB-003356472104"

FIRMWARE = "DCX960__-mon-dbg-00.01-023-aa-AL-20170622153441-un000"

LAB_NAME = "lab5a"

LABS_CONF = {
    "lab5a": {"ACS": {"host": "172.30.183.25", "user": "admin", "password": "ax"}},
    "Mock": {"ACS": {"host": "127.0.0.1", "user": "abc", "password": "def"}}
}

CPE_STATUS_RESPONSE_FNAME = "test_sample_cpe_status.html"

CPE_DETAILS_RESPONSE_FNAME = "test_sample_cpe_details.html"

CPE_STATUS = {"status": True, "status_cpe": "PENDING (1)"}

CPE_DETAILS = {
    "status": True,
    "ip": "10.11.80.2",
    "firmware_url": "http://omwssu.lab5a.nl.dmdsdp.com/swimages/dawn/software/dcx960/1/",
    "last_msg": "Wed Aug  2 12:54:13 2017"
}


def mock_requests_get(*args, **kwargs):
    """A method imitates sending GET requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    url = args[0]
    headers = kwargs["headers"] if "headers" in kwargs else None
    folder = os.path.dirname(os.path.abspath(__file__))
    if "CPEManager/manage_scenario?cpeid=" in url and headers:
        with open(os.path.join(folder, CPE_STATUS_RESPONSE_FNAME), "r+") as _f:
            html_text = _f.read()
        data = dict(text=html_text, status_code=200, reason="OK")
    elif "CPEManager/getCPEDetails?cpeid=" in url and headers:
        with open(os.path.join(folder, CPE_DETAILS_RESPONSE_FNAME), "r+") as _f:
            html_text = _f.read()
        data = dict(text=html_text, status_code=200, reason="OK")
    else:
        data = dict(text="", status_code=404, reason="Not Found")
    return type("", (), data)()


def mock_requests_post(*args, **kwargs):
    """A method imitates sending POST requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    url = args[0]
    headers = kwargs["headers"] if "headers" in kwargs else None
    if "/dawn/" in url and headers:
        data = dict(text="", status_code=200, reason="OK", headers={"Set-Cookie": "abc"})
    else:
        data = dict(text="", status_code=404, reason="Not Found")
    return type("", (), data)()


@mock.patch("requests.post", side_effect=mock_requests_post)
@mock.patch("requests.get", side_effect=mock_requests_get)
def run_keyword_by_name(name, *args):
    """A function calls Keywords()' method by its name and returns its results."""
    return getattr(Keywords(), name)(*args[:-2])


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


class TestKeyword_CheckNow(TestCaseNameAsDescription):
    """Class contains unit tests of check_now() keyword."""

    @classmethod
    def setUpClass(cls):
        args = [LABS_CONF["Mock"], CPE_ID]
        cls.result = run_keyword_by_name("check_now", *args)

    @classmethod
    def tearDownClass(cls):
        pass

    def test_cpe_check_now_ok(self):
        """Check CheckNow ACS-command is successful."""
        self.assertTrue(self.result)


class TestKeyword_CheckCPEStatus(TestCaseNameAsDescription):
    """Class contains unit tests of check_cpe_status() keyword."""

    @classmethod
    def setUpClass(cls):
        args = [LABS_CONF["Mock"], CPE_ID]
        cls.result = run_keyword_by_name("check_cpe_status", *args)

    @classmethod
    def tearDown(cls):
        pass

    def test_cpe_status_ok(self):
        """Check CPE status command is successful."""
        self.assertTrue(self.result["status"])

    def test_cpe_status(self):
        """Check CPE status is parsed correctly from response text (HTML)."""
        self.assertEqual(self.result["status_cpe"], CPE_STATUS["status_cpe"])


class TestKeyword_DownloadURL(TestCaseNameAsDescription):
    """Class contains unit tests of download_url() keyword."""

    @classmethod
    def setUpClass(cls):
        args = [LABS_CONF["Mock"], CPE_ID, FIRMWARE]
        cls.result = run_keyword_by_name("download_url", *args)

    @classmethod
    def tearDown(cls):
        pass

    def test_download_firmware_ok(self):
        """Check download firmware is successful."""
        self.assertTrue(self.result)


class TestKeyword_DownloadURLChange(TestCaseNameAsDescription):
    """Class contains unit tests of download_url_change() keyword."""

    @classmethod
    def setUpClass(cls):
        args = [LABS_CONF["Mock"], CPE_ID, FIRMWARE]
        cls.result = run_keyword_by_name("download_url_change", *args)

    @classmethod
    def tearDown(cls):
        pass

    def test_change_download_url_ok(self):
        """Check download another firmware command is successful."""
        self.assertFalse(self.result)


class TestKeyword_FactoryReset(TestCaseNameAsDescription):
    """Class contains unit tests of factory_reset() keyword."""

    @classmethod
    def setUpClass(cls):
        args = [LABS_CONF["Mock"], CPE_ID]
        cls.result = run_keyword_by_name("factory_reset", *args)

    @classmethod
    def tearDown(cls):
        pass

    def test_cpe_factory_reset_ok(self):
        """Check factory reset command is successful."""
        self.assertTrue(self.result)


class TestKeyword_FixFwCPE(TestCaseNameAsDescription):
    """Class contains unit tests of fix_fw_cpe() keyword."""

    @classmethod
    def setUpClass(cls):
        args = [LABS_CONF["Mock"], CPE_ID, FIRMWARE]
        cls.result = run_keyword_by_name("fix_fw_cpe", *args)

    @classmethod
    def tearDown(cls):
        pass

    def test_fix_firmware_ok(self):
        """Check download another firmware is successful and it is accepted."""
        self.assertTrue(self.result)


class TestKeyword_GetDetailsCPE(TestCaseNameAsDescription):
    """Class contains unit tests of get_cpe_details() keyword."""

    @classmethod
    def setUpClass(cls):
        args = [LABS_CONF["Mock"], CPE_ID]
        cls.result = run_keyword_by_name("get_cpe_details", *args)

    @classmethod
    def tearDownClass(cls):
        pass

    def test_cpe_details_ok(self):
        """Check CPE details command is successful."""
        self.assertTrue(self.result["status"])

    def test_cpe_details_ip(self):
        """Check IP address of CPE is parsed correctly from response text (HTML)."""
        self.assertEqual(self.result["ip"], CPE_DETAILS["ip"])

    def test_cpe_details_last_msg(self):
        """Check last access date is parsed correctly from response text (HTML)."""
        self.assertEqual(self.result["last_msg"], CPE_DETAILS["last_msg"])

    def test_cpe_details_firmware_url(self):
        """Check firmware URL is parsed correctly from response text (HTML)."""
        self.assertEqual(self.result["firmware_url"], CPE_DETAILS["firmware_url"])


class TestKeyword_Reboot(TestCaseNameAsDescription):
    """Class contains unit tests of reboot() keyword."""

    @classmethod
    def setUpClass(cls):
        args = [LABS_CONF["Mock"], CPE_ID]
        cls.result = run_keyword_by_name("reboot", *args)

    @classmethod
    def tearDownClass(cls):
        pass

    def test_cpe_reboot_done(self):
        """Check reboot command is successful."""
        self.assertTrue(self.result)


def suite_check_cpe_status():
    """A function builds a test suite for check_cpe_status() keyword."""
    return unittest.makeSuite(TestKeyword_CheckCPEStatus, "test")


def suite_check_now():
    """A function builds a test suite for check_now() keyword."""
    return unittest.makeSuite(TestKeyword_CheckNow, "test")


def suite_download_url():
    """A function builds a test suite for download_url() keyword."""
    return unittest.makeSuite(TestKeyword_DownloadURL, "test")


def suite_download_url_change():
    """A function builds a test suite for download_url_change() keyword."""
    return unittest.makeSuite(TestKeyword_DownloadURLChange, "test")


def suite_factory_reset():
    """A function builds a test suite for factory_reset() keyword."""
    return unittest.makeSuite(TestKeyword_FactoryReset, "test")


def suite_fix_fw_cpe():
    """A function builds a test suite for fix_fw_cpe() keyword."""
    return unittest.makeSuite(TestKeyword_FixFwCPE, "test")


def suite_get_cpe_details():
    """A function builds a test suite for get_cpe_details() keyword."""
    return unittest.makeSuite(TestKeyword_GetDetailsCPE, "test")


def suite_reboot():
    """A function builds a test suite for reboot() keyword."""
    return unittest.makeSuite(TestKeyword_Reboot, "test")


def run_tests():
    """A function runs unit tests; HTTP requests will not go to real servers."""
    suites = [
        suite_check_cpe_status(),
        suite_check_now(),
        suite_download_url(),
        suite_download_url_change(),
        suite_factory_reset(),
        suite_fix_fw_cpe(),
        suite_get_cpe_details(),
        suite_reboot(),
    ]
    for suite in suites:
        unittest.TextTestRunner(verbosity=2).run(suite)


def debug(num, cpe=CPE_ID, lab=LAB_NAME):
    """A function to perform real ACS commands on real CPEs (default),
    or mock ACS requests will be send if lab value is set to "Mock".

    :param num: an integer number of action to be performed (available: 1-8).
    :param lab: a lab name ("lab5A UPCless", "Mock" are available names).

    :return: the return value of selected keyword.
    """
    conf = LABS_CONF[lab] if lab in LABS_CONF else LABS_CONF[LAB_NAME]
    kwd = Keywords()
    kwds = {
        "check_cpe_status": lambda: kwd.check_cpe_status(conf, cpe),
        "check_now": lambda: kwd.check_now(conf, cpe),
        "download_url": lambda: kwd.download_url(conf, cpe, FIRMWARE),
        "download_url_change": lambda: kwd.download_url_change(conf, cpe, FIRMWARE),
        "factory_reset": lambda: kwd.factory_reset(conf, cpe),
        "fix_fw_cpe": lambda: kwd.fix_fw_cpe(conf, cpe, FIRMWARE),
        "get_cpe_details": lambda: kwd.get_cpe_details(conf, cpe),
        "reboot": lambda: kwd.reboot(conf, cpe),
    }
    if not (isinstance(num, int) and num in list(range(1, 1+len(list(kwds.keys()))))):
        num = 1
    key = list(sorted(kwds.keys()))[num-1]
    print(("\nRunning keyword '%s'..." % key))
    print(("Keyword '%s' completed. Returned value is: %s" % (key, kwds[key]())))


if __name__ == "__main__":
    #for i in list(range(1, 9)):
    #    debug(i)
    run_tests()
