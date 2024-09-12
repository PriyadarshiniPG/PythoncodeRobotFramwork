# pylint: skip-file
# pylint: disable=unused-argument
# Disabled pylint "unused-argument" since it's required,
# but internal in mocked functions.
"""Unit tests of IngestionE2E library's keywords for Robot Framework.

Tests use mock module and do not establish real connections with real servers.
The global function debug() can be used for testing real ingestion process in real lab.
"""

import os
import sys
import inspect
import socket
import re
import datetime
import json
currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
lib_dir = os.path.dirname(currentdir)
robot_dir = os.path.dirname(lib_dir)
sys.path.append(robot_dir)
from import_file import import_file
try:
    from io import StringIO
except ImportError:
    from io import StringIO
import io
import unittest
try:
    import mock
except ImportError:
    import unittest.mock as mock
import xmltodict
import paramiko
import pysftp
from pysftp.exceptions import CredentialException
import xml.etree.ElementTree as ElementTree
import urllib.request, urllib.parse, urllib.error
import ast
import requests
from shutil import copyfile
from pathlib import Path
import subprocess
from Libraries.IngestionE2E.keywords import Keywords
from Libraries.IngestionE2E.tools import Tools
from Libraries.IngestionE2E.helpers import E2E as helpers
from Libraries.IngestionE2E.health import HealthChecks
from Libraries.general.keywords import Keywords as general
general_keywords = general()
from robot.libraries.BuiltIn import BuiltIn
import types

current_dir = os.path.dirname(os.path.realpath(__file__))
mock_data = import_file("%s/../../resources/stages/mock_data/data.py" % current_dir).MOCK_DATA


E2E_CONF = {
    "mock": {
        "FABRIX": [{"host": "10.10.10.10", "port": 5929},
                   {"host": "10.10.10.00", "port": 5929}],
        "AIRFLOW_WORKERS": [{"host": "10.10.10.11", "port": 22,
                             "user": "admin", "password": "admin",
                             "logs_folder": "/usr/local/airflow/logs",
                             "path": "/var/logs",
                             "managed_folder": "some/path",
                             "watch_folder": "some/path"},
                            {"host": "10.10.10.12", "port": 22,
                             "user": "admin", "password": "admin",
                             "logs_folder": "/usr/local/airflow/logs",
                             "path": "/var/logs",
                             "managed_folder": "some/path",
                             "watch_folder": "some/path"}
                           ],
        "AIRFLOW_WORKERS_JUMP_SERVER": {"host": "10.10.10.13", "port": 22,
                             "user": "admin", "password": "admin",
                             "logs_folder": "/usr/local/airflow/logs",
                             "path": "/var/logs",
                             "managed_folder": "some/path",
                             "watch_folder": "some/path"},
        "TRANSCODER_WORKERS": [{"host": "10.10.10.14", "port": 22,
                             "user": "admin", "password": "admin",
                             "logs_folder": "/usr/local/airflow/logs",
                             "path": "/var/logs",
                             "managed_folder": "some/path",
                             "watch_folder": "some/path"},
                            {"host": "10.10.10.15", "port": 22,
                             "user": "admin", "password": "admin",
                             "logs_folder": "/usr/local/airflow/logs",
                             "path": "/var/logs",
                             "managed_folder": "some/path",
                             "watch_folder": "some/path"}
                           ],
        "TRANSCODER_WORKERS_JUMP_SERVER": {"host": "10.10.10.16", "port": 22,
                             "user": "admin", "password": "admin",
                             "logs_folder": "/usr/local/airflow/logs",
                             "path": "/var/logs",
                             "managed_folder": "some/path",
                             "watch_folder": "some/path"},
        "AIRFLOW_WEB": {"host": "some.host.com", "port": 22,
                        "user": "user", "key_path": "horizongodevepam_missing.pem"},
        "AIRFLOW_API": {
            "host": "some.host.com"
        },
        "ASSET_GENERATOR": {"host": "10.10.10.17", "port": 22,
                            "user": "admin ", "password": "admin",
                            "path": "/var/logs"},
        "MICROSERVICES" : {
            "STATICQBR": "some.fqdn"
        },
        "OG": [{"host": "11.10.10.11", "port": 22,
                             "user": "admin", "password": "admin",
                             "logs_folder": "/usr/local/airflow/logs",
                             "path": "/var/logs",
                             "managed_folder": "some/path",
                             "watch_folder": "some/path"},
                            {"host": "12.10.10.12", "port": 22,
                             "user": "admin", "password": "admin",
                             "logs_folder": "/usr/local/airflow/logs",
                             "path": "/var/logs",
                             "managed_folder": "some/path",
                             "watch_folder": "some/path"}
                           ],
    }
}

tools = Tools(E2E_CONF["mock"])

SSH = [E2E_CONF["mock"]["AIRFLOW_WORKERS"][0]["host"], E2E_CONF["mock"]["AIRFLOW_WORKERS"][0]["port"],
       E2E_CONF["mock"]["AIRFLOW_WORKERS"][0]["user"], E2E_CONF["mock"]["AIRFLOW_WORKERS"][0]["password"]]

BAD_METADATA = [
    {
        "xpath_locate": "./Asset/Asset/Metadata/AMS[@Asset_Class='poster']",
        "xpath_change": ".",
        "attrs": {"Asset_Name": "POSTER", "Asset_ID": "POSTER"},
        "cmd": "",
    },
    {
        "xpath_locate": "./Asset/Asset/Metadata/AMS[@Asset_Class='poster']",
        "xpath_change": "../../Content",
        "attrs": {"Value": "POSTER.JPG"},
        "cmd": "cd %(dir_to_adi)s && ls -l && mv %(old_val)s POSTER.JPG && ls -l POSTER.JPG",
    },
    {
        "xpath_locate": "./Asset/Asset/Metadata/AMS[@Asset_Class='box-cover']",
        "xpath_change": ".",
        "attrs": {"Asset_Name": "BOX-COVER", "Asset_ID": "BOX-COVER"},
        "cmd": "",
    },
    {
        "xpath_locate": "./Asset/Asset/Metadata/AMS[@Asset_Class='box-cover']",
        "xpath_change": "../../Content",
        "attrs": {"Value": "BOX-COVER.JPG"},
        "cmd": "cd %(dir_to_adi)s && ls -l && mv %(old_val)s BOX-COVER.JPG && ls -l BOX-COVER.JPG",
    },
    {
        "xpath_locate": "./Asset/Metadata/AMS[@Asset_Class='title']",
        "xpath_change": "../App_Data[@Name='Licensing_Window_Start']",
        "attrs": {"Value": -365},
        "cmd": "",
    },
    {
        "xpath_locate": "./Asset/Metadata/AMS[@Asset_Class='title']",
        "xpath_change": "../App_Data[@Name='Licensing_Window_End']",
        "attrs": {"Value": -365},
        "cmd": "",
    },
    {
        "xpath_locate": "./Asset/Asset/Metadata/AMS[@Asset_Class='movie']",
        "xpath_change": "../App_Data[@Name='Content_CheckSum']",
        "attrs": {"Value": "abc"},
        "cmd": "",
    },
]

FOLDER = os.path.dirname(os.path.abspath(__file__))

with io.open(os.path.join(FOLDER, "samples/TVA_ts1111_original.xml"), "r+", encoding="utf-8") as _f:
    TVA_ts1111_XML = tools.filter_chars(_f.read())

with io.open(os.path.join(FOLDER, "samples/ADI_XML_sample.txt"), "r+", encoding="utf-8") as _f:
    ADI_XML = tools.filter_chars(_f.read())

def remove_asset_subnode(adi_xml):
    xml_bytes = adi_xml.encode("UTF-8")
    xml = ElementTree.fromstring(xml_bytes)
    asset_node = xml.find("Asset")
    for child in asset_node.findall("Asset"):
        for ams in child.iter('AMS'):
            if ams.attrib["Asset_Class"] == "movie":
                asset_node.remove(child)
    return general.insure_text(ElementTree.tostring(xml))

ADI_XML_NONE_ASSET_SUBNODE = remove_asset_subnode(ADI_XML)

with io.open(os.path.join(FOLDER, "samples/ADI_XML_block_ott.txt"), "r+", encoding="utf-8") as _f:
    ADI_XML_BLOCK_OTT = tools.filter_chars(_f.read())

with io.open(os.path.join(FOLDER, "samples/output_tva_ts1111.txt"), "r+", encoding="utf-8") as _f:
    OUTPUT_TVA_TS1111 = tools.filter_chars(_f.read())

with io.open(os.path.join(FOLDER, "samples/output_tva_ts0000.txt"), "r+", encoding="utf-8") as _f:
    OUTPUT_TVA_TS0000 = tools.filter_chars(_f.read())

with io.open(os.path.join(FOLDER, "samples/output_tva_ts0142.txt"), "r+", encoding="utf-8") as _f:
    OUTPUT_TVA_TS0142 = tools.filter_chars(_f.read())

with io.open(os.path.join(FOLDER, "samples/output_tva_ts0145.txt"), "r+", encoding="utf-8") as _f:
    OUTPUT_TVA_TS0145 = tools.filter_chars(_f.read())

with io.open(os.path.join(FOLDER, "samples/output_tva_ts0201.txt"), "r+", encoding="utf-8") as _f:
    OUTPUT_TVA_TS0201 = tools.filter_chars(_f.read())

with io.open(os.path.join(FOLDER, "samples/output_tva_ts0220.txt"), "r+", encoding="utf-8") as _f:
    OUTPUT_TVA_TS0220 = tools.filter_chars(_f.read())

with io.open(os.path.join(FOLDER, "samples/transcode_movie_stb_assets_log_file.txt"), "r+", encoding="utf-8") as _f:
    TRANSCODE_MOVIE_STB_ASSETS_LOG_FILE = tools.filter_chars(_f.read())

with io.open(os.path.join(FOLDER, "samples/transcode_assets_log_file.txt"), "r+", encoding="utf-8") as _f:
    TRANSCODE_ASSETS_LOG_FILE = tools.filter_chars(_f.read())

with io.open(os.path.join(FOLDER, "samples/spoiled_transcode_movie_stb_assets_log_file.txt"), "r+", encoding="utf-8") as _f:
    SPOILED_TRANSCODE_MOVIE_STB_ASSETS_LOG_FILE = tools.filter_chars(_f.read())

GEN_SCRIPT_MULTIPLE = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["run_command_to_generate_offer"]["stderr_to_log"]["ts0216"]
GEN_SCRIPT_SINGLE = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["run_command_to_generate_offer"]["stderr_to_log"]["ts0000"]
GEN_SCRIPT_SINGLE_HOLD = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["run_command_to_generate_offer"]["stderr_to_log"]["ts0000 HOLD"]

with io.open(os.path.join(FOLDER, "samples/fabrix_properties_sample.txt"), "r+", encoding="utf-8") as _f:
    PROPERTIES = _f.read()

PROPERTIES_DICT = json.loads(json.dumps(xmltodict.parse(PROPERTIES)["view_asset_properties"]))

OFFER_ID = "1502271815.36"

PATH_TO_ADI = "/var/tmp/adi-auto-deploy/e2esi/1001-ts0000_20170815_115252pt-0-0_Package/ADI.XML"

ADI_FILE = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["_spoil_adi"]["ts0000"]["xml_str_decoded"]

SINGLE_PKG_AIRFLOW_ID = "ts0000_20170815_115252pt"

SINGLE_PKG_FABRIX_ID_OTT = "80f3e0ddc1134c240e24f11bc762eda1_ec80816b362f47f54c637f2ad253deb4"

SINGLE_PKG_FABRIX_ID_STB = "38ffccc1d32106c618862de7f423be8d_3db98b518644918080e48343bdb644a1"

SINGLE_INPUT_DETAILS = {
    "HES-14": {
        "sample_id": "ts0000", "bad_metadata": BAD_METADATA,
        "file_override": "", "pattern": None,
        "expected_dag": "csi_lab_create_obo_assets_transcoding_driven_workflow"
    },
    "HES-105": {
        "sample_id": "ts1111", "bad_metadata": BAD_METADATA,
        "file_override": "", "pattern": None,
        "expected_dag": "csi_lab_create_obo_assets_transcoding_driven_workflow"
    }
}

SINGLE_PKG_DETAILS = {'HES-105': {'expected_dag': 'csi_lab_create_obo_assets_transcoding_driven_workflow', 'offer_id': '1502271815.36', 'packages': {'ts0000_20190320_155231pt': {'transcoder_workers_logs_masks': [], 'errors': [], 'fabrix_asset_id': '', 'actual_dag': '', 'movie_type': 'None', 'output_tva': '', 'tva': '', 'properties': {}, 'airflow_workers_logs_masks': [], 'adi': '/var/tmp/adi-auto-deploy/obocsi/1001-ts0000_20190320_155231pt-0-0_Package-HOLD/ADI.XML'}}, 'error': '', 'sample_id': 'ts1111'}, 'HES-14': {'expected_dag': 'csi_lab_create_obo_assets_transcoding_driven_workflow', 'offer_id': '1502271815.36', 'packages': {'ts0000_20190320_155231pt': {'transcoder_workers_logs_masks': [], 'errors': [], 'fabrix_asset_id': '', 'actual_dag': '', 'movie_type': 'None', 'output_tva': '', 'tva': '', 'properties': {}, 'airflow_workers_logs_masks': [], 'adi': '/var/tmp/adi-auto-deploy/obocsi/1001-ts0000_20190320_155231pt-0-0_Package-HOLD/ADI.XML'}}, 'error': '', 'sample_id': 'ts0000'}}

SINGLE_INGESTION_RESULTS_KWD = {
    "HES-14": {
        "sample_id": "ts0000", "offer_id": OFFER_ID,
        "packages": {SINGLE_PKG_AIRFLOW_ID: {
            "fabrix_asset_id": SINGLE_PKG_FABRIX_ID_OTT, "errors": [],
            "airflow_workers_logs_masks": [], "transcoder_workers_logs_masks": [],
            "adi": PATH_TO_ADI, "properties": PROPERTIES_DICT,
        }},
    },
    "HES-105": {
        "sample_id": "ts1111", "offer_id": OFFER_ID,
        "packages": {SINGLE_PKG_AIRFLOW_ID: {
            "fabrix_asset_id": SINGLE_PKG_FABRIX_ID_OTT, "errors": [],
            "airflow_workers_logs_masks": [], "transcoder_workers_logs_masks": [],
            "adi": PATH_TO_ADI, "properties": PROPERTIES_DICT,
        }},
    }
}

MULTIPLE_INPUT_DETAILS = {
    "HES-14": {
        "sample_id": "ts0216", "bad_metadata": None,
        "file_override": "", "pattern": "ts[0-9]{4}_[0-9]{8}_[0-9]{6}[0-9\-]{0,3}pt[0-9]{0,2}",
        "expected_dag": "csi_lab_create_obo_assets_transcoding_driven_workflow"
    }
}

MULTIPLE_PACKAGES = sorted(['ts0216_20190319_155131-4pt', 'ts0216_20190319_155131-6pt', 'ts0216_20190319_155131-9pt', 'ts0216_20190319_155131-2pt', 'ts0216_20190319_155131-10pt', 'ts0216_20190319_155131-5pt', 'ts0216_20190319_155131-7pt', 'ts0216_20190319_155131-8pt', 'ts0216_20190319_155131-1pt', 'ts0216_20190319_155131-3pt'])

MULTIPLE_PACKAGES_DICT = {}
for package_name in MULTIPLE_PACKAGES:
    tmp_dict = {"adi": PATH_TO_ADI.replace(SINGLE_PKG_AIRFLOW_ID, package_name),
                "fabrix_asset_id": "", "properties": {},
                "airflow_workers_logs_masks": [], "transcoder_workers_logs_masks": [], "output_tva": "", "errors": []}
    MULTIPLE_PACKAGES_DICT.update({package_name: tmp_dict})

MULTIPLE_PKG_DETAILS = {'HES-14': {'expected_dag': 'csi_lab_create_obo_assets_transcoding_driven_workflow', 'offer_id': '1502271815.36', 'packages': {'ts0216_20190319_155131-4pt': {'transcoder_workers_logs_masks': [], 'errors': [], 'fabrix_asset_id': '', 'actual_dag': '', 'movie_type': 'None', 'output_tva': '', 'tva': '', 'properties': {}, 'airflow_workers_logs_masks': [], 'adi': '/var/tmp/adi-auto-deploy/obocsi/1001-ts0216_20190319_155131-4pt-0-0_Package/ADI.XML'}, 'ts0216_20190319_155131-6pt': {'transcoder_workers_logs_masks': [], 'errors': [], 'fabrix_asset_id': '', 'actual_dag': '', 'movie_type': 'None', 'output_tva': '', 'tva': '', 'properties': {}, 'airflow_workers_logs_masks': [], 'adi': '/var/tmp/adi-auto-deploy/obocsi/1001-ts0216_20190319_155131-6pt-0-0_Package/ADI.XML'}, 'ts0216_20190319_155131-9pt': {'transcoder_workers_logs_masks': [], 'errors': [], 'fabrix_asset_id': '', 'actual_dag': '', 'movie_type': 'None', 'output_tva': '', 'tva': '', 'properties': {}, 'airflow_workers_logs_masks': [], 'adi': '/var/tmp/adi-auto-deploy/obocsi/1001-ts0216_20190319_155131-9pt-0-0_Package/ADI.XML'}, 'ts0216_20190319_155131-2pt': {'transcoder_workers_logs_masks': [], 'errors': [], 'fabrix_asset_id': '', 'actual_dag': '', 'movie_type': 'None', 'output_tva': '', 'tva': '', 'properties': {}, 'airflow_workers_logs_masks': [], 'adi': '/var/tmp/adi-auto-deploy/obocsi/1001-ts0216_20190319_155131-2pt-0-0_Package/ADI.XML'}, 'ts0216_20190319_155131-10pt': {'transcoder_workers_logs_masks': [], 'errors': [], 'fabrix_asset_id': '', 'actual_dag': '', 'movie_type': 'None', 'output_tva': '', 'tva': '', 'properties': {}, 'airflow_workers_logs_masks': [], 'adi': '/var/tmp/adi-auto-deploy/obocsi/1001-ts0216_20190319_155131-10pt-0-0_Package/ADI.XML'}, 'ts0216_20190319_155131-5pt': {'transcoder_workers_logs_masks': [], 'errors': [], 'fabrix_asset_id': '', 'actual_dag': '', 'movie_type': 'None', 'output_tva': '', 'tva': '', 'properties': {}, 'airflow_workers_logs_masks': [], 'adi': '/var/tmp/adi-auto-deploy/obocsi/1001-ts0216_20190319_155131-5pt-0-0_Package/ADI.XML'}, 'ts0216_20190319_155131-7pt': {'transcoder_workers_logs_masks': [], 'errors': [], 'fabrix_asset_id': '', 'actual_dag': '', 'movie_type': 'None', 'output_tva': '', 'tva': '', 'properties': {}, 'airflow_workers_logs_masks': [], 'adi': '/var/tmp/adi-auto-deploy/obocsi/1001-ts0216_20190319_155131-7pt-0-0_Package/ADI.XML'}, 'ts0216_20190319_155131-8pt': {'transcoder_workers_logs_masks': [], 'errors': [], 'fabrix_asset_id': '', 'actual_dag': '', 'movie_type': 'None', 'output_tva': '', 'tva': '', 'properties': {}, 'airflow_workers_logs_masks': [], 'adi': '/var/tmp/adi-auto-deploy/obocsi/1001-ts0216_20190319_155131-8pt-0-0_Package/ADI.XML'}, 'ts0216_20190319_155131-1pt': {'transcoder_workers_logs_masks': [], 'errors': [], 'fabrix_asset_id': '', 'actual_dag': '', 'movie_type': 'None', 'output_tva': '', 'tva': '', 'properties': {}, 'airflow_workers_logs_masks': [], 'adi': '/var/tmp/adi-auto-deploy/obocsi/1001-ts0216_20190319_155131-1pt-0-0_Package/ADI.XML'}, 'ts0216_20190319_155131-3pt': {'transcoder_workers_logs_masks': [], 'errors': [], 'fabrix_asset_id': '', 'actual_dag': '', 'movie_type': 'None', 'output_tva': '', 'tva': '', 'properties': {}, 'airflow_workers_logs_masks': [], 'adi': '/var/tmp/adi-auto-deploy/obocsi/1001-ts0216_20190319_155131-3pt-0-0_Package/ADI.XML'}}, 'error': '', 'sample_id': 'ts0216'}}

MULTIPLE_PACKAGES_RESULT = {}
for package_name in MULTIPLE_PACKAGES:
    tmp_dict = {"fabrix_asset_id": SINGLE_PKG_FABRIX_ID_OTT,
                "properties": PROPERTIES_DICT, "errors": [],
                "airflow_workers_logs_masks": [], "transcoder_workers_logs_masks": []}
    MULTIPLE_PACKAGES_RESULT.update({package_name: tmp_dict})

MULTIPLE_INGESTION_RESULTS_KWD = {
    "HES-14": {"sample_id": "ts0244", "offer_id": OFFER_ID, "packages": MULTIPLE_PACKAGES_RESULT}
}

FABRIX_LOG_LINES = ["logs/create_obo_assets_transcoding_driven_workflow/submit_assets_to_origin/\
2017-08-15T12:01:35.979785:[2018-03-07 08:37:22,488] {base_task_runner.py:96} \
INFO - Subtask: [2018-03-07 08:37:22,487] {irdeto_client.py:47} INFO - Using params: \
account='lgiobo', external_id='%s', policy='131'" % SINGLE_PKG_FABRIX_ID_OTT]

DETAILS_DAGS = "3214665b5bf3affde1e2adcee3c84002ae1ee5d7 (actual) != " + \
          "4e0caa758062cf8d2e6cc7f1e2198763398c9e1d2 (expected)"

DETAILS = "9875f29a821dfb6b487bbdea90712e0952a8e143 (actual) != " + \
          "a60e511bf73fdd525db83a1b7d802469500dba812 (expected)"

REVISION_ERRORS = [
    "Wrong revision in 172.23.69.118:/usr/local/airflow/Revision_airflow-dags: %s" % DETAILS_DAGS,
    "Wrong revision in 172.23.69.118:/usr/local/airflow/Revision_airflow: %s" % DETAILS,
    "Wrong revision in 172.23.69.117:/usr/local/airflow/Revision_airflow-dags: %s" % DETAILS_DAGS,
    "Wrong revision in 172.23.69.117:/usr/local/airflow/Revision_airflow: %s" % DETAILS]

VALUES_OK = {"errors": [], "VERSION": "v1.50",
             "Revision_airflow": "9875f29a821dfb6b487bbdea90712e0952a8e143",
             "Revision_airflow-dags": "3214665b5bf3affde1e2adcee3c84002ae1ee5d7"}

VALUES_NOK = {"errors": REVISION_ERRORS,
              "VERSION": None, "Revision_airflow": None, "Revision_airflow-dags": None}

VERSION_ERROR = "Web version v1.48 != Git version: v1.49"

