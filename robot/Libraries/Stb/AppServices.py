#!/usr/bin/env python27
# pylint: disable=C0103, W0703, invalid-name
"""
Module handling STB application service calls
"""

import json
from robot.libraries.BuiltIn import BuiltIn
from Libraries.Common.utils import get_non_consistent_channel_numbers
from Libraries.Common.AppServicesRequestHandler import AppServicesRequestHandler

LANG_BE = ["nl", "fr", "en", "", "ar", "bo", "zh", "hr", "cs", "da", "et",
           "el", "fi", "de", "he", "hi", "hu", "it", "lv", "lt", "no", "mt",
           "mk", "pl", "pt", "ro", "ru", "sr", "sk", "es", "sv", "tr", "ur"]
LANG_NL = ["nl", "en", "", "ar", "bo", "zh", "hr", "cs", "da", "et", "el",
           "fi", "fr", "de", "he", "hi", "hu", "it", "lv", "lt", "no", "mt",
           "mk", "pl", "pt", "ro", "ru", "sr", "sk", "es", "sv", "tr", "ur"]
LANG_CH = ["de", "fr", "it", "en", "", "ar", "bs", "zh", "hr", "cs", "da",
           "nl", "et", "el", "fi", "he", "hi", "hu", "lv", "lt", "no", "mt",
           "mk", "pl", "pt", "ro", "ru", "sr", "sk", "es", "sv", "tr", "ur"]
LANG_CL = ["es", "en", "", "ar", "bs", "zh", "hr", "cs", "da", "nl", "et",
           "el", "fi", "fr", "de", "he", "hi", "hu", "it", "lv", "lt", "no",
           "mt", "mk", "pl", "pt", "ro", "ru", "sr", "sk", "sv", "tr", "ur"]
LANG_GB = ["en", "", "ar", "bs", "zh", "hr", "cs", "da", "nl", "et", "el",
           "fi", "fr", "de", "he", "hi", "hu", "it", "lv", "lt", "no", "mt",
           "mk", "pl", "pt", "ro", "ru", "sr", "sk", "es", "sv", "tr", "ur"]
PREF_LANG_BE = ["nl", "fr", "en"]
PREF_LANG_NL = ["nl", "en"]
PREF_LANG_CH = ["de", "fr", "it", "en"]
PREF_LANG_CL = ["es", "en"]
PREF_LANG_GB = ["en"]
AUDIO_DEFAULT = "nl"
AUDIO_DEFAULT_CH = "de"
AUDIO_DEFAULT_CL = "es"
AUDIO_DEFAULT_GB = "en"
OSD_DEFAULT = "nl"
OSD_DEFAULT_CH = "de"
OSD_DEFAULT_CL = "es"
OSD_DEFAULT_GB = "en"
AGELOCK_DEFAULT = -1
NL_AR_LIST = [-1, 6, 9, 12, 16, 18]
BE_AR_LIST = [-1, 6, 9, 12, 16, 18]
CH_AR_LIST = [-1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18]
CL_AR_LIST = [-1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18]
GB_AR_LIST = [-2, -1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18]
TIMEZONE_BE = 'Europe/Brussels'
TIMEZONE_NL = 'Europe/Amsterdam'
TIMEZONE_CH = 'Europe/Zurich'
TIMEZONE_CL = 'America/Santiago'
TIMEZONE_GB = 'Europe/London'
COUNTRY_BE_DEFAULTS = {
    'code': 'be',
    'agelock_default': AGELOCK_DEFAULT,
    'time_zone': TIMEZONE_BE,
    'pref_list': PREF_LANG_BE,
    'osd_list': PREF_LANG_BE,
    'agelock_list': BE_AR_LIST,
    'audio_list': LANG_BE,
    'sub_list': LANG_BE,
    'audio_default': AUDIO_DEFAULT,
    'osd_default': OSD_DEFAULT,
    'skip_screens': [],
    'personal_suggestions': True
}
COUNTRY_NL_DEFAULTS = {
    'code': 'nl',
    'agelock_default': AGELOCK_DEFAULT,
    'time_zone': TIMEZONE_NL,
    'pref_list': PREF_LANG_NL,
    'osd_list': PREF_LANG_NL,
    'agelock_list': NL_AR_LIST,
    'audio_list': LANG_NL,
    'sub_list': LANG_NL,
    'audio_default': AUDIO_DEFAULT,
    'osd_default': OSD_DEFAULT,
    'skip_screens': ["languageSelection", "network"],
    'personal_suggestions': False
}
COUNTRY_CH_DEFAULTS = {
    'code': 'ch',
    'agelock_default': AGELOCK_DEFAULT,
    'time_zone': TIMEZONE_CH,
    'pref_list': PREF_LANG_CH,
    'osd_list': PREF_LANG_CH,
    'agelock_list': CH_AR_LIST,
    'audio_list': LANG_CH,
    'sub_list': LANG_CH,
    'audio_default': AUDIO_DEFAULT_CH,
    'osd_default': OSD_DEFAULT_CH,
    'skip_screens': ["languageSelection", "network"],
    'personal_suggestions': False
}
COUNTRY_CL_DEFAULTS = {
    'code': 'cl',
    'agelock_default': AGELOCK_DEFAULT,
    'time_zone': TIMEZONE_CL,
    'pref_list': PREF_LANG_CL,
    'osd_list': PREF_LANG_CL,
    'agelock_list': CL_AR_LIST,
    'audio_list': LANG_CL,
    'sub_list': LANG_CL,
    'audio_default': AUDIO_DEFAULT_CL,
    'osd_default': OSD_DEFAULT_CL,
    'skip_screens': ["languageSelection", "network"],
    'personal_suggestions': False
}
COUNTRY_GB_DEFAULTS = {
    'code': 'gb',
    'agelock_default': AGELOCK_DEFAULT,
    'time_zone': TIMEZONE_GB,
    'pref_list': PREF_LANG_GB,
    'osd_list': PREF_LANG_GB,
    'agelock_list': GB_AR_LIST,
    'audio_list': LANG_GB,
    'sub_list': LANG_GB,
    'audio_default': AUDIO_DEFAULT_GB,
    'osd_default': OSD_DEFAULT_GB,
    'skip_screens': ["languageSelection", "network"],
    'personal_suggestions': False
}


