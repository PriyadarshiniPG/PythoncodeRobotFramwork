# pylint: disable=C0301
# pylint: disable=C0103
# pylint: disable=W0612
# pylint: disable=R0912
# pylint: disable=fixme
# pylint: disable=too-many-public-methods
# pylint: disable=wrong-import-position
# pylint: disable=wrong-import-order
"""Implementation of IngestionE2E library's keywords for Robot Framework.
Uncomment below block for debug purpose only:
from __future__ import print_function
import sys
try:
    import __builtin__  # Python 2
except ImportError:
    import builtins as __builtin__  # Python 3
from robot.api import logger

def print(*args, **kwargs):
    '''Custom print() function.'''
    sys.__stderr__.write(str(args))
    logger.debug(str(args))
    return __builtin__.print(*args, **kwargs)
"""
import os
import sys
import inspect
import re
import time
import json
import socket
import datetime
from xml.parsers.expat import ExpatError
import pytz
from pytz import reference
from import_file import import_file
import requests
import xmltodict
from robot.libraries.BuiltIn import BuiltIn
currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
lib_dir = os.path.dirname(currentdir)
robot_dir = os.path.dirname(lib_dir)
sys.path.append(robot_dir)
from Libraries.general.keywords import Keywords as general
easy_debug = general.easy_debug
general = general()
from .tools import Tools
from .helpers import E2E
from .health import HealthChecks

current_dir = os.path.dirname(os.path.realpath(__file__))
current_file = os.path.basename(__file__)
mock_data = import_file("%s/../../resources/stages/mock_data/data.py" % current_dir).MOCK_DATA
general = import_file("%s/../general/keywords.py" % current_dir).Keywords()
Fabrix = import_file("%s/../Backend/Fabrix/keywords.py" % current_dir).Keywords()


