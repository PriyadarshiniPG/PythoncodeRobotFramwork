"""Implementation of ACS library's keywords for Robot Framework.
Script automates CPE management by sending HTTP GET and POST requests
to ACS (Auto Configuration Server).

v0.0.1 - Fernando Cobos: initial version.
v0.0.2 - Natallia Savelyeva: refactoring + unit tests.
"""
import os
import time
import json
import urllib.parse
import requests
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError


LOGIN_ACS = "manage?__ac_name=%(acs_user)s&__ac_password=%(acs_password)s&submit_button="

SCENARIO_PROCESS = "CPEManager/getCPEScenarioProcess?AJAXactivateScenarioNow=1&methodName="

REBOOT_CPE = "Reboot&parameters=Reboot%%20by%%20Axess%%20Server&cpeid=%(cpe)s"

FACTORY_RESET_CPE = "FactoryReset&parameters=%%7B%%7D&cpeid=%(cpe)s"

CPE_EXISTS = "CPEManager/manage_scenario?cpeid=%(cpe)s"

CPE_DETAILS = "CPEManager/getCPEDetails?cpeid=%(cpe)s"

DOWNLOAD_URL = """SetParameterValues&parameters=%%7B'.ManagementServer\
.X_LGI-COM_SoftwareDownload.OAL.DownloadURL'%%3A%%20'http%%3A%%2F%%2Fdawnssu.dmdsdp.com%%\
2Fswimages%%2Fdawn%%2Fsoftware%%2Fdcx960%%2F1%%2F%(firmware)s%%2F'%%20%%7D&cpeid=%(cpe)s"""

CHECK_NOW = """SetParameterValues&parameters=%%7B'Device\
.ManagementServer.X_LGI-COM_SoftwareDownload.OAL.CheckNow'%%3A%%201%%7D%%20&cpeid=%(cpe)s"""


def print_http_err(msg_prefix, url, response):
    """A function prints error message: given comment, url, response details."""
    err_msg = "%s %s - %s %s" % \
        (msg_prefix, url, response.status_code, response.reason)
    print(err_msg)


