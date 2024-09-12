"""
    This module provides a class for Json scraping
"""
import re
from collections import OrderedDict
import simplejson as json
from requests import HTTPError
from Libraries.Common.AppServicesRequestHandler import AppServicesRequestHandler


# pylint: disable=R0913,no-self-use,too-many-locals,too-many-branches


class JsonUiHandler(object):
    """
        This class provides methods for Json scraping
    """
    _testtools_url_xap = 'http://127.0.0.1:8125'

    def __init__(self, application_service_handler=AppServicesRequestHandler()):
        """
        Constructor, Initialization of application service handler
        :param application_service_handler: Application service handler object
        """
        self.as_handler = application_service_handler

    def _get_ui_handler_json_info(self, ip_address, cpe_id, url, xap):
        """
        This method send a GET request to testtools via XAP by default
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param url: Json request URL
        :param xap: Is xap request
        :return: json payload response
        """
        return self.as_handler.get(
            ip_address, cpe_id, url, True, xap=xap, timeout=10)

    def _put_ui_json_info(self, ip_address, cpe_id, url, body=None, xap=True):
        """
        This method send a PUT request to testtools via XAP by default
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param url: Json request URL
        :param xap: Is xap request
        """
        headers = {'Content-type': 'application/json'}
        return self.as_handler.put(
            ip_address, cpe_id, url, body, headers, xap=xap, timeout=10)

    def _delete_ui_json_info(self, ip_address, cpe_id, url, xap):
        """
        This method send a DELETE request to testtools via XAP by default
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param url: Json request URL
        :param xap: Is xap request
        """
        headers = {'Accept': 'application/json'}
        return self.as_handler.delete(
            ip_address, cpe_id, url, headers, xap=xap, timeout=10)

    def get_ui_json_via_tt(self,
                           ip_address, cpe_id,
                           version=2,
                           xap=True):
        """
        This method performs a request to STB to get json ui
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param version: version of state endpoint
        :param xap: Is xap request
        :return: json payload response
        """
        url = self._testtools_url_xap + _version_path(version)
        url += '/state'
        json_reply = self._get_ui_handler_json_info(
            ip_address, cpe_id, url, xap)
        if json_reply:
            default_ordered_json = json.loads(
                json.dumps(json_reply), encoding='utf-8')
            return default_ordered_json

        raise HTTPError('Unable to retrieve JSON UI')

    def get_player_json_via_tt(self, ip_address, cpe_id, xap=True):
        """
        This method performs a request to STB to get player json
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        :return: json payload response
        """
        url = self._testtools_url_xap + '/player/state'
        json_reply = self._get_ui_handler_json_info(
            ip_address, cpe_id, url, xap)
        if json_reply:
            default_ordered_json = json.loads(
                json.dumps(json_reply), encoding='utf-8')
            return default_ordered_json

        raise HTTPError('Unable to retrieve Player JSON')

    def get_data_via_testtools(self, ip_address, cpe_id, path, xap=True):
        """
        This method performs a custom HTTP GET request to STB to retrieve
        data via testtols
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param path: Json request route path
        :param xap: Is xap request
        :return: json payload response
        """
        url = self._testtools_url_xap + path
        json_reply = self._get_ui_handler_json_info(
            ip_address, cpe_id, url, xap)
        if json_reply:
            default_ordered_json = json.loads(
                json.dumps(json_reply), encoding='utf-8')
            return default_ordered_json

        raise HTTPError('Unable to retrieve JSON UI')

    def get_ui_json_focused_elements_via_tt(self,
                                            ip_address, cpe_id,
                                            version=2,
                                            xap=True):
        """
        This method performs a request to STB to get json ui
        focused elements
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :return: json payload response
        """
        url = self._testtools_url_xap + _version_path(version)
        url += '/nodes/focused'
        json_reply = self._get_ui_handler_json_info(
            ip_address, cpe_id, url, xap)
        if json_reply:
            default_ordered_json = json.loads(json.dumps(
                json_reply))
            return default_ordered_json

        raise HTTPError('Unable to retrieve JSON UI')

    def get_locale_languages_via_tt(self, ip_address, cpe_id, xap=True):
        """
        This method performs a request to STB to get the
        list of locales proposed to the User for the UI
        :return: json payload response
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        :return: locale languages
        """
        url = self._testtools_url_xap + '/locale/options'
        json_reply = self._get_ui_handler_json_info(
            ip_address, cpe_id, url, xap)
        if json_reply:
            default_ordered_json = json.loads(
                json.dumps(json_reply), encoding='utf-8')
            return default_ordered_json

        raise HTTPError('Unable to retrieve UI Locale languages')

    def get_locale_keys_via_tt(self, ip_address, cpe_id, xap=True):
        """
        This method performs a request to STB to get the list
        of translation keys available for the current locale
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        :return: json payload response
        """
        url = self._testtools_url_xap + '/locale/keys'
        json_reply = self._get_ui_handler_json_info(
            ip_address, cpe_id, url, xap)
        if json_reply:
            default_ordered_json = json.loads(
                json.dumps(json_reply), encoding='utf-8')
            return default_ordered_json

        raise HTTPError('Unable to retrieve UI Locale keys')

    def get_locale_state_via_tt(self, ip_address, cpe_id, xap=True):
        """
        This method performs a request to STB to get the list
        of truncated & not truncated translated texts
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        :return: json payload response
        """
        url = self._testtools_url_xap + '/locale/state'
        json_reply = self._get_ui_handler_json_info(
            ip_address, cpe_id, url, xap)
        if json_reply:
            default_ordered_json = json.loads(
                json.dumps(json_reply), encoding='utf-8')
            return default_ordered_json

        raise HTTPError('Unable to retrieve UI Locale keys')

    def get_ui_config_via_tt(self, ip_address, cpe_id, key,
                             version=2,
                             xap=True):
        """
        This method performs a request to STB to get json ui config
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param key: One of the keys
        :param version: endpoint version
        :param xap: Is xap request
        :return: json payload response
        """
        url = self._testtools_url_xap + _version_path(version)
        url += '/config'
        json_reply = self._get_ui_handler_json_info(
            ip_address, cpe_id, url + '/' + key, xap)
        if json_reply:
            default_ordered_json = json.loads(
                json.dumps(json_reply), encoding='utf-8')
            return default_ordered_json

        raise HTTPError('Unable to retrieve UI CONFIG')

    def set_ui_config_via_tt(self, ip_address, cpe_id, key, value,
                             version=2,
                             xap=True):
        """
        This method performs a request to STB to set a ui config value
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param key: key in json dict
        :param value:  value in json dict
        :param version: endpoint version
        :param xap: Is xap request
        """
        url = self._testtools_url_xap + _version_path(version)
        url += '/config/' + key + '/' + value
        self._put_ui_json_info(ip_address, cpe_id, url, xap=xap)

    def reset_recently_used_apps_via_tt(self, ip_address, cpe_id, xap=True):
        """
        This method performs a reset the recently used app list of the STB
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        :return: json payload response
        """
        url = self._testtools_url_xap + '/apps/recentlyUsed'
        apps = self._delete_ui_json_info(ip_address, cpe_id, url, xap)
        if apps == '[]':
            return True

        raise HTTPError('Unable to reset Recently Used App list')

    def set_recently_used_apps_via_tt(
            self, ip_address, cpe_id, app_list, xap=True):
        """
        This method initialize the recently used app list of the STB
        with specific app ids (seperated by comas)
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param app_list: List of Apps to be initialized
        :param xap: Is xap request
        :return: json payload response
        """
        url = self._testtools_url_xap + '/apps/recentlyUsed'
        json_reply = self._put_ui_json_info(
            ip_address, cpe_id, url, app_list, xap)
        if json_reply:
            return True

        raise HTTPError('Unable to set Recently Used App list')

    @staticmethod
    def is_in_json(json_object, in_param, find_param,
                   and_params=None, regexp=False):
        """
        This method checks if given values are in Json parameter
        parameter
        :param json_object: json object
        :param in_param: value to depict a json subtree to search within,
        e.g. id:block_3_event_4_0_text
        :param find_param: value to search in found json subtree,
        e.g. visible:false
        :param and_params: list of optional values to find along find_param
        :param regexp: flag which informs that in_param and find_param contain
        regular expression patterns
        :return: bool result
        """
        json_object = _convert_to_ordered_dict(json_object)
        in_param_key = in_param[0:in_param.find(':')]
        in_param_value = _get_find_param_value(in_param, regexp)

        find_param_key = find_param[0:find_param.find(':')]
        find_param_value = _get_find_param_value(find_param, regexp)

        and_params = and_params if and_params else []

        found_jsons = []
        _get_json_fragment_for_search(
            json_object, in_param_key, in_param_value, found_jsons, regexp)

        result_list = [False]
        for found_json in found_jsons:
            find_param_in_json, _ = _is_find_param_in_json(
                find_param_key, find_param_value, and_params,
                found_json, regexp)
            result_list.append(find_param_in_json)
        return max(result_list)

    @staticmethod
    def extract_value_for_key(json_object, in_param, key_name, regexp=False):
        """
        This method extracts value for given key from given json
        :param json_object: json object
        :param in_param: value to depict a json subtree to search within,
        e.g. id:block_3_event_4_0_text
        :param key_name: key which value should be retrieved
        :param regexp: flag which informs that in_param contains
        regular expression patterns
        :return: found value
        """
        json_object = _convert_to_ordered_dict(json_object)
        in_param_key = in_param[0:in_param.find(':')]
        in_param_value = _get_find_param_value(in_param, regexp)

        found_jsons = []
        _get_json_fragment_for_search(
            json_object, in_param_key, in_param_value, found_jsons, regexp)

        extracted = None
        for found_json in found_jsons:
            extracted, successful = _extract_value(key_name, found_json)
            if successful:
                break
        if extracted is None:
            extracted = 'None'
        return extracted

    @staticmethod
    def get_enclosing_json(json_object, in_param, find_param,
                           ancestor_level, and_params=None,
                           regexp=False):
        """
        This method returns ancestor json of given level for entry
        identified by in_param parameter
        :param json_object: json object
        :param in_param: value to depict a json subtree to search within,
        e.g. id:block_3_event_4_0_text
        :param find_param: value to search in found json subtree,
        e.g. visible:false
        :param ancestor_level: 1 - parent, 2 - grandfather, and so on
        :param and_params: list of optional values to find along find_param
        :param regexp: flag which informs that in_param and find_param contain
        regular expression patterns
        :return: bool json as dictionary
        """
        json_object = _convert_to_ordered_dict(json_object)
        in_param_key = in_param[0:in_param.find(':')]
        in_param_value = _get_find_param_value(in_param, regexp)

        find_param_key = find_param[0:find_param.find(':')]
        find_param_value = _get_find_param_value(find_param, regexp)

        and_params = and_params if and_params else []

        found_jsons = []
        _get_json_fragment_for_search(
            json_object, in_param_key, in_param_value, found_jsons, regexp)

        ancestor = {}
        for found_json in found_jsons:
            find_param_in_json, found_node = _is_find_param_in_json(
                find_param_key, find_param_value, and_params,
                found_json, regexp)
            if find_param_in_json:
                entire_json_string = _get_string_from_ordered_dict(json_object)
                found_json_string = _get_string_from_ordered_dict(found_json)
                node_string = _get_string_from_ordered_dict(found_node)

                search_start_index = entire_json_string.index(
                    found_json_string) + found_json_string.index(node_string)
                search_end_index = search_start_index + len(node_string)
                json_length = len(entire_json_string)

                ancestor = _get_parent_json_string(
                    search_start_index, search_end_index,
                    json_length, entire_json_string, ancestor_level)
                ancestor = json.loads(
                    ancestor, encoding='utf-8', object_pairs_hook=OrderedDict)
                break
        return ancestor

    @staticmethod
    def read_json_as_string(json_object):
        """
        This method returns json content as string
        :param json_object: json object
        :return: json content as string
        """
        content = json.dumps(json_object, encoding='utf-8')
        return content.replace('\r\n', '\n')

    @staticmethod
    def check_if_jsons_are_different(json_object, other_json_object):
        """Simple method to determinate if difference between to json objects is present"""
        return json_object != other_json_object


