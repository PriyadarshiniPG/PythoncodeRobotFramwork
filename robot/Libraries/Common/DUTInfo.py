#!/usr/bin/env python27
"""
This module contains the class which gives information
about the device under test based on the RACK_SLOT_ID from rack_details.yml
"""
import os
# import sys
import yaml
from robot.libraries.BuiltIn import BuiltIn

_RACK_SIZE = 8
_PDU_REVERSE_SLOT_START = 23


class Platforms(object):
    """Platform constants"""
    ARRIS = 'DCX960'
    ARRIS_HDD = 'DCX960-d'
    HUMAX = 'EOS1008C'
    HUMAX_HDD = 'EOS1008R'
    SELENE_7401 = 'SMT-G7401'
    SELENE_7400 = 'SMT-G7400'
    APOLLO = 'APOLLO'

    def get_arris(self):
        """Arris getter"""
        return self.ARRIS

    def get_arris_hdd(self):
        """Arris hdd getter"""
        return self.ARRIS_HDD

    def get_humax(self):
        """Humax getter"""
        return self.HUMAX

    def get_humax_hd(self):
        """Humax hdd getter"""
        return self.HUMAX_HDD

    def get_selene_7401(self):
        """Selene 7401 getter"""
        return self.SELENE_7401

    def get_selene_7400(self):
        """Selene 7400 getter"""
        return self.SELENE_7400

    def get_apollo(self):
        """Apollo getter"""
        return self.APOLLO


