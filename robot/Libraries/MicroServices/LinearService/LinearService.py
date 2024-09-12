# pylint: disable = invalid-name
#!/usr/bin/env python27
# -*- coding: utf-8 -*-
"""
Description         Class definition for Linear Service
Reference: https://wikiprojects.upc.biz/display/SPARK/
           Linear+Service+-+Regionalized+channel+lineup+API+specification
"""

import sys
import os
import urllib.parse
import random
import requests

from requests import HTTPError
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError


# from Utils.zephyr_reporter.modules.zephyr_api import retry_decorator

# Following pylint warnings were disabled for this class
# C0103 - Invalid method name - we don't want to shorten each method name
# pylint: disable=C0103


class LinearService(object):
    """
        Class related to functionalities with Linear Service
    """

    def __init__(self):
        """
        Initialise.
        """
        try:
            lab_name = BuiltIn().get_variable_value("${LAB_NAME}")
            if lab_name:
                self._micro_service_url = BuiltIn().get_variable_value(
                    "${E2E_CONF['"+lab_name+"']['MICROSERVICES']['OBOQBR']}")
                if self._micro_service_url is None:
                    BuiltIn().log_to_console(
                        "ERROR: : E2E_CONF[%s]['MICROSERVICES']['OBOQBR'] dont exist \n" % lab_name)
                    sys.exit()
            else:
                BuiltIn().log_to_console("WARN: LAB_NAME is empty - LAB_NAME:%s" % lab_name)
                self._micro_service_url = "ERROR: No LAB_NAME Specify"
            self._linear_service_url = "http://"+self._micro_service_url+"/linear-service/"
        except RobotNotRunningError:
            pass

    @staticmethod
    # @retry_decorator
    def _get_http_request(req):
        """"
        http get request
        :param req: request url
        """
        response = requests.get(req, timeout=10)
        if response.status_code != 200:
            raise HTTPError('Status:', response.status_code,
                            'The get request was not successful')
        return response

    def get_current_channel_lineup_via_ls(
            self, city_id, language, product_class):
        """
        Query Linear Service for channel line-up
        :param city_id: Current customer city id
        :param language: Customer language (OSD language of the STB)
        :param product_class: CPE product class (EOSSTB, HZNSTB, APLSTB)
        :return: Channel line-up object of type Json
        """
        if city_id == "default":
            BuiltIn().log_to_console("ERROR: : Linear Services - city_id: %s" % city_id)
            response = None
        else:
            req_url = \
                self._linear_service_url + \
                'v1/channels?cityId=' + \
                city_id + '&language=' + language + \
                '&deviceType=ALL&productClass=' + product_class
            response = self._get_http_request(req_url).json()
        return response

    def get_detail_of_linear_event(
            self, crid, language, returnLinearContent=True):
        """
        Query Linear Service to get the details of Replay Event
        :param crid: crid of Replay event
        :return: Event Details object of type Json
        """
        req_url = "%sv1/replayEvent/%s?returnLinearContent=%s&language=%s" \
                  % (self._linear_service_url, crid, str(returnLinearContent), language)
        response = self._get_http_request(req_url)
        return response.json()

    def get_channel_name_via_ls(
            self, city_id, channel_number, language, product_class):
        """
        Returns the channel name from the input channel number
        :param city_id: Current customer city id
        :param channel_number: LCN which require the channel name
        :param language: Customer language (OSD language of the STB)
        :param product_class: CPE product class (EOSSTB, HZNSTB, APLSTB)
        :return: Channel name
        """
        channel_name = None
        channel_lineup = \
            self.get_current_channel_lineup_via_ls(
                city_id, language, product_class)
        for channel in channel_lineup:
            if channel_number == repr(channel['logicalChannelNumber']):
                channel_name = str(channel['name'])
                channel_name.encode("ascii", "replace")
                break
        return channel_name

    def get_channel_id_by_name_via_ls(
            self, city_id, channel_name, language, product_class):
        """
        Returns the channel id from the input channel name
        :param city_id: Current customer city id
        :param channel_name: Channel name
        :param language: Customer language (OSD language of the STB)
        :param product_class: CPE product class (EOSSTB, HZNSTB, APLSTB)
        :return: Channel id
        """
        channel_id = None
        channel_lineup = self.get_current_channel_lineup_via_ls(
            city_id, language, product_class)
        for channel in channel_lineup:
            if channel_name == channel['name']:
                channel_id = channel['id']
                break
        return channel_id

    def get_channel_id_by_number_via_ls(
            self, city_id, channel_number, language, product_class):
        """
        Returns the channel id from the input channel number
        :param city_id: Current customer city id
        :param channel_number: Channel number
        :param language: Customer language (OSD language of the STB)
        :param product_class: CPE product class (EOSSTB, HZNSTB, APLSTB)
        :return: Channel id
        """

        channel_id = None
        channel_lineup = self.get_current_channel_lineup_via_ls(
            city_id, language, product_class)
        for channel in channel_lineup:
            if channel_number == repr(channel['logicalChannelNumber']):
                channel_id = channel['id']
                break
        return channel_id

    def get_channel_summary_by_attribute_via_ls(
            self, city_id, attribute_name, attribute_value,
            language, product_class, _4k_support=True):
        """
        Returns the channel summary
        :param city_id: Current customer city id
        :param attribute_name: Channel attribute keys
         (eg: id, logicalChannelNumber, name etc )
        :param attribute_value: Value of the attribute
        :param language: Customer language (OSD language of the STB)
        :param product_class: CPE product class (EOSSTB, HZNSTB, APLSTB)
        :param _4k_support: Boolean - Indicate if CPE is in 4K or not

        :return: Channel summary details of type Json
        """
        channel_lineup = self.get_current_channel_lineup_via_ls(
            city_id, language, product_class)
        matched_channel = None
        for channel in channel_lineup:
            # BuiltIn().log_to_console("channel: %s" % channel)
            channel_attribute_value = repr(channel[attribute_name]) \
                if isinstance(channel[attribute_name], int) \
                else channel[attribute_name]

            if (attribute_value == channel_attribute_value and

                    (_4k_support or channel["resolution"] != "4K")):
                matched_channel = channel
                break
        return matched_channel

    @staticmethod
    def _get_referenced_channel_number_from_list(
            channel_list, channel_index, position, cpe_id):
        """
        Get previous/next channel number from channel list,
        :param channel_list: All supported channels list
        :param channel_index: Referenced channel index in channel list
        :param position: +/- position of channel from reference channel
        :param cpe_id: unique STB CPE ID
        :return: Referenced channel number
        """

        referenced_channel = None
        service_count = len(channel_list)
        if position < 0:
            if channel_index != 0:
                channel_list = channel_list[:channel_index + position + 1]
            else:
                channel_list = channel_list[:service_count + position + 1]
            channel_list.reverse()
        else:
            if channel_index != (service_count - 1):
                channel_list = channel_list[channel_index + position:]
            else:
                channel_list = channel_list[:position]
                channel_list.reverse()
        for channel in channel_list:
            if '0000F0' in cpe_id and channel['resolution'] == '4K':
                continue
            referenced_channel = channel['logicalChannelNumber']
            break
        return str(referenced_channel)

    @staticmethod
    def _remove_radio_channels_from_channel_lineup(channel_lineup):
        """
        Remove the Radio Channels from channel_lineup
        :param channel_lineup: channel_lineup
        :return: channel_lineup without Radio Channels
        """
        service_count = len(channel_lineup)
        for channel_index in reversed(list(range(service_count))):
            if ("isRadio" in channel_lineup[channel_index]
                    and channel_lineup[channel_index]["isRadio"]):
                del channel_lineup[channel_index]
        return channel_lineup

    def get_from_referenced_channel_via_ls(
            self, city_id, channel_number, cpe_id, language,
            product_class, position=0, radio=False):
        """
        Query Linear Service for channel previous/next to a
        channel in channel lineup
        :param city_id: Current customer city id
        :param channel_number: Channel number
        :param cpe_id: unique STB CPE ID
        :param language: Customer language (OSD language of the STB)
        :param product_class: CPE product class (EOSSTB, HZNSTB, APLSTB)
        :param position: +/- position of channel from reference channel
        :param radio: Retrieve Radio Channels or not (True or False)
        :return: Channel number in the position from referenced position
        """

        position = int(position)
        channel_lineup = \
            self.get_current_channel_lineup_via_ls(
                city_id, language, product_class)
        if not radio:
            channel_lineup = self._remove_radio_channels_from_channel_lineup(channel_lineup)
        service_count = len(channel_lineup)
        found_index = 0
        for channel_index in range(service_count):
            if channel_number == repr(
                    channel_lineup[channel_index]['logicalChannelNumber']):
                found_index = channel_index
                break
            if channel_index == service_count:
                raise ValueError('Channel number not found in position'
                                 ' from the reference channel')
        return self._get_referenced_channel_number_from_list(
            channel_lineup, found_index, position, cpe_id)

    def is_logo_present_in_channel_bar(
            self, city_id, channel_number,
            language, product_class, _4k_support=False):
        """
        Returns if logo is present on server from the input channel number
        :param city_id: Current customer city id
        :param channel_number: Channel number
        :param language: Customer language (OSD language of the STB)
        :param product_class: CPE product class (EOSSTB, HZNSTB, APLSTB)
        :param _4k_support: Boolean - Indicate if CPE is in 4K or not
        :return: logo availability status (True/False)
        """
        is_logo = True
        logo_url = self.get_channel_bar_logo_url(city_id, channel_number,
                                                 language, product_class, _4k_support)
        img_dimension_param = '?w=80&h=50&mode=box'
        logo_image_url = logo_url + img_dimension_param
        BuiltIn().log("Testing Request of logo_image_url: %s" % str(logo_image_url))
        try:
            self._get_http_request(logo_image_url)
        except HTTPError as err:
            is_logo = False
            BuiltIn().log("ERROR: Testing HTTP logo_image_url: %s - %s" % (logo_image_url, err))
        return is_logo

    def get_channel_number_by_id(
            self, city_id, channel_id,
            language, product_class):
        """
        Returns the channel number from the input channel id
        :param city_id: Current customer city id
        :param channel_id: Channel id
        :param language: Customer language (OSD language of the STB)
        :param product_class: CPE product class (EOSSTB, HZNSTB, APLSTB)
        :return: Channel number
        """

        channel_number = None
        channel_summary = \
            self.get_channel_summary_by_attribute_via_ls(
                city_id, 'id', channel_id, language, product_class)

        if channel_summary:
            channel_number = str(channel_summary['logicalChannelNumber'])

        return channel_number

    def get_channel_name_by_id(
            self, city_id, channel_id,
            language, product_class):
        """
        Returns the channel name from the input channel id
        :param city_id: Current customer city id
        :param channel_id: Channel id
        :param language: Customer language (OSD language of the STB)
        :param product_class: CPE product class (EOSSTB, HZNSTB, APLSTB)
        :return: Channel name
        """

        channel_name = None
        channel_summary = \
            self.get_channel_summary_by_attribute_via_ls(
                city_id, 'id', channel_id, language, product_class)
        if channel_summary:
            channel_name = str(channel_summary['name'])

        return channel_name

    def get_channel_number_by_name(
            self, city_id, channel_name,
            language, product_class):
        """
        Returns the channel number from the input channel name
        :param city_id: Current customer city id
        :param channel_name: Channel name
        :param language: Customer language (OSD language of the STB)
        :param product_class: CPE product class (EOSSTB, HZNSTB, APLSTB)
        :return: Channel number
        """

        channel_number = None
        channel_summary = \
            self.get_channel_summary_by_attribute_via_ls(
                city_id, 'name', channel_name, language, product_class)
        if channel_summary:
            channel_number = str(channel_summary['logicalChannelNumber'])
        return channel_number

    def get_channel_bar_logo_basename(
            self, city_id, channel_number,
            language, product_class, _4k_support):
        """
        Returns channel logo name if the logo is present on server
        from the input channel number
        :param city_id: Current customer city id
        :param channel_number: Channel number
        :param language: Customer language (OSD language of the STB)
        :param product_class: CPE product class (EOSSTB, HZNSTB, APLSTB)
        :param _4k_support: Boolean - Indicate if CPE is in 4K or not

        :return: Channel logo base name
        """

        logo_base_name = None
        logo_url = self.get_channel_bar_logo_url(city_id, channel_number,
                                                 language, product_class, _4k_support)
        disassembled = os.path.splitext(
            os.path.basename(urllib.parse.urlsplit(logo_url).path))
        logo_base_name = disassembled[0]
        return logo_base_name

    def get_channel_bar_logo_url(
            self, city_id, channel_number,
            language, product_class, _4k_support):
        """
        Returns channel logo URL if the logo is present on server
        from the input channel number
        :param city_id: Current customer city id
        :param channel_number: Channel number
        :param language: Customer language (OSD language of the STB)
        :param product_class: CPE product class (EOSSTB, HZNSTB, APLSTB)
        :param _4k_support: Boolean - Indicate if CPE is in 4K or not

        :return: Channel logo base name
        """

        logo_url = None
        channel_summary = \
            self.get_channel_summary_by_attribute_via_ls(
                city_id, 'logicalChannelNumber',
                channel_number, language, product_class, _4k_support)
        if channel_summary:
            logo_url = channel_summary['logo']['focused']
        return logo_url

    def get_total_channel_count_via_ls(
            self, city_id, language, product_class):
        """
        Returns the total channel count
        :param city_id: Current customer city id
        :param language: Customer language (OSD language of the STB)
        :param product_class: CPE product class (EOSSTB, HZNSTB, APLSTB)
        :return: Total channel count
        """
        channel_lineup = \
            self.get_current_channel_lineup_via_ls(
                city_id, language, product_class)
        channel_count = len(channel_lineup)
        return channel_count

    def get_random_channel_via_ls(self, city_id, language, product_class):
        """
        Returns a random Channel From Channel Lineup
        :param city_id: Current customer city id
        :param language: Customer language (OSD language of the STB)
        :param product_class: CPE product class (EOSSTB, HZNSTB, APLSTB)
        :return: Total channel count
        """
        req_url = "%s/v1/channels?cityId=%s&language=%s&deviceType=ALL&productClass=%s" % \
                  (self._linear_service_url, city_id, language, product_class)
        response = self._get_http_request(req_url)
        random_channel = random.choice(response.json())
        return random_channel

    @staticmethod
    def get_ip_channel_list(response):
        """
        Returns IP channel list from get_current_channel_lineup_via_ls
        :param response: Response of get_current_channel_lineup_via_ls
        :return: List of IP channels
        """
        channel_identifier_locator = 'locator'
        qam_channel_schange = 'schange'
        ip_channel_list = []
        channel_count = len(response)
        for channel_index in range(channel_count):
            if channel_identifier_locator in list(response[channel_index].keys()):
                if qam_channel_schange in repr(response[channel_index][channel_identifier_locator]):
                    continue

                ip_channel_list.append(response[channel_index]['id'])
        return ip_channel_list

    @staticmethod
    def get_details_of_linear_event(crid, language, returnLinearContent=True):
        """
        Query Linear Service to get the details of Replay Event
        :param crid: crid of Replay event
        :return: Event Details object of type Json
        """
        ls_object = LinearService()
        response = ls_object.get_detail_of_linear_event(crid, language, returnLinearContent)
        return response

    @staticmethod
    def get_qam_channel_list(response):
        """
        Returns QAM channel list from get_current_channel_lineup_via_ls
        :param response: Response of get_current_channel_lineup_via_ls
        :return: List of QAM channels
        """
        channel_identifier_locator = 'locator'
        qam_channel_schange = 'schange'
        qam_channel_list = []
        channel_count = len(response)
        for channel_index in range(channel_count):
            if channel_identifier_locator in response[channel_index].keys():
                if qam_channel_schange in repr(response[channel_index][channel_identifier_locator]):
                    qam_channel_list.append(response[channel_index]['id'])
                else:
                    continue

        return qam_channel_list