class Keywords(object):
    """Keywords visible in Robot Framework."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self):
        self.keyword_variables = {}
        self.helpers_variables = {}

    @staticmethod
    @easy_debug
    def call_helper_method(method_name, lab_name, conf, *args):
        """Interface to reach any method from helpers.py file

        :param method_name: name of the method from helpers.py file, string with the same lowercase
         as method named in the file, for example "get_image_size"
        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf_obolab.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf_obolab.py.
        :param args: all arguments what expected by helper method to call
        :return: return value from helper method
        """
        helpers_obj = E2E(lab_name=lab_name, e2e_conf=conf)
        return getattr(helpers_obj, method_name)(*args)

    @staticmethod
    @easy_debug
    def call_tools_method(method_name, lab_name, conf, *args):
        """Interface to reach any method from tools.py file

        :param method_name: name of the method from tools.py file, string with the same lowercase
         as method named in the file, for example "run_ssh_cmd"
        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf_obolab.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf_obolab.py.
        :param args: all arguments what expected by tools method to call
        :return: return value from tools method
        """
        tools_obj = Tools(conf[lab_name])
        return getattr(tools_obj, method_name)(*args)

    @easy_debug
    def log_variables(self, method, namespace):  # pylint: disable=R0801
        """ A method to log to Robot Framework HTML log:
            - file name
            - method name
            - variable name
            - variable type
            - variable value
        Result example:
        "File 'keywords.py' >>> Method 'get_package_name' >>> Variable name 'package'.\
            Type 'str'. Value:
                ts0201_20190314_134718ot"

        :param method: method instance
        :param namespace: local namespace of the method
        """
        # BuiltIn().log_to_console("self.keyword_variables BEFORE: %s" % self.keyword_variables)
        # BuiltIn().log_to_console(method)
        # BuiltIn().log_to_console(namespace)
        printed_variables = general.log_all_variables_name_and_value(
            vars_dictionary=self.keyword_variables, file_name=current_file,
            method=method, namespace=namespace)

        self.keyword_variables = printed_variables
        # BuiltIn().log_to_console("self.keyword_variables AFTER: %s" % self.keyword_variables)

    @easy_debug
    def generate_no_og_offers(self, lab_name, conf, map_dict, crid_name="Random",
                              watch_folder=None, unique=True):
        """A keyword to generate several packages to be picked up by Airflow at once.

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf.py.
        :param map_dict: a dictionary - keys are Jira tickets, values are dicts of package details.
        :param random_offer_id: boolean, is offer id random or not

        :return: a dictionary where keys are jira tickets and values are assets' details.

        :Example:

        >>>map_dict = {
        ...    "HES-14": {"sample_id":
        ...        "/mnt/nfs_watch/Test_Assets/2_UHD_HEVC/10378-big-buck-bunny-hd-4k-3d"},
        ...    "HES-105": {"sample_id":
        ...        "/mnt/nfs_watch/Test_Assets/3_HEVC_720p/49707-hanni-nanni"}
        ... }
        >>>Keywords().generate_no_og_offers("e2esi", E2E_CONF, map_dict)
        {'HES-14': {'sample_id':
                              '/mnt/nfs_watch/Test_Assets/2_UHD_HEVC/10378-big-buck-bunny-hd-4k-3d',
            'offer_id': '2017_11_30-16_28_14-839107',
            'packages': {'TVA_000001_20170824055751.xml': {}},
        'HES-105': {'sample_id': '/mnt/nfs_watch/Test_Assets/3_HEVC_720p/49707-hanni-nanni',
            'offer_id': '2017_11_30-16_29_08-331296',
            'packages': {'TVA_000001_20170802081133.xml': {}}
        }
        """
        result = {}
        e2e_obj = E2E(lab_name=lab_name, e2e_conf=conf, keywords_object=self)

        # try:
        #     movie_type = ticket_details["movie_type"]
        # except KeyError:
        #     movie_type = None

        for jira_ticket_id, ticket_details in list(map_dict.items()):
            try:
                change_image_extension = ticket_details["change_image_extension"]
            except KeyError:
                change_image_extension = None
            e2e_obj.packages = {}
            if not isinstance(unique, bool):
                if "False" in unique:
                    unique = False
                elif "True" in unique:
                    unique = True
                else:
                    raise Exception("Unexpected 'unique value' %s" % unique)

            if "new_time_delta" in list(ticket_details.keys()):
                new_time_delta = ticket_details["new_time_delta"]
            else:
                new_time_delta = None
            if "new_tva_name" in list(ticket_details.keys()):
                new_tva_name = ticket_details["new_tva_name"]
            else:
                new_tva_name = None
            sample_id = general.insure_text(ticket_details["sample_id"]).strip()
            sample_id = general.remove_non_ascii(sample_id)
            e2e_obj.create_no_og_package(src_dir=sample_id, offer_id=crid_name,
                                         folder=watch_folder, unique=unique,
                                         change_image_extension=change_image_extension,
                                         new_time_delta=new_time_delta, new_tva_name=new_tva_name)
            # We use this rule only in robot/ingestion/order_check/single_ingestion.txt
            if "ignore_package_in_watch_folder" in list(ticket_details.keys()):
                ignore_package_in_watch_folder = ticket_details["ignore_package_in_watch_folder"]
            else:
                ignore_package_in_watch_folder = False
            tmp = {"sample_id": ticket_details["sample_id"], "offer_id": e2e_obj.offer_id,
                   "packages": e2e_obj.packages, "error": e2e_obj.error,
                   "expected_dag": ticket_details["expected_dag"],
                   "ignore_package_in_watch_folder": ignore_package_in_watch_folder
                  }
            result.update({"%s" % jira_ticket_id: tmp})
            # result example:
            # {
            #     u'HES-390': {
            #         'offer_id': None,
            #         'packages': {
            #             '2018_08_15-13_01_04-032793': {
            #                 'errors': [],
            #                 'output_tva': '',
            #                 'properties': {},
            #                 'fabrix_asset_id': '',
            #                 'tva': u'/mnt/nfs_watch/Countries/CSI/ToAirflow'
            #                        u'/2018_08_15-13_01_04-032793/TVA_000001_20170802081133.xml',
            #                 'logs_masks': [],
            #                 'adi': ''
            #             }
            #         },
            #         'error': '',
            #         'sample_id': u'/mnt/nfs_watch/Test_Assets/3_HEVC_720p/49707-hanni-nanni'
            #     }
            # }
        BuiltIn().log_to_console("Generated packages:\n%s" % result)
        self.log_variables(self.generate_no_og_offers, locals())
        return result

    @easy_debug
    def generate_offers(self, lab_name, conf, map_dict):
        """A keyword to generate several packages to be picked up by Airflow at once.

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf.py.
        :param map_dict: a dictionary - keys are Jira tickets, values are dicts of package details.
        .. note:: the generator script is located at 172.30.218.244:/opt/makeadi/bin/makeadi.pl.

        :return: a dictionary where keys are jira tickets and values are assets' details.

        :Example:

        >>>bad_metadata1 = [{"xpath_locate": "./Asset/Metadata/AMS[@Asset_Class='title']",
        ...                  "xpath_change": "../App_Data[@Name='Licensing_Window_Start']",
        ...                  "attrs": {"Value": -365}, "cmd": "",},
        ...                 {"xpath_locate": "./Asset/Metadata/AMS[@Asset_Class='title']",
        ...                  "xpath_change": "../App_Data[@Name='Licensing_Window_End']",
        ...                  "attrs": {"Value": -365}, "cmd": "",}]
        >>>bad_metadata2 = [{"xpath_locate": "./Asset/Asset/Metadata/AMS[@Asset_Class='movie']",
        ...                  "xpath_change": "../App_Data[@Name='Content_CheckSum']",
        ...                  "attrs": {"Value": "abc"}, "cmd": "",}]
        >>>details = {
        ...    "HES-14": {"sample_id": "ts0000", "bad_metadata": bad_metadata1, "pattern": None,
        ...               "file_override": ""},
        ...    "HES-105": {"sample_id": "ts1111", "bad_metadata": bad_metadata2, "pattern": None,
        ...                "file_override": "/data/TestData/00-01-34_3764kbs_mpeg2video_720x576_" +
        ...                "16x9_25fps_DEU.mp2_NOSUB.german_trailer_asset_test_SD.ts"}
        ... }
        >>>Keywords().generate_offers("e2esi", E2E_CONF, details)
        {'HES-14': {'sample_id': 'ts0000', 'offer_id': '1502271815.36', \
                    'packages': {'ts0000_20170809_094340pt': {}},
        'HES-105': {'sample_id': 'ts1111', 'offer_id': '1503578035.55', \
                    'packages': {'ts1111_20170824_094417pt': {}}
        }
        """
        result = {}
        e2e_obj = E2E(lab_name=lab_name, e2e_conf=conf, keywords_object=self)
        for jira_ticket_id, ticket_details in list(map_dict.items()):
            e2e_obj.packages = {}
            try:
                movie_type = ticket_details["movie_type"]
            except KeyError:
                movie_type = None
            try:
                package_copy_name = ticket_details["package_copy_name"]
            except KeyError:
                package_copy_name = None
            try:
                unique_title_id = ticket_details["unique_title_id"]
            except KeyError:
                unique_title_id = None
            try:
                new_licensing_window_end = ticket_details["new_licensing_window_end"]
            except KeyError:
                new_licensing_window_end = None
            e2e_obj.generate_offer(ticket_details["sample_id"], ticket_details["bad_metadata"],
                                   ticket_details["file_override"], ticket_details["pattern"],
                                   movie_type, package_copy_name,
                                   unique_title_id, new_licensing_window_end)
            tmp = {"sample_id": ticket_details["sample_id"], "offer_id": e2e_obj.offer_id,
                   "packages": e2e_obj.packages, "error": e2e_obj.error,
                   "expected_dag": ticket_details["expected_dag"]}
            result.update({"%s" % jira_ticket_id: tmp})

        self.log_variables(self.generate_offers, locals())
        return result

    # pylint: disable=too-many-statements
    @easy_debug
    def get_ingestion_results(self, lab_name, conf, details, tries=900, interval=10):
        """A keyword to perform ingestion from the generation of a package
        till the asset becomes available on Fabrix or DAG is failed.

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf.py.
        :param details: a list returned by "generate_offers" keyword.
        :param tries: a number of attempts to check ingestion process, set 0 for unlimited attempts.
        :param interval: a number of seconds between re-tries.

        :return: a dictionary of ingestion details for each jira ticket (see example below).

        :Example (note, result is manually formatted for better readability):

        >>># 2 jira tickets with one package for each:
        >>>Keywords().get_ingestion_results("e2esi", E2E_CONF, details)
        {'HES-105':{
          'offer_id':'1504772401.63',
          'packages':{
            'ts0000_20170907_062209pt':{'adi':
                 '/var/tmp/adi-auto-deploy/e2esi/1001-ts0000_20170907_062209pt-0-0_Package/ADI.XML',
              'errors':[  ],
              'fabrix_asset_id':'50e5ab537ac47c74e4ce6a7bffa55a3d_ec80816b362f47f54c637f2ad253deb4',
              'properties':{ <dictionary_content_is_removed_due_to_its_large_size> },
              'logs_masks':['/usr/local/airflow/logs/\
                   create_obo_assets_transcoding_driven_workflow/*/2017-09-12T06:51:20.620621',
                   '/usr/local/airflow/logs/\
                   e2esi_lab_create_obo_assets_transcoding_driven_trigger/*/2017-09-12T06:40:00']
            }
          },
          'sample_id':'ts1111'
        },
        'HES-14':{
          'offer_id':'1504772408.66',
          'packages':{
            'ts0000_20170907_062216pt':{'adi':
                 '/var/tmp/adi-auto-deploy/e2esi/1001-ts0000_20170907_062216pt-0-0_Package/ADI.XML',
              'errors':["Bad checksum for the 'ts0000_20170907_062216pt1.ts' video file \
                       (actual: 3db98b518644918080e48343bdb644a1, expected: abc)"],
              'fabrix_asset_id':'80f3e0ddc1134c240e24f11bc762eda1_ec80816b362f47f54c637f2ad253deb4',
              'properties':{ <dictionary_content_is_removed_due_to_its_large_size> },
              'logs_masks':['/usr/local/airflow/logs/\
                    create_obo_assets_transcoding_driven_workflow/*/2017-09-12T06:51:16.282893',
                    '/usr/local/airflow/logs/\
                    e2esi_lab_create_obo_assets_transcoding_driven_trigger/*/2017-09-12T06:40:00']
            }
          },
          'sample_id':'ts0000'
        }
        }
        >>># 1 jira ticket with several packages (scheme):
        >>>Keywords().get_ingestion_results("e2esi", E2E_CONF, details)
        {'HES-14':{
          'offer_id':'1502271815.36',
          'packages':{
            '1001-CoD_1_SVod_Entry-0-0':{'adi': <PATH_TO_ADI>, 'tva': <TVA_FILE_NAME>,
              'errors':[ <same structure as in the above example> ],
              'fabrix_asset_id':'80f3e0ddc1134c240e24f11bc762eda1_ec80816b362f47f54c637f2ad253deb4',
              'properties':{ <same structure as in the above example> },
              'logs_masks':[ <same structure as in the above example> ]
            },
            '1001-CoD_2_SVod_Entry-0-0':{'adi': <PATH_TO_ADI>, 'tva': <TVA_FILE_NAME>,
              'errors':[ <same structure as in the above example> ],
              'fabrix_asset_id':'80f3e0ddc1134c240e24f11bc762eda1_ec80816b362f47f54c637f2ad253deb4',
              'properties':{ <same structure as in the above example> },
              'logs_masks':[ <same structure as in the above example> ]
            },
            ... <packages_skipped> ...
            '1001-Free_SVoD_Entry-0-0':{'adi': <PATH_TO_ADI>, 'tva': <TVA_FILE_NAME>,
              'errors':[ <same structure as in the above example> ],
              'fabrix_asset_id':'80f3e0ddc1134c240e24f11bc762eda1_ec80816b362f47f54c637f2ad253deb4',
              'properties':{ <same structure as in the above example> },
              'logs_masks':[ <same structure as in the above example> ]
            }
           },
           'sample_id':'ts0244'
          }
        }

        # details example:
            # {
            #     u'HES-390': {
            #         'offer_id': None,
            #         'packages': {
            #             '2018_08_15-13_01_04-032793': {
            #                 'errors': [],
            #                 'output_tva': '',
            #                 'properties': {},
            #                 'fabrix_asset_id': '',
            #                 'tva': u'/mnt/nfs_watch/Countries/CSI/ToAirflow'
            #                        u'/2018_08_15-13_01_04-032793/TVA_000001_20170802081133.xml',
            #                 'logs_masks': [],
            #                 'adi': ''
            #             }
            #         },
            #         'error': '',
            #         'sample_id': u'/mnt/nfs_watch/Test_Assets/3_HEVC_720p/49707-hanni-nanni'
            #     }
            # }
        """

        BuiltIn().log_to_console("\n\n\n\nStarting to collect ingestion results")
        # time.sleep(20)
        tries = int(tries)
        interval = float(interval)

        i = 0
        items_to_test = details.copy()
        items_to_return = {}
        e2e_obj = E2E(lab_name=lab_name, e2e_conf=conf, keywords_object=self)
        while True:
            i += 1
            for jira_ticket_id in list(items_to_test.keys()):
                details_dict = items_to_test[jira_ticket_id]
                if e2e_obj.offer_id != details_dict["offer_id"]:
                    e2e_obj.offer_id = details_dict["offer_id"]
                if e2e_obj.packages != details_dict["packages"]:
                    e2e_obj.packages = details_dict["packages"]
                if details_dict["error"]:
                    items_to_return[jira_ticket_id] = {}
                    items_to_return[jira_ticket_id]['error'] = details_dict["error"]
                    del items_to_test[jira_ticket_id]
                    continue
                for package, package_dict in list(details_dict["packages"].items()):
                    # 1. Check all logs of Airflow to find name of our package in a log
                    # 2. Check finned logs, that we have errors there
                    package_dict["start_time"] = ""
                    package_dict["end_time"] = ""
                    try:
                        BuiltIn().log_to_console("\nRunning logs analyse for package %s (%s Jira ticket)" %
                                                 (str(package), str(jira_ticket_id)))
                    except UnicodeEncodeError as err:
                        BuiltIn().log_to_console("\nRunning logs analyse for package %s (%s Jira ticket)" %
                                                 (package, jira_ticket_id))
                        print(err)
                    asset_failed = e2e_obj.check_asset_failed(package)
                    # asset_failed = False
                    if not asset_failed:
                        # We use this rule only in robot/ingestion/order_check/single_ingestion.txt
                        if "ignore_package_in_watch_folder" in list(details_dict.keys()):
                            ignore_watch = details_dict["ignore_package_in_watch_folder"]
                            if not isinstance(ignore_watch, bool):
                                if "False" in ignore_watch:
                                    ignore_watch = False
                                elif "True" in ignore_watch:
                                    ignore_watch = True
                                else:
                                    raise Exception("Unexpected 'ignore_package_in_watch_folder"
                                                    " value' %s" % ignore_watch)
                            if ignore_watch:
                                is_asset_in_watch_folder = False
                            else:
                                is_asset_in_watch_folder = e2e_obj.is_asset_present_in_watch_folder(
                                    conf[lab_name]["AIRFLOW_WORKERS"][0]["watch_folder"], package)
                        else:
                            is_asset_in_watch_folder = e2e_obj.is_asset_present_in_watch_folder(
                                conf[lab_name]["AIRFLOW_WORKERS"][0]["watch_folder"], package)
                        # is_asset_in_watch_folder = False
                        if not is_asset_in_watch_folder:
                            dag_failed = e2e_obj.check_dag_failed(package)
                            # dag_failed = False
                            package_dict_airflow_workers_logs_masks = \
                                package_dict["airflow_workers_logs_masks"] = \
                                e2e_obj.packages[package]["airflow_workers_logs_masks"]
                            # package_dict["airflow_workers_logs_masks"] = mock_data["robot"]["Libraries"]["IngestionE2E"]["keywords.py"]["get_ingestion_results"]["no_og_package"]["airflow_workers_logs_masks"]

                            # Trying to find "external_id" or "INFO - Asset" value in the logs
                            if not dag_failed:
                                if package_dict_airflow_workers_logs_masks:
                                    dag_started = e2e_obj.is_dag_started(package, package_dict)
                                    # dag_started = True
                                    if dag_started:
                                        # Trying to get asset properties  by sending GET to
                                        # url like "http://%s:%s/v2/view_asset_properties?id=%s" % \
                                        #          (self.conf["FABRIX"]["host"],
                                        #           self.conf["FABRIX"]["port"],
                                        #           self.packages[package]["fabrix_asset_id"])
                                        movie_type = e2e_obj.get_movie_type(e2e_obj, package)

                                        actual_dag = e2e_obj.packages[package]["actual_dag"] \
                                            or e2e_obj.get_actual_dag_name(package_dict["airflow_workers_logs_masks"], package)
                                        if actual_dag == str(details_dict["expected_dag"]):
                                            BuiltIn().log_to_console("DAG type is correct")
                                            package_dict["fabrix_asset_id"] = e2e_obj.packages[package]["fabrix_asset_id"] or \
                                                                              e2e_obj.get_particular_fabrix_asset_id_of_package(
                                                                                  package, 10, 5, movie_type, actual_dag)

                                            if e2e_obj.packages[package]["fabrix_asset_id"]:
                                                package_dict["properties"] = e2e_obj.packages[package]["properties"] \
                                                                             or e2e_obj.get_asset_properties(package, 10, 20)

                                                if package_dict["properties"] != {}:
                                                    output_tva_ready = e2e_obj.is_output_tva_file_ready(package)

                                                    if output_tva_ready:
                                                        package_dict["stb_movie_has_been_ingested"] = e2e_obj.was_movie_type_ingested(package, "stb", actual_dag)
                                                        package_dict["ott_movie_has_been_ingested"] = e2e_obj.was_movie_type_ingested(package, "ott", actual_dag)
                                                        package_dict["selene_stb_movie_has_been_ingested"] = e2e_obj.was_movie_type_ingested(package, "stb", actual_dag, platform="selene")
                                                        package_dict["selene_ott_movie_has_been_ingested"] = e2e_obj.was_movie_type_ingested(package, "ott", actual_dag, platform="selene")

                                                        start_time = e2e_obj.get_ingestion_start_time(package)
                                                        end_time = e2e_obj.get_ingestion_end_time(package)
                                                        if start_time:
                                                            package_dict["start_time"] = start_time
                                                        else:
                                                            package_dict["start_time"] = ""
                                                        if end_time:
                                                            package_dict["end_time"] = end_time
                                                        else:
                                                            package_dict["end_time"] = ""

                                            else:
                                                package_dict["properties"] = {}
                                        else:
                                            fail_message = "Wrong DAG '%s' was used to ingest %s package. Expected: %s" % (actual_dag, package, details_dict["expected_dag"])
                                            BuiltIn().log_to_console(fail_message)
                                            if package_dict["errors"]:
                                                package_dict["errors"] += [fail_message]
                                            else:
                                                package_dict["errors"] = [fail_message]
                                    else:
                                        BuiltIn().log_to_console("DAG was NOT started yet for package %s" % package)
                            else:
                                package_dict["errors"] = e2e_obj.packages[package]["errors"]
                    else:
                        package_dict_errors = package_dict["errors"] = e2e_obj.packages[package]["errors"]
                        print(package_dict_errors)

                    if (package_dict["start_time"] != "" and package_dict["end_time"] != "") or package_dict["errors"] != []:

                        if list(items_to_test[jira_ticket_id]['packages'].keys()):
                            try:
                                BuiltIn().log_to_console(
                                    "\nGot all necessary ingestion results for "
                                    "package %s" % str(package))
                            except UnicodeEncodeError as err:
                                BuiltIn().log_to_console(
                                    "\nGot all necessary ingestion results for "
                                    "package %s" % package)
                            # Add data to return
                            if jira_ticket_id not in list(items_to_return.keys()):
                                items_to_return[jira_ticket_id] = {}
                            if "packages" not in list(items_to_return[jira_ticket_id].keys()):
                                items_to_return[jira_ticket_id]["packages"] = {}
                            items_to_return[jira_ticket_id]["packages"][package] = package_dict
                            # Remove data to check
                            del items_to_test[jira_ticket_id]['packages'][package]
                            BuiltIn().log_to_console("-" * 78)
                        if not list(items_to_test[jira_ticket_id]['packages'].keys()):
                            BuiltIn().log_to_console("\nGot all necessary ingestion results for "
                                                     "Jira ticket %s" % jira_ticket_id)
                            # Add data to return
                            items_to_return[jira_ticket_id]['offer_id'] = details[jira_ticket_id][
                                'offer_id']
                            items_to_return[jira_ticket_id]['error'] = details[jira_ticket_id][
                                'error']
                            items_to_return[jira_ticket_id]['sample_id'] = details[jira_ticket_id][
                                'sample_id']
                            items_to_return[jira_ticket_id]['expected_dag'] = details[jira_ticket_id][
                                'expected_dag']
                            # Remove data to check
                            del items_to_test[jira_ticket_id]
                            BuiltIn().log_to_console("=" * 78)

            if list(items_to_test.keys()) and i != tries:
                BuiltIn().log_to_console("Pause to %s sec" % interval)
                time.sleep(interval)
                BuiltIn().log_to_console("\n\n%s" % ("- " * 25))
                BuiltIn().log_to_console("\nRetrying to collect necessary ingestion results...\n")
                BuiltIn().log_to_console("%s\n\n" % ("- " * 25))
            else:
                BuiltIn().log_to_console("\n\n\nDONE: all ingestion results has collected")
                break

        self.log_variables(self.get_ingestion_results, locals())
        return items_to_return

    @easy_debug
    def get_ingestion_starting_time(self, lab_name, conf, details, watch_folder="watch_folder", tries=900, interval=10):
        """A keyword to get start time of package ingestion.

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf.py.
        :param details: a list returned by "generate_offers" keyword.
        :param watch_folder: watch folder to asset to be ingested normal/priority.
        :param tries: a number of attempts to check ingestion process, set 0 for unlimited attempts.
        :param interval: a number of seconds between re-tries.

        :return: a dictionary of ingestion details is returned for the package.
        """

        BuiltIn().log_to_console("\n\n\n\nStarting to determinate the ingestion start time")
        # time.sleep(20)
        tries = int(tries)
        interval = float(interval)

        i = 0
        while True:
            i += 1
            package_dict = {}
            e2e_obj = E2E(lab_name, conf, details["offer_id"], details["packages"], self)
            for package, package_dict in list(details["packages"].items()):
                # 1. Check all logs of Airflow to find name of our package in a log
                # 2. Check finned logs, that we have errors there
                package_dict["start_time"] = ""
                try:
                    BuiltIn().log_to_console("\nGetting ingestion start time: Running logs analyse for package %s " %
                                             str(package))
                except UnicodeEncodeError as err:
                    BuiltIn().log_to_console("\nGetting ingestion start time: Running logs analyse for package %s " %
                                             (package))
                    print(err)
                asset_failed = e2e_obj.check_asset_failed(package)
                # asset_failed = False
                BuiltIn().log_to_console("Ingestion start time: asset_failed %s" % asset_failed)
                if not asset_failed:

                    is_asset_in_watch_folder = e2e_obj.is_asset_present_in_watch_folder(
                        conf[lab_name]["AIRFLOW_WORKERS"][0][watch_folder], package)
                    # is_asset_in_watch_folder = False
                    if not is_asset_in_watch_folder:
                        dag_failed = e2e_obj.check_dag_failed(package)
                        # dag_failed = False
                        package_dict_airflow_workers_logs_masks = package_dict["airflow_workers_logs_masks"] = e2e_obj.get_package_log_masks(package)
                        # package_dict["airflow_workers_logs_masks"] = mock_data["robot"]["Libraries"]["IngestionE2E"]["keywords.py"]["get_ingestion_results"]["no_og_package"]["airflow_workers_logs_masks"]

                        # Trying to find "external_id" or "INFO - Asset" value in the logs
                        if not dag_failed:
                            if package_dict_airflow_workers_logs_masks:
                                dag_started = e2e_obj.is_dag_started(package, package_dict)
                                # dag_started = True
                                if dag_started:
                                    # package_dict["start_time"] = 20190325115530
                                    package_dict["start_time"] = e2e_obj.get_ingestion_start_time(package)
                                else:
                                    BuiltIn().log_to_console("Ingestion start time: Ingestion was NOT started yet for package %s" % package)
                        else:
                            package_dict["errors"] = e2e_obj.packages[package]["errors"]
                else:
                    package_dict_errors = package_dict["errors"] = e2e_obj.packages[package]["errors"]
                    print(package_dict_errors)

            if not package_dict["start_time"] and i != tries:
                BuiltIn().log_to_console("Pause to %s sec" % interval)
                time.sleep(interval)
                BuiltIn().log_to_console("\n\n%s" % ("- " * 25))
                BuiltIn().log_to_console("\nRetrying to determinate the ingestion start time...\n")
                BuiltIn().log_to_console("%s\n\n" % ("- " * 25))
            else:
                BuiltIn().log_to_console("\n\n\nDONE: ingestion start time is collected")
                break

        self.log_variables(self.get_ingestion_starting_time, locals())
        return package_dict

    @easy_debug
    def check_ingestion_is_started(self, lab_name, conf, details):
        """A keyword to check that the package ingestion is started

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf.py.
        :param details: a list returned by "generate_offers" keyword.

        :return: True if the ingestion is started, False otherwise.
        """
        e2e_obj = E2E(lab_name, conf, details["offer_id"], details["packages"], self)
        for package in list(details["packages"].keys()):
            try:
                BuiltIn().log_to_console("\nChecking logs if ingestion is started for package %s " %
                                         (str(package)))
            except UnicodeEncodeError as err:
                BuiltIn().log_to_console("\nChecking logs if ingestion is started for package %s " %
                                         (package))
                print(err)
            self.log_variables(self.check_ingestion_is_started, locals())
            # return False
            return e2e_obj.check_ingestion_started(package)

    @easy_debug
    def tva_make_checksums_uppercase(self, lab_name, conf, tva_path):
        """A method to make MD5 checksums uppercase in the TVA xml file."""
        tools = Tools(conf[lab_name])
        checksums = set()
        e2e_obj = E2E(lab_name=lab_name, e2e_conf=conf, keywords_object=self)
        tva = e2e_obj.read_tva(tva_path[:tva_path.rfind("/")])
        all_hashes = re.findall("[a-fA-F0-9]{32}", str(tva))
        for path, value in tools.dict_walk(tva):
            value = value.strip()
            if path.endswith("[InstanceDescription][OtherIdentifier][#text]") \
            and value in all_hashes:
                checksums.add(value)
        for checksum in checksums:
            command = "sed -i 's|%s|%s|g' %s " % (checksum, checksum.upper(), tva_path)
            error = tools.run_ssh_cmd(conf[lab_name]["AIRFLOW_WORKERS"][0]["host"],
                                      conf[lab_name]["AIRFLOW_WORKERS"][0]["port"],
                                      conf[lab_name]["AIRFLOW_WORKERS"][0]["user"],
                                      conf[lab_name]["AIRFLOW_WORKERS"][0]["password"], command)[1]
            if error:
                self.log_variables(self.tva_make_checksums_uppercase, locals())
                return ["Cannot replace checksum to uppercase in %s due to %s"
                        % (tva_path[:tva_path.rfind("/")], error)]
        e2e_obj.read_tva(tva_path[:tva_path.rfind("/")])
        self.log_variables(self.tva_make_checksums_uppercase, locals())
        return []

    @easy_debug
    def unlock_package_in_watch(self, lab_name, conf, packages):
        """Method removes 'lock.tmp' file from the given folders mounted on the Airflow workers.

        :param packages: a packages dictionary OR a list of abs paths to the packages files.

        :return: a list of error message(s), should be empty if no errors occurred.
        """
        tools = Tools(conf[lab_name])
        result = []
        if list(packages.keys()):
            folders = []
            if isinstance(packages, dict):
                for package in list(packages.keys()):
                    folders.append(packages[package]["tva"][:packages[package]["tva"].rfind("/")])
            else:
                folders = packages

            cmd = "chmod -R a+w %s/ " % folders[0]
            # cmd = "chmod -R a+w %s/../%s* " % \
            #       (folders[0], folders[0][folders[0].rfind("/")+1:5])
            cmd += "&& rm -f %s" % " ".join("%s/lock.tmp" % folder for folder in folders)
            error = tools.run_ssh_cmd(conf[lab_name]["AIRFLOW_WORKERS"][0]["host"],
                                      conf[lab_name]["AIRFLOW_WORKERS"][0]["port"],
                                      conf[lab_name]["AIRFLOW_WORKERS"][0]["user"],
                                      conf[lab_name]["AIRFLOW_WORKERS"][0]["password"], cmd)[1]
            if error:
                result = ["Cannot remove 'lock.tmp' file in package(s) folder(s): %s" % error]
        else:
            self.log_variables(self.unlock_package_in_watch, locals())
            raise Exception("Packages dictionary is empty =(")

        self.log_variables(self.unlock_package_in_watch, locals())
        return result

    @easy_debug
    def block_movie_type_ingestion(self, lab_name, conf, path_to_adi, movie_type):
        """Method to block ott or stb movie ingestion by adding special line to ADI.XML file

        :param path_to_adi: an absolute path to ADI.XML written by generator script.
        :param movie_type: ott or stb, string. Lower and upper case are allowed
        """
        e2e_obj = E2E(lab_name=lab_name, e2e_conf=conf, keywords_object=self)
        e2e_obj.block_movie_type_ingestion_in_adi_file(path_to_adi, movie_type)
        self.log_variables(self.block_movie_type_ingestion, locals())

    @easy_debug
    def unhold_package_and_offer_in_asset_generator(self, lab_name, conf, package, environment="obocsi"):
        """A method to remove "HOLD" from the package and offer directories to make ir autodeployed

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf.py.
        :param package: package name, string.
        :param environment: lab name, string
        """
        e2e_obj = E2E(lab_name=lab_name, e2e_conf=conf, keywords_object=self)
        e2e_obj.unhold_package_and_offer(package, environment)
        self.log_variables(self.unhold_package_and_offer_in_asset_generator, locals())

    @easy_debug
    def collect_from_airflow_logs(self, lab_name, conf, results_dict, package_name, search_entry):
        """A keyword to generate several packages to be picked up by Airflow at once.

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf.py.
        :param results_dict: a dictionary of results returned by 'get_ingestion_results' keyword.

        :return: a list of log-records containing the given entry.
        """
        entries = []
        for jira_ticket_id in list(results_dict.keys()):
            ticket_details = results_dict[jira_ticket_id]
            if package_name in ticket_details["packages"]:
                e2e_obj = E2E(lab_name=lab_name, e2e_conf=conf, keywords_object=self)
                e2e_obj.packages.update(ticket_details["packages"])
                entries = e2e_obj.collect_from_logs(package_name, search_entry)
                break

        self.log_variables(self.collect_from_airflow_logs, locals())
        return entries

    @easy_debug
    def get_log_data_from_airflow_logs(self, lab_name, conf, logfile_path):
        """ A method to get the log file data from the airflow workers

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf_obolab.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf_obolab.py.
        :param logfile_path: absolute path to output file to get data
        :return: list type, data is returned as list
        """

        e2e_obj = E2E(lab_name=lab_name, e2e_conf=conf)
        result = e2e_obj.get_log_data(logfile_path)
        self.log_variables(self.get_log_data_from_airflow_logs, locals())
        if result:
            return result
        raise Exception("Logfile Path '%s' was not found on the Airflow workers" %logfile_path)

    @easy_debug
    def check_airflow_logging_enabled(self, lab_name, conf):
        """A keyword to check whether logs are kept locally on all Airflow workers.

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf.py.

        :return: an error message (should be "" if local logging is enabled on all Airflow workers).

        :Example:

        >>>Keywords().check_local_logging_enabled("e2esi", E2E_CONF)
        True
        """
        tools = Tools(conf[lab_name])
        error = ""
        command = "cat /usr/local/airflow/airflow.cfg | grep keep_local_logs"
        for cnf in conf[lab_name]["AIRFLOW_WORKERS"]:
            try:
                stdout, stderr = tools.run_ssh_cmd(cnf["host"], cnf["port"],
                                                   cnf["user"], cnf["password"],
                                                   command)
                #print("Done: %s.\nReturned stdout: %s\nReturned stderr:\n%s\n" \
                #      % (command, stdout, stderr))
                if stdout and "true" not in stdout.lower():
                    error += "Local logging is not enabled on Airflow worker %s. " % cnf["host"]
                elif stderr and "Could not chdir to home directory" not in stderr:
                    error += stderr
            except socket.error as err:
                error += "SSH to host %s failed due to: %s. " % (cnf["host"], err)
        if error:
            self.log_variables(self.check_airflow_logging_enabled, locals())
            return "Cannot connect to Airflow worker(s): %s" % error

        self.log_variables(self.check_airflow_logging_enabled, locals())
        return error

    @easy_debug
    def check_airflow_logs_structure(self, lab_name, conf, airflow_workers_logs_masks):
        """A method to check that Airflow logs has Json basded structure with:
        asctime, filename, lineno and levelname keys
        As precondition: "*_json_log_active" Af variable have to be True

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf.py.
        :param airflow_workers_logs_masks: list of log masks (absolute path to log)
        :return: error messages, or empty
        """
        e2e_obj = E2E(lab_name=lab_name, e2e_conf=conf)
        error_messages = []
        for log in airflow_workers_logs_masks:
            log_lines = e2e_obj.get_log_data(log)
            if log_lines:
                logging_detected = False
                for line in log_lines:
                    incorrect_logging_attribute = False
                    fail_reasons = []
                    if line.startswith("{"):
                        logging_detected = True
                        line = json.loads(line)
                        # line example: {"asctime": "2019-07-09 07:37:34,972", "filename": "multi_branch_python_operator.py", "lineno": 32, "context": "ecx_superset_create_obo_assets_transcoding_driven_trigger-20190709T07:36:00+00:00-lookup_dir-1", "levelname": "INFO", "message": "INFO - Done.", "env": "ecx_superset", "app": "airflow", "stack": "end2end", "tier": "worker"}
                        asctime = line["asctime"]
                        file_name = line["filename"]
                        line_num = str(line["lineno"])
                        log_level = line["levelname"]

                        # asctime example "2019-07-09 07:37:34,972"
                        if not re.match("\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3}", asctime):  # pylint: disable=anomalous-backslash-in-string
                            incorrect_logging_attribute = True
                            fail_reasons.append("Incorrect 'asctime': %s. " % asctime)
                        # file_name example "base_task_runner.py"
                        if not re.match("[a-z,0-9,_]+.py", file_name):
                            incorrect_logging_attribute = True
                            fail_reasons.append("Incorrect 'file_name': %s. " % file_name)
                        # line_num example "102"
                        if not re.match("\d{1,5}", line_num):  # pylint: disable=anomalous-backslash-in-string
                            incorrect_logging_attribute = True
                            fail_reasons.append("Incorrect 'line_num': %s. " % line_num)
                        # log_level example "INFO"
                        if log_level not in ["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"]:
                            incorrect_logging_attribute = True
                            fail_reasons.append("Incorrect 'log_level': %s. " % log_level)
                    if incorrect_logging_attribute:
                        error_message = "Incorrect log line was detected in the %s file. " \
                                        "Line: %s. Errors: %s. " % (log, line, fail_reasons)
                        error_messages.append(error_message)
                        break

                if not logging_detected:
                    error_messages.append("Logging attributes was not detected in the %s. " % log)
            else:
                error_messages.append("Data was not found inside %s. " % log)
        self.log_variables(self.check_airflow_logs_structure, locals())
        return error_messages

    @easy_debug
    def get_workflow_dags_count(self, lab_name, conf, fabrix_asset_id):
        """A keyword to count the number of workflow DAGs launched by a trigger-DAG.

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf.py.
        :param fabrix_asset_id: external asset id from logs.

        :return: the number of workflow dags started at once by the trigger and workflow DAGs.

        :Example:

        >>>Keywords().workflow_dags_count("e2esi", E2E_CONF, external_asset_id)
        2
        """
        tools = Tools(conf[lab_name])
        external_asset_ids = []
        for cnf in conf[lab_name]["AIRFLOW_WORKERS"]:
            command = "grep -r 'airflow trigger_dag -r' %s/* | grep %s" % \
                      (cnf["logs_folder"], fabrix_asset_id)
            stdout = tools.run_ssh_cmd(cnf["host"], cnf["port"],
                                       cnf["user"], cnf["password"],
                                       command)[0]
            if stdout and not external_asset_ids:
                # Regexp to find all external_asset_id in stdout
                pattern = '(?!"external_ids"\[)"[0-9a-z]{32}_[0-9a-z]{32}",?(?<!\])' # pylint: disable=W1401
                external_asset_ids = re.findall(pattern, stdout)
                break
        result = len(external_asset_ids)
        if result < 2:
            BuiltIn().log_to_console("Command %s.\nStdout: %s\n" % (command, stdout))
            BuiltIn().log_to_console("External ids list: " % external_asset_ids)

        self.log_variables(self.get_workflow_dags_count, locals())
        return

    @easy_debug
    def check_airflow_workers(self, lab_name, conf, ssh_prompt="$", sftp_prompt="sftp> "):
        """A keyword to check all Airflow workers: running processes and mounted folders.

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf.py.
        :param ssh_prompt: a string of an SSH prompt on Airflow's worker hosts.
        :param sftp_prompt: a string of an SFTP prompt on Airflow's worker hosts.

        :return: the list of error messages (unique); should be an empty list if no errors occurred.

        :Example:

        >>>Keywords().check_airflow_workers("e2esi", E2E_CONF)
        []
        """
        tools = Tools(conf[lab_name])
        errors = []
        health = HealthChecks(lab_name, conf)
        for cnf in conf[lab_name]["AIRFLOW_WORKERS"]:
            ssh_cnf = dict({"prompt": ssh_prompt}, **cnf)
            sftp_cnf = dict({"prompt": sftp_prompt}, **cnf)
            errors.extend(health.check_running_processes(ssh_cnf, ["airflow", "celeryd"], False))
            for folder in [cnf["watch_folder"], cnf["managed_folder"]]:
                perms = "drwxrwsr-x"
                errors.extend(health.check_folders_ssh(ssh_cnf, folder, perms))
                perms = "drwxrwsr-x"
                errors.extend(health.check_folders_sftp(ssh_cnf, sftp_cnf, folder, perms))
        # Note, airflow_local user will require skip_prefix="Could not chdir to home directory":
        skips = ["sftp -o StrictHostKeyChecking=no", "Command 'bye' failed"]
        errors = tools.filter_list(errors, skips)

        self.log_variables(self.check_airflow_workers, locals())
        return errors

    @easy_debug
    def check_storage_shares(self, lab_name, conf, ssh_prompt="$", sftp_prompt="sftp> "):
        """A keyword to check the permissions of shared folders on OG, origins and transcoders.

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf.py.

        :return: the list of error messages (unique); should be an empty list if no errors occurred.

        :Example:

        >>>Keywords().check_storage_shares("e2esi", E2E_CONF)
        []
        """
        tools = Tools(conf[lab_name])
        errors = []
        health = HealthChecks(lab_name, conf)
        # Check watch folder is correctly mounted on OG servers:
        for cnf in conf[lab_name]["OG"]:
            ssh_cnf = dict({"prompt": ssh_prompt}, **cnf)
            sftp_cnf = dict({"prompt": sftp_prompt}, **cnf)
            sftp_cnf.update({"password": ""})
            errors.extend(health.check_folders_sftp(ssh_cnf, sftp_cnf,
                                                    cnf["watch_folder"], "drwxrwsr-x"))

        # Check managed folder is correctly mounted on Origins:
        # TODO: fix based on answer here:
        # https://jira.lgi.io/browse/HES-214?focusedCommentId=2430720&page=com.atlassian.jira.plugin.system.issuetabpanels:comment-tabpanel#comment-2430720
        for ssh_cnf in conf[lab_name]["ORIGINS"]:
            todos = [{"cmd": "ls -ltR %s/ | head -n 100 | awk '{if(NR>2)print}' " % ssh_cnf["managed_folder"], "entry": "crid"},
                     {"cmd": "ls -ltR %s/ | head -n 100 | awk '{if(NR>2)print}' " % ssh_cnf["managed_folder"], "entry": "5001 5000"}]
            errors.extend(health.check_folders_ssh(ssh_cnf,
                                                   ssh_cnf["managed_folder"], "drwxrwxr-x", todos))

        # Check managed folder is correctly mounted on Transcoders:
        for ssh_cnf in conf[lab_name]["TRANSCODERS"]:
            errors.extend(health.check_folders_ssh(ssh_cnf, ssh_cnf["managed_folder"], "drwxrwsr-x",
                                                   sudo_prefix=ssh_cnf["sudo_prefix"]))
        skips = ["Could not chdir to home directory", "Command 'bye' failed"]
        errors = tools.filter_list(errors, skips)

        self.log_variables(self.check_storage_shares, locals())
        return errors

    @easy_debug
    def check_offering_generator(self, lab_name, conf, processes, ssh_prompt="$", sftp_prompt="sftp> "):
        """A keyword to check offering generator servers: running processes, logs, ProFTPd.

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf.py.
        :param processes: a list of processes to check, e.g.: ["/home/og/bin"] or even lab-specific:
            ["/home/og/bin/run_og.sh -c /opt/og/Countries/E2ESI/config/config-E2ESI.sh"]
        :param ssh_prompt: a string of an SSH prompt on OG hosts.
        :param sftp_prompt: a string of an SFTP prompt on OG hosts.

        :return: the list of error messages (unique); should be an empty list if no errors occurred.

        :Example:

        >>>Keywords().check_offering_generator("e2esi", E2E_CONF)
        []
        """
        tools = Tools(conf[lab_name])
        errors = []
        health = HealthChecks(lab_name, conf)
        errs = []
        for cnf in conf[lab_name]["OG"]:
            ssh_cnf = dict({"prompt": ssh_prompt}, **cnf)
            sftp_cnf = dict({"prompt": sftp_prompt}, **cnf)
            sftp_cnf.update({"password": ""})
            errors.extend(health.check_folders_sftp(ssh_cnf, sftp_cnf,
                                                    cnf["watch_folder"], "drwxrwsr-x"))
            errors.extend(health.check_todays_logs(ssh_cnf, cnf["logs_folder"]))
            errs = health.check_running_processes(ssh_cnf, processes, True, 330, 1)
            if not errs:
                break  # should not check other hosts if at least one OG host is working
        errors.extend(errs)  # if no OG host is working, take errors of the last OG host
        skips = ["Could not chdir to home directory", "Command 'bye' failed"]
        errors = tools.filter_list(errors, skips)

        self.log_variables(self.check_offering_generator, locals())
        return errors

    @easy_debug
    def check_airflow_manager_version(self, lab_name, conf, cur_dir):
        """A keyword to check all Airflow workers: running processes and mounted folders.

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf.py.
        :param cur_dir: a current directory (usually it is robot/ingestion/healthchecks).
        .. note :: cur_dir can be ${CURDIR} value called from a test case in Robot Framework.

        :return: the list of error messages (unique); should be an empty list if no errors occurred.

        :Example:

        >>>Keywords().check_airflow_version("e2esi", E2E_CONF, "v1.50")
        []
        """
        tools = Tools(conf[lab_name])
        errors = []
        health = HealthChecks(lab_name, conf)
        errors.extend(health.check_airflow_manager_version(cur_dir, conf[lab_name]))
        # Note, airflow_local user will require skip_prefix="Could not chdir to home directory":
        errors = tools.filter_list(errors)

        self.log_variables(self.check_airflow_manager_version, locals())
        return errors

    @easy_debug
    def check_airflow_workers_revisions(self, lab_name, conf, expected_values):
        """A keyword to check all Airflow workers: running processes and mounted folders.

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf.py.
        :param expected_values: a dictionary with keys "Revision_airflow", "Revision_airflow-dags".

        :return: the list of error messages (unique); should be an empty list if no errors occurred.

        :Example:

        >>>Keywords().check_airflow_version("e2esi", E2E_CONF, "v1.50")
        []
        """
        tools = Tools(conf[lab_name])
        errors = []
        health = HealthChecks(lab_name, conf)
        for ssh_cnf in conf[lab_name]["AIRFLOW_WORKERS"]:
            errors.extend(
                health.check_airflow_worker_revisions(ssh_cnf,
                                                      expected_values["Revision_airflow"],
                                                      expected_values["Revision_airflow-dags"])
            )
        # Note, airflow_local user will require skip_prefix="Could not chdir to home directory":
        errors = tools.filter_list(errors)

        self.log_variables(self.check_airflow_workers_revisions, locals())
        return errors

    @easy_debug
    def get_data_from_airflow_aws(self, lab_name, conf, cur_dir):
        """Retrieve data from Airflow web server deployed in AWS, the key horizongodevepam.pem
        will be used to SSH onto the server like it can be done with the command:
         ssh -i ~/.ssh/horizongodevepam.pem ec2-user@webserver1.airflow-lab5a.horizongo.eu <command>

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf.py.
        :param cur_dir: a current directory (usually it is robot/ingestion/healthchecks).
        .. note :: cur_dir can be ${CURDIR} value called from a test case in Robot Framework.

        :return: a dictionary with keys named as files and "errors":
        {'errors': [], 'VERSION': 'v1.50',
        'Revision_airflow': '9875f29a821dfb6b487bbdea90712e0952a8e143',
        'Revision_airflow-dags': '3214665b5bf3affde1e2adcee3c84002ae1ee5d7'}
        """
        health = HealthChecks(lab_name, conf)
        files = ["VERSION", "Revision_airflow", "Revision_airflow-dags"]
        result = health.get_data_from_aws_host(conf[lab_name]["AIRFLOW_WEB"],
                                               ["/usr/local/airflow/%s" % item for item in files],
                                               cur_dir)

        self.log_variables(self.get_data_from_airflow_aws, locals())
        return result

    @easy_debug
    def check_group_users_membership(self, lab_name, conf, group, user, expected_gid=5000):
        """A keyword to check if a given group exists on all Airflow workers,
         and all given users are its members.

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf.py.
        :param group: a group name, e.g. "flowusers".
        :param users: a list of users, e.g. ["airflow", "airflow_local", "airflowlogin"].

        :return: a tuple (data_dict, errors_list).

        :Example:

        >>>group, users = "flowusers", ["airflow", "airflow_local", "airflowlogin"]
        >>>Keywords().check_airflow_workers("e2esi", E2E_CONF, group, users)
        ({'172.23.69.117': {'gid': '5000'}, '172.23.69.118': {'gid': '5000'}}, ["User \
        'airflow_local' is not a member of the group 'flowusers' on Airflow worker 172.23.69.117"])
        """
        errors = []
        data = {}
        health = HealthChecks(lab_name, conf)
        for cnf in conf[lab_name]["AIRFLOW_WORKERS"]:
            gid, errs = health.check_group_users_membership(cnf, group, user, expected_gid)
            errors.extend(errs)
            data.update({cnf["host"]: {"gid": gid}})

        self.log_variables(self.check_group_users_membership, locals())
        return data, errors

    @easy_debug
    def check_group_users_details(self, lab_name, conf, gids, expected):
        """A keyword to check all Airflow workers: running processes and mounted folders.

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf.py.
        :param gids: a dictionary, first element returned by check_group_users_membership() method.
        :param expected: a dictionary (keys are users) describing expected values for users details.

        :return: a tuple (data_dict, errors_list).

        :Example:

        >>>users, bash = ["airflow", "airflow_local", "airflowlogin"], "/bin/bash"
        >>>gids = {"172.23.69.117": {"gid": "5000"}, "172.23.69.118": {"gid": "5000"}}
        >>>expected = {
        ..."airflow": {"uid": 5001, "gid": None, "home": "/usr/local/airflow", "shell": bash},
        ..."airflowlogin": {"uid": 5003, "gid": 5003, "home": "/opt/airflow", "shell": bash},
        ..."airflow_local": {"uid": 5002, "gid": None, "home": "/home/airflow_local", "shell": bash}
        ...}}
        >>>Keywords().check_group_users_details("e2esi", E2E_CONF, gids, expected)
        ({'172.23.69.117': {'airflow': {'uid': '5001', 'gid': '5000', 'home': '/usr/local/airflow',\
        'shell': '/bin/bash'}, 'airflow_local': {'uid': '5002', 'gid': '5000', \
        'home': '/home/airflow_local', 'shell': '/bin/bash'}, 'airflowlogin': {'uid': '5003', \
        'gid': '5008', 'home': '/home/airflowlogin', 'shell': '/bin/bash'}}, \
        '172.23.69.118': {'airflow': {'uid': '5001', 'gid': '5000', 'home': '/usr/local/airflow', \
        'shell': '/bin/bash'}, 'airflow_local': {'uid': '5002', 'gid': '5000', \
        'home': '/home/airflow_local', 'shell': '/bin/bash'}, 'airflowlogin': {'uid': '5003', \
        'gid': '5003', 'home': '/opt/airflow', 'shell': '/bin/bash'}}}, \
        ["On Airflow worker 172.23.69.117 user 'airflowlogin' has gid=5008 (expected 5003)", \
        "On Airflow worker 172.23.69.117 user 'airflowlogin' has home=/home/airflowlogin \
        (expected /opt/airflow)"])
        """
        errors = []
        data = {}
        health = HealthChecks(lab_name, conf)
        for cnf in conf[lab_name]["AIRFLOW_WORKERS"]:
            gid = [gids[host]["gid"] for host in list(gids.keys()) if cnf["host"] == host][0]
            for user in list(expected.keys()):
                if "gid" in expected[user] and not expected[user]["gid"]:
                    expected[user].update({"gid": gid})
            details, errs = health.check_user_details(cnf, expected)
            errors.extend(errs)
            data.update({cnf["host"]: details})

        self.log_variables(self.check_group_users_details, locals())
        return data, errors

    @easy_debug
    def check_users_homes(self, lab_name, conf, expected):
        """A keyword to check all Airflow workers: running processes and mounted folders.

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf.py.
        :param expected: a dictionary describing expected values for users details.

        :return: a tuple (data_dict, errors_list).

        :Example:

        >>>expected = {"airflow":
        ...   {"owner": "airflow", "group": "flowusers", "home": "/usr/local/airflow"}}
        >>>Keywords().check_group_users_homes("e2esi", E2E_CONF, expected)
        ({'172.23.69.118': {'airflow': {'perms': 'drwxrwx---.', 'owner': 'airflow', 'group': \
        'flowusers', 'home': '/usr/local/airflow'}}, '172.23.69.117': {'airflow': {'perms': \
        'drwxrwx---.', 'owner': 'airflow', 'group': 'flowusers', 'home': '/usr/local/airflow'}}},[])
        """
        errors = []
        data = {}
        health = HealthChecks(lab_name, conf)
        for cnf in conf[lab_name]["AIRFLOW_WORKERS"]:
            details, errs = health.check_users_homes(cnf, expected)
            errors.extend(errs)
            data.update({cnf["host"]: details})

        self.log_variables(self.check_users_homes, locals())
        return data, errors

    @easy_debug
    def check_countries_subdirs(self, lab_name, conf, countries_dir, countries=None, subdirs=None,
                                exp_uid=5000, exp_gid=5000, exp_perms="drwxr-sr-x"):
        """A keyword to check permissions & ownership of subfolders inside countries watch folders.

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf.py.
        :param countries_dir: a folder which contains countries subdirs.
        :param countries: a list of country codes to verify, by default all subdirs of 'Countries'.
        :param subdirs: a list of folder names to verify the existence and ownership.
        :param exp_uid: an expected id of the user owner.
        :param exp_gid: an expected id of the group owner.
        :param exp_perms: expected permissions in the string form, e.g. "drwxr-sr-x.".

        :return: a list of error messages, should be empty if no errors occurred.

        :Example:

        >>>Keywords().check_watch_countries_subdirs("e2esi", E2E_CONF, countries=["E2ESI"])
        []
        """
        countries = countries or []
        subdirs = subdirs or ["config", "content", "export", "fail", "feed", "ingest", "log",
                              "output", "tmp", "transfer", "uploaded", "filter"]
        health = HealthChecks(lab_name, conf)
        errors = health.check_countries_subdirs(conf[lab_name]["AIRFLOW_WORKERS"][0], countries_dir,
                                                countries, subdirs, exp_uid, exp_gid, exp_perms)
        self.log_variables(self.check_countries_subdirs, locals())
        return errors

    @easy_debug
    def check_workers_connectivity(self, lab_name, conf, host, port):
        """A keyword to check connectivity from all Airflow workers to a remote host:port.

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf.py.
        :param host: an IP address or a hostname to check connectivity to.
        :param port: a port number of the remote host to check connectivity to.

        :return: a list of error messages, should be empty if no errors occurred.

        :Example:

        >>>Keywords().check_workers_connectivity("e2esi", CONF, "lgiobo.stage.ott.irdeto.com", 80)
        []
        """
        errors = []
        health = HealthChecks(lab_name, conf)
        for cnf in conf[lab_name]["AIRFLOW_WORKERS"]:
            errors.extend(health.check_connectivity(cnf, host, port))

        self.log_variables(self.check_workers_connectivity, locals())
        return errors

    @easy_debug
    def check_transcoders_connectivity(self, lab_name, conf):
        """A keyword to check connectivity from local host to transcoders.

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf.py.

        :return: a list of error messages, should be empty if no errors occurred.

        :Example:

        >>>Keywords().check_transcoders_connectivity("e2esi", CONF)
        []
        """
        errors = []
        health = HealthChecks(lab_name, conf)
        for cnf in conf[lab_name]["TRANSCODERS"]:
            errors.extend(health.check_connectivity_from_localhost(cnf))

        self.log_variables(self.check_transcoders_connectivity, locals())
        return errors

    @easy_debug
    def check_mount_points(self, lab_name, conf, cmd, src_host, src_folder, fs_type):
        """A keyword to check connectivity from all Airflow workers to a remote host:port.
        Example values for 'cmd' argument:
            mount | grep nfs | awk '{print $1,$5,$3}'  # check if the folders are currently mounted
            cat /etc/fstab | grep nfs | awk '{print $1,$3,$2}'  # check auto-mounting in /etc/fstab

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf.py.
        :param cmd: a command to be executed to check mounting.
        :param src_host: an IP address of the host the src_folder is shared from.
        :param src_folder: a path to the shared folder (that is located on the src_host).
        :param fs_type: a file system type, e.g. 'nfs', 'cifs', etc.

        :return: a list of error messages, should be empty if no errors occurred.

        :Example:

        >>>Keywords().check_mount_points("e2esi", E2E_CONF, countries=["E2ESI"])
        []
        """
        errors = []
        health = HealthChecks(lab_name, conf)
        for cnf in conf[lab_name]["AIRFLOW_WORKERS"]:
            dst_folder = cnf["watch_folder"] if "watch" in src_folder else cnf["managed_folder"]
            errors.extend(health.check_mount_points(cnf, cmd,
                                                    src_host, src_folder, fs_type, dst_folder))

        self.log_variables(self.check_mount_points, locals())
        return errors

    @easy_debug
    def check_movie_has_correct_resolution(self, lab_name, conf, path_to_output_tva, movie_type, definition_type):
        """ A method to get movie resolution depends on passed movie type (OTT, STB) and
        definition type (HD, SD) and check it with expected values

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf_obolab.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf_obolab.py.
        :param path_to_output_tva: absolute path to output tva xml file to analyze
        :param movie_type: "OTT" or "STB"
        :param definition_type: "HD" or "SD"
        :return: empty string in case if check is PASS, or fail reason message string
        """
        e2e_obj = E2E(lab_name=lab_name, e2e_conf=conf)
        expected_resolution = {
            "OTT": {
                "HD": {
                    "horizontal_size": 1280,
                    "vertical_size": 720
                },
                "SD": {
                    "horizontal_size": 1024,
                    "vertical_size": 576
                }
            },
            "STB": {
                "HD": {
                    "horizontal_size": 1280,
                    "vertical_size": 720
                },
                "SD": {
                    "horizontal_size": 720,
                    "vertical_size": 576
                }
            }
        }

        expected_horizontal_size = expected_resolution[movie_type][definition_type]["horizontal_size"]
        expected_vertical_size = expected_resolution[movie_type][definition_type]["vertical_size"]

        actual_horizontal_size, actual_vertical_size = e2e_obj.get_resolution_from_output_tva_file(
            path_to_output_tva, movie_type, definition_type
        )

        result = ""
        if actual_horizontal_size != expected_horizontal_size:
            result = "Incorrect horizontal size for %s movie in %s resolution: %s. Expected %s. " % (
                movie_type, definition_type, actual_horizontal_size, expected_horizontal_size
            )
        if actual_vertical_size != expected_vertical_size:
            result += "Incorrect vertical size for %s movie in %s resolution: %s. Expected %s." % (
                movie_type, definition_type, actual_vertical_size, expected_vertical_size
            )

        self.log_variables(self.check_movie_has_correct_resolution, locals())
        return result

    @easy_debug
    def check_movie_has_correct_video_format(self, lab_name, conf, path_to_output_tva, movie_type, definition_type):
        """ A method to get movie video format depends on passed movie type (OTT, STB) and
        definition type (HD, SD) and check it with expected values

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf_obolab.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf_obolab.py.
        :param path_to_output_tva: absolute path to output tva xml file to analyze
        :param movie_type: "OTT" or "STB"
        :param definition_type: "HD" or "SD"
        :return: empty string in case if check is PASS, or fail reason message string
        """
        e2e_obj = E2E(lab_name=lab_name, e2e_conf=conf)
        expected_formats = {
            "OTT": {
                "HD": {
                    "format": "H264"
                },
                "SD": {
                    "format": "H264"
                }
            },
            "STB": {
                "HD": {
                    "format": "H264"
                },
                "SD": {
                    "format": "H264"
                }
            }
        }
        expected_format_value = expected_formats[movie_type][definition_type]["format"]

        actual_format_value = e2e_obj.get_video_format_from_output_tva_file(path_to_output_tva, movie_type, definition_type)

        result = ""
        if actual_format_value != expected_format_value:
            result = "Incorrect Video format for %s movie in %s resolution: %s. Expected %s. " % (
                movie_type, definition_type, actual_format_value, expected_format_value
            )

        self.log_variables(self.check_movie_has_correct_video_format, locals())
        return result

    @easy_debug
    def check_audio_coding_formats(self, lab_name, conf, path_to_output_tva):
        """ A method to check AudioCodingFormat for every audio coding in output TVA file
        Examples:
        AudioCodingFormat - <Coding href="urn:mpeg:mpeg7:cs:AudioCodingFormatCS:2001:4.3.2">
        Audio coding - <Name xml:lang="nl-NL">AAC (ADTS)</Name>

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf_obolab.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf_obolab.py.
        :param path_to_output_tva: absolute path to output tva xml file to analyze
        :return: empty string if format is correct, Fail massage in case of incorrect format
        """
        e2e_obj = E2E(lab_name=lab_name, e2e_conf=conf)

        expected_values = {
            # "audio coding": "AudioCodingFormat",
            "AC-3": "1",
            "E-AC-3": "1.1",
            "MPG_1": "3.1",
            "MPG_2": "3.2",
            "AAC (ADTS)": "4.3.2",
            "AAC (LATM)": "4.3.1"
        }

        failed_reason = ""
        actual_values = e2e_obj.get_audio_coding_formats_from_output_tva_file(path_to_output_tva)
        for key, value in list(actual_values.items()):
            if len(value) != 1:
                failed_reason += "'%s' audio coding has more then one value of AudioCodingFormat: %s. " \
                                % (key, value)

        if not failed_reason:
            for key, value in list(actual_values.items()):
                if value[0] != expected_values[key]:
                    failed_reason += "Incorrect value %s of AudioCodingFormat for %s audio coding. " \
                                     % (value, key)

        self.log_variables(self.check_audio_coding_formats, locals())
        return  failed_reason

    @easy_debug
    def check_images_fqdn_in_output_tva_file(self, lab_name, conf, path_to_output_tva):
        """Keyword to check that images URL in output tva file use FQDNs, not IPs

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf_obolab.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf_obolab.py.
        :param path_to_output_tva: absolute path to output tva xml file to analyze
        :return: empty string if check is correct, Fail massage in case check was failed
        """
        failed_reason = ""
        helpers_obj = E2E(lab_name=lab_name, e2e_conf=conf)
        images = helpers_obj.get_images_from_output_tva_file(path_to_output_tva)
        hosts = []
        for image in images:
            hosts.append(helpers_obj.get_host_from_url(image))

        for host in hosts:
            # check host is FQDN, not IP
            if not re.match("(?=^.{4,253}$)(^((?!-)[a-zA-Z0-9-]{0,62}[a-zA-Z0-9]\.)+[a-zA-Z]{2,63}$)", host):  # pylint: disable=W1401
                if not failed_reason:
                    failed_reason = "Output TVA file %s contain images URLs without FQDN:" % path_to_output_tva
                failed_reason += " Host %s ." % host
        self.log_variables(self.check_images_fqdn_in_output_tva_file, locals())
        return failed_reason

    @easy_debug
    def check_transcoding_job_polling_interval(self, lab_name, conf, transcoder_workers_logs_masks, expected_polling_interval=10):
        """ Method to validate transcoding job polling interval. Details here https://jira.lgi.io/browse/HES-2051

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf_obolab.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf_obolab.py.
        :param list of transcoder_workers_logs_masks from ingestion results object:
        :param expected_polling_interval: default value of transcoding_job_polling_interval
        :return: If actual interval more then expected, failed reason will be returned. Else - empty string
        """
        expected_polling_interval = int(expected_polling_interval)
        failed_reason = ""
        current_polling_intervals_list = []
        helpers_obj = E2E(lab_name=lab_name, e2e_conf=conf)
        log_to_analyze_for_assets_workflow = "transcode_movie_stb_assets"
        log_to_analyze_for_transcoding_driven_workflow = "transcode_assets"
        log_mask = ""

        for mask in transcoder_workers_logs_masks:
            if log_to_analyze_for_assets_workflow in mask or log_to_analyze_for_transcoding_driven_workflow in mask:
                log_mask = mask
        if log_mask:
            # log_data = mock_data["robot"]["Libraries"]["IngestionE2E"]["keywords.py"]["check_transcoding_job_polling_interval"]["log_data"]
            if "SINGLE_LOGS_HOST" in os.environ:
                if os.environ['SINGLE_LOGS_HOST'] == "True":
                    log_data = helpers_obj.get_log_data(log_mask, False)
                else:
                    log_data = helpers_obj.get_log_data(log_mask, False, "TRANSCODER_WORKERS")
            else:
                log_data = helpers_obj.get_log_data(log_mask, False, "TRANSCODER_WORKERS")
            if log_data:
                date_time_pattern = "Subtask\: \[\d{4}\-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3}\] {{[a-z,_,.,-]+:\d+}} INFO -[ INFO -]*Performing GET request to"  # pylint: disable=anomalous-backslash-in-string
                matches = re.findall(date_time_pattern, log_data)
                data_time_list = []
                for string in matches:
                    data_time_list.append(string.split("Subtask: [")[1].split(" {{")[0].split("]")[0].split(",")[0])
                unique_data_time_list = list(set(data_time_list))
                time_list = [item.replace("-", "").replace(":", "").replace(" ", "") for item in
                             unique_data_time_list]
                time_list = sorted(time_list, reverse=True)
                for time_value in time_list:
                    # example of time_value: 20190122154156
                    current_value_index = time_list.index(time_value)
                    if current_value_index < len(time_list) - 1:
                        # example of previous_time_value: 20190122154146
                        previous_time_value = time_list[current_value_index + 1]
                        # work with seconds only
                        # example of seconds_time_value 56
                        time_value_seconds = time_value[-2:]
                        previous_time_value_seconds = previous_time_value[-2:]

                        time_value_seconds = int(time_value_seconds)
                        previous_time_value_seconds = int(previous_time_value_seconds)
                        # case example (begin of the minute): 5 - 55 = -50
                        if time_value_seconds < 10:
                            # will be: 65 - 55 = 10
                            time_value_seconds += 60
                        result = time_value_seconds - previous_time_value_seconds
                        # ignore 1 second fout
                        if result not in [1, 11, 61]:
                            current_polling_intervals_list.append(result)
                unique_current_polling_intervals_list = list(set(current_polling_intervals_list))
                for interval in unique_current_polling_intervals_list:
                    if expected_polling_interval != interval:
                        failed_reason += "Incorrect actual polling interval: %s. " % interval
                if len(unique_current_polling_intervals_list) > 1:
                    failed_reason += "Polling interval value is not single. %s" % list(unique_current_polling_intervals_list)
            else:
                self.log_variables(self.check_transcoding_job_polling_interval, locals())
                raise Exception("Empty data was returned from log %s" % log_mask)
        else:
            self.log_variables(self.check_transcoding_job_polling_interval, locals())
            raise Exception("%s and %s logs was not detected in the list of transcoder_workers_logs_masks" % (
                log_to_analyze_for_assets_workflow, log_to_analyze_for_transcoding_driven_workflow
            ))

        self.log_variables(self.check_transcoding_job_polling_interval, locals())
        return failed_reason

    @easy_debug
    def check_thumbnails_aspect_ratio(
            self, lab_name, conf, path_to_output_tva, sample_id, airflow_workers_logs_masks, fabrix_asset_ids_info):
        """A method to validate list of aspect ratio of all thumbnails images from output TVA file
        with expected values

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf_obolab.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf_obolab.py.
        :param path_to_output_tva: absolute path to output tva xml file to analyze
        :param sample_id: id of the sample, as ts0000 or ts1111
        :param airflow_workers_logs_masks: list of path to Airflow worker logs
        :param fabrix_asset_ids_info: dictionary from results object with information about particular fabrix_asset_id, like movie_type, device_type and aspect ratio
        :return: empty string if validation was passed, fail message otherwise
        """
        fail_reason = ""
        helpers_obj = E2E(lab_name=lab_name, e2e_conf=conf)
        # expected_aspect_ratio = {
        #     "ts0000": [1.78],
        #     "ts1111": [1.78],
        #     "ts0142": [1.33, 1.78],
        #     "ts0145": [1.33, 1.78],
        #     "ts0201": [1.33, 1.78],
        #     "ts0220": [1.78]
        # }
        expected_aspect_ratio = []
        for asset_id in fabrix_asset_ids_info:
            expected_aspect_ratio.append(
                round(
                    float(fabrix_asset_ids_info[asset_id]["aspect_ratio"]),
                    2
                )
            )
        # use unique values only
        expected_aspect_ratio = list(set(expected_aspect_ratio))

        all_aspect_ratio = helpers_obj.get_all_thumbnails_aspect_ratio_from_output_tva(
            path_to_output_tva, airflow_workers_logs_masks)
        if isinstance(all_aspect_ratio, list):
            if all_aspect_ratio != expected_aspect_ratio:
                fail_reason = "Incorrect aspect ratio for %s: %s. Expected %s" % (
                    sample_id, all_aspect_ratio, expected_aspect_ratio)
            self.log_variables(self.check_thumbnails_aspect_ratio, locals())
        else:
            fail_reason = "%s for sample id %s" % (all_aspect_ratio, sample_id)
        return fail_reason

    @easy_debug
    def check_thumbnails_upload(
            self, lab_name, conf, package_name, airflow_workers_logs_masks, fabrix_asset_ids_info,
            delay=30):
        """A method to validate thumbnails upload:
            * thumbnails_workflow_enabled
            * count of all_thumbnails_urls
            * check of actual_aspect_ratio

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf_obolab.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf_obolab.py.
        :param package_name: name of package, string
        :param airflow_workers_logs_masks: list of path to Airflow worker logs
        :param fabrix_asset_ids_info: dictionary from results object with information about particular fabrix_asset_id, like movie_type, device_type and aspect ratio
        :param delay: time to wait in minutes
        :return: fail reason, string or empty string
        """
        helpers_obj = E2E(lab_name=lab_name, e2e_conf=conf)
        fail_reason = ""
        time_to_wait = datetime.datetime.now() + datetime.timedelta(minutes=delay)

        all_fabrix_asset_ids = list(fabrix_asset_ids_info.keys())

        thumbnails_workflow_enabled = helpers_obj.insure_thumbnails_workflow_enabled(
            airflow_workers_logs_masks)

        if thumbnails_workflow_enabled:
            for asset_id in all_fabrix_asset_ids:

                all_thumbnails_urls = []
                while not all_thumbnails_urls and (datetime.datetime.now() < time_to_wait):
                    all_thumbnails_urls = helpers_obj.get_all_thumbnails_urls(asset_id)

                if all_thumbnails_urls and isinstance(all_thumbnails_urls, list):

                    # BuiltIn().log_to_console(all_thumbnails_urls)
                    duration_seconds = helpers_obj.get_asset_general_duration_in_seconds(
                        package_name, asset_id)
                    # BuiltIn().log_to_console(duration_seconds)

                    if duration_seconds:
                        expected_thumbnails_count = int(duration_seconds / 10)

                        # BuiltIn().log_to_console(expected_thumbnails_count)
                        if len(all_thumbnails_urls) not in [
                                expected_thumbnails_count,
                                expected_thumbnails_count - 1]:
                            fail_reason += "Actual len (%s) of thumbnails_urls for asset %s. Expected: %s. " % (
                                len(all_thumbnails_urls), asset_id, expected_thumbnails_count
                            )

                        actual_thumbnails_count = helpers_obj.get_asset_thumbnails_count(package_name, asset_id)
                        # BuiltIn().log_to_console(expected_thumbnails_count)
                        if actual_thumbnails_count not in [
                                expected_thumbnails_count,
                                expected_thumbnails_count - 1]:
                            fail_reason += "Unexpected actual_thumbnails_count (%s) of thumbnails_urls for asset %s. Expected: %s. " % (
                                actual_thumbnails_count, asset_id, expected_thumbnails_count
                            )

                        for t_url in all_thumbnails_urls:
                            height, width = helpers_obj.get_thumbnails_size(t_url)
                            # BuiltIn().log_to_console("%sx%s" % (height, width))
                            actual_aspect_ratio = helpers_obj.get_image_aspect_ratio(height, width)
                            expected_aspect_ratio = round(float(fabrix_asset_ids_info[asset_id]["aspect_ratio"]), 2)
                            if actual_aspect_ratio != expected_aspect_ratio:
                                fail_reason += "Unexpected aspect_ratio (%s) of thumbnails for asset %s. Expected: %s. " % (
                                    actual_thumbnails_count, asset_id, expected_aspect_ratio
                                )
                    else:
                        fail_reason += "There was no duration detected for asset id %s. " % asset_id
                elif "Unexpected status code" in all_thumbnails_urls:
                    fail_reason = all_thumbnails_urls
                else:
                    fail_reason += "There was no thumbnails urls detected for asset id %s. " % asset_id
        else:
            fail_reason = "thumbnails_workflow was not enabled"

        self.log_variables(self.check_thumbnails_upload, locals())
        return fail_reason

    @easy_debug
    def get_all_manifest_urls_from_logs(self, lab_name, conf, log_masks, actual_dag):
        """Method to get all manifest url from logs like:
        /usr/local/airflow/logs/csi_lab_create_obo_assets_workflow/perform_movie_selene_video_qc/2019-03-25T11:50:58/1.log
        /usr/local/airflow/logs/csi_lab_create_obo_assets_workflow/perform_movie_ott_video_qc/2019-03-25T11:50:58/1.log
        /usr/local/airflow/logs/csi_lab_create_obo_assets_workflow/perform_movie_stb_video_qc/2019-03-25T11:50:58/1.log

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf_obolab.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf_obolab.py.
        :param actual_dag: DAG type used for the ingestion
        :param log_masks: list of path to logs from ingestion RESULT object
        :return: list of absolute path to Manifest urls
        """
        helpers_obj = E2E(lab_name=lab_name, e2e_conf=conf)
        all_device_types = ["ott", "stb", "selene"]
        all_manifest_urls = []
        transcoding_driven_workflows = ["csi_lab_create_obo_assets_transcoding_driven_workflow",
                                        "ecx_superset_create_obo_assets_transcoding_driven_workflow"]
        if actual_dag in transcoding_driven_workflows:
            all_manifest_urls = helpers_obj.get_manifest_url_from_log(log_masks, actual_dag)
        else:
            for device_type in all_device_types:
                url = helpers_obj.get_manifest_url_from_log(log_masks, actual_dag, device_type)
                all_manifest_urls.append(url)
        self.log_variables(self.get_all_manifest_urls_from_logs, locals())
        return all_manifest_urls

    @easy_debug
    def check_improper_image_indication(self, lab_name, conf, airflow_workers_logs_masks, change_image_extension):
        """A keyword to cover validation steps of HES-3654

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf_obolab.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf_obolab.py.
        :param airflow_workers_logs_masks: list of path to Airflow worker logs
        :param change_image_extension: list with two values, old and new image extension
        :return: fail reason string or empty string
        """
        helpers_obj = E2E(lab_name=lab_name, e2e_conf=conf)
        failed_reason = ""
        old_image_extantion = change_image_extension[0]
        new_image_extantion = change_image_extension[1]
        submit_images_to_image_service_log = ""
        perform_images_qc_for_image_service_log = ""
        warning_text_found = False
        error_text_found = False
        failed_text_found = False
        print(old_image_extantion)

        for log in airflow_workers_logs_masks:
            if "submit_images_to_image_service" in log:
                submit_images_to_image_service_log = log
            elif "perform_images_qc_for_image_service" in log:
                perform_images_qc_for_image_service_log = log

        if submit_images_to_image_service_log:
            s_i_to_i_s_log_data = helpers_obj.get_log_data(submit_images_to_image_service_log)
            warning_text = "WARNING - Failed to upload images"
            for line in s_i_to_i_s_log_data:
                if warning_text in line:
                    warning_text_found = True
                    if not new_image_extantion in line:
                        failed_reason += "Wrong image was bloked for ingestion. " \
                                         "'submit_images_to_image_service' log line: %s. " % line

            if not warning_text_found:
                failed_reason += "'%s' text was not found in 'submit_images_to_image_service' log. " % warning_text
        else:
            failed_reason += "'submit_images_to_image_service' log was not found in airflow_workers_logs_masks. "

        if perform_images_qc_for_image_service_log:
            p_i_qc_for_i_s_log_data = helpers_obj.get_log_data(perform_images_qc_for_image_service_log)
            error_text = "Image does not exist on Image Service by url"
            failed_text = "Marking task as FAILED"
            for line in p_i_qc_for_i_s_log_data:
                if error_text in line:
                    error_text_found = True
                    if new_image_extantion not in line:
                        failed_reason += "Wrong image was missed on a previous step of ingestion. " \
                                         "'perform_images_qc_for_image_service' log line: %s. " % line

                elif failed_text in line:
                    failed_text_found = True

            if not error_text_found:
                failed_reason += "'%s' text was not found in 'perform_images_qc_for_image_service' log. " % error_text
            if not failed_text_found:
                failed_reason += "'%s' text was not found in 'perform_images_qc_for_image_service' log. " % failed_text_found

        else:
            failed_reason += "'perform_images_qc_for_image_service' log was not found in airflow_workers_logs_masks. "

        self.log_variables(self.check_improper_image_indication, locals())
        return failed_reason

    @easy_debug
    def check_package_structure_in_managed_folder(self, lab_name, conf, path_to_output_tva_file):
        """A keyword for HES-985 test case to check package folder structure:
        See that directory has subdirs for each ProgramURL from output TVA,
        see that these subdirs have transcoded .ts files. Asset has only one TVA.xml

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf_obolab.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf_obolab.py.
        :param path_to_output_tva_file: absolute path to output_tva file
        :return: fail reason string or empty string
        """
        failed_reason = ""
        helpers_obj = E2E(lab_name=lab_name, e2e_conf=conf)
        lab_conf = conf[lab_name]
        ssh = [lab_conf["AIRFLOW_WORKERS"][0]["host"], lab_conf["AIRFLOW_WORKERS"][0]["port"],
               lab_conf["AIRFLOW_WORKERS"][0]["user"], lab_conf["AIRFLOW_WORKERS"][0]["password"]]
        package_folder = "/".join(path_to_output_tva_file.split("/")[:-2])
        program_urls_command = "cat %s | grep ProgramURL | grep -Po '[0-9a-f]{32}_[0-9a-f]{32}'" % path_to_output_tva_file
        program_urls = self.call_tools_method("run_ssh_cmd", lab_name, conf, *(ssh + [program_urls_command]))[0].splitlines()
        program_url_folders = []
        structure_of_package_folder, stderr = helpers_obj.get_directory_structure(ssh, package_folder)
        structure_of_package_folder = structure_of_package_folder.splitlines()
        if stderr:
            self.log_variables(self.check_package_structure_in_managed_folder,
                               locals())
            return stderr
        tva_file_found = False
        for entity in structure_of_package_folder:
            if entity in program_urls:
                program_url_folders.append(entity)
            elif entity.startswith("TVA_") and entity.endswith(".xml"):
                tva_file_found = True

        if not tva_file_found:
            failed_reason += "We didn't find TVA file inside of %s. " % package_folder
        if not program_url_folders:
            failed_reason += "We didn't find %s folders inside of %s. " % (program_urls, package_folder)
        if not sorted(program_urls) == sorted(program_url_folders):
            failed_reason += "We detected difference between program_urls %s and program_url_folders %s. " % \
                             (program_urls, program_url_folders)
        if program_url_folders:
            for folder_name in program_url_folders:
                program_url_folder = "%s/%s" % (package_folder, folder_name)
                structure_of_program_url_folders, stderr = helpers_obj.get_directory_structure(ssh, program_url_folder)
                structure_of_program_url_folders = structure_of_program_url_folders.splitlines()
                if stderr:
                    self.log_variables(
                        self.check_package_structure_in_managed_folder,
                        locals())
                    return stderr
                if structure_of_program_url_folders:
                    ts_file_fount = False
                    for entity in structure_of_program_url_folders:
                        if entity.endswith(".ts"):
                            ts_file_fount = True
                    if not ts_file_fount:
                        failed_reason += "We didn't find .ts files inside of %s. " % program_url_folder
                else:
                    failed_reason += "Nothing was fount inside of %s. " % program_url_folder

        self.log_variables(self.check_package_structure_in_managed_folder, locals())
        return failed_reason

    @easy_debug
    def check_delete_obo_assets_db_workflow_was_run(
            self, lab_name, conf, package_name, expiration_date, delete_offset, fabrix_asset_id):
        """A method to check 'delete_obo_assets_db_workflow' based on steps from HES-7288

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf_obolab.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf_obolab.py.
        :param package_name: name of the package, string
        :param ingestion_start_time: time, when first job of ingestion was triggered
        :param new_time_delta: time delta when package have to be expired compare to ingestion start time
        :param fabrix_asset_id: fabrix_asset_id
        :return: fail reason, or empty
        """
        helpers_obj = E2E(lab_name=lab_name, e2e_conf=conf)
        fail_reason = ""
        expected_delete_workflow_jobs = [
            "expire_metadata_on_mag_and_prodis",
            "validate_prodis_mag_ingest",
            "unregister_assets_on_license_server",
            "remove_assets_from_fabrix",
            "remove_images_from_poster_servers",
            "remove_assets_from_thumbnail_service",
            "remove_package_from_managed",
            "remove_package_data_from_db",
            "delete_airflow_references"
        ]
        delete_workflow = "ecx_superset_delete_obo_assets_db_workflow"
        actual_delete_workflow_jobs = []
        actual_delete_workflow_logs = []
        delete_offset = int(delete_offset)
        maximum_expected_delete_offset = datetime.timedelta(minutes=delete_offset)
        expiration_date = datetime.datetime.strptime(expiration_date, "%Y-%m-%dT%H:%M:%SZ")
        maximum_delete_workflow_start_time = expiration_date + maximum_expected_delete_offset
        maximum_time_to_keep_trying = expiration_date + datetime.timedelta(
            minutes=(delete_offset + 240))
        while maximum_time_to_keep_trying > datetime.datetime.utcnow():
            utc_time_now = datetime.datetime.utcnow()
            print(utc_time_now)
            # BuiltIn().log_to_console("\nmaximum_time_to_keep_trying: %s" % maximum_time_to_keep_trying)
            # BuiltIn().log_to_console("utc_time_now: %s" % utc_time_now)
            BuiltIn().log_to_console("\nI'm going to check was Delete workflow Done or not yet...")

            helpers_obj.packages[package_name] = {}
            helpers_obj.packages[package_name]["airflow_workers_logs_masks"] = []
            helpers_obj.packages[package_name]["transcoder_workers_logs_masks"] = []
            helpers_obj.packages[package_name]["fabrix_asset_id"] = fabrix_asset_id
            helpers_obj.collect_log_files_masks(package_name)
            # helpers_obj.packages[package_name]["airflow_workers_logs_masks"] = mock_data["robot"]["Keywords"]["ingestion.basic.robot"]["Run Ingestion Suite"]["results-3"]["HES-2139"]["packages"][package_name]["airflow_workers_logs_masks"]
            airflow_workers_logs_masks = helpers_obj.packages[package_name]["airflow_workers_logs_masks"]
            if airflow_workers_logs_masks:
                for log_path in airflow_workers_logs_masks:
                    if delete_workflow in log_path:
                        delete_workflow_job = log_path.split(delete_workflow)[1].split("/")[1]
                        if delete_workflow_job not in actual_delete_workflow_jobs:
                            actual_delete_workflow_jobs.append(delete_workflow_job)
                            actual_delete_workflow_logs.append(log_path)
            else:
                fail_reason += "We didn't find 'airflow_workers_logs_masks'. "
                break
            log_actual_delete_workflow_jobs = actual_delete_workflow_jobs
            print(log_actual_delete_workflow_jobs)
            if not sorted(actual_delete_workflow_jobs) == sorted(expected_delete_workflow_jobs):
                local_time_zone = reference.LocalTimezone()
                time_to_sleep = 300  # sec
                if not actual_delete_workflow_jobs:
                    maximum_delete_workflow_local_start_time = maximum_delete_workflow_start_time \
                        .replace(tzinfo=pytz.utc) \
                        .astimezone(local_time_zone) \
                        .strftime("%H:%M:%S")
                    BuiltIn().log_to_console("\nDelete workflow is not started yet. "
                                             "It have to start at %s. "
                                             "Sleep %s sec...........\n" %
                                             (maximum_delete_workflow_local_start_time, time_to_sleep))
                else:
                    BuiltIn().log_to_console("%s != %s" % (
                        sorted(actual_delete_workflow_jobs), sorted(expected_delete_workflow_jobs)))
                    maximum_local_time_to_keep_trying = maximum_time_to_keep_trying\
                        .replace(tzinfo=pytz.utc)\
                        .astimezone(local_time_zone)\
                        .strftime("%H:%M:%S")
                    BuiltIn().log_to_console("\nDelete workflow is not Done yet. "
                                             "I'll keep trying to check until %s. "
                                             "Sleep %s sec...........\n" %
                                             (maximum_local_time_to_keep_trying, time_to_sleep))
                time.sleep(time_to_sleep)
            else:
                break

        first_workflow_job = "expire_metadata_on_mag_and_prodis"
        if first_workflow_job in actual_delete_workflow_jobs:
            log_file = ""
            for log in actual_delete_workflow_logs:
                if first_workflow_job in log:
                    log_file = log
            if log_file:
                delete_worflow_start_time_str = log_file.split("/")[-2]
                delete_worflow_start_time = datetime.datetime.strptime(
                    delete_worflow_start_time_str, "%Y-%m-%dT%H:%M:%S")
                actual_delete_offset = delete_worflow_start_time - expiration_date
                if actual_delete_offset > maximum_expected_delete_offset:
                    fail_reason += "Actual *_delete_expiration_offset more then %s minutes: %s" % \
                                   (str(delete_offset), str(actual_delete_offset))

        if sorted(actual_delete_workflow_jobs) != sorted(expected_delete_workflow_jobs):
            missed_jobs = []
            for expected_job in expected_delete_workflow_jobs:
                if expected_job not in actual_delete_workflow_jobs:
                    missed_jobs.append(expected_job)
            fail_reason += "'%s' jobs were not found. " % missed_jobs
        self.log_variables(self.check_delete_obo_assets_db_workflow_was_run,
                           locals())
        return fail_reason

    # pylint: disable=R0914,R0916,R0915
    @easy_debug
    def check_delete_workflow_logic(self, lab_name, conf, package_name,
                                    expiration_date, delete_offset,
                                    output_tva, all_fabrix_asset_ids):
        """Test steps from HES-3978

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf_obolab.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf_obolab.py.
        :param package_name: name of the package, string
        :param expiration_date: expiration date from TVA file, string. Example 2019-08-07T14:13:58Z
        :param delete_offset: Airflow "*_delete_expiration_offse" variable value, string.
        :param output_tva: absolute path to Output TVA file
        :param all_fabrix_asset_ids: list of all Fabrix asset IDs of the package
        :return: fail message or empty
        """
        helpers_obj = E2E(lab_name=lab_name, e2e_conf=conf)
        store_package_data_in_db_job_validated = False
        expire_metadata_on_mag_and_prodis_job_validated = False
        unregister_assets_on_license_server_job_validated = False
        remove_assets_from_fabrix_job_validated = False
        remove_assets_from_thumbnail_service_job_validated = False
        remove_package_from_managed_job_validated = False
        delete_airflow_references_job_validated = False

        # from "2019-08-07T14:13:58Z" to "2019-08-07 14:13:58"
        expected_expiration_date = expiration_date.replace("T", " ").replace("Z", "")
        expiration_date = datetime.datetime.strptime(expiration_date, "%Y-%m-%dT%H:%M:%SZ")
        maximum_time_to_keep_trying = expiration_date + datetime.timedelta(
            minutes=(int(delete_offset) + 240))
        fail_reason = ""
        if maximum_time_to_keep_trying < datetime.datetime.utcnow():
            fail_reason += "We was not able to check test logic as ADI expiration date is in the past. "
        while maximum_time_to_keep_trying > datetime.datetime.utcnow():
            utc_time_now = datetime.datetime.utcnow()
            print(utc_time_now)
            # BuiltIn().log_to_console("\nmaximum_time_to_keep_trying: %s" % maximum_time_to_keep_trying)
            # BuiltIn().log_to_console("utc_time_now: %s" % utc_time_now)
            BuiltIn().log_to_console("\nI'm going to check Delete workflow logic...")
            helpers_obj.packages[package_name] = {}
            helpers_obj.packages[package_name]["airflow_workers_logs_masks"] = []
            fabrix_asset_id = all_fabrix_asset_ids[0]
            helpers_obj.packages[package_name]["fabrix_asset_id"] = fabrix_asset_id
            helpers_obj.collect_log_files_masks(package_name)
            # helpers_obj.packages[package_name]["airflow_workers_logs_masks"] = mock_data["robot"]["Keywords"]["ingestion.basic.robot"]["Run Ingestion Suite"]["results-3"]["HES-2139"]["packages"][package_name]["airflow_workers_logs_masks"]
            airflow_workers_logs_masks = helpers_obj.packages[package_name][
                "airflow_workers_logs_masks"]
            if airflow_workers_logs_masks:

                store_package_data_in_db_log_path = ""
                expire_metadata_on_mag_and_prodis_log_path = ""
                unregister_assets_on_license_server_log_path = ""
                remove_assets_from_fabrix_log_path = ""
                remove_assets_from_thumbnail_service_log_path = ""
                remove_package_from_managed_log_path = ""
                delete_airflow_references_log_path = ""
                for log_path in airflow_workers_logs_masks:
                    if "store_package_data_in_db" in log_path:
                        store_package_data_in_db_log_path = log_path
                    if "expire_metadata_on_mag_and_prodis" in log_path:
                        expire_metadata_on_mag_and_prodis_log_path = log_path
                    if "unregister_assets_on_license_server" in log_path:
                        unregister_assets_on_license_server_log_path = log_path
                    if "remove_assets_from_fabrix" in log_path:
                        remove_assets_from_fabrix_log_path = log_path
                    if "remove_assets_from_thumbnail_service" in log_path:
                        remove_assets_from_thumbnail_service_log_path = log_path
                    if "remove_package_from_managed" in log_path:
                        remove_package_from_managed_log_path = log_path
                    if "delete_airflow_references" in log_path:
                        delete_airflow_references_log_path = log_path

                BuiltIn().log_to_console("step #3")
                if not store_package_data_in_db_job_validated:
                    new_fail_message = "We did't found 'store_package_data_in_db' log path. "
                    if store_package_data_in_db_log_path:
                        fail_reason = self.remove_fail_message_from_fail_reason_if_nesessary(
                            fail_reason, new_fail_message)
                        store_package_data_in_db_log_data = helpers_obj.get_log_data(
                            store_package_data_in_db_log_path, split_lines=False)
                        expected_log_string = "expiration_date='%s'" % expected_expiration_date
                        fail_reason = self.update_fail_reason_if_line_not_found_in_a_log(
                            expected_log_string, store_package_data_in_db_log_data,
                            store_package_data_in_db_log_path, fail_reason)[1]
                        store_package_data_in_db_job_validated = True
                    else:
                        fail_reason = self.update_fail_reason_if_nesessary(fail_reason, new_fail_message)

                BuiltIn().log_to_console("step #4")
                if not expire_metadata_on_mag_and_prodis_job_validated:
                    new_fail_message = "We din't get 'expire_metadata_on_mag_and_prodis_log_path' yet. "
                    if expire_metadata_on_mag_and_prodis_log_path:
                        fail_reason = self.remove_fail_message_from_fail_reason_if_nesessary(
                            fail_reason, new_fail_message)

                        expire_metadata_on_mag_and_prodis_log_date = \
                            helpers_obj.get_log_data(
                                expire_metadata_on_mag_and_prodis_log_path, split_lines=False)

                        fail_reason = self.update_fail_reason_if_line_not_found_in_a_log(
                            output_tva, expire_metadata_on_mag_and_prodis_log_date,
                            expire_metadata_on_mag_and_prodis_log_path, fail_reason)[1]

                        expected_log_string = "Updating fragmentExpirationDate to"
                        fail_reason = self.update_fail_reason_if_line_not_found_in_a_log(
                            expected_log_string, expire_metadata_on_mag_and_prodis_log_date,
                            expire_metadata_on_mag_and_prodis_log_path, fail_reason)[1]

                        output_tva_file = output_tva.split("/")[-1]
                        output_tva_file = output_tva_file.replace("_000001_", "_000002_")
                        expected_log_string = "Uploading the '%s' file into " \
                                              "'piksel-lgilabs-assets' Mag S3 bucket" % output_tva_file
                        fail_reason = self.update_fail_reason_if_line_not_found_in_a_log(
                            expected_log_string, expire_metadata_on_mag_and_prodis_log_date,
                            expire_metadata_on_mag_and_prodis_log_path, fail_reason)[1]

                        expire_metadata_on_mag_and_prodis_job_validated = True
                    else:
                        fail_reason = self.update_fail_reason_if_nesessary(fail_reason,
                                                                           new_fail_message)

                BuiltIn().log_to_console("step #5")
                if not unregister_assets_on_license_server_job_validated:
                    new_fail_message = "We din't get 'unregister_assets_on_license_server_log_path' yet. "
                    if unregister_assets_on_license_server_log_path:
                        fail_reason = self.remove_fail_message_from_fail_reason_if_nesessary(
                            fail_reason, new_fail_message)
                        unregister_assets_on_license_server_log_data = \
                            helpers_obj.get_log_data(
                                unregister_assets_on_license_server_log_path, split_lines=False)

                        fail_reason = self.update_fail_reason_if_line_not_found_in_a_log(
                            "irdeto", unregister_assets_on_license_server_log_data,
                            unregister_assets_on_license_server_log_path, fail_reason)[1]

                        fail_reason = self.update_fail_reason_if_line_not_found_in_a_log(
                            "Asset unregistered", unregister_assets_on_license_server_log_data,
                            unregister_assets_on_license_server_log_path, fail_reason)[1]

                        unregister_assets_on_license_server_job_validated = True

                    else:
                        fail_reason = self.update_fail_reason_if_nesessary(fail_reason,
                                                                           new_fail_message)

                BuiltIn().log_to_console("step #6")
                if not remove_assets_from_fabrix_job_validated:
                    new_fail_message = "We din't get 'remove_assets_from_fabrix_log_path' yet. "
                    if remove_assets_from_fabrix_log_path:
                        fail_reason = self.remove_fail_message_from_fail_reason_if_nesessary(
                            fail_reason, new_fail_message)
                        remove_assets_from_fabrix_log_data = helpers_obj.get_log_data(
                            remove_assets_from_fabrix_log_path, split_lines=False)
                        fail_reason = self.update_fail_reason_if_line_not_found_in_a_log(
                            "Asset removed", remove_assets_from_fabrix_log_data,
                            remove_assets_from_fabrix_log_path, fail_reason)[1]
                        remove_assets_from_fabrix_job_validated = True
                    else:
                        fail_reason = self.update_fail_reason_if_nesessary(fail_reason,
                                                                           new_fail_message)

                BuiltIn().log_to_console("step #7")
                if not remove_assets_from_thumbnail_service_job_validated:
                    new_fail_message = "We din't get 'remove_assets_from_thumbnail_service_log_path' yet. "
                    if remove_assets_from_thumbnail_service_log_path:
                        fail_reason = self.remove_fail_message_from_fail_reason_if_nesessary(
                            fail_reason, new_fail_message)

                        remove_assets_from_thumbnail_service_log_data = \
                            helpers_obj.get_log_data(
                                remove_assets_from_thumbnail_service_log_path, split_lines=False)

                        not_deleted_thumbnails = []
                        responded_thumbnails = []
                        for asset_id in all_fabrix_asset_ids:
                            expected_log_string = "Deleting thumbnails for '%s'" % asset_id
                            thumbnails_deleting_found, fail_reason = self.update_fail_reason_if_line_not_found_in_a_log(
                                expected_log_string, remove_assets_from_thumbnail_service_log_data,
                                remove_assets_from_thumbnail_service_log_path, fail_reason)
                            if not thumbnails_deleting_found:
                                not_deleted_thumbnails.append(asset_id)

                            host = conf[lab_name]["MICROSERVICES"]["STATICQBR"]
                            url = "https://%s/thumbnail-service/assets/%s" % (host, asset_id)
                            thumbnails_response = requests.get(url)
                            if thumbnails_response.status_code != 404:
                                BuiltIn().log_to_console("Unexpected status code %s when GET to %s" %
                                                         (thumbnails_response.status_code, url))
                                responded_thumbnails.append(asset_id)

                        if not_deleted_thumbnails or responded_thumbnails:
                            fail_reason += "not_deleted_thumbnails: %s. responded_thumbnails: %s. " % \
                                           (not_deleted_thumbnails, responded_thumbnails)
                        remove_assets_from_thumbnail_service_job_validated = True
                    else:
                        fail_reason = self.update_fail_reason_if_nesessary(fail_reason,
                                                                           new_fail_message)

                BuiltIn().log_to_console("step #8")
                if not remove_package_from_managed_job_validated:
                    new_fail_message = "We din't get 'remove_package_from_managed_log_path' yet. "
                    if remove_package_from_managed_log_path:
                        fail_reason = self.remove_fail_message_from_fail_reason_if_nesessary(
                            fail_reason, new_fail_message)
                        remove_package_from_managed_log_data = helpers_obj.get_log_data(
                            remove_package_from_managed_log_path, split_lines=False)

                        package_folder = "/".join(output_tva.split("/")[:-2])
                        expected_log_string = "Check path exists: %s" % package_folder
                        fail_reason = self.update_fail_reason_if_line_not_found_in_a_log(
                            expected_log_string, remove_package_from_managed_log_data,
                            remove_package_from_managed_log_path, fail_reason)[1]

                        fail_reason = self.update_fail_reason_if_line_not_found_in_a_log(
                            "Deleting directory", remove_package_from_managed_log_data,
                            remove_package_from_managed_log_path, fail_reason)[1]

                        fail_reason = self.update_fail_reason_if_line_not_found_in_a_log(
                            "Deleting file", remove_package_from_managed_log_data,
                            remove_package_from_managed_log_path, fail_reason)[1]

                        fail_reason = self.update_fail_reason_if_line_not_found_in_a_log(
                            "Done. Returned value was: None", remove_package_from_managed_log_data,
                            remove_package_from_managed_log_path, fail_reason)[1]

                        ssh = [conf[lab_name]["AIRFLOW_WORKERS"][0]["host"],
                               conf[lab_name]["AIRFLOW_WORKERS"][0]["port"],
                               conf[lab_name]["AIRFLOW_WORKERS"][0]["user"],
                               conf[lab_name]["AIRFLOW_WORKERS"][0]["password"]]
                        stdout, stderr = helpers_obj.get_directory_structure(ssh, package_folder)
                        if "No such file or directory" not in stderr:
                            fail_reason += "Unexpected ls -l responce after deleting. stdout: %s. stderr: %s. " % \
                                           (stdout, stderr)

                        remove_package_from_managed_job_validated = True
                    else:
                        fail_reason = self.update_fail_reason_if_nesessary(fail_reason,
                                                                           new_fail_message)

                BuiltIn().log_to_console("step #9")
                if not delete_airflow_references_job_validated:
                    new_fail_message = "We din't get 'delete_airflow_references_log_path' yet. "
                    if delete_airflow_references_log_path:
                        fail_reason = self.remove_fail_message_from_fail_reason_if_nesessary(
                            fail_reason, new_fail_message)
                        delete_airflow_references_log_data = helpers_obj.get_log_data(
                            delete_airflow_references_log_path, split_lines=False)

                        fail_reason = self.update_fail_reason_if_line_not_found_in_a_log(
                            "Dag runs were successfully deleted",
                            delete_airflow_references_log_data,
                            delete_airflow_references_log_path, fail_reason)[1]
                        delete_airflow_references_job_validated = True
                    else:
                        fail_reason = self.update_fail_reason_if_nesessary(fail_reason,
                                                                           new_fail_message)

            else:
                new_fail_message = "We didn't find 'airflow_workers_logs_masks'. "
                fail_reason = self.update_fail_reason_if_nesessary(fail_reason, new_fail_message)
                break

            if store_package_data_in_db_job_validated \
                    and expire_metadata_on_mag_and_prodis_job_validated \
                    and unregister_assets_on_license_server_job_validated \
                    and remove_assets_from_fabrix_job_validated \
                    and remove_assets_from_thumbnail_service_job_validated \
                    and remove_package_from_managed_job_validated \
                    and delete_airflow_references_job_validated:
                break
        self.log_variables(self.check_delete_workflow_logic,
                           locals())
        return fail_reason

    @easy_debug
    def update_fail_reason_if_line_not_found_in_a_log(
            self, expected_log_string, log_data, log_path, fail_reason):
        """Sub-method of 'check_delete_workflow_logic' method to prevent copy-paste"""
        found = False
        if expected_log_string in log_data:
            found = True
        else:
            new_fail_message = "We did't found %s string in %s log file. " % \
                               (expected_log_string,
                                log_path)
            fail_reason = self.update_fail_reason_if_nesessary(fail_reason,
                                                               new_fail_message)
            self.log_variables(self.update_fail_reason_if_line_not_found_in_a_log,
                               locals())
        return found, fail_reason

    @easy_debug
    def update_fail_reason_if_nesessary(self, fail_reason, new_fail_message):
        """ Simple method to update fail reason if fail message not present there yet"""
        if new_fail_message not in fail_reason:
            fail_reason += new_fail_message
            BuiltIn().log_to_console(new_fail_message)
            self.log_variables(self.update_fail_reason_if_nesessary,
                               locals())
        return fail_reason

    @easy_debug
    def remove_fail_message_from_fail_reason_if_nesessary(self, fail_reason, new_fail_message):
        """ Simple method to remove fail message from fail reason if fail message present there"""
        if new_fail_message in fail_reason:
            fail_reason = fail_reason.replace(new_fail_message, "")
            self.log_variables(self.remove_fail_message_from_fail_reason_if_nesessary,
                               locals())
        return fail_reason

    @easy_debug
    def submit_an_image_to_the_image_service(self, lab_name, conf, image_path, delay=30):
        """Test steps of HES-905 - Add ImageService to the linear_cycle

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf_obolab.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf_obolab.py.
        :param image_path: relative path to image what will be ingested
        :param delay: time in minutes to wait for ingestion DAG will be done
        :return: fail reason string or empty string
        """
        fail_reason = ""
        # put test image to linear_images_watch_folder
        host = conf[lab_name]["IMAGES_WATCH_FOLDER"]["host"]
        port = conf[lab_name]["IMAGES_WATCH_FOLDER"]["port"]
        username = conf[lab_name]["IMAGES_WATCH_FOLDER"]["user"]
        password = conf[lab_name]["IMAGES_WATCH_FOLDER"]["password"]
        remotepath = conf[lab_name]["IMAGES_WATCH_FOLDER"]["path"]
        args = (host, port, username, password, image_path, remotepath)
        self.call_tools_method("sftp_put_file", lab_name, conf, *args)

        # grep logs
        helpers_obj = E2E(lab_name=lab_name, e2e_conf=conf)
        image_name = image_path.split("/")[-1]
        # image_name = "ORG_FAIL_1.jpg"
        helpers_obj.packages[image_name] = {}
        helpers_obj.packages[image_name]["airflow_workers_logs_masks"] = []
        time_to_wait = datetime.datetime.now() + datetime.timedelta(minutes=delay)
        expected_logs = [
            "lookup_dir_images",
            "submit_images_to_image_service",
            "perform_images_qc_for_image_service"
        ]
        all_logs_present = False
        while datetime.datetime.now() < time_to_wait and not all_logs_present:
            actual_logs = []
            helpers_obj.collect_log_files_masks(image_name)
            logs_masks = helpers_obj.packages[image_name]["airflow_workers_logs_masks"]
            for log_path in logs_masks:
                for log in expected_logs:
                    if log in log_path and log not in actual_logs:
                        actual_logs.append(log)

            BuiltIn().log_to_console("\nexpected_logs: %s" % sorted(expected_logs))
            BuiltIn().log_to_console("\nactual_logs: %s\n" % sorted(actual_logs))

            if sorted(expected_logs) == sorted(actual_logs):
                all_logs_present = True
        if not all_logs_present:
            fail_reason += "Not all the logs were found!!! Expected: %s. Was found: %s" % (
                expected_logs, actual_logs
            )
        BuiltIn().log_to_console("DONE")

        # get image
        hostname = conf[lab_name]["MICROSERVICES"]["STATICQBR"]
        url = "https://%s/image-service/ImagesEPG/EventImages/%s" % (hostname, image_name)
        response = requests.get(url)
        if response.status_code != 200:
            fail_reason += "The image was not getting from image service. " \
                           "Status code: %s. Reason: %s" % (response.status_code, response.reason)
            self.log_variables(self.submit_an_image_to_the_image_service,
                               locals())
        return fail_reason

    @easy_debug
    def check_content_was_removed_from_vspp(
            self, lab_name, conf, package_ingestion_result, device_type):
        """By this keyword we check was content for device type(ott, stb) removed or not

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf_obolab.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf_obolab.py.
        :param package_ingestion_result: all ingestion results of single package
        :param device_type: OTT or STB
        :return: fail reason if contwent was not removed, othervice empty
        """
        fail_reason = ""
        external_ids = self.get_all_fabrix_id_for_device_type(device_type, package_ingestion_result)

        host = conf[lab_name]["FABRIX"][1]["host"]
        port = conf[lab_name]["FABRIX"][1]["port"]
        for external_id in external_ids:
            result = Fabrix.get_asset_by_external_id(host, port, external_id)
            if isinstance(result, requests.Response):
                status_code = result.status_code
                reason = result.reason
                if status_code != 404:
                    fail_reason += "Unexpected status code %s was returned from Fabrix. " \
                                   "Reason: %s. " % (status_code, reason)
            else:
                try:
                    valid_xml = xmltodict.parse(result)
                    if valid_xml:
                        fail_reason += "Asset %s is still present in Fabrix. " % external_id
                except ExpatError:
                    fail_reason = "Unexpected response from Fabrix for %s id:\n%s" % \
                                  (external_id, result)
        self.log_variables(
            self.check_content_was_removed_from_vspp, locals())
        return fail_reason

    @easy_debug
    def check_single_asset_was_removed_from_vspp(
            self, lab_name, conf, external_id):
        """By this keyword we check was single removed or not

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf_obolab.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf_obolab.py.
        :param external_id: Fabrix asset ID, like 80f3e0ddc1134c240e24f11bc762eda1_ec80816b362f47f54c637f2ad253deb4
        :return: fail reason if contwent was not removed, othervice empty
        """
        fail_reason = ""

        host = conf[lab_name]["FABRIX"][1]["host"]
        port = conf[lab_name]["FABRIX"][1]["port"]
        result = Fabrix.get_asset_by_external_id(host, port, external_id)
        if isinstance(result, requests.Response):
            status_code = result.status_code
            reason = result.reason
            if status_code != 404:
                fail_reason += "Unexpected status code %s was returned from Fabrix. " \
                               "Reason: %s. " % (status_code, reason)
        else:
            try:
                valid_xml = xmltodict.parse(result)
                if valid_xml:
                    fail_reason = "Asset %s is still present in Fabrix. " % external_id
            except ExpatError:
                fail_reason = "Unexpected response from Fabrix for %s id:\n%s" % \
                              (external_id, result)
        self.log_variables(
            self.check_single_asset_was_removed_from_vspp, locals())
        return fail_reason

    @easy_debug
    def get_all_fabrix_id_for_device_type(self, device_type, package_ingestion_result):
        """By this keyword we collect list of fabrix asset IDs related to particular divice type,
        as OTT or STB

        :param device_type: OTT or STB
        :param package_ingestion_result: all ingestion results of single package
        :return: list of collected Fabrix external ids
        """
        external_ids = []
        for fabrix_asset_id in list(package_ingestion_result["fabrix_asset_ids_info"].keys()):
            id_info = package_ingestion_result["fabrix_asset_ids_info"][fabrix_asset_id]
            if id_info["device_type"] == device_type.lower():
                external_ids.append(fabrix_asset_id)
        self.log_variables(self.get_all_fabrix_id_for_device_type,
                           locals())
        return external_ids

    # pylint: disable=dangerous-default-value
    @easy_debug
    def check_dag_run_was_done_after_particular_time(
            self, lab_name, conf, package_name, dag_id,
            ingestion_init_time, run_ids_to_ignore=[], delay=180, pause=600, api_url=None):
        """By this keyword we check was particular dur_run runned ofter particular time stamp
        We check that package name is present in run_id and status of this run is "success"

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf_obolab.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf_obolab.py.
        :param package_name: name of the package
        :param dag_id: DAG name, as "ecx_superset_create_obo_assets_transcoding_driven_workflow"
        :param ingestion_init_time: time stamp to be used as value of "execution_date__gt"
        :param run_ids_to_ignore: IDs of the run, what have to be ignored
        :param delay: time to wait
        :param pause: time for pause
        :param api_url: defailt url will be used at the begining, then in recursion url of a next page
        :return: fail reason of success dug run was not found, or empty
        """
        delay = int(delay)
        pause = int(pause)
        fail_reason = ""
        host = conf[lab_name]["AIRFLOW_API"]["host"]
        if api_url:
            url = api_url
        else:
            url = "http://%s/dag_runs?execution_date__gt=%s&dag_id=%s&relations=tasks" % \
                  (host, ingestion_init_time, dag_id)
        BuiltIn().log_to_console("API url is: %s" % url)
        time_to_wait = datetime.datetime.now() + datetime.timedelta(minutes=delay)
        while datetime.datetime.now() < time_to_wait:
            response = requests.get(url)
            if response.status_code == 200:
                dag_runs = response.json()
                run_data, run_state = self._get_run_data_and_run_state(package_name, dag_runs,
                                                                       run_ids_to_ignore)
                if not run_data and "next" in list(dag_runs.keys()):
                    next_page = dag_runs["next"]
                    BuiltIn().log_to_console("I'll go to next page of API responce: %s" % next_page)
                    # Recursion is here
                    return self.check_dag_run_was_done_after_particular_time(
                        lab_name, conf, package_name, dag_id,
                        ingestion_init_time, run_ids_to_ignore,
                        delay, pause, api_url=next_page)
                if run_data:
                    run_id = run_data["run_id"]
                    BuiltIn().log_to_console("Dug run %s. State: '%s'" % (run_id, run_state))

                    if run_state == "running":
                        BuiltIn().log_to_console("Wait %s sec..." % pause)
                        time.sleep(pause)
                    else:
                        if run_state == "success":
                            self.log_variables(
                                self.check_dag_run_was_done_after_particular_time,
                                locals())
                        elif run_state == "failed":
                            fail_reason = "Dug run of %s was failed. Json:\n%s" % \
                                          (package_name, run_data)
                            self.log_variables(
                                self.check_dag_run_was_done_after_particular_time,
                                locals())
                        return fail_reason, run_data
                else:
                    BuiltIn().log_to_console("Dug run of %s. State: NOT started yet" % package_name)
                    BuiltIn().log_to_console("Wait %s sec..." % pause)
                    time.sleep(pause)
            else:
                fail_reason = "Wrong response when trying to reach dag runs from API." \
                       "Status code: %s. Reason: %s" % (response.status_code, response.reason)
                self.log_variables(
                    self.check_dag_run_was_done_after_particular_time,
                    locals())
                return fail_reason, {}
        if run_data:  # pylint: disable=no-else-return
            fail_reason = "Dug run of %s is still running after %s minutes of waiting" % \
                          (package_name, delay)
            self.log_variables(self.check_dag_run_was_done_after_particular_time,
                               locals())
            return fail_reason, run_data
        else:
            fail_reason = "Dug run of %s was not started after %s minutes of waiting" % \
                          (package_name, delay)
            self.log_variables(self.check_dag_run_was_done_after_particular_time,
                               locals())
            return fail_reason, {}

    @easy_debug
    def _get_run_data_and_run_state(self, package_name, dag_runs, run_ids_to_ignore):
        """Sub-method of self.check_dag_run_was_done_after_particular_time"""
        # BuiltIn().log_to_console("\nurl: %s" % url)
        # BuiltIn().log_to_console("dag_runs: %s\n" % dag_runs)
        run_data = {}
        run_state = ""
        for run in dag_runs["items"]:
            #     BuiltIn().log_to_console("package_name: %s" % package_name)
            #     BuiltIn().log_to_console("run_id: %s" % run["run_id"])
            if package_name in run["run_id"]:
                run_id = run["run_id"]
                if run_id  in run_ids_to_ignore:
                    BuiltIn().log_to_console("I'm ignoring run %s" % run_id)
                else:
                    run_data = run
                    run_state = run_data["state"]
                    break
        self.log_variables(self._get_run_data_and_run_state, locals())
        return run_data, run_state

    @easy_debug
    def check_linked_assets_was_ingested_after_particular_time(
            self, lab_name, conf, unique_title_id, assets_quantity, dag_id,
            ingestion_init_time, delay=240):
        """A method to determinate was linked (by unique_title_id) assets was successfuly ingested

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf_obolab.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf_obolab.py.
        :param unique_title_id: Value of "Unique_Title_Id" in ADI.XML file
        :param assets_quantity: amount of linked assets
        :param dag_id: name of the DAG, string
        :param ingestion_init_time: time, when ingestin was started
        :param delay: time to wait
        :return: failed reason or empty
        """
        run_ids_to_ignore = []
        results = {}
        for i in range(0, int(assets_quantity)):
            BuiltIn().log_to_console("Run #%s" % i)
            fail_reason, run_data = self.check_dag_run_was_done_after_particular_time(
                lab_name, conf, unique_title_id, dag_id,
                ingestion_init_time, run_ids_to_ignore=run_ids_to_ignore, delay=delay)
            if run_data and not fail_reason:
                results[run_data["filename"]] = run_data
                run_ids_to_ignore.append(run_data["run_id"])
                BuiltIn().log_to_console("\nResults 'with TVA': %s\n" % results)
            else:
                BuiltIn().log_to_console("I've broke the loop. Fail reson: %s" % fail_reason)
                break
        # results = mock_data["robot"]["Libraries"]["IngestionE2E"]["keywords.py"]["get_ingestion_results"]["no_og_package"]["linked_packages_results"]
        if results:
            helpers_obj = E2E(lab_name=lab_name, e2e_conf=conf)
            results_keys = list(results.keys())
            logs_folder = conf[lab_name]["AIRFLOW_WORKERS"][0]["logs_folder"]
            for i, val in enumerate(results_keys):
                pattern = "ts\d{4}_\d{8}_\d{6}pt"  # pylint: disable=anomalous-backslash-in-string
                path_to_log = ""
                for task in results[val]["tasks"]:
                    log_url = task["log_url"]
                    if "check_assets" in log_url:
                        # log_execution_time = "2019-09-18T14:56:28"
                        BuiltIn().log_to_console("\nlog_url : %s" % log_url)
                        log_execution_time = log_url.split("execution_date=")[1]
                        # log_execution_time_utc = (
                        #     datetime.datetime.strptime(
                        #         log_execution_time, "%Y-%m-%dT%H:%M:%S") -
                        #     datetime.timedelta(hours=1)
                        # ).strftime('%Y-%m-%dT%H:%M:%S')
                        path_to_log = "%s/%s/check_assets/%s/1.log" % \
                                      (logs_folder, dag_id, log_execution_time)
                package_name = helpers_obj.get_package_name_from_log(path_to_log, pattern)
                # change 'results' dict keys from tva to package name
                results[package_name] = results.pop(val)
            BuiltIn().log_to_console("\nResults 'with package name': %s\n" % results)
        self.log_variables(
            self.check_linked_assets_was_ingested_after_particular_time,
            locals())
        return results

    @easy_debug
    def collect_all_package_fafrix_external_asset_ids(
            self, lab_name, conf, package_name, package_or_offer="pt"):
        """A method to get all fafrix_external_asset_ids of the package when you
        have only package name

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf_obolab.py.
        :param conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf_obolab.py.
        :param package_name: name of the package, string
        :param package_or_offer: package or offer based on end of the package name ("pt" or "or")
        :return: external_asset_ids list
        """
        if package_or_offer == "pt":
            package_name = package_name.replace("ot", "pt")
        elif package_or_offer == "ot":
            package_name = package_name.replace("pt", "ot")
        external_asset_ids = []
        helpers_obj = E2E(lab_name=lab_name, e2e_conf=conf)
        helpers_obj.packages[package_name] = {}
        helpers_obj.packages[package_name]["airflow_workers_logs_masks"] = []
        helpers_obj.packages[package_name]["transcoder_workers_logs_masks"] = []
        helpers_obj.collect_log_files_masks(package_name, look_for_subpackage=True)
        external_asset_ids = helpers_obj.get_all_package_fafrix_external_asset_ids(package_name)
        self.log_variables(
            self.collect_all_package_fafrix_external_asset_ids, locals())
        return external_asset_ids

    @easy_debug
    def dummy_method(self, x):
        """Dummy method to check what ever you need"""
        x = int(x)
        # a = 1
        # b = 5
        # c = "rttyrew"
        result = x * 2
        self.log_variables(
            self.dummy_method, locals())
        return result