class ACS(object):
    """A class to handle requests to ACS (Auto Configuration Server)."""

    def __init__(self, conf, cpe):
        self.conf = conf
        self.auth = (conf["ACS"]["user"], conf["ACS"]["password"])
        self.sid = None
        self.cpe = cpe.replace("3C36E4-EOSSTB-", "")
        try:
            # Use folder name where this file is placed
            # (as Traxis, Fabrix, PurchaseMicroservice, etc) as a tag
            folder_name = os.path.basename(os.path.dirname(os.path.realpath(__file__)))
            BuiltIn().set_test_variable("${ENDPOINT_TAG}", "%s" % folder_name)
        except RobotNotRunningError:
            pass

    def _refresh_session(self):
        self.sid = self._get_sid_value()

    def _get_sid_value(self):
        headers = {"Content-Type": "application/x-www-form-urlencoded"}
        url = ("http://%s/dawn/" % self.conf["ACS"]["host"]) \
            + (LOGIN_ACS % {"acs_user": self.conf["ACS"]["user"],
                            "acs_password": self.conf["ACS"]["password"]})
        data = {}

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        response = requests.post(url, data=json.dumps(data), headers=headers)
        if response.status_code != 200:
            self._refresh_session()
        cookie = ""
        try:
            cookie = response.headers['Set-Cookie'] #.encode('utf-8')
            cookie = cookie.replace("; Path=/", "")
        except ValueError as err:
            print(("%s: %s %s" % (err, response.status_code, response.headers)))
        return cookie

    def get_data(self, url_api_part):
        """A method sends GET request to ACS.

        :param url_api_part: everything after 'http://<ACS>/dawn/' in full ACS URL.

        :return: 2-tuple (True if GET is successful False otherwise, response text).
        """
        status = True
        if not self.sid:
            self._refresh_session()
        url = "http://%s/dawn/%s" % (self.conf["ACS"]["host"], url_api_part)
        headers = {"Cookie": self.sid}

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        response = requests.get(url, headers=headers)
        if response.status_code != 200:
            self._refresh_session()
            print_http_err("ERROR: GET to ACS", url, response)
            status = False
        return status, response.text

    def post_data(self, url_api_part):
        """A method sends POST request to ACS.

        :param url_api_part: everything after 'http://<ACS>/dawn/' in full ACS URL.

        :return: True if POST is successful, False otherwise.
        """
        status = True
        if not self.sid:
            self._refresh_session()
        url = "http://%s/dawn/%s" % (self.conf["ACS"]["host"], url_api_part)
        headers = {"Cookie": self.sid, \
                   "Content-type": "application/x-www-form-urlencoded"}

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        response = requests.post(url, headers=headers)
        if response.status_code != 200:
            self._refresh_session()
            print_http_err("ERROR: POST to ACS", url, response)
            status = False
        return status

    def reboot(self):
        """Perform rebooting the CPE by sending POST request to ACS.

        :return: True if POST request is successful, False otherwise.
        """
        acs_cmd = SCENARIO_PROCESS + (REBOOT_CPE % {"cpe": self.cpe})
        return self.post_data(acs_cmd)

    def download_url(self, firmware):
        """Perform downloading firmware for CPE by sending POST request to ACS.

        :param firmware: a package name of the firmware.

        :return: True if POST request is successful, False otherwise.

        :Example:

        >>>self.download_url("DCX960__-mon-dbg-00.01-023-aa-AL-20170622153441-un000")
        True
        """
        acs_cmd = SCENARIO_PROCESS \
                + (DOWNLOAD_URL % {"cpe": self.cpe, "firmware": firmware})
        return self.post_data(acs_cmd)

    def check_now(self):
        """Apply current firmware for CPE by sending POST request to ACS.

        :return: True if POST request is successful, False otherwise.
        """
        acs_cmd = SCENARIO_PROCESS + (CHECK_NOW % {"cpe": self.cpe})
        return self.post_data(acs_cmd)

    def fix_fw_cpe(self, firmware):
        """Download and apply firmware for CPE by sending POST requests to ACS.

        :param firmware: a package name of the firmware.

        :return: True if POST request is successful, False otherwise.

        :Example:

        >>>self.fix_fw_cpe("DCX960__-mon-dbg-00.01-023-aa-AL-20170622153441-un000")
        True
        """
        status = False
        if self.download_url(firmware):
            time.sleep(3)
            status = self.check_now()
        return status

    def factory_reset(self):
        """Perform a factory reset for the CPE by sending POST request to ACS.

        :return: True if POST request is successful, False otherwise.
        """
        acs_cmd = SCENARIO_PROCESS + (FACTORY_RESET_CPE % {"cpe": self.cpe})
        return self.post_data(acs_cmd)

    def check_cpe_status(self):
        """Detect current status of the CPE by sending GET request to ACS.

        :return: a dictionary of boolean response status and a CPE status message.

        :Example:

        >>>self.check_cpe_status()
        {'status': True, 'status_cpe': 'PENDING (1)'}
        """
        status, html = self.get_data(CPE_EXISTS % {"cpe": self.cpe})
        _pos_1 = html.find('onmouseout="tt_swap(\'props%s\')" src="' % self.cpe)
        _pos_2 = html.find('alt=""/><div class="toolTip" id="props')
        status_cpe = html[_pos_1:_pos_2]
        status_cpe = status_cpe[status_cpe.find('title="')+7:len(status_cpe)-2]
        result = {"status": status, "status_cpe": status_cpe}
        return result

    def get_cpe_details(self):
        """Collect details about the CPE by sending GET request to ACS.

        :return: a dictionary with details of the given CPE.

        :Example:

        >>>self.get_cpe_details()
        {'status': True, 'ip': '10.11.80.2', 'firmware_url': 'http://omwssu.lab5a.nl.dmds
        dp.com/swimages/dawn/software/dcx960/1/', 'last_msg': 'Wed Aug  2 12:54:13 2017'}
        """
        status, html = self.get_data(CPE_DETAILS % {"cpe": self.cpe})
        _ip_pos_1 = html.find('IP:&nbsp;</b>') + 13
        _ip_pos_2 = html.find('<br/><hr/><b>parentID')
        _lm_pos_1 = html.find('lastMsg:&nbsp;</b>') + 18
        _lm_pos_2 = html.find('<br/><hr/><b>protocolVersion')
        _fw_pos_1 = html.find('D.DI.SV&nbsp;:&nbsp;<b>') + 23
        _fw_pos_2 = html.find("</b></div><div title='..I-COM")
        _fw_url_pos_1 = html.find('D.MS.XSD.O.DU&nbsp;:&nbsp;<b>') + 29
        _fw_url_pos_2 = html.find("</b></div><div title='..LGI")
        details = {"ip": html[_ip_pos_1:_ip_pos_2],
                   "last_msg": html[_lm_pos_1:_lm_pos_2],
                   "firmware_url": html[_fw_url_pos_1:_fw_url_pos_2],
                   "firmware": html[_fw_pos_1:_fw_pos_2],
                   "status": status}
        return details

    @staticmethod
    def __parse_firmware_from_url(firmware_url):
        pos = firmware_url.find("/1/") + 3
        firmware = firmware_url[pos:].replace("/", "")
        return firmware

    def download_url_change(self, firmware):
        """Download firmware for CPE and check if it is changed."""
        result = False
        data = self.get_cpe_details()
        if data["status"]:
            firm_bckp = self.__parse_firmware_from_url(data["firmware_url"])
            if firmware == firm_bckp:
                firmware = "TEST-FIRM-CHANGE"
            if self.download_url(firmware):
                time.sleep(10)
                data = self.get_cpe_details()
                if data["status"]:
                    firm = self.__parse_firmware_from_url(data["firmware_url"])
                    if firm == firmware:
                        if self.download_url(firm_bckp):
                            result = True
        return result


