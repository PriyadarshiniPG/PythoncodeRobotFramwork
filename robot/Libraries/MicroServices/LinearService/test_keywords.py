# pylint: disable=W0632
# pylint: disable=W0212
# pylint: disable=W0613
# pylint: disable=R0904
"""Unit tests of of Linear Service Microservice tests for HZN 4.

Tests use mock module and do not send real requests to real Linear Service.
"""
import unittest
try:
    import mock
except ImportError:
    import unittest.mock as mock
from .LinearService import LinearService

CONF = {
    "MICROSERVICES": {
        "OBOQBR": "oboqbr.some_lab.nl.dmdsdp.com"
    }
}

MOCK_CHANNEL_REFERENCE = [
    {
        "id": "NL_000190_01",
        "name": "Film1 On Demand_1",
        "logicalChannelNumber": 1,
        "logo": {
            "focused": "https://staticqbr-nl-prod.prod.cdn.dmdsdp.com/image-service/"
                       "ImagesEPG/EventImages/film1_ondemand_1.png"
        },
        "locator": "tune://pgmno=24001&frequency=330000000&modulation=16&symbol_rate=6900",
        "resolution": "HD",
        "isRadio": "true"
    },
    {
        "id": "NL_000190_02",
        "name": "Film1 On Demand_2",
        "logicalChannelNumber": 2,
        "logo": {
            "focused": "https://staticqbr-nl-prod.prod.cdn.dmdsdp.com/image-service/"
                       "ImagesEPG/EventImages/film1_ondemand_2.png"
        },
        "resolution": "HD"
    },
    {
        "id": "NL_000190_03",
        "name": "Film1 On Demand_3",
        "logicalChannelNumber": 3,
        "logo": {
            "focused": "https://staticqbr-nl-prod.prod.cdn.dmdsdp.com/image-service/"
                       "ImagesEPG/EventImages/film1_ondemand_3.png"
        },
        "resolution": "HD"
    },
    {
        "id": "NL_000190_04",
        "name": "Film1 On Demand_4",
        "logicalChannelNumber": 4,
        "logo": {
            "focused": "https://staticqbr-nl-prod.prod.cdn.dmdsdp.com/image-service/"
                       "ImagesEPG/EventImages/film1_ondemand_4.png"
        },
        "resolution": "HD"
    }
]

MOCK_CHANNEL_LINE_UP_COUNT = [
    {
        "id": "NL_000190_01",
        "name": "Film1 On Demand_1",
        "logicalChannelNumber": 1,
        "logo": {
            "focused": "https://staticqbr-nl-prod.prod.cdn.dmdsdp.com/image-service/"
                       "ImagesEPG/EventImages/film1_ondemand_1.png"
        },
        "locator": "tune://pgmno=24001&frequency=330000000&modulation=16&symbol_rate=6900",
        "resolution": "HD",
        "isRadio": "true"
    },
    {
        "id": "NL_000190_02",
        "name": "Film1 On Demand_2",
        "logicalChannelNumber": 2,
        "logo": {
            "focused": "https://staticqbr-nl-prod.prod.cdn.dmdsdp.com/image-service/"
                       "ImagesEPG/EventImages/film1_ondemand_2.png"
        },
        "resolution": "HD"
    }
]

MOCK_CHANNEL_LINE_UP = [
    {
        "id": "NL_000190_01",
        "name": "Film1 On Demand_1",
        "logicalChannelNumber": 1,
        "logo": {
            "focused": "https://staticqbr-nl-prod.prod.cdn.dmdsdp.com/image-service/"
                       "ImagesEPG/EventImages/film1_ondemand_1.png"
        },
        "locator": "tune://pgmno=24001&frequency=330000000&modulation=16&symbol_rate=6900",
        "resolution": "HD",
        "isRadio": "true"
    },
    {
        "id": "NL_000190_02",
        "name": "Film1 On Demand_2",
        "logicalChannelNumber": 2,
        "logo": {
            "focused": "https://staticqbr-nl-prod.prod.cdn.dmdsdp.com/image-service/"
                       "ImagesEPG/EventImages/film1_ondemand_2.png"
        },
        "resolution": "HD"
    },
    {
        "id": "NL_000190_03",
        "name": "Film1 On Demand_3",
        "logicalChannelNumber": 3,
        "logo": {
            "focused": "https://staticqbr-nl-prod.prod.cdn.dmdsdp.com/image-service/"
                       "ImagesEPG/EventImages/film1_ondemand_3.png"
        },
        "resolution": "HD"
    },
    {
        "id": "NL_000190_04",
        "name": "Film1 On Demand_4",
        "logicalChannelNumber": 4,
        "logo": {
            "focused": "https://staticqbr-nl-prod.prod.cdn.dmdsdp.com/image-service/"
                       "ImagesEPG/EventImages/film1_ondemand_4.png"
        },
        "resolution": "HD"
    }
]

