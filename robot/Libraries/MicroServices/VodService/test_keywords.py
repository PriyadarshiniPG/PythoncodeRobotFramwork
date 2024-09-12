# pylint: disable=unused-argument,invalid-name
# Disabled pylint "unused-argument" complaining on args for mock patches'
# Disabled pylint "invalid-name" complaining on the keywords 'test_vod_mostrelevantepisode_refused',
# 'test_vod_mostrelevantepisode_failed' (snake_case naming style, name length > 30).

"""Unit tests of of VOD Microservice tests for HZN 4.

Tests use mock module and do not send real requests to real VOD Service.

v0.0.1 - Anuj Teotia: Add unittest:  get_rental_assets.
v0.0.2 - Vasundhara Agrawal: Added unittests:  get_vod_gridoptions,
         get_vod_tilescreen, get_detailscreen
v0.0.3 - Anuj Teotia: Added get_basic_collection_vod_crid and get_grid_collection_vod_crid.
v0.0.4 - Anuj Teotia: Added get_grid_collection_vod_crid & get_tile_screen_crid
"""

import unittest
try:
    import mock
except ImportError:
    import unittest.mock as mock
import socket
import requests
from robot.libraries.BuiltIn import BuiltIn
from .keywords import Keywords
from .keywords import VodServiceRequests

CONF = {
    "MICROSERVICES": {
        "OBOQBR": "oboqbr.some_host.nl.dmdsdp.com",
        },
    "CPE_ID": "3C36E4-EOSSTB-003469707008"
    }

MOCK_STRUCTURE_RESPONSE = "MOCK_STRUCTURE_RESPONSE"

MOCK_CONTEXT_RESPONSE = "MOCK_CONTEXT_RESPONSE"

MOCK_SCREEN_RESPONSE = "MOCK_SCREEN_RESPONSE"

MOCK_DETAILSCREEN_RESPONSE = "MOCK_DETAILSCREEN_RESPONSE"

MOCK_MOSTRELEVANTEPISODE_RESPONSE = "MOCK_MOSTRELEVANTEPISODE_RESPONSE"

MOCK_GRIDSCREEN_RESPONSE = "MOCK_GRIDSCREEN_RESPONSE"

MOCK_SERIES_DETAILSCREEN_RESPONSE = "MOCK_SERIES_DETAILSCREEN_RESPONSE"

MOCK_RENTALS_RESPONSE = "MOCK_RENTALS_RESPONSE"

MOCK_RENTAL_ASSETS = "MOCK_RENTAL_ASSETS"

MOCK_GRIDOPTIONS_RESPONSE = "MOCK_GRIDOPTIONS_RESPONSE"

MOCK_TILESCREEN_RESPONSE = "MOCK_TILESCREEN_RESPONSE"

