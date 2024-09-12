#!/usr/bin/env python27
"""
Description         Module handling interacting with Obelix PDU interface

"""
import xml.etree.ElementTree as ET
from enum import Enum
import requests
from requests import HTTPError
from Libraries.Environment.AbstractPDU import AbstractPDU

# too-many-boolean-expressions -> use of multiple or/and required
# instead of breaking it into nested if-else
# pylint: disable=too-many-boolean-expressions

# Constants
_PDU_SERVER_URL = \
    "http://10.64.12.11/miRoNvtSnmpService/miRo_NvtSnmpService.asmx"
_LOCAL_POWER_OID = '1.3.6.1.4.1.39525.11.1.2.'


class SOAPPDUDefines(Enum):
    """
    SOAP PDU constants
    """
    SOAP_POWER_OFF = 0
    SOAP_POWER_ON = 1
    SOAP_POWER_CYCLE = 2


class ObelixPDU(AbstractPDU):
    """
    Class for Obelix PDU module
    """

    def __init__(self, rack_config):
        self._pdu_type = rack_config['PDU_TYPE']
        self._pdu_ip = rack_config['PDU_IP']
        self._rack_pc_ip = rack_config['RACK_PC_IP']

    def get_power_level(self, selector, pdu_selector):
        """
        Method to get power level
        :param selector: STB slot - ignored, pdu_selector is used
        :param pdu_selector: pdu slot
        :return: float with power level
        """
        power_level = float(0)
        if self._pdu_type == 'SOAP' or not self._pdu_type:
            power_level = self._get_power_level_soap(pdu_selector)
        elif self._pdu_type == 'REST':
            raise ValueError("REST support not available")
        else:
            raise ValueError("Wrong value of pdu type")
        return power_level

    def _get_power_level_soap(self, selector):
        headers = {'content-type': 'text/xml'}
        body = """<?xml version="1.0" encoding="UTF-8"?>
                                   <s:Envelope xmlns:s=
                                   "http://schemas.xmlsoap.org/soap/envelope/">
                                     <s:Body>
                                       <snmpGet xmlns="MiRo.Telenet.Nvt"
                                        xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
                                         <requestData>
                                           <snmpOidList>
                                             <string>.1.3.6.1.4.1.13742.6.5.4.3.1.4.1.{0}.5</string></snmpOidList>
                                           <setType>snmpSetTypeInteger</setType>
                                           <targetIp>{1}</targetIp>
                                           <targetCommunityString>private</targetCommunityString>
                                           <snmpTimeOut>0</snmpTimeOut>
                                           <snmpRetries>3</snmpRetries>
                                         </requestData>
                                       </snmpGet>
                                     </s:Body>
                                   </s:Envelope>""". \
            format(selector, self._pdu_ip)
        pdu_req = requests.post(_PDU_SERVER_URL, data=body,
                                headers=headers, timeout=20)
        if pdu_req.status_code != 200:
            raise Exception("Power level check failed")
        xml_response = pdu_req.content.decode()
        with open('soap_powercheck.xml', 'w') as soapresponse:
            soapresponse.write(xml_response)
        doc = ET.parse("soap_powercheck.xml")
        for elem in doc.findall('.//{MiRo.Telenet.Nvt}snmpResponseValue'):
            power = elem.findtext('{MiRo.Telenet.Nvt}snmpValue')
            return float(power)

    def power_cycle(self, selector, pdu_selector):
        """
        Method to power cycle
        :param selector: STB slot - ignored, pdu_selector is used
        :param pdu_selector: pdu slot
        """
        if self._pdu_type == 'REST':
            self._power_cycle_rest(selector)
        elif self._pdu_type == 'SOAP' or not self._pdu_type:
            self._power_command_soap(
                pdu_selector, SOAPPDUDefines.SOAP_POWER_CYCLE)
        else:
            raise ValueError("Wrong value of pdu type")
        return

    def _power_cycle_rest(self, selector):
        rack_pc_url = "http://{}/TestBox{}/PDUCONTROL/".format(
            self._rack_pc_ip, selector)
        body = {"command": "powercycle"}
        pdu_req = requests.post(rack_pc_url, json=body, timeout=20)
        if pdu_req.status_code != 200:
            raise HTTPError("Power Cycle failed")
        if "false" in pdu_req.text:
            raise Exception("Power Cycle failed")

    def _power_command_soap(
            self, selector, command=SOAPPDUDefines.SOAP_POWER_CYCLE):
        """
        Method to power on/off/powercycle stb for soap pdu.
        controlCommand: 0-2: 0 = power off, 1 = power on, 2 = power cycle
        :param selector: STB slot
        """
        headers = {'content-type': 'text/xml'}
        if command not in SOAPPDUDefines:
            raise ValueError(
                "PDU SOAP command {0} not implemented".format(command.value))
        body = """<?xml version="1.0" encoding="UTF-8"?>
                            <s:Envelope xmlns:s=
                            "http://schemas.xmlsoap.org/soap/envelope/">
                              <s:Body>
                                <snmpSet xmlns="MiRo.Telenet.Nvt" xmlns:i=
                                "http://www.w3.org/2001/XMLSchema-instance">
                                  <requestData>
                                    <snmpOid>.1.3.6.1.4.1.13742.6.4.1.2.1.2.1.{0}</snmpOid>
                                    <setValue i:type="a:int" xmlns:a=
                                    "http://www.w3.org/2001/XMLSchema">{1}</setValue>
                                    <setType>snmpSetTypeInteger</setType>
                                    <targetIp>{2}</targetIp>
                                    <targetCommunityString>private</targetCommunityString>
                                    <snmpTimeOut>0</snmpTimeOut>
                                    <snmpRetries>3</snmpRetries>
                                  </requestData>
                                </snmpSet>
                              </s:Body>
                            </s:Envelope>""". \
            format(selector, command.value, self._pdu_ip)
        pdu_req = requests.post(_PDU_SERVER_URL, data=body,
                                headers=headers, timeout=20)
        if pdu_req.status_code != 200:
            raise Exception("{0} failed".format(command.name))

    def power_off(self, selector, pdu_selector):
        """
        Method to power off the STB
        :param selector: STB slot - ignored, pdu_selector is used
        :param pdu_selector: pdu slot
        """
        if self._pdu_type == 'SOAP' or not self._pdu_type:
            self._power_command_soap(
                pdu_selector, SOAPPDUDefines.SOAP_POWER_OFF)
        else:
            raise ValueError(
                "PowerOff not implemented for {0} PDU".format(self._pdu_type))

    def power_on(self, selector, pdu_selector):
        """
        Method to power on the STB
        :param selector: STB slot - ignored, pdu_selector is used
        :param pdu_selector: pdu slot
        """
        if self._pdu_type == 'SOAP' or not self._pdu_type:
            self._power_command_soap(
                pdu_selector, SOAPPDUDefines.SOAP_POWER_ON)
        else:
            raise ValueError(
                "PowerOn not implemented for {0} PDU".format(self._pdu_type))