MOCK_IP_CHANNEL = [
    {
        "id": "NL_000190_01",
        "name": "Film1 On Demand_1",
        "logicalChannelNumber": 1,
        "logo": {
            "focused": "https://staticqbr-nl-prod.prod.cdn.dmdsdp.com/image-service/"
                       "ImagesEPG/EventImages/film1_ondemand_1.png"
        },
        "locator": "tune://pgmno=24001&frequency=330000000&modulation=16&symbol_rate=6900",
        "resolution": "HD",
        "isRadio": "true"
    }
]

MOCK_RANDOM_CHANNEL = [
    {
        "id": "NL_000190_01",
        "name": "Film1 On Demand_1",
        "logicalChannelNumber": 1,
        "logo": {
            "focused": "https://staticqbr-nl-prod.prod.cdn.dmdsdp.com/image-service/"
                       "ImagesEPG/EventImages/film1_ondemand_1.png"
        },
        "locator": "tune://pgmno=24001&frequency=330000000&modulation=16&symbol_rate=6900",
        "resolution": "HD",
        "isRadio": "true"
    }
]

MOCK_REMOVED_RADIO_CHANNEL_LINE_UP = [
    {
        "id": "NL_000190_02",
        "name": "Film1 On Demand_2",
        "logicalChannelNumber": 2,
        "logo": {
            "focused": "https://staticqbr-nl-prod.prod.cdn.dmdsdp.com/image-service/"
                       "ImagesEPG/EventImages/film1_ondemand_2.png"
        },
        "resolution": "HD"
    },
    {
        "id": "NL_000190_03",
        "name": "Film1 On Demand_3",
        "logicalChannelNumber": 3,
        "logo": {
            "focused": "https://staticqbr-nl-prod.prod.cdn.dmdsdp.com/image-service/"
                       "ImagesEPG/EventImages/film1_ondemand_3.png"
        },
        "resolution": "HD"
    },
    {
        "id": "NL_000190_04",
        "name": "Film1 On Demand_4",
        "logicalChannelNumber": 4,
        "logo": {
            "focused": "https://staticqbr-nl-prod.prod.cdn.dmdsdp.com/image-service/"
                       "ImagesEPG/EventImages/film1_ondemand_4.png"
        },
        "resolution": "HD"
    }
]

MOCK_EVENT_DETAILS = {
    "channels": [
        {
            "id": "NL_000190_02",
            "name": "Film1 On Demand_2",
            "logicalChannelNumber": 2,
            "logo": {
                "focused": "https://staticqbr-nl-prod.prod.cdn.dmdsdp.com/image-service/ImagesEPG/"
                           "EventImages/film1_ondemand_2.png"
            },
            "resolution": "HD"
        }
    ]
}

MOCK_CHANNEL_SUMMARY = {
    "id": "NL_000190_01",
    "name": "Film1 On Demand_1",
    "logicalChannelNumber": 1,
    "logo": {
        "focused": "https://staticqbr-nl-prod.prod.cdn.dmdsdp.com/image-service/"
                   "ImagesEPG/EventImages/film1_ondemand_1.png"
    },
    "locator": "tune://pgmno=24001&frequency=330000000&modulation=16&symbol_rate=6900",
    "resolution": "HD",
    "isRadio": "true"
}