MOCK_VOD_STRUCTURE = {
    "screens": [{
        "ordinal": 1,
        "screenLayout": "Collection",
        "title": "Discover",
        "_performanceData": {
            "numberOfErrors": 0
        },
        "id": "crid:~~2F~~2Fschange.com~~2Fd8e833fc-2471-4f60-b10c-eb759db302d0",
        "isAdult": "False"
    }, {
        "ordinal": 2,
        "screenLayout": "Collection",
        "title": "Movies",
        "_performanceData": {
            "numberOfErrors": 0
        },
        "id": "crid:~~2F~~2Fschange.com~~2F5d1c9c01-8605-4063-91ce-54d19fa68fef",
        "isAdult": "False"
    }, {
        "ordinal": 3,
        "screenLayout": "Collection",
        "title": "Series",
        "_performanceData": {
            "numberOfErrors": 0
        },
        "id": "crid:~~2F~~2Fschange.com~~2Ffde930d8-4444-4563-8449-116086e0a438",
        "isAdult": "False"
    }, {
        "ordinal": 4,
        "screenLayout": "Collection",
        "title": "Kids",
        "_performanceData": {
            "numberOfErrors": 0
        },
        "id": "crid:~~2F~~2Fschange.com~~2F3eee660b-8b9c-43f7-80ae-5f6a74dfacbd",
        "isAdult": "False"
    }, {
        "ordinal": 5,
        "screenLayout": "Collection",
        "title": "RENT",
        "_performanceData": {
            "numberOfErrors": 0
        },
        "id": "crid:~~2F~~2Fschange.com~~2F5f497f63-c3a1-4351-8484-d9d2057ec5b2",
        "isAdult": "False"
    }, {
        "ordinal": 6,
        "screenLayout": "Tile",
        "title": "Providers",
        "_performanceData": {
            "numberOfErrors": 0
        },
        "id": "crid:~~2F~~2Fschange.com~~2F60dd2209-099e-4e09-9a46-a91c813e1629",
        "isAdult": "False"
    }, {
        "ordinal": 7,
        "screenLayout": "Collection",
        "title": "Selene",
        "_performanceData": {
            "numberOfErrors": 0
        },
        "id": "crid:~~2F~~2Fschange.com~~2F9db5e393-e9dc-419e-888d-90c06dd036ac",
        "isAdult": "False"
    }
               ],
    "rootId": "omw_hzn4_vod",
    "hotlinks": {
        "adultRentScreen": {
            "ordinal": 12,
            "screenLayout": "Sections",
            "title": "Adult",
            "_performanceData": {
                "numberOfErrors": 0
            },
            "id": "crid:~~2F~~2Fschange.com~~2F73ab2a4f-d1af-42fc-a3d7-1379a9c11798",
            "isAdult": "True"
        },
        "rentScreen": {
            "ordinal": 12,
            "screenLayout": "Collection",
            "title": "RENT",
            "_performanceData": {
                "numberOfErrors": 0
            },
            "id": "crid:~~2F~~2Fschange.com~~2F5f497f63-c3a1-4351-8484-d9d2057ec5b2",
            "isAdult": "False"
        }
    },
    "id": "crid:~~2F~~2Fschange.com~~2F37379cf0-7712-4718-8ce0-d0e21c77d7dd",
    "title": "MOVIES & SERIES"
}
MOCK_VOD_SCREEN = """
{
"screenLayout": "Collection",
"title": "Discover",
"collections": [{
        "ordinal": 1,
        "contentType": "ContinueWatching",
        "collectionLayout": "BasicCollection",
        "title": "Continue Watching",
        "items": [{
                "ordinal": 1,
                "assetType": "REGULAR",
                "title": "A View to a Kill",
                "bookmark": 12,
                "landscapeImageTileType": "HighResLandscapeProductionStill",
                "popularity": 8,
                "landscapeImageType": "HighResLandscape",
                "minResolution": "SD",
                "duration": 28,
                "ageRating": "12",
                "type": "ASSET",
                "id": "crid:~~2F~~2Fperf.e2e-si.lgi.com~~2F707-a-view-to-a-killl",
                "imageType": "HighResPortrait",
                "isAdult": "False"
            }, {
                "ordinal": 2,
                "assetType": "REGULAR",
                "minPriceDisplay": "6,00",
                "title": "Justice League stevenvi",
                "bookmark": 504,
                "landscapeImageTileType": "HighResLandscapeProductionStill",
                "minResolution": "HD",
                "duration": 634,
                "minPrice": "6.00",
                "type": "ASSET",
                "id": "crid:~~2F~~2Fe2e-si.lgi.com~~2F141052-justice-league-steven",
                "imageType": "HighResPortrait",
                "isAdult": "False"
            }
        ],
        "totalCount": 2,
        "type": "UnfocusedShowcase",
        "id": "crid:~~2F~~2Fschange.com~~2Fc8425ae0-93e1-4a9d-baca-067577b4cce5",
        "isAdult": "False"
    },{
        "id": "crid:~~2F~~2Fschange.com~~2F667dec71-3c65-4f6e-b4e3-4c0a3977cbfb",
        "title": "Genres",
        "ordinal": 3,
        "type": "UnfocusedShowcase",
        "isAdult": "false",
        "collectionLayout": "TileCollection",
        "contentType": "Editorial",
        "items": [{
                "id": "crid:~~2F~~2Fschange.com~~2F32ec5278-5741-4ca8-b2a5-f092ee96a661",
                "title": "Action",
                "subTitle": "Action",
                "isAdult": "false",
                "gridLink": {
                    "id": "crid:~~2F~~2Fschange.com~~2F599c14aa-63fe-488b-9959-91800197b0b3",
                    "type": "Grid",
                    "softLinkType": "GenreCategoryLink",
                    "title": "Action"
                },
                "screenLayout": "Grid"
            }, {
                "id": "crid:~~2F~~2Fschange.com~~2F45647ad8-24ea-4619-a543-78457e1eed88",
                "title": "Adventure",
                "subTitle": "Adventure",
                "isAdult": "false",
                "gridLink": {
                    "id": "crid:~~2F~~2Fschange.com~~2F266196d4-5914-4956-b6a5-9001259ce7e4",
                    "type": "Grid",
                    "softLinkType": "GenreCategoryLink",
                    "title": "Adventure"
                },
                "screenLayout": "Grid"
            }
        ]
    },{
        "id": "crid:~~2F~~2Fschange.com~~2F3de0212d-b0e7-42cd-8f76-e0d98d3ab562",
        "title": "HZN4PD-32514_ser",
        "ordinal": 4,
        "type": "SeriesContainer",
        "isAdult": "false",
        "collectionLayout": "GridCollection",
        "contentType": "Editorial",
        "totalCount": 14,
        "gridLink": {
            "id": "crid:~~2F~~2Fschange.com~~2F3de0212d-b0e7-42cd-8f76-e0d98d3ab562",
            "type": "Grid",
            "title": "HZN4PD-32514_ser"
        },
        "items": [{
                "id": "crid:~~2F~~2Fe2e-si.lgi.com~~2F1399-game-of-thrones",
                "type": "SERIES",
                "title": "Game of Thrones",
                "ordinal": 1,
                "isAdult": "false",
                "popularity": 316,
                "imageType": "HighResPortrait",
                "landscapeImageType": "HighResLandscape",
                "landscapeImageTileType": "HighResLandscape",
                "userInteractedWithSeries": "false",
                "minResolution": "SD"
            }, {
                "id": "crid:~~2F~~2Fe2e-si.lgi.com~~2F1412-arrow",
                "type": "SERIES",
                "title": "Arrow",
                "ordinal": 2,
                "isAdult": "false",
                "popularity": 526,
                "imageType": "HighResPortrait",
                "landscapeImageType": "HighResLandscape",
                "landscapeImageTileType": "HighResLandscape",
                "userInteractedWithSeries": "false",
                "minResolution": "SD"
            }
        ]
    }
],
"id": "crid:~~2F~~2Fschange.com~~2Fd8e833fc-2471-4f60-b10c-eb759db302d0",
"isAdult": "False"
}
"""

