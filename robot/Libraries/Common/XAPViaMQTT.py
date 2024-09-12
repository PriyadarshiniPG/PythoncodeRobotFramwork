#!/usr/bin/env python27
"""
Description         Module handling XAP requests

"""
import sys
import json
import logging
from os.path import dirname, join
from robot.libraries.BuiltIn import BuiltIn
import requests

from Libraries.Exceptions.XAPError import XAPPayloadError, XAPResponseError


class XAPViaMQTT(object):
    """
    Class to handle XAP requests
    """
    _xap_request_headers = {'Content-type': 'application/json',
                            'Accept': 'text/plain'}

    def __init__(self):
        """
        Sets all the XAP details
        :return:
        """
        self._broker_url = 'tcp://mqtt:1883' #'tcp://mqtt.appdev.io:1883/mqtt'
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
        self._xap_url = self._micro_service_url + "/xap"
        self._websocket_url = 'ws://127.0.0.1:{0}'

        logger = logging.getLogger('XAPError')
        logger.setLevel(logging.DEBUG)

        file_name = 'XAPError.log'
        directory = dirname(__file__)
        log_path = join(directory, '..', '..', file_name)

        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        file_handler = logging.FileHandler(log_path)
        file_handler.setLevel(logging.DEBUG)
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)

        self._logger = logger

    def get_via_xap(self, cpe_id, url, is_json=True):
        """
        Posts a GET request to XAP
        :param cpe_id: STB ID
        :param url: The request url
        :param is_json: is_json
        :return: payload
        """
        data = {'method': 'GET',
                'cpeId': cpe_id,
                'brokerUrl': self._broker_url,
                'url': url,
                'json': is_json}
        json_data = json.dumps(data)
        return self._post_and_verify(json_data)

    def put_via_xap(self, cpe_id, url, body, headers, raw=False):
        """
        Posts a PUT request to XAP
        :param cpe_id: STB ID
        :param url: The request url
        :param body: request body
        :param headers: request headers
        :return: payload
        """
        if raw:
            body_string = body
        else:
            body_string = json.dumps(body)
        data = {
            'method': 'PUT',
            'cpeId': cpe_id,
            'brokerUrl': self._broker_url,
            'url': url,
            'body': body_string,
            'headers': headers,
            'json': True
        }
        json_data = json.dumps(data)
        return self._post_and_verify(json_data)

    def delete_via_xap(self, cpe_id, url, headers):
        """
        Posts a DELETE request to XAP
        :param cpe_id: STB ID
        :param url: The request url
        :param headers: request headers
        :return: payload
        """
        data = {
            'method': 'DELETE',
            'cpeId': cpe_id,
            'brokerUrl': self._broker_url,
            'url': url,
            'headers': headers
        }
        json_data = json.dumps(data)
        return self._post_and_verify(json_data)

    def post_via_xap(self, cpe_id, url, body=None, headers=None):
        """
        Posts a POST request to XAP
        :param cpe_id: STB ID
        :param url: The request url
        :param body: request body
        :param headers: request headers
        :return: payload
        """
        body_string = json.dumps(body)
        data = {
            'method': 'POST',
            'cpeId': cpe_id,
            'brokerUrl': self._broker_url,
            'url': url,
            'body': body_string,
            'headers': headers,
            'json': True
        }
        json_data = json.dumps(data)
        return self._post_and_verify(json_data)

    def post_ss_via_xap(self, cpe_id, width, height, compression_type):
        """
        Posts a POST request to XAP for screenshot
        :param cpe_id: STB ID
        """
        data = {'cpeId': cpe_id,
                'brokerUrl': self._broker_url,
                'w': width,
                'h': height,
                'compressionType': compression_type
               }
        json_data = json.dumps(data)
        json_response = self._xap_request_screenshot(
            json_data)
        return self._verify_response(json_response)

    def _verify_response(self, json_response):
        """
        Verify the response from XAP
        :param json_response:
        :return: payload
        """
        payload = 'payload'
        error = 'error'
        if type(json_response) is str:
            json_response = json.loads(json_response)
            if json_response['event'] == 'keyPress':
                # json_response = json.loads(json_response)
                return json_response['payload']
            else:
                return json_response['payload']

        else:
            if json_response.status_code == 200:
                json_object = json_response.json()
                if json_object.get(error) is not None:
                    raise XAPResponseError(
                        json.dumps(json_object[error]), self._logger)
                if payload in json_object:
                    payload_content = json_object[payload]
                    if isinstance(payload_content,
                                  dict) and error in payload_content and payload_content[error] is not None:
                        raise XAPPayloadError(
                            self._logger, json.dumps(payload_content[error]))
                return json_object.get(payload)
            raise XAPResponseError(json_response, self._logger)

    def _xap_request(self, data_to_be_posted):
        """
        Post the request to XAP and return the response
        :param data_to_be_posted:
        :return:
        """
        post_to_url = 'http://' + self._xap_url + '/http'
        xap_timeout = BuiltIn().get_variable_value("${XAP_TIMEOUT}")
        if xap_timeout == 'True':
            try:
                json_response = requests.post(post_to_url,
                                              headers=self._xap_request_headers,
                                              stream=True,
                                              data=data_to_be_posted,
                                              timeout=1.5)
                return json_response
            except:
                # print("XAP performance validation timed out, took more than 1 sec")
                BuiltIn().set_global_variable("${PERF_CHECK_XAP_TIMEDOUT}", 'True')
                is_Xap_Reboot = BuiltIn().get_variable_value("${TEST TAGS}")
                if 'Xap_Reboot' in is_Xap_Reboot:
                    BuiltIn().set_global_variable("${PERF_CHECK_XAP_TIMEDOUT}", 'False')
                thisdict = {
                    "event": "xapPerfValidation",
                    "payload": {"status": "XAP performance validation timed out, took more than 1.5 sec", "msg": ""},
                }
                json_response = json.dumps(thisdict)
                return json_response
        else:
            if data_to_be_posted.__contains__('keyinjector'):
                try:
                    json_response = requests.post(post_to_url,
                                                  headers=self._xap_request_headers,
                                                  stream=True,
                                                  data=data_to_be_posted,
                                                  timeout=0.4)
                    return json_response
                except:
                    print("XAP key press timed out, took more than 0.4 sec")
                    thisdict = {
                        "event" : "keyPress",
                        "payload": {"stat": "OK", "msg": ""},
                    }
                    json_response = json.dumps(thisdict)
                    return json_response
            else:
                print("20 Sec time out for normal Xap validation")
                json_response = requests.post(post_to_url,
                                              headers=self._xap_request_headers,
                                              stream=True,
                                              data=data_to_be_posted,
                                              timeout=20)
                return json_response


    def _xap_request_ws(self, data_to_be_posted):
        """
        Post the request to XAP and return the response
        :param data_to_be_posted: data which should be send via xap
        :return: json_response: result of post request to xap
        """
        post_to_url = 'http://' + self._xap_url + '/ws'
        json_response = requests.post(post_to_url,
                                      headers=self._xap_request_headers,
                                      stream=True,
                                      data=data_to_be_posted,
                                      timeout=20)
        return json_response

    def _xap_request_screenshot(self, data_to_be_posted):
        """
        Post the request to XAP and return the response
        :param data_to_be_posted:
        :return:
        """
        post_to_url = 'http://' + self._xap_url + '/screenshot'
        json_reply = requests.post(post_to_url,
                                   headers=self._xap_request_headers,
                                   stream=True,
                                   data=data_to_be_posted,
                                   timeout=20)
        return json_reply

    def _post_and_verify(self, json_data):
        """
        Posts the request and verify the response
        :param json_data:
        :return: payload
        """
        json_response = self._xap_request(json_data)

        return self._verify_response(json_response)

    def send_websocket_message(self, message, cpe_id, port):
        """
        Sends websocket command via XAP
        :param message: message which should be send via websocket
        :param port: port of websocket service
        """
        self._open_websocket(cpe_id, port)
        self._send_websocket_message(cpe_id, port, message)
        self._close_websocket(cpe_id, port)

    def _open_websocket(self, cpe_id, port):
        self._send_websocket_command('connect', cpe_id, port)

    def _send_websocket_message(self, cpe_id, port, message):
        self._send_websocket_command('send', cpe_id, port, message)

    def _close_websocket(self, cpe_id, port):
        self._send_websocket_command('close', cpe_id, port)

    def _send_websocket_command(self, cpe_id, port, command, message=''):
        data = {
            'command': command,
            'cpeId': cpe_id,
            'brokerUrl': self._broker_url,
            'url': self._websocket_url.format(port),
            'message': message
        }

        json_data = json.dumps(data)
        json_response = self._xap_request_ws(json_data)

        if json_response.status_code != 200:
            raise XAPResponseError(json_response, self._logger)