def mock_requests_get(*args, **kwargs):
    """A Function to create a fake response depending on the unit test required"""

    path = args[0]
    if "channellineup" in path:
        response_data = dict(text=MOCK_CHANNEL_LINE_UP, status_code=200, reason="OK",
                             json=lambda x: MOCK_CHANNEL_LINE_UP)
    elif "eventdetails" in path:
        response_data = dict(text=MOCK_EVENT_DETAILS, status_code=200, reason="OK",
                             json=lambda x: MOCK_EVENT_DETAILS)
    elif "image-service" in path:
        response_data = dict(text="image_url_response", status_code=200, reason="OK",
                             json=lambda x: None)
    elif "randomchannel" in path:
        response_data = dict(text=MOCK_RANDOM_CHANNEL, status_code=200, reason="OK",
                             json=lambda x: MOCK_RANDOM_CHANNEL)
    elif "count" in path:
        response_data = dict(text=MOCK_CHANNEL_LINE_UP_COUNT, status_code=200, reason="OK",
                             json=lambda x: MOCK_CHANNEL_LINE_UP_COUNT)
    return type("", (), response_data)()


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_current_channel_lineup_via_ls(*args):
    """
    Function to mock the get_current_channel_lineup_via_ls function.

    :param args: arguments parsed from real function
    :return: mocked response
    """
    city_id, language, product_class = args[:-1]
    with mock.patch.object(LinearService, "__init__", lambda x: None):
        obj = LinearService()
        obj._linear_service_url = "mock_url"
        return obj.get_current_channel_lineup_via_ls(city_id, language, product_class)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_detail_of_linear_event(*args):
    """
    Function to mock the get_current_channel_lineup_via_ls function.

    :param args: arguments parsed from real function
    :return: mocked response
    """
    crid, language, return_linear_content = args[:-1]
    with mock.patch.object(LinearService, "__init__", lambda x: None):
        obj = LinearService()
        obj._linear_service_url = "mock_url"
        return obj.get_detail_of_linear_event(crid, language, return_linear_content)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_channel_name_via_ls(*args):
    """
    Function to mock the get_current_channel_lineup_via_ls function.

    :param args: arguments parsed from real function
    :return: mocked response
    """
    city_id, channel_number, language, product_class = args[:-1]
    with mock.patch.object(LinearService, "__init__", lambda x: None):
        obj = LinearService()
        obj._linear_service_url = "mock_url"
        return obj.get_channel_name_via_ls(city_id, channel_number,
                                           language, product_class)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_channel_id_by_name_via_ls(*args):
    """
    Function to mock the get_current_channel_lineup_via_ls function.

    :param args: arguments parsed from real function
    :return: mocked response
    """
    city_id, channel_name, language, product_class = args[:-1]
    with mock.patch.object(LinearService, "__init__", lambda x: None):
        obj = LinearService()
        obj._linear_service_url = "mock_url"
        return obj.get_channel_id_by_name_via_ls(city_id, channel_name,
                                                 language, product_class)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_channel_id_by_number_via_ls(*args):
    """
    Function to mock the get_current_channel_lineup_via_ls function.

    :param args: arguments parsed from real function
    :return: mocked response
    """
    with mock.patch.object(LinearService, "__init__", lambda x: None):
        city_id, channel_number, language, product_class = args[:-1]
        obj = LinearService()
        obj._linear_service_url = "mock_url"
        return obj.get_channel_id_by_number_via_ls(city_id, channel_number,
                                                   language, product_class)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_channel_summary_by_attribute_via_ls(*args):
    """
    Function to mock the get_current_channel_lineup_via_ls function.

    :param args: arguments parsed from real function
    :return: mocked response
    """
    city_id, attribute_name, attribute_value, language, product_class, \
    _4k_support = args[:-1]
    with mock.patch.object(LinearService, "__init__", lambda x: None):
        obj = LinearService()
        obj._linear_service_url = "mock_url"
        return obj.get_channel_summary_by_attribute_via_ls\
            (city_id, attribute_name, attribute_value, language, product_class, _4k_support)


def get_referenced_channel_number_from_list(*args):
    """
    Function to mock the get_current_channel_lineup_via_ls function.

    :param args: arguments parsed from real function
    :return: mocked response
    """
    channel_list, channel_index, position, cpe_id = args
    with mock.patch.object(LinearService, "__init__", lambda x: None):
        obj = LinearService()
        obj._linear_service_url = "mock_url"
        return obj._get_referenced_channel_number_from_list\
            (channel_list, channel_index, position, cpe_id)