MOCK_GRID_SCREEN = """
{
    "id": "crid:~~2F~~2Fschange.com~~2F4e01f549-775b-4d0b-8044-482ecc882025",
    "title": "All Series",
    "screenLayout": "Grid",
    "isAdult": "False",
    "indexStart": 0,
    "itemCount": 42,
    "totalCount": 61,
    "items": [{
            "id": "crid:~~2F~~2Fe2e-si.lgi.com~~2F66788-13-reasons-why",
            "type": "SERIES",
            "title": "13 Reasons Why",
            "ordinal": 1,
            "isAdult": "False",
            "popularity": 1704,
            "imageType": "HighResPortrait",
            "landscapeImageType": "HighResLandscape",
            "landscapeImageTileType": "HighResLandscape",
            "userInteractedWithSeries": "False",
            "minResolution": "SD"
        }, {
            "id": "crid:~~2F~~2Fe2e-si.lgi.com~~2F1412-arrow",
            "type": "SERIES",
            "title": "Arrow",
            "ordinal": 2,
            "isAdult": "False",
            "popularity": 1404,
            "imageType": "HighResPortrait",
            "landscapeImageType": "HighResLandscape",
            "landscapeImageTileType": "HighResLandscape",
            "userInteractedWithSeries": "False",
            "minResolution": "SD"
        }, {
            "id": "crid:~~2F~~2Fe2e-si.lgi.com~~2F30639-aspe",
            "type": "SERIES",
            "title": "Aspe",
            "ordinal": 3,
            "isAdult": "False",
            "popularity": 1679,
            "imageType": "HighResPortrait",
            "landscapeImageType": "HighResLandscape",
            "landscapeImageTileType": "HighResLandscape",
            "userInteractedWithSeries": "False",
            "minResolution": "SD"
        }
    ]
}
"""