class DUTInfo(object):
    """
    This class contains the information about the device under test based on
    the rack_details.yml file
    """
    # Schema: robot\resources\Rack_Details\_Rack_Details_Schema.yml
    # Using robot\resources\Rack_Details\{LAB_NAME}.yml
    #   --variable=LAB_NAME:{TENANT} --variable=RACK_SLOT_ID:FCOBOS_RACK_SLOT_ID
    def __init__(self):
        self._cache = {}
        lab_name = BuiltIn().get_variable_value("${LAB_NAME}")
        if lab_name:
            rack_file_name = 'resources/Rack_Details/%s.yml' % lab_name
            self._rack_details_path = os.path.join(os.getcwd(), rack_file_name)
            BuiltIn().log_to_console("rack_details_path: %s" % str(self._rack_details_path))
        else:
            BuiltIn().log_to_console("WARN: LAB_NAME is empty - LAB_NAME:%s" % lab_name)

    def _read_rack_details(self):
        with open(self._rack_details_path, 'r') as \
                rack_details_file:
            rack_details_content = yaml.load(rack_details_file, Loader=yaml.FullLoader)
        print(("rack_details_content: " + str(rack_details_content)))
        return rack_details_content

    def _get_entry_from_rack_details(self, rack_slot_id):
        print(("rack_slot_id: " + str(rack_slot_id)))
        rack_details_content = self._read_rack_details()

        found_entry = None
        for entry in rack_details_content:
            if entry['RACK_SLOT_ID'] == rack_slot_id:
                found_entry = entry
                break
        if not found_entry:
            raise ValueError(
                'No entry found in {} '.format(self._rack_details_path) +
                'for rack_slot_id [{}]'.format(rack_slot_id))
        return found_entry

    def _add_entry_to_cache_if_its_not_there(self, rack_slot_id):
        if rack_slot_id not in self._cache:
            entry = self._get_entry_from_rack_details(rack_slot_id)
            self._cache[rack_slot_id] = entry

    def _get_from_cache(self, rack_slot_id, key):
        self._add_entry_to_cache_if_its_not_there(rack_slot_id)
        return self._cache[rack_slot_id].get(key)

    def get_rack_slot_id(self, rack_slot_id):
        """
        Returns RACK_SLOT_ID for given rack_slot_id
        """
        return self._get_from_cache(rack_slot_id, 'RACK_SLOT_ID')

    def get_pdu_ip(self, rack_slot_id):
        """
        Returns PDU_IP for given rack_slot_id
        """
        return self._get_from_cache(rack_slot_id, 'PDU_IP')

    def get_rack_pc_ip(self, rack_slot_id):
        """
        Returns RACK_PC_IP for given rack_slot_id
        """
        return self._get_from_cache(rack_slot_id, 'RACK_PC_IP')

    def get_cpe_ip(self, rack_slot_id):
        """
        Returns STB_IP for given rack_slot_id
        """
        if self._get_from_cache(rack_slot_id, 'STB_IP') is None:
            result = "127.0.0.1"
        else:
            result = self._get_from_cache(rack_slot_id, 'STB_IP')
        return result

    def get_serial_port(self, rack_slot_id):
        """
        Returns SERIAL for given rack_slot_id
        """
        if self._get_from_cache(rack_slot_id, 'SERIAL') is None:
            result = "False", -1
        else:
            result = "True", self._get_from_cache(rack_slot_id, 'SERIAL')
        return result

    def get_cpe_id(self, rack_slot_id):
        """
        Returns CPE_ID for given rack_slot_id
        """
        return self._get_from_cache(rack_slot_id, 'CPE_ID')

    def get_general_platform(self, rack_slot_id):
        """
        Returns generalized PLATFORM for given rack_slot_id
        """
        platform = self._get_from_cache(rack_slot_id, 'PLATFORM')
        return_platform = None
        if platform in (Platforms.ARRIS, Platforms.ARRIS_HDD):
            return_platform = Platforms.ARRIS
        elif platform in (Platforms.HUMAX, Platforms.HUMAX_HDD):
            return_platform = Platforms.HUMAX
        elif platform in (Platforms.SELENE_7400, Platforms.SELENE_7401,
                          Platforms.APOLLO):
            return_platform = platform
        else:
            ValueError(
                'Could not find platform value '
                'rack_slot_id [{}]'.format(rack_slot_id))
        return return_platform

    def get_exact_platform(self, rack_slot_id):
        """
        Returns exact PLATFORM for given rack_slot_id
        """
        return self._get_from_cache(rack_slot_id, 'PLATFORM')

    def get_red_rat_ir_ip(self, rack_slot_id):
        """
        Returns RED_RAT_IR_IP for given rack_slot_id
        """
        return self._get_from_cache(rack_slot_id, 'RED_RAT_IR_IP')

    def get_red_rat_ir_port(self, rack_slot_id):
        """
        Returns RED_RAT_IR_PORT for given rack_slot_id
        """
        return self._get_from_cache(rack_slot_id, 'RED_RAT_IR_PORT')

    def get_red_rat_ir_device(self, rack_slot_id):
        """
        Returns RED_RAT_IR_DEVICE for given rack_slot_id
        """
        return self._get_from_cache(rack_slot_id, 'RED_RAT_IR_DEVICE')

    def get_red_rat_ir_device_output_port(self, rack_slot_id):
        """
        Returns RED_RAT_IR_DEVICE_OUTPUT_PORT for given rack_slot_id
        """
        return self._get_from_cache(rack_slot_id, 'RED_RAT_DEVICE_OUTPUT_PORT')

    def get_lan_pc_ip(self, rack_slot_id):
        """
        Returns LAN_PC_IP for given rack_slot_id
        """
        return self._get_from_cache(rack_slot_id, 'LAN_PC_IP')

    def get_test_status(self, rack_slot_id):
        """
        Returns TEST_STATUS for given rack_slot_id
        """
        return self._get_from_cache(rack_slot_id, 'TEST_STATUS')

    def get_lab_name(self, rack_slot_id):
        """
        Returns LAB_NAME for given rack_slot_id
        """
        return self._get_from_cache(rack_slot_id, 'LAB_NAME')

    def get_obelix_support(self, rack_slot_id):
        """
        Returns OBELIX_SUPPORT for given rack_slot_id
        """
        if self._get_from_cache(rack_slot_id, 'OBELIX_SUPPORT') is None:
            result = "False"
        else:
            result = self._get_from_cache(rack_slot_id, 'OBELIX_SUPPORT')
        return result

    def get_ca_id(self, rack_slot_id):
        """
        Returns CA_ID for given rack_slot_id
        """
        return self._get_from_cache(rack_slot_id, 'CA_ID')

    def get_rl_port(self, rack_slot_id):
        """
        Returns RL_PORT for given rack_slot_id
        """
        return self._get_from_cache(rack_slot_id, 'RL_PORT')

    def get_pdu_type(self, rack_slot_id):
        """
        Returns PDU_TYPE for given rack_slot_id
        """
        return self._get_from_cache(rack_slot_id, 'PDU_TYPE')

    def get_rack_type(self, rack_slot_id):
        """
        Returns RACK_TYPE for given rack_slot_id
        """
        return self._get_from_cache(rack_slot_id, 'RACK_TYPE')

    def get_stb_mac(self, rack_slot_id):
        """
        Returns STB_MAC for given rack_slot_id
        """
        return self._get_from_cache(rack_slot_id, 'STB_MAC')

    def get_broker_url(self, rack_slot_id):
        """
        Returns BROKER_URL for given rack_slot_id
        """
        if self._get_from_cache(rack_slot_id, 'BROKER_URL') is None:
            result = "tcp://mqtt:1883"
        else:
            result = self._get_from_cache(rack_slot_id, 'BROKER_URL')
        return result

    def get_degraded_mode_broker(self, rack_slot_id):
        """
        Returns DEGRADED_MODE_BROKER for given rack_slot_id
        """
        if self._get_from_cache(rack_slot_id, 'DEGRADED_MODE_BROKER') is None:
            result = "ws://127.0.0.1:8888/mqtt"
        else:
            result = self._get_from_cache(rack_slot_id, 'DEGRADED_MODE_BROKER')
        return result

    def get_city_id(self, rack_slot_id):
        """
        Returns CITY_ID for given rack_slot_id
        """
        if self._get_from_cache(rack_slot_id, 'CITY_ID') is None:
            result = "default"
        else:
            result = self._get_from_cache(rack_slot_id, 'CITY_ID')
        return result

    def get_osd_language_details(self, rack_slot_id):
        """
        Returns OSD_LANGUAGE for given rack_slot_id by default "en"
        """
        if self._get_from_cache(rack_slot_id, 'OSD_LANGUAGE') is None:
            result = "en"
        else:
            result = self._get_from_cache(rack_slot_id, 'OSD_LANGUAGE')
        return result

    def get_all_dut_details(self, rack_slot_id):
        """
        Returns entire STB entry for given rack_slot_id
        """
        self._add_entry_to_cache_if_its_not_there(rack_slot_id)
        return self._cache[rack_slot_id]

    def get_panoramix_support(self, rack_slot_id):
        """
        Returns PANORAMIX_SUPPORT for given rack_slot_id
        """
        if self._get_from_cache(rack_slot_id, 'PANORAMIX_SUPPORT') is None:
            result = "False"
        else:
            result = self._get_from_cache(rack_slot_id, 'PANORAMIX_SUPPORT')
        return result

    def get_elastic(self, rack_slot_id):
        """
        Returns ELASTIC for given rack_slot_id
        """
        if self._get_from_cache(rack_slot_id, 'ELASTIC') is None:
            result = "True"
        else:
            result = self._get_from_cache(rack_slot_id, 'ELASTIC')
        return result

    def get_router_pc_ip(self, rack_slot_id):
        """
        Returns ROUTER_PC_IP for given rack_slot_id
        """
        return self._get_from_cache(rack_slot_id, 'ROUTER_PC_IP')

    def get_pdu_slot(self, rack_slot_id):
        """
        Returns slot number for given rack_slot_id
        If STB is marked with reverse pdu schema, it returns the
        converted slot number
        """
        slot = self._get_exact_slot_number(rack_slot_id)
        reverse_pdu_schema = self._get_from_cache(
            rack_slot_id, 'REVERSE_PDU_SCHEMA')
        if reverse_pdu_schema:
            slot = _PDU_REVERSE_SLOT_START - slot
        return slot

    def _get_exact_slot_number(self, rack_slot_id):
        acquired_rack_slot_id = self.get_rack_slot_id(rack_slot_id)
        return int(acquired_rack_slot_id.rsplit('-', 1)[1])

    def get_slot(self, rack_slot_id):
        """
        Returns slot number for given rack_slot_id
        """
        slot = self._get_exact_slot_number(rack_slot_id)
        if slot > _RACK_SIZE:
            slot -= _RACK_SIZE
        return slot
