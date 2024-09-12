#!/usr/bin/env python27
# -*- coding: utf-8 -*-
"""
Description         Class definition for the Bookmark Service
Reference: https://wikiprojects.upc.biz/display/SPARK/
Bookmark+Service+API+Specification
"""

import sys
import json
import requests
from requests import HTTPError
# from Utils.zephyr_reporter.Keywords.zephyr_api import retry_decorator
from robot.libraries.BuiltIn import BuiltIn
from Libraries.general.keywords import Keywords as general

class BookmarkService(object):
    """
    Reference: https://wikiprojects.upc.biz/display/SPARK/
                Bookmark+Service+API+Specification
    """
    def __init__(self):
        """
        Initialise.
        """
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
        self._bookmark_service_url = "http://"+self._micro_service_url+"/bookmark-service/"

    @staticmethod
    def _get_http_request(url, headers=None, parameters=None):
        """
        http get request
        :param url: The request url
        :return response: The response from the request
        """
        headers = general.update_microservice_headers(headers)
        response = requests.get(url, headers=headers, params=parameters, timeout=10)
        if response.status_code in [200, 204]:
            return response

        raise HTTPError('Status:', response.status_code,
                        response.reason)


    @staticmethod
    def _put_http_request(url, parameters=None, headers=None):
        """
        http get request
        :param url: The request url
        :return response: The response from the request
        """
        headers = general.update_microservice_headers(headers)
        response = requests.put(url, data=parameters, headers=headers)
        if response.status_code in [200, 204]:
            return response

        raise HTTPError('Status:', response.status_code,
                        response.reason)

    @staticmethod
    def _delete_http_request(url):
        """
        http delete request
        :param url: The request url
        :return response: The response from the request
        """
        response = requests.delete(url, timeout=10)
        if response.status_code != 204:
            raise HTTPError('Status:', response.status_code,
                            'Problem with the request')
        return response

    # @retry_decorator
    def get_profile_bookmarks_via_cs(self, profile_id, content_type=None, return_json=True):
        """
        Query the Bookmark Service for the list of bookmarks for the given
        profile with given content type.
        :param profile_id: The profile id string to get the bookmarks from
        :param content_type: The content type to filter the bookmarks.
        Defaults to None. Accepted values are 'vod', 'replay',
        'network-recording', and 'local-recording'
        :param return_json: return json if true else complete response
        :return list of all bookmarks for the given profile, filtered
        by the content type if provided
        """
        req_url = '{}profiles/{}/bookmarks'.format(
            self._bookmark_service_url, profile_id)

        if content_type:
            req_url += '?contentType={}'.format(content_type)

        bookmarks = self._get_http_request(req_url, headers=None, parameters=None)
        if return_json:
            bookmarks = bookmarks.json()
        return bookmarks

    def delete_profile_bookmarks_via_cs(self, profile_id):
        """
        Delete all bookmarks for the given profile
        :param profile_id: The profile id string to delete the bookmarks from
        """
        req_url = '{}profiles/{}/bookmarks'.format(
            self._bookmark_service_url, profile_id)

        return self._delete_http_request(req_url)

    # pylint: disable=too-many-arguments
    def set_profile_bookmarks_via_cs(self, profile_id, content_id,
                                     customer_id, cpe_id, bookmark_position,
                                     asset_duration, content_type, season_id=None,
                                     show_id=None, episode_number=0, season_number=0,
                                     is_adult=False, minimum_age=0,
                                     deletion_date=None, channel_id=None):
        """
        Stores a bookmark for a given profile and content (which can be either vod,
        replay, or a recording)
        :param profile_id: the profile id string to get the bookmarks from
        :param content_id: the crid_id of the asset for which we want to set bookmark
        :param customer_id: customer id of the CPE
        :param cpe_id: cpe id of the box
        :param bookmark_position: the bookmark position we want set(in seconds)
        :param asset_duration: duration of the asset (in seconds)
        :param season_id: season id of recording or replay asset
        :param show_id: show id of recording or replay asset
        :param episode_number: season number of recording or replay asset
        :param season_number: season number of recording or replay asset
        :param is_adult: flag whether asset is adult or not
        :param minimum_age: age raiting of the asset
        :param content_type: The content type to filter the bookmarks.
            Defaults to None. Accepted values are 'vod', 'replay',
            'network-recording', and 'local-recording'
        :param deletion_date: deletion date of the asset
        :param channel_id: channel id for replay channel
        """
        req_url = '{}profiles/{}/bookmarks/{}'.format(
            self._bookmark_service_url, profile_id, content_id)
        if content_type == 'vod':
            title_id = content_id
        else:
            content_list = content_id.split(",")
            title_id = content_list[0]

        parameters = json.dumps({'customerId': customer_id, 'position': bookmark_position,
                                 'duration': asset_duration, 'titleId': title_id,
                                 'seasonId': season_id, 'showId': show_id,
                                 'episodeNumber': episode_number, 'seasonNumber': season_number,
                                 'isAdult': is_adult, 'minimumAge': minimum_age,
                                 'contentType': content_type,
                                 'deletionDate': deletion_date,
                                 'channelId': channel_id})

        response = self._put_http_request(req_url, parameters, headers=None)
        return response