# pylint: disable=too-many-public-methods
class AppServicesImpl(object):
    """
    Methods related with sending requests to app services.
    """
    # read only keys from "cpe" section
    NON_CONFIGURABLE_KEYS = ['generatedId', 'id', 'modelName', 'hwVersion',
                             'serialNumber', 'chipid', 'buildVersion',
                             'asVersion', 'appVersion', 'firmwareVersion',
                             'imageName', 'caProject', 'caCakVersion',
                             'caPrmVersion', 'caSerialNumber', 'caNUID',
                             'caChipsetType', 'caChipsetRev',
                             'caParingSaId', 'caCscMaxIndex',
                             'productClass', 'ssdpUuid', 'oui', 'netflixEsn',
                             'ethernetMacAddress', 'wirelessMacAddress',
                             'userAgentExtension']

    _timeout = 10

    def __init__(self, application_service_handler=AppServicesRequestHandler()):
        """
        Constructor, Initialization of application service handler
        :param application_service_handler: Application service handler object
        """
        self.as_handler = application_service_handler

    def _settings_get_request(self, ip_address, cpe_id, url, xap):
        """
        Send get request for given url to CPE
        """
        return self.as_handler.get(ip_address, cpe_id, url, xap=xap,
                                   timeout=self._timeout)

    @staticmethod
    def _get_event_duration(start_time, end_time):
        """
        Get event duration from the specified start/end times
        """
        event_duration = end_time - start_time
        event_duration = str(event_duration)
        if event_duration.find(',') != -1 or event_duration.find('-1') != -1:
            event_duration = event_duration.split(',')[1].strip()
        return event_duration

    def _settings_put_request(self, ip_address, cpe_id, url, body=None,
                              xap=True, raw=False):
        """
        Send put request for given url to CPE
        """
        headers = {'Content-type': 'application/json', 'Accept': 'text/plain'}
        return self.as_handler.put(ip_address, cpe_id, url, body, headers,
                                   xap=xap, raw=raw, timeout=self._timeout)

    def get_application_service_setting_via_as(self, ip_address, cpe_id,
                                               key, xap=True):
        """
        Get a setting of stb via application service.
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param key: One of the keys
        :param xap: Is xap request
        :return: Actual value
        """
        return self._settings_get_request(
            ip_address, cpe_id, 'http://127.0.0.1:10014/settings/'
                                'getSetting/{0}'.format(key), xap=xap)

    def get_application_service_configuration_via_as(self, ip_address,
                                                     cpe_id, key, xap=True):
        """
        Get a configuration of stb via application service.
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param key: One of the keys from self.configuration dict
        :param xap: Is xap request
        :return: Actual value
        """
        return self._settings_get_request(
            ip_address, cpe_id, 'http://127.0.0.1:10014/configuration/'
                                'getConfig/{0}'.format(key), xap=xap)

    def reset_application_services_setting_via_as(self, ip_address,
                                                  cpe_id, key, xap=True):
        """
        Send reset profile request with given param.
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param key: One of the keys
        :param xap: Is xap request
        """
        self._settings_put_request(
            ip_address, cpe_id, 'http://127.0.0.1:10014/settings'
                                '/resetSetting/{0}'.format(key), xap=xap)

    def set_application_services_setting_via_as(self, ip_address, cpe_id,
                                                key, value, xap=True,
                                                raw=False):
        """
        Set a new value via application service.
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param key: One of the keys
        :param value: an object
        :param xap: Is xap request
        :param raw: value is a raw JSON string
        """
        self._settings_put_request(
            ip_address, cpe_id,
            'http://127.0.0.1:10014/settings/setSetting/{0}'
            .format(key), value, xap=xap, raw=raw)

    @staticmethod
    def _get_country_defaults(country_code):
        country_defaults = dict()
        country_defaults['code'] = country_code
        country_defaults['agelock_default'] = AGELOCK_DEFAULT
        if country_code == 'be':
            country_defaults = COUNTRY_BE_DEFAULTS
        elif country_code == 'nl':
            country_defaults = COUNTRY_NL_DEFAULTS
        elif country_code == 'ch':
            country_defaults = COUNTRY_CH_DEFAULTS
        elif country_code == 'cl':
            country_defaults = COUNTRY_CL_DEFAULTS
        elif country_code == 'gb':
            country_defaults = COUNTRY_GB_DEFAULTS
        else:
            raise NotImplementedError(
                'Country code \'{0}\' not yet implemented '
                'in test library'.format(country_code))
        return country_defaults

    def get_country_code_from_stb_via_as(self, ip_address, cpe_id, xap=True):
        """
        Get country code from stb
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        :return: Country code
        """
        response = self._settings_get_request(
            ip_address, cpe_id, 'http://127.0.0.1:10014/'
                                'configuration/getConfig', xap=xap)
        return response['cpe']['country']

    def get_configuration_via_as(self, ip_address, cpe_id, xap=True):
        """
        Get country code from stb
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        :return: STB configuration
        """
        response = self._settings_get_request(
            ip_address, cpe_id, 'http://127.0.0.1:10014/configuration'
                                '/getConfig', xap=xap)
        return response

    def get_paired_devices_from_stb_via_as(self, ip_address, cpe_id, xap=True):
        """
        Get paired devices details from stb
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        :return: paired devices json data
        """
        response = self._settings_get_request(
            ip_address, cpe_id, 'http://127.0.0.1:10014/settings/getSetting/'
            'cpe.quicksetPairedDevicesInfo', xap=xap)
        return response

    def set_dummy_paired_status_to_paired_devices(self, ip_address, cpe_id,
                                                  is_paired=True,
                                                  xap=True):
        """
        Set dummy paired status on stb.
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param is_paired: Boolean to be set to "tv" and "amp" elements
        :param xap: Is xap request
        :return: None
        """
        result = False
        paired_body = self.get_paired_devices_from_stb_via_as(
            ip_address, cpe_id, xap=xap)

        if paired_body is not None:
            if paired_body['tv']['isPaired'] == paired_body['amp']['isPaired']\
               and is_paired == paired_body['tv']['isPaired']:
                result = True

            paired_body['tv']['isPaired'] = is_paired
            paired_body['amp']['isPaired'] = is_paired
            self._settings_put_request(
                ip_address, cpe_id,
                'http://127.0.0.1:10014/settings/setSetting/'
                'cpe.quicksetPairedDevicesInfo', paired_body, xap=xap)
        return result

    def set_country_code_via_as(self, ip_address, cpe_id, country_code,
                                xap=True):
        """
        Set country code on stb.
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param country_code: Country code to set
        :param xap: Is xap request
        """
        config_body = self._settings_get_request(
            ip_address, cpe_id, 'http://127.0.0.1:10014/configuration/'
                                'getConfig', xap=xap)

        for element in self.NON_CONFIGURABLE_KEYS:
            if element in config_body['cpe']:
                del config_body['cpe'][element]

        country_defaults = self._get_country_defaults(country_code)
        config_body['cpe']['country'] = country_code
        config_body['cpe']['timezone'] = country_defaults['time_zone']
        config_body['app']['preferredLanguages'] = \
            country_defaults['pref_list']
        config_body['settings']['profile.osdLang']['default'] = \
            country_defaults['osd_default']
        config_body['settings']['profile.osdLang']['enum'] = \
            country_defaults['osd_list']
        config_body['settings']['profile.ageLock']['enum'] = \
            country_defaults['agelock_list']
        config_body['settings']['profile.ageLock']['default'] = \
            country_defaults['agelock_default']
        config_body['settings']['profile.audioLang']['enum'] = \
            country_defaults['audio_list']
        config_body['settings']['profile.audioLang']['default'] = \
            country_defaults['audio_default']
        config_body['settings']['profile.subLang']['enum'] = \
            country_defaults['sub_list']
        config_body['settings']['profile.subLang']['default'] = \
            country_defaults['audio_default']
        config_body['ftiApp']['screensToSkip'] = \
            country_defaults['skip_screens']
        config_body['settings']['customer.personalSuggestions']['default'] = \
            country_defaults['personal_suggestions']
        self._settings_put_request(ip_address, cpe_id,
                                   'http://127.0.0.1:10014/configuration/'
                                   'setConfiguration', config_body, xap=xap)
        self.validate_applied_country_settings(ip_address, cpe_id,
                                               country_code,
                                               is_default=True,
                                               xap=xap)

    # pylint: disable=too-many-locals,too-many-branches,too-many-statements,
    # pylint: disable=too-many-arguments
    def validate_applied_country_settings(self, ip_address, cpe_id,
                                          country_code, is_default=True,
                                          xap=True):
        """
        Validate applied country settings, according to default values.
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param country_code: Country code to set
        :param xap: Is xap request
        """
        country_defaults = self._get_country_defaults(country_code)
        prefs_default = country_defaults['pref_list']

        config_body = self._settings_get_request(
            ip_address, cpe_id, 'http://127.0.0.1:10014/'
                                'configuration/getConfig', xap=xap)
        cpe_country_code = config_body['cpe']['country']
        cpe_timezone = config_body['cpe']['timezone']
        cpe_osddefault = config_body['settings']['profile.osdLang']['default']
        cpe_lang_def = config_body['settings']['profile.audioLang']['default']
        cpe_preflang = config_body['app']['preferredLanguages']
        cpe_osd_enum = config_body['settings']['profile.osdLang']['enum']
        cpe_age_enum = config_body['settings']['profile.ageLock']['enum']
        cpe_audio_enum = config_body['settings']['profile.audioLang']['enum']
        cpe_sublang_enum = config_body['settings']['profile.subLang']['enum']
        cpe_sublang_def = config_body['settings']['profile.subLang']['default']
        cpe_skip_screens = config_body['ftiApp']['screensToSkip']
        cpe_psdefault = \
            config_body['settings']['customer.personalSuggestions']['default']
        if cpe_country_code != country_code:
            raise ValueError('country_code \'{}\' is not \'{}\'.'
                             .format(cpe_country_code, country_code))
        if cpe_timezone != country_defaults['time_zone']:
            raise ValueError('timezone \'{}\' is not \'{}\'.'
                             .format(cpe_timezone,
                                     country_defaults['time_zone']))
        if cpe_osddefault != country_defaults['osd_default']:
            raise ValueError('profile.osdLang default \'{}\' is not \'{}\'.'
                             .format(cpe_osddefault,
                                     country_defaults['osd_default']))
        if cpe_lang_def == '' and cpe_osddefault \
                != country_defaults['audio_default']:
            raise ValueError('profile.audioLang \'{}\' is not \'{}\'.'
                             .format(cpe_osddefault,
                                     country_defaults['audio_default']))
        if cpe_lang_def != '' and cpe_lang_def \
                not in prefs_default:
            raise ValueError('profile.audioLang \'{}\' is not in \'{}\'.'
                             .format(cpe_lang_def,
                                     prefs_default))
        if cpe_preflang[:len(prefs_default)] != prefs_default:
            raise ValueError('preferredLanguages \'{}\' is not \'{}\'.'
                             .format(cpe_preflang[:len(prefs_default)],
                                     prefs_default))
        if cpe_osd_enum != country_defaults['osd_list']:
            raise ValueError('profile.osdLang enum \'{}\' is not \'{}\'.'
                             .format(cpe_osd_enum,
                                     country_defaults['osd_list']))
        if cpe_age_enum != country_defaults['agelock_list']:
            raise ValueError('profile.ageLock enum \'{}\' is not \'{}\'.'
                             .format(cpe_age_enum,
                                     country_defaults['agelock_list']))
        lang_list = []
        for audio_lang in prefs_default:
            if audio_lang not in cpe_audio_enum:
                lang_list.append(audio_lang)
        if lang_list:
            raise ValueError(
                'profile.audioLang enum \'{}\' '
                'is missing the following \'{}\'.'
                .format(cpe_audio_enum, lang_list))
        sublang_list = []
        for audio_lang in prefs_default:
            if audio_lang not in cpe_sublang_enum:
                sublang_list.append(audio_lang)
        if sublang_list:
            raise ValueError(
                'profile.subLang enum \'{}\' is missing the following \'{}\'.'
                .format(cpe_sublang_enum, sublang_list))
        if is_default and cpe_sublang_def != country_defaults['audio_default']:
            raise ValueError('profile.subLang default \'{}\' is not \'{}\'.'
                             .format(cpe_sublang_def,
                                     country_defaults['audio_default']))
        if not is_default and cpe_sublang_def not in cpe_osd_enum:
            raise ValueError('profile.subLang default \'{}\' not in \'{}\'.'
                             .format(cpe_sublang_def, cpe_osd_enum))
        if cpe_skip_screens != country_defaults['skip_screens']:
            raise ValueError('ftiApp.screensToSkip \'{}\' is not \'{}\'.'
                             .format(cpe_skip_screens,
                                     country_defaults['skip_screens']))
        if cpe_psdefault != country_defaults['personal_suggestions']:
            raise \
                ValueError('customer.personalSuggestions default \'{}\' \
                           is not \'{}\'.'
                           .format(cpe_psdefault,
                                   country_defaults['personal_suggestions']))

    def reset_channels_via_as(self, ip_address, cpe_id, channel_type,
                              xap=True):
        """
        Reset channels list of current user
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param channel_type: Channel list type
            - favourites channels: FAVORITE
            - locked channels: LOCKED
            - user created list: USER
        :param xap: Is xap request
        """
        return self.set_channels_via_as(
            ip_address, cpe_id, channel_type, [], xap=xap)

    def set_channels_via_as(self, ip_address, cpe_id, channel_list_type,
                            channel_list, xap=True):
        """
        Set channels list of current user
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param channel_list_type: Channel list type, Supported values
            - favourites channels: FAVORITE
            - locked channels: LOCKED
            - user created list: USER
        :param channel_list: List of channels in string format
        :param xap: Is xap request
        """
        available_types = ['FAVORITE', 'LOCKED', 'USER']
        if channel_list_type not in available_types:
            raise ValueError('Channels Type \'{}\' is invalid.'
                             .format(channel_list_type))
        payload = [{'type': channel_list_type, 'name': '',
                    'channels': channel_list}]
        headers = {'Content-type': 'application/json',
                   'Accept': 'application/json'}
        return self.as_handler.put(
            ip_address, cpe_id, 'http://127.0.0.1:10014/channels/'
                                'setChannelLists', payload, headers, xap=xap,
            timeout=self._timeout)

    def reset_watchlist_via_as(self, ip_address, cpe_id, xap=True):
        """
        Reset watchlist.
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        """
        self.as_handler.delete(
            ip_address, cpe_id, 'http://127.0.0.1:8125/watchlist',
            {'Content-type': 'application/json', 'Accept': 'text/plain'},
            xap=xap, timeout=self._timeout)

    def reset_all_recordings_via_as(self, ip_address, cpe_id, xap=True):
        """
        Reset recorded list
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        """
        self.as_handler.put(
            ip_address, cpe_id, 'http://127.0.0.1:10014/recordings/'
                                'deleteAllRecordings',
            {'recordingsType': 'ALL'},
            {'content-type': 'application/json'},
            xap=xap, timeout=self._timeout)

    def delete_recordings_of_type_via_as(
            self, ip_address, cpe_id, recordings_type='ALL', xap=True):
        """
        Deletes recordings of the type specified.
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param recordings_type: The type of recordings to delete. Default='ALL'
        :param xap: Is xap request
        """
        self.as_handler.put(
            ip_address, cpe_id, 'http://127.0.0.1:10014/recordings/'
                                'deleteAllRecordings',
            {'recordingsType': recordings_type},
            {'content-type': 'application/json'},
            xap=xap, timeout=self._timeout)

    def delete_recording_via_as(self, ip_address, cpe_id, recording_id,
                                xap=True):
        """
        Delete saved recording from STB via application service
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param recording_id: Recording ID
        :param xap: Is xap request
        """
        self.as_handler.put(
            ip_address, cpe_id, 'http://127.0.0.1:10014/recordings/'
                                'deleteRecording',
            {'recordingId': recording_id},
            {'Content-Type': 'application/json'},
            xap=xap, timeout=self._timeout)

    def cancel_recording_via_as(self, ip_address, cpe_id, recording_id,
                                manual_conflict_resolution,
                                xap=True):
        """
        Cancel a recording
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param recording_id: Recording ID
        :param manual_conflict_resolution: true when cancel action
            is a result of manual conflict resolution
        :param xap: Is xap request
        """
        self.as_handler.put(
            ip_address, cpe_id, 'http://127.0.0.1:10014/recordings/'
                                'cancelRecording',
            {'recordingId': recording_id,
             'manualConflictResolution': manual_conflict_resolution},
            {'Content-Type': 'application/json'},
            xap=xap, timeout=self._timeout)

    def get_current_channel_via_as(self, ip_address, cpe_id, xap=True):
        """
        Get current tuned channel
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        """
        return self.as_handler.put(
            ip_address, cpe_id, 'http://localhost:10014/channels/'
                                'getCurrentChannel', None,
            {'content-type': 'application/json'},
            xap=xap, timeout=self._timeout)

    def get_application_services_utilities_via_as(self, ip_address,
                                                  cpe_id, key, xap=True):
        """
        Get application service utility status
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param key: One of the keys
        :param xap: Is xap request
        :return:
        """
        return self._settings_get_request(
            ip_address, cpe_id,
            'http://127.0.0.1:10014/utilities/{0}'.format(key), xap=xap)

    def get_power_state_from_stb_via_as(self, ip_address, cpe_id, xap=True):
        """
        Get current power state and state change reason
        of STB using App service
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        :return: Current power state with change reason
        """
        response = self._settings_get_request(
            ip_address, cpe_id, 'http://127.0.0.1:10014/power-manager/'
                                'getPowerState', xap=xap)
        return response

    def get_current_power_state_from_stb_via_as(self, ip_address, cpe_id,
                                                xap=True):
        """
        Get power current state of STB using App service
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        :return: Current power state
        """
        response = self.get_power_state_from_stb_via_as(ip_address, cpe_id,
                                                        xap=xap)
        return response['currentState']

    def _request_as_powermanagement(self, ip_address, cpe_id, standby_state,
                                    xap=True):
        """
        Post Request to Application Services for power management
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        :return:
        """
        url = 'http://127.0.0.1:10014/power-manager/setPowerState'
        body = {'state': standby_state}
        return self.as_handler.post(
            ip_address, cpe_id, url, body,
            headers={'Content-type': 'application/json'}, xap=xap,
            timeout=self._timeout)

    def cpe_to_standby_as_via_as(self, ip_address, cpe_id, xap=True):
        """
        send request to go to ActiveStandby via Application Services
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        """
        response = self._request_as_powermanagement(ip_address, cpe_id,
                                                    'ActiveStandby', xap=xap)
        if response.strip("\"") == 'OperationSuccessful':
            return True
        return False

    def cpe_out_of_standby_as_via_as(self, ip_address, cpe_id, xap=True):
        """
        send request to go to Operational mode via Application Services
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        """
        response = self._request_as_powermanagement(ip_address, cpe_id,
                                                    'Operational', xap=xap)
        if response.strip("\"") == 'OperationSuccessful':
            return True
        return False

    def _get_channels(self, ip_address, cpe_id, xap=True):
        """
        Send request for get channel list.
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        :return channel list json
        """
        url = 'http://127.0.0.1:10014/channels/getChannels'
        headers = {'Content-type': 'application/json', 'Accept': 'text/plain'}
        return self.as_handler.put(ip_address, cpe_id, url, None,
                                   headers, xap=xap, timeout=self._timeout)

    def get_channel_lineup_via_as(self, ip_address, cpe_id, xap=True):
        """
        Get channels dict {channelNumber: channelId, ...}
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        """
        response_json = self._get_channels(ip_address, cpe_id, xap=xap)
        channels_dict = dict()

        for channel in response_json:
            channels_dict[channel['channelNumber']] = channel['channelId']

        return channels_dict

    def get_locator_for_channel_number_via_as(self, ip_address, cpe_id,
                                              channel_number, xap=True):
        """
        Get locator for given channel number
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param channel_number: channelNumber field
        :param xap: Is xap request
        :return: locator
        """
        response_json = self._get_channels(ip_address, cpe_id, xap=xap)

        for channel in response_json:
            if channel['channelNumber'] == int(channel_number):
                return channel['locator']

        raise ValueError('Can not find channel number {0} in the channel list'
                         .format(channel_number))

    def get_vod_rentals_via_as(self, ip_address, cpe_id, xap=True):
        """
        Get the VOD asset purchase details via application service
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        :return: rental_assets
        """
        assets = self.as_handler.get(
            ip_address, cpe_id, 'http://127.0.0.1:10014/'
                                'entitlements/getRentals',
            xap=xap, timeout=self._timeout)
        asset_list = []
        for asset in assets:
            asset_list.append(asset['id'])
        return asset_list

    def _get_channel_lists_by_type(self, ip_address, cpe_id, xap=True):
        """
        Sends put request to get channel lists for type favourites and locked.
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :return channel lists json
        """
        url = 'http://127.0.0.1:10014/channels/getChannelLists'
        headers = {'Content-type': 'application/json', 'Accept': 'text/plain'}
        return self.as_handler.put(ip_address, cpe_id, url, None, headers,
                                   xap=xap, timeout=self._timeout)

    def get_channel_list_by_type_via_as(self, ip_address, cpe_id,
                                        ch_type='FAVORITE', xap=True):
        """
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param ch_type: type of channel (FAVOURITE/LOCKED)
        :param xap: Is xap request
        :return ch_id_list: channels list for type
        """
        response_json = self._get_channel_lists_by_type(ip_address, cpe_id,
                                                        xap=xap)
        ch_id_list = []
        for channel in response_json:
            if channel['type'] == ch_type:
                channel_list = channel['channels']
                for ch in channel_list:
                    ch_id_list.append(ch['channelId'])
        return ch_id_list

    @staticmethod
    def filter_the_channel_list(
            channel_list, channel_id=None, name=None,
            channel_number=None, is_radio=None, is_adult=None,
            is_3d=None, resolution=None, is_entitled=None,
            allow_start_over=None, allow_replay_tv=None):
        """
        Filter the channel list based  on the parameters
        :param channel_list: Input channel list
        :param channel_id: Filter value - channel ID
        :param name: Filter value - channel name
        :param channel_number: Filter value - channel number
        :param is_radio: Filter value - is radio, Boolean
        :param is_adult: Filter value - channel adult, Boolean
        :param is_3d: Filter value - is channel 3D, Boolean
        :param resolution: Filter value - channel resolution
        :param is_entitled: Filter value - is entitled, Boolean
        :param allow_start_over: Filter value - allow start over, Boolean
        :param allow_replay_tv: Filter value - allow reply tv, Boolean
        :return: List of filtered channels based on the filter values
        """
        filtered_channels = list()
        for channel in channel_list:
            if channel_id is not None and \
                    channel['channelId'] != channel_id:
                continue
            if name is not None and channel['name'] != name:
                continue
            if channel_number is not None and \
                    channel['channelNumber'] != channel_number:
                continue
            if 'isRadio' in channel:
                if is_radio is not None and channel['isRadio'] != is_radio:
                    continue
            if is_adult is not None and channel['isAdult'] != is_adult:
                continue
            if is_3d is not None and channel['is3D'] != is_3d:
                continue
            if resolution is not None and \
                    channel['resolution'] != resolution:
                continue
            if is_entitled is not None and \
                    channel['isEntitled'] != is_entitled:
                continue
            if allow_start_over is not None and \
                    channel['allowStartOver'] != allow_start_over:
                continue
            if allow_replay_tv is not None and \
                    channel['allowReplayTV'] != allow_replay_tv:
                continue
            filtered_channels.append(channel)

        return filtered_channels

    def get_all_good_entitled_linear_channel_id_list_via_as(
            self, ip_address, cpe_id, xap=True):
        """
        Get all the good entitled linear channel list via as
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        :return: List of good entitled linear channel id list
        """
        good_channel_ids = list()
        channel_list = self._get_channels(ip_address, cpe_id, xap=xap)
        entitled_linear_channels = self.filter_the_channel_list(
            channel_list, is_radio=False, is_entitled=True)
        non_consistent_channel_numbers = get_non_consistent_channel_numbers()
        for channel in entitled_linear_channels:
            if channel['channelNumber'] in non_consistent_channel_numbers:
                continue
            good_channel_ids.append(
                {'channelId': str(channel['channelId'])})

        return good_channel_ids

    def create_event_record_via_as(
            self, ip_address, cpe_id, channel_id, event_id, event_start_time,
            xap=True):
        """
        Create event based record on STB via xap
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param channel_id: Channel ID
        :param event_id: Event ID
        :param event_start_time: Event start time in epoch, datetime object
        :param xap: Is xap request
        :return: Recording ID on success, False on failure
        """
        event_start_time = int(event_start_time)
        payload = {'eventId': event_id,
                   'channelId': str(channel_id),
                   'startTime': str(event_start_time)}
        headers = {'Content-type': 'application/json',
                   'Accept': 'application/json'}
        json_response = self.as_handler.put(
            ip_address, cpe_id, 'http://127.0.0.1:10014/recordings/'
                                'createEventRecording',
            payload, headers, xap, timeout=self._timeout)
        if 'recordingId' in json_response:
            recording_id = str(json_response['recordingId'])
        else:
            recording_id = 'null'
            # raise KeyError(
            #     'Not able to get the recording ID from the response')

        return recording_id

    def get_recording_session_using_session_service_via_as(
            self, ip_address, cpe_id, customer_id, recording_id, xap=True):
        """
        Open a session for a recording using session service via xap
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param customer_id: Customer id
        :param recording_id: Recording ID of the recording
        :param xap: Is xap request
        :return:
        """
        url = 'http://127.0.0.1:81/common-service/session-service/' + \
              'session/customers/' + customer_id + '/recordings/' + \
              recording_id
        headers = {'Content-type': 'application/json',
                   'Accept': 'application/json',
                   'User-Agent': 'ONEMW Automation team'}
        body = {}
        json_response = self.as_handler.post(
            ip_address, cpe_id, url, body, headers, xap, timeout=self._timeout)
        if isinstance(json_response, dict) and 'url' in json_response:
            recording_url = str(json_response['url'])
        else:
            raise KeyError(
                'Unable to open session of given recording id')

        return recording_url

    def get_ldvr_recording_playback_locator_via_as(
            self, ip_address, cpe_id, customer_id, recording_id, xap=True):
        """
        Gets playback location for a local recording
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param customer_id: Customer id
        :param recording_id: Recording ID of the recording
        :param cpe_id: STB ID
        :param xap: Is xap request
        :return: playback locator for the recording
        """
        url = 'http://127.0.0.1:10014/recordings/getRecording'
        headers = {'Content-type': 'application/json',
                   'Accept': 'application/json',
                   'X-Cus': customer_id,
                   'X-Dev': cpe_id}
        body = {'recordingId': recording_id}
        json_response = self.as_handler.post(
            ip_address, cpe_id, url, body, headers, xap, timeout=self._timeout)
        if isinstance(json_response, dict) and \
                'playbackLocator' in json_response:
            playback_locator = str(json_response['playbackLocator'])
        else:
            raise KeyError(
                'Unable to get playback locator for recording id')
        return playback_locator

    def get_channel_id_via_as(self, ip_address, cpe_id, channel_number,
                              xap=True):
        """
        Get channel id via xap
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param channel_number: Channel number
        :param xap: Is xap request
        :return: Channel ID
        """
        response_json = self._get_channels(ip_address, cpe_id, xap)

        for channel in response_json:
            if channel['channelNumber'] == int(channel_number):
                return channel['channelId']

        raise ValueError('Can not find channel number {0} in the channel list'
                         .format(channel_number))

    def get_recording_collection_via_as(self, ip_address, cpe_id, xap=True):
        """
        Get recordings in the box
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        :return: Recording collection object
        """
        return self.as_handler.post(
            ip_address, cpe_id, 'http://127.0.0.1:10014/recordings/'
                                'getCollection',
            headers={'Accept': 'application/json'}, xap=xap,
            timeout=self._timeout)

    def get_remaining_pin_attempts_via_as(self, ip_address, cpe_id,
                                          pin_type='master', xap=True):
        """
        Gets the PIN entry attempts remaining
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param pin_type: Type of the pin to check.
        Possible types are 'master', 'adult', and 'profile'
        Defaults to 'master'.
        :param xap: Is xap request
        :return: number of attempts left
        """
        headers = {'Content-type': 'application/json',
                   'Accept': 'application/json'}
        if pin_type not in ['master', 'adult', 'profile']:
            raise ValueError(
                'Wrong type of PIN: {0} not a valid type'.format(pin_type))
        data = {'pinType': pin_type}
        attempts_left = self.as_handler.put(
            ip_address, cpe_id, 'http://127.0.0.1:10014/auth/'
                                'getRemainingAttempts',
            data, headers, xap, timeout=self._timeout)
        return attempts_left['count']

    def get_pin_suspension_timeout_via_as(self, ip_address, cpe_id, xap=True):
        """
        Gets the value of the pin suspension timeout
        setting from the STB
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        :return: current pin suspension timeout value
        """
        config_body = self._settings_get_request(
            ip_address, cpe_id, 'http://127.0.0.1:10014/configuration/'
                                'getConfig', xap=xap)
        current_timeout = \
            config_body['appservices']['auth']['pinSuspensionTimeout']
        return current_timeout

    def set_pin_suspension_timeout_via_as(self, ip_address, cpe_id, timeout,
                                          xap=True):
        """
        Set the pin suspension timeout value on the STB.
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param timeout: Suspension timeout in seconds
        :param xap: Is xap request
        :return: new pin suspension timeout value
        """
        headers = {'Content-type': 'application/json',
                   'Accept': 'application/json'}
        data = {'appservices.auth.pinSuspensionTimeout': timeout}
        updated_config = self.as_handler.put(
            ip_address, cpe_id, 'http://127.0.0.1:10014/configuration/'
                                'updateConfiguration',
            data, headers, xap, timeout=self._timeout)
        updated_timeout = \
            updated_config['appservices']['auth']['pinSuspensionTimeout']
        if updated_timeout != timeout:
            raise ValueError('pinSuspensionTimeout setting was not updated')
        return updated_timeout

    def set_watershed_periods_via_as(
            self, ip_address, cpe_id, watershed_periods, xap=True):
        """
        Set the pin suspension timeout value on the STB.
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param watershed_periods: Watershed values
        :param xap: Is xap request
        :return: new pin suspension timeout value
        """
        watershed_periods = watershed_periods if watershed_periods else None
        headers = {'Content-type': 'application/json',
                   'Accept': 'application/json'}
        data = {'app.watershedPeriods': watershed_periods}
        updated_config = self.as_handler.put(
            ip_address, cpe_id, 'http://127.0.0.1:10014/configuration/'
                                'updateConfiguration',
            data, headers, xap, timeout=self._timeout)
        updated_watershed_periods = \
            updated_config['app']['watershedPeriods']
        if updated_watershed_periods != watershed_periods:
            raise ValueError('watershedPeriods setting was not updated')
        return updated_watershed_periods
    def get_profiles_list_via_as(self, ip_address, cpe_id, xap=True):
        """
        Gets the profiles list via AS
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        :return: Array of currently existing profiles
        """
        headers = {'Content-type': 'application/json',
                   'Accept': 'application/json'}
        profiles = self.as_handler.put(
            ip_address, cpe_id, 'http://127.0.0.1:10014/auth/getProfilesList',
            None, headers, xap, timeout=self._timeout)
        return profiles

    def _get_current_profile_via_as(self, ip_address, cpe_id, xap=True):
        """
        Gets the current active profile details via AS
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        :return: Dictionary with the current active profile details
        """
        headers = {'Content-type': 'application/json',
                   'Accept': 'application/json'}
        current_profile = self.as_handler.put(
            ip_address, cpe_id, 'http://127.0.0.1:10014/auth/'
                                'getCurrentProfile',
            None, headers, xap, timeout=self._timeout)
        return current_profile

    def get_current_profile_id_via_as(self, ip_address, cpe_id, xap=True):
        """
        Gets the current active profile id via AS
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        :return: Value of current active profile id
        """
        current_profile = self._get_current_profile_via_as(ip_address,
                                                           cpe_id, xap)
        if not current_profile['id']:
            raise ValueError('Failed to get the current profile id')
        return current_profile['id']

    def get_current_profile_name_via_as(self, ip_address, cpe_id, xap=True):
        """
        Gets the current active profile name via AS
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        :return: Name of current active profile
        """
        current_profile = self._get_current_profile_via_as(ip_address,
                                                           cpe_id, xap)
        if not current_profile['name']:
            raise ValueError('Failed to get the current profile name')
        return current_profile['name']

    def reset_profiles_via_as(self, ip_address, cpe_id, xap=True):
        """
        Deletes all custom profiles via AS
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        """
        headers = {'Content-type': 'application/json',
                   'Accept': 'application/json'}
        profiles = self.get_profiles_list_via_as(ip_address, cpe_id, xap)
        for profile in profiles:
            if not profile['isShared']:
                self.as_handler.post(
                    ip_address, cpe_id, 'http://127.0.0.1:10014/auth/'
                                        'removeProfile',
                    profile['id'], headers, xap, timeout=self._timeout)

    def add_profile_via_as(self, ip_address, cpe_id, profile_name,
                           profile_color, profile_channels=None, xap=True):
        """
        Adds a profile via AS
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param profile_name: Name of the new profile
        :param profile_color: Color of the new profile.
        :param profile_channels: Array of channelId strings
        of the personal lineup for the profile.
        :param xap: Is xap request
        :return: Profile ID of the newly created profile
        """
        if profile_channels:
            if len(profile_channels) < 3:
                raise ValueError('Personal channel line-ups' +
                                 ' need at least 3 channels')
        data = {'name': profile_name, 'color': profile_color,
                'favoriteChannels': profile_channels}
        headers = {'Content-type': 'application/json',
                   'Accept': 'application/json'}
        profile_id = self.as_handler.post(
            ip_address, cpe_id, 'http://127.0.0.1:10014/auth/addProfile',
            data, headers, xap, timeout=self._timeout)
        return profile_id

    def get_recordings_filter_status_via_as(
            self, ip_address, cpe_id, status_list, xap=True):
        """
        Fetches all recording data for recordings that
        match filter: status
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param status_list: The list of statuses to check
        1 status or multiple statuses can be checked
        See this link for valid values:
        https://wikiprojects.upc.biz/display/CTOM/recording+manager
        :param xap: Is xap request
        :return: list of recording records
        """
        url = 'http://127.0.0.1:10014/recordings/getRecordings'
        headers = {'Content-type': 'application/json'}
        body = {'status': status_list}
        recordings = self.as_handler.post(
            ip_address, cpe_id, url, body, headers, xap, timeout=self._timeout)
        return recordings['recordingRecords']

    def get_recordings_quota_via_as(
            self, ip_address, cpe_id, xap=True):
        """
        Fetches quota for recordings
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        https://wikiprojects.upc.biz/display/CTOM/recording+manager
        :param xap: Is xap request
        :return: percentage recording gquota for the customer
        """
        url = 'http://127.0.0.1:10014/recordings/getRecordings'
        headers = {'Content-type': 'application/json'}
        body = {}
        recordings = self.as_handler.post(
            ip_address, cpe_id, url, body, headers, xap, timeout=self._timeout)
        return recordings['quota']['occupationPercentage']

    def get_current_event_via_as(
            self, ip_address, cpe_id, channel_id, current_time, xap=True):
        """
        get the current event id,start time end time, event duration
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param channel_id: Channel id
        :param current_time: current time in seconds from epoch
        :param xap: xap True or False value
        :return: 4 element array with [eventid , start time , end time,
         event duration]
        """
        url = 'http://127.0.0.1:10014/epg/getEPGEvents'
        headers = {'Content-type': 'application/json',
                   'Accept': 'application/json'}
        body = {'startTime': current_time, 'endTime': current_time,
                'channelIds': [channel_id]}
        event_response = self.as_handler.put(
            ip_address, cpe_id, url, body, headers, xap=xap,
            timeout=self._timeout)
        try:
            event_node = event_response[0]['events'][0]
            event_duration = self._get_event_duration(
                event_node['startTime'], event_node['endTime'])
            current_event = [event_node['eventId'], event_node['startTime'],
                             event_node['endTime'], event_duration]
            if 'seriesId' in event_node:
                BuiltIn().set_suite_variable("${CURRENT_SERIES_ID}", event_node['seriesId'])
        except Exception as err:
            BuiltIn().log("Exception message: %s - Ignoring and continue" % err.args[0])
            current_event = []
        return current_event

    def get_channel_events_via_as(
            self, ip_address, cpe_id, channel_id, start_time,
            events_before, events_after, xap=True):
        """
        Get the events  for a given channel at a given time with a specified
        number of events around it (before and after).
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param channel_id: the Channel Id we want the events from
        :param start_time: time in seconds from the epoch to start getting
        events from
        :param events_before: how many events to get before the start time
        :param events_after:  how many events to get after the start time
        :param xap: is XAP request
        :return: list of events around the start time for the given channel
        """
        url = 'http://127.0.0.1:10014/epg/getEPGEventsAround'
        headers = {'Content-type': 'application/json',
                   'Accept': 'application/json'}
        body = {'startTime': start_time,
                'numberOfEventsBefore': int(events_before),
                'numberOfEventsAfter': int(events_after),
                'channelId': channel_id}
        events_response = self.as_handler.put(
            ip_address, cpe_id, url, body, headers, xap=xap,
            timeout=self._timeout)
        channel_events = list(events_response['eventsBefore'])
        channel_events.append(events_response['event'])
        channel_events.extend(events_response['eventsAfter'])
        return channel_events

    def set_current_profile_via_as(
            self, ip_address, cpe_id, profile_id, xap=True):
        """
        set a profile as active profile via AS
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param profile_id: id of the profile
        :param xap: is XAP request
        """
        headers = {'Content-type': 'application/json',
                   'Accept': 'application/json'}
        self.as_handler.post(ip_address, cpe_id,
                             'http://127.0.0.1:10014/auth/setCurrentProfile',
                             profile_id, headers, xap=xap)

    def update_cpe_configuration_via_as(self, ip_address, cpe_id,
                                        overrides, xap=True, raw=False):
        """
        Updates current CPE configuration file with
        the specified overrides JSON object.
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param overrides: key-value pair object to override
        the current CPE configuration
        :param xap: Is xap request
        :param raw: value is a raw JSON string
        """
        if not raw:
            overrides = json.dumps(overrides)
        url = 'http://127.0.0.1:10014/configuration/updateConfiguration'
        headers = {'Content-type': 'application/json',
                   'Accept': 'application/json'}
        self.as_handler.put(ip_address, cpe_id, url,
                            overrides, headers, xap=xap,
                            raw=raw, timeout=self._timeout)