WEBVTT_RESPONSE = """
WEBVTT

00:00:10.000 --> 00:00:20.000
/thumbnail-service/assets/9377980492f6df1d7427e3c376c7f81f_3db98b518644918080e48343bdb644a1/1.bin#bytes=0-2172

00:00:20.000 --> 00:00:30.000
/thumbnail-service/assets/9377980492f6df1d7427e3c376c7f81f_3db98b518644918080e48343bdb644a1/1.bin#bytes=2173-11151

00:00:30.000 --> 00:00:40.000
/thumbnail-service/assets/9377980492f6df1d7427e3c376c7f81f_3db98b518644918080e48343bdb644a1/1.bin#bytes=11152-21345

00:00:40.000 --> 00:00:50.000
/thumbnail-service/assets/9377980492f6df1d7427e3c376c7f81f_3db98b518644918080e48343bdb644a1/1.bin#bytes=21346-24040

00:00:50.000 --> 00:01:00.000
/thumbnail-service/assets/9377980492f6df1d7427e3c376c7f81f_3db98b518644918080e48343bdb644a1/1.bin#bytes=24041-30076

00:01:00.000 --> 00:01:10.000
/thumbnail-service/assets/9377980492f6df1d7427e3c376c7f81f_3db98b518644918080e48343bdb644a1/1.bin#bytes=30077-40191

00:01:10.000 --> 00:01:20.000
/thumbnail-service/assets/9377980492f6df1d7427e3c376c7f81f_3db98b518644918080e48343bdb644a1/1.bin#bytes=40192-50981

00:01:20.000 --> 00:01:30.000
/thumbnail-service/assets/9377980492f6df1d7427e3c376c7f81f_3db98b518644918080e48343bdb644a1/1.bin#bytes=50982-57113
"""

LONG_LISTING_FORMAT_OUTPUT = """
total 585
-rw-r--r-- 1 Ievgen_Petrash 1049089    460 Jan 14 15:24 __init__.py
drwxr-xr-x 1 Ievgen_Petrash 1049089      0 Feb 14 17:44 __pycache__/
-rw-r--r-- 1 Ievgen_Petrash 1049089  32904 Jan 28 10:47 health.py
-rw-r--r-- 1 Ievgen_Petrash 1049089 192142 Feb 14 17:36 helpers.py
drwxr-xr-x 1 Ievgen_Petrash 1049089      0 Feb  4 17:36 htmlcov/
-rw-r--r-- 1 Ievgen_Petrash 1049089 147957 Feb  3 12:11 keywords.py
drwxr-xr-x 1 Ievgen_Petrash 1049089      0 Feb 14 14:26 samples/
-rw-r--r-- 1 Ievgen_Petrash 1049089 166399 Feb 14 17:46 test_keywords.py
-rw-r--r-- 1 Ievgen_Petrash 1049089  24752 Feb 10 13:50 tools.py
"""

class Mock_urllib():

    def __init__(self, url):
        self.url = url
        self.code = "200"

    def read(self):
        if "/thumbnail-service/assets/" in self.url:
            return WEBVTT_RESPONSE


def mock_grep_logs(*args):
    """A method imitates searching through log files on a remote server - it analyzes arguments,
    and returns predefined data (lines of the output returned by the command).

    :param args: an array - [host, port, username, password, path, entry, pipes].
    .. note:: args can be anything since this is a mock, only host and pipes will be analyzed.

    :return: array of strings.
    """
    lines = [""]
    host = args[0]
    pipes = args[6]
    if host in [cnf["host"] for cnf in E2E_CONF["mock"]["AIRFLOW_WORKERS"]] and "Fabrix" in pipes:
        lines[0] = FABRIX_LOG_LINES[0]
    return lines