def _version_path(version=1):
    """
    Generate potentialy required version subpath
    :param version: API version number
    """
    return '' if (version == 1) else '/v' + str(version)


def _get_string_from_ordered_dict(ordered_dict):
    return json.dumps(ordered_dict, encoding='utf-8', separators=(',', ':'))


def _get_json_fragment_for_search(
        node, in_param_key, in_param_value, jsons_list, regexp):
    if in_param_key and in_param_value:
        if isinstance(node, dict):
            if regexp:
                pattern = re.compile(in_param_value)
                if in_param_key in node and pattern.match(
                        node[in_param_key]):
                    jsons_list.append(node)
            else:
                if in_param_key in node \
                        and node[in_param_key] == in_param_value:
                    jsons_list.append(node)
            for attribute in node:
                _get_json_fragment_for_search(
                    node[attribute], in_param_key, in_param_value,
                    jsons_list, regexp)
        elif isinstance(node, list):
            for item in node:
                _get_json_fragment_for_search(
                    item, in_param_key, in_param_value, jsons_list, regexp)
    else:
        jsons_list.append(node)


def _extract_value(key, node):
    successful = False
    if isinstance(node, dict):
        if key in node:
            return node[key], True
        for attribute in node:
            extracted, successful = _extract_value(key, node[attribute])
            if successful:
                return extracted, successful
    elif isinstance(node, list):
        for item in node:
            extracted, successful = _extract_value(key, item)
            if successful:
                return extracted, successful
    return None, successful


