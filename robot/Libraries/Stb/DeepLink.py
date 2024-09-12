"""
    Module contains methods used for navigation via DeepLinks on STB UI
"""
# import websocket

from Libraries.Common.XAPViaMQTT import XAPViaMQTT

# pylint: disable=too-few-public-methods, too-many-arguments


class DeepLink(object):
    """
        Class contains methods used for navigation via DeepLinks on STB UI
    """
    _message_template = 'navigateTo:{{\"path\": \"{0}\", \"params\":{1}}}'
    _deeplink_port = '10016'

    def __init__(self, requests_via_xap=None):
        if requests_via_xap:
            self.requests_via_xap = requests_via_xap
        else:
            self.requests_via_xap = XAPViaMQTT()

    # def navigate_to_view_via_deeplink(
    #         self, ip_address, cpe_id, path, params, xap=False):
    #     """
    #     Method which opens view in parameter on UI
    #     :param ip_address: STB IP address
    #     :param cpe_id: STB ID
    #     :param path: deeplink path
    #     :param params: params for deeplink method
    #     :param xap: Is xap request
    #     """
    #     message = self._message_template.format(path, params)
    #     if xap:
    #         self._navigate_to_view_via_deeplink_xap(message, cpe_id)
    #     else:
    #         self._navigate_to_view_via_deeplink_direct(message, ip_address)

    def _navigate_to_view_via_deeplink_xap(self, message, cpe_id):
        self.requests_via_xap.send_websocket_message(
            message, cpe_id, self._deeplink_port)

    # def _navigate_to_view_via_deeplink_direct(self, message, ip_address):
    #     web_socket = websocket.WebSocket()
    #     web_socket.connect(
    #         'ws://{0}:{1}'.format(ip_address, self._deeplink_port),
    #         timeout=30)
    #     web_socket.send(message)
    #     web_socket.close(timeout=10)