MOCK_CRID_ID = None
MOCK_TILE_SCREEN = "MOCK_TILE_SCREEN"


def mock_requests_get(*args, **kwargs):
    """A Function to create the fake response"""
    response_data = {}
    profile_id = ""
    if 'profileId' in kwargs['params']:
        profile_id = kwargs['params']['profileId']
    else:
        x_cust = kwargs['headers']['x-cus']
    if "test1" in profile_id:
        response_data = dict(text=MOCK_STRUCTURE_RESPONSE, status_code=200, reason="OK")
    elif "test2" in profile_id:
        response_data = dict(text=MOCK_CONTEXT_RESPONSE, status_code=200, reason="OK")
    elif "test3" in profile_id:
        response_data = dict(text=MOCK_SCREEN_RESPONSE, status_code=200, reason="OK")
    elif "test4" in profile_id:
        response_data = dict(text=MOCK_DETAILSCREEN_RESPONSE, status_code=200, reason="OK")
    elif "test5" in profile_id:
        response_data = dict(text=MOCK_MOSTRELEVANTEPISODE_RESPONSE, status_code=200, reason="OK")
    elif "test6" in profile_id:
        response_data = dict(text=MOCK_GRIDSCREEN_RESPONSE, status_code=200, reason="OK")
    elif "test7" in profile_id:
        response_data = dict(text=MOCK_SERIES_DETAILSCREEN_RESPONSE, status_code=200, reason="OK")
    elif "test8" in profile_id:
        response_data = dict(text=MOCK_RENTALS_RESPONSE, status_code=200, reason="OK")
    elif "test9" in profile_id:
        response_data = dict(text=MOCK_GRIDOPTIONS_RESPONSE, status_code=200, reason="OK")
    elif "test0" in profile_id:
        response_data = dict(text=MOCK_TILESCREEN_RESPONSE, status_code=200, reason="OK")
    elif "1test" in profile_id:
        response_data = dict(text=MOCK_VOD_SCREEN, status_code=200, reason="OK")
    elif "2test" in profile_id:
        response_data = dict(text=MOCK_GRID_SCREEN, status_code=200, reason="OK")
    elif "3test" in profile_id:
        response_data = dict(text=MOCK_TILE_SCREEN, status_code=200, reason="OK")
    elif "4test" in profile_id:
        response_data = dict(text=MOCK_VOD_SCREEN, status_code=200, reason="OK")
    elif "refused" in profile_id:
        raise requests.exceptions.ConnectionError("[WinError 10061] No connection could be made " +
                                                  "because the target machine actively refused it")
    elif "failed" in profile_id:
        raise socket.gaierror("[Errno 11001] getaddrinfo failed")
    elif "cust_id" in x_cust:
        response_data = dict(text=MOCK_RENTAL_ASSETS, status_code=200, reason="OK")
    return type("", (), response_data)()


@mock.patch("requests.get", side_effect=mock_requests_get)
@mock.patch.object(BuiltIn, "get_variable_value", return_value=(CONF["CPE_ID"]))
def get_vod_structure(*args):
    """
    Function to mock the get_vod_structure function.

    :param args: arguments parsed from real function
    :return: mocked response
    """

    conf, country, language, customer_id, profile_id, root_id = args[:-2]
    return Keywords.get_vod_structure(conf, country, language, customer_id, profile_id, root_id)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_vod_context_menu(*args):
    """
    Function to mock the get_vod_context_menu function.

    :param args: arguments parsed from real function
    :return: mocked response
    """

    conf, country, language, customer_id, profile_id, root_id, opt_in = args[:-1]
    return Keywords.get_vod_context_menu(conf, country, language, customer_id, profile_id,
                                         root_id, opt_in)