class AppServices(AppServicesImpl):
    """
    Provides keywords for Application Services
    """

    def __init__(self, as_handler=AppServicesRequestHandler()):
        """
        Constructor
        """
        AppServicesImpl.__init__(self, as_handler)

    def get_subtitles_control_via_as(self, ip_address, cpe_id, xap=True):
        """
        Get subtitles control value from settings.
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        :return: Actual value
        """
        return self.get_application_service_setting_via_as(
            ip_address, cpe_id, 'profile.subControl', xap=xap)

    def get_fti_state_via_as(self, ip_address, cpe_id, xap=True):
        """
        Get fti status from settings.
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        :return: Actual state
        """
        return self.get_application_service_setting_via_as(
            ip_address, cpe_id, 'cpe.ftiState', xap=xap)

    def get_personalisation_status(self, ip_address, cpe_id, xap=True):
        """
        returns the status based on whether the personalisation feature
        is enabled for a customer or not
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param xap: Is xap request
        :return: status
        """
        return self.get_application_service_setting_via_as(
            ip_address, cpe_id, 'customer.personalSuggestions', xap=xap)
#************************************CPE PERFORMANCE*****************************************
    def get_recordings_quota_status_via_as(
            self, ip_address, cpe_id, xap=True):
        """
        Fetches recording quota usage
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :return: quota usage in percentage
        """
        body = {}
        url = 'http://localhost:10014/recordings/getStorageOccupation'
        headers = {'Content-type': 'application/json'}
        storage_info = self.as_handler.get(
            ip_address, cpe_id, url)
        return storage_info['volumes'][0]['occupationPercentage']

    def delete_series_recording_via_as(self, ip_address, cpe_id, series_id,
                                channel_id, xap=True):
        """
        Delete series recording from STB via application service
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param series_id: series ID
        :param channel_id: channel_id ID
        :param xap: Is xap request
        """
        self.as_handler.put(
            ip_address, cpe_id, 'http://127.0.0.1:10014/recordings/'
                                'deleteSeries',
            {'seriesId': series_id, 'channelId': channel_id},
            {'Content-Type': 'application/json'},
            xap=xap, timeout=self._timeout)
    def cancel_series_recording_via_as(self, ip_address, cpe_id, series_id,
                                channel_id, xap=True):
        """
        Cancel series recording from STB via application service
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param series_id: series ID
        :param channel_id: channel_id ID
        :param xap: Is xap request
        """
        self.as_handler.put(
            ip_address, cpe_id, 'http://127.0.0.1:10014/recordings/'
                                'cancelSeries',
            {'seriesId': series_id, 'channelId': channel_id},
            {'Content-Type': 'application/json'},
            xap=xap, timeout=self._timeout)