def _is_find_param_in_json(
        key, value, additional_params, node, regexp):
    result = False
    found_node = None
    if isinstance(node, dict):
        if regexp:
            pattern = re.compile(value)
            if key in node and pattern.match(str(node[key])):
                result = True
                for additional_param in additional_params:
                    param_key = additional_param[0:additional_param.find(':')]
                    param_value = _get_find_param_value(
                        additional_param, regexp)
                    additional_pattern = re.compile(param_value)
                    result = \
                        param_key in node and \
                        bool(additional_pattern.match(
                            str(node[param_key])))
                if result:
                    return result, node
            else:
                for attribute in node:
                    result, found_node = _is_find_param_in_json(
                        key, value, additional_params, node[attribute], regexp)
                    if result:
                        return result, found_node
        else:
            if key in node and node[key] == value:
                result = True
                for additional_param in additional_params:
                    param_key = additional_param[0:additional_param.find(':')]
                    param_value = _get_find_param_value(
                        additional_param, regexp)
                    result = \
                        param_key in node and \
                        node[param_key] == param_value
                if result:
                    return result, node
            else:
                for attribute in node:
                    result, found_node = _is_find_param_in_json(
                        key, value, additional_params, node[attribute], regexp)
                    if result:
                        return result, found_node
    elif isinstance(node, list):
        for item in node:
            result, found_node = _is_find_param_in_json(
                key, value, additional_params, item, regexp)
            if result:
                return result, found_node
    return result, found_node