@mock.patch("requests.get", side_effect=mock_requests_get)
@mock.patch.object(BuiltIn, "get_variable_value", return_value=(CONF["CPE_ID"]))
def get_vod_screen(*args):
    """
    Function to mock the get_vod_screen function.

    :param args: arguments parsed from real function
    :return: mocked response
    """

    conf, country, language, customer_id, profile_id, root_id, crid, opt_in = args[:-2]
    return Keywords.get_vod_screen(conf, country, language, customer_id, profile_id,
                                   root_id, crid, opt_in)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_vod_detailscreen(*args):
    """
    Function to mock the get_vod_structure function.

    :param args: arguments parsed from real function
    :return: mocked response
    """

    conf, country, language, customer_id, profile_id, crid = args[:-1]
    return Keywords.get_vod_detailscreen(conf, country, language, customer_id, profile_id,
                                         crid)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_detailscreen(*args):
    """
    Function to mock the get_vod_structure function.

    :param args: arguments parsed from real function
    :return: mocked response
    """

    conf, country, language, customer_id, profile_id, crid = args[:-1]
    return Keywords.get_detailscreen(conf, country, language, customer_id, profile_id,
                                     crid)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_vod_mostrelevantepisode(*args):
    """
    Function to mock the get_vod_structure function.

    :param args: arguments parsed from real function
    :return: mocked response
    """

    conf, country, language, customer_id, profile_id, crid, vod_type = args[:-1]
    return Keywords.get_vod_mostrelevantepisode(conf, country, language, customer_id, profile_id,
                                                crid, vod_type)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_vod_gridscreen(*args):
    """
    Function to mock the get_vod_gridscreen function.

    :param args: arguments parsed from real function
    :return: mocked response
    """

    conf, country, language, customer_id, profile_id, root_id, crid, opt_in = args[:-1]
    return Keywords.get_vod_gridscreen(conf, country, language, customer_id, profile_id, root_id,
                                       crid, opt_in)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_vod_series_detailscreen(*args):
    """
    Function to mock the get_vod_series_detail function.

    :param args: arguments parsed from real function
    :return: mocked response
    """

    conf, country, language, customer_id, profile_id, crid = args[:-1]
    return Keywords.get_vod_series_detail(conf, country, language, customer_id, profile_id,
                                          crid)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_vod_rentals(*args):
    """
    Function to mock get_vod_rentals function.

    :param args: arguments parsed from real function
    :return: mocked response
    """

    conf, country, language, customer_id, profile_id = args[:-1]
    return Keywords.get_vod_rentals(conf, country, language, customer_id, profile_id)


@mock.patch("requests.get", side_effect=mock_requests_get)
@mock.patch.object(BuiltIn, "get_variable_value", return_value=(CONF["CPE_ID"]))
def get_rental_assets(*args):
    """
    Function to mock the get_rental_assets function.

    :param args: arguments parsed from real function
    :return: mocked response
    """

    conf, country, language, customer_id, profile_id = args[:-2]
    return Keywords.get_rental_assets(conf, country, language, customer_id, profile_id)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_vod_gridoptions(*args):
    """
    Function to mock the get_vod_gridoptions function.

    :param args: arguments parsed from real function
    :return: mocked response
    """

    conf, country, language, customer_id, profile_id, crid, opt_in = args[:-1]
    return Keywords.get_vod_gridoptions(conf, country, language, customer_id, profile_id,
                                        crid, opt_in)


@mock.patch("requests.get", side_effect=mock_requests_get)
def get_vod_tilescreen(*args):
    """
    Function to mock the get_vod_tilescreen function.

    :param args: arguments parsed from real function
    :return: mocked response
    """

    conf, country, language, customer_id, profile_id, root_id, crid, opt_in = args[:-1]
    return Keywords.get_vod_tilescreen(conf, country, language, customer_id, profile_id,
                                       root_id, crid, opt_in)


