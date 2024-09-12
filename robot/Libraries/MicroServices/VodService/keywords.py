# pylint: disable=W0613
#pylint: disable-msg=R0913
"""Implementation of VOD Microservice for HZN 4
v0.0.1 - Vasundhara Agrawal: Added functions get_vod_gridoptions, get_vod_tilescreen;
        get_detailscreen to eliminate customerId
v0.0.2 - Anuj Teotia :  Added function get_grid_id
v0.0.3 - Anuj Teotia :  Changed all the functions to adapt new profile Id from
                        Personalization service.
v0.0.4 - Anuj Teotia : Added function get_vod_crid
v0.0.5 - Anuj Teotia: Added get_basic_collection_vod_crid and get_grid_collection_vod_crid.
v0.0.6 - Anuj Teotia: Added get_grid_collection_vod_crid & get_tile_screen_crid
v0.0.7 - Anuj Teotia: Modified get_rental_assets for R4.18
"""
import os
import socket
import json
import urllib.parse
import requests
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError


def failed_response_data(req_method, req_url, req_body, error):
    """A function returns an instance similar to the http response.
    "Similar" means it has some attributes of the http response instance used in Robot test cases.
    This function should be used to guarantee even if we could not connect to the server,
    we still have the attributes of the http response to verify (they just will have None values),
    so the results will go to ElasticSearch properly.

    :param req_method: an HTTP method, e.g. "POST".
    :param req_url: a url used to send the request.
    :param req_body: a string of data sent (if any).
    :param error: an error message caught by try-except block.

    :return: an instance of an anonymous class.
    """
    data = dict(text=None, status_code=None, reason=None, json=lambda arg: None, error=error,
                request=type("", (), dict(method=req_method, url=req_url, body=req_body))()
               )
    return type("", (), data)()