def mock_requests_get(*args):
    """A method imitates sending requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    url = args[0]
    status_code, reason = 200, "OK"
    if "properties" in url:
        response_text = PROPERTIES
    else:
        response_text, status_code, reason = "", 404, "Not Found"
    content = "some content"
    url = "some url"
    data = dict(text=response_text, url=url, status_code=status_code, reason=reason, content=content)
    return type("", (), data)()

def mock_run_ssh_cmd(host, port, username, password, command, timeout=15, get_pty=False,
                    return_connect_only=False):
    if "HOLD" in command:
        stderr = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["run_command_to_generate_offer"]["stderr_to_log"]["ts0000 HOLD"]
    else:
        stderr = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["run_command_to_generate_offer"]["stderr_to_log"]["ts0000"]
    return "", stderr

def return_run_ssh_cmd_method_arguments(*args, **kwargs):
    return "", (args, kwargs)

def mock_create_unique_tva(host, port, username, password, command, timeout=15, get_pty=False,
                    return_connect_only=False):
    """Method to use as side-effect of mock function. This method will create modified copy of
    TVA_ts1111_original.txt based on "sed" command  from original function.
    Path in original sed command will be modified to "samples/unique_tva.txt"
    """
    # path_to_sample_file = FOLDER / Path("samples/TVA_ts1111_original.txt")
    # path_to_temp_file = FOLDER / Path("samples/unique_tva.txt")
    path_to_sample_file = os.path.join(FOLDER, "samples/TVA_ts1111_original.txt")
    path_to_temp_file = os.path.join(FOLDER, "samples/unique_tva.txt")

    copyfile(path_to_sample_file, path_to_temp_file)
    # replace destination path in sed command to "samples/%s" % random_name
    path_to_temp_file = Path(path_to_temp_file)
    cmd = command.replace('dir/TVA_test.xml', "'%s'" % str(path_to_temp_file))
    cmd = cmd.replace("sudo", "")
    subprocess.check_output(['bash', '-c', cmd])
    return "", ""

def mock_read_tva(path, fname):
    """Method to reads TVA xml file on local robot/lib/IngestionE2E/samples directory

    :param path: a relative path to the folder containing TVA xml file(s).
    :param fname: a TVA file name.

    :return: TVA file contents loaded into a dictionary.
    """
    with io.open(os.path.join(FOLDER, "%s/%s" % (path, fname)), "r+", encoding="utf-8") as _f:
        content = general_keywords.insure_text(_f.read())
        stdout = tools.filter_chars(content)
    json_str = json.dumps(xmltodict.parse(stdout), sort_keys=True, indent=4)
    return json.loads(json_str)

def mock_get_log_data(logfile_path, split_lines=True):
    """A method to get the log file data from the airflow workers

    :param logfile_path: absolute path to output file to get data
    :param split_lines: Bool type, default True
    :return: list/string type based on the split_lines flag
    """

    if "perform_movie_selene_video_qc" in logfile_path:
        logfile_path = "samples/perform_movie_selene_video_qc.log"

    if "perform_videos_qc" in logfile_path:
        logfile_path = "samples/perform_videos_qc.log"

    if "/some/path" in logfile_path:
        logfile_path = "samples/perform_videos_qc.log"

    if "/error/path" in logfile_path:
        result = ""
        return result

    if split_lines:
        result = []
    else:
        result = ""

    with io.open(os.path.join(FOLDER, logfile_path), "r+", encoding="utf-8") as _f:
        log_file = _f.read()

    if log_file:
        if split_lines:
            result = log_file.splitlines()
        else:
            result = log_file
    return result

def mock_read_unique_tva_and_remove(path, fname):
    """Method to use as side-effect of mock function. This method will read data of
    samples/unique_tva.txt what was created in 'mock_create_unique_tva' function.
    This data will be returned as mock data and file will be removed
    """
    path_to_temp_file = os.path.join(FOLDER, "samples/unique_tva.txt")
    unique_tva = mock_read_tva("samples", "unique_tva.txt")
    os.remove(path_to_temp_file)
    return unique_tva

def mock_urlopen(url):
    return Mock_urllib(url)


@mock.patch.object(Tools, "run_ssh_command_itself", return_value=("", GEN_SCRIPT_SINGLE_HOLD))
@mock.patch.object(Tools, "ssh_read_file", return_value=ADI_XML)
@mock.patch.object(Tools, "ssh_write_file", return_value=True)
@mock.patch.object(helpers, "run_bad_metadata_command", return_value="")
@mock.patch.object(helpers, "unhold_package_and_offer", return_value="")
def run_gen_offers_single_keyword(*args):
    """A function to run packages generation keyword for Robot Framework using mock connections."""
    lab_name, e2e_conf, details = args[:3]
    result = Keywords().generate_offers(lab_name, e2e_conf, details)
    return result

@mock.patch("requests.get", side_effect=mock_requests_get)
@mock.patch.object(helpers, "collect_from_logs", return_value=FABRIX_LOG_LINES)
@mock.patch.object(helpers, "check_dag_failed", return_value=False)
def run_get_ingest_results_keyword(*args):
    """A function to collect ingestion results using a keyword for Robot Framework and
    mock connections.
    """
    lab_name, e2e_conf, details, tries, interval = args[:5]
    result = Keywords().get_ingestion_results(lab_name, e2e_conf, details, tries, interval)
    return result

@mock.patch.object(Tools, "run_ssh_command_itself", return_value=("", GEN_SCRIPT_MULTIPLE))
@mock.patch.object(Tools, "ssh_read_file", return_value=ADI_XML)
@mock.patch.object(Tools, "ssh_write_file", return_value=True)
def run_gen_offers_multiple_keyword(*args):
    """A function to run packages generation keyword for Robot Framework using mock connections."""
    lab_name, e2e_conf, details = args[:3]
    result = Keywords().generate_offers(lab_name, e2e_conf, details)
    return result


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


@mock.patch.object(helpers, "get_package_log_masks", return_value=mock_data["robot"]["Libraries"]["IngestionE2E"]["keywords.py"]["get_ingestion_results"]["no_og_package"]["airflow_workers_logs_masks"])
class Test_keywords(TestCaseNameAsDescription):
    """Class contains unit tests of keywords.py methods."""

    @classmethod
    def setUpClass(cls):
        cls.keywords_object = Keywords()
        pass


    @classmethod
    def tearDownClass(cls):
        pass

    @mock.patch.object(helpers, "check_asset_failed", return_value=False)
    @mock.patch.object(helpers, "is_asset_present_in_watch_folder", return_value=False)
    @mock.patch.object(helpers, "check_dag_failed", return_value=False)
    @mock.patch.object(helpers, "is_dag_started", return_value=True)
    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=(mock_data["robot"]["Keywords"]["ingestion.basic.robot"]["Run Ingestion Suite"]["results"]["HES-105"]["packages"]["ts0220_20190325_113823pt"]["start_time"] ,""))
    def test_get_ingestion_starting_time(self, *args):
        details = mock_data["robot"]["Keywords"]["ingestion.basic.robot"]["Run Ingestion Suite"]["packages"]["HES-14"]
        expected_result = mock_data["robot"]["Keywords"]["ingestion.basic.robot"]["Run Ingestion Suite"]["results"]["HES-105"]["packages"]["ts0220_20190325_113823pt"]["start_time"]
        result = Keywords().get_ingestion_starting_time("mock", E2E_CONF, details)
        actual_result = result["start_time"]
        self.assertEqual(actual_result, expected_result)


# TODO fix the unit test. works separately but fails when execute for whole unit tests

    @mock.patch.object(helpers, "read_tva", return_value=mock_read_tva("samples", "output_tva_ts0000.txt"))
    def test_check_images_fqdn_in_output_tva_file_positive(self, *args):
        fail_reason = self.keywords_object.check_images_fqdn_in_output_tva_file("mock", E2E_CONF, "some/path")
        self.assertFalse(fail_reason)

    @mock.patch.object(helpers, "get_images_from_output_tva_file", return_value=["http://172.30.108.112", "https://172.30.108.113:8080", "http://172.30.108.114"])
    def test_check_images_fqdn_in_output_tva_file_negative_only_ip(self, *args):
        fail_reason = self.keywords_object.check_images_fqdn_in_output_tva_file("mock", E2E_CONF, "some/path")
        self.assertTrue(fail_reason)

    @mock.patch.object(helpers, "get_images_from_output_tva_file", return_value=["http://anyhost.nl", "https://somehost.com:8080", "http://172.30.108.114"])
    def test_check_images_fqdn_in_output_tva_file_negative_ip_and_fqdn(self, *args):
        fail_reason = self.keywords_object.check_images_fqdn_in_output_tva_file("mock", E2E_CONF, "some/path")
        self.assertTrue(fail_reason)

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=(TRANSCODE_MOVIE_STB_ASSETS_LOG_FILE, ""))
    def test_check_transcoding_job_polling_interval_positive(self, *args):
        transcoder_workers_logs_masks = mock_data["robot"]["Keywords"]["ingestion.basic.robot"]["Run Ingestion Suite"]["results"]["HES-198"]["packages"]["ts1111_20190325_113830pt"]["transcoder_workers_logs_masks"]
        result = self.keywords_object.check_transcoding_job_polling_interval("mock", E2E_CONF, transcoder_workers_logs_masks)
        self.assertEqual(result, "")

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=(TRANSCODE_ASSETS_LOG_FILE, ""))
    def test_check_transcoding_job_polling_interval_positive_transcoder_workflow(self, *args):
        transcoder_workers_logs_masks = mock_data["robot"]["Keywords"]["ingestion.basic.robot"]["Run Ingestion Suite"]["results"]["HES-198"]["packages"]["ts1111_20190325_113830pt"]["transcoder_workers_logs_masks"]
        result = self.keywords_object.check_transcoding_job_polling_interval("mock", E2E_CONF, transcoder_workers_logs_masks)
        self.assertEqual(result, "")

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=(SPOILED_TRANSCODE_MOVIE_STB_ASSETS_LOG_FILE, ""))
    def test_check_transcoding_job_polling_interval_spoiled_log(self, *args):
        transcoder_workers_logs_masks = mock_data["robot"]["Keywords"]["ingestion.basic.robot"]["Run Ingestion Suite"]["results"]["HES-198"]["packages"]["ts1111_20190325_113830pt"]["transcoder_workers_logs_masks"]
        result = self.keywords_object.check_transcoding_job_polling_interval("mock", E2E_CONF, transcoder_workers_logs_masks)
        self.assertNotEqual(result, "")

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=(OUTPUT_TVA_TS0000, ""))
    @mock.patch.object(Tools, "run_local_command", return_value=0)
    @mock.patch.object(helpers, "get_mediainfo_by_url", return_value=mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_all_thumbnails_aspect_ratio_from_output_tva"]["media_info_string"]["ts0000"])
    @mock.patch.object(helpers, "insure_thumbnails_workflow_enabled", return_value=True)
    def test_check_thumbnails_aspect_ratio_positive(self, *args):
        airflow_workers_logs_masks = ["/some/path_1/.1.log", "/some/path_2/.1.log"]
        fabrix_asset_ids_info = mock_data["robot"]["Keywords"]["ingestion.basic.robot"]["Run Ingestion Suite"]["results"]["HES-14"]["packages"]["ts0000_20190325_113818pt"]["fabrix_asset_ids_info"]
        fail_reason = self.keywords_object.check_thumbnails_aspect_ratio(
            "mock", E2E_CONF, "/some/path", "ts0000", airflow_workers_logs_masks, fabrix_asset_ids_info)
        self.assertEqual(fail_reason, "")

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=(OUTPUT_TVA_TS0000, ""))
    @mock.patch.object(Tools, "run_local_command", return_value=0)
    @mock.patch.object(helpers, "get_mediainfo_by_url", return_value=mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_all_thumbnails_aspect_ratio_from_output_tva"]["media_info_string"]["spoiled_ts0000"])
    def test_check_thumbnails_aspect_ratio_negative(self, *args):
        airflow_workers_logs_masks = ["/some/path_1/.1.log", "/some/path_2/.1.log"]
        fabrix_asset_ids_info = mock_data["robot"]["Keywords"]["ingestion.basic.robot"]["Run Ingestion Suite"]["results"]["HES-14"]["packages"]["ts0000_20190325_113818pt"]["fabrix_asset_ids_info"]
        fail_reason = self.keywords_object.check_thumbnails_aspect_ratio(
            "mock", E2E_CONF, "/some/path", "ts0000", airflow_workers_logs_masks, fabrix_asset_ids_info)
        self.assertNotEqual(fail_reason, "")

    @mock.patch.object(helpers, "get_log_data", side_effect=mock_get_log_data)
    def test_get_log_data_from_airflow_logs(self, *args):
        with io.open(os.path.join(FOLDER, 'samples/perform_videos_qc.log'), "r+", encoding="utf-8") as _f:
            expected_loglines = _f.read().splitlines()
        actual_loglines = self.keywords_object.get_log_data_from_airflow_logs("mock", E2E_CONF, "/some/path")
        self.assertIs(type(actual_loglines), list)
        self.assertListEqual(actual_loglines, expected_loglines)

    @mock.patch.object(helpers, "get_log_data", side_effect=mock_get_log_data)
    def test_get_log_data_from_airflow_logs_negative(self, *args):
        with self.assertRaises(Exception) as err_obj:
            self.keywords_object.get_log_data_from_airflow_logs("mock", E2E_CONF, "/error/path")
        err_msg = err_obj.exception
        self.assertEqual(str(err_msg), "Logfile Path '/error/path' was not found on the Airflow workers")


class Test_helpers(TestCaseNameAsDescription):
    """Class contains unit tests for methods of E2E() class."""

    @classmethod
    def setUpClass(cls):
        cls.lab_name = "mock"
        cls.helpers_obj = helpers(cls.lab_name, E2E_CONF)
        cls.conf = E2E_CONF[cls.lab_name]
        cls.path_to_tva_file = "samples"
        cls.tva_file_sample = "TVA_ts1111_original.txt"
        cls.tva_xmldict = mock_read_tva(cls.path_to_tva_file, cls.tva_file_sample)
        cls.tva_program_description = cls.tva_xmldict["TVAMain"]["ProgramDescription"]
        cls.offer_id = "test_offer_id"
        cls.pkg_dir = "dir"
        cls.path = "/dummy/path"
        cls.ssh = SSH
        cls.test_tva_file_name = "TVA_test.xml"

    @classmethod
    def tearDownClass(cls):
        pass

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=("", GEN_SCRIPT_SINGLE))
    def test_generate_offer_id_based_on_time_stamp(self, *args):
        """Check the package id is correctly parsed from the html text
        returned by the generator script.
        """
        offer_id = self.helpers_obj.generate_offer_id_based_on_time_stamp()
        matches = True if re.match(r"[0-9]{10}\.[0-9]{1}", offer_id) else False
        self.assertTrue(matches)

    @mock.patch.object(Tools, "run_ssh_command_itself", side_effect=mock_run_ssh_cmd)
    def test_run_command_to_generate_offer(self, *args):
        stderr_none_movie_type = self.helpers_obj.run_command_to_generate_offer(
            "", None, "ts0000", "1553007969.32", None, None, None, None)
        self.assertFalse("Package-HOLD/ADI.XML" in stderr_none_movie_type)
        self.assertTrue("Package/ADI.XML" in stderr_none_movie_type)

        stderr_not_none_movie_type = self.helpers_obj.run_command_to_generate_offer(
            "", "stb", "ts0000", "1553007969.32", None, None, None, None)
        self.assertTrue("Package-HOLD/ADI.XML" in stderr_not_none_movie_type)
        self.assertFalse("Package/ADI.XML" in stderr_not_none_movie_type)

    def test_get_path_to_adi_file(self, *args):
        adi_file_writing_line = "Package/ADI.XML"
        expected_path_to_adi = "/var/tmp/adi-auto-deploy/obocsi/1001-ts0000_20170815_115252pt-0-0_Package/ADI.XML"
        adi_file_writing_line_hold = "Package-HOLD/ADI.XML"
        expected_path_to_adi_hold = "/var/tmp/adi-auto-deploy/obocsi/1001-ts0000_20190320_155231pt-0-0_Package-HOLD/ADI.XML"

        path_to_adi_list = self.helpers_obj.get_path_to_adi_file(adi_file_writing_line, "ts0000", GEN_SCRIPT_SINGLE)
        self.assertTrue(isinstance(path_to_adi_list, list))
        self.assertEqual(path_to_adi_list[0], expected_path_to_adi)

        path_to_adi_list = self.helpers_obj.get_path_to_adi_file(adi_file_writing_line_hold, "ts0000", GEN_SCRIPT_SINGLE_HOLD)
        self.assertTrue(isinstance(path_to_adi_list, list))
        self.assertEqual(path_to_adi_list[0], expected_path_to_adi_hold)

    @mock.patch.object(Tools, "ssh_write_file", return_value=True)
    @mock.patch.object(Tools, "ssh_read_file", return_value=mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["_spoil_adi"]["ts0000"]["xml_str_decoded"])
    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=("",""))
    def test_spoil_adi(self, *args):
        path_to_adi = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["_spoil_adi"]["ts0000"]["xml_str_to_write"]
        expected_xml = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["_spoil_adi"]["ts0000"]["xml_str_to_write"]
        bad_metadata = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["_spoil_adi"]["ts0000"]["bad_metadata"]

        status, spoiled_xml = self.helpers_obj._spoil_adi(path_to_adi, bad_metadata)
        spoiled_xml = spoiled_xml.decode("UTF-8")
        self.assertTrue(status)
        self.assertEqual(spoiled_xml.replace('\n', '').replace(" ", ""), expected_xml.replace('\n', '').replace(" ", ""))

    @mock.patch.object(Tools, "ssh_read_file", return_value="")
    def test_spoil_adi_empty_xml(self, *args):
        path_to_adi = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["_spoil_adi"]["ts0000"]["xml_str_to_write"]
        bad_metadata = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["_spoil_adi"]["ts0000"]["bad_metadata"]
        with self.assertRaises(Exception) as err_obj:
            self.helpers_obj._spoil_adi(path_to_adi, bad_metadata)
        err_msg = err_obj.exception
        self.assertEqual(str(err_msg), "We didn't find xml string when tried to spoil ADI.XML file")

    @mock.patch.object(Tools, "ssh_write_file", return_value=True)
    @mock.patch.object(Tools, "ssh_read_file", return_value=mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["_spoil_adi"]["ts0000"]["xml_str_decoded"])
    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=("",""))
    @mock.patch.object(helpers, "run_bad_metadata_command", return_value="")
    def test_spoil_adi_bad_data_cmd(self, mocked_run_bad_metadata_command, *args):
        path_to_adi = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["_spoil_adi"]["ts0000"]["xml_str_to_write"]
        expected_xml = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["_spoil_adi"]["ts0000"]["xml_str_to_write"]
        bad_metadata = [{"xpath_locate": "./Asset/Asset/Metadata/AMS[@Asset_Class=\'poster\']", "xpath_change": "../../Content", "attrs": {"Value": "POSTER.JPG"}, "cmd": "mv %(dir_to_adi)s/%(old_val)s %(dir_to_adi)s/POSTER.JPG"}]
        status, spoiled_xml = self.helpers_obj._spoil_adi(path_to_adi, bad_metadata)
        spoiled_xml = spoiled_xml.decode("UTF-8")
        self.assertTrue(status)
        self.assertTrue(spoiled_xml)
        mocked_run_bad_metadata_command.assetr_called()

    @mock.patch.object(Tools, "ssh_read_file", return_value=mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["_spoil_adi"]["ts0000"]["xml_str_decoded"])
    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=("",""))
    @mock.patch.object(helpers, "run_bad_metadata_command", return_value="some_error")
    def test_spoil_adi_bad_data_cmd_error(self, mocked_run_bad_metadata_command, *args):
        path_to_adi = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["_spoil_adi"]["ts0000"]["xml_str_to_write"]
        bad_metadata = [{"xpath_locate": "./Asset/Asset/Metadata/AMS[@Asset_Class=\'poster\']", "xpath_change": "../../Content", "attrs": {"Value": "POSTER.JPG"}, "cmd": "mv %(dir_to_adi)s/%(old_val)s %(dir_to_adi)s/POSTER.JPG"}]
        with self.assertRaises(Exception) as err_obj:
            self.helpers_obj._spoil_adi(path_to_adi, bad_metadata)
        err_msg = err_obj.exception
        self.assertEqual(str(err_msg), "Fail in '_spoil_adi' when wrote new content")


    def test_define_package_name_and_structure(self, *args):
        movie_type = None
        path_to_adi = "/var/tmp/adi-auto-deploy/obocsi/1001-ts0000_20170815_115252pt-0-0_Package/ADI.XML"
        expected_package_name = "ts0000_20170815_115252pt"
        path_to_adi_hold = "/var/tmp/adi-auto-deploy/obocsi/1001-ts0000_20190320_155231pt-0-0_Package-HOLD/ADI.XML"
        expected_package_name_hold = "ts0000_20190320_155231pt"
        pattern = "ts[0-9]{4}_[0-9]{8}_[0-9]{6}[0-9\-]{0,3}pt[0-9]{0,2}"
        sample_id = "ts0000"

        package_name = self.helpers_obj.define_package_name_and_structure(movie_type, path_to_adi, pattern, sample_id)
        self.assertEqual(package_name, expected_package_name)
        self.assertEqual(self.helpers_obj.packages[package_name]["adi"], path_to_adi)
        self.assertEqual(self.helpers_obj.packages[package_name]["fabrix_asset_id"], "")
        self.assertEqual(self.helpers_obj.packages[package_name]["properties"], {})
        self.assertEqual(self.helpers_obj.packages[package_name]["output_tva"], "")
        self.assertEqual(self.helpers_obj.packages[package_name]["airflow_workers_logs_masks"], [])
        self.assertEqual(self.helpers_obj.packages[package_name]["transcoder_workers_logs_masks"], [])
        self.assertEqual(self.helpers_obj.packages[package_name]["errors"], [])
        self.assertEqual(self.helpers_obj.packages[package_name]["movie_type"], str(movie_type))
        self.assertEqual(self.helpers_obj.packages[package_name]["actual_dag"], "")

        movie_type = "ott"
        package_name_hold = self.helpers_obj.define_package_name_and_structure(movie_type, path_to_adi_hold, pattern, sample_id)
        self.assertEqual(package_name_hold, expected_package_name_hold)
        self.assertEqual(self.helpers_obj.packages[package_name_hold]["adi"], path_to_adi_hold)
        self.assertEqual(self.helpers_obj.packages[package_name_hold]["fabrix_asset_id"], "")
        self.assertEqual(self.helpers_obj.packages[package_name_hold]["properties"], {})
        self.assertEqual(self.helpers_obj.packages[package_name_hold]["output_tva"], "")
        self.assertEqual(self.helpers_obj.packages[package_name_hold]["airflow_workers_logs_masks"], [])
        self.assertEqual(self.helpers_obj.packages[package_name_hold]["transcoder_workers_logs_masks"], [])
        self.assertEqual(self.helpers_obj.packages[package_name_hold]["errors"], [])
        self.assertEqual(self.helpers_obj.packages[package_name_hold]["movie_type"], str(movie_type))
        self.assertEqual(self.helpers_obj.packages[package_name_hold]["actual_dag"], "")

    @mock.patch.object(Tools, "ssh_write_file", return_value=True)
    @mock.patch.object(Tools, "ssh_read_file", return_value=ADI_XML)
    @mock.patch.object(Tools, "ssh_write_file", return_value="")
    def test_block_movie_type_ingestion_in_adi_file(self, *args):
        for movie_type in [
                'ott', 'OTT',
                'stb', 'STB',
                '4k_stb', '4K_STB',
                '4k_ott', '4K_OTT']:
            asset_found = False
            app_data_found = False
            block_platform = False
            actual_result = self.helpers_obj.block_movie_type_ingestion_in_adi_file("some/path", movie_type)
            result_json_str = json.dumps(xmltodict.parse(actual_result), sort_keys=True, indent=4)
            result_dictionary = json.loads(result_json_str)
            for asset in result_dictionary["ADI"]["Asset"]["Asset"]:
                asset_found = True
                for app_data in asset["Metadata"]["App_Data"]:
                    app_data_found = True
                    if app_data["@Name"] == "Block_Platform":
                        block_platform = True
                        result = app_data["@Value"]
                        self.assertEqual(result, "BLOCK_%s" % movie_type.upper())
            if not asset_found:
                self.assertTrue(False, msg="We did't find result_dictionary['ADI']['Asset']['Asset']")

            if not app_data_found:
                self.assertTrue(False, msg="We didn't find asset['Metadata']['App_Data']")

            if not block_platform:
                self.assertTrue(False, msg="'Block_Platform' statememt was not found")

    @mock.patch.object(Tools, "ssh_read_file", return_value=ADI_XML_NONE_ASSET_SUBNODE)
    @mock.patch.object(Tools, "ssh_write_file", return_value="")
    def test_block_movie_type_ingestion_in_adi_file_none_asset_subnode(self, *args):
        with self.assertRaises(Exception) as err_obj:
            self.helpers_obj.block_movie_type_ingestion_in_adi_file("some/path", "ott", "OG")
        err_msg = err_obj.exception
        self.assertEqual(str(err_msg), "ADI.XML parsing error")

    @mock.patch.object(Tools, "ssh_read_file", return_value=ADI_XML)
    @mock.patch.object(Tools, "ssh_write_file")
    def test_block_movie_type_ingestion_in_adi_file_didnt_write(self, mocked_ssh_write_file, *args):
        mocked_ssh_write_file.return_value = False
        with self.assertRaises(Exception) as err_obj:
            self.helpers_obj.block_movie_type_ingestion_in_adi_file("some/path", "ott", "OG")
        err_msg = err_obj.exception
        self.assertEqual(str(err_msg), "Fail in 'block_movie_type_ingestion_in_adi_file' "
                            "when wrote new content")

    @mock.patch.object(Tools, "ssh_read_file", return_value=ADI_XML)
    @mock.patch.object(Tools, "ssh_write_file", return_value="")
    def test_set_unique_title_id_in_package_adi(self, *args):
        unique_title_id = "test_201909191025_auto"
        actual_result = self.helpers_obj.set_unique_title_id_in_package_adi("some/path", unique_title_id)
        result_json_str = json.dumps(xmltodict.parse(actual_result), sort_keys=True, indent=4)
        result_dictionary = json.loads(result_json_str)
        app_data_list = result_dictionary["ADI"]["Asset"]["Metadata"]["App_Data"]
        correct = False
        for app_data in app_data_list:
            if app_data["@Name"] == "Unique_Title_Id" and app_data["@Value"] == unique_title_id:
                correct = True
        self.assertTrue(correct)

    @mock.patch.object(Tools, "ssh_read_file", return_value=ADI_XML)
    @mock.patch.object(Tools, "ssh_write_file", return_value="")
    def test_set_title_value_in_package_adi(self, *args):
        title = "test_201909191025_auto"
        actual_result = self.helpers_obj.set_title_value_in_package_adi("some/path", title)
        result_json_str = json.dumps(xmltodict.parse(actual_result), sort_keys=True, indent=4)
        result_dictionary = json.loads(result_json_str)
        app_data_list = result_dictionary["ADI"]["Asset"]["Metadata"]["App_Data"]
        correct = False
        for app_data in app_data_list:
            if app_data["@Name"] == "Title" and app_data["@Value"] == title:
                correct = True
        self.assertTrue(correct)

    @mock.patch.object(Tools, "ssh_read_file", return_value=ADI_XML)
    @mock.patch.object(Tools, "ssh_write_file", return_value="")
    def test_set_new_licensing_window_end_in_package_adi(self, *args):
        new_licensing_window_end = "2019-09-19T12:34:00"
        actual_result = self.helpers_obj.set_new_licensing_window_end_in_package_adi("some/path", new_licensing_window_end)
        result_json_str = json.dumps(xmltodict.parse(actual_result), sort_keys=True, indent=4)
        result_dictionary = json.loads(result_json_str)
        app_data_list = result_dictionary["ADI"]["Asset"]["Metadata"]["App_Data"]
        correct = False
        for app_data in app_data_list:
            if app_data["@Name"] == "Licensing_Window_End" and app_data["@Value"] == new_licensing_window_end:
                correct = True
        self.assertTrue(correct)

    # def test_unhold_package_and_offer(self, *args):
    #     # TODO
    #     pass

    @mock.patch.object(Tools, "ssh_read_file", return_value=ADI_XML)
    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=("", GEN_SCRIPT_SINGLE))
    def test_parse_airflow_asset_ids(self, *args):
        """Check the asset id used by Airflow's tasks is correctly parsed
        from Airflow's log files.
        """
        self.helpers_obj.generate_offer("ts0000", BAD_METADATA)
        self.assertTrue(isinstance(self.helpers_obj.packages, dict))
        self.assertTrue(SINGLE_PKG_AIRFLOW_ID in list(self.helpers_obj.packages.keys()))

    @mock.patch.object(helpers, "collect_from_logs", return_value=FABRIX_LOG_LINES)
    @mock.patch.object(helpers, "get_all_package_fafrix_external_asset_ids", return_value=mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_all_package_fafrix_external_asset_ids"]["result"])
    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=(mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_particular_fabrix_asset_id_of_package"]["stdout"]["DAG: csi_lab_create_obo_assets_workflow"],""))
    def test_parse_fabrix_asset_old_dag(self, *args):
        """Check the internal asset id used by Fabrix is correctly parsed
        from Airflow's log files.
        """
        old_dag = "csi_lab_create_obo_assets_workflow"
        none_movie_type = None
        ott_movie_type = "ott"
        stb_movie_type = "stb"
        check_assets_log = "/usr/local/airflow/logs/ecx_superset_create_obo_assets_transcoding_driven_workflow/check_assets/2019-06-28T12:51:14/1.log"
        self.helpers_obj.packages[SINGLE_PKG_AIRFLOW_ID]["airflow_workers_logs_masks"].append(
            check_assets_log)

        # Case: (old_dag + none_movie_type) and (old_dag + ott_movie_type)
        for movie_type in [none_movie_type, ott_movie_type]:
            self.helpers_obj.get_particular_fabrix_asset_id_of_package(SINGLE_PKG_AIRFLOW_ID, 100, 120,
                                                                   movie_type, old_dag)
            self.assertEqual(self.helpers_obj.packages[SINGLE_PKG_AIRFLOW_ID]["fabrix_asset_id"],
                             SINGLE_PKG_FABRIX_ID_OTT)

        # Case: old_dag + stb_movie_type
        self.helpers_obj.get_particular_fabrix_asset_id_of_package(SINGLE_PKG_AIRFLOW_ID, 100, 120,
                                                               stb_movie_type, old_dag)
        self.assertEqual(self.helpers_obj.packages[SINGLE_PKG_AIRFLOW_ID]["fabrix_asset_id"],
                         SINGLE_PKG_FABRIX_ID_STB)

    @mock.patch.object(helpers, "collect_from_logs", return_value=FABRIX_LOG_LINES)
    @mock.patch.object(helpers, "get_all_package_fafrix_external_asset_ids", return_value=mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_all_package_fafrix_external_asset_ids"]["result"])
    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=(mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_particular_fabrix_asset_id_of_package"]["stdout"]["DAG: csi_lab_create_obo_assets_transcoding_driven_workflow"],""))
    def test_parse_fabrix_asset_new_dag(self, *args):
        """Check the internal asset id used by Fabrix is correctly parsed
        from Airflow's log files.
        """
        new_dag = "csi_lab_create_obo_assets_transcoding_driven_workflow"
        none_movie_type = None
        ott_movie_type = "ott"
        stb_movie_type = "stb"
        check_assets_log = "/usr/local/airflow/logs/ecx_superset_create_obo_assets_transcoding_driven_workflow/check_assets/2019-06-28T12:51:14/1.log"
        self.helpers_obj.packages[SINGLE_PKG_AIRFLOW_ID]["airflow_workers_logs_masks"].append(
            check_assets_log)

        # Case: (new_dag + none_movie_type) and (new_dag + ott_movie_type)
        for movie_type in [none_movie_type, ott_movie_type]:
            self.helpers_obj.get_particular_fabrix_asset_id_of_package(SINGLE_PKG_AIRFLOW_ID, 100, 120, movie_type, new_dag)
            self.assertEqual(self.helpers_obj.packages[SINGLE_PKG_AIRFLOW_ID]["fabrix_asset_id"], SINGLE_PKG_FABRIX_ID_OTT)

        # Case: new_dag + stb_movie_type
        self.helpers_obj.get_particular_fabrix_asset_id_of_package(SINGLE_PKG_AIRFLOW_ID, 100, 120, stb_movie_type, new_dag)
        self.assertEqual(self.helpers_obj.packages[SINGLE_PKG_AIRFLOW_ID]["fabrix_asset_id"], SINGLE_PKG_FABRIX_ID_STB)

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_parse_asset_properties(self, *args):
        """Check parsing Fabrix response of the asset properties."""
        self.helpers_obj.packages[SINGLE_PKG_AIRFLOW_ID]["fabrix_asset_id"] = SINGLE_PKG_FABRIX_ID_OTT
        self.helpers_obj.get_asset_properties(SINGLE_PKG_AIRFLOW_ID, 100, 120)
        self.assertEqual(self.helpers_obj.packages[SINGLE_PKG_AIRFLOW_ID]["properties"]["id"],
                         SINGLE_PKG_FABRIX_ID_OTT)

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=(mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["is_output_tva_file_ready"]["output"],""))
    @mock.patch.object(helpers, "get_output_tva_file_path", return_value="/mnt/nfs_managed/Countries/CSI/FromAirflow/crid~~3A~~2F~~2Fog.libertyglobal.com~~2F1001~~2Fts1111_20190325_113830pt/output_TVA/TVA_100006_20190325124647.xml")
    def test_is_output_tva_file_ready(self, *args):
        package = SINGLE_PKG_AIRFLOW_ID
        generate_tva_file_log = "/usr/local/airflow/logs/ecx_superset_create_obo_assets_transcoding_driven_workflow/generate_tva_file/2019-06-28T13:00:59/1.log"
        self.helpers_obj.packages[package]["airflow_workers_logs_masks"].append(
            generate_tva_file_log)
        expected_output_tva = "/mnt/nfs_managed/Countries/CSI/FromAirflow/crid~~3A~~2F~~2Fog.libertyglobal.com~~2F1001~~2Fts1111_20190325_113830pt/output_TVA/TVA_100006_20190325124647.xml"

        result = self.helpers_obj.is_output_tva_file_ready(package)
        self.assertTrue(result)
        self.assertEqual(self.helpers_obj.packages[package]["output_tva"], expected_output_tva)

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=(OUTPUT_TVA_TS1111 ,""))
    def test_get_resolution_from_output_tva_file(self, *args):
        output_tva = "/mnt/nfs_managed/Countries/CSI/FromAirflow/crid~~3A~~2F~~2Fog.libertyglobal.com~~2F1001~~2Fts1111_20190325_113830pt/output_TVA/TVA_100006_20190325124647.xml"

        horizontal_size, vertical_size = self.helpers_obj.get_resolution_from_output_tva_file(output_tva, "OTT", "HD")
        self.assertEqual(horizontal_size, 1920)
        self.assertEqual(vertical_size, 1080)

        horizontal_size, vertical_size = self.helpers_obj.get_resolution_from_output_tva_file(output_tva, "STB", "HD")
        self.assertEqual(horizontal_size, 1920)
        self.assertEqual(vertical_size, 1080)

        horizontal_size, vertical_size = self.helpers_obj.get_resolution_from_output_tva_file(output_tva, "OTT", "SD")
        self.assertEqual(horizontal_size, 1024)
        self.assertEqual(vertical_size, 576)

        horizontal_size, vertical_size = self.helpers_obj.get_resolution_from_output_tva_file(output_tva, "STB", "SD")
        self.assertEqual(horizontal_size, 720)
        self.assertEqual(vertical_size, 576)

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=(OUTPUT_TVA_TS1111,""))
    def test_get_audio_coding_format_from_output_tva_file_ts1111(self, *args):
        path_to_output_tva = "/mnt/nfs_managed/Countries/CSI/FromAirflow/crid~~3A~~2F~~2Fog.libertyglobal.com~~2F1001~~2Fts1111_20190325_113830pt/output_TVA/TVA_100006_20190325124647.xml"
        result = self.helpers_obj.get_audio_coding_formats_from_output_tva_file(path_to_output_tva)
        self.assertTrue(isinstance(result, dict))
        for value in list(result.values()):
            self.assertTrue(isinstance(value, list))
            self.assertEqual(len(value), 1)

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=(OUTPUT_TVA_TS0000,""))
    def test_get_audio_coding_format_from_output_tva_file_ts0000(self, *args):
        path_to_output_tva = "/mnt/nfs_managed/Countries/CSI/FromAirflow/crid~~3A~~2F~~2Fog.libertyglobal.com~~2F1001~~2Fts1111_20190325_113830pt/output_TVA/TVA_100006_20190325124647.xml"
        result = self.helpers_obj.get_audio_coding_formats_from_output_tva_file(path_to_output_tva)
        self.assertTrue(isinstance(result, dict))
        for value in list(result.values()):
            self.assertTrue(isinstance(value, list))
            self.assertEqual(len(value), 1)

    @mock.patch.object(helpers, "collect_log_files_masks", return_value=["some/path"])
    def test_check_ingestion_started_positive(self, *args):
        self.helpers_obj.packages = mock_data["robot"]["Keywords"]["ingestion.basic.robot"]["Run Ingestion Suite"]["results"]["HES-105"]["packages"]
        result = self.helpers_obj.check_ingestion_started("ts0220_20190325_113823pt")
        self.assertTrue(result)

    @mock.patch.object(helpers, "collect_log_files_masks", return_value=[])
    def test_check_ingestion_started_negative(self, *args):
        package = "ts0000_20190318_153140pt"
        self.helpers_obj.packages = mock_data["robot"]["Keywords"]["ingestion.basic.robot"]["Run Ingestion Suite"]["packages"]["HES-14"]["packages"]
        self.helpers_obj.packages[package]["airflow_workers_logs_masks"] = []
        result = self.helpers_obj.check_ingestion_started(package)
        self.assertFalse(result)

    def test_get_no_og_package_name(self, *args):
        custom_expected_result = "some_package_name"
        custom_actual_result = self.helpers_obj.get_no_og_package_name(custom_expected_result)
        self.assertEqual(custom_expected_result, custom_actual_result)

        random_actual_result = self.helpers_obj.get_no_og_package_name("Random")
        self.assertTrue(re.match("[0-9]{4}\_[0-9]{2}\_[0-9]{2}\-[0-9]{2}\_[0-9]{2}\_[0-9]{2}\-[0-9]{6}", random_actual_result))

    def test_get_no_og_watch_folder_path(self, *args):
        default_expected_result = E2E_CONF["mock"]["AIRFLOW_WORKERS"][0]["watch_folder"]
        default_actual_result = self.helpers_obj.get_no_og_watch_folder_path()
        self.assertEqual(default_expected_result, default_actual_result)
        default_actual_result = self.helpers_obj.get_no_og_watch_folder_path(None)
        self.assertEqual(default_expected_result, default_actual_result)

        custom_expected_result = "watch_folder_priority"
        custom_actual_result = self.helpers_obj.get_no_og_watch_folder_path(custom_expected_result)
        self.assertEqual(custom_expected_result, custom_actual_result)

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=("TVA_000001_20170802081133.xml", ""))
    def test_get_tva_file_name(self, *args):
        result = self.helpers_obj.get_tva_file_name("some/dir", SSH)
        self.assertEqual(result, "TVA_000001_20170802081133.xml")

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=("FFF_000001_20170802081133.xml", ""))
    def test_get_tva_file_name_exception_startswith(self, *args):
        self.assertRaises(Exception, self.helpers_obj.get_tva_file_name, "some/dir", SSH)

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=("TVA_000001_20170802081133.txt", ""))
    def test_get_tva_file_name_exception_endswith(self, *args):
        self.assertRaises(Exception, self.helpers_obj.get_tva_file_name, "some/dir", SSH)

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=("some/data", ""))
    def test_is_asset_present_in_watch_folder_positive(self, *args):
        result = self.helpers_obj.is_asset_present_in_watch_folder("some/folder", "some_package_name")
        self.assertTrue(result)

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=("", ""))
    def test_is_asset_present_in_watch_folder_negative(self, *args):
        result = self.helpers_obj.is_asset_present_in_watch_folder("some/folder", "some_package_name")
        self.assertFalse(result)

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=("", "some_errors"))
    def test_is_asset_present_in_watch_folder_exception(self, *args):
        self.assertRaises(Exception, self.helpers_obj.is_asset_present_in_watch_folder, "some/folder", "some_package_name")

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=(TVA_ts1111_XML, ""))
    def test_read_tva_keycheck(self, *args):
        result = self.helpers_obj.read_tva("some/folder", "some_package_name")
        key = "TVAMain"
        self.assertTrue(key in list(result.keys()))

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=(TVA_ts1111_XML, ""))
    def test_read_tva_type(self, *args):
        result = self.helpers_obj.read_tva("some/folder", "some_package_name")
        self.assertIs(type(result), dict)

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=("", "some_errors"))
    def test_read_tva_negative(self, *args):
        result = self.helpers_obj.read_tva("some/folder", "some_package_name")
        self.assertIs(type(result), list)

    def test_prepare_no_og_package_structure_keys(self, *args):
        self.helpers_obj.prepare_no_og_package_structure(True, "some_package_name", "some/folder", "some/file")
        actual_keylist = list(self.helpers_obj.packages["some_package_name"].keys())
        expected_keylist = ["adi", "tva", "output_tva", "fabrix_asset_id",
                            "properties", "airflow_workers_logs_masks", "actual_dag",
                            "transcoder_workers_logs_masks", "errors", 'new_time_delta',
                            "expiration_date", "new_tva_name"]
        self.assertIs(type(self.helpers_obj.packages["some_package_name"]), dict)
        self.assertListEqual(sorted(actual_keylist), sorted(expected_keylist))

    def test_prepare_no_og_package_structure_exception(self, *args):
        self.assertRaises(Exception, self.helpers_obj.prepare_no_og_package_structure, False, "some_package_name", "some/folder", "some/file")

    @mock.patch.object(Tools, "run_ssh_command_itself", side_effect=mock_create_unique_tva)
    @mock.patch.object(helpers, "read_tva", side_effect=mock_read_unique_tva_and_remove)
    def test_make_tva_instance_metadata_id_unique_positive(self, *args):
        result = self.helpers_obj.make_tva_instance_metadata_id_unique(
            self.offer_id, self.pkg_dir, self.ssh, self.test_tva_file_name,
            self.tva_program_description)
        on_demand_programs = result["TVAMain"]["ProgramDescription"]["ProgramLocationTable"]["OnDemandProgram"]
        for program in on_demand_programs:
            self.assertTrue(self.offer_id in program["InstanceMetadataId"])

    @mock.patch.object(Tools, "run_ssh_cmd", side_effect=mock_create_unique_tva)
    @mock.patch.object(helpers, "read_tva", side_effect=mock_read_unique_tva_and_remove)
    def test_make_tva_instance_metadata_id_unique_positive_dict(self, *args):
        tva_program_description = {'ProgramLocationTable': {'OnDemandProgram': {'InstanceMetadataId': 'imi:1001_ts1111_20190325_113830pt2'}}}
        result = self.helpers_obj.make_tva_instance_metadata_id_unique(
            self.offer_id, self.pkg_dir, self.ssh, self.test_tva_file_name,
            tva_program_description)
        on_demand_programs = result["TVAMain"]["ProgramDescription"]["ProgramLocationTable"]["OnDemandProgram"]
        result = False
        for program in on_demand_programs:
            if self.offer_id in program["InstanceMetadataId"]:
                result = True
        self.assertTrue(result)

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=("", "some error"))
    @mock.patch.object(helpers, "read_tva", return_value="")
    def test_make_tva_instance_metadata_id_unique_negative(self, *args):
        self.assertRaises(Exception, self.helpers_obj.make_tva_instance_metadata_id_unique,
                          self.offer_id, self.pkg_dir, self.ssh, self.test_tva_file_name,
                          self.tva_program_description)

    @mock.patch.object(Tools, "run_ssh_command_itself", side_effect=mock_create_unique_tva)
    @mock.patch.object(helpers, "read_tva", side_effect=mock_read_unique_tva_and_remove)
    def test_make_tva_group_id_unique_positive(self, *args):
        result = self.helpers_obj.make_tva_group_id_unique(
            self.offer_id, self.pkg_dir, self.ssh, self.test_tva_file_name,
            self.tva_program_description)
        group_information = result["TVAMain"]["ProgramDescription"]["GroupInformationTable"]["GroupInformation"]
        unique = False
        for info in group_information:
            if self.offer_id in info["@groupId"]:
                unique = True
        self.assertTrue(unique)

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=("", "some error"))
    @mock.patch.object(helpers, "read_tva", return_value="")
    def test_make_tva_group_id_unique_negative(self, *args):
        self.assertRaises(Exception, self.helpers_obj.make_tva_group_id_unique,
                          self.offer_id, self.pkg_dir, self.ssh, self.test_tva_file_name,
                          self.tva_program_description)

    @mock.patch.object(Tools, "run_ssh_command_itself", side_effect=mock_create_unique_tva)
    @mock.patch.object(helpers, "read_tva", side_effect=mock_read_unique_tva_and_remove)
    def test_make_tva_program_id_unique_positive(self, *args):
        result = self.helpers_obj.make_tva_program_id_unique(
            self.offer_id, self.pkg_dir, self.ssh, self.test_tva_file_name,
            self.tva_program_description)
        program_information = result["TVAMain"]["ProgramDescription"]["ProgramInformationTable"]["ProgramInformation"]
        unique = False
        for info in program_information:
            if self.offer_id in info["@programId"]:
                unique = True
        self.assertTrue(unique)

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=("", "some error"))
    @mock.patch.object(helpers, "read_tva", return_value="")
    def test_make_tva_program_id_unique_negative(self, *args):
        self.assertRaises(Exception, self.helpers_obj.make_tva_program_id_unique,
                          self.offer_id, self.pkg_dir, self.ssh, self.test_tva_file_name,
                          self.tva_program_description)

    @mock.patch.object(Tools, "run_ssh_command_itself", side_effect=mock_create_unique_tva)
    @mock.patch.object(helpers, "read_tva", side_effect=mock_read_unique_tva_and_remove)
    def test_make_tva_expiration_date_unique_positive(self, *args):
        now = datetime.datetime.utcnow()
        time_delta = datetime.timedelta(days=3)
        expected_expiration_date = now + time_delta
        expected_expiration_date = expected_expiration_date.strftime('%Y-%m-%dT%H:%M:%SZ')
        result = self.helpers_obj._change_tva_expiration_date(
            self.ssh, self.tva_xmldict, self.offer_id, self.pkg_dir, self.test_tva_file_name)[0]
        # BuiltIn().log_to_console(result)
        unique = False
        program_information = result["TVAMain"]["ProgramDescription"]["ProgramInformationTable"]["ProgramInformation"]
        for info in program_information:
            if expected_expiration_date in info["@fragmentExpirationDate"]:
                unique = True
        self.assertTrue(unique)

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=("", "some error"))
    @mock.patch.object(helpers, "read_tva", return_value="")
    def test_make_tva_expiration_date_unique_negative(self, *args):
        self.assertRaises(Exception, self.helpers_obj._change_tva_expiration_date,
                          self.ssh, self.tva_xmldict, self.offer_id, self.pkg_dir,
                          self.test_tva_file_name)

    @mock.patch.object(helpers, "read_tva", return_value=mock_read_tva("samples", "output_tva_ts0000.txt"))
    def test_get_images_from_output_tva_file(self, *args):
        images = self.helpers_obj.get_images_from_output_tva_file("some/path")
        self.assertTrue(isinstance(images, list))
        for image in images:
            self.assertTrue("http://" in image)
            self.assertTrue(".jpg" in image)

    def test_get_host_from_url(self, *args):
        url_with_ip = "http://172.30.108.114:8080/job/bitbucket-pull-request-trigger/"
        url_with_fqdn = "https://webserver1.end2end.airflow.upc.biz/admin/airflow/graph?dag_id=1"
        expected_ip = "172.30.108.114"
        expected_fqdn = "webserver1.end2end.airflow.upc.biz"
        actual_ip = self.helpers_obj.get_host_from_url(url_with_ip)
        actual_fqdn = self.helpers_obj.get_host_from_url(url_with_fqdn)

        self.assertEqual(expected_ip, actual_ip)
        self.assertEqual(expected_fqdn, actual_fqdn)

    @mock.patch.object(Tools, "run_ssh_command_itself",return_value=(mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["stdout_1"], ""))
    def test_get_dag_fail_reason_from_scratch_running(self, *args):
        cnf = E2E_CONF["mock"]["AIRFLOW_WORKERS"][0]
        given_failed_messages = {}
        expected_failed_messages = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["failed_messages_1"]
        mask = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["mask_1"]
        given_output = ""
        expected_output = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["output_1"]
        package = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["package"]

        actual_output, actual_failed_messages = self.helpers_obj.get_dag_fail_reason(cnf, given_failed_messages, mask, given_output, package)
        self.assertTrue(isinstance(actual_failed_messages, dict))
        self.assertEqual(actual_output, expected_output)
        self.assertEqual(actual_failed_messages, expected_failed_messages)
        self.assertEqual(mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["stdout_1"], actual_output)
        self.assertTrue(mask in list(actual_failed_messages.keys()))

    @mock.patch.object(Tools, "run_ssh_command_itself",return_value=(mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["stdout_2"], ""))
    def test_get_dag_fail_reason_update_running(self, *args):
        cnf = E2E_CONF["mock"]["AIRFLOW_WORKERS"][0]
        given_failed_messages = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["failed_messages_1"]
        expected_failed_messages = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["failed_messages_2"]
        mask = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["mask_2"]
        given_output = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["output_1"]
        expected_output = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["output_2"]
        package = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["package"]

        actual_output, actual_failed_messages = self.helpers_obj.get_dag_fail_reason(cnf, given_failed_messages, mask, given_output, package)
        self.assertTrue(isinstance(actual_failed_messages, dict))
        self.assertEqual(actual_output, expected_output)
        self.assertEqual(actual_failed_messages, expected_failed_messages)
        self.assertTrue(given_output in actual_output)
        self.assertTrue(mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["stdout_2"] in actual_output)
        self.assertTrue(mask in list(actual_failed_messages.keys()))
        self.assertTrue(mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["mask_1"] in list(actual_failed_messages.keys()))

    @mock.patch.object(Tools, "run_ssh_command_itself",return_value=(mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["stdout_2"], ""))
    def test_get_dag_fail_reason_unique_messages_only(self, *args):
        cnf = E2E_CONF["mock"]["AIRFLOW_WORKERS"][0]
        given_failed_messages = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["failed_messages_2"]
        mask = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["mask_2"]
        given_output = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["output_2"]
        package = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["package"]

        actual_output, actual_failed_messages = self.helpers_obj.get_dag_fail_reason(cnf, given_failed_messages, mask, given_output, package)
        self.assertEqual(actual_failed_messages, given_failed_messages)

    @mock.patch.object(Tools, "run_ssh_command_itself",return_value=("ERROR - File found in failed folder", ""))
    def test_get_dag_fail_reason_skip_rule_1(self, *args):
        cnf = E2E_CONF["mock"]["AIRFLOW_WORKERS"][0]
        given_failed_messages = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["failed_messages_2"]
        mask = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["mask_2"]
        given_output = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["output_2"]
        package = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["package"]

        actual_output, actual_failed_messages = self.helpers_obj.get_dag_fail_reason(cnf, given_failed_messages, mask, given_output, package)
        self.assertEqual(actual_failed_messages, given_failed_messages)

    @mock.patch.object(Tools, "run_ssh_command_itself",return_value=("ERROR - files were marked as failed", ""))
    def test_get_dag_fail_reason_skip_rule_2(self, *args):
        cnf = E2E_CONF["mock"]["AIRFLOW_WORKERS"][0]
        given_failed_messages = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["failed_messages_2"]
        mask = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["mask_2"]
        given_output = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["output_2"]
        package = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["package"]

        actual_output, actual_failed_messages = self.helpers_obj.get_dag_fail_reason(cnf, given_failed_messages, mask, given_output, package)
        self.assertEqual(actual_failed_messages, given_failed_messages)

    @mock.patch.object(Tools, "run_ssh_command_itself",return_value=("ERROR - File not found after retry: TVA_", ""))
    def test_get_dag_fail_reason_skip_rule_3(self, *args):
        cnf = E2E_CONF["mock"]["AIRFLOW_WORKERS"][0]
        given_failed_messages = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["failed_messages_2"]
        mask = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["mask_2"]
        given_output = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["output_2"]
        package = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_dag_fail_reason"]["package"]
        self.helpers_obj.packages[package] = {"tva": "/mnt/nfs_managed/Countries/CSI/FromAirflow/*ts0000_20190417_091942pt/TVA_100000_20190417112516.xml"}

        actual_output, actual_failed_messages = self.helpers_obj.get_dag_fail_reason(cnf, given_failed_messages, mask, given_output, package)
        self.assertEqual(actual_failed_messages, given_failed_messages)

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=(OUTPUT_TVA_TS0000, ""))
    @mock.patch.object(Tools, "run_local_command", return_value=0)
    @mock.patch.object(helpers, "get_mediainfo_by_url", return_value=mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_all_thumbnails_aspect_ratio_from_output_tva"]["media_info_string"]["ts0000"])
    @mock.patch.object(helpers, "insure_thumbnails_workflow_enabled", return_value=True)
    def test_get_all_thumbnails_aspect_ratio_from_output_tva(self, *args):
        airflow_workers_logs_masks = ["/some/path_1/.1.log", "/some/path_2/.1.log"]
        all_aspect_ratio = self.helpers_obj.get_all_thumbnails_aspect_ratio_from_output_tva(
            "/some/path", airflow_workers_logs_masks)
        self.assertTrue(isinstance(all_aspect_ratio, list))
        for ratio in all_aspect_ratio:
            self.assertTrue(isinstance(ratio, float))

    @mock.patch.object(helpers, "get_log_data", side_effect=mock_get_log_data)
    def test_get_manifest_url_from_log(self, *args):
        actual_dag = 'csi_lab_create_obo_assets_workflow'
        device_type = "selene"
        pattern = "http.+\/Manifest\?device\=[a-z, A-Z, 0-9, -]+"

        log_masks = mock_data["robot"]["Keywords"]["ingestion.basic.robot"]["Run Ingestion Suite"]["results"]["HES-105"]["packages"]["ts0220_20190325_113823pt"]["airflow_workers_logs_masks"]
        url = self.helpers_obj.get_manifest_url_from_log(log_masks, actual_dag, device_type)
        self.assertTrue(re.match(pattern, url))

    @mock.patch.object(helpers, "get_log_data", side_effect=mock_get_log_data)
    def test_get_manifest_url_from_log_negative(self, *args):
        actual_dag = 'csi_lab_create_obo_assets_workflow'
        device_type = "selene"
        pattern = "http.+\/Manifest\?device\=[a-z, A-Z, 0-9, -]+"
        log_masks = ""
        with self.assertRaises(Exception) as err_obj:
            self.helpers_obj.get_manifest_url_from_log(log_masks, actual_dag, device_type)
        err_msg = err_obj.exception
        self.assertEqual(str(err_msg), "Path to 'perform_movie_selene_video_qc' log file was not found in log masks list")

    @mock.patch.object(helpers, "get_log_data", side_effect=mock_get_log_data)
    def test_get_manifest_url_from_log_transcoding_driven_workflow(self, *args):
        actual_dag = 'csi_lab_create_obo_assets_transcoding_driven_workflow'
        device_type = ""
        pattern = "http.+\/Manifest\?device\=[a-z, A-Z, 0-9, -]+"
        log_masks = mock_data["robot"]["Keywords"]["ingestion.basic.robot"]["Run Ingestion Suite"]["results"]["HES-105"]["packages"]["ts0220_20190325_113823pt"]["airflow_workers_logs_masks"]
        urls = self.helpers_obj.get_manifest_url_from_log(log_masks, actual_dag, device_type)
        self.assertIs(type(urls), list)
        for url in urls:
            self.assertTrue(re.match(pattern, url))

    @mock.patch.object(helpers, "get_log_data", side_effect=mock_get_log_data)
    def test_get_manifest_url_from_log_transcoding_driven_workflow_negative(self, *args):
        actual_dag = 'csi_lab_create_obo_assets_transcoding_driven_workflow'
        device_type = ""
        pattern = "http.+\/Manifest\?device\=[a-z, A-Z, 0-9, -]+"
        log_masks = ""
        with self.assertRaises(Exception) as err_obj:
            self.helpers_obj.get_manifest_url_from_log(log_masks, actual_dag, device_type)
        err_msg = err_obj.exception
        self.assertEqual(str(err_msg), "Path to 'perform_videos_qc' log file was not found in log masks list")

    def test_define_fabrix_asset_ids_info(self, *args):
        package_name = self.offer_id
        self.helpers_obj.packages[package_name] = {}
        for dag_name in ["csi_lab_create_obo_assets_workflow", "csi_lab_create_obo_assets_transcoding_driven_workflow"]:
            dictionary_from_airflow_log = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_particular_fabrix_asset_id_of_package"]["get_particular_fabrix_asset_id_of_package"][dag_name]
            self.helpers_obj._define_fabrix_asset_ids_info(package_name, dictionary_from_airflow_log, dag_name)
            result = self.helpers_obj.packages[package_name]["fabrix_asset_ids_info"]
            # BuiltIn().log_to_console(result)
            self.assertTrue(isinstance(result, dict))
            pattern = "[a-z,A-Z,0-9]{32}_[a-z,A-Z,0-9]{32}"
            for fabrix_asset_id in list(result.keys()):
                self.assertTrue(re.match(pattern, fabrix_asset_id))
                for property in ["device_type", "video_type", "aspect_ratio"]:
                    self.assertTrue(property in list(result[fabrix_asset_id].keys()))
                    self.assertEqual(len(list(result[fabrix_asset_id].keys())), 3)
                for value in list(result[fabrix_asset_id].values()):
                    self.assertTrue(value in ["ott", "stb", "movie", "preview", "1.333", "1.778"])

    def test_get_image_aspect_ratio(self, *args):
        height = 2
        width = 10
        aspect_ratio = self.helpers_obj.get_image_aspect_ratio(height, width)
        self.assertEqual(aspect_ratio, 5.0)
        height = 3
        width = 10
        aspect_ratio = self.helpers_obj.get_image_aspect_ratio(height, width)
        self.assertEqual(aspect_ratio, 3.33)

    def test_get_image_size(self, *args):
        result = self.helpers_obj.get_image_size("samples/lgi_logo.jpg")
        self.assertTrue(isinstance(result, tuple))
        self.assertEqual(len(result), 2)
        self.assertEqual(result, (250, 300))

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=("68", ""))
    def test_get_asset_thumbnails_count_positive(self, *args):
        package_name = "some_name"
        fabrix_asset_id = "some_id"
        result = self.helpers_obj.get_asset_thumbnails_count(package_name, fabrix_asset_id)
        self.assertTrue(isinstance(result, int))
        self.assertEqual(result, 68)

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=("", ""))
    def test_get_asset_thumbnails_count_negative_stdout(self, *args):
        package_name = "some_name"
        fabrix_asset_id = "some_id"
        self.assertRaises(
            Exception,
            self.helpers_obj.get_asset_thumbnails_count,
            package_name,
            fabrix_asset_id
        )

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=("", "some error"))
    def test_get_asset_thumbnails_count_negative_stderr(self, *args):
        package_name = "some_name"
        fabrix_asset_id = "some_id"
        self.assertRaises(
            Exception,
            self.helpers_obj.get_asset_thumbnails_count,
            package_name,
            fabrix_asset_id
        )

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=("1 min 26 s", ""))
    def test_get_asset_general_duration_in_seconds_positive_long_duration(self, *args):
        package_name = "some_name"
        fabrix_asset_id = "some_id"
        result = self.helpers_obj.get_asset_general_duration_in_seconds(package_name, fabrix_asset_id)
        self.assertTrue(isinstance(result, int))
        self.assertEqual(result, 86)

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=("18 s", ""))
    def test_get_asset_general_duration_in_seconds_positive_short_duration(self, *args):
        package_name = "some_name"
        fabrix_asset_id = "some_id"
        result = self.helpers_obj.get_asset_general_duration_in_seconds(package_name, fabrix_asset_id)
        self.assertTrue(isinstance(result, int))
        self.assertEqual(result, 18)

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=("", ""))
    def test_get_asset_general_duration_in_seconds_negative_stdout(self, *args):
        package_name = "some_name"
        fabrix_asset_id = "some_id"
        self.assertRaises(
            Exception,
            self.helpers_obj.get_asset_general_duration_in_seconds,
            package_name,
            fabrix_asset_id
        )

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=("", "some error"))
    def test_get_asset_general_duration_in_seconds_negative_stderr(self, *args):
        package_name = "some_name"
        fabrix_asset_id = "some_id"
        self.assertRaises(
            Exception,
            self.helpers_obj.get_asset_general_duration_in_seconds,
            package_name,
            fabrix_asset_id
        )

    @mock.patch.object(urllib.request, "urlopen", side_effect=mock_urlopen)
    def test_get_all_thumbnails_urls(self, *args):
        fabrix_asset_id = "9377980492f6df1d7427e3c376c7f81f_3db98b518644918080e48343bdb644a1"
        expected_result = [
            '/thumbnail-service/assets/9377980492f6df1d7427e3c376c7f81f_3db98b518644918080e48343bdb644a1/1.bin#bytes=0-2172',
            '/thumbnail-service/assets/9377980492f6df1d7427e3c376c7f81f_3db98b518644918080e48343bdb644a1/1.bin#bytes=2173-11151',
            '/thumbnail-service/assets/9377980492f6df1d7427e3c376c7f81f_3db98b518644918080e48343bdb644a1/1.bin#bytes=11152-21345',
            '/thumbnail-service/assets/9377980492f6df1d7427e3c376c7f81f_3db98b518644918080e48343bdb644a1/1.bin#bytes=21346-24040',
            '/thumbnail-service/assets/9377980492f6df1d7427e3c376c7f81f_3db98b518644918080e48343bdb644a1/1.bin#bytes=24041-30076',
            '/thumbnail-service/assets/9377980492f6df1d7427e3c376c7f81f_3db98b518644918080e48343bdb644a1/1.bin#bytes=30077-40191',
            '/thumbnail-service/assets/9377980492f6df1d7427e3c376c7f81f_3db98b518644918080e48343bdb644a1/1.bin#bytes=40192-50981',
            '/thumbnail-service/assets/9377980492f6df1d7427e3c376c7f81f_3db98b518644918080e48343bdb644a1/1.bin#bytes=50982-57113']

        result = self.helpers_obj.get_all_thumbnails_urls(fabrix_asset_id)
        self.assertEqual(result, expected_result)

    def test_insure_thumbnails_workflow_enabled_positive(self, *args):
        airflow_workers_logs_masks = [
            "/log/number/1.log",
            "/log/number/2.log",
            "/log/need_to_generate_thumbnails/1.log",
            "/log/number/3.log",
        ]
        result = self.helpers_obj.insure_thumbnails_workflow_enabled(airflow_workers_logs_masks)
        self.assertTrue(result)

    def test_insure_thumbnails_workflow_enabled_negative(self, *args):
        airflow_workers_logs_masks = [
            "/log/number/1.log",
            "/log/number/2.log",
            "/log/number/3.log",
            "/log/number/4.log",
        ]
        result = self.helpers_obj.insure_thumbnails_workflow_enabled(airflow_workers_logs_masks)
        self.assertFalse(result)

    @mock.patch.object(requests, "get", side_effect=mock_requests_get)
    @mock.patch.object(helpers, "get_image_size", return_value=(100, 200))
    def test_get_thumbnails_size(self, *args):
        thumbnail_url = "/thumbnail-service/assets/9377980492f6df1d7427e3c376c7f81f_3db98b518644918080e48343bdb644a1/1.bin#bytes=40192-50981"
        result = self.helpers_obj.get_thumbnails_size(thumbnail_url)
        self.assertTrue(isinstance(result, tuple))
        self.assertEqual(result, (100, 200))

    @mock.patch.object(Tools, "run_ssh_cmd", return_value=(PROPERTIES, ""))
    def test_get_log_data_list_return(self, *args):
        expected_result = PROPERTIES.splitlines()
        actual_result = self.helpers_obj.get_log_data("/some/path")
        self.assertIs(type(actual_result), list)
        self.assertListEqual(actual_result, expected_result)

    @mock.patch.object(Tools, "run_ssh_cmd", return_value=(PROPERTIES, ""))
    def test_get_log_data_str_return(self, *args):
        expected_result = PROPERTIES
        actual_result = self.helpers_obj.get_log_data("/some/path", split_lines=False)
        self.assertEqual(actual_result, expected_result)

    @mock.patch.object(Tools, "run_ssh_cmd", return_value=("", ""))
    def test_get_log_data_expection(self, *args):
        with self.assertRaises(Exception) as err_obj:
            self.helpers_obj.get_log_data("/some/path")
        err_msg = err_obj.exception
        self.assertEqual(str(err_msg), "Log file is *NOT* present on the 'AIRFLOW_WORKERS' servers for the path /some/path")

    @mock.patch.object(Tools, "run_ssh_cmd", return_value=(PROPERTIES, ""))
    @mock.patch.object(ast, "literal_eval", return_value=PROPERTIES_DICT)
    def test_get_assets_from_generate_tva_file_return(self, *args):
        expected_result = PROPERTIES_DICT
        actual_result = self.helpers_obj.get_assets_from_generate_tva_file("/some/path")
        self.assertIs(type(actual_result), dict)
        self.assertDictEqual(actual_result, expected_result)

    @mock.patch.object(Tools, "run_ssh_cmd", return_value=("", ""))
    def test_get_assets_from_generate_tva_file_negative(self, *args):
        with self.assertRaises(Exception) as err_obj:
            self.helpers_obj.get_assets_from_generate_tva_file("/some/path")
        err_msg = err_obj.exception
        self.assertEqual(str(err_msg), "Log file is *NOT* present on the 'AIRFLOW_WORKERS' servers for the path /some/path")

    def test_get_assets_from_generate_tva_file_exception(self, *args):
        with self.assertRaises(Exception) as err_obj:
            self.helpers_obj.get_assets_from_generate_tva_file("")
        err_msg = err_obj.exception
        self.assertEqual(str(err_msg), "logfile_path parameter passed is *NOT* valid on the 'AIRFLOW_WORKERS' servers")

    def test_check_dag_workflow_steps_status_no_service(self, *args):
        with self.assertRaises(Exception) as err_obj:
            self.helpers_obj.check_dag_workflow_steps_status("some_filepath", "", "some_dag")
        err_msg = err_obj.exception
        self.assertEqual(str(err_msg), "Service workflow check is invalid, check service string: ")

    @mock.patch("requests.get", side_effect=mock_requests_get)
    def test_check_dag_workflow_steps_status_bad_request(self, *args):
        with self.assertRaises(Exception) as err_obj:
            self.helpers_obj.check_dag_workflow_steps_status("some_filepath", "some_string", "some_dag")
        err_msg = err_obj.exception
        expected_msg = "some_filepath file url for ingested workflow details is not valued" \
                       " http://some.host.com/dag_runs?filename=some_filepath"

        self.assertEqual(str(err_msg), expected_msg)

    @mock.patch.object(helpers, "_change_tva_expiration_date", return_value=("updated_tva_file", "new_expiration_date"))
    @mock.patch.object(helpers, "make_tva_program_id_unique")
    @mock.patch.object(helpers, "make_tva_group_id_unique")
    @mock.patch.object(helpers, "make_tva_instance_metadata_id_unique")
    def test_make_tva_unique(
            self, mock_make_tva_instance_metadata_id_unique,
            mock_make_tva_group_id_unique,
            mock_make_tva_program_id_unique,
            mock_change_tva_expiration_date, *args):
        ssh = "ssh"
        tva_xmldict = {
            "TVAMain": {
                "ProgramDescription": "dummy value"
            }
        }
        tva_program_description = tva_xmldict["TVAMain"]["ProgramDescription"]
        offer_id = "offer_id"
        pkg_dir = "pkg_dir",
        tva_fname = "tva_fname"
        new_time_delta = "new_time_delta"
        result = self.helpers_obj._make_tva_unique(
            ssh=ssh, tva_xmldict=tva_xmldict, offer_id=offer_id, pkg_dir=pkg_dir,
            tva_fname=tva_fname, new_time_delta=new_time_delta
        )
        mock_change_tva_expiration_date.assert_called_with(
            ssh, tva_xmldict, offer_id, pkg_dir, tva_fname, new_time_delta
        )
        mock_make_tva_program_id_unique.assert_called_with(
            offer_id, pkg_dir, ssh, tva_fname, tva_program_description
        )
        mock_make_tva_group_id_unique.assert_called_with(
            offer_id, pkg_dir, ssh, tva_fname, tva_program_description
        )
        mock_make_tva_instance_metadata_id_unique.assert_called_with(
            offer_id, pkg_dir, ssh, tva_fname, tva_program_description
        )
        self.assertEqual(result, "new_expiration_date")

    def test_get_time_delta_object_from_string(self, *args):
        time_delta_list = ["1-days", "2-seconds", "3-microseconds", "4-milliseconds",
                           "5-minutes", "6-hours", "7-weeks"]

        for new_time_delta in time_delta_list:
            value, units = new_time_delta.split("-")
            kwargs = dict()
            kwargs[units] = int(value)
            result = self.helpers_obj.get_time_delta_object_from_string(new_time_delta)
            self.assertTrue(isinstance(result, datetime.timedelta))
            self.assertEqual(
                result, datetime.timedelta(**kwargs)
            )

    @mock.patch.object(helpers, "prepare_no_og_package_structure")
    @mock.patch.object(helpers, "is_asset_present_in_watch_folder", return_value=True)
    @mock.patch.object(tools, "run_ssh_cmd", return_value="")
    @mock.patch.object(helpers, "rename_tva_file", return_value="TVA_dummy_new.xml")
    @mock.patch.object(helpers, "change_asset_image_extension")
    @mock.patch.object(helpers, "_change_tva_expiration_date", return_value="01.01.2020")
    @mock.patch.object(helpers, "_make_tva_unique", return_value="01.01.2020")
    @mock.patch.object(helpers, "read_tva", return_value="dummy content")
    @mock.patch.object(helpers, "get_tva_file_name", return_value="TVA_dummy.xml")
    @mock.patch.object(helpers, "run_ssh_commands_for_no_og_ingestion", return_value="/dummy/watch/folder")
    @mock.patch.object(helpers, "get_no_og_watch_folder_path", return_value="/dummy/watch/folder")
    @mock.patch.object(helpers, "get_no_og_package_name", return_value="dummy_package_name")
    def test_create_no_og_package(
            self,
            mock_get_no_og_package_name,
            mock_get_no_og_watch_folder_path,
            mock_run_ssh_commands_for_no_og_ingestion,
            mock_get_tva_file_name,
            mocked_read_tva,
            mock_make_tva_unique,
            mock_change_tva_expiration_date,
            mock_change_asset_image_extension,
            mock_rename_tva_file,
            mocked_run_ssh_cmd,
            mock_is_asset_present_in_watch_folder,
            mock_prepare_no_og_package_structure,
            *args
    ):

        ssh = [self.conf["AIRFLOW_WORKERS"][0]["host"], self.conf["AIRFLOW_WORKERS"][0]["port"],
               self.conf["AIRFLOW_WORKERS"][0]["user"], self.conf["AIRFLOW_WORKERS"][0]["password"]]
        package_name = "dummy_package_name"
        pkg_dir = "/dummy/watch/folder/%s" % package_name
        tva_fname = "TVA_dummy.xml"
        watch_folder = "/dummy/watch/folder"
        self.helpers_obj.create_no_og_package(self.path)
        mock_get_no_og_package_name.assert_called_with("Random")
        mock_get_no_og_watch_folder_path.assert_called_with(None)
        mock_run_ssh_commands_for_no_og_ingestion.assert_called_with(ssh, pkg_dir, self.path, None)
        mock_get_tva_file_name.assert_called_with(pkg_dir, ssh)
        mocked_read_tva.assert_called_with(pkg_dir, tva_fname)
        mock_make_tva_unique.assert_called_with(
            ssh, "dummy content", package_name, pkg_dir, tva_fname, None
        )
        mock_change_tva_expiration_date.assert_not_called()
        mock_change_asset_image_extension.assert_not_called()
        mock_rename_tva_file.assert_not_called()
        mocked_run_ssh_cmd.assert_not_called()
        mock_is_asset_present_in_watch_folder.assert_called_with(watch_folder, package_name)
        mock_prepare_no_og_package_structure.assert_called_with(
            True, package_name, watch_folder, tva_fname, None, "01.01.2020", None
        )

    @mock.patch.object(helpers, "prepare_no_og_package_structure")
    @mock.patch.object(helpers, "is_asset_present_in_watch_folder", return_value=True)
    @mock.patch.object(Tools, "run_ssh_cmd", return_value=("", "dummy error"))
    @mock.patch.object(helpers, "rename_tva_file", return_value="TVA_dummy_new.xml")
    @mock.patch.object(helpers, "change_asset_image_extension")
    @mock.patch.object(helpers, "_change_tva_expiration_date", return_value="01.01.2020")
    @mock.patch.object(helpers, "_make_tva_unique", return_value="01.01.2020")
    @mock.patch.object(helpers, "read_tva", return_value="dummy content")
    @mock.patch.object(helpers, "get_tva_file_name", return_value="TVA_dummy.xml")
    @mock.patch.object(helpers, "run_ssh_commands_for_no_og_ingestion", return_value="/dummy/watch/folder")
    @mock.patch.object(helpers, "get_no_og_watch_folder_path", return_value="/dummy/watch/folder")
    @mock.patch.object(helpers, "get_no_og_package_name", return_value="dummy_package_name")
    def test_create_no_og_package_keep_lock_false_error(
            self,
            mock_get_no_og_package_name,
            mock_get_no_og_watch_folder_path,
            mock_run_ssh_commands_for_no_og_ingestion,
            mock_get_tva_file_name,
            mocked_read_tva,
            mock_make_tva_unique,
            mock_change_tva_expiration_date,
            mock_change_asset_image_extension,
            mock_rename_tva_file,
            mocked_run_ssh_cmd,
            mock_is_asset_present_in_watch_folder,
            mock_prepare_no_og_package_structure,
            *args
    ):

        ssh = [self.conf["AIRFLOW_WORKERS"][0]["host"], self.conf["AIRFLOW_WORKERS"][0]["port"],
               self.conf["AIRFLOW_WORKERS"][0]["user"], self.conf["AIRFLOW_WORKERS"][0]["password"]]
        package_name = "dummy_package_name"
        pkg_dir = "/dummy/watch/folder/%s" % package_name
        tva_fname = "TVA_dummy.xml"
        result = self.helpers_obj.create_no_og_package(self.path, keep_lock=False)
        mock_get_no_og_package_name.assert_called_with("Random")
        mock_get_no_og_watch_folder_path.assert_called_with(None)
        mock_run_ssh_commands_for_no_og_ingestion.assert_called_with(ssh, pkg_dir, self.path, None)
        mock_get_tva_file_name.assert_called_with(pkg_dir, ssh)
        mocked_read_tva.assert_called_with(pkg_dir, tva_fname)
        mock_make_tva_unique.assert_called_with(
            ssh, "dummy content", package_name, pkg_dir, tva_fname, None
        )
        mock_change_tva_expiration_date.assert_not_called()
        mock_change_asset_image_extension.assert_not_called()
        mock_rename_tva_file.assert_not_called()
        mocked_run_ssh_cmd.assert_called_with(
            *(ssh + ["rm -f %s/lock.tmp" % pkg_dir])
        )
        mock_is_asset_present_in_watch_folder.assert_not_called()
        mock_prepare_no_og_package_structure.assert_not_called()
        self.assertEqual(result, ["dummy error"])

    @mock.patch.object(helpers, "prepare_no_og_package_structure")
    @mock.patch.object(helpers, "is_asset_present_in_watch_folder", return_value=True)
    @mock.patch.object(tools, "run_ssh_cmd", return_value="")
    @mock.patch.object(helpers, "rename_tva_file", return_value="TVA_dummy_new.xml")
    @mock.patch.object(helpers, "change_asset_image_extension")
    @mock.patch.object(helpers, "_change_tva_expiration_date", return_value="01.01.2020")
    @mock.patch.object(helpers, "_make_tva_unique", return_value="01.01.2020")
    @mock.patch.object(helpers, "read_tva", return_value="dummy content")
    @mock.patch.object(helpers, "get_tva_file_name", return_value="TVA_dummy.xml")
    @mock.patch.object(helpers, "run_ssh_commands_for_no_og_ingestion", return_value="/dummy/watch/folder")
    @mock.patch.object(helpers, "get_no_og_watch_folder_path", return_value="/dummy/watch/folder")
    @mock.patch.object(helpers, "get_no_og_package_name", return_value="dummy_package_name")
    def test_create_no_og_package_change_image_extension(
            self,
            mock_get_no_og_package_name,
            mock_get_no_og_watch_folder_path,
            mock_run_ssh_commands_for_no_og_ingestion,
            mock_get_tva_file_name,
            mocked_read_tva,
            mock_make_tva_unique,
            mock_change_tva_expiration_date,
            mock_change_asset_image_extension,
            mock_rename_tva_file,
            mocked_run_ssh_cmd,
            mock_is_asset_present_in_watch_folder,
            mock_prepare_no_og_package_structure,
            *args
    ):

        ssh = [self.conf["AIRFLOW_WORKERS"][0]["host"], self.conf["AIRFLOW_WORKERS"][0]["port"],
               self.conf["AIRFLOW_WORKERS"][0]["user"], self.conf["AIRFLOW_WORKERS"][0]["password"]]
        package_name = "dummy_package_name"
        pkg_dir = "/dummy/watch/folder/%s" % package_name
        tva_fname = "TVA_dummy.xml"
        watch_folder = "/dummy/watch/folder"
        change_image_extension = "png"
        self.helpers_obj.create_no_og_package(self.path, change_image_extension=change_image_extension)
        mock_get_no_og_package_name.assert_called_with("Random")
        mock_get_no_og_watch_folder_path.assert_called_with(None)
        mock_run_ssh_commands_for_no_og_ingestion.assert_called_with(ssh, pkg_dir, self.path, None)
        mock_get_tva_file_name.assert_called_with(pkg_dir, ssh)
        mocked_read_tva.assert_called_with(pkg_dir, tva_fname)
        mock_make_tva_unique.assert_called_with(
            ssh, "dummy content", package_name, pkg_dir, tva_fname, None
        )
        mock_change_tva_expiration_date.assert_not_called()
        mock_change_asset_image_extension.assert_called_with(
            ssh, pkg_dir, change_image_extension
        )
        mock_rename_tva_file.assert_called_with(
            pkg_dir, ssh, tva_fname
        )
        mocked_run_ssh_cmd.assert_not_called()
        mock_is_asset_present_in_watch_folder.assert_called_with(watch_folder, package_name)
        mock_prepare_no_og_package_structure.assert_called_with(
            True, package_name, watch_folder, 'TVA_dummy_new.xml', None, "01.01.2020", None
        )

    @mock.patch.object(helpers, "prepare_no_og_package_structure")
    @mock.patch.object(helpers, "is_asset_present_in_watch_folder", return_value=True)
    @mock.patch.object(tools, "run_ssh_cmd", return_value="")
    @mock.patch.object(helpers, "rename_tva_file", return_value="TVA_dummy_new.xml")
    @mock.patch.object(helpers, "change_asset_image_extension")
    @mock.patch.object(helpers, "_change_tva_expiration_date", return_value="01.01.2020")
    @mock.patch.object(helpers, "_make_tva_unique", return_value="01.01.2020")
    @mock.patch.object(helpers, "read_tva", return_value="dummy content")
    @mock.patch.object(helpers, "get_tva_file_name", return_value="TVA_dummy.xml")
    @mock.patch.object(helpers, "run_ssh_commands_for_no_og_ingestion", return_value="/dummy/watch/folder")
    @mock.patch.object(helpers, "get_no_og_watch_folder_path", return_value="/dummy/watch/folder")
    @mock.patch.object(helpers, "get_no_og_package_name", return_value="dummy_package_name")
    def test_create_no_og_package_unique_false(
            self,
            mock_get_no_og_package_name,
            mock_get_no_og_watch_folder_path,
            mock_run_ssh_commands_for_no_og_ingestion,
            mock_get_tva_file_name,
            mocked_read_tva,
            mock_make_tva_unique,
            mock_change_tva_expiration_date,
            mock_change_asset_image_extension,
            mock_rename_tva_file,
            mocked_run_ssh_cmd,
            mock_is_asset_present_in_watch_folder,
            mock_prepare_no_og_package_structure,
            *args
    ):

        ssh = [self.conf["AIRFLOW_WORKERS"][0]["host"], self.conf["AIRFLOW_WORKERS"][0]["port"],
               self.conf["AIRFLOW_WORKERS"][0]["user"], self.conf["AIRFLOW_WORKERS"][0]["password"]]
        package_name = "dummy_package_name"
        pkg_dir = "/dummy/watch/folder/%s" % package_name
        tva_fname = "TVA_dummy.xml"
        watch_folder = "/dummy/watch/folder"
        self.helpers_obj.create_no_og_package(self.path, unique=False)
        mock_get_no_og_package_name.assert_called_with("Random")
        mock_get_no_og_watch_folder_path.assert_called_with(None)
        mock_run_ssh_commands_for_no_og_ingestion.assert_called_with(ssh, pkg_dir, self.path, None)
        mock_get_tva_file_name.assert_called_with(pkg_dir, ssh)
        mocked_read_tva.assert_called_with(pkg_dir, tva_fname)
        mock_make_tva_unique.assert_not_called()
        mock_change_tva_expiration_date.assert_called_with(
            ssh, "dummy content", package_name, pkg_dir, tva_fname
        )
        mock_change_asset_image_extension.assert_not_called()
        mock_rename_tva_file.assert_not_called()
        mocked_run_ssh_cmd.assert_not_called()
        mock_is_asset_present_in_watch_folder.assert_called_with(watch_folder, package_name)
        mock_prepare_no_og_package_structure.assert_called_with(
            True, package_name, watch_folder, tva_fname, None, "1", None
        )

    @mock.patch.object(helpers, "prepare_no_og_package_structure")
    @mock.patch.object(helpers, "is_asset_present_in_watch_folder", return_value=True)
    @mock.patch.object(tools, "run_ssh_cmd", return_value="")
    @mock.patch.object(helpers, "rename_tva_file", return_value="TVA_dummy_new.xml")
    @mock.patch.object(helpers, "change_asset_image_extension")
    @mock.patch.object(helpers, "_change_tva_expiration_date", return_value="01.01.2020")
    @mock.patch.object(helpers, "_make_tva_unique", return_value="01.01.2020")
    @mock.patch.object(helpers, "read_tva", return_value=["dummy error"])
    @mock.patch.object(helpers, "get_tva_file_name", return_value="TVA_dummy.xml")
    @mock.patch.object(helpers, "run_ssh_commands_for_no_og_ingestion", return_value="/dummy/watch/folder")
    @mock.patch.object(helpers, "get_no_og_watch_folder_path", return_value="/dummy/watch/folder")
    @mock.patch.object(helpers, "get_no_og_package_name", return_value="dummy_package_name")
    def test_create_no_og_package_error_read_tva(
            self,
            mock_get_no_og_package_name,
            mock_get_no_og_watch_folder_path,
            mock_run_ssh_commands_for_no_og_ingestion,
            mock_get_tva_file_name,
            mocked_read_tva,
            mock_make_tva_unique,
            mock_change_tva_expiration_date,
            mock_change_asset_image_extension,
            mock_rename_tva_file,
            mocked_run_ssh_cmd,
            mock_is_asset_present_in_watch_folder,
            mock_prepare_no_og_package_structure,
            *args
    ):

        ssh = [self.conf["AIRFLOW_WORKERS"][0]["host"], self.conf["AIRFLOW_WORKERS"][0]["port"],
               self.conf["AIRFLOW_WORKERS"][0]["user"], self.conf["AIRFLOW_WORKERS"][0]["password"]]
        package_name = "dummy_package_name"
        pkg_dir = "/dummy/watch/folder/%s" % package_name
        tva_fname = "TVA_dummy.xml"
        result = self.helpers_obj.create_no_og_package(self.path)
        mock_get_no_og_package_name.assert_called_with("Random")
        mock_get_no_og_watch_folder_path.assert_called_with(None)
        mock_run_ssh_commands_for_no_og_ingestion.assert_called_with(ssh, pkg_dir, self.path, None)
        mock_get_tva_file_name.assert_called_with(pkg_dir, ssh)
        mocked_read_tva.assert_called_with(pkg_dir, tva_fname)
        mock_make_tva_unique.assert_not_called()
        mock_change_tva_expiration_date.assert_not_called()
        mock_change_asset_image_extension.assert_not_called()
        mock_rename_tva_file.assert_not_called()
        mocked_run_ssh_cmd.assert_not_called()
        mock_is_asset_present_in_watch_folder.assert_not_called()
        mock_prepare_no_og_package_structure.assert_not_called()
        self.assertEqual(result, ["dummy error"])

    @mock.patch.object(Tools, "run_ssh_cmd", return_value=("", ""))
    def test_run_bad_metadata_command(self, mocked_run_ssh_cmd, *args):
        """Test for 'run_bad_metadata_command' method
        """
        bad_data = {
            'xpath_locate': "./Asset/Asset/Metadata/AMS[@Asset_Class='poster']",
            'xpath_change': '../../Content',
            'attrs': {'Value': 'POSTER.JPG'},
            'cmd': 'mv %(dir_to_adi)s/%(old_val)s %(dir_to_adi)s/POSTER.JPG'
        }
        old_val = "dummy_val"
        path_to_adi = "/path/dummy"
        ssh_creds = [self.conf["ASSET_GENERATOR"]["host"], self.conf["ASSET_GENERATOR"]["port"],
                     self.conf["ASSET_GENERATOR"]["user"], self.conf["ASSET_GENERATOR"]["password"]]
        stderr = self.helpers_obj.run_bad_metadata_command(bad_data, old_val, path_to_adi, ssh_creds)
        mocked_run_ssh_cmd.assert_called_with(
            ssh_creds[0], ssh_creds[1], ssh_creds[2], ssh_creds[3],
            'mv /path/dummy_val /path/POSTER.JPG')
        self.assertFalse(stderr)

    @mock.patch.object(helpers, "change_line_in_file")
    @mock.patch.object(helpers, "rename_file")
    @mock.patch.object(helpers, "get_directory_structure", return_value=("1.jpg\n3.png\n3.png\n4.xml", ""))
    def test_change_asset_image_extension(
            self,
            mocked_get_directory_structure,
            mocked_rename_file,
            mocked_change_line_in_file,
            *args
    ):
        """Test for 'run_bad_metadata_command' method"""
        ssh = [self.conf["AIRFLOW_WORKERS"][0]["host"], self.conf["AIRFLOW_WORKERS"][0]["port"],
               self.conf["AIRFLOW_WORKERS"][0]["user"], self.conf["AIRFLOW_WORKERS"][0]["password"]]
        pkg_dir = "/path/dummy"
        change_image_extension = ["png", "jpg"]
        self.helpers_obj.change_asset_image_extension(ssh, pkg_dir, change_image_extension)
        mocked_get_directory_structure.assert_called_with(ssh, pkg_dir)
        mocked_rename_file.assert_called_with(ssh, "/path/dummy/3.png", "3.jpg")
        mocked_change_line_in_file.assert_called_with(ssh, "/path/dummy/4.xml", "3.png", "3.jpg")

    @mock.patch.object(helpers, "change_line_in_file")
    @mock.patch.object(helpers, "rename_file")
    @mock.patch.object(helpers, "get_directory_structure", return_value=("", "error message"))
    def test_change_asset_image_extension_exception(
            self,
            mocked_get_directory_structure,
            mocked_rename_file,
            mocked_change_line_in_file,
            *args
    ):
        """Test for 'run_bad_metadata_command' method"""
        ssh = [self.conf["AIRFLOW_WORKERS"][0]["host"], self.conf["AIRFLOW_WORKERS"][0]["port"],
               self.conf["AIRFLOW_WORKERS"][0]["user"], self.conf["AIRFLOW_WORKERS"][0]["password"]]
        pkg_dir = "/path/dummy"
        change_image_extension = ["png", "jpg"]
        with self.assertRaises(Exception) as err_obj:
            self.helpers_obj.change_asset_image_extension(ssh, pkg_dir, change_image_extension)
        err_msg = err_obj.exception
        mocked_get_directory_structure.assert_called_with(ssh, pkg_dir)
        self.assertEqual(str(err_msg), "error message")
        mocked_rename_file.assert_not_called()
        mocked_change_line_in_file.assert_not_called()

    @mock.patch.object(Tools, "run_ssh_cmd", return_value=("", ""))
    def test_change_line_in_file(self, mocked_run_ssh_cmd, *args):
        ssh = [self.conf["AIRFLOW_WORKERS"][0]["host"], self.conf["AIRFLOW_WORKERS"][0]["port"],
               self.conf["AIRFLOW_WORKERS"][0]["user"], self.conf["AIRFLOW_WORKERS"][0]["password"]]
        path_to_file = "/path/dummy"
        old_value = "old_dummy"
        new_value = "new_dummy"
        expected_command = "sed -i 's/%s/%s/' %s" % (old_value, new_value, path_to_file)
        self.helpers_obj.change_line_in_file(ssh, path_to_file, old_value, new_value)
        mocked_run_ssh_cmd.assert_called_with(*(ssh + [expected_command]))

    @mock.patch.object(Tools, "run_ssh_cmd", return_value=("", "error message"))
    def test_change_line_in_file_exception(self, mocked_run_ssh_cmd, *args):
        ssh = [self.conf["AIRFLOW_WORKERS"][0]["host"], self.conf["AIRFLOW_WORKERS"][0]["port"],
               self.conf["AIRFLOW_WORKERS"][0]["user"], self.conf["AIRFLOW_WORKERS"][0]["password"]]
        path_to_file = "/path/dummy"
        old_value = "old_dummy"
        new_value = "new_dummy"
        with self.assertRaises(Exception) as err_obj:
            self.helpers_obj.change_line_in_file(ssh, path_to_file, old_value, new_value)
        err_msg = err_obj.exception
        self.assertEqual(str(err_msg), "error message")

    @mock.patch.object(Tools, "run_ssh_cmd", return_value=("dummy_file.txt", ""))
    def test_get_directory_structure(self, mocked_run_ssh_cmd, *args):
        ssh = [self.conf["AIRFLOW_WORKERS"][0]["host"], self.conf["AIRFLOW_WORKERS"][0]["port"],
               self.conf["AIRFLOW_WORKERS"][0]["user"], self.conf["AIRFLOW_WORKERS"][0]["password"]]
        path_to_dir = "/path/dummy"
        expected_command = "ls %s" % path_to_dir
        stdout, stderr = self.helpers_obj.get_directory_structure(ssh, path_to_dir)
        mocked_run_ssh_cmd.assert_called_with(*(ssh + [expected_command]))
        self.assertFalse(stderr)
        self.assertEqual(stdout, "dummy_file.txt")

    @mock.patch.object(Tools, "run_ssh_cmd", return_value=(LONG_LISTING_FORMAT_OUTPUT, ""))
    def test_get_directory_structure_long_listing_format(self, mocked_run_ssh_cmd, *args):
        ssh = [self.conf["AIRFLOW_WORKERS"][0]["host"], self.conf["AIRFLOW_WORKERS"][0]["port"],
               self.conf["AIRFLOW_WORKERS"][0]["user"], self.conf["AIRFLOW_WORKERS"][0]["password"]]
        path_to_dir = "/path/dummy"
        expected_command = "ls -l %s" % path_to_dir
        stdout, stderr = self.helpers_obj.get_directory_structure(
            ssh, path_to_dir, long_listing_format=True)
        mocked_run_ssh_cmd.assert_called_with(*(ssh + [expected_command]))
        self.assertFalse(stderr)
        self.assertEqual(stdout, LONG_LISTING_FORMAT_OUTPUT)

    @mock.patch.object(Tools, "run_ssh_cmd", return_value=(LONG_LISTING_FORMAT_OUTPUT, ""))
    def test_get_directory_structure_long_listing_format_show_hidden(self, mocked_run_ssh_cmd, *args):
        ssh = [self.conf["AIRFLOW_WORKERS"][0]["host"], self.conf["AIRFLOW_WORKERS"][0]["port"],
               self.conf["AIRFLOW_WORKERS"][0]["user"], self.conf["AIRFLOW_WORKERS"][0]["password"]]
        path_to_dir = "/path/dummy"
        expected_command = "ls -la %s" % path_to_dir
        stdout, stderr = self.helpers_obj.get_directory_structure(
            ssh, path_to_dir, long_listing_format=True, show_hidden=True)
        mocked_run_ssh_cmd.assert_called_with(*(ssh + [expected_command]))
        self.assertFalse(stderr)
        self.assertEqual(stdout, LONG_LISTING_FORMAT_OUTPUT)

    @mock.patch.object(Tools, "run_ssh_cmd", return_value=(".dummy_fiden_file", ""))
    def test_get_directory_structure_show_hidden(self, mocked_run_ssh_cmd, *args):
        ssh = [self.conf["AIRFLOW_WORKERS"][0]["host"], self.conf["AIRFLOW_WORKERS"][0]["port"],
               self.conf["AIRFLOW_WORKERS"][0]["user"], self.conf["AIRFLOW_WORKERS"][0]["password"]]
        path_to_dir = "/path/dummy"
        expected_command = "ls -a %s" % path_to_dir
        stdout, stderr = self.helpers_obj.get_directory_structure(
            ssh, path_to_dir, show_hidden=True)
        mocked_run_ssh_cmd.assert_called_with(*(ssh + [expected_command]))
        self.assertFalse(stderr)
        self.assertEqual(stdout, ".dummy_fiden_file")

    @mock.patch.object(Tools, "run_ssh_cmd", return_value=("", ""))
    def test_rename_file(self, mocked_run_ssh_cmd, *args):
        """Unit test for 'rename_file' method"""
        ssh = [self.conf["AIRFLOW_WORKERS"][0]["host"], self.conf["AIRFLOW_WORKERS"][0]["port"],
               self.conf["AIRFLOW_WORKERS"][0]["user"], self.conf["AIRFLOW_WORKERS"][0]["password"]]
        path_to_file = "/some/path/dummy_old.txt"
        folder = "/".join(path_to_file.split("/")[:-1])
        new_name = "dummy_new.txt"
        new_path = "%s/%s" % (folder, new_name)
        expected_command = "mv %s %s" % (path_to_file, new_path)
        self.helpers_obj.rename_file(ssh, path_to_file, new_name)
        mocked_run_ssh_cmd.assert_called_with(*(ssh + [expected_command]))

    @mock.patch.object(Tools, "run_ssh_cmd", return_value=("", "some error"))
    def test_rename_file_stderr(self, *args):
        """Unit test for 'rename_file' method"""
        ssh = [self.conf["AIRFLOW_WORKERS"][0]["host"], self.conf["AIRFLOW_WORKERS"][0]["port"],
               self.conf["AIRFLOW_WORKERS"][0]["user"], self.conf["AIRFLOW_WORKERS"][0]["password"]]
        path_to_file = "/some/path/dummy_old.txt"
        folder = "/".join(path_to_file.split("/")[:-1])
        new_name = "dummy_new.txt"
        new_path = "%s/%s" % (folder, new_name)
        expected_command = "mv %s %s" % (path_to_file, new_path)
        with self.assertRaises(Exception) as err_obj:
            self.helpers_obj.rename_file(ssh, path_to_file, new_name)
        err_msg = err_obj.exception
        self.assertEqual(str(err_msg), "some error")

    @mock.patch.object(Tools, "run_ssh_cmd", return_value=("", ""))
    def test_rename_tva_file(self, mocked_run_ssh_cmd, *args):
        """Unit test for 'rename_tva_file' method"""
        ssh = [self.conf["AIRFLOW_WORKERS"][0]["host"], self.conf["AIRFLOW_WORKERS"][0]["port"],
               self.conf["AIRFLOW_WORKERS"][0]["user"], self.conf["AIRFLOW_WORKERS"][0]["password"]]
        pkg_dir = "/some/path/dummy"
        tva_fname = "TVA_000001_20170802081133.xml"
        self.helpers_obj.rename_tva_file(pkg_dir, ssh, tva_fname)
        mocked_run_ssh_cmd.assert_called()

    @mock.patch.object(Tools, "run_ssh_cmd", return_value=("", "some error"))
    def test_rename_tva_file_stderr(self, *args):
        """Unit test for 'rename_file' method"""
        ssh = [self.conf["AIRFLOW_WORKERS"][0]["host"], self.conf["AIRFLOW_WORKERS"][0]["port"],
               self.conf["AIRFLOW_WORKERS"][0]["user"], self.conf["AIRFLOW_WORKERS"][0]["password"]]
        pkg_dir = "/some/path/dummy"
        tva_fname = "TVA_000001_20170802081133.xml"
        with self.assertRaises(Exception) as err_obj:
            self.helpers_obj.rename_tva_file(pkg_dir, ssh, tva_fname)
        err_msg = err_obj.exception
        self.assertEqual(str(err_msg), "Failed to rename TVA file. Error: some error")

    @mock.patch.object(Tools, "run_ssh_cmd", return_value=("", "some error"))
    def test_rename_tva_file_unexpected_tva_file_name_format(self, *args):
        """Unit test for 'rename_file' method"""
        ssh = [self.conf["AIRFLOW_WORKERS"][0]["host"], self.conf["AIRFLOW_WORKERS"][0]["port"],
               self.conf["AIRFLOW_WORKERS"][0]["user"], self.conf["AIRFLOW_WORKERS"][0]["password"]]
        pkg_dir = "/some/path/dummy"
        tva_fname = "TVA_00000_20170802081133.xml"
        with self.assertRaises(Exception) as err_obj:
            self.helpers_obj.rename_tva_file(pkg_dir, ssh, tva_fname)
        err_msg = err_obj.exception
        self.assertEqual(str(err_msg), "Unexpected TVA file name format: %s. Expected format like "
                            "'TVA_000001_20170802081133.xml'")

    def test_new_attr_value(self, *args):
        """Unit test for '_new_attr_value' method"""
        old_val = "2020-02-16T00:00:00"
        item = {"attrs": {"days": 2}}
        attr = "days"
        new_val = self.helpers_obj._new_attr_value(old_val, item, attr)
        self.assertEqual(new_val, "2020-02-18T00:00:00")

    def test_new_attr_value_attr_not_str(self, *args):
        """Unit test for '_new_attr_value' method"""
        old_val = "old"
        item = {"attrs": {"days": 1}}
        attr = "days"
        new_val = self.helpers_obj._new_attr_value(old_val, item, attr)
        self.assertEqual(new_val, "1")

    @mock.patch.object(Tools, "run_ssh_cmd", return_value=("output", ""))
    def test_run_ssh_commands_for_no_og_ingestion(self, mocked_run_ssh_cmd, *args):
        out = self.helpers_obj.run_ssh_commands_for_no_og_ingestion(self.ssh, self.pkg_dir, self.path)
        expected_command = "mkdir dir && touch dir/lock.tmp && (cp /dummy/path/* dir/ || echo 1) && ls -ltr dir/TVA_*.xml | awk '{if(NR>1)print}' | awk '{print $NF}' | xargs rm -f"
        mocked_run_ssh_cmd.assert_called_with(*(self.ssh + [expected_command]))

    @mock.patch.object(Tools, "run_ssh_cmd", return_value=("output", ""))
    def test_run_ssh_commands_for_no_og_ingestion_tva_name(self, mocked_run_ssh_cmd, *args):
        out = self.helpers_obj.run_ssh_commands_for_no_og_ingestion(
            self.ssh, self.pkg_dir, self.path, tva_name="TVA_dummy.xml")
        expected_command = "mkdir dir && touch dir/lock.tmp && (cp /dummy/path/* dir/ || echo 1) && mv dir/TVA_*.xml dir/TVA_dummy.xml && sed -i 's/path/dir/' dir/TVA_dummy.xml && rename path dir dir/* && ls -ltr dir/TVA_*.xml | awk '{if(NR>1)print}' | awk '{print $NF}' | xargs rm -f"
        mocked_run_ssh_cmd.assert_called_with(*(self.ssh + [expected_command]))

    @mock.patch.object(Tools, "run_ssh_cmd", return_value=("", "Dummy error"))
    def test_run_ssh_commands_for_no_og_ingestion_stderr(self, *args):
        with self.assertRaises(Exception) as err_obj:
            self.helpers_obj.run_ssh_commands_for_no_og_ingestion(self.ssh, self.pkg_dir, self.path)
        err_msg = err_obj.exception
        self.assertEqual(str(err_msg), "Could not prepare a package folder inside the watch folder. Error: Dummy error")

    @mock.patch.object(Tools, "run_ssh_cmd", return_value=("output", "bla bla bla omitting directory bla bla bla"))
    def test_run_ssh_commands_for_no_og_ingestion_stderr_omitting_directory(self, *args):
        out = self.helpers_obj.run_ssh_commands_for_no_og_ingestion(self.ssh, self.pkg_dir, self.path)
        self.assertEqual(out, "output")

    @mock.patch.object(helpers, "define_package_name_and_structure", return_value="ts0000_20200218_073107pt")
    @mock.patch.object(helpers, "get_path_to_adi_file", return_value=["/some/dummy/path"])
    @mock.patch.object(helpers, "run_command_to_generate_offer", return_value=GEN_SCRIPT_SINGLE)
    @mock.patch.object(helpers, "generate_offer_id_based_on_time_stamp", return_value="1582127084.75")
    def test_generate_offer(
            self,
            mocked_generate_offer_id_based_on_time_stamp,
            mocked_run_command_to_generate_offer,
            mocked_get_path_to_adi_file,
            mocked_define_package_name_and_structure,
            *args):
        self.helpers_obj.generate_offer()
        mocked_generate_offer_id_based_on_time_stamp.assert_called()
        mocked_run_command_to_generate_offer.assert_called()
        mocked_get_path_to_adi_file.assert_called_with('Package/ADI.XML', 'ts0000', GEN_SCRIPT_SINGLE)
        mocked_define_package_name_and_structure.assert_called_with(None, '/some/dummy/path', 'ts[0-9]{4}_[0-9]{8}_[0-9]{6}[0-9\\-]{0,3}pt[0-9]{0,2}', 'ts0000')

    @mock.patch.object(helpers, "unhold_package_and_offer")
    @mock.patch.object(helpers, "define_package_name_and_structure", return_value="ts0000_20200218_073107pt")
    @mock.patch.object(helpers, "_spoil_adi")
    @mock.patch.object(helpers, "get_path_to_adi_file", return_value=["/some/dummy/path"])
    @mock.patch.object(helpers, "run_command_to_generate_offer", return_value=mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["run_command_to_generate_offer"]["stderr_to_log"]["ts0000 HOLD"])
    @mock.patch.object(helpers, "generate_offer_id_based_on_time_stamp", return_value="1582127084.75")
    def test_generate_offer_bad_metadata(
            self,
            mocked_generate_offer_id_based_on_time_stamp,
            mocked_run_command_to_generate_offer,
            mocked_get_path_to_adi_file,
            mocked_spoil_adi,
            mocked_define_package_name_and_structure,
            mocked_unhold_package_and_offer,
            *args):
        self.helpers_obj.generate_offer(bad_metadata={"dummy":{}})
        mocked_generate_offer_id_based_on_time_stamp.assert_called()
        mocked_run_command_to_generate_offer.assert_called()
        mocked_get_path_to_adi_file.assert_called()
        mocked_spoil_adi.assert_called()
        mocked_define_package_name_and_structure.assert_called_with(None, '/some/dummy/path', 'ts[0-9]{4}_[0-9]{8}_[0-9]{6}[0-9\\-]{0,3}pt[0-9]{0,2}', 'ts0000')
        mocked_unhold_package_and_offer.assert_called_with('ts0000_20200218_073107pt')



    @mock.patch.object(helpers, "unhold_package_and_offer")
    @mock.patch.object(helpers, "block_movie_type_ingestion_in_adi_file")
    @mock.patch.object(helpers, "define_package_name_and_structure", return_value="ts0000_20200218_073107pt")
    @mock.patch.object(helpers, "get_path_to_adi_file", return_value=["/some/dummy/path"])
    @mock.patch.object(helpers, "run_command_to_generate_offer", return_value=mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["run_command_to_generate_offer"]["stderr_to_log"]["ts0000 HOLD"])
    @mock.patch.object(helpers, "generate_offer_id_based_on_time_stamp", return_value="1582127084.75")
    def test_generate_offer_movie_type(
            self,
            mocked_generate_offer_id_based_on_time_stamp,
            mocked_run_command_to_generate_offer,
            mocked_get_path_to_adi_file,
            mocked_define_package_name_and_structure,
            mocked_block_movie_type_ingestion_in_adi_file,
            mocked_unhold_package_and_offer,
            *args):
        for m_type in ["ott", "stb", "4k_stb", "4K_STB", "4k_ott", "4K_OTT"]:
            self.helpers_obj.generate_offer(movie_type=m_type)
            mocked_generate_offer_id_based_on_time_stamp.assert_called()
            mocked_run_command_to_generate_offer.assert_called()
            mocked_get_path_to_adi_file.assert_called()
            mocked_block_movie_type_ingestion_in_adi_file.assert_called()
            mocked_define_package_name_and_structure.assert_called_with(m_type, '/some/dummy/path', 'ts[0-9]{4}_[0-9]{8}_[0-9]{6}[0-9\\-]{0,3}pt[0-9]{0,2}', 'ts0000')
            mocked_unhold_package_and_offer.assert_called_with('ts0000_20200218_073107pt')

    @mock.patch.object(helpers, "unhold_package_and_offer")
    @mock.patch.object(helpers, "set_title_value_in_package_adi")
    @mock.patch.object(helpers, "set_unique_title_id_in_package_adi")
    @mock.patch.object(helpers, "define_package_name_and_structure", return_value="ts0000_20200218_073107pt")
    @mock.patch.object(helpers, "get_path_to_adi_file", return_value=["/some/dummy/path"])
    @mock.patch.object(helpers, "run_command_to_generate_offer", return_value=mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["run_command_to_generate_offer"]["stderr_to_log"]["ts0000 HOLD"])
    @mock.patch.object(helpers, "generate_offer_id_based_on_time_stamp", return_value="1582127084.75")
    def test_generate_offer_unique_title_id(
            self,
            mocked_generate_offer_id_based_on_time_stamp,
            mocked_run_command_to_generate_offer,
            mocked_get_path_to_adi_file,
            mocked_define_package_name_and_structure,
            mocked_set_unique_title_id_in_package_adi,
            mocked_set_title_value_in_package_adi,
            mocked_unhold_package_and_offer,
            *args):
        self.helpers_obj.generate_offer(unique_title_id="unique")
        mocked_generate_offer_id_based_on_time_stamp.assert_called()
        mocked_run_command_to_generate_offer.assert_called()
        mocked_get_path_to_adi_file.assert_called()
        mocked_define_package_name_and_structure.assert_called_with(None, '/some/dummy/path', 'ts[0-9]{4}_[0-9]{8}_[0-9]{6}[0-9\\-]{0,3}pt[0-9]{0,2}', 'ts0000')
        mocked_set_unique_title_id_in_package_adi.assert_called_with('/some/dummy/path', 'unique')
        mocked_set_title_value_in_package_adi.assert_called_with('/some/dummy/path', 'unique')
        mocked_unhold_package_and_offer.assert_called_with('ts0000_20200218_073107pt')


class Test_tools(TestCaseNameAsDescription):
    """Class contains unit tests for Tools class."""

    @classmethod
    def setUpClass(cls):
        cls.lab_name = "mock"
        cls.conf = E2E_CONF[cls.lab_name]
        cls.tools = Tools(cls.conf)
        cls.airflow_worker_host = cls.conf["AIRFLOW_WORKERS"][0]["host"]
        cls.port = cls.conf["AIRFLOW_WORKERS"][0]["port"]
        cls.username = cls.conf["AIRFLOW_WORKERS"][0]["user"]
        cls.password = cls.conf["AIRFLOW_WORKERS"][0]["password"]
        cls.command = "dummy command"
        cls.af_worers_jump_server = cls.conf["AIRFLOW_WORKERS_JUMP_SERVER"]["host"]
        cls.transcoders_worers_jump_server = cls.conf["TRANSCODER_WORKERS_JUMP_SERVER"]["host"]
        cls.file_name = "dummy.json"
        cls.content = "Dummy content"
        cls.path = "/dummy/path"
        cls.entry = "dummy_entry"
        # Uncomment below for debug purpose if needed
        # cls.maxDiff = None

    @classmethod
    def tearDownClass(cls):
        pass

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=("", "correct stdout"))
    @mock.patch.object(Tools, "run_ssh_command_through_jump_server", return_value=("", "wrong stdout"))
    def test_run_ssh_cmd_positive_itself_not_use_jump_server(self, *args):
        """Check of run_ssh_cmd method, positive."""
        # Unset USE_JUMP_SERVER environment variable
        os.environ.pop("USE_JUMP_SERVER", None)
        result = self.tools.run_ssh_cmd(
            self.airflow_worker_host, self.port, self.username, self.password, self.command)
        self.assertTrue(isinstance(result, tuple))
        self.assertEqual(result[0], "")
        self.assertEqual(result[1], "correct stdout")

    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=("", "correct stdout"))
    @mock.patch.object(Tools, "run_ssh_command_through_jump_server", return_value=("", "wrong stdout"))
    def test_run_ssh_cmd_positive_itself_use_jump_server_not_af_worker_host(self, *args):
        """Check of run_ssh_cmd method, positive."""
        host = "12.13.14.15"
        # Set USE_JUMP_SERVER environment variable
        os.environ["USE_JUMP_SERVER"] = "True"
        result = self.tools.run_ssh_cmd(host, self.port, self.username, self.password, self.command)
        self.assertTrue(isinstance(result, tuple))
        self.assertEqual(result[0], "")
        self.assertEqual(result[1], "correct stdout")

    @mock.patch.object(Tools, "run_ssh_command_through_jump_server", return_value=("", "correct stdout"))
    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=("", "wrong stdout"))
    def test_run_ssh_cmd_positive_through_jump_server_af_worker(self, *args):
        """Check of run_ssh_cmd method, positive."""
        # Set USE_JUMP_SERVER environment variable
        os.environ["USE_JUMP_SERVER"] = "True"
        result = self.tools.run_ssh_cmd(
            self.airflow_worker_host, self.port, self.username, self.password, self.command)
        self.assertTrue(isinstance(result, tuple))
        self.assertEqual(result[0], "")
        self.assertEqual(result[1], "correct stdout")

    @mock.patch.object(Tools, "run_ssh_command_through_jump_server", return_value=("", "correct stdout"))
    @mock.patch.object(Tools, "run_ssh_command_itself", return_value=("", "wrong stdout"))
    def test_run_ssh_cmd_positive_through_jump_server_transcoder_worker(self, *args):
        """Check of run_ssh_cmd method, positive."""
        host = self.conf["TRANSCODER_WORKERS"][0]["host"]
        port = self.conf["TRANSCODER_WORKERS"][0]["port"]
        username = self.conf["TRANSCODER_WORKERS"][0]["user"]
        password = self.conf["TRANSCODER_WORKERS"][0]["password"]
        # Set USE_JUMP_SERVER environment variable
        os.environ["USE_JUMP_SERVER"] = "True"
        result = self.tools.run_ssh_cmd(host, port, username, password, self.command)
        self.assertTrue(isinstance(result, tuple))
        self.assertEqual(result[0], "")
        self.assertEqual(result[1], "correct stdout")

    @mock.patch.object(Tools, "run_ssh_command_through_jump_server", side_effect=return_run_ssh_cmd_method_arguments)
    def test_run_ssh_cmd_timeout_not_int(self, *args):
        """Check of run_ssh_cmd method, positive."""
        timeout = "20"
        # Set USE_JUMP_SERVER environment variable
        os.environ["USE_JUMP_SERVER"] = "True"
        result = self.tools.run_ssh_cmd(
            self.airflow_worker_host, self.port, self.username, self.password, self.command, timeout=timeout)
        timeout = result[1][1]["timeout"]
        self.assertTrue(isinstance(timeout, int))

    @mock.patch.object(Tools, "run_ssh_command_through_jump_server", side_effect=return_run_ssh_cmd_method_arguments)
    def test_run_ssh_cmd_port_not_int(self, *args):
        """Check of run_ssh_cmd method, positive."""
        port = "22"
        # Set USE_JUMP_SERVER environment variable
        os.environ["USE_JUMP_SERVER"] = "True"
        result = self.tools.run_ssh_cmd(
            self.airflow_worker_host, port, self.username, self.password, self.command)
        port = result[1][0][1]
        self.assertTrue(isinstance(port, int))

    @mock.patch.object(Tools, "run_ssh_command_through_jump_server", side_effect=return_run_ssh_cmd_method_arguments)
    def test_run_ssh_cmd_unexpected_port(self, *args):
        """Check of run_ssh_cmd method, negative."""
        port = "not a digit"
        # Set USE_JUMP_SERVER environment variable
        os.environ["USE_JUMP_SERVER"] = "True"
        with self.assertRaises(Exception) as err_obj:
            self.tools.run_ssh_cmd(
            self.airflow_worker_host, port, self.username, self.password, self.command)
        err_msg = err_obj.exception
        self.assertEqual(
            str(err_msg), "Unexpected type for 'port' variable: <class 'str'>")

    @mock.patch.object(paramiko.SSHClient, "set_missing_host_key_policy", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "connect", return_value=None)
    def test_run_ssh_command_itself_return_connect_only(self, *args):
        """Check of run_ssh_cmd method, negative."""
        result = self.tools.run_ssh_command_itself(
            self.airflow_worker_host, self.port, self.username, self.password, self.command,
            return_connect_only=True, timeout=1, attempts=9)
        ssh_object = result[0]
        self.assertTrue(isinstance(ssh_object, paramiko.SSHClient))

    @mock.patch.object(paramiko.SSHClient, "set_missing_host_key_policy", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "connect", side_effect=paramiko.SSHException("SSH-ERR"))
    def test_run_ssh_command_itself_return_connect_exception(self, *args):
        """Check of run_ssh_cmd method, negative."""
        result = self.tools.run_ssh_command_itself(
            self.airflow_worker_host, self.port, self.username, self.password, self.command, timeout=1, attempts=9)
        exceptin_message = result[1]
        self.assertTrue("SSH Connection from" in exceptin_message)
        self.assertTrue(" to %s host failed: SSH-ERR" % self.airflow_worker_host in exceptin_message)

    @mock.patch.object(paramiko.SSHClient, "set_missing_host_key_policy", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "connect", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "exec_command", return_value=("", mock.MagicMock(), mock.MagicMock()))
    def test_run_ssh_command_itself_exec_command(self, *args):
        """Check of run_ssh_cmd method, negative."""
        stdout, stderr = self.tools.run_ssh_command_itself(
            self.airflow_worker_host, self.port, self.username, self.password, self.command, timeout=1, attempts=9)
        expected = "<MagicMock name='mock.read().decode().strip()"
        self.assertIn(expected, str(stdout))
        self.assertIn(expected, str(stderr))

    @mock.patch.object(paramiko.SSHClient, "set_missing_host_key_policy", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "connect", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "exec_command", side_effect=paramiko.SSHException("SSH-ERR"))
    def test_run_ssh_command_itself_exec_command_exception(self, *args):
        """Check of run_ssh_cmd method, negative."""
        stdout, stderr = self.tools.run_ssh_command_itself(
            self.airflow_worker_host, self.port, self.username, self.password, self.command, timeout=1, attempts=9)
        expected_message = " SSH command %s on %s failed: SSH-ERR" % (self.command, self.airflow_worker_host)
        self.assertFalse(stdout)
        self.assertIn(expected_message, stderr)

    @mock.patch.object(paramiko.SSHClient, "set_missing_host_key_policy", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "connect", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "get_transport", return_value=mock.MagicMock())
    def test_run_ssh_command_through_jump_server_return_connect_only(self, *args):
        """Check of run_ssh_cmd method, negative."""
        result = self.tools.run_ssh_command_through_jump_server(
            self.airflow_worker_host, self.port, self.username, self.password, self.command,
            return_connect_only=True, timeout=1, attempts=9)
        ssh_object = result[0]
        self.assertTrue(isinstance(ssh_object, paramiko.SSHClient))

    @mock.patch.object(paramiko.SSHClient, "set_missing_host_key_policy", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "connect", side_effect=paramiko.SSHException("SSH-ERR"))
    def test_run_ssh_command_through_jump_server_exception_when_connect_to_jump_server(self, *args):
        """Check of run_ssh_cmd method, negative."""
        host = self.conf["TRANSCODER_WORKERS"][0]["host"]
        port = self.conf["TRANSCODER_WORKERS"][0]["port"]
        username = self.conf["TRANSCODER_WORKERS"][0]["user"]
        password = self.conf["TRANSCODER_WORKERS"][0]["password"]
        stdout, stderr = self.tools.run_ssh_command_through_jump_server(
            host, port, username, password, self.command,
            timeout=1, attempts=9)
        local_hostname = socket.gethostname()
        local_fqdn = socket.gethostbyname(socket.getfqdn())

        expected_message = " SSH Connection from %s (%s) to %s host failed: SSH-ERR" % (
            local_hostname, local_fqdn, self.transcoders_worers_jump_server
        )
        self.assertFalse(stdout)
        self.assertIn(expected_message, stderr)

    @mock.patch.object(paramiko.SSHClient, "set_missing_host_key_policy", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "connect", return_value=None)
    def test_run_ssh_command_through_jump_server_unexpected_jump_server(self, *args):
        """Check of run_ssh_cmd method, negative."""
        host = self.conf["ASSET_GENERATOR"]["host"]
        expected_message = "Unexpected host (%s) for using as a jump server" % host
        with self.assertRaises(Exception) as err_obj:
            self.tools.run_ssh_command_through_jump_server(
                host, self.port, self.username, self.password, self.command, timeout=1, attempts=9)
        err_msg = err_obj.exception
        self.assertEqual(str(err_msg), expected_message)

    @mock.patch.object(paramiko.SSHClient, "set_missing_host_key_policy", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "connect", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "get_transport", side_effect=paramiko.SSHException("SSH-ERR"))
    def test_run_ssh_command_through_jump_server_exception_when_connect_to_destination_server(self, *args):
        """Check of run_ssh_cmd method, negative."""
        stdout, stderr = self.tools.run_ssh_command_through_jump_server(
            self.airflow_worker_host, self.port, self.username, self.password, self.command,
            timeout=1, attempts=9)

        local_hostname = socket.gethostname()
        local_fqdn = socket.gethostbyname(socket.getfqdn())

        expected_message = " SSH Connection from %s (%s) to %s host failed: SSH-ERR" % (
            local_hostname, local_fqdn, self.airflow_worker_host
        )
        self.assertFalse(stdout)
        self.assertIn(expected_message, stderr)

    @mock.patch.object(paramiko.SSHClient, "set_missing_host_key_policy", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "connect", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "get_transport", return_value=mock.MagicMock())
    @mock.patch.object(paramiko.SSHClient, "exec_command", return_value=("", mock.MagicMock(), mock.MagicMock()))
    def test_run_ssh_command_through_jump_server_positive(self, *args):
        """Check of run_ssh_cmd method, negative."""
        stdout, stderr = self.tools.run_ssh_command_through_jump_server(
            self.airflow_worker_host, self.port, self.username, self.password, self.command,
            timeout=1, attempts=9)
        expected = "<MagicMock name='mock.read().decode().strip()"
        self.assertIn(expected, str(stdout))
        self.assertIn(expected, str(stderr))

    @mock.patch.object(paramiko.SSHClient, "set_missing_host_key_policy", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "connect", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "get_transport", return_value=mock.MagicMock())
    @mock.patch.object(paramiko.SSHClient, "exec_command", side_effect=paramiko.SSHException("SSH-ERR"))
    def test_run_ssh_command_through_jump_server_exception_when_exec_command(self, *args):
        """Check of run_ssh_cmd method, negative."""
        stdout, stderr = self.tools.run_ssh_command_through_jump_server(
            self.airflow_worker_host, self.port, self.username, self.password, self.command,
            timeout=1, attempts=9)

        expected_message = " SSH command %s on %s failed: SSH-ERR" % (
            self.command, self.airflow_worker_host
        )
        self.assertFalse(stdout)
        self.assertIn(expected_message, stderr)

    @mock.patch.object(paramiko.SSHClient, "set_missing_host_key_policy", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "connect", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "open_sftp", return_value=mock.MagicMock())
    @mock.patch.object(general, "insure_text", return_value="Correct")
    def test_ssh_read_file_positive(self, *args):
        """Check of ssh_read_file method"""
        content = self.tools.ssh_read_file(
            self.airflow_worker_host, self.port, self.username, self.password, self.file_name,
            timeout=1)
        self.assertEqual(content, "Correct")

    @mock.patch.object(paramiko.SSHClient, "set_missing_host_key_policy", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "connect", side_effect=paramiko.SSHException("SSH-ERR"))
    @mock.patch.object(BuiltIn, "log_to_console", side_effect=print)
    def test_ssh_read_file_exception_wen_ssh_connect(self, mock_print, *args):
        """Check of ssh_read_file method"""
        content = self.tools.ssh_read_file(
            self.airflow_worker_host, self.port, self.username, self.password, self.file_name,
            timeout=1)
        local_hostname = socket.gethostname()
        local_fqdn = socket.gethostbyname(socket.getfqdn())
        expected_print_message = "SSH Connection from %s (%s) to %s host failed: SSH-ERR" % (
            local_hostname, local_fqdn, self.airflow_worker_host
        )
        mock_print.assert_called_with(expected_print_message)
        self.assertEqual(content, None)

    @mock.patch.object(paramiko.SSHClient, "set_missing_host_key_policy", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "connect", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "open_sftp", return_value=mock.MagicMock())
    @mock.patch.object(general, "insure_text", side_effect=IOError)
    @mock.patch.object(BuiltIn, "log_to_console", side_effect=print)
    def test_ssh_read_file_exception_wen_reading_under_sftp(self, mock_print, *args):
        """Check of ssh_read_file method"""
        content = self.tools.ssh_read_file(
            self.airflow_worker_host, self.port, self.username, self.password, self.file_name,
            timeout=1)
        expected_print_message = "Error reading file %s on host %s via SSH: " % (
            self.file_name, self.airflow_worker_host
        )
        mock_print.assert_called_with(expected_print_message)
        self.assertEqual(content, None)

    @mock.patch.object(paramiko.SSHClient, "set_missing_host_key_policy", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "connect", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "open_sftp", return_value=mock.MagicMock())
    @mock.patch.object(general, "insure_text", return_value="Dummy content")
    def test_ssh_write_file_positive(self, *args):
        """Check of ssh_write_file method"""
        result = self.tools.ssh_write_file(
            self.airflow_worker_host, self.port, self.username, self.password, self.file_name,
            self.content, timeout=1)
        self.assertTrue(result)

    @mock.patch.object(paramiko.SSHClient, "set_missing_host_key_policy", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "connect", side_effect=paramiko.SSHException("SSH-ERR"))
    @mock.patch.object(BuiltIn, "log_to_console", side_effect=print)
    def test_ssh_write_file_exception_wen_ssh_connect(self, mock_print, *args):
        """Check of ssh_write_file method"""
        result = self.tools.ssh_write_file(
            self.airflow_worker_host, self.port, self.username, self.password, self.file_name,
            self.content, timeout=1)
        local_hostname = socket.gethostname()
        local_fqdn = socket.gethostbyname(socket.getfqdn())
        expected_print_message = "SSH Connection from %s (%s) to %s host failed: SSH-ERR" % (
            local_hostname, local_fqdn, self.airflow_worker_host
        )
        mock_print.assert_called_with(expected_print_message)
        self.assertFalse(result)

    @mock.patch.object(paramiko.SSHClient, "set_missing_host_key_policy", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "connect", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "open_sftp", return_value=mock.MagicMock())
    @mock.patch.object(general, "insure_text", side_effect=IOError)
    @mock.patch.object(BuiltIn, "log_to_console", side_effect=print)
    def test_ssh_write_file_exception_wen_writing_under_sftp(self, mock_print, *args):
        """Check of ssh_write_file method"""
        result = self.tools.ssh_write_file(
            self.airflow_worker_host, self.port, self.username, self.password, self.file_name,
            self.content, timeout=1)
        expected_print_message = "Error accessing file %s on host %s via SSH: " % (
            self.file_name, self.airflow_worker_host
        )
        mock_print.assert_called_with(expected_print_message)
        self.assertFalse(result)

    @mock.patch.object(Tools, "run_ssh_cmd", return_value=("", ""))
    def test_ssh_move_file_positive(self, *args):
        """Unit test to check ssh_move_file method"""
        result = self.tools.ssh_move_file(
            self.airflow_worker_host, self.port, self.username, self.password, self.file_name,
            self.path
        )
        self.assertTrue(result)

    @mock.patch.object(Tools, "run_ssh_cmd", return_value=("", "some error"))
    def test_ssh_move_file_negative_stderr(self, *args):
        """Unit test to check ssh_move_file method"""
        result = self.tools.ssh_move_file(
            self.airflow_worker_host, self.port, self.username, self.password, self.file_name,
            self.path
        )
        self.assertFalse(result)

    @mock.patch.object(Tools, "run_ssh_cmd", return_value=("some output", ""))
    def test_ssh_move_file_negative_stdout(self, *args):
        """Unit test to check ssh_move_file method"""
        result = self.tools.ssh_move_file(
            self.airflow_worker_host, self.port, self.username, self.password, self.file_name,
            self.path
        )
        self.assertFalse(result)

    @mock.patch.object(pysftp, "Connection", return_value=mock.MagicMock())
    @mock.patch.object(BuiltIn, "log_to_console", side_effect=print)
    def test_sftp_put_file_positive(self, mock_print, *args):
        """Unit test to check sftp_put_file method"""
        result = self.tools.sftp_put_file(
            self.airflow_worker_host, self.port, self.username, self.password, self.file_name,
            self.path
        )
        self.assertTrue(result)
        mock_print.assert_called()

    @mock.patch.object(pysftp, "Connection", side_effect=CredentialException("Invalid username or password"))
    @mock.patch.object(BuiltIn, "log_to_console", side_effect=print)
    def test_sftp_put_file_connection_exception(self, mock_print, *args):
        """Unit test to check sftp_put_file method"""
        with self.assertRaises(Exception) as err_obj:
            self.tools.sftp_put_file(
                self.airflow_worker_host, self.port, self.username, self.password, self.file_name,
                self.path
            )
        err_msg = err_obj.exception
        self.assertEqual(str(err_msg), "Invalid username or password")
        mock_print.assert_called()

    @mock.patch("pysftp.Connection")
    def test_sftp_put_file_put_exception(self, mock_connection, *args):
        """Unit test to check sftp_put_file method"""
        exception_message = "Path %s doesn't exist" % self.path
        mock_connection.return_value.__enter__.return_value.listdir.side_effect = IOError(exception_message)
        with self.assertRaises(Exception) as err_obj:
            self.tools.sftp_put_file(
                self.airflow_worker_host, self.port, self.username, self.password, self.file_name,
                self.path
            )
        err_msg = err_obj.exception
        self.assertEqual(str(err_msg), exception_message)

    @mock.patch.object(Tools, "run_ssh_cmd", return_value=("correct stdout", ""))
    def test_grep_logs_positive(self, *args):
        """Unit test to check grep_logs method"""
        stdout = self.tools.grep_logs(
            self.airflow_worker_host, self.port, self.username, self.password, self.path,
            self.entry
        )
        self.assertEqual(stdout, ["correct stdout"])

    def test_grep_logs_check_command(self, *args):
        """Unit test to check grep_logs method"""
        tools_obj = Tools(E2E_CONF["mock"])
        tools_obj.run_ssh_cmd = mock.MagicMock(return_value=("correct stdout", ""))
        stdout = tools_obj.grep_logs(
            self.airflow_worker_host, self.port, self.username, self.password, self.path,
            self.entry
        )
        expected_command = "grep -r '%s' %s " % (self.entry, self.path)
        tools_obj.run_ssh_cmd.assert_called_with(
            self.airflow_worker_host, self.port, self.username, self.password, expected_command
        )
        self.assertEqual(stdout, ["correct stdout"])

    def test_grep_logs_check_command_with_grep_ignore_pattern(self, *args):
        """Unit test to check grep_logs method"""
        tools_obj = Tools(E2E_CONF["mock"])
        tools_obj.run_ssh_cmd = mock.MagicMock(return_value=("correct stdout", ""))
        grep_ignore_pattern = "ignore_me"
        tools_obj.grep_logs(
            self.airflow_worker_host, self.port, self.username, self.password, self.path,
            self.entry, grep_ignore_pattern=grep_ignore_pattern
        )
        expected_command = "grep -r '%s' %s  | grep -vP %s" % (
            self.entry, self.path, grep_ignore_pattern
        )
        tools_obj.run_ssh_cmd.assert_called_with(
            self.airflow_worker_host, self.port, self.username, self.password, expected_command
        )

    @mock.patch.object(Tools, "run_ssh_cmd", return_value=("", "some error"))
    @mock.patch.object(BuiltIn, "log_to_console", side_effect=print)
    def test_grep_logs_stderr(self, mock_print, *args):
        """Unit test to check grep_logs method"""
        stdout = self.tools.grep_logs(
            self.airflow_worker_host, self.port, self.username, self.password, self.path,
            self.entry
        )
        expected_print_message = "Reading logs via SSH failed on %s: %s =(" % (
            self.airflow_worker_host, "some error")
        self.assertEqual(stdout, [""])
        mock_print.assert_called_with(expected_print_message)

    @mock.patch.object(Tools, "run_ssh_cmd", return_value=("", "some error"))
    @mock.patch.object(BuiltIn, "log_to_console", side_effect=print)
    def test_filter_list(self, mock_print, *args):
        """Unit test to check grep_logs method"""
        errors = [
            "", "Error 1", "", "Err 2", "Error 1"
            "Could not chdir to home directory /home/airflow ..."]
        result = self.tools.filter_list(errors, skip=["Could not chdir to home directory"])
        self.assertEqual(sorted(result), ['Err 2', 'Error 1'])

    def test_dict_walk(self, *args):
        """Unit test to check grep_logs method"""
        tva = mock_read_tva("samples", "TVA_ts1111_original.txt")
        result = self.tools.dict_walk(tva)
        self.assertTrue(isinstance(result, types.GeneratorType))
        result_list = list(result)
        for item in result_list:
            self.assertTrue(isinstance(item, tuple))
        for path, value in result:
            for expected in ["obj", "[", "]"]:
                self.assertIn(expected, path)
            self.assertIn(value, tva)

    @mock.patch.object(general, "insure_text", return_value="dummy command 2")
    @mock.patch.object(os, "system", return_value=0)
    def test_run_local_command(self, mocked_os_system, mocked_insure_text, *args):
        """Unit test to check grep_logs method"""
        self.tools.run_local_command("dummy command 1")
        mocked_insure_text.assert_called_with("dummy command 1")
        mocked_os_system.assert_called_with("dummy command 2")


class Test_healthchecks(TestCaseNameAsDescription):
    """Class contains unit tests for keywords which use HealthChecks() class."""

    @classmethod
    def setUpClass(cls):
        cls.lab_name = "mock"
        cls.conf = E2E_CONF
        cls.kwd = Keywords()
        # Uncomment below for debug purpose if needed
        # cls.maxDiff = None

    @classmethod
    def tearDownClass(cls):
        pass

    @mock.patch.object(HealthChecks, "check_airflow_worker_revisions", return_value=[])
    def test_positive_worker_revisions(self, *args):
        """Check an empty list of errors is returned if a dictionary with valid data is provided."""
        errors = self.kwd.check_airflow_workers_revisions(self.lab_name, self.conf, VALUES_OK)
        self.assertEqual(errors, [])

    @mock.patch.object(HealthChecks, "check_airflow_worker_revisions", return_value=REVISION_ERRORS)
    def test_negative_worker_revisions(self, *args):
        """Check a list of errors is returned if a dictionary with unexpected values is provided."""
        errors = self.kwd.check_airflow_workers_revisions(self.lab_name, self.conf, VALUES_NOK)
        self.assertEqual(sorted(errors), sorted(REVISION_ERRORS))

    @mock.patch.object(HealthChecks, "check_airflow_manager_version", return_value=[])
    def test_positive_manager_version(self, *args):
        """Check an empty list of errors is returned if the version taken from git repository
        is the same as the version on the Airflow web server: code version == deployed version."""
        errors = self.kwd.check_airflow_manager_version(self.lab_name, self.conf, "")
        self.assertEqual(errors, [])

    @mock.patch.object(HealthChecks, "check_airflow_manager_version", return_value=[VERSION_ERROR])
    def test_negative_manager_version(self, *args):
        """Check a returned list of errors contains a message about version mismatch, if the version
        taken from git repository is different from the version on the Airflow web server:
        code version != deployed version."""
        errors = self.kwd.check_airflow_manager_version(self.lab_name, self.conf, "")
        self.assertEqual(errors, [VERSION_ERROR])

    @mock.patch.object(paramiko.SSHClient, "connect", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "exec_command",
                       side_effect=lambda *args: (0, StringIO("abc"), StringIO("")))
    @mock.patch.object(paramiko.RSAKey, "from_private_key_file", return_value=None)
    def test_positive_data_from_aws(self, *args):
        """Check the structure of returned result if all the data are successfully got from
        Airflow web server deployed in AWS; verify also that no errors are returned in this case."""
        result = self.kwd.get_data_from_airflow_aws(self.lab_name, self.conf, "")
        for key in VALUES_OK:
            self.assertTrue(key in result)
            self.assertEqual(result[key], [] if key == "errors" else "abc")

    @mock.patch.object(paramiko.SSHClient, "connect", return_value=None)
    @mock.patch.object(paramiko.SSHClient, "exec_command",
                       side_effect=lambda *args: (0, StringIO(""), StringIO("err")))
    @mock.patch.object(paramiko.RSAKey, "from_private_key_file", return_value=None)
    def test_negative_data_from_aws(self, *args):
        """Check the structure of returned result if it was possible to connect to
        Airflow web server deployed in AWS but could not get data from version and revision files;
        verify also that a non-empty errors list is returned in this case."""
        result = self.kwd.get_data_from_airflow_aws(self.lab_name, self.conf, "")
        for key in VALUES_OK:
            self.assertTrue(key in result)
            self.assertEqual(result[key], ["err", "err", "err"] if key == "errors" else "")

    @mock.patch.object(paramiko.SSHClient, "connect", side_effect=paramiko.SSHException("SSH-ERR"))
    @mock.patch.object(paramiko.RSAKey, "from_private_key_file", return_value=None)
    def test_connect_aws_ssh_exception(self, *args):
        """Check the structure of the returned result if it was not possible to connect to
        Airflow web server deployed in AWS due to SSH exception."""
        result = self.kwd.get_data_from_airflow_aws(self.lab_name, self.conf, "")
        for key in VALUES_OK:
            self.assertTrue(key in result)
            if key != "errors":
                self.assertEqual(result[key], None)
        for err in result["errors"]:
            self.assertTrue(err.startswith("SSH Connection from %s" %
                                           self.conf[self.lab_name]["AIRFLOW_WEB"]["host"]))
            self.assertTrue(err.endswith("failed: SSH-ERR"))

    @mock.patch.object(paramiko.SSHClient, "connect", side_effect=socket.gaierror("SOCKET-GAI-ERR"))
    @mock.patch.object(paramiko.RSAKey, "from_private_key_file", return_value=None)
    def test_connect_aws_gai_exception(self, *args):
        """Check the structure of the returned result if it was not possible to connect to
        Airflow web server deployed in AWS due to DNS failure."""
        result = self.kwd.get_data_from_airflow_aws(self.lab_name, self.conf, "")
        for key in VALUES_OK:
            self.assertTrue(key in result)
            if key != "errors":
                self.assertEqual(result[key], None)
        for err in result["errors"]:
            self.assertTrue(err.startswith("SSH Connection from %s" %
                                           self.conf[self.lab_name]["AIRFLOW_WEB"]["host"]))
            self.assertTrue(err.endswith("failed: SOCKET-GAI-ERR"))

    @mock.patch.object(paramiko.SSHClient, "connect", side_effect=socket.error("SOCKET-ERR"))
    @mock.patch.object(paramiko.RSAKey, "from_private_key_file", return_value=None)
    def test_connect_aws_sock_exception(self, *args):
        """Check the structure of the returned result if it was not possible to connect to
        Airflow web server deployed in AWS due to socket exception."""
        result = self.kwd.get_data_from_airflow_aws(self.lab_name, self.conf, "")
        for key in VALUES_OK:
            self.assertTrue(key in result)
            if key != "errors":
                self.assertEqual(result[key], None)
        for err in result["errors"]:
            self.assertTrue(err.startswith("SSH Connection from %s" %
                                           self.conf[self.lab_name]["AIRFLOW_WEB"]["host"]))
            self.assertTrue(err.endswith("failed: SOCKET-ERR"))


class TestKeyword_GenerateOffersSingle(TestCaseNameAsDescription):
    """Class contains unit tests of generate_packages() keyword."""

    @classmethod
    def setUpClass(cls):
        lab_name = "mock"
        cls.result = run_gen_offers_single_keyword(lab_name, E2E_CONF, SINGLE_INPUT_DETAILS)
        for jira_ticket in list(SINGLE_INPUT_DETAILS.keys()):
            cls.result[jira_ticket]["offer_id"] = OFFER_ID
        # Uncomment below for debug purpose if needed
        # cls.maxDiff = None

    @classmethod
    def tearDownClass(cls):
        pass

    def test_keyword_finite(self):
        """Check the keyword execution is not infinite."""
        self.assertTrue(isinstance(self.result, dict))

    def test_keyword_result_structure(self):
        """Check the structure of the result returned by the keyword."""
        self.assertTrue(isinstance(self.result, dict))
        for jira_ticket in list(SINGLE_INPUT_DETAILS.keys()):
            self.assertTrue(isinstance(self.result[jira_ticket], dict))
            self.assertTrue("sample_id" in self.result[jira_ticket])
            self.assertTrue("offer_id" in self.result[jira_ticket])
            self.assertTrue("packages" in self.result[jira_ticket])
            self.assertTrue(isinstance(self.result[jira_ticket]["packages"], dict))

    def test_keyword_result_content(self):
        """Check the content of the result returned by the keyword."""
        # BuiltIn().log_to_console("\n\n%s\n\n" % self.result)
        self.assertEqual(self.result, SINGLE_PKG_DETAILS)


class TestKeyword_GetIngestionResultsSingle(TestCaseNameAsDescription):
    """Class contains unit tests of get_ingestion_results() keyword."""

    @classmethod
    def setUpClass(cls):
        lab_name = "mock"
        cls.helpers_obj = helpers("mock", E2E_CONF)
        cls.result = run_get_ingest_results_keyword(lab_name, E2E_CONF, SINGLE_PKG_DETAILS, 1, 1)
        # Uncomment below for debug purpose if needed
        # cls.maxDiff = None

    @classmethod
    def tearDownClass(cls):
        pass

    # def test_keyword_finite(self):
    #     """Check the keyword execution is not infinite
    #     (i.e. properties of all assets can be retrieved if all assets have been ingested),
    #     even if tries=0 (see setUpClass() method).
    #     """
    #     self.assertTrue(isinstance(self.result, dict))

    # def test_keyword_result_structure(self):
    #     """Check the structure of the result returned by the keyword."""
    #     for jira_ticket in list(SINGLE_INPUT_DETAILS.keys()):
    #         self.assertTrue(isinstance(self.result[jira_ticket], dict))
    #         self.assertTrue("sample_id" in self.result[jira_ticket])
    #         self.assertTrue("offer_id" in self.result[jira_ticket])
    #         self.assertTrue("packages" in self.result[jira_ticket])
    #         self.assertTrue(isinstance(self.result[jira_ticket]["packages"], dict))

    # def test_keyword_result_content(self):
    #     """Check the content of the result returned by the keyword."""
    #     for jira_ticket in list(SINGLE_INPUT_DETAILS.keys()):
    #         self.assertEqual(self.result[jira_ticket]["sample_id"],
    #                          SINGLE_INGESTION_RESULTS_KWD[jira_ticket]["sample_id"])
    #         self.assertEqual(self.result[jira_ticket]["offer_id"],
    #                          SINGLE_INGESTION_RESULTS_KWD[jira_ticket]["offer_id"])
    #         for package in [SINGLE_PKG_AIRFLOW_ID]:
    #             actual_pkg = self.result[jira_ticket]["packages"][package]
    #             expected_pkg = SINGLE_INGESTION_RESULTS_KWD[jira_ticket]["packages"][package]
    #             self.assertEqual(actual_pkg["fabrix_asset_id"], expected_pkg["fabrix_asset_id"])
    #             self.assertEqual(actual_pkg["airflow_workers_logs_masks"],
    #                 expected_pkg["airflow_workers_logs_masks"])
    #             self.assertEqual(actual_pkg["transcoder_workers_logs_masks"], expected_pkg["transcoder_workers_logs_masks"])
    #             self.assertEqual(actual_pkg["errors"], expected_pkg["errors"])
    #             self.assertEqual(actual_pkg["properties"], expected_pkg["properties"])


