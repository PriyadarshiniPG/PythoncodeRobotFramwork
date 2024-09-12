"""
Creator for Obelix/Panoramix instances
"""

from Libraries.Obelix.ObelixAudio import ObelixAudio
from Libraries.Obelix.ObelixClient import ObelixClient
from Libraries.Obelix.ObelixHD import ObelixHD, ObelixHDVideo
from Libraries.Obelix.ObelixPDU import ObelixPDU
from Libraries.Stb.IRRemote import IRRemote
from Libraries.panoramix.PanoramixClient import PanoramixClient
from Libraries.panoramix.PanoramixConnect import PanoramixConnect


class ObelixPanoramixCreator(object):
    """
    A factory for keyword classes related to black-box bench utils
    """

    def __init__(self, rack_config):
        self._rack_config = rack_config

    def create_instances(self):
        """"Creates instances based on server type"""
        if self._rack_config['PANORAMIX_SUPPORT']:
            instances = self._create_panoramix_instances()
        else:
            instances = self._create_obelix_instances()
        return instances

    def _create_obelix_instances(self):
        """
        Create Obelix instances based on version of Obelix
        :return: Dictionary of Obelix instances
        """
        instances = None
        server_type = 'Legacy'
        if self._rack_config['OBELIX_SUPPORT']:
            server_type = ObelixClient(self._rack_config).get_server_type(
                self._rack_config['RACK_PC_IP'])
        if server_type == 'Mondrian':
            instances = self._create_obelix_mondrian_instances()
        elif server_type == 'Legacy':
            instances = self._create_obelix_legacy_instances()
        return instances

    def _create_panoramix_instances(self):
        """
        Create panoramix instances
        :return: Dictionary of panoramix instances
        """
        return {
            'Connect': PanoramixConnect(),
            'Video': PanoramixClient(self._rack_config['RACK_PC_IP'])
        }

    def _create_obelix_mondrian_instances(self):
        return {'Video': ObelixClient(self._rack_config['RACK_PC_IP'])}

    def _create_obelix_legacy_instances(self):
        """
        Create Obelix legacy instances
        :return: Dictionary of Obelix legacy instances
        """
        return {
            'Audio': ObelixAudio(self._rack_config),
            'Video': ObelixHDVideo(self._rack_config['RACK_PC_IP']),
            'Connect': ObelixHD(self._rack_config),
            'Power': ObelixPDU(self._rack_config),
            'Ir': IRRemote(self._rack_config['RACK_PC_IP'])
        }