class VodServiceRequests(object):
    """Class handling all functions relating
    to making VOD Service requests
    """

    def __init__(self, conf, country, language, customer_id, profile_id, root_id="omw_hzn4_vod"):
        """"Class initializer.
        :param conf: config file for labs
        :param country: the country provided by Jenkins
        :param language: the language provided by Jenkins
        :param profile: the customer profile Id returned from IT Faker
        """
        self.basepath = "http://%s/one-catalog-service" % conf["MICROSERVICES"]["OBOQBR"]
        self.country = country
        self.language = language
        self.master_profile_id = profile_id
        self.master_customer_id = customer_id
        self.fallback_root_id = root_id

        try:
            self.cpe_id = BuiltIn().get_variable_value("${CPE_ID}")
            # Use folder name where this file is placed
            # (as Traxis, Fabrix, PurchaseMicroservice, etc) as a tag
            folder_name = os.path.basename(os.path.dirname(os.path.realpath(__file__)))
            BuiltIn().set_test_variable("${ENDPOINT_TAG}", "%s" % folder_name)
        except RobotNotRunningError:
            pass

    def get_vod_structure(self, root_id):
        """A function to return the VOD structure.
        :param root_id: root key of vod structure provided by Jenkins

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        url = "%s/v3/structure/%s" % (self.basepath, root_id)
        BuiltIn().log("Url is : {}".format(url))
        parameters = {'fallbackRootId': self.fallback_root_id, 'language': self.language,
                      'profileId': self.master_profile_id}
        headers = {"X-dev": self.cpe_id}
        BuiltIn().log("Parameter Values are : {}".format(parameters))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url, params=parameters, headers=headers)
            if response.status_code != 200:
                BuiltIn().log_to_console("Send GET to %s?fallbackRootId=%s&language=%s"
                                         "Status code: %s, Reason: %s"
                                         % (url, self.fallback_root_id, self.language,
                                            response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

    def get_vod_structure_by_crid(self, root_id, crid_id):
        """A function to return the VOD structure.
        :param root_id: root key of vod structure provided by Jenkins
        :param crid_id: the crid id of the screen for which structure is to be found

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        url = "%s/v2/vodstructure/%s/%s" % (self.basepath, root_id, crid_id)
        BuiltIn().log("Url is : {}".format(url))
        parameters = {'fallbackRootId': self.fallback_root_id, 'language': self.language,
                      'profileId': self.master_profile_id}
        headers = {"X-dev": self.cpe_id}
        BuiltIn().log("Parameter Values are : {}".format(parameters))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url, params=parameters, headers=headers)
            if response.status_code != 200:
                BuiltIn().log_to_console("Send GET to %s?fallbackRootId=%s&language=%s"
                                         "Status code: %s, Reason: %s"
                                         % (url, self.fallback_root_id, self.language,
                                            response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

    def get_vod_context_menu(self, root_id, opt_in):
        """A function to return the context menu for a single VOD node.
        :param root_id: root key of vod structure provided by Jenkins
        :param opt_in: optIn status of the customer, provided by Jenkins

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        url = "%s/v2/contextualvod/%s" % (self.basepath, root_id)
        parameters = {'country': self.country, 'language': self.language,
                      'optIn': opt_in, 'profileId': self.master_profile_id}
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url, params=parameters)
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

    def get_vod_screen(self, root_id, crid, opt_in, return_json=True):
        """A function to return the vod screen for a single VOD asset.
        :param root_id: root key of vod structure provided by Jenkins
        :param crid: crid of vod folder to display
        :param opt_in: optIn status of the customer, provided by Jenkins

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        url = "%s/v2/vodscreen/%s/%s" % (self.basepath, root_id, crid)
        parameters = {'language': self.language, 'optIn': opt_in,
                      'profileId': self.master_profile_id,
                      'customerId': self.master_customer_id}
        headers = {"X-dev": self.cpe_id, "X-cus": self.master_customer_id}
        BuiltIn().log("Url={} and parameters={}".format(url, parameters))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url, params=parameters, headers=headers)
            if response.status_code != 200:
                BuiltIn().log_to_console("To get VOD screen we send GET "
                                         "to %s?language=%s&profileId=%s&optIn=%s&customerId=%s"
                                         % (url, self.language, opt_in,
                                            self.master_profile_id,
                                            self.master_customer_id))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        if not return_json:
            return response.text
        return response

    def get_grid_id(self, root_id, crid_list, is_grid_id, opt_in):
        """A function to return the vod screen for a single VOD asset.
        :param root_id: root key of vod structure provided by Jenkins
        :param crid_list: list  of crid ids of vod folder to display
        :param isGridId : gridId check in collections
        :param opt_in: optIn status of the customer, provided by Jenkins

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        for crid in crid_list:
            url = "%s/v2/vodscreen/%s/%s" % (self.basepath, root_id, crid)
            parameters = {'language': self.language, 'optIn': opt_in,
                          'profileId': self.master_profile_id,
                          'customerId': self.master_customer_id}
            BuiltIn().log("Url={} and parameters={}".format(url, parameters))
            try:
                BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                            urllib.parse.urlparse(url).path)
            except RobotNotRunningError:
                pass

            try:
                response = requests.get(url, params=parameters)
                if response.status_code != 200:
                    BuiltIn().log_to_console("To get VOD screen we send GET to %s?language=%s"
                                             "&profileId=%s&optIn=%s&customerId=%s"
                                             % (url, self.language, opt_in,
                                                self.master_profile_id,
                                                self.master_customer_id))
                elif response.status_code == 200:
                    collections = response.json()['collections']
                    BuiltIn().log(response.json()['title'])
                    grid_id = None
                    for collection in collections:
                        try:
                            if is_grid_id:
                                grid_id = collection['gridLink']['id']
                            else:
                                grid_id = collection['id']
                        except KeyError:
                            pass
                        if grid_id is not None:
                            break
                    if grid_id is not None:
                        break
            except (requests.exceptions.ConnectionError, socket.gaierror) as err:
                print(("Could not send GET %s due to %s" % (url, err)))
                response = failed_response_data("GET", url, None, err)
        return response, grid_id

    def get_vod_detailscreen(self, crid):
        """A function to return the detailed metadata for a single VOD asset.
        :param crid: crid of vod folder to display
        :param asset_type: asset asset type for detail request [vod]

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        url = "%s/v2/detailscreen/%s" % (self.basepath, crid)
        parameters = {'language': self.language,
                      'profileId': self.master_profile_id,
                      'customerId': self.master_customer_id}
        BuiltIn().log("Url={} and Parameters={}".format(url, parameters))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url, params=parameters)
            if response.status_code != 200:
                BuiltIn().log_to_console(
                    "\nTo get VOD detailscreen we send GET "
                    "to %s?language=%s&profileId=%s&customerId=%s"
                    "\nStatus code %s . Reason %s"
                    % (url, self.language, self.master_profile_id,
                       self.master_customer_id, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

    def get_detailscreen(self, crid):
        """A function to return the detailed metadata for a single VOD asset.
        :param crid: crid of vod folder to display

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        url = "%s/v2/detailscreen/%s" % (self.basepath, crid)
        parameters = {'language': self.language,
                      'profileId': self.master_profile_id,
                      'customerId': self.master_customer_id}
        BuiltIn().log("Url={} and parameters={}".format(url, parameters))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url, params=parameters)
            if response.status_code != 200:
                BuiltIn().log_to_console(
                    "\nTo get VOD detailscreen we send GET "
                    "to %s?language=%s&profileId=%s&customerId=%s"
                    "\nStatus code %s . Reason %s"
                    % (url, self.language, self.master_profile_id,
                       self.master_customer_id, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

    def get_vod_mostrelevantepisode(self, crid, vod_type):
        """A function to return the most relevant episode metadata for a single Serie VOD asset.

        :param crid: crid of Series vod to display most relevant episode
        :param vod_type: a string value to specify the type of VOD asset, e.g. "SERIRS".

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        url = "%s/v2/%s" % (self.basepath, "mostrelevantepisode")
        parameters = {'country': self.country,
                      'language': self.language,
                      'profileId': self.master_profile_id}
        if 'SERIES' in vod_type:
            parameters.update({'showId': crid})
        else:
            parameters.update({'seasonId': crid})
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url, params=parameters)
            if response.status_code != 200:
                BuiltIn().log_to_console("\nTo get_vod_mostrelevantepisode we send GET to %s"
                                         "\nParameters:\n%s\nStatus code %s . Reason %s"
                                         % (url, parameters, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

    def get_vod_gridscreen(self, root_id, crid, opt_in, return_json=True):
        """A function to return the gridscreen for a single VOD node.
        :param root_id: root key of vod structure provided by Jenkins
        :param crid: crid of vod folder to display
        :param opt_in: optIn status of the customer, provided by Jenkins

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        url = "%s/v2/gridscreen/%s/%s" % (self.basepath, root_id, crid)
        parameters = {'language': self.language, 'optIn': opt_in,
                      'profileId': self.master_profile_id,
                      'customerId': self.master_customer_id}
        BuiltIn().log("Url={} and parameters={}".format(url, parameters))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url, params=parameters)
            if response.status_code != 200:
                BuiltIn().log_to_console("\nTo get_vod_gridscreen we send GET to %s"
                                         "\nParameters:\n%s\nStatus code %s . Reason %s"
                                         % (url, parameters, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)

        if not return_json:
            return response.text
        return response

    def get_vod_service_info(self):
        """A method sends GET request to get the information about VOD Microservice
        A text of Session Microservice response is a json string.

        :return: an HTTP response instance
        """
        url = "%s/info" % self.basepath
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url)
            if response.status_code != 200:
                BuiltIn().log_to_console("\nTo get_vod_gridscreen we send GET to %s"
                                         "\nStatus code %s . Reason %s"
                                         % (url, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return  response

    def get_vod_series_detail(self, crid):

        """A function to return the detailed metadata for a Series asset.
        :param crid: crid of vod folder to display

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        url = "%s/v2/seriesdetail/%s" % (self.basepath, crid)
        parameters = {'language': self.language,
                      'profileId': self.master_profile_id,
                      'customerId': self.master_customer_id}
        BuiltIn().log("Url={} and parameters={}".format(url, parameters))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url, params=parameters)
            if response.status_code != 200:
                BuiltIn().log_to_console("\nTo get_vod_series_detail we send GET to %s"
                                         "\nParameters:\n%s\nStatus code %s . Reason %s"
                                         % (url, parameters, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

    def get_vod_rentals(self):
        """A function to return the VOD rental assets.
        :return: result of requests.get() or failed_response_data() if request failed.
        """
        url = "%s/v2/rentals" % self.basepath
        parameters = {'country': self.country, 'language': self.language,
                      'profileId': self.master_profile_id}
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url, params=parameters)
            if response.status_code != 200:
                BuiltIn().log_to_console("\nTo get_vod_rentals we send GET to %s"
                                         "\nParameters:\n%s\nStatus code %s . Reason %s"
                                         % (url, parameters, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

    def get_rental_assets(self):
        """A function to return the rental assets
        :return: result of requests.get() or failed_response_data() if request failed.
        """
        url = "%s/v2/rentals" % self.basepath
        parameters = {'language': self.language}
        headers = {"x-cus": self.master_customer_id, "x-dev": self.cpe_id}
        BuiltIn().log("Url={} and parameters={} and headers={}".format
                      (url, parameters, headers))

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url, params=parameters, headers=headers)
            if response.status_code != 200:
                BuiltIn().log_to_console("\nTo get_rental_assets we send GET to %s"
                                         "\nParameters:%s\nHeaders:%s\nStatus code %s . Reason %s"
                                         % (url, parameters, headers, response.status_code,
                                            response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

    def get_vod_tilescreen(self, root_id, crid, opt_in):
        """A function to return the gridscreen for a single VOD node.
        :param root_id: root key of vod structure provided by Jenkins
        :param crid: crid of vod folder to display
        :param opt_in: optIn status of the customer, provided by Jenkins

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        url = "%s/v2/tilescreen/%s/%s" % (self.basepath, root_id, crid)
        parameters = {'country': self.country, 'language': self.language,
                      'optIn': opt_in, 'profileId': self.master_profile_id}
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url, params=parameters)
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

    def get_vod_gridoptions(self, crid, opt_in, genre_crid=True):
        """A function to return the gridoptions for a single VOD node.
        :param crid: crid of vod folder to display
        :param opt_in: optIn status of the customer, provided by Jenkins
        :param genre_crid: True if provided crid is for a genre grid screen

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        url = "%s/v2/gridoptions/%s" % (self.basepath, crid)
        parameters = {'country': self.country, 'language': self.language,
                      'optIn': opt_in, 'profileId': self.master_profile_id,
                      'genreCrid': genre_crid}
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url, params=parameters)
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        return response

    def get_vod_crid(self, vod_structure, root_id, screen_layout="Collection",
                     collection_type="BasicCollection", asset_type="ASSET",
                     is_rented=False, is_adult=False):
        """A function to return the crid id for a sVOD asset.
        :param vod_structure: Structure of the VOD returned by get_vod_structure function.
        :param root_id: root_id of the vod structure.
        :param screen_layout: Type of screen => Collection or Tile
        :param collection_type: Type of collection => BasicCollection/TileCollection/GridCollection
        :param asset_type: Type of asset => ASSET(Movies)/SERIES/SEASON/EPISODE.
        :param is_rented: Arguments to filter out rented/not rented assets.
        :param is_adult: True : Adult, False : Not Adult

        :return: returns the crid Id for the requested arguments.
        """

        crid_id = None
        tvod_list = ["minPrice", "minPriceDisplay", "price", "priceDisplay"]
        try:
            for screens in vod_structure['screens']:
                BuiltIn().log("Screen Layout Name : {}".format(screens['title']))
                response = VodServiceRequests.get_vod_screen(self, root_id, screens['id'], True)
                response_data = json.loads(response.text)
                screen_layout = screen_layout.lower()
                if screen_layout == "collection" and \
                        response_data['screenLayout'].lower() == screen_layout:
                    for collection in response_data['collections']:
                        collection_type = collection_type.lower()
                        if collection_type == "basiccollection" and \
                                collection['collectionLayout'].lower() == collection_type:
                            for item in collection['items']:
                                if item['type'].upper() == asset_type.upper() and \
                                        is_adult == item['isAdult'] and \
                                        ((not [value for value in tvod_list
                                               if value in item]) == is_rented):
                                    BuiltIn().log("Collection layout Name : {}".
                                                  format(collection['title']))
                                    crid_id = item['id']
                                    break
                            if crid_id:
                                break
                        elif collection_type == "gridcollection" and \
                                collection['collectionLayout'].lower() == collection_type:
                            try:
                                grid_id = collection['gridLink']['id']
                            except KeyError:
                                continue
                            response_grid = VodServiceRequests.\
                                get_vod_gridscreen(self, root_id, grid_id, True)
                            response_grid_data = json.loads(response_grid.text)
                            for item in response_grid_data['items']:
                                if item['type'].upper() == asset_type.upper() and \
                                        is_adult == item['isAdult'] and \
                                        ((not [value for value in tvod_list
                                               if value in item]) == is_rented):
                                    BuiltIn().log("Collection layout Name : {}".
                                                  format(collection['title']))
                                    crid_id = item['id']
                                    break
                            if crid_id:
                                break
                        elif collection_type == "tilecollection" and \
                                collection['collectionLayout'].lower() == collection_type:
                            for item in collection['items']:
                                try:
                                    BuiltIn().log("Tile Name : {}".format(item['title']))
                                    tile_crid_id = item['gridLink']['id']
                                except KeyError:
                                    continue
                                response_tile = VodServiceRequests.\
                                    get_vod_gridscreen(self, root_id, tile_crid_id, True)
                                response_tile_data = json.loads(response_tile.text)
                                for asset in response_tile_data['items']:
                                    if asset['type'].upper() == asset_type.upper() and\
                                            is_adult == asset['isAdult'] and \
                                            ((not [value for value in tvod_list
                                                   if value in asset]) == is_rented):
                                        BuiltIn().log("Collection layout Name : {}".
                                                      format(collection['title']))
                                        crid_id = asset['id']
                                        break
                                if crid_id:
                                    break
                elif screen_layout == "tile" and \
                        response_data['screenLayout'].lower() == screen_layout:
                    BuiltIn().log("Screen Title : {}".format(response_data['title']))
                    crid_id = response_data['id']

                else:
                    continue

                if crid_id:
                    break
        except Exception:
            raise Exception(BuiltIn().log("Neither Collection Nor Tile Screen Found!!!"))
        return crid_id

    def get_basic_collection_vod_crid(self, vod_structure, root_id, asset_type="ASSET",
                                      is_tvod=False, is_adult=False):
        """A function to return the crid id for a VOD asset.
        :param vod_structure: Structure of the VOD returned by get_vod_structure function.
        :param root_id: root_id of the vod structure.
        :param asset_type: Type of asset => ASSET(Movies)/SERIES/SEASON/EPISODE.
        :param is_tvod: True -> Unrented VOD asset, False -> SVOD.
        :param is_adult: True : Adult, False : Not Adult

        :return: returns the crid Id for the requested arguments.
        """
        crid_id = None
        tvod_list = ["minPrice", "minPriceDisplay", "price", "priceDisplay"]
        try:
            screens = vod_structure['screens']
            for screen in screens:
                BuiltIn().log("Screen Layout Name : {}".format(screen['title']))
                response_data = self.get_vod_screen(root_id, screen['id'], True, False)
                response_data = json.loads(response_data)
                try:
                    if response_data['screenLayout'].lower() == "collection":
                        for collection in response_data['collections']:
                            if collection['collectionLayout'].lower() == "basiccollection":
                                for item in collection['items']:
                                    if item['type'].upper() == asset_type.upper() and \
                                            is_adult == item['isAdult'] and \
                                            ((not [value for value in tvod_list
                                                   if value in item]) != is_tvod):
                                        BuiltIn().log("Collection layout Name : {}".
                                                      format(collection['title']))
                                        crid_id = item['id']
                                        break
                                if crid_id:
                                    break
                            else:
                                continue
                    else:
                        continue
                except KeyError:
                    raise KeyError("Error in VOD Screen Data")
                if crid_id:
                    break
        except KeyError:
            raise KeyError("Error in VOD Structure data")
        return crid_id

    def get_grid_collection_vod_crid(self, vod_structure, root_id, asset_type="ASSET",
                                     is_tvod=False, is_adult=False):
        """A function to return the crid id for a VOD asset.
        :param vod_structure: Structure of the VOD returned by get_vod_structure function.
        :param root_id: root_id of the vod structure.
        :param asset_type: Type of asset => ASSET(Movies)/SERIES/SEASON/EPISODE.
        :param is_tvod: True -> Unrented VOD asset, False -> SVOD.
        :param is_adult: True : Adult, False : Not Adult

        :return: returns the crid Id for the requested arguments.
        """
        crid_id = None
        tvod_list = ["minPrice", "minPriceDisplay", "price", "priceDisplay"]
        try:
            screens = vod_structure['screens']
            for screen in screens:
                BuiltIn().log("Screen Layout Name : {}".format(screen['title']))
                response_data = self.get_vod_screen(root_id, screen['id'], True, False)
                response_data = json.loads(response_data)
                try:
                    if response_data['screenLayout'].lower() == "collection":
                        for collection in response_data['collections']:
                            if collection['collectionLayout'].lower() == "gridcollection":
                                try:
                                    grid_id = collection['gridLink']['id']
                                except KeyError:
                                    continue
                                response_grid_data = self.get_vod_gridscreen(root_id,
                                                                             grid_id, True, False)
                                response_grid_data = json.loads(response_grid_data)
                                for item in response_grid_data['items']:
                                    if item['type'].upper() == asset_type.upper() and \
                                            is_adult == item['isAdult'] and \
                                            ((not [value for value in tvod_list
                                                   if value in item]) != is_tvod):
                                        BuiltIn().log("Collection layout Name : {}".
                                                      format(collection['title']))
                                        crid_id = item['id']
                                        break
                                if crid_id:
                                    break
                            else:
                                continue
                    else:
                        continue
                except KeyError:
                    raise KeyError("Error in VOD Screen/Collection Data")
                if crid_id:
                    break
        except KeyError:
            raise KeyError("Error in VOD Structure data")
        return crid_id

    def get_tile_collection_vod_crid(self, vod_structure, root_id, asset_type="ASSET",
                                     is_tvod=False, is_adult=False):
        """A function to return the crid id for a VOD asset.
        :param vod_structure: Structure of the VOD returned by get_vod_structure function.
        :param root_id: root_id of the vod structure.
        :param asset_type: Type of asset => ASSET(Movies)/SERIES/SEASON/EPISODE.
        :param is_tvod: True -> Unrented VOD asset, False -> SVOD.
        :param is_adult: True : Adult, False : Not Adult

        :return: returns the crid Id for the requested arguments.
        """
        crid_id = None
        tvod_list = ["minPrice", "minPriceDisplay", "price", "priceDisplay"]
        try:
            screens = vod_structure['screens']
            for screen in screens:
                BuiltIn().log("Screen Layout Name : {}".format(screen['title']))
                response_data = self.get_vod_screen(root_id, screen['id'], True, False)
                response_data = json.loads(response_data)
                try:
                    if response_data['screenLayout'].lower() == "collection":
                        for collection in response_data['collections']:
                            if collection['collectionLayout'].lower() == "tilecollection":
                                for item in collection['items']:
                                    try:
                                        BuiltIn().log("Tile Name : {}".format(item['title']))
                                        tile_crid_id = item['gridLink']['id']
                                    except KeyError:
                                        continue
                                    response_tile = VodServiceRequests. \
                                        get_vod_gridscreen(self, root_id, tile_crid_id, True, False)
                                    response_tile_data = json.loads(response_tile)
                                    for asset in response_tile_data['items']:
                                        if asset['type'].upper() == asset_type.upper() and \
                                                is_adult == asset['isAdult'] and \
                                                ((not [value for value in tvod_list
                                                       if value in item]) != is_tvod):
                                            BuiltIn().log("Collection layout Name : {}".
                                                          format(collection['title']))
                                            crid_id = item['id']
                                            break
                                    if crid_id:
                                        break
                            else:
                                continue
                    else:
                        continue
                except KeyError:
                    raise KeyError("Error in VOD Screen Data")
                if crid_id:
                    break
        except KeyError:
            raise KeyError("Error in VOD Structure data")
        return crid_id

    def get_tile_screen_crid(self, vod_structure, root_id):
        """A function to return crid Id for Tile Screen
        :param vod_structure: Structure of the VOD returned by get_vod_structure function.
        :param root_id: root_id of the vod structure.

        :return: returns the crid Id for the requested arguments.
        """
        crid_id = None
        try:
            screens = vod_structure['screens']
            for screen in screens:
                BuiltIn().log("Screen Layout Name : {}".format(screen['title']))
                response_data = self.get_vod_screen(root_id, screen['id'], True, False)
                response_data = json.loads(response_data)
                try:
                    if response_data['screenLayout'].lower() == "tile":
                        BuiltIn().log("Screen Title : {}".format(response_data['title']))
                        crid_id = response_data['id']
                    else:
                        continue

                    if crid_id:
                        break
                except KeyError:
                    raise KeyError("Tile Screen Not Found")
        except KeyError:
            raise KeyError("Error in Fetching Vod Structure")
        return crid_id

    def get_content_url(self, section, screen_type, provider, sort_type):
        """
            This method retrieves url of first item of content_type
            from vod service from given section
        """
        url = None
        VOD_SERVICE_URL = "%s/v2/vodscreen/" % self.basepath
        VOD_SERVICE_DETAILS_GRIDSCREEN_URL = "%s/v2/gridscreen/" % self.basepath
        VOD_SERVICE_DETAILS_TILESCREEN_URL = "%s/v2/tilescreen/" % self.basepath
        vod_structure = self.get_vod_structure(self.fallback_root_id)
        vod_structure = json.loads(vod_structure.text)
        section_crid = None
        for screen in vod_structure['screens']:
            if screen['title'].upper() == section.upper():
                section_crid = screen['id']
        if screen_type == 'collection':
            if not provider:
                url = "{}{}/{}?language={}" \
                      "&profileId={}&optIn=true&" \
                      "sortType={}" \
                    .format(VOD_SERVICE_URL, self.fallback_root_id,
                            section_crid, self.language, self.master_profile_id, sort_type)
            else:
                url = "{}{}/{}?language={}" \
                      "&profileId={}&optIn=true" \
                      "&sortType={}" \
                    .format(VOD_SERVICE_URL, self.fallback_root_id,
                            section_crid, self.language, self.master_profile_id, sort_type)
        if screen_type in ['editorial_grid', 'grid']:
            if not provider:
                url = "{}{}/{}?country={}&language={}&profileId={}" \
                      "&customerId={}&pagingOffset=0&pagingSize=49&" \
                      "optIn=true&sortType={}" \
                    .format(VOD_SERVICE_DETAILS_GRIDSCREEN_URL,
                            self.fallback_root_id, section_crid,
                            self.country, self.language, self.master_profile_id,
                            self.master_customer_id,
                            sort_type)
            else:
                url = "{}{}/{}?country={}&language={}&profileId={}" \
                      "&customerId={}&pagingOffset=0&pagingSize=49&" \
                      "optIn=true&sortType={}" \
                    .format(VOD_SERVICE_DETAILS_GRIDSCREEN_URL,
                            self.fallback_root_id,
                            section_crid,
                            self.country, self.language, self.master_profile_id,
                            self.master_customer_id,
                            sort_type)
        if provider is True:
            if screen_type == 'Tile':
                url = "{}{}/{}?country={}&language={}&profileId={}" \
                      "&customerId={}&pagingOffset=0&pagingSize=49&" \
                      "optIn=true&sortType={}" \
                    .format(VOD_SERVICE_DETAILS_TILESCREEN_URL,
                            self.fallback_root_id,
                            section_crid,
                            self.country, self.language, self.master_profile_id,
                            self.master_customer_id,
                            sort_type)
        return url

    def get_content(self, section, content_type, count='single',
                    screen_type='collection', provider=None,
                    sort_type='popularity', promotional_tile=True):
        """
            This method retrieves
            by default (count='single') first item
            or list (count='all') of items
            of given content_type from vod service from given section
        """
        url = self.get_content_url(section, screen_type, provider,
                                   sort_type)
        url = str(url)
        headers = {'x-cus':self.master_customer_id, 'x-dev': self.cpe_id}
        BuiltIn().log("Url={} and Headers={}".format(url, headers))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass
        try:
            response = requests.get(url, headers=headers)
            print(response)
            if response.status_code != 200:
                BuiltIn().log_to_console("To get VOD screen we send GET "
                                         "to %s"
                                         % (url))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        url_response = response.json()
        return self.parse_content(url_response, section,
                                  content_type, count,
                                  screen_type, promotional_tile)

    @staticmethod
    def parse_content(url_response, section, content_type,
                      count, screen_type, promotional_tile):
        """
            This method parses url response for method get_content
        """
        content = None
        content_list = []
        assets = []
        print("url:", url_response)
        if screen_type == 'collection':
            collections = url_response['collections']
            if promotional_tile:
                collections = [item['items'] for item in collections
                               if 'items' in item]
            else:
                collections = [item['items'] for item in collections
                               if ('items' in item and
                                   item['collectionLayout'] != 'PromotionCollection')]
            for items_list in collections:
                if section == 'Passion':
                    assets.extend([item for item in items_list
                                   if 'type' in item and 'isAdult' in item])
                    for item in assets:
                        if item['type'] == content_type and item['isAdult']:
                            content_list.append(item)
                else:
                    assets.extend([item for item in items_list
                                   if 'type' in item])
                    for item in assets:
                        if item['type'] == content_type:
                            if item not in content_list:
                                content_list.append(item)
        if screen_type in ['editorial_grid', 'grid', 'Sections']:
            items = url_response['items']
            for item in items:
                if section == 'Passion':
                    if item['type'] == content_type and item['isAdult']:
                        content_list.append(item)
                else:
                    if item['type'] == content_type:
                        content_list.append(item)
        if screen_type == 'Tile' and section == 'Providers':
            if url_response['screenLayout'] == screen_type:
                content_list.append(url_response['items'])
        if content_list:
            if count == 'single':
                content = content_list[0]
            elif count == 'all':
                content = content_list
        return content

    def get_asset_by_crid(self, crid):
        """A function to return the detailed metadata for a single VOD asset.
        :param crid: crid of vod folder to display
        :param asset_type: asset asset type for detail request [vod]

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        url = "%s/v2/detailscreen/%s" % (self.basepath, crid)
        parameters = {'language': self.language,
                      'profileId': self.master_profile_id,
                      'customerId': self.master_customer_id}
        headers = {'x-cus': self.master_customer_id, 'x-dev': self.cpe_id}
        BuiltIn().log("Url={} and Parameters={} and hearders={}".format(url, parameters, headers))
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url, params=parameters, headers=headers)
            if response.status_code != 200:
                BuiltIn().log_to_console(
                    "\nTo get VOD detailscreen we send GET "
                    "to %s?language=%s&profileId=%s&customerId=%s"
                    "\nStatus code %s . Reason %s"
                    % (url, self.language, self.master_profile_id,
                       self.master_customer_id, response.status_code, response.reason))
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send GET %s due to %s" % (url, err)))
            response = failed_response_data("GET", url, None, err)
        print(response.json())
        return response.json()


def check_most_watched_toplist(response):
    """A function to check that the "Most Watched" collection is of type "TopList".
    :param response: response containg a VOD collections screenlayout.

    :Validation Point: "Most Watched" content Type is "TopList" return 0
    :Validation Point: "Most Watched" content Type is NOT "TopList" return 1
    :Validation Point: "Most Watched" collection not found return 2
    """
    json_response = json.loads(response.text)
    for collection in json_response['collections']:
        # We use "nl" language in request
        if "meest bekeken" in collection['title'].lower():
            if collection['contentType'] == "TopList":
                return 0
            return 1
    return 2


def check_collection_type_present(response, collection_type):
    """A function to check that the response contains at least one collection of {type}
    :param response: response containing a VOD collections screenlayout.
    :param collection_type: type of collection to validate

    :Validation Point: contentType of {type} found - return 0
    :Validation Point: contentType of {type} NOT found - return 1
    """
    json_response = json.loads(response.text)
    for collection in json_response['collections']:
        if collection_type in collection['contentType']:
            return 0
    return 1


def get_asset_crid(response, node_name):
    """A function to extract the first asset from the "nodename" catalogue
    :param response: response containing a VOD collections screenlayout.
    :param node_name: name of the collection to extract the crid from
    """
    node_name = node_name.lower()
    json_response = json.loads(response.text)
    for collection in json_response['collections']:
        if node_name in collection['title'].lower():
            crid = collection['items'][0]['id']
            return crid
    return ""


class Keywords(object):
    """"Keywords visible in Robot Framework"""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @staticmethod
    def get_vod_structure(conf, country, language, customer_id, profile_id, root_id):
        """A keyword to return the VOD structure.
        :param conf: config file for labs
        :param country: the country provided by Jenkins
        :param language: the language provided by Jenkins
        :param customer_id: the customer Id returned from Traxis
        :param profile_id: the customer profile Id returned from personalization service
        :param root_id: root key of vod structure provided by Jenkins

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        vs_obj = VodServiceRequests(conf, country, language, customer_id, profile_id)
        response = vs_obj.get_vod_structure(root_id)
        return response

    @staticmethod
    def get_vod_structure_by_crid(conf, country, language, customer_id, profile_id,
                                  root_id, crid_id):
        """A keyword to return the VOD structure.
        :param conf: config file for labs
        :param country: the country provided by Jenkins
        :param language: the language provided by Jenkins
        :param customer_id: the customer Id returned from Traxis
        :param profile_id: the customer profile Id returned from personalization service
        :param crid_id: the crid id of the screen for which structure is to be found
        :param root_id: root key of vod structure provided by Jenkins

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        vs_obj = VodServiceRequests(conf, country, language, customer_id, profile_id)
        response = vs_obj.get_vod_structure_by_crid(root_id, crid_id)
        return response

    @staticmethod
    def get_vod_context_menu(conf, country, language, customer_id, profile_id, root_id, opt_in):
        """A keyword to return the context menu for a single VOD node.
        :param conf: config file for labs
        :param country: the country provided by Jenkins
        :param language: the language provided by Jenkins
        :param customer_id: the customer Id returned from Traxis
        :param profile_id: the customer profile Id returned from personalization service
        :param root_id: root key of vod structure provided by Jenkins
        :param opt_in: optIn status of the customer, provided by Jenkins

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        vs_obj = VodServiceRequests(conf, country, language, customer_id, profile_id)
        response = vs_obj.get_vod_context_menu(root_id, opt_in)
        return response

    @staticmethod
    def get_vod_screen(conf, country, language, customer_id, profile_id, root_id, crid, opt_in):
        """A keyword to return the vod screen for a single VOD node.
        :param conf: config file for labs
        :param country: the country provided by Jenkins
        :param language: the language provided by Jenkins
        :param customer_id: the customer Id returned from Traxis
        :param profile_id: the customer profile Id returned from personalization service
        :param root_id: root key of vod structure provided by Jenkins
        :param crid: crid of vod folder to display
        :param opt_in: optIn status of the customer, provided by Jenkins

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        vs_obj = VodServiceRequests(conf, country, language, customer_id, profile_id)
        response = vs_obj.get_vod_screen(root_id, crid, opt_in)
        return response

    @staticmethod
    def get_grid_id(conf, country, language, customer_id, profile_id, root_id, crid_list,
                    is_grid_id, opt_in):
        """A keyword to return the vod screen for a single VOD node.
        :param conf: config file for labs
        :param country: the country provided by Jenkins
        :param language: the language provided by Jenkins
        :param customer_id: the customer Id returned from Traxis
        :param profile_id: the customer profile Id returned from personalization service
        :param root_id: root key of vod structure provided by Jenkins
        :param crid_list: list  of crid ids of vod folder to display
        :param isGridId : gridId check in collections
        :param opt_in: optIn status of the customer, provided by Jenkins

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        vs_obj = VodServiceRequests(conf, country, language, customer_id, profile_id)
        response = vs_obj.get_grid_id(root_id, crid_list, is_grid_id, opt_in)
        return response

    @staticmethod
    def get_vod_detailscreen(conf, country, language, customer_id, profile_id, crid):
        """A keyword to return the detailed metadata for a single VOD asset.
        :param conf: config file for labs
        :param country: the country provided by Jenkins
        :param language: the language provided by Jenkins
        :param customer_id: the customer Id returned from Traxis
        :param profile_id: the customer profile Id returned from personalization service
        :param crid: crid of vod folder to display

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        vs_obj = VodServiceRequests(conf, country, language, customer_id, profile_id)
        response = vs_obj.get_vod_detailscreen(crid)
        return response

    @staticmethod
    def get_detailscreen(conf, country, language, customer_id, profile_id, crid):
        """A keyword to return the detailed metadata for a single VOD asset.
        :param conf: config file for labs
        :param country: the country provided by Jenkins
        :param language: the language provided by Jenkins
        :param customer_id: the customer Id returned from Traxis
        :param profile_id: the customer profile Id returned from personalization service
        :param crid: crid of vod folder to display

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        vs_obj = VodServiceRequests(conf, country, language, customer_id, profile_id)
        response = vs_obj.get_detailscreen(crid)
        return response

    @staticmethod
    def get_vod_mostrelevantepisode(conf, country, language, customer_id, profile_id,
                                    crid, vod_type):
        """A keyword to return the most relevant episode metadata for a single Serie VOD asset.
        :param conf: config file for labs
        :param country: the country provided by Jenkins
        :param language: the language provided by Jenkins
        :param customer_id: the customer Id returned from Traxis
        :param profile_id: the customer profile Id returned from personalization service
        :param crid: crid of Series vod to display most relevant episode
        :param vod_type: a string value to specify the type of VOD asset, e.g. "SERIRS".

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        vs_obj = VodServiceRequests(conf, country, language, customer_id, profile_id)
        response = vs_obj.get_vod_mostrelevantepisode(crid, vod_type)
        return response

    @staticmethod
    def get_vod_gridscreen(conf, country, language, customer_id, profile_id, root_id,
                           crid, opt_in):
        """A keyword to return the gridscreen for a single VOD node.
        :param conf: config file for labs
        :param country: the country provided by Jenkins
        :param language: the language provided by Jenkins
        :param customer_id: the customer Id returned from Traxis
        :param profile_id: the customer profile Id returned from personalization service
        :param root_id: root key of vod structure provided by Jenkins
        :param crid: crid of vod folder to display
        :param opt_in: optIn status of the customer, provided by Jenkins

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        vs_obj = VodServiceRequests(conf, country, language, customer_id, profile_id)
        response = vs_obj.get_vod_gridscreen(root_id, crid, opt_in)
        return response

    @staticmethod
    def check_most_watched_toplist(response):
        """A keyword to check that the "Most Watched" collection is of type "TopList".
        :param response: response containg a VOD collections screenlayout

        :Validation Point: "Most Watched" content Type is "TopList" return 0
        :Validation Point: "Most Watched" content Type is NOT "TopList" return 1
        """
        return_code = check_most_watched_toplist(response)
        return return_code

    @staticmethod
    def check_collection_type_present(response, collection_type):
        """A keyword to check that the response contains at least one collection of {type}
        :param response: response containing a VOD collections screenlayout.
        :param type: type of collection to validate

        :Validation Point: contentType of {type} found - return 0
        :Validation Point: contentType of {type} NOT found - return 1
        """
        return_code = check_collection_type_present(response, collection_type)
        return return_code

    @staticmethod
    def get_asset_crid(response, node_name):
        """A keyword to extract item 0 crid from a given VOD screen and nodename
        :param response: response containing a VOD collections screenlayout.
        :param node_name: name of the catalogue to pull the crid from

        :return: a string - crid value.
        """
        crid = get_asset_crid(response, node_name)
        return crid


    @staticmethod
    def get_vod_service_info(conf, country, language, customer_id, profile_id):
        """A keyword to return the VOD structure.
        :param conf: config file for labs
        :param country: the country provided by Jenkins
        :param language: the language provided by Jenkins
        :param customer_id: the customer Id returned from Traxis
        :param profile_id: the customer profile Id returned from personalization service
        :param root_id: root key of vod structure provided by Jenkins

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        vs_obj = VodServiceRequests(conf, country, language, customer_id, profile_id)
        response = vs_obj.get_vod_service_info()
        return response

    @staticmethod
    def get_vod_series_detail(conf, country, language, customer_id, profile_id, crid):
        """A keyword to return the detailed metadata for a series VOD asset.
        :param conf: config file for labs
        :param country: the country provided by Jenkins
        :param language: the language provided by Jenkins
        :param customer_id: the customer Id returned from Traxis
        :param profile_id: the customer profile Id returned from personalization service
        :param crid: crid of vod folder to display

        :return: result of requests.get() or failed_response_data() if request failed.
        """

        vs_obj = VodServiceRequests(conf, country, language, customer_id, profile_id)
        response = vs_obj.get_vod_series_detail(crid)
        return response

    @staticmethod
    def get_rental_assets(conf, country, language, customer_id, profile_id):
        """A keyword to return the VOD structure.
        :param conf: config file for labs
        :param country: the country provided by Jenkins
        :param language: the language provided by Jenkins
        :param customer_id: the customer Id returned from Traxis
        :param profile_id: the customer profile Id returned from personalization service

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        vs_obj = VodServiceRequests(conf, country, language, customer_id, profile_id)
        response = vs_obj.get_rental_assets()
        return response

    @staticmethod
    def get_vod_rentals(conf, country, language, customer_id, profile_id):
        """A keyword to return the VOD structure.
        :param conf: config file for labs
        :param country: the country provided by Jenkins
        :param language: the language provided by Jenkins
        :param customer_id: the customer Id returned from Traxis
        :param profile_id: the customer profile Id returned from personalization service

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        vs_obj = VodServiceRequests(conf, country, language, customer_id, profile_id)
        response = vs_obj.get_vod_rentals()
        return response

    @staticmethod
    def get_vod_tilescreen(conf, country, language, customer_id, profile_id, root_id,
                           crid, opt_in):
        """A keyword to return the vod screen for a single VOD node.
        :param conf: config file for labs
        :param country: the country provided by Jenkins
        :param language: the language provided by Jenkins
        :param customer_id: the customer Id returned from Traxis
        :param profile_id: the customer profile Id returned from personalization service
        :param root_id: root key of vod structure provided by Jenkins
        :param crid: crid of vod folder to display
        :param opt_in: optIn status of the customer, provided by Jenkins

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        vs_obj = VodServiceRequests(conf, country, language, customer_id, profile_id)
        response = vs_obj.get_vod_tilescreen(root_id, crid, opt_in)
        return response

    @staticmethod
    def get_vod_gridoptions(conf, country, language, customer_id, profile_id, crid, opt_in,
                            genre_crid=True):
        """A keyword to return the vod screen for a single VOD node.
        :param conf: config file for labs
        :param country: the country provided by Jenkins
        :param language: the language provided by Jenkins
        :param customer_id: the customer Id returned from Traxis
        :param profile_id: the customer profile Id returned from personalization service
        :param crid: crid of vod folder to display
        :param opt_in: optIn status of the customer, provided by Jenkins
        :param genre_crid: True if provided crid is for a genre grid screen

        :return: result of requests.get() or failed_response_data() if request failed.
        """
        vs_obj = VodServiceRequests(conf, country, language, customer_id, profile_id)
        response = vs_obj.get_vod_gridoptions(crid, opt_in, genre_crid)
        return response

    @staticmethod
    def get_vod_crid(conf, country, language, customer_id, profile_id, vod_structure, root_id,
                     screen_layout="Collection", collection_type="BasicCollection",
                     asset_type="ASSET", is_rented=False, is_adult=False):
        """A keyword to return the VOD structure.
        :param conf: config file for labs
        :param country: the country provided by Jenkins
        :param language: the language provided by Jenkins
        :param customer_id: the customer Id returned from Traxis
        :param profile_id: the customer profile Id returned from personalization service
        :param vod_structure: Structure of the VOD returned by get_vod_structure function.
        :param root_id: root_id of the vod structure.
        :param screen_layout: Type of screen => Collection or Tile
        :param collection_type: Type of collection => BasicCollection/TileCollection/GridCollection
        :param asset_type: Type of asset => ASSET(Movies)/SERIES/SEASON/EPISODE.
        :param is_rented: Arguments to filter out rented/not rented assets.
        :param is_adult: True : Adult, False : Not Adult

        :return: returns the crid Id for the requested arguments.
        """

        vs_obj = VodServiceRequests(conf, country, language, customer_id, profile_id)
        response = vs_obj.get_vod_crid(vod_structure, root_id, screen_layout,
                                       collection_type, asset_type, is_rented, is_adult)
        return response

    @staticmethod
    def get_basic_collection_vod_crid(conf, country, language, customer_id, profile_id,
                                      vod_structure, root_id,
                                      asset_type="ASSET", is_tvod=False, is_adult=False):
        """A keyword to return the crid id for basic collection asset.
        :param conf: config file for labs
        :param country: the country provided by Jenkins
        :param language: the language provided by Jenkins
        :param customer_id: the customer Id returned from Traxis
        :param profile_id: the customer profile Id returned from personalization service
        :param vod_structure: Structure of the VOD returned by get_vod_structure function.
        :param root_id: root_id of the vod structure.
        :param asset_type: Type of asset => ASSET(Movies)/SERIES/SEASON/EPISODE.
        :param is_tvod: True -> Unrented VOD asset, False -> SVOD.
        :param is_adult: True : Adult, False : Not Adult

        :return: returns the crid Id for the requested arguments.
        """
        vs_obj = VodServiceRequests(conf, country, language, customer_id, profile_id)
        response = vs_obj.get_basic_collection_vod_crid(vod_structure, root_id, asset_type,
                                                        is_tvod, is_adult)
        return response

    @staticmethod
    def get_grid_collection_vod_crid(conf, country, language, customer_id, profile_id,
                                     vod_structure, root_id,
                                     asset_type="ASSET", is_tvod=False, is_adult=False):
        """A keyword to return the crid id for grid collection asset.
        :param conf: config file for labs
        :param country: the country provided by Jenkins
        :param language: the language provided by Jenkins
        :param customer_id: the customer Id returned from Traxis
        :param profile_id: the customer profile Id returned from personalization service
        :param vod_structure: Structure of the VOD returned by get_vod_structure function.
        :param root_id: root_id of the vod structure.
        :param asset_type: Type of asset => ASSET(Movies)/SERIES/SEASON/EPISODE.
        :param is_tvod: True -> Unrented VOD asset, False -> SVOD.
        :param is_adult: True : Adult, False : Not Adult

        :return: returns the crid Id for the requested arguments.
        """
        vs_obj = VodServiceRequests(conf, country, language, customer_id, profile_id)
        response = vs_obj.get_grid_collection_vod_crid(vod_structure, root_id, asset_type,
                                                       is_tvod, is_adult)
        return response

    @staticmethod
    def get_tile_collection_vod_crid(conf, country, language, customer_id, profile_id,
                                     vod_structure, root_id,
                                     asset_type="ASSET", is_tvod=False, is_adult=False):
        """A keyword to return the crid id for tile collection asset.
        :param conf: config file for labs
        :param country: the country provided by Jenkins
        :param language: the language provided by Jenkins
        :param customer_id: the customer Id returned from Traxis
        :param profile_id: the customer profile Id returned from personalization service
        :param vod_structure: Structure of the VOD returned by get_vod_structure function.
        :param root_id: root_id of the vod structure.
        :param asset_type: Type of asset => ASSET(Movies)/SERIES/SEASON/EPISODE.
        :param is_tvod: True -> Unrented VOD asset, False -> SVOD.
        :param is_adult: True : Adult, False : Not Adult

        :return: returns the crid Id for the requested arguments.
        """
        vs_obj = VodServiceRequests(conf, country, language, customer_id, profile_id)
        response = vs_obj.get_tile_collection_vod_crid(vod_structure, root_id, asset_type,
                                                       is_tvod, is_adult)
        return response

    @staticmethod
    def get_tile_screen_crid(conf, country, language, customer_id, profile_id,
                             vod_structure, root_id):
        """A keyword to return the crid id for Tile screen.
        :param conf: config file for labs
        :param country: the country provided by Jenkins
        :param language: the language provided by Jenkins
        :param customer_id: the customer Id returned from Traxis
        :param profile_id: the customer profile Id returned from personalization service
        :param vod_structure: Structure of the VOD returned by get_vod_structure function.
        :param root_id: root_id of the vod structure.

        :return: returns the crid Id for the requested arguments.
        """
        vs_obj = VodServiceRequests(conf, country, language, customer_id, profile_id)
        response = vs_obj.get_tile_screen_crid(vod_structure, root_id)
        return response

    @staticmethod
    def get_content(conf, section, content_type, country, language,
                    profile_id, root_id, customer_id, count='single',
                    screen_type='collection', provider=None,
                    sort_type='popularity', promotional_tile=True):
        """A keyword to return the VOD structure for each tab of VOD.
            :param conf: config file for labs
            :param country: the country provided by Jenkins
            :param language: the language provided by Jenkins
            :param customer_id: the customer Id returned from Traxis
            :param profile_id: the customer profile Id returned from personalization service
            :param promotional_tile: True if promotional tiles are to be considered, False otherwise
            """
        vs_obj = VodServiceRequests(conf, country, language, customer_id, profile_id, root_id)
        response = vs_obj.get_content(section, content_type, count,
                                      screen_type, provider, sort_type, promotional_tile)
        return response

    @staticmethod
    def get_asset_by_crid(conf, crid, country, language, profile_id,
                          customer_id):
        """A keyword to return the deatils of the asset by cridid
            :param conf: config file for labs
            :param country: the country provided by Jenkins
            :param language: the language provided by Jenkins
            :param customer_id: the customer Id returned from Traxis
            :param profile_id: the customer profile Id returned from personalization service
            :return: returns the details of the asset for the requested arguments.
            """
        vs_obj = VodServiceRequests(conf, country, language, customer_id, profile_id)
        response = vs_obj.get_asset_by_crid(crid)
        return response