def remove_radio_channels_from_channel_lineup(*args):
    """
    Function to mock the get_current_channel_lineup_via_ls function.

    :param args: arguments parsed from real function
    :return: mocked response
    """
    channel_lineup = args[0]
    with mock.patch.object(LinearService, "__init__", lambda x: None):
        obj = LinearService()
        obj._linear_service_url = "mock_url"
        return obj._remove_radio_channels_from_channel_lineup(channel_lineup)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_from_referenced_channel_via_ls(*args):
    """
    Function to mock the get_current_channel_lineup_via_ls function.

    :param args: arguments parsed from real function
    :return: mocked response
    """
    city_id, channel_number, cpe_id, language, product_class, position, radio = args[:-1]
    with mock.patch.object(LinearService, "__init__", lambda x: None):
        obj = LinearService()
        obj._linear_service_url = "mock_url"
        return obj.get_from_referenced_channel_via_ls\
            (city_id, channel_number, cpe_id, language, product_class, position, radio)


@mock.patch("requests.get", side_effect=mock_requests_get)
def is_logo_present_in_channel_bar(*args):
    """
    Function to mock the get_current_channel_lineup_via_ls function.

    :param args: arguments parsed from real function
    :return: mocked response
    """
    city_id, channel_number, language, product_class, _4k_support = args[:-1]
    with mock.patch.object(LinearService, "__init__", lambda x: None):
        obj = LinearService()
        obj._linear_service_url = "mock_url"
        return obj.is_logo_present_in_channel_bar\
            (city_id, channel_number, language, product_class, _4k_support)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_channel_number_by_id(*args):
    """
    Function to mock the get_current_channel_lineup_via_ls function.

    :param args: arguments parsed from real function
    :return: mocked response
    """
    city_id, channel_id, language, product_class = args[:-1]
    with mock.patch.object(LinearService, "__init__", lambda x: None):
        obj = LinearService()
        obj._linear_service_url = "mock_url"
        return obj.get_channel_number_by_id\
            (city_id, channel_id, language, product_class)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_channel_number_by_name(*args):
    """
    Function to mock the get_current_channel_lineup_via_ls function.

    :param args: arguments parsed from real function
    :return: mocked response
    """
    city_id, channel_name, language, product_class = args[:-1]
    with mock.patch.object(LinearService, "__init__", lambda x: None):
        obj = LinearService()
        obj._linear_service_url = "mock_url"
        return obj.get_channel_number_by_name\
            (city_id, channel_name, language, product_class)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_channel_bar_logo_basename(*args):
    """
    Function to mock the get_current_channel_lineup_via_ls function.

    :param args: arguments parsed from real function
    :return: mocked response
    """
    city_id, channel_number, language, product_class, _4k_support = args[:-1]
    with mock.patch.object(LinearService, "__init__", lambda x: None):
        obj = LinearService()
        obj._linear_service_url = "mock_url"
        return obj.get_channel_bar_logo_basename\
            (city_id, channel_number, language, product_class, _4k_support)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_channel_bar_logo_url(*args):
    """
    Function to mock the get_current_channel_lineup_via_ls function.

    :param args: arguments parsed from real function
    :return: mocked response
    """
    city_id, channel_id, language, product_class, _4k_support = args[:-1]
    with mock.patch.object(LinearService, "__init__", lambda x: None):
        obj = LinearService()
        obj._linear_service_url = "mock_url"
        return obj.get_channel_bar_logo_url\
            (city_id, channel_id, language, product_class, _4k_support)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_total_channel_count_via_ls(*args):
    """
    Function to mock the get_current_channel_lineup_via_ls function.

    :param args: arguments parsed from real function
    :return: mocked response
    """
    city_id, language, product_class = args[:-1]
    with mock.patch.object(LinearService, "__init__", lambda x: None):
        obj = LinearService()
        obj._linear_service_url = "mock_url"
        return obj.get_total_channel_count_via_ls\
            (city_id, language, product_class)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_random_channel_via_ls(*args):
    """
    Function to mock the get_current_channel_lineup_via_ls function.

    :param args: arguments parsed from real function
    :return: mocked response
    """
    city_id, language, product_class = args[:-1]
    with mock.patch.object(LinearService, "__init__", lambda x: None):
        obj = LinearService()
        obj._linear_service_url = "mock_url"
        return obj.get_random_channel_via_ls(city_id, language, product_class)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_ip_channel_list(*args):
    """
    Function to mock the get_current_channel_lineup_via_ls function.

    :param args: arguments parsed from real function
    :return: mocked response
    """
    response = args[0]
    with mock.patch.object(LinearService, "__init__", lambda x: None):
        obj = LinearService()
        obj._linear_service_url = "mock_url"
        return obj.get_ip_channel_list(response)


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