@mock.patch("requests.get", side_effect=mock_requests_get)
@mock.patch.object(BuiltIn, "get_variable_value", return_value=(CONF["CPE_ID"]))
def get_basic_collection_vod_crid(*args):
    """
    Function to mock the get_basic_collection_vod_crid function.

    :param args: arguments parsed from real function
    :return: mocked response
    """
    conf, country, language, customer_id, profile_id, root_id, asset_type, \
    is_tvod, is_adult = args[:-2]
    return Keywords.get_basic_collection_vod_crid(conf, country, language, customer_id, profile_id,
                                                  root_id, asset_type, is_tvod, is_adult)


@mock.patch("requests.get", side_effect=mock_requests_get)
@mock.patch.object(BuiltIn, "get_variable_value", return_value=(CONF["CPE_ID"]))
def get_tile_screen_crid(*args):
    """
    Function to mock the get_tile_screen_crid function.

    :param args: arguments parsed from real function
    :return: mocked response
    """

    conf, country, language, customer_id, profile_id, vod_structure, root_id = args[:-2]
    return Keywords.get_tile_screen_crid(conf, country, language, customer_id,
                                         profile_id, vod_structure, root_id)


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


class TestKeyword_VodService(TestCaseNameAsDescription):
    """Class contains unit tests of VodService keyword."""

    @classmethod
    def setUpClass(cls):
        cls.keywords = Keywords

    def test_vod_structure_ok(self):
        """Test to check successful response for vod structure"""

        response = get_vod_structure(CONF, "NL", "nld", "cust_id", "test1", "root_id")
        self.assertEqual(response.text, MOCK_STRUCTURE_RESPONSE)

    def test_vod_structure_refused(self):
        """Test to check refused connection for vod structure"""

        response = str(get_vod_structure(CONF, "NL", "nld", "cust_id", "refused", "root_id").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_vod_structure_failed(self):
        """Test to check failed connection for vod structure"""

        response = str(get_vod_structure(CONF, "NL", "nld", "cust_id", "failed", "root_id").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

    def test_vod_context_menu_ok(self):
        """Test to check successful response for vod context menu"""

        response = get_vod_context_menu(CONF, "NL", "nld", "cust_id", "test2", "root_id", True)
        self.assertEqual(response.text, MOCK_CONTEXT_RESPONSE)

    def test_vod_context_menu_refused(self):
        """Test to check refused connecion for vod context menu"""

        response = str(get_vod_context_menu(CONF, "NL", "nld", "cust_id", "refused", "root_id",
                                            True).error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_vod_context_menu_failed(self):
        """Test to check failed connection for vod context menu"""

        response = str(get_vod_context_menu(CONF, "NL", "nld", "cust_id", "failed", "root_id",
                                            True).error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

    def test_vod_screen_ok(self):
        """Test to check successful response for vod screen"""

        response = get_vod_screen(CONF, "NL", "nld", "cust_id", "test3", "root_id", "crid", True)
        self.assertEqual(response.text, MOCK_SCREEN_RESPONSE)

    def test_vod_screen_refused(self):
        """Test to check refused connection for vod screen"""

        response = str(get_vod_screen(CONF, "NL", "nld", "cust_id", "refused", "root_id", "crid",
                                      True).error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_vod_screen_menu_failed(self):
        """Test to check failed connection for vod screen"""

        response = str(get_vod_screen(CONF, "NL", "nld", "cust_id", "failed", "root_id", "crid",
                                      True).error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

    def test_vod_detail_screen_ok(self):
        """Test to check successful response for vod detail screen"""

        response = get_vod_detailscreen(CONF, "NL", "nld", "cust_id", "test4", "crid")
        self.assertEqual(response.text, MOCK_DETAILSCREEN_RESPONSE)

    def test_vod_detail_screen_refused(self):
        """Test to check refused connection for vod detail screen"""

        response = str(get_vod_detailscreen(CONF, "NL", "nld", "cust_id", "refused", "crid").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_vod_detail_screen_failed(self):
        """Test to check failed connection for vod detail screen"""

        response = str(get_vod_detailscreen(CONF, "NL", "nld", "cust_id", "failed", "crid").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

    def test_detail_screen_ok(self):
        """Test to check successful response for vod detail screen"""

        response = get_detailscreen(CONF, "NL", "nld", "cust_id", "test4", "crid")
        self.assertEqual(response.text, MOCK_DETAILSCREEN_RESPONSE)

    def test_detail_screen_refused(self):
        """Test to check refused connection for vod detail screen"""

        response = str(get_detailscreen(CONF, "NL", "nld", "cust_id", "refused", "crid").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_detail_screen_failed(self):
        """Test to check failed connection for vod detail screen"""

        response = str(get_detailscreen(CONF, "NL", "nld", "cust_id", "failed", "crid").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

    def test_vod_mostrelevantepisode_ok(self):
        """Test to check successful response for vod detail screen"""

        response = get_vod_mostrelevantepisode(CONF, "NL", "nld", "cust_id", "test5",
                                               "crid", "SERIES")
        self.assertEqual(response.text, MOCK_MOSTRELEVANTEPISODE_RESPONSE)

    def test_vod_mostrelevantepisode_refused(self):
        """Test to check refused connection for vod detail screen"""
        response = get_vod_mostrelevantepisode(CONF, "NL", "nld", "cust_id", "refused",
                                               "crid", "SERIES")
        error = str(response.error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(error, expected)

    def test_vod_mostrelevantepisode_failed(self):
        """Test to check failed connection for vod detail screen"""
        response = get_vod_mostrelevantepisode(CONF, "NL", "nld", "cust_id", "failed",
                                               "crid", "SERIES")
        error = str(response.error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(error, expected)

    def test_vod_gridscreen_ok(self):
        """Test to check successful response for vod gridscreen"""

        response = get_vod_gridscreen(CONF, "NL", "nld", "cust_id", "test6", "root_id",
                                      "crid", True)
        self.assertEqual(response.text, MOCK_GRIDSCREEN_RESPONSE)

    def test_vod_gridscreen_refused(self):
        """Test to check refused connection for vod gridscreen"""

        response = str(get_vod_gridscreen(CONF, "NL", "nld", "cust_id", "refused",
                                          "root_id", "crid", True).error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_vod_gridscreen_menu_failed(self):
        """Test to check failed connection for vod gridscreen"""

        response = str(get_vod_gridscreen(CONF, "NL", "nld", "cust_id", "failed",
                                          "root_id", "crid", True).error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

    def test_vod_series_detailscreen_ok(self):
        """Test to check successful response for vod detail screen"""

        response = get_vod_series_detailscreen(CONF, "NL", "nld", "cust_id", "test7",
                                               "crid")
        self.assertEqual(response.text, MOCK_SERIES_DETAILSCREEN_RESPONSE)

    def test_vod_Series_detailscreen_refused(self):
        """Test to check refused connection for vod detail screen"""

        response = str(get_vod_detailscreen(CONF, "NL", "nld", "cust_id", "refused",
                                            "crid").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_vod_Series_detailscreen_failed(self):
        """Test to check failed connection for vod detail screen"""

        response = str(get_vod_series_detailscreen(
            CONF, "NL", "nld", "cust_id", "failed", "crid").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

    def test_vod_rentals_ok(self):
        """Test to check successful response for vod rentals"""

        response = get_vod_rentals(CONF, "NL", "nld", "cust_id", "test8")
        self.assertEqual(response.text, MOCK_RENTALS_RESPONSE)

    def test_vod_rentals_refused(self):
        """Test to check refused connection for vod rentals"""

        response = str(get_vod_rentals(CONF, "NL", "nld", "cust_id", "refused").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_vod_rentals_failed(self):
        """Test to check failed connection for vod rentals"""

        response = str(get_vod_rentals(CONF, "NL", "nld", "cust_id", "failed").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

    def test_vod_rental_assets(self):
        """Test to check successful response for vod rental assets"""

        response = get_rental_assets(CONF, "be", "en", "cust_id", "assets")
        self.assertEqual(response.text, MOCK_RENTAL_ASSETS)

    def test_vod_gridoptions_ok(self):
        """Test to check successful response for vod grid options"""

        response = get_vod_gridoptions(CONF, "NL", "nld", "cust_id", "test9", "crid", True)
        self.assertEqual(response.text, MOCK_GRIDOPTIONS_RESPONSE)

    def test_vod_gridoptions_refused(self):
        """Test to check refused connection for vod grid options"""
        response = get_vod_gridoptions(CONF, "NL", "nld", "cust_id", "refused", "crid", True)
        error = str(response.error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(error, expected)

    def test_vod_gridoptions_failed(self):
        """Test to check failed connection for vod grid options"""
        response = get_vod_gridoptions(CONF, "NL", "nld", "cust_id", "failed", "crid", True)
        error = str(response.error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(error, expected)

    def test_vod_tilescreen_ok(self):
        """Test to check successful response for vod tile screen"""

        response = get_vod_tilescreen(CONF, "NL", "nld", "cust_id", "test0", "root_id",
                                      "crid", True)
        self.assertEqual(response.text, MOCK_TILESCREEN_RESPONSE)

    def test_vod_tilescreen_refused(self):
        """Test to check refused connection for vod tile screen"""
        response = get_vod_tilescreen(CONF, "NL", "nld", "cust_id", "refused", "root_id",
                                      "crid", True)
        error = str(response.error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(error, expected)

    def test_vod_tilescreen_failed(self):
        """Test to check failed connection for vod tile screen"""
        response = get_vod_tilescreen(CONF, "NL", "nld", "cust_id", "failed", "root_id",
                                      "crid", True)
        error = str(response.error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(error, expected)

    def test_get_basic_collection_vod_crid(self):
        """Test to check successful response for vod basic crid"""

        response = get_basic_collection_vod_crid(
            CONF, "NL", "nld", "cust_id", "1test", MOCK_VOD_STRUCTURE, "1test", "ASSET", True)
        self.assertEqual(response, MOCK_CRID_ID)

    @mock.patch.object(VodServiceRequests, "get_vod_screen", return_value=MOCK_VOD_SCREEN)
    @mock.patch.object(VodServiceRequests, "get_vod_gridscreen", return_value=MOCK_GRID_SCREEN)
    def test_get_grid_collection_vod_crid(self, *args):
        """Test to check successful response for vod grid crid"""

        response = self.keywords.get_grid_collection_vod_crid(CONF, "NL", "nld", "cust_id",
                                                              "profid", MOCK_VOD_STRUCTURE,
                                                              "2test", "ASSET", True)

        self.assertEqual(response, MOCK_CRID_ID)

    @mock.patch.object(VodServiceRequests, "get_vod_screen", return_value=MOCK_VOD_SCREEN)
    @mock.patch.object(VodServiceRequests, "get_vod_gridscreen", return_value=MOCK_GRID_SCREEN)
    def test_get_tile_collection_vod_crid(self, *args):
        """Test to check successful response for vod tile crid"""

        response = self.keywords.get_grid_collection_vod_crid(CONF, "NL", "nld", "cust_id",
                                                              "profid", MOCK_VOD_STRUCTURE,
                                                              "3test", "ASSET", True)

        self.assertEqual(response, MOCK_CRID_ID)

    def test_get_tile_screen_crid(self):
        """Test to check successful response for vod tile screen crid"""

        response = get_tile_screen_crid(CONF, "NL", "nld", "cust_id", "4test",
                                        MOCK_VOD_STRUCTURE, "root_id")
        print(response)
        self.assertEqual(response, MOCK_CRID_ID)


def suite_vodservice():
    """Function to make the test suite for unittests"""

    return unittest.makeSuite(TestKeyword_VodService, "test")


def run_tests():
    """A function to run unit tests (real EPG Service will not be used)."""

    suite = suite_vodservice()
    unittest.TextTestRunner(verbosity=2).run(suite)


if __name__ == "__main__":
    run_tests()