def _get_find_param_value(find_param, regexp):
    if regexp:
        find_param_value = find_param[find_param.find(':') + 1:]
    else:
        find_param_value = _get_object_find_param_value(find_param)
    return find_param_value


def _get_object_find_param_value(find_param):
    string_value = find_param[find_param.find(':') + 1:]
    integer_pattern = re.compile('^\\d+$')
    boolean_pattern = re.compile('^(true|false)$')
    none_pattern = re.compile('^null$')

    if integer_pattern.match(string_value):
        find_param_value = int(string_value)
    elif boolean_pattern.match(string_value):
        bool_string = string_value[:1].upper() + string_value[1:]
        find_param_value = bool(bool_string == 'True')
    elif none_pattern.match(string_value):
        find_param_value = None
    else:
        find_param_value = string_value

    key = find_param[0:find_param.find(':')]
    if key == 'textValue':
        find_param_value = str(find_param_value)
    return find_param_value


def _get_parent_json_string(
        search_start_index, search_end_index, json_length,
        entire_json_string, ancestor_level):
    count = 0
    i = 0
    j = 0
    k = 0
    parent_start = 0
    parent_end = 0

    for i in range(0, ancestor_level):
        j = search_start_index
        while j != -1:
            char = entire_json_string[j]
            if char == '}':
                count += 1
            elif char == '{' and count != 0:
                count -= 1
            elif char == '{' and count == 0:
                parent_start = j
                search_start_index = j - 1
                count = 0
                break
            j -= 1

        k = search_end_index - 1
        while k != json_length:
            char = entire_json_string[k]
            if char == '{':
                count += 1
            elif char == '}' and count != 0:
                count -= 1
            elif char == '}' and count == 0:
                parent_end = k
                search_end_index = k + 2
                count = 0
                break
            k += 1

    if (j == -1 or k == json_length) and i != ancestor_level:
        parent = ''
    else:
        parent = entire_json_string[parent_start:parent_end + 1]

    return parent


def _convert_to_ordered_dict(json_object):
    """
    Convert json object to ordered dictionary
    :param json_object:
    :return:
    """
    sorted_json = json.dumps(
        json_object, encoding='utf-8', sort_keys=True)
    return json.loads(sorted_json, encoding='utf-8',
                      object_pairs_hook=OrderedDict)