class Keywords(object):
    """Keywords visible in Robot Framework."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @staticmethod
    def check_cpe_status(conf, cpe):
        """A keyword to detect current status of the CPE.

        :return: a dictionary of boolean response status and a CPE status message.

        :Example:

        >>>Keywords().check_cpe_status(CONF, "3C36E4-EOSSTB-003356472104")
        {'status': True, 'status_cpe': 'PENDING (1)'}
        """
        return ACS(conf, cpe).check_cpe_status()

    @staticmethod
    def check_now(conf, cpe):
        """A keyword to execute CheckNow ACS command for the given CPE.

        :param conf: a dictionary with configuration settings (host, port, etc.).
        :param cpe: a CPE id like "3C36E4-EOSSTB-003356472104".

        :return: True if command was successful, False otherwise.
        """
        return ACS(conf, cpe).check_now()


    @staticmethod
    def download_url(conf, cpe, firmware):
        """A keyword to download firmware for the given CPE.

        :param conf: a dictionary with configuration settings (host, port, etc.).
        :param cpe: a CPE id like "3C36E4-EOSSTB-003356472104".
        :param firmware: a package name of the firmware.

        :return: True if command was successful, False otherwise.

        :Example:

        >>>Keywords().download_url(CONF, "3C36E4-EOSSTB-003356472104", \
        ... "DCX960__-mon-dbg-00.01-023-aa-AL-20170622153441-un000")
        True
        """
        return ACS(conf, cpe).download_url(firmware)

    @staticmethod
    def download_url_change(conf, cpe, firmware):
        """A keyword to download firmware for the CPE and check if it is changed."""
        return ACS(conf, cpe).download_url_change(firmware)

    @staticmethod
    def factory_reset(conf, cpe):
        """A keyword to perform a factory reset of the given CPE.

        :param conf: a dictionary with configuration settings (host, port, etc.).
        :param cpe: a CPE id like "3C36E4-EOSSTB-003356472104".

        :return: True if command was successful, False otherwise.
        """
        return ACS(conf, cpe).factory_reset()

    @staticmethod
    def fix_fw_cpe(conf, cpe, firmware):
        """A keyword to download and apply firmware for CPE.

        :param conf: a dictionary with configuration settings (host, port, etc.).
        :param cpe: a CPE id like "3C36E4-EOSSTB-003356472104".
        :param firmware: a package name of the firmware.

        :return: True if command was successful, False otherwise.
        """
        return ACS(conf, cpe).fix_fw_cpe(firmware)

    @staticmethod
    def get_cpe_details(conf, cpe):
        """A keyword to collect details about the CPE.

        :return: a dictionary with details of the given CPE.

        :Example:

        >>>Keywords().get_cpe_details(CONF, "3C36E4-EOSSTB-003356472104")
        {'status': True, 'ip': '10.11.80.2', 'firmware_url': 'http://omwssu.lab5a.nl.dmds
        dp.com/swimages/dawn/software/dcx960/1/', 'last_msg': 'Wed Aug  2 12:54:13 2017'}
        """
        return ACS(conf, cpe).get_cpe_details()

    @staticmethod
    def reboot(conf, cpe):
        """A keyword to reboot the CPE.

        :param conf: a dictionary with configuration settings (host, port, etc.).
        :param cpe: a CPE id like "3C36E4-EOSSTB-003356472104".

        :return: True if command was successful, False otherwise.
        """
        return ACS(conf, cpe).reboot()