class TestKeyword_GenerateOffersMultiple(TestCaseNameAsDescription):
    """Class contains unit tests of generate_packages() keyword."""

    @classmethod
    def setUpClass(cls):
        lab_name = "mock"
        cls.result = run_gen_offers_multiple_keyword(lab_name, E2E_CONF, MULTIPLE_INPUT_DETAILS)
        for jira_ticket in list(MULTIPLE_INPUT_DETAILS.keys()):
            cls.result[jira_ticket]["offer_id"] = OFFER_ID
        # Uncomment below for debug purpose if needed
        # cls.maxDiff = None

    @classmethod
    def tearDownClass(cls):
        pass

    def test_keyword_finite(self):
        """Check the keyword execution is not infinite."""
        self.assertTrue(isinstance(self.result, dict))

    def test_all_packages_parsed(self):
        """Check the keyword execution is not infinite."""
        for jira_ticket in list(MULTIPLE_INPUT_DETAILS.keys()):
            # self.assertTrue(list(self.result[jira_ticket]["packages"].keys()), MULTIPLE_PACKAGES)
            self.assertEqual(
                sorted(list(self.result[jira_ticket]["packages"].keys())),
                MULTIPLE_PACKAGES)

    def test_keyword_result_structure(self):
        """Check the structure of the result returned by the keyword."""
        self.assertTrue(isinstance(self.result, dict))
        for jira_ticket in list(MULTIPLE_INPUT_DETAILS.keys()):
            self.assertTrue(isinstance(self.result[jira_ticket], dict))
            self.assertTrue("sample_id" in self.result[jira_ticket])
            self.assertTrue("offer_id" in self.result[jira_ticket])
            self.assertTrue("packages" in self.result[jira_ticket])
            self.assertTrue(isinstance(self.result[jira_ticket]["packages"], dict))

    def test_keyword_result_content(self):
        """Check the content of the result returned by the keyword."""
        self.assertEqual(self.result, MULTIPLE_PKG_DETAILS)