class TestKeywordLinearService(TestCaseNameAsDescription):
    """Class contains unit tests of Linear keyword."""

    def test_get_current_channel_lineup_via_ls_success_if(self):
        """Test to validate passing response to info call"""
        get_current_channel_lineup_via_ls_response = get_current_channel_lineup_via_ls\
            ("default", "mock_language", "mock_class")
        self.assertEqual(get_current_channel_lineup_via_ls_response, None)

    def test_get_current_channel_lineup_via_ls_success_else(self):
        """Test to validate passing response to info call"""
        get_current_channel_lineup_via_ls_response = get_current_channel_lineup_via_ls\
            ("channellineup", "mock_language", "mock_class")
        self.assertEqual(get_current_channel_lineup_via_ls_response, MOCK_CHANNEL_LINE_UP)

    def test_get_detail_of_linear_event_success(self):
        """Test to validate passing response to info call"""
        get_detail_of_linear_event_response = get_detail_of_linear_event\
            ("eventdetails", "mock_language", "mock_return_linear_content")
        self.assertEqual(get_detail_of_linear_event_response, MOCK_EVENT_DETAILS)

    def test_get_channel_name_via_ls(self):
        """Test to validate passing response to info call"""
        get_channel_name_via_ls_response = get_channel_name_via_ls\
            ("channellineup", "1", "mock_language", "mock_product_class")
        self.assertEqual(get_channel_name_via_ls_response, "Film1 On Demand_1")

    def test_get_channel_id_by_name_via_ls(self):
        """Test to validate passing response to info call"""
        get_channel_id_by_name_via_ls_response = get_channel_id_by_name_via_ls\
            ("channellineup", "Film1 On Demand_1", "mock_language", "mock_product_class")
        self.assertEqual(get_channel_id_by_name_via_ls_response, "NL_000190_01")

    def test_get_channel_id_by_number_via_ls(self):
        """Test to validate passing response to info call"""
        get_channel_id_by_number_via_ls_response = get_channel_id_by_number_via_ls\
            ("channellineup", "1", "mock_language", "mock_product_class")
        self.assertEqual(get_channel_id_by_number_via_ls_response, "NL_000190_01")

    def test_get_channel_summary_by_attribute_via_ls(self):
        """Test to validate passing response to info call"""
        get_channel_summary_by_attribute_via_ls_response = get_channel_summary_by_attribute_via_ls\
            ("channellineup", "id", "NL_000190_01", "mock_language",
             "mock_product_class", "mock_4k_support")
        self.assertEqual(get_channel_summary_by_attribute_via_ls_response, MOCK_CHANNEL_SUMMARY)

    def test_get_referenced_channel_number_from_list_case1(self):
        """Test to validate passing response to info call"""
        get_referenced_channel_number_from_list_response = get_referenced_channel_number_from_list\
            (MOCK_CHANNEL_REFERENCE, 0, 1, "0000F0-HZNSTB-171582122429")
        self.assertEqual(get_referenced_channel_number_from_list_response, '2')

    def test_get_referenced_channel_number_from_list_case2(self):
        """Test to validate passing response to info call"""
        get_referenced_channel_number_from_list_response = get_referenced_channel_number_from_list\
            (MOCK_CHANNEL_REFERENCE, 1, 0, "000000-HZNSTB-171582122429")
        self.assertEqual(get_referenced_channel_number_from_list_response, '2')

    def test_get_referenced_channel_number_from_list_case3(self):
        """Test to validate passing response to info call"""
        get_referenced_channel_number_from_list_response = get_referenced_channel_number_from_list\
            (MOCK_CHANNEL_REFERENCE, 0, -1, "0000F0-HZNSTB-171582122429")
        self.assertEqual(get_referenced_channel_number_from_list_response, '4')

    def test_get_referenced_channel_number_from_list_case4(self):
        """Test to validate passing response to info call"""
        get_referenced_channel_number_from_list_response = get_referenced_channel_number_from_list\
            (MOCK_CHANNEL_REFERENCE, 1, -1, "000000-HZNSTB-171582122429")
        self.assertEqual(get_referenced_channel_number_from_list_response, '1')

    def test_remove_radio_channels_from_channel_lineup(self):
        """Test to validate passing response to info call"""
        remove_radio_channels_from_channel_lineup_response = \
            remove_radio_channels_from_channel_lineup(MOCK_CHANNEL_LINE_UP)
        self.assertEqual(remove_radio_channels_from_channel_lineup_response,
                         MOCK_REMOVED_RADIO_CHANNEL_LINE_UP)

    def test_get_from_referenced_channel_via_ls_radio_channels_enabled(self):
        """Test to validate passing response to info call"""
        get_from_referenced_channel_via_ls_response = get_from_referenced_channel_via_ls\
            ("channellineup", 1, "mock_cpe_id", "mock_language", "mock_product_class", 0, True)
        self.assertEqual(get_from_referenced_channel_via_ls_response, '2')

    def test_get_from_referenced_channel_via_ls_radio_channels_disabled(self):
        """Test to validate passing response to info call"""
        get_from_referenced_channel_via_ls_response = get_from_referenced_channel_via_ls\
            ("channellineup", 2, "mock_cpe_id", "mock_language", "mock_product_class", 1, False)
        self.assertEqual(get_from_referenced_channel_via_ls_response, '3')

    def test_is_logo_present_in_channel_bar(self):
        """Test to validate passing response to info call"""
        is_logo_present_in_channel_bar_response = is_logo_present_in_channel_bar\
            ("channellineup", '2', "mock_language", "mock_product_class", True)
        self.assertEqual(is_logo_present_in_channel_bar_response, True)

    def test_get_channel_number_by_id(self):
        """Test to validate passing response to info call"""
        get_channel_number_by_id_response = get_channel_number_by_id\
            ("channellineup", 'NL_000190_03', "mock_language", "mock_product_class")
        self.assertEqual(get_channel_number_by_id_response, '3')

    def test_get_channel_number_by_name(self):
        """Test to validate passing response to info call"""
        get_channel_number_by_name_response = get_channel_number_by_name\
            ("channellineup", 'Film1 On Demand_1', "mock_language", "mock_product_class")
        self.assertEqual(get_channel_number_by_name_response, '1')

    def test_get_channel_bar_logo_basename(self):
        """Test to validate passing response to info call"""
        get_channel_bar_logo_basename_response = get_channel_bar_logo_basename\
            ("channellineup", '2', "mock_language", "mock_product_class", True)
        self.assertEqual(get_channel_bar_logo_basename_response, "film1_ondemand_2")

    def test_get_channel_bar_logo_url(self):
        """Test to validate passing response to info call"""
        get_channel_bar_logo_url_response = get_channel_bar_logo_url\
            ("channellineup", '2', "mock_language", "mock_product_class", True)
        self.assertEqual(get_channel_bar_logo_url_response,
                         "https://staticqbr-nl-prod.prod.cdn.dmdsdp.com/image-service"
                         "/ImagesEPG/EventImages/film1_ondemand_2.png")

    def test_get_total_channel_count_via_ls(self):
        """Test to validate passing response to info call"""
        get_total_channel_count_via_ls_response = get_total_channel_count_via_ls\
            ("count", "mock_language", "mock_product_class")
        self.assertEqual(get_total_channel_count_via_ls_response, 2)

    def test_get_random_channel_via_ls(self):
        """Test to validate passing response to info call"""
        get_random_channel_via_ls_response = get_random_channel_via_ls\
            ("randomchannel", "mock_language", "mock_product_class")
        self.assertEqual(get_random_channel_via_ls_response, MOCK_RANDOM_CHANNEL[0])

    def test_get_ip_channel_list(self):
        """Test to validate passing response to info call"""
        get_ip_channel_list_response = get_ip_channel_list(MOCK_IP_CHANNEL)
        self.assertEqual(get_ip_channel_list_response, ['NL_000190_01'])


def suite_linearservice():
    """Function to make the test suite for unittests"""
    return unittest.makeSuite(TestKeywordLinearService, "test")

def run_tests():
    """A function to run unit tests (real Linear Service will not be used)."""
    suite = suite_linearservice()
    unittest.TextTestRunner(verbosity=2).run(suite)

if __name__ == "__main__":
    run_tests()