#******************************CPE PERFORMANCE*************************************************
    def create_series_record_via_as(
            self, ip_address, cpe_id, channel_id, series_id, event_id, event_start_time,
            xap=True):
        """
        Create event based record on STB via xap
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param channel_id: Channel ID
        :param series_id: Series ID
        :param event_id: Event ID
        :param event_start_time: Event start time in epoch, datetime object
        :param xap: Is xap request
        :return: Recording ID on success, False on failure
        """
        event_start_time = int(event_start_time)
        payload = {'eventId': event_id,
                   'channelId': str(channel_id),
                   'seriesId': str(series_id),
                   'startTime': event_start_time}
        headers = {'Content-type': 'application/json',
                   'Accept': 'application/json'}
        json_response = self.as_handler.put(
            ip_address, cpe_id, 'http://127.0.0.1:10014/recordings/createSeriesRecording',
                payload, headers, xap, timeout=self._timeout)
        if 'statusCode' not in json_response and 'recordingId' in json_response[0]:
            recording_id = str(json_response[0]['recordingId'])
        else:
            recording_id = 'null'
            # raise KeyError(
            #     'Not able to get the recording ID from the response')

        return recording_id


    def get_series_recording_info_via_as(
            self, ip_address, cpe_id, customer_id, channel_id, series_id, xap=True):
        """
        Gets series recording info
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param customer_id: Customer id
        :param series_id: Series ID of the recording
        :param cpe_id: STB ID
        :param xap: Is xap request
        :return: playback locator for the recording
        """
        url = 'http://127.0.0.1:10014/recordings/getSeries'
        headers = {'Content-type': 'application/json',
                   'Accept': 'application/json',
                   'X-Cus': customer_id,
                   'X-Dev': cpe_id}
        body = {'channelId': str(channel_id),
                   'seriesId': str(series_id),
                   'startTime': 0,
                   "isAdult": False,
                   "mostRelevantEpisodeType": "RECORDING"
                   }
        json_response = self.as_handler.post(
            ip_address, cpe_id, url, body, headers, xap, timeout=self._timeout)
        if isinstance(json_response, dict) and \
                'seriesTitle' in json_response:
            return json_response
        else:
            raise KeyError(
                'Unable to get series details' )

    def get_single_recording_info_via_as(
            self, ip_address, cpe_id, customer_id, recording_id, xap=True):
        """
        Gets playback location for a local recording
        :param ip_address: STB IP address
        :param cpe_id: STB ID
        :param customer_id: Customer id
        :param recording_id: Recording ID of the recording
        :param cpe_id: STB ID
        :param xap: Is xap request
        :return: recording info
        """
        url = 'http://127.0.0.1:10014/recordings/getRecording'
        headers = {'Content-type': 'application/json',
                   'Accept': 'application/json',
                   'X-Cus': customer_id,
                   'X-Dev': cpe_id}
        body = {'recordingId': recording_id}
        json_response = self.as_handler.post(
            ip_address, cpe_id, url, body, headers, xap, timeout=self._timeout)
        if isinstance(json_response, dict) and \
                'recordingId' in json_response:
            return json_response
        else:
            raise KeyError(
                'Unable to get recording info for recording id')