class TestKeyword_GetIngestionResultsMultiple(TestCaseNameAsDescription):
    """Class contains unit tests of get_ingestion_results() keyword."""

    @classmethod
    def setUpClass(cls):
        lab_name = "mock"
        cls.result = run_get_ingest_results_keyword(lab_name, E2E_CONF, MULTIPLE_PKG_DETAILS, 1, 1)
        # Uncomment below for debug purpose if needed
        # cls.maxDiff = None

    @classmethod
    def tearDownClass(cls):
        pass

    # def test_keyword_finite(self):
    #     """Check the keyword execution is not infinite
    #     (i.e. properties of all assets can be retrieved if all assets have been ingested),
    #     even if tries=0 (see setUpClass() method).
    #     """
    #     self.assertTrue(isinstance(self.result, dict))

    # def test_keyword_result_structure(self):
    #     """Check the structure of the result returned by the keyword."""
    #     for jira_ticket in list(MULTIPLE_INPUT_DETAILS.keys()):
    #         self.assertTrue(isinstance(self.result[jira_ticket], dict))
    #         self.assertTrue("sample_id" in self.result[jira_ticket])
    #         self.assertTrue("offer_id" in self.result[jira_ticket])
    #         self.assertTrue("packages" in self.result[jira_ticket])
    #         self.assertTrue(isinstance(self.result[jira_ticket]["packages"], dict))

    # def test_keyword_result_content(self):
    #     """Check the content of the result returned by the keyword."""
    #     for jira_ticket in list(MULTIPLE_INPUT_DETAILS.keys()):
    #         self.assertEqual(self.result[jira_ticket]["sample_id"],
    #                          MULTIPLE_INGESTION_RESULTS_KWD[jira_ticket]["sample_id"])
    #         self.assertEqual(self.result[jira_ticket]["offer_id"],
    #                          MULTIPLE_INGESTION_RESULTS_KWD[jira_ticket]["offer_id"])
    #         for package in MULTIPLE_PACKAGES:
    #             actual_pkg = self.result[jira_ticket]["packages"][package]
    #             expected_pkg = MULTIPLE_INGESTION_RESULTS_KWD[jira_ticket]["packages"][package]
    #             self.assertEqual(actual_pkg["fabrix_asset_id"], expected_pkg["fabrix_asset_id"])
    #             self.assertEqual(actual_pkg["airflow_workers_logs_masks"],
    #                 expected_pkg["airflow_workers_logs_masks"])
    #             self.assertEqual(actual_pkg["transcoder_workers_logs_masks"], expected_pkg["transcoder_workers_logs_masks"])
    #             self.assertEqual(actual_pkg["errors"], expected_pkg["errors"])
    #             self.assertEqual(actual_pkg["properties"], expected_pkg["properties"])



def suite_keywords():
    """A function builds a test suite for get_ingestion_results() keyword."""
    return unittest.makeSuite(Test_keywords, "test")


def suite_helpers():
    """A function builds a test suite for the methods of E2E() class."""
    return unittest.makeSuite(Test_helpers, "test")


def suite_tools():
    """A function builds a test suite for the methods of Tools class."""
    return unittest.makeSuite(Test_tools, "test")


def suite_health():
    """A function builds a test suite for the keywords that use methods of HealthChecks() class."""
    return unittest.makeSuite(Test_healthchecks, "test")


def suite_kwd_gen_offers_single():
    """A function builds a test suite for generate_packages() keyword."""
    return unittest.makeSuite(TestKeyword_GenerateOffersSingle, "test")


def suite_kwd_ingest_results_single():
    """A function builds a test suite for get_ingestion_results() keyword."""
    return unittest.makeSuite(TestKeyword_GetIngestionResultsSingle, "test")


def suite_kwd_gen_offers_multi():
    """A function builds a test suite for generate_packages() keyword."""
    return unittest.makeSuite(TestKeyword_GenerateOffersMultiple, "test")


def suite_kwd_ingest_results_multi():
    """A function builds a test suite for get_ingestion_results() keyword."""
    return unittest.makeSuite(TestKeyword_GetIngestionResultsMultiple, "test")


def run_tests():
    """A function to run unit tests
    (real Airflow workers and real Asset Generator script will not be used).
    """
    suites = [
        suite_keywords(),
        suite_helpers(),
        suite_tools(),
        suite_health(),
        suite_kwd_gen_offers_single(),
        suite_kwd_ingest_results_single(),
        suite_kwd_gen_offers_multi(),
        suite_kwd_ingest_results_multi(),
    ]
    for suite in suites:
        unittest.TextTestRunner(verbosity=2, buffer=True).run(suite)


def debug_ingestion(lab_name, e2e_conf):
    """A function to perform real ingestion using a keyword ingest_sample_package()."""
    outdated_license_window = {
        "title": {"xpath": "./Asset/Metadata/",
                  "attrs": {"Licensing_Window_Start": -365, "Licensing_Window_End": -366}}
    }
    bad_md5 = {
        "movie": {"xpath": "./Asset/Asset/Metadata/",
                  "attrs": {"Content_CheckSum": "Bad_Checksum_(this_is_a_negative_test)"}}
    }
    # Use for single packages tests:
    map_dict = {
        "HES-137": {"sample_id": "ts0000", "file_override": "", "pattern": None,
                    "bad_metadata": outdated_license_window},
        "HES-74": {"sample_id": "ts0000", "file_override": "", "pattern": None,
                   "bad_metadata": bad_md5}
    }
    # Uncomment to use for multiple packages tests:
    # map_dict = {"HES-209": {"sample_id": "ts0026", "file_override": "", "bad_metadata": None,
    #                         "pattern": "ts[0-9_]{1,}[0-9None]{1,4}pt"}
    # }
    helpers_obj = Keywords()
    packages = helpers_obj.generate_offers(lab_name, e2e_conf, map_dict)
    helpers_obj.get_ingestion_results(lab_name, e2e_conf, packages)
    print((helpers_obj.__dict__))


def debug_healthchecks(lab_name, e2e_conf):
    """A function to perform real health checks of the readiness for ingestion."""
    separator = "\n" + "_" * 10
    print(("%s\nKeywords().check_airflow_workers" % separator))
    Keywords().check_airflow_workers(lab_name, e2e_conf)
    print(("%s\nKeywords().check_storage_shares" % separator))
    Keywords().check_storage_shares(lab_name, e2e_conf)
    print(("%s\nKeywords().check_offering_generator" % separator))
    Keywords().check_offering_generator(lab_name, e2e_conf, ["/home/og/bin"])
    print(("%s\nKeywords().get_data_from_airflow_aws" % separator))
    result = Keywords().get_data_from_airflow_aws(lab_name, e2e_conf, "")
    print(("%s\nKeywords().check_airflow_manager_version" % separator))
    Keywords().check_airflow_manager_version(lab_name, e2e_conf, "")
    print(("%s\nKeywords().check_airflow_workers_revisions" % separator))
    Keywords().check_airflow_workers_revisions(lab_name, e2e_conf, result)


def debug_deploychecks(lab_name, e2e_conf):
    """A function to perform deploy checks of the readiness for ingestion."""
    separator = "\n" + "_" * 10
    print(("%s\nKeywords().check_group_users_membership():" % separator))
    users = ["airflow", "airflow_local", "airflowlogin"]
    gids, errors = Keywords().check_group_users_membership(lab_name, e2e_conf, "flowusers", users)
    print((gids, errors))
    print(("%s\nKeywords().check_group_users_details():" % separator))
    bash = "/bin/bash"
    expected = {"airflow": {"uid": 5001, "gid": None, "home": "/usr/local/airflow", "shell": bash},
                "airflowlogin": {"shell": bash}, "airflow_local": {"shell": bash}}
    details, errors = Keywords().check_group_users_details(lab_name, e2e_conf, gids, expected)
    print((details, errors))
    print(("%s\nKeywords().check_users_homes():" % separator))
    expected = {"airflow": {"owner": "airflow", "group": "flowusers", "home": "/usr/local/airflow"}}
    details, errors = Keywords().check_users_homes(lab_name, e2e_conf, expected)
    print((details, errors))


def debug_no_og_ingestion(lab_name, e2e_conf):
    """A function to perform real ingestion where no OG is involved."""
    helpers_obj = helpers(lab_name, e2e_conf)
    path = "/mnt/nfs_watch/Test_Assets/4_5_Audio_Dolby_2audios/" + \
           "crid~~3A~~2F~~2Fe2e-si.lgi.com~~2F1-sundancetv3_trimmed_multiaudio_multisub"
    # path = "/mnt/nfs_watch/Test_Assets/3_HEVC_720p/49707-hanni-nanni"
    print((helpers_obj.create_no_og_package(path)))


if __name__ == "__main__":
    E2E_CONF.update({"labobocsi": {
        "CPE_ID": "3C36E4-EOSSTB-003356410807",
        "country": "nl", "languages": ["nl"],
        "ITFAKER": {"host": "172.30.182.30", "port": 8000, "env": "labobocsi"},
        "FABRIX": {"host": "172.30.107.68", "port": 5929},
        "STREAMER": {"host": "172.30.106.85", "port": 5554},
        "MOUNTS": {"watch": {"host": "192.168.1.193", "folder": "/obo_watch", "type": "nfs"},
                   "manage": {"host": "192.168.1.194", "folder": "/obo_manage", "type": "nfs"}},
        "IRDETO": {"host": "lgiobo.stage.ott.irdeto.com", "port": 80},
        "OESP": {"username": "wipronl01", "password": "wipro1234",
                 "country": "NL", "language": "nld", "device": "web"},
        "AIRFLOW_WORKERS": [{"host": "172.23.69.113", "port": 22,
                             "user": "airflowlogin", "password": "air@flow123",
                             "logs_folder": "/usr/local/airflow/logs",
                             "watch_folder": "/mnt/nfs_watch/Countries/CSI/ToAirflow",
                             "managed_folder": "/mnt/nfs_managed/Countries/CSI/FromAirflow"},
                            {"host": "172.23.69.57", "port": 22,
                             "user": "airflowlogin", "password": "air@flow123",
                             "logs_folder": "/usr/local/airflow/logs",
                             "watch_folder": "/mnt/nfs_watch/Countries/CSI/ToAirflow",
                             "managed_folder": "/mnt/nfs_managed/Countries/CSI/FromAirflow"},
                           ],
        "AIRFLOW_WEB": {"host": "webserver1.airflow-lab5a.horizongo.eu", "port": 22,
                        "user": "ec2-user",
                        "key_path": "../../resources/stages/horizongodevepam.pem"},
        "ASSET_GENERATOR": {"host": "172.30.218.244", "port": 22,
                            "user": "og", "password": "cutv", "path": "/var/tmp/adi-auto-deploy"},
        "OG": [{"host": "172.30.108.16", "port": 22, "user": "og", "password": "cutv",
                "watch_folder": "/opt/og/Countries/CSI/ToAirflow",
                "logs_folder": "/opt/og/Countries/CSI/log"},
               {"host": "172.30.108.17", "port": 22, "user": "og", "password": "cutv",
                "watch_folder": "/opt/og/Countries/CSI/ToAirflow",
                "logs_folder": "/opt/og/Countries/CSI/log"},
              ],
        "ORIGINS": [{"host": "172.30.107.71", "port": 22, "user": "root", "password": "F@brix",
                     "managed_folder": "/obo_manage/Countries/CSI/FromAirflow"},
                    {"host": "172.30.107.72", "port": 22, "user": "root", "password": "F@brix",
                     "managed_folder": "/obo_manage/Countries/CSI/FromAirflow"}
                   ],
        "TRANSCODERS": [{"host": "172.30.108.10", "port": 22,
                         "user": "oboadm", "password": "oboadm1n",
                         "managed_folder": "/mnt/obo_manage/Countries/CSI/FromAirflow",
                         "sudo_prefix": "echo -e oboadm1n | sudo -S su - ericsson -c "},
                        {"host": "172.30.108.77", "port": 22,
                         "user": "oboadm", "password": "oboadm1n",
                         "managed_folder": "/mnt/obo_manage/Countries/CSI/FromAirflow",
                         "sudo_prefix": "echo -e oboadm1n | sudo -S su - ericsson -c "}
                       ],
        "SEACHANGE": {"TRAXIS_WEB": {"host": "172.30.97.13", "port": 80, "path": "traxis/web"}},
        "MICROSERVICES" : {
            "OBOQBR": "oboqbr.labe2esuperset.ss.dmdsdp.com",
            "EPG-SERVICE": "epg.labe2esuperset.ss.dmdsdp.com",
        },
        "CDN": {"epg": "epg.labe2esuperset.nl.dmdsdp.com",
                "poster": "oboposter.labe2esuperset.nl.dmdsdp.com",
                "omw": "omw.labe2esuperset.nl.dmdsdp.com",
                "omwssu": "omwssu.labe2esuperset.nl.dmdsdp.com",
                "speedtest": "speedtest.labe2esuperset.nl.dmdsdp.com",
                "vod": "labobocsi_cdn_vod.txt", "replay": "labobocsi_cdn_replay.txt",
                "dvrrb": "labobocsi_cdn_dvrrb.txt", "dvr": "labobocsi_cdn_dvr.txt",
                "review": "labobocsi_cdn_review.txt",
                "ASSETIZED_REC_CRID": {"3C36E4-EOSSTB-003356410807":
                                       "crid:~~2F~~2Fbds.tv~~2F196376630,imi:0010000000172308"}
               },
        "XAP": {"host": "172.30.108.21", "port": 80},
    },
                    })
    # debug_ingestion("labobocsi", E2E_CONF)
    # debug_healthchecks("labobocsi", E2E_CONF)
    # debug_deploychecks("labobocsi", E2E_CONF)
    # debug_no_og_ingestion("labobocsi", E2E_CONF)

    run_tests()
