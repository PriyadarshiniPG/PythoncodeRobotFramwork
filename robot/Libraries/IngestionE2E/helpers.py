# pylint: disable=W1401
# pylint: disable=C0301
# pylint: disable=too-many-lines
# pylint: disable=wrong-import-position
# pylint: disable=wrong-import-order
# pylint: disable=C0103
# pylint: disable=W0612
# pylint: disable=R0912
# pylint: disable=C0302
# Disabled "anomalous-backslash-in-string" until we move Robot Framework and libraries to Python 3.
"""Implementation of a helper class for IngestionE2E library's keywords in Robot Framework."""
import os
import sys
import inspect
currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
lib_dir = os.path.dirname(currentdir)
import datetime
import re
import time
import json
import ast
import random
import xml.etree.ElementTree as ElementTree
import urllib.request
import urllib.parse
import urllib.error
from import_file import import_file
import requests
import xmltodict
from bs4 import BeautifulSoup
from lxml import etree
import pymediainfo
from PIL import Image
from robot.libraries.BuiltIn import BuiltIn
robot_dir = os.path.dirname(lib_dir)
sys.path.append(robot_dir)
from Libraries.general.keywords import Keywords as general
easy_debug = general.easy_debug
general = general()
from .tools import Tools
current_dir = os.path.dirname(os.path.realpath(__file__))
current_file = os.path.basename(__file__)
mock_data = import_file("%s/../../resources/stages/mock_data/data.py" % current_dir).MOCK_DATA

FOLDER = os.path.dirname(os.path.abspath(__file__))


# pylint: disable=R0904
class E2E(object):
    """A class to handle connections and requests used in E2E ingestion tests."""

    def __init__(self, lab_name, e2e_conf, offer_id=None, packages=None, keywords_object=None):
        """The class initializer.

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf.py.
        :param e2e_conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf.py.
        :param offer_id: an identifier returned by asset generator script.
        :param packages: a dictionary of details for all packages in the offer.
        """
        self.lab_name = lab_name.replace("lab", "")
        self.conf = e2e_conf[lab_name]
        self.offer_id = offer_id or None
        self.packages = packages or {}
        self.error = ""
        if keywords_object:
            self.variables = keywords_object.helpers_variables
        else:
            self.variables = {}
        self.tools = Tools(self.conf)
        self.create_obo_assets_workflows = [
            "create_obo_assets_workflow",
            "csi_lab_create_obo_assets_workflow",
            "ecx_superset_create_obo_assets_workflow"
        ]
        self.create_obo_assets_transcoding_driven_workflows = [ # pylint: disable=C0103
            "csi_lab_create_obo_assets_transcoding_driven_workflow",
            "e2esi_lab_create_obo_assets_transcoding_driven_workflow",
            "ecx_superset_create_obo_assets_transcoding_driven_workflow"
        ]

    @easy_debug
    def log_variables(self, method, namespace):
        """
        A method to log to Robot Framework HTML log:
            - file name
            - method name
            - variable name
            - variable type
            - variable value
        Result example:
        "File 'helpers.py' >>> Method 'get_movie_type' >>> Variable name 'package'. \
            Type 'str'. Value:
                ts0201_20190314_134718ot"

        :param method: method instance
        :param namespace: local namespace of the method
        """
        printed_variables = general.log_all_variables_name_and_value(
            vars_dictionary=self.variables, file_name=current_file,
            method=method, namespace=namespace)

        self.variables = printed_variables

    @easy_debug
    def _new_attr_value(self, old_val, item, attr):
        if isinstance(item["attrs"][attr], int) \
                and re.match("[0-9\-]{10}T[0-9:]{8}", old_val):
            old_date = datetime.datetime.strptime(old_val, "%Y-%m-%dT%H:%M:%S")
            new_date = (old_date + datetime.timedelta(item["attrs"][attr]))
            new_val = new_date.strftime("%Y-%m-%dT%H:%M:%S")
        elif not isinstance(item["attrs"][attr], str):
            new_val = str(item["attrs"][attr])
        else:
            new_val = item["attrs"][attr]

        new_val = general.remove_non_ascii(new_val)
        new_val = general.insure_text(new_val)
        self.log_variables(self._new_attr_value, locals())
        BuiltIn().log_to_console("New value: %s. Type: %s" % (new_val, type(new_val)))
        return new_val

    @easy_debug
    def _spoil_adi(self, path_to_adi, bad_metadata):
        """Method spoils the contents of ADI.XML to prepare incorrect metadata about the package,
        which will be used for negative tests.

        :param path_to_adi: an absolute path to ADI.XML written by generator script.
        :param bad_metadata: a list of dictionaries describing the changes to be done to ADI.XML.
        .. note :: find an example of bad matadata in test_keywords.py (BAD_METADATA const).

        :return: True if writing content into a file on remote host is successful, False otherwise.
        """

        BuiltIn().log_to_console("\nI'm going to spoil file %s\n" % path_to_adi)

        ssh_creds = [self.conf["ASSET_GENERATOR"]["host"], self.conf["ASSET_GENERATOR"]["port"],
                     self.conf["ASSET_GENERATOR"]["user"], self.conf["ASSET_GENERATOR"]["password"]]
        xml_str = self.tools.ssh_read_file(*(ssh_creds + [path_to_adi]))
        xml_bites = xml_str.encode('utf-8')

        if not xml_bites:
            self.log_variables(self._spoil_adi, locals())
            raise Exception("We didn't find xml string when tried to spoil ADI.XML file")

        xml = etree.fromstring(xml_bites)

        status = True
        for bad_data in bad_metadata:
            asset_class_node = xml.findall(bad_data["xpath_locate"])[0]

            for attr in list(bad_data["attrs"].keys()):
                asset_node = asset_class_node.find(bad_data["xpath_change"])
                old_val = asset_node.attrib[attr]
                # Consider integer value of bad_metadata as time delta for date-type attributes:
                new_attribute = self._new_attr_value(old_val, bad_data, attr)
                asset_node.attrib[attr] = new_attribute
                if bad_data["cmd"]:
                    stderr = self.run_bad_metadata_command(bad_data, old_val, path_to_adi,
                                                           ssh_creds)
                    status = False if stderr else status
        xml_str_to_write = etree.tostring(xml, encoding="UTF-8", pretty_print=True)
        status = status and self.tools.ssh_write_file(*(ssh_creds + [path_to_adi, xml_str_to_write]))
        if status:
            BuiltIn().log_to_console("ADI file was successfuly spoiled")
            new_content = self.tools.ssh_read_file(*(ssh_creds + [path_to_adi]))
            BuiltIn().log_to_console("New content is:\n\n%s\n" % new_content)
        else:
            raise Exception("Fail in '_spoil_adi' when wrote new content")
        self.log_variables(self._spoil_adi, locals())
        return status, xml_str_to_write

    @easy_debug
    def run_bad_metadata_command(self, bad_data, old_val, path_to_adi, ssh_creds):
        """A sub-method of _spoil_adi to run command from bad_metadata"""
        args = {"dir_to_adi": path_to_adi[:path_to_adi.rfind("/")], "old_val": old_val}
        stderr = self.tools.run_ssh_cmd(*(ssh_creds + [bad_data["cmd"] % args]))[1]
        BuiltIn().log_to_console("Done: %s.\nReturned stderr:\n%s\n" %
                                 (bad_data["cmd"], stderr))
        return stderr

    @easy_debug
    def block_movie_type_ingestion_in_adi_file(
            self, path_to_adi, movie_type, server="ASSET_GENERATOR"):
        """Method to block ott or stb movie ingestion by adding special line to ADI.XML file

        :param path_to_adi: an absolute path to ADI.XML written by generator script.
        :param movie_type: ott or stb, string. Lower and upper case are allowed
        :param server: remote server name from conf file, like OG, ASSET_GENERATOR, etc
        """
        if server == "OG":
            server_creds = self.conf[server][0]
        else:
            server_creds = self.conf[server]
        ssh_creds = [server_creds["host"], server_creds["port"],
                     server_creds["user"], server_creds["password"]]
        xml_str = self.tools.ssh_read_file(*(ssh_creds + [path_to_adi]))
        xml_bytes = xml_str.encode("UTF-8")
        BuiltIn().log_to_console("\nI'm going to block %s movie type in adi file %s" %
                                 (movie_type, path_to_adi))
        BuiltIn().log_to_console("Old content of the adi file is:\n\n%s\n" %
                                 general.insure_text(xml_str))
        xml = ElementTree.fromstring(xml_bytes)
        asset_node = xml.find("Asset")
        asset_subnode = None
        for child in asset_node.findall("Asset"):
            for ams in child.iter('AMS'):
                if ams.attrib["Asset_Class"] == "movie":
                    asset_subnode = child
        if asset_subnode is None:
            self.log_variables(self.block_movie_type_ingestion_in_adi_file, locals())
            raise Exception("ADI.XML parsing error")
        # else:
        metadata = asset_subnode.find("Metadata")
        block_node = ElementTree.SubElement(metadata, "App_Data")
        block_node.set("App", "MOD")
        block_node.set("Name", "Block_Platform")

        if movie_type in ['ott', 'OTT']:
            block_node.set("Value", "BLOCK_OTT")
        elif movie_type in ['stb', 'STB']:
            block_node.set("Value", "BLOCK_STB")
        elif movie_type in ['4k_stb', '4K_STB']:
            block_node.set("Value", "BLOCK_4K_STB")
        elif movie_type in ['4k_ott', '4K_OTT']:
            block_node.set("Value", "BLOCK_4K_OTT")
        xml_str_to_write = ElementTree.tostring(xml, encoding="UTF-8")
        file_changed = self.tools.ssh_write_file(*(ssh_creds + [path_to_adi, xml_str_to_write]))
        if file_changed:
            BuiltIn().log_to_console("ADI.xml file was successfully modified")
            new_content = self.tools.ssh_read_file(*(ssh_creds + [path_to_adi]))
            BuiltIn().log_to_console("New content is:\n\n%s\n" % new_content)
        else:
            raise Exception("Fail in 'block_movie_type_ingestion_in_adi_file' "
                            "when wrote new content")
        self.log_variables(self.block_movie_type_ingestion_in_adi_file, locals())
        return xml_str_to_write

    @easy_debug
    def _make_tva_unique(self, ssh, tva_xmldict, offer_id, pkg_dir, tva_fname, new_time_delta=None):
        """Append timestamps to group_id, program_id, imi in the TVA file to make it unique."""
        BuiltIn().log_to_console("\nMaking TVA file unique for package %s" % offer_id)

        updated_tva_file, new_expiration_date = self._change_tva_expiration_date(
            ssh, tva_xmldict, offer_id, pkg_dir, tva_fname, new_time_delta)

        BuiltIn().log(updated_tva_file)

        tva_program_description = tva_xmldict["TVAMain"]["ProgramDescription"]

        BuiltIn().log_to_console("\n\n%s\n\n" % tva_program_description)

        self.make_tva_program_id_unique(offer_id, pkg_dir, ssh, tva_fname, tva_program_description)

        self.make_tva_group_id_unique(offer_id, pkg_dir, ssh, tva_fname, tva_program_description)

        self.make_tva_instance_metadata_id_unique(offer_id, pkg_dir, ssh, tva_fname, tva_program_description)

        BuiltIn().log_to_console("Done, package %s is unique now\n" % offer_id)
        return new_expiration_date

    @easy_debug
    def make_tva_instance_metadata_id_unique(self, offer_id, pkg_dir, ssh, tva_fname, tva_program_description):
        """ Sub-method of _make_tva_unique to make unique 'InstanceMetadataId' value of TVA.XML file

        :param offer_id: package name, string
        :param pkg_dir: absolute path to package directory
        :param ssh: ssh credentials dictionary
        :param tva_fname: name of TVA.....xml file
        :param tva_program_description: tva_file["TVAMain"]["ProgramDescription"]
        :return: updated_tva_file, dict
        """
        cmd = []
        on_demand_program = tva_program_description["ProgramLocationTable"]["OnDemandProgram"]
        if isinstance(on_demand_program, list):
            for item in on_demand_program:
                imi = item["InstanceMetadataId"]
                cmd.append("sed -i 's|%s|%s_%s|g' %s/%s" % \
                      (str(imi), str(imi), str(offer_id), str(pkg_dir), str(tva_fname)))
        elif isinstance(on_demand_program, dict):
            imi = on_demand_program["InstanceMetadataId"]
            cmd.append("sed -i 's|%s|%s_%s|g' %s/%s" % \
                       (str(imi), str(imi), str(offer_id), str(pkg_dir), str(tva_fname)))
        # BuiltIn().log_to_console("Command: %s" % " && ".join(cmd))
        error = self.tools.run_ssh_cmd(*(ssh + [" && ".join(cmd)]))[1]
        updated_tva_file = self.read_tva(pkg_dir, tva_fname)
        self.log_variables(self.make_tva_instance_metadata_id_unique, locals())
        if error:
            raise Exception("Could not replace InstanceMetadataId in the TVA xml file %s"
                            % error)
        # else:
        return updated_tva_file

    @easy_debug
    def make_tva_group_id_unique(self, offer_id, pkg_dir, ssh, tva_fname, tva_program_description):
        """ Sub-method of _make_tva_unique to make unique '@groupId' value of TVA.XML file

        :param offer_id: package name, string
        :param pkg_dir: absolute path to package directory
        :param ssh: ssh credentials dictionary
        :param tva_fname: name of TVA.....xml file
        :param tva_program_description: tva_file["TVAMain"]["ProgramDescription"]
        :return: updated_tva_file, dict
        """
        group_information = tva_program_description["GroupInformationTable"]["GroupInformation"]
        gr_id = group_information[0]["@groupId"] if isinstance(group_information, list) \
            else group_information["@groupId"]
        try:
            cmd = "sed -i 's|%s|%s_%s|g' %s/%s " % \
                  (str(gr_id), str(gr_id), str(offer_id), str(pkg_dir), str(tva_fname))
        except UnicodeEncodeError:
            cmd = "sed -i 's|%s|%s_%s|g' %s/%s " % \
                  (gr_id, gr_id, offer_id, pkg_dir, tva_fname)
        # BuiltIn().log_to_console("Command: %s" % cmd)
        error = self.tools.run_ssh_cmd(*(ssh + [cmd]))[1]
        updated_tva_file = self.read_tva(pkg_dir, tva_fname)
        self.log_variables(self.make_tva_group_id_unique, locals())
        if error:
            raise Exception("Could not replace group id in the TVA xml file %s"
                            % error)
        # else:
        return updated_tva_file

    @easy_debug
    def make_tva_program_id_unique(self, offer_id, pkg_dir, ssh, tva_fname, tva_program_description):
        """ Sub-method of _make_tva_unique to make unique '@programId' value of TVA.XML file

        :param offer_id: package name, string
        :param pkg_dir: absolute path to package directory
        :param ssh: ssh credentials dictionary
        :param tva_fname: name of TVA.....xml file
        :param tva_program_description: tva_file["TVAMain"]["ProgramDescription"]
        :return: updated_tva_file, dict
        """
        program_information = tva_program_description["ProgramInformationTable"]["ProgramInformation"]
        pr_id = program_information[0]["@programId"] if isinstance(program_information, list) else \
            program_information["@programId"]
        try:
            cmd = "sed -i 's|%s|%s_%s|g' %s/%s " % \
                  (str(pr_id), str(pr_id), str(offer_id), str(pkg_dir), str(tva_fname))
        except UnicodeEncodeError:
            cmd = "sed -i 's|%s|%s_%s|g' %s/%s " % \
                  (pr_id, pr_id, offer_id, pkg_dir, tva_fname)
        # BuiltIn().log_to_console("Command: %s" % cmd)
        error = self.tools.run_ssh_cmd(*(ssh + [cmd]))[1]
        updated_tva_file = self.read_tva(pkg_dir, tva_fname)
        self.log_variables(self.make_tva_program_id_unique, locals())
        if error:
            raise Exception("Could not replace program id in the TVA xml file %s"
                            % error)
        # else:
        return updated_tva_file

    @easy_debug
    def _change_tva_expiration_date(self, ssh, tva_xmldict, offer_id, pkg_dir, tva_fname, new_time_delta=None):
        """Append timestamps to group_id, program_id, imi in the TVA file to make it unique."""
        BuiltIn().log_to_console("Changing of expiration date in TVA file")
        tva_xmldict = tva_xmldict["TVAMain"]["ProgramDescription"]
        program_information = tva_xmldict["ProgramInformationTable"]["ProgramInformation"]
        on_demand_program = tva_xmldict["ProgramLocationTable"]["OnDemandProgram"]
        expiration_date = program_information[0]["@fragmentExpirationDate"] \
            if isinstance(program_information, list) \
            else program_information["@fragmentExpirationDate"]
        old_end_of_availability = on_demand_program[0]["EndOfAvailability"] \
            if isinstance(on_demand_program, list) \
            else on_demand_program["EndOfAvailability"]
        # Format: 2019-08-02T10:09:51.535879+02:00
        old_end_of_availability = old_end_of_availability.split(".")[0]
        BuiltIn().log_to_console(expiration_date)
        BuiltIn().log_to_console(old_end_of_availability)
        now = datetime.datetime.utcnow()
        if not new_time_delta:
            time_delta = datetime.timedelta(days=3)
        else:
            time_delta = self.get_time_delta_object_from_string(new_time_delta)
        new_expiration_date_obj = now + time_delta  # N days in a future
        new_expiration_date = new_expiration_date_obj.strftime('%Y-%m-%dT%H:%M:%SZ')
        new_end_of_availability = new_expiration_date_obj.strftime('%Y-%m-%dT%H:%M:%S')
        BuiltIn().log_to_console("\nNew expiration date for package %s is: %s\n" %
                                 (offer_id, new_expiration_date))
        cmd = "sed -i 's|%s|%s|g' %s/%s " % \
               (str(expiration_date),
                str(new_expiration_date),
                str(pkg_dir), str(tva_fname))
        cmd += "&& sed -i 's|%s|%s|g' %s/%s " % \
               (str(old_end_of_availability),
                str(new_end_of_availability),
                str(pkg_dir), str(tva_fname))
        error = self.tools.run_ssh_cmd(*(ssh + [cmd]))[1]
        updated_tva_file = self.read_tva(pkg_dir, tva_fname)
        # BuiltIn().log_to_console("\n\n%s\n\n" % updated_tva_file)
        self.log_variables(self._change_tva_expiration_date, locals())
        if error:
            raise Exception("Could not upgrade expiration date in TVA xml file %s" % error)
        # else:
        return updated_tva_file, new_expiration_date

    @easy_debug
    def get_time_delta_object_from_string(self, new_time_delta):
        """Helpful method to return datetime.timedelta object from string like "1-hours"

        :param new_time_delta: string like "1-hours"
        :return: datetime.timedelta object
        """
        value, units = new_time_delta.split("-")
        if units == "days":
            time_delta = datetime.timedelta(days=int(value))
        elif units == "seconds":
            time_delta = datetime.timedelta(seconds=int(value))
        elif units == "microseconds":
            time_delta = datetime.timedelta(microseconds=int(value))
        elif units == "milliseconds":
            time_delta = datetime.timedelta(milliseconds=int(value))
        elif units == "minutes":
            time_delta = datetime.timedelta(minutes=int(value))
        elif units == "hours":
            time_delta = datetime.timedelta(hours=int(value))
        elif units == "weeks":
            time_delta = datetime.timedelta(weeks=int(value))
        else:
            raise Exception("Unexpected units for timedelta: %s" % units)
        self.log_variables(self.get_time_delta_object_from_string, locals())
        return time_delta

    @easy_debug
    def create_no_og_package(self, src_dir, keep_lock=True,
                             offer_id="Random", folder=None, unique=True, change_image_extension=None,
                             new_time_delta=None, new_tva_name=None):
        """On Airflow workers the folders containing packages for no-OG tests are mounted.
        Method copies the package into the watch folder and puts an empty 'lock.tmp' file -
        to make sure, Airflow does not pick it up until changes to the packages are completed
        (at least an update of crid value in the TVA XML is needed).
        If keep_lock is True, the lock file is not removed, so additional changes can be done later.
        Note, only the oldest TVA file is copied, and all subfolders are skipped if any, i.e.:

        :param src_dir: an abs path to a folder with the package files (mounted on each AF worker).
        :param keep_lock: a boolean indicator whether to leave the package locked from Airflow.
        :param offer_id: string name of offer id
        :param change_image_extension: None or list with current and new image extension
        :param new_tva_name: dictionary for concurency and priority test like:



        :return: a 3-tuple (offer_id, pkg_dir, tva_fname) or a list of error messages if any.
        """
        package_name = self.get_no_og_package_name(offer_id)
        watch_folder = self.get_no_og_watch_folder_path(folder)
        pkg_dir = "%s/%s" % (watch_folder, package_name)
        ssh = [self.conf["AIRFLOW_WORKERS"][0]["host"], self.conf["AIRFLOW_WORKERS"][0]["port"],
               self.conf["AIRFLOW_WORKERS"][0]["user"], self.conf["AIRFLOW_WORKERS"][0]["password"]]
        out = self.run_ssh_commands_for_no_og_ingestion(ssh, pkg_dir, src_dir, new_tva_name)
        print(out)
        tva_fname = self.get_tva_file_name(pkg_dir, ssh)
        # read TVA content, grab program id and group id and make the package unique
        tva = self.read_tva(pkg_dir, tva_fname)
        if isinstance(tva, list):
            error_messages_list = tva
            self.log_variables(self.create_no_og_package, locals())
            return error_messages_list  # list of error messages

        if unique:
            new_expiration_date = self._make_tva_unique(
                ssh, tva, package_name, pkg_dir, tva_fname, new_time_delta)
        else:
            new_expiration_date = self._change_tva_expiration_date(
                ssh, tva, package_name, pkg_dir, tva_fname)[1]

        if change_image_extension:
            self.change_asset_image_extension(ssh, pkg_dir, change_image_extension)

            tva_fname = self.rename_tva_file(pkg_dir, ssh, tva_fname)
        if not keep_lock:
            error = self.tools.run_ssh_cmd(*(ssh + ["rm -f %s/lock.tmp" % pkg_dir]))[1]
            if error:
                self.log_variables(self.create_no_og_package, locals())
                return [error]

        attempt = 0
        ingestion_started = False
        while not ingestion_started and attempt < 60:
            time.sleep(1)
            ingestion_started = self.is_asset_present_in_watch_folder(watch_folder, package_name)
            attempt += 1

        self.prepare_no_og_package_structure(
            ingestion_started, package_name,
            watch_folder, tva_fname, new_time_delta,
            new_expiration_date, new_tva_name)

        self.log_variables(self.create_no_og_package, locals())

    @easy_debug
    def change_asset_image_extension(self, ssh, pkg_dir, change_image_extension):
        """A method to change extension of image modify the TVA file as well accordingly
        This method is precondition part of HES-3654 test case

        :param ssh: list of ssh credentials, as host, port, username, password
        :param pkg_dir: absolute path to package folder, string
        :param change_image_extension: list with current and new image extension
        """
        old_format = change_image_extension[0]
        new_format = change_image_extension[1]
        # change image extension itself
        files_str, stderr = self.get_directory_structure(ssh, pkg_dir)
        if stderr:
            raise Exception(stderr)
        images = [image for image in files_str.splitlines() if old_format in image]
        tva_file = [tva for tva in files_str.splitlines() if ".xml" in tva][0]
        random_image = random.choice(images)
        path_to_image = "%s/%s" % (pkg_dir, random_image)
        new_name = random_image.replace(old_format, new_format)
        self.rename_file(ssh, path_to_image, new_name)

        # new_path_to_image = path_to_image.replace(random_image, new_name)
        # host, port, username, password = tuple(ssh)
        # # Doc: http://effbot.org/imagingbook/image.htm
        # command = """python -c "exec(\\"from PIL import Image\\nImage.open('%s').convert('RGB').save('%s')\\")" && rm -f %s""" % (
        #     path_to_image, new_path_to_image, path_to_image)
        # # BuiltIn().log_to_console(command)
        # stdout, stderr = self.tools.run_ssh_cmd(host, port, username, password, command)
        # if stderr:
        #     raise Exception("Failed to change image format in "
        #                     "change_asset_image_extension: %s" % stderr)
        # BuiltIn().log_to_console("stdout: %s" % stdout)

        # change image extension in TVA file
        path_to_tva_file = "%s/%s" % (pkg_dir, tva_file)
        self.change_line_in_file(ssh, path_to_tva_file, random_image, new_name)
        self.log_variables(self.change_asset_image_extension, locals())

    @easy_debug
    def change_line_in_file(self, ssh, path_to_file, old_value, new_value):
        """A method to change any value in any file on remote host using 'sed'

        :param ssh: list of ssh credentials, as host, port, username, password
        :param path_to_file: absolute path to file
        :param old_value: old value what need to be changed
        :param new_value: new value, what replace old value in the file
        """
        command = "sed -i 's/%s/%s/' %s" % (old_value, new_value, path_to_file)
        BuiltIn().log_to_console("I'm going to change %s to %s in %s file" %
                                 (old_value, new_value, path_to_file))
        stdout, stderr = self.tools.run_ssh_cmd(*(ssh + [command]))
        if stderr:
            raise Exception(stderr)
        BuiltIn().log_to_console("Done")
        self.log_variables(self.change_line_in_file, locals())

    @easy_debug
    def get_directory_structure(self, ssh, path_to_dir, long_listing_format=False, show_hidden=False):
        """A method to get folder structure (what is inside) ising 'ls'

        :param ssh: list of ssh credentials, as host, port, username, password
        :param path_to_dir: absolute path to folder
        :param long_listing_format: "ls -l" command will be used
        :param show_hidden: show files what started from . (dot)
        :return:
        """
        if long_listing_format:
            if show_hidden:
                ls_command = "ls -la"
            else:
                ls_command = "ls -l"
        else:
            if show_hidden:
                ls_command = "ls -a"
            else:
                ls_command = "ls"
        command = "%s %s" % (ls_command, path_to_dir)
        stdout, stderr = self.tools.run_ssh_cmd(*(ssh + [command]))
        self.log_variables(self.get_directory_structure, locals())
        return stdout, stderr

    @easy_debug
    def rename_file(self, ssh, path_to_file, new_name):
        """A method to rename any remote file

        :param ssh: list of ssh credentials, as host, port, username, password
        :param path_to_file: absolute path to file what needs to be renamed, string
        :param new_name: new name of the file, string
        """
        folder = "/".join(path_to_file.split("/")[:-1])
        old_name = path_to_file.split("/")[-1]
        new_path = "%s/%s" % (folder, new_name)
        command = "mv %s %s" % (path_to_file, new_path)
        BuiltIn().log_to_console("I'm going to rename %s to %s" % (old_name, new_name))
        stdout, stderr = self.tools.run_ssh_cmd(*(ssh + [command]))
        self.log_variables(self.rename_file, locals())
        if stderr:
            raise Exception(stderr)
        BuiltIn().log_to_console("Done")

    @easy_debug
    def rename_tva_file(self, pkg_dir, ssh, tva_fname):
        """A method to rename TVA file based on timestamp to make it unique

        :param pkg_dir: dir where package with TVA file is placed
        :param ssh: ssh credentials
        :param tva_fname: actual TVA file name
        :return: new TVA file name based on timestamp
        """
        # Example of TVA file name TVA_000001_20170802081133.xml
        if re.match(pattern="TVA_\d{6}_\d{14}.xml", string=tva_fname):
            old_time_stamp = tva_fname.split(".")[0].split("_")[2]
            new_time_stamp = datetime.datetime.now().strftime('%Y%m%d%H%M%S')
            new_tva_fname = tva_fname.replace(old_time_stamp, new_time_stamp)
            command = "mv {pkg_dir}/{tva_fname} {pkg_dir}/{new_tva_fname}".format(
                pkg_dir=pkg_dir, tva_fname=tva_fname, new_tva_fname=new_tva_fname
            )
            error = self.tools.run_ssh_cmd(*(ssh + [command]))[1]
            if not error:
                tva_fname = new_tva_fname
            else:
                raise Exception("Failed to rename TVA file. Error: %s" % error)
        else:
            raise Exception("Unexpected TVA file name format: %s. Expected format like "
                            "'TVA_000001_20170802081133.xml'")
        return tva_fname

    @easy_debug
    def prepare_no_og_package_structure(self, ingestion_started, package_name,
                                        watch_folder, tva_fname, new_time_delta=None,
                                        new_expiration_date=None, new_tva_name=None):
        """Sub-method of create_no_og_package method to structure and update self.packages[package_name]

        :param ingestion_started: boolean. True if asset_present_in_watch_folder, else False
        :param package_name: package name, string
        :param watch_folder: "watch_folder" or "watch_folder_priority, string"
        :param tva_fname: name of TVA....XML file
        """
        if ingestion_started:
            pkg_dir = "%s/%s" % (watch_folder, package_name)
            try:
                pkg_struct = {"adi": "", "tva": "%s/%s" % (str(pkg_dir), str(tva_fname)),
                              "output_tva": "", "fabrix_asset_id": "",
                              "properties": {}, "airflow_workers_logs_masks": [], "actual_dag": "",
                              "transcoder_workers_logs_masks": [], "errors": [],
                              "new_time_delta": new_time_delta,
                              "expiration_date": new_expiration_date,
                              "new_tva_name": new_tva_name}
            except UnicodeEncodeError as err:
                pkg_struct = {"adi": "", "tva": "%s/%s" % (pkg_dir, tva_fname), "output_tva": "",
                              "fabrix_asset_id": "", "properties": {},
                              "airflow_workers_logs_masks": [], "actual_dag": "",
                              "transcoder_workers_logs_masks": [], "errors": [],
                              "new_time_delta": new_time_delta,
                              "expiration_date": new_expiration_date,
                              "new_tva_name": new_tva_name}
                print(err)
            BuiltIn().log_to_console("PACKAGE NAME is: %s" % package_name)
            BuiltIn().log_to_console("PACKAGE STRUCTURE is: %s" % pkg_struct)

            self.packages.update({package_name: pkg_struct})
            self.log_variables(self.prepare_no_og_package_structure, locals())
        else:
            self.log_variables(self.prepare_no_og_package_structure, locals())
            raise Exception("Asset data was not found in watch folder")

    @easy_debug
    def get_tva_file_name(self, pkg_dir, ssh):
        """Sub-method of create_no_og_package method to get TVA file name from the package folder,
        by this time this is the only TVA xml there

        :param pkg_dir: absolute path to package directory
        :param ssh: ssh credentials
        :return: tva_fname, string
        """
        cmd = "ls -ltr %s/TVA_*.xml | head -n 1 | awk -F '/' '{print $NF}'" % pkg_dir  # oldest TVA
        tva_fname, error = self.tools.run_ssh_cmd(*(ssh + [cmd]))
        self.log_variables(self.get_tva_file_name, locals())
        if not (tva_fname.startswith("TVA_") and tva_fname.endswith(".xml")):
            raise Exception("Could not get TVA file name. Error: %s" % error)
        return tva_fname

    @easy_debug
    def run_ssh_commands_for_no_og_ingestion(self, ssh, pkg_dir, src_dir, tva_name=None):
        """Sub-method of create_no_og_package method to run ssh commands for no og ingestion

        :param pkg_dir: absolute path to package directory
        :param ssh: ssh credentials
        :param src_dir: an abs path to a folder with the package files (mounted on each AF worker).
        :param tva_name: dictionary for concurency and priority test like:

        :return: output of ssh command
        """
        cmd = "mkdir %s && touch %s/lock.tmp " % (str(pkg_dir), str(pkg_dir))
        cmd += "&& (cp %s/* %s/ || echo 1) " % (str(src_dir), str(pkg_dir))
        if tva_name:
            BuiltIn().log_to_console("I'll rename TVA file and change "
                                     "all necessary values inside of it")
            old_pkg_name = src_dir.split("/")[-1]
            new_pkg_name = pkg_dir.split("/")[-1]
            cmd += "&& mv %s/TVA_*.xml %s/%s " % (str(pkg_dir), str(pkg_dir), str(tva_name))
            cmd += "&& sed -i 's/%s/%s/' %s/%s " % (
                str(old_pkg_name), str(new_pkg_name), str(pkg_dir), str(tva_name))
            cmd += "&& rename %s %s %s/* " % (str(old_pkg_name), str(new_pkg_name), str(pkg_dir))
        cmd += ("&& ls -ltr %s/TVA_*.xml | awk '{if(NR>1)print}' | awk '{print $NF}'"
                " | xargs rm -f") % str(pkg_dir)
        BuiltIn().log_to_console("Command: %s" % cmd)
        # make dir in the watch folder, put a lock file inside and copy package files
        out, error = self.tools.run_ssh_cmd(*(ssh + [cmd]))
        print(out)
        if error and "omitting directory" not in error:
            self.tools.run_ssh_cmd(*(ssh + ["rm -rf %s" % pkg_dir]))
            self.log_variables(self.run_ssh_commands_for_no_og_ingestion, locals())
            raise Exception("Could not prepare a package folder inside the watch folder. Error: %s" % error)
        self.log_variables(self.run_ssh_commands_for_no_og_ingestion, locals())
        return out

    @easy_debug
    def get_no_og_watch_folder_path(self, folder=None):
        """Sub-method of create_no_og_package method to return default or custom watch_folder path

        :param folder: path to watch folder , string
        :return: watch_folder_path, string
        """
        if folder is None:
            watch_folder_path = self.conf["AIRFLOW_WORKERS"][0]["watch_folder"]
        else:
            watch_folder_path = folder
        self.log_variables(self.get_no_og_watch_folder_path, locals())
        return watch_folder_path

    @easy_debug
    def get_no_og_package_name(self, offer_id="Random"):
        """Sub-method of create_no_og_package method to return random or particular package name

        :param offer_id: custom package name, string
        :return: random or custom page name, string
        """
        if str(offer_id) == "Random":
            package_name = datetime.datetime.now().strftime(
                '%Y_%m_%d-%H_%M_%S-%f')  # unique identifier
        else:
            package_name = offer_id
        self.log_variables(self.get_no_og_package_name, locals())
        return package_name

    @easy_debug
    def read_tva(self, path, fname=""):
        """Method reads TVA xml file on the remote host (Airflow worker).

        :param path: an absolute path to the folder containing TVA xml file(s).
        :param fname: a TVA file name, not necessary if TVA_*.xml is the only xml in the folder.

        :return: TVA file contents loaded into a dictionary.
        """
        ssh = [self.conf["AIRFLOW_WORKERS"][0]["host"], self.conf["AIRFLOW_WORKERS"][0]["port"],
               self.conf["AIRFLOW_WORKERS"][0]["user"], self.conf["AIRFLOW_WORKERS"][0]["password"]]
        command = "cat %s/%s" % (path, fname or "TVA_*.xml")
        stdout, stderr = self.tools.run_ssh_cmd(*(ssh + [command]))
        # BuiltIn().log_to_console("Done: %s.\nReturned stdout: %s\nReturned stderr:\n%s\n" % (command, stdout, stderr))
        if stderr:
            self.log_variables(self.read_tva, locals())
            return [stderr]
        json_str = json.dumps(xmltodict.parse(stdout), sort_keys=True, indent=4)
        result = json.loads(json_str)
        self.log_variables(self.read_tva, locals())
        return result

    @easy_debug
    def generate_offer(
            self, sample_id="ts0000", bad_metadata=None,
            file_override="", pattern=None, movie_type=None,
            package_copy_name=None, unique_title_id=None, new_licensing_window_end=None):
        """A method generates an offer id and packages of the desired type for the selected lab.
        Using the offer id (e.g. 1503955941.44), a command like:
            /usr/local/bin/makeadi e2esi ts0000 testrunid="1503955941.44"
        or (optionally, to override a movie file with the one from /data/TestData folder):
            /usr/local/bin/makeadi e2esi ts0000 /data/TestData/<file>.ts testrunid="1503955941.44"
        is executed on the package generator host (172.30.218.244, see E2E_CONF in conf.py).
        The stderr output text returned by the generator script is searched for a line like:
        INFO: Writing /var/tmp/adi-auto-deploy/LAB/1001-ts0000_20170828_133102pt-0-0_Package/ADI.XML
        and a package id (e.g. ts0000_20170828_133102pt) is parsed from this line using pattern.
        The method sets the identifiers as "offer_id" and "packages" properties correspondingly.

        :param sample_id: an identifier of the sample to be used by the offer generator script.
        .. note:: the generator script is located at 172.30.218.244:/opt/makeadi/bin/makeadi.pl.
        :param bad_metadata: an optional dictionary to spoil ADI.XML (for negative test cases).
        .. note:: find sample of bad_metadata in the docstring for _spoil_adi() method;
        .. note:: if an offer has multiple packages, bad_metadata will be applied to all of them.
        :param file_override: an absolute path to the *.ts file a movie should be replaced with.
        .. note:: an empty string value (default) will not do any replacements.
        :param pattern: a regular expression string to find all package identifiers in text.
        .. note:: if pattern=None, default value "ts[0-9]{4}_[0-9]{8}_[0-9]{6}pt" will be used.

        :return: self instance.

        :Example:

        >>>fname = "00-25-07_3751kbs_mpeg2video_704x576_4x3_25fps_mp2_NOSUB.Joban_Rosszban.ts"
        >>>e2e_obj.generate_offer("ts0000", file_override="/data/TestData/%s" % fname).offer_id
        '1503955941.44'
        >>>e2e_obj.packages
        {'ts0000_20170828_133102pt': {}, 'ts0000_20170828_133114pt': {}}
        >>>e2e_obj.packages["ts0000_20170828_133102pt"]["adi"]
        /var/tmp/adi-auto-deploy/E2ESI/1001-ts0000_20170828_133102pt-0-0_Package/ADI.XML
        """

        time_stamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        BuiltIn().log_to_console("\nStarting to generate offer for %s at %s" %
                                 (sample_id, time_stamp))

        self.error = ""
        pattern = pattern or "ts[0-9]{4}_[0-9]{8}_[0-9]{6}[0-9\-]{0,3}pt[0-9]{0,2}"

        self.offer_id = self.generate_offer_id_based_on_time_stamp()

        stderr = self.run_command_to_generate_offer(
            file_override, movie_type, sample_id, time_stamp, package_copy_name,
            unique_title_id, new_licensing_window_end, bad_metadata)

        if movie_type or \
                package_copy_name or \
                unique_title_id or \
                new_licensing_window_end or \
                bad_metadata:
            package_adi_writing_line = "Package-HOLD/ADI.XML"
            offer_adi_writing_line = "Offer-HOLD/ADI.XML"
        else:
            package_adi_writing_line = "Package/ADI.XML"
            offer_adi_writing_line = "Offer/ADI.XML"

        if package_adi_writing_line in stderr:
            # for line in stderr.split("\n"):
            path_to_package_adi_list = self.get_path_to_adi_file(package_adi_writing_line, sample_id, stderr)

            if path_to_package_adi_list:
                for path_to_adi in path_to_package_adi_list:
                    if bad_metadata:
                        self._spoil_adi(path_to_adi, bad_metadata)

                    package = self.define_package_name_and_structure(movie_type, path_to_adi, pattern,
                                                                     sample_id)
                    if movie_type:
                        if str(movie_type) == "ott":
                            self.block_movie_type_ingestion_in_adi_file(path_to_adi, "stb")
                        elif str(movie_type) == "stb":
                            self.block_movie_type_ingestion_in_adi_file(path_to_adi, "ott")
                        elif str(movie_type) == "4k_stb" or str(movie_type) == "4K_STB":
                            self.block_movie_type_ingestion_in_adi_file(path_to_adi, "4k_stb")
                        elif str(movie_type) == "4k_ott" or str(movie_type) == "4K_OTT":
                            self.block_movie_type_ingestion_in_adi_file(path_to_adi, "4k_ott")

                    if unique_title_id:
                        self.set_unique_title_id_in_package_adi(path_to_adi, unique_title_id)
            else:
                message = "We wasn't able to determinate path to \"Package\" ADI.XML file " \
                          "from 'makeadi' output. "
                BuiltIn().log_to_console(message)
                self.error = message

            if movie_type \
                    or package_copy_name \
                    or unique_title_id \
                    or new_licensing_window_end \
                    or bad_metadata:
                path_to_offer_adi_list = self.get_path_to_adi_file(
                    offer_adi_writing_line, sample_id, stderr)
                if path_to_offer_adi_list:
                    path_to_all_adi_list = path_to_package_adi_list + path_to_offer_adi_list
                    for path_to_adi in path_to_all_adi_list:
                        if unique_title_id:
                            self.set_title_value_in_package_adi(path_to_adi, unique_title_id)
                        if new_licensing_window_end:
                            self.set_new_licensing_window_end_in_package_adi(
                                path_to_adi, new_licensing_window_end)
                else:
                    message = "We wasn't able to determinate path to \"Offer\" ADI.XML file " \
                              "from 'makeadi' output. "
                    BuiltIn().log_to_console(message)
                    self.error += message

                if package_copy_name:
                    self.make_package_copy(package, package_copy_name)

                self.unhold_package_and_offer(package)

        else:
            BuiltIn().log_to_console("Sample: %s: \"%s\" line was not fount in output "
                                     "of \"makeadi\" tool =(" % (sample_id, package_adi_writing_line))
            self_error = self.error = stderr

        if not self.error:
            BuiltIn().log_to_console(
                "Sample: %s: set self.offer_id = %s\nSet self.packages = %s" %
                (sample_id, self.offer_id, self.packages))
            BuiltIn().log_to_console("_" * 78)
            BuiltIn().log(vars(self))
        else:
            print(self_error)

        self.log_variables(self.generate_offer, locals())
        return self

    @easy_debug
    def set_unique_title_id_in_package_adi(
            self, path_to_adi, unique_title_id, server="ASSET_GENERATOR"):
        """Method to set Unique_Title_Id what can be used to link few asets with same ID

        :param path_to_adi: an absolute path to ADI.XML written by generator script.
        :param unique_title_id: any value what can be used to link few asets with same ID
        :param server: remote server name from conf file, like OG, ASSET_GENERATOR, etc
        """
        if server == "OG":
            server_creds = self.conf[server][0]
        else:
            server_creds = self.conf[server]
        ssh_creds = [server_creds["host"], server_creds["port"],
                     server_creds["user"], server_creds["password"]]
        xml_str = self.tools.ssh_read_file(*(ssh_creds + [path_to_adi]))
        xml_bytes = xml_str.encode("UTF-8")
        BuiltIn().log_to_console("\nI'm going to set '%s' Unique_Title_Id in adi file %s" %
                                 (unique_title_id, path_to_adi))
        # BuiltIn().log_to_console("Old content of the adi file is:\n\n%s\n" % xml_str)
        xml = etree.fromstring(xml_bytes)
        asset_node = xml.find("Asset")
        metadata = asset_node.find("Metadata")
        ams = metadata[0]
        asset_class = ams.get("Asset_Class")
        if asset_class == "title":
            new_app_data = etree.Element("App_Data", App="MOD", Name="Unique_Title_Id",
                                         Value=unique_title_id)
            # new_app_data_string = etree.tostring(new_app_data)
            # BuiltIn().log_to_console(new_app_data_string)
            metadata.append(new_app_data)
        else:
            self.log_variables(self.set_unique_title_id_in_package_adi,
                               locals())
            raise Exception("ADI.XML parsing error in 'set_unique_title_id_in_package_adi' method")

        xml_str_to_write = etree.tostring(xml, encoding="UTF-8", pretty_print=True)
        self.tools.ssh_write_file(*(ssh_creds + [path_to_adi, xml_str_to_write]))
        BuiltIn().log_to_console("ADI.xml file was successfully modified")
        # BuiltIn().log_to_console("New content is:\n\n%s\n" % xml_str)
        self.log_variables(self.set_unique_title_id_in_package_adi,
                           locals())
        return xml_str_to_write

    @easy_debug
    def set_title_value_in_package_adi(
            self, path_to_adi, title_value, server="ASSET_GENERATOR"):
        """Method to set value of "Title" attribute in ADI.XML file

        :param path_to_adi: an absolute path to ADI.XML written by generator script.
        :param title_value: value of title attribute, string
        :param server: remote server name from conf file, like OG, ASSET_GENERATOR, etc
        """
        if server == "OG":
            server_creds = self.conf[server][0]
        else:
            server_creds = self.conf[server]
        ssh_creds = [server_creds["host"], server_creds["port"],
                     server_creds["user"], server_creds["password"]]
        xml_str = self.tools.ssh_read_file(*(ssh_creds + [path_to_adi]))
        xml_bytes = xml_str.encode("UTF-8")
        BuiltIn().log_to_console("\nI'm going to set '%s' Title value in adi file %s" %
                                 (title_value, path_to_adi))
        # BuiltIn().log_to_console("Old content of the adi file is:\n\n%s\n" % xml_str)
        xml = etree.fromstring(xml_bytes)
        asset_node = xml.find("Asset")
        metadata = asset_node.find("Metadata")
        ams = metadata[0]
        asset_class = ams.get("Asset_Class")
        if asset_class == "title":
            modified = False
            for element in metadata:
                atributes = list(element.keys())
                if "App" in atributes:
                    if element.get("Name") == 'Title':
                        # BuiltIn().log_to_console(etree.tostring(element))
                        element.attrib["Value"] = title_value
                        # BuiltIn().log_to_console(etree.tostring(element))
                        modified = True
            if not modified:
                self.log_variables(self.set_title_value_in_package_adi, locals())
                raise Exception(
                    "ADI.XML modification issue in 'set_title_value_in_package_adi' method")

        else:
            self.log_variables(self.set_title_value_in_package_adi, locals())
            raise Exception("ADI.XML parsing error in 'set_title_value_in_package_adi' method")

        xml_str_to_write = etree.tostring(xml, encoding="UTF-8", pretty_print=True)
        self.tools.ssh_write_file(*(ssh_creds + [path_to_adi, xml_str_to_write]))
        BuiltIn().log_to_console("ADI.xml file was successfully modified")
        # BuiltIn().log_to_console("New content is:\n\n%s\n" % xml_str)
        self.log_variables(self.set_title_value_in_package_adi,
                           locals())
        return xml_str_to_write

    @easy_debug
    def set_new_licensing_window_end_in_package_adi(
            self, path_to_adi, new_licensing_window_end, server="ASSET_GENERATOR"):
        """Method to set value of "Licensing_Window_End" attribute in ADI.XML file
        to expire the package

        :param path_to_adi: an absolute path to ADI.XML written by generator script.
        :param new_licensing_window_end: value of "Licensing_Window_End" attribute, string
        :param server: remote server name from conf file, like OG, ASSET_GENERATOR, etc
        """
        if server == "OG":
            server_creds = self.conf[server][0]
        else:
            server_creds = self.conf[server]
        ssh_creds = [server_creds["host"], server_creds["port"],
                     server_creds["user"], server_creds["password"]]
        xml_str = self.tools.ssh_read_file(*(ssh_creds + [path_to_adi]))
        # BuiltIn().log_to_console("Old content of the adi file is:\n\n%s\n" % xml_str)
        xml_bytes = xml_str.encode("UTF-8")
        xml = etree.fromstring(xml_bytes)
        asset_node = xml.find("Asset")
        metadata = asset_node.find("Metadata")
        ams = metadata[0]
        asset_class = ams.get("Asset_Class")
        if asset_class == "title":
            l_w_e_modified = False
            d_i_modified = False
            for element in metadata:
                atributes = list(element.keys())
                if "App" in atributes:
                    if element.get("Name") == 'Licensing_Window_End':
                        BuiltIn().log_to_console(
                            "\nI'm going to set '%s' value of 'Licensing_Window_End' "
                            "attribute in adi file %s" % (new_licensing_window_end, path_to_adi)
                        )
                        # BuiltIn().log_to_console(etree.tostring(element))
                        element.attrib["Value"] = new_licensing_window_end
                        # BuiltIn().log_to_console(etree.tostring(element))
                        l_w_e_modified = True
                    if element.get("Name") == 'Display_Item':
                        # BuiltIn().log_to_console(etree.tostring(element))
                        display_item_value = element.get("Value")
                        tmp_list = display_item_value.split("::")
                        tmp_list[-2] = new_licensing_window_end
                        display_item_new_value = "::".join(tmp_list)
                        BuiltIn().log_to_console(
                            "\nI'm going to set '%s' value of 'Display_Item' "
                            "attribute in adi file %s" % (display_item_new_value, path_to_adi)
                        )
                        element.attrib["Value"] = display_item_new_value
                        # BuiltIn().log_to_console(etree.tostring(element))
                        d_i_modified = True
            if not l_w_e_modified or not d_i_modified:
                self.log_variables(
                    self.set_new_licensing_window_end_in_package_adi, locals())
                raise Exception(
                    "ADI.XML modification issue in "
                    "'set_new_licensing_window_end_in_package_adi' method")
        else:
            self.log_variables(
                self.set_new_licensing_window_end_in_package_adi, locals())
            raise Exception("ADI.XML parsing error in "
                            "'set_new_licensing_window_end_in_package_adi' method")
        xml_str_to_write = etree.tostring(xml, encoding="UTF-8", pretty_print=True)
        self.tools.ssh_write_file(*(ssh_creds + [path_to_adi, xml_str_to_write]))
        BuiltIn().log_to_console("ADI.xml file was successfully modified")
        # BuiltIn().log_to_console("New content is:\n\n%s\n" % xml_str)
        self.log_variables(self.set_new_licensing_window_end_in_package_adi,
                           locals())
        return xml_str_to_write

    @easy_debug
    def define_package_name_and_structure(self, movie_type, path_to_adi, pattern, sample_id):
        """A method to get package name from path to ADI.XML file and define package structure

        :param movie_type: type of the movie, string or None
        :param path_to_adi: path to ADI.XML file
        :param pattern: regex pattern
        :param sample_id: id of the sample, as ts000
        :return: name of the package, string
        """

        package_name = re.findall(pattern, path_to_adi)[0]
        package_name = package_name.replace("1001-", "") if package_name.startswith("1001-") \
            else package_name
        package_name = package_name.replace("-0-0", "") if package_name.endswith("-0-0") \
            else package_name
        print(("Sample: %s: parsed package name '%s' from path_to_adi: %s" %
               (sample_id, package_name, path_to_adi)))
        if package_name not in list(self.packages.keys()):
            # Temporary workaround for SVOD test case - skip 2 packages
            if package_name not in ["DelayTV_Free_SVod_Entry", "Digitale_TV_Starter"]:
                pkg_struct = {"adi": path_to_adi, "fabrix_asset_id": "", "properties": {},
                              "tva": "", "output_tva": "", "airflow_workers_logs_masks": [],
                              "transcoder_workers_logs_masks": [], "errors": [],
                              "movie_type": str(movie_type), "actual_dag": ""}
                self.packages.update({package_name: pkg_struct})
                self_packages = self.packages
                print(self_packages)
        self.log_variables(self.define_package_name_and_structure, locals())
        return package_name

    @easy_debug
    def get_path_to_adi_file(self, adi_file_writing_line, sample_id, makeadi_output):
        """A method to parse output from 'makeadi' command and get path to ADI.XML file

        :param adi_file_writing_line: line to find in output from 'makeadi' command
        :param sample_id: id of the sample, as ts000
        :param makeadi_output: output from 'makeadi' command
        :return: path to ADI.XML file, string
        """

        path_to_adi_list = []
        for line in makeadi_output.split("\n"):
            line = line.strip()
            if line.endswith(adi_file_writing_line):
                path_to_adi = line.split(" ")[2]
                if path_to_adi not in path_to_adi_list:
                    BuiltIn().log_to_console("Sample: %s: generated ADI - %s:%s" %
                                             (sample_id, self.conf["ASSET_GENERATOR"]["host"],
                                              path_to_adi))
                    path_to_adi_list.append(path_to_adi)
        self.log_variables(self.get_path_to_adi_file, locals())
        return path_to_adi_list

    @easy_debug
    def run_command_to_generate_offer(
            self, file_override, movie_type, sample_id,
            time_stamp, package_copy_name, unique_title_id, new_licensing_window_end, bad_metadata):
        """A method to run 'makeadi' command to generate the offer
        :return: command output (stderr)
        """

        if movie_type \
                or package_copy_name \
                or unique_title_id \
                or new_licensing_window_end \
                or bad_metadata:
            command = "/usr/local/bin/makeadi %s %s HOLD " \
                      "%s testrunid='%s'" % (self.lab_name, sample_id, file_override, self.offer_id)
        else:
            command = "/usr/local/bin/makeadi " \
                      "%s %s %s testrunid='%s'" % (self.lab_name, sample_id,
                                                   file_override, self.offer_id)
        stdout, stderr = self.tools.run_ssh_cmd(self.conf["ASSET_GENERATOR"]["host"],
                                                self.conf["ASSET_GENERATOR"]["port"],
                                                self.conf["ASSET_GENERATOR"]["user"],
                                                self.conf["ASSET_GENERATOR"]["password"],
                                                command)
        stderr_to_log = stderr
        BuiltIn().log_to_console("+" * 78)
        BuiltIn().log_to_console("Command: %s.\nReturned stdout: %s\nReturned stderr:\n%s\n" %
                                 (command, stdout, stderr_to_log))
        BuiltIn().log_to_console("\nFinished to generate offer for %s at %s" %
                                 (sample_id, time_stamp))
        BuiltIn().log_to_console(("+" * 78) + "\n")
        self.log_variables(self.run_command_to_generate_offer, locals())
        return stderr

    @easy_debug
    def generate_offer_id_based_on_time_stamp(self):
        """A method to generate unique offer id based on timestamp

        :return: unique id of the offer, string
        """
        timestamp = "%s" % (datetime.datetime.now() - datetime.datetime(1970, 1, 1)).total_seconds()
        self_offer_id = timestamp[:timestamp.find(".") + 3]
        self.log_variables(self.generate_offer_id_based_on_time_stamp, locals())
        return self_offer_id

    @easy_debug
    def get_offer_folder_name_from_asset_generator_host(self, package, environment="obocsi"):
        """A method to get offer folder name from asset generator host

        :param package: package name, string.
        :param environment: lab name, string

        :return: folder name, string
        """
        command = "ls -l %s/%s | grep %s | awk '{print $9}'" % (
            self.conf["ASSET_GENERATOR"]["path"], environment, package.replace("pt", ""))
        stdout, stderr = self.tools.run_ssh_cmd(self.conf["ASSET_GENERATOR"]["host"],
                                                self.conf["ASSET_GENERATOR"]["port"],
                                                self.conf["ASSET_GENERATOR"]["user"],
                                                self.conf["ASSET_GENERATOR"]["password"],
                                                command)
        print(stderr)
        offer_folder = None
        for folder in stdout.split("\n"):
            if "Offer" in folder:
                offer_folder = folder
        self.log_variables(self.get_offer_folder_name_from_asset_generator_host, locals())
        return offer_folder

    @easy_debug
    def get_package_folder_name_from_asset_generator_host(self, package, environment="obocsi"):
        """A method to get package folder name from asset generator host

        :param package: package name, string.
        :param environment: lab name, string

        :return: folder name, string
        """
        command = "ls -l %s/%s | grep %s | awk '{print $9}'" % (
            self.conf["ASSET_GENERATOR"]["path"], environment, package.replace("pt", ""))
        stdout, stderr = self.tools.run_ssh_cmd(self.conf["ASSET_GENERATOR"]["host"],
                                                self.conf["ASSET_GENERATOR"]["port"],
                                                self.conf["ASSET_GENERATOR"]["user"],
                                                self.conf["ASSET_GENERATOR"]["password"],
                                                command)
        print(stderr)
        package_folder = None
        for folder in stdout.split("\n"):
            if "Package" in folder:
                package_folder = folder
        self.log_variables(self.get_package_folder_name_from_asset_generator_host, locals())
        return package_folder

    @easy_debug
    def get_export_adi_name_from_offer_generator_host(self, package, path_to_adi):
        """A method to get package folder name from offer generator host

        :param package: package name, string.
        :param path_to_adi: path to ADI.XML on Asset generator host what was created
                            rigt after makeadi command

        :return: folder name, string
        """
        provider = self.get_provider_from_adi_file(path_to_adi)
        export_adi_folder = self.conf["OG"][0]["export_adi"]
        package_pattern = package.replace("pt", "")
        command = "ls -l %s/%s/ | grep %s | awk '{print $9}'" % (
            export_adi_folder, provider, package_pattern)
        stdout, stderr = self.tools.run_ssh_cmd(self.conf["OG"][0]["host"],
                                                self.conf["OG"][0]["port"],
                                                self.conf["OG"][0]["user"],
                                                self.conf["OG"][0]["password"],
                                                command)
        print(stderr)
        output_list = stdout.split("\n")
        export_adi_name = None
        if len(output_list) > 1:
            for entry in output_list:
                if ".xml" in entry:
                    export_adi_name = entry
                    break
        else:
            export_adi_name = stdout
        self.log_variables(
            self.get_export_adi_name_from_offer_generator_host, locals())
        return export_adi_name, provider

    @easy_debug
    def get_provider_from_adi_file(self, path_to_adi):
        """Method to get provider name from ADI.xml file

        :param path_to_adi: path to ADI.XML on Asset generator host what was created
                            rigt after makeadi command
        :return: provider name, string
        """
        package = path_to_adi.split("/")[-2]
        # Could be a case when path was modifyed with "-Done" like:
        # /var/tmp/adi-auto-deploy/obocsi/1001-ts0000_20200122_013141pt-0-0_Package-Done/ADI.XML
        path_to_adi = path_to_adi.replace(package, package + "*")
        command = "cat %s  | grep 'Provider='" % path_to_adi
        stdout, stderr = self.tools.run_ssh_cmd(self.conf["ASSET_GENERATOR"]["host"],
                                                self.conf["ASSET_GENERATOR"]["port"],
                                                self.conf["ASSET_GENERATOR"]["user"],
                                                self.conf["ASSET_GENERATOR"]["password"],
                                                command)
        if not stderr and stdout:
            for line in stdout.splitlines():
                providers = []
                provider = line.replace("Provider=", "").replace('"', '').strip()
                if provider not in providers:
                    providers.append(provider)
            if providers:
                if len(providers) == 1:
                    result = providers[0]
                else:
                    raise Exception("More then one provider was found in %s: %s" % (
                        path_to_adi, providers))
            else:
                self.log_variables(self.get_provider_from_adi_file, locals())
                raise Exception("Providers was not found in %s" % path_to_adi)
        else:
            self.log_variables(self.get_provider_from_adi_file, locals())
            raise Exception("Error when trying to get provider: %s. Stdout: %s" % (stderr, stdout))
        self.log_variables(self.get_provider_from_adi_file, locals())
        return result

    @easy_debug
    def unhold_package_and_offer(self, package, environment="obocsi"):
        """A method to remove "HOLD" from the package and offer directories to make ir autodeployed

        :param package: package name, string.
        :param environment: lab name, string
        """

        BuiltIn().log_to_console("\nI'm going to unhold package %s" % package)
        offer_folder_name = self.get_offer_folder_name_from_asset_generator_host(package,
                                                                                 environment)
        package_folder_name = self.get_package_folder_name_from_asset_generator_host(package,
                                                                                     environment)


        host = self.conf["ASSET_GENERATOR"]["host"]
        port = self.conf["ASSET_GENERATOR"]["port"]
        user = self.conf["ASSET_GENERATOR"]["user"]
        password = self.conf["ASSET_GENERATOR"]["password"]

        offer_command = "mv %s/%s/%s  %s/%s/%s" % (
            self.conf["ASSET_GENERATOR"]["path"], environment, offer_folder_name,
            self.conf["ASSET_GENERATOR"]["path"], environment, offer_folder_name.replace(
                "-HOLD", "")
        )
        package_command = "mv %s/%s/%s  %s/%s/%s" % (
            self.conf["ASSET_GENERATOR"]["path"], environment, package_folder_name,
            self.conf["ASSET_GENERATOR"]["path"], environment, package_folder_name.replace(
                "-HOLD", "")
        )
        command = "%s && %s" % (offer_command, package_command)
        stdout, stderr = self.tools.run_ssh_cmd(host, port, user, password, command)
        stdout_to_log = stdout
        stderr_to_log = stderr
        BuiltIn().log_to_console(
            "\n Unhold_package_and_offer command: %s\nStdout: %s\nStderr: %s\n" % (
                command, stdout_to_log, stderr_to_log))
        self.log_variables(self.unhold_package_and_offer, locals())
        return stdout

    @easy_debug
    def get_tva_filenames(self, tries=60, interval=30):
        """Offering generator gives metadata in ADI.XML which is later transformed to TVA xml.
        TVA*.xml file name contains timestamp so this file name uniquely defines
        what Airflow DAG has been executed for that package.
        A method iterates through all the packages and searches inside Airflow's watch folder
        to grab file names of the TVA*.xml files which contain the given testrunid value.
        The watch folder is monitored with retries until all TVA are found or all tries are used.
        In fact, the following command is executed on the first Airflow worker host:
            grep - r <testrunid> /mnt/nfs_watch/Countries/E2ESI/ToAirflow/*/TVA*.xml \
             | awk '{print $1;}'| grep <package_name> | uniq".
        The method works but it's not used since all tests have unique names, let's keep it though.

        :return: True if TVA*.xml were found for all packages, False otherwise.

        :Example:

        >>>e2e_obj.packages["ts0000_20170828_133102pt"]["tva"]
        'TVA_100000_20170927095046.xml'
        """
        i = 0
        while True:
            i += 1
            all_tva_found = True
            for package in list(self.packages.keys()):
                if "tva" not in self.packages[package]:
                    cmd = "grep -r '%s' %s/*/TVA*.xml | awk '{print $1;}' | grep %s | uniq" % \
                          (self.offer_id, self.conf["AIRFLOW_WORKERS"][0]["watch_folder"], package)
                    stdout = self.tools.run_ssh_cmd(self.conf["AIRFLOW_WORKERS"][0]["host"],
                                                    self.conf["AIRFLOW_WORKERS"][0]["port"],
                                                    self.conf["AIRFLOW_WORKERS"][0]["user"],
                                                    self.conf["AIRFLOW_WORKERS"][0]["password"],
                                                    cmd)[0]
                    if stdout.strip():
                        tva_filename = stdout.split(":")[0].split("/")[-1]
                        self.packages[package].update({"tva": tva_filename})
                        BuiltIn().log("Found TVA %s for package %s:" % (tva_filename, package))
                if "tva" not in self.packages[package]:
                    all_tva_found = False
            print(("In these packages dict, there should be a 'tva' key: %s" % self.packages))
            if (all_tva_found and self.packages) or i == tries:
                break
            # else:
            time.sleep(interval)
        self.log_variables(self.get_tva_filenames, locals())
        return all_tva_found

    @easy_debug
    def collect_log_files_masks(self, package, path=None, host=None, debug_message="",
                                look_for_subpackage=False):
        """A method collects absolute paths to the log files of both trigger- and workflow-DAGs,
        executed for the given package (each key of self.packages dictionary).
        Airflow's task names in those absolute paths are replaced with "*".
        The resulting list can contain up to 2 elements (always unique),
        and is set as a value for "airflow_workers_logs_masks" and "transcoder_workers_logs_masks"
        key for each package in self.packages.

        :return: self instance.

        :Example:

        >>>e2e_obj.packages["ts0000_20170828_133102pt"]["airflow_workers_logs_masks"]
        ['/usr/local/airflow/logs/create_obo_assets_transcoding_driven_workflow/*/\
        2017-09-12T08:21:40.708566',
        '/usr/local/airflow/logs/e2esi_lab_create_obo_assets_transcoding_driven_trigger/*/\
        2017-09-12T08:10:00']

        >>>e2e_obj.packages["ts0000_20170828_133102pt"]["transcoder_workers_logs_masks"]
        ['/usr/local/airflow/logs/csi_lab_create_obo_assets_transcoding_driven_workflow\
        /transcode_assets/2019-03-07T14:14:08',
        '/usr/local/airflow/logs/csi_lab_create_obo_assets_transcoding_driven_workflow\
        /transcode_assets/2017-09-12T08:10:00']
        """
        BuiltIn().log_to_console("\nSTART to collect log files masks (%s). Package %s =======>" %
                                 (debug_message, package))
        # logs_folder_to_ignore = ["csi_lab_create_obo_assets_workflow",
        #                          "create_obo_assets_workflow"]
        logs_folder_to_ignore = []
        entry = package
        # pattern fot a string like ts0014_20190620_222659pt10
        pattern = "ts[0-9]{4}_[0-9]{8}_[0-9]{6}[0-9\-]{0,3}[p,o]t[0-9]{0,2}"
        if re.match(pattern, package) and not look_for_subpackage:
            # to not to match package "ts0014_20190620_222659pt10" when looking for package ...
            # ...                     "ts0014_20190620_222659pt1" :
            grep_ignore_pattern = "%s[0-9]" % package
        else:
            grep_ignore_pattern = ""
        concurrency_and_priority_test = False
        concurrency_and_priority_pattern = "hanni-nanni-\d{14}"
        if re.match(concurrency_and_priority_pattern, package):
            concurrency_and_priority_test = True
        if concurrency_and_priority_test:
            entry = self.packages[package]["new_tva_name"]
        else:
            if "fabrix_asset_id" in list(self.packages[package].keys()):
                if self.packages[package]["fabrix_asset_id"]:
                    entry += "\|%s" % self.packages[package]["fabrix_asset_id"]
        # entry example:
        # ts0000_20190410_173408pt\|448f35c417e35d69aab8ceca12aa628a_3db98b518644918080e48343bdb644a1

        if host:
            log_hosts = [host]
        else:
            if "SINGLE_LOGS_HOST" in os.environ:
                if os.environ['SINGLE_LOGS_HOST'] == "True":
                    log_hosts = ["AIRFLOW_WORKERS"]
                else:
                    log_hosts = ["TRANSCODER_WORKERS", "AIRFLOW_WORKERS"]
            else:
                log_hosts = ["AIRFLOW_WORKERS"]
        for log_host in log_hosts:
            lines = []
            if log_host == "AIRFLOW_WORKERS":
                package_logs_masks_key = "airflow_workers_logs_masks"
            elif log_host == "TRANSCODER_WORKERS":
                package_logs_masks_key = "transcoder_workers_logs_masks"
            else:
                package_logs_masks_key = "airflow_workers_logs_masks"

            for cnf in self.conf[log_host]:
                if path is None:
                    date_today = datetime.datetime.now().strftime('%Y-%m-%d')
                    logs_path = "%s/*/*/%s*" % (cnf["logs_folder"], date_today)
                else:
                    logs_path = path
                result = []
                i = 0
                while len(result) < 2 and i < 10:
                    result = self.tools.grep_logs(
                        cnf["host"], cnf["port"], cnf["user"],
                        cnf["password"], "%s/*" % logs_path, entry,
                        grep_ignore_pattern=grep_ignore_pattern)
                    i += 1
                lines += result
                BuiltIn().log("Logs lines from %s (%s) host for package %s: \n%s" % (
                    log_host, cnf["host"], package, result))

            if len(lines) > 1:
                logs_masks = []
                for line in lines:
                    if line:
                        parts = line.split(":{")[0].split("/")
                        # parts[-2] = "*"
                        mask = "/".join(parts)
                        # remove everything after ".log"
                        mask = "".join(mask.partition(".log")[:-1])
                        if "/usr/local/airflow/logs" in mask:
                            # remove everything before "/usr/local/airflow/logs"
                            mask = "".join(mask.partition("/usr/local/airflow/logs")[1:])
                        if mask not in logs_masks:
                            logs_masks.append(mask)
                if not logs_masks:
                    BuiltIn().log_to_console("We didn't find \"%s\" for package %s "
                                             "in a lines of the logs =(\n" %
                                             (package_logs_masks_key, package))
                else:
                    BuiltIn().log_to_console("Done: \"%s\" was found for package %s\n" %
                                             (package_logs_masks_key, package))
                    for new_mask in logs_masks:
                        for ignored_logs_folder in logs_folder_to_ignore:
                            if "/%s/" % ignored_logs_folder in new_mask:
                                logs_masks.remove(new_mask)
                    for actual_logs_mask in logs_masks:
                        if not self.packages[package][package_logs_masks_key]:
                            self.packages[package].update(
                                {package_logs_masks_key: ["%s" % actual_logs_mask]})
                        else:
                            if actual_logs_mask not in \
                                self.packages[package][package_logs_masks_key]:
                                self.packages[package][package_logs_masks_key]\
                                    .append(actual_logs_mask)
            else:
                BuiltIn().log_to_console("We didn't find name of our package %s in a logs =(" %
                                         package)

        BuiltIn().log_to_console("\nAirflow workers logs masks: %s" %
                                 self.packages[package]["airflow_workers_logs_masks"])
        # BuiltIn().log_to_console("Transcoder workers logs masks: %s\n" %
        #                          self.packages[package]["transcoder_workers_logs_masks"])

        self_packages_package_package_logs_masks_key = \
            self.packages[package][package_logs_masks_key]
        print(self_packages_package_package_logs_masks_key)

        BuiltIn().log(vars(self))


        BuiltIn().log_to_console("\n<======= STOP to collect log files masks (%s). Package %s" %
                                 (debug_message, package))

        self.log_variables(self.collect_log_files_masks, locals())
        return self

    @easy_debug
    def collect_from_logs(self, package, entry, pipes="", particular_log=None,
                          logs_host="AIRFLOW_WORKERS"):
        """A method collects unique entries registered during trigger- and workflow- DAGs execution.
        This is done by analysing the content of log files of the DAGs' tasks, using file masks.
        File masks can be obtained by collect_log_files_masks() method.

        :param package: a package name.
        :param entry: a string to search for in the logs of both trigger- and workflow- DAGs.
        :param pipes: additional pipe(s) to be appended to the command, e.g. '| grep .. | tail -n 1'
        :param particular_log: single log to get log_record
        :param logs_host: host where we going analyze logs

        :return: a list of log-records containing the given entry.

        .. note :: The resulting list can be empty or contain unique elements.
        """
        if particular_log:
            logs_list = [particular_log]
        else:
            if logs_host == "AIRFLOW_WORKERS":
                logs_list = self.packages[package]["airflow_workers_logs_masks"]
            elif logs_host == "TRANSCODER_WORKERS":
                logs_list = self.packages[package]["transcoder_workers_logs_masks"]
            else:
                logs_list = []
        output = ""
        for mask in logs_list:
            command = "cat %s | grep '%s' | grep '%s' %s" % (mask, package, entry, pipes)
            for cnf in self.conf[logs_host]:
                stdout = self.tools.run_ssh_cmd(cnf["host"], cnf["port"],
                                                cnf["user"], cnf["password"], command)[0]
                output = "\n".join([output, stdout.strip()])
                #print("Done: %s.\nReturned stdout: %s\nReturned stderr:\n%s\n"
                #      % (command, stdout, stderr))
        items = []
        for line in output.strip().split("\n"):
            if line:
                item = line.split(entry)[1].strip()
                if item not in items:
                    items.append(item)
        self.log_variables(self.collect_from_logs, locals())
        return items

    @easy_debug
    def get_main_logs_time(self, package):  # pylint: disable=R1710
        """A method to get time stamp folder of all logs what we see in AirflowUI.
        This timestamp is used in log path.
        Like: .../need_to_ingest_movie_stb/2019-01-08T13:30:57/1.log

        :param package: a package name.

        :return: timestamp, string.

        """
        result = False
        command = "grep -r '%s' /usr/local/airflow/logs/*/check_assets |" \
                  " grep -Po '\d{4}\-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}' | sort -n | uniq" % package
        for cnf in self.conf["AIRFLOW_WORKERS"]:
            stdout = self.tools.run_ssh_cmd(cnf["host"], cnf["port"], cnf["user"], cnf["password"],
                                            command)[0]
            if stdout:
                BuiltIn().log_to_console("Main logs time is: %s" % stdout)
                result = True
                self.log_variables(self.get_main_logs_time, locals())
                return stdout

        if not result:
            self.log_variables(self.get_main_logs_time, locals())
            raise Exception("I can't find main logs time. The command is: %s" % command)

    @easy_debug
    def get_package_tva(self, package):
        """A method to determinate the name of package TVA file name

        :param package: a package name.

        :return: path and name of package's TVA file.

        """
        ssh = [self.conf["AIRFLOW_WORKERS"][0]["host"], self.conf["AIRFLOW_WORKERS"][0]["port"],
               self.conf["AIRFLOW_WORKERS"][0]["user"], self.conf["AIRFLOW_WORKERS"][0]["password"]]
        pkg_dir = "%s/*%s" % (self.conf["AIRFLOW_WORKERS"][0]["managed_folder"], package)
        cmd = "ls -ltr %s/TVA_*.xml | head -n 1 | awk -F '/' '{print $NF}'" % pkg_dir  # oldest TVA
        tva_fname, error = self.tools.run_ssh_cmd(*(ssh + [cmd]))
        if not (tva_fname.startswith("TVA_") and tva_fname.endswith(".xml")):
            BuiltIn().log_to_console("\n\n\nCould not get TVA file name %s\n\n\n" % error)
            result = ""
        else:
            result = "%s/%s" % (pkg_dir, tva_fname)
            BuiltIn().log_to_console("\nTVA is: %s\n" % result)
        self.log_variables(self.get_package_tva, locals())
        return result

    @easy_debug
    def check_dag_failed(self, package):
        """A method collects log files names of the Airflow's tasks executed for the given package -
        i.e. for each package identified by keys of self.packages dictionary.
        It is assumed, the DAG has failed if at least one its tasks has exited with non-zero code,
        i.e. the log file of any task contains an entry like:
            "Task exited with return code N" (where N != 0).
        In fact, commands like
            "grep -r 'ts0000_20170815_115252pt' /usr/local/airflow/logs/*", and
            "cat logs/create_obo_assets_transcoding_driven_workflow/check_assets/\
             2017-09-07T06:31:25.421397 | grep 'Task exited with return code' | grep -v 'code 0'"
        is executed through SSH on all Airflow worker hosts.

        :return: True if the DAG has failed, False otherwise (i.e. it has not fail - yet).

        .. note :: this method does not check whether the execution of the DAG is completed.

        :Example:

        >>># Here the DAG can be still in progress and can fail later:
        >>>e2e_obj.check_dag_failed("ts0000_20170828_133102pt")
        False
        """
        result = False  # Assume DAG is passed
        # Separately check failure_detector logs folder for yesterday

        if not self.packages[package]["actual_dag"]:
            self.get_actual_dag_name(self.packages[package]["airflow_workers_logs_masks"], package)

        logs_yesterday = self.generate_path_to_logs_dir_to_analyze(package, "yesterday")

        self.collect_log_files_masks(package=package, path=logs_yesterday,
                                     debug_message="check_dag_failed, yesterday")
        # Separately check failure_detector logs folder for today
        logs_today = self.generate_path_to_logs_dir_to_analyze(package, "today")
        self.collect_log_files_masks(package=package, path=logs_today,
                                     debug_message="check_dag_failed, today")

        if not self.packages[package]["actual_dag"]:
            self.get_actual_dag_name(self.packages[package]["airflow_workers_logs_masks"], package)

        if self.packages[package]["airflow_workers_logs_masks"]:
            if not self.packages[package]["tva"]:
                self.packages[package]["tva"] = self.get_package_tva(package)

            BuiltIn().log_to_console("Started to check logs by finned masks, to determinate, "
                                     "was DAG failed or not for package %s" % package)
            output = ""
            failed_messages = {} # Dict with "log_file": ["message", "message"] structure


            if "SINGLE_LOGS_HOST" in os.environ:
                if os.environ['SINGLE_LOGS_HOST'] == "True":
                    log_hosts = ["AIRFLOW_WORKERS"]
                else:
                    log_hosts = ["TRANSCODER_WORKERS", "AIRFLOW_WORKERS"]
            else:
                log_hosts = ["AIRFLOW_WORKERS"]
            for host in log_hosts:
                if host == "AIRFLOW_WORKERS":
                    package_logs_masks_key = "airflow_workers_logs_masks"
                elif host == "TRANSCODER_WORKERS":
                    package_logs_masks_key = "transcoder_workers_logs_masks"
                else:
                    package_logs_masks_key = "airflow_workers_logs_masks"

                for mask in self.packages[package][package_logs_masks_key]:
                    if self.packages[package]["actual_dag"]:
                        if self.packages[package]["actual_dag"] not in mask:
                            continue
                    command = "cat %s | grep 'Marking task as FAILED'" % mask
                    for cnf in self.conf[host]:
                        stdout, stderr = self.tools.run_ssh_cmd(
                            cnf["host"], cnf["port"], cnf["user"], cnf["password"], command)
                        if stdout:
                            output, failed_messages = self.get_dag_fail_reason(
                                cnf, failed_messages, mask, output, package)
                        if stderr:
                            print(stderr)

            if failed_messages:   # consider DAG has been failed
                result = True
                # concatenate failed_messages.values() sub-lists to one list of errors:
                self.packages[package]["errors"] = \
                    [item for sublist in list(failed_messages.values()) for item in sublist]
                BuiltIn().log_to_console(
                    "Dag IS FAILED =(. Package: %s . Log files: %s\nErrors:\n%s" %
                    (package, list(failed_messages.keys()), self.packages[package]["errors"]))
            else:
                BuiltIn().log_to_console("Done: DAG was NOT failed.\n")
        else:
            BuiltIn().log_to_console("We didn't find package %s mention in Airflow logs "
                                     "(/usr/local/airflow/logs/*) yet =(" % package)
        self.log_variables(self.check_dag_failed, locals())
        return result

    @easy_debug
    def get_dag_fail_reason(self, cnf, failed_messages, mask, output, package):
        """Sub-method of check_dag_failed to grep errors from logs what was the reason of DAG fail"""
        updated_failed_messages = failed_messages
        entry = "ERROR "
        command = "cat %s | grep '%s'" % (mask, entry)
        stdout, stderr = self.tools.run_ssh_cmd(
            cnf["host"], cnf["port"], cnf["user"], cnf["password"], command)
        print(stderr)
        updated_output = "\n".join([output, stdout.strip()])
        for line in updated_output.strip().split("\n"):
            if str(line):
                item = str(line.split(entry)[1].strip().split("- ")[1])
                list_of_all_fail_messages = [
                    value for sublist in list(updated_failed_messages.values()) for value in sublist]
                if item not in list_of_all_fail_messages:
                    if "File found in failed folder" in item:  # pylint: disable=no-else-continue
                        # Ignore for now
                        continue
                        # uncomment when will be necessary
                        # pattern = "(?!\/failed\/)(TVA_\d{6}_\d{14})"
                        # failed_tva_name = \
                        # '%s.xml' % re.findall(pattern, item)[0]
                        # if failed_tva_name in self.packages[package]["tva"]:
                        #     if mask not in failed_messages.keys():
                        #         failed_messages[mask] = []
                        #     failed_messages[mask].append(item)
                    elif "files were marked as failed" in item:
                        continue
                    elif "File not found after retry: TVA_" in item \
                        and self.packages[package]["tva"].split("/")[-1] not in item:
                        continue
                    else:
                        if mask not in list(updated_failed_messages.keys()):
                            updated_failed_messages[mask] = []
                        updated_failed_messages[mask].append(item)
        self.log_variables(self.get_dag_fail_reason, locals())
        return updated_output, updated_failed_messages

    @easy_debug
    def check_asset_failed(self, package):
        """A method collects log file name of the Airflow's
        lookup_dir task executed for the given package -
        i.e. for each package identified by keys of self.packages dictionary.
        It is assumed, the asset has failed if lookup_dir tasks has such message:
            "move_assets_to_failed"
        In fact, commands like
            "/usr/local/airflow/logs/csi_lab_create_obo_assets_trigger/lookup_dir/2018-11-28*", and
            "cat /usr/local/airflow/logs/csi_lab_create_obo_assets_trigger/\
            lookup_dir/2018-11-28T09:04:00/1.log \
             | grep 'move_assets_to_failed'"
        is executed through SSH on all Airflow worker hosts.

        :return: True if the asset has failed, False otherwise .

        :Example:

        >>>e2e_obj.check_asset_failed("ts0000_20170828_133102pt")
        False
        """
        result = False  # Assume asset is passed

        logs_dir = self.generate_path_to_logs_dir_to_analyze(package, "today", "lookup_dir")

        self.collect_log_files_masks(package=package, path=logs_dir, host="AIRFLOW_WORKERS",
                                     debug_message="check_asset_failed, lookup_dir, today")


        if self.packages[package]["airflow_workers_logs_masks"]:
            self_packages_package_airflow_workers_logs_masks = \
                self.packages[package]["airflow_workers_logs_masks"]
            print(self_packages_package_airflow_workers_logs_masks)
            BuiltIn().log_to_console("Started to check logs by finned masks, to determinate, "
                                     "was asset failed or not")
            output = ""
            failed_messages = {} # Dict with "log_file": ["message", "message"] structure

            for mask in self.packages[package]["airflow_workers_logs_masks"]:
                if self.packages[package]["actual_dag"]:
                    if self.packages[package]["actual_dag"] not in mask:
                        continue
                command = "cat %s | grep 'move_assets_to_failed'" % mask
                for cnf in self.conf["AIRFLOW_WORKERS"]:
                    stdout, stderr = self.tools.run_ssh_cmd(
                        cnf["host"], cnf["port"], cnf["user"], cnf["password"], command)
                    if stdout:
                        output, failed_messages = self.get_asset_fail_reason(
                            cnf, failed_messages, mask, output, package)
                    if stderr:
                        print(stderr)

            if failed_messages:   # consider DAG has failed
                result = True
                # concatenate failed_messages.values() sub-lists to one list of errors:
                self.packages[package]["errors"] = \
                    [warning_log_line for sublist in list(failed_messages.values())
                     for warning_log_line in sublist]
                BuiltIn().log_to_console(
                    "Asset IS FAILED =(. Package: %s . Log files: %s\nErrors:\n%s" %
                    (package, list(failed_messages.keys()), self.packages[package]["errors"]))
            else:
                BuiltIn().log_to_console("Done: Asset was NOT failed.\n")
        else:
            BuiltIn().log_to_console("We didn't find package %s mention in lookup_dir logs "
                                     "(grep -r '%s' %s) yet =(" % (package, package, logs_dir))

        self.log_variables(self.check_asset_failed, locals())
        return result

    @easy_debug
    def get_asset_fail_reason(self, cnf, failed_messages, mask, output, package):
        """Sub-method of check_asset_failed to grep errors from logs what was the reason of DAG fail"""
        updated_failed_messages = failed_messages
        entry = "WARNING -"
        command = "cat %s | grep '%s'" % (mask, entry)
        stdout, stderr = self.tools.run_ssh_cmd(
            cnf["host"], cnf["port"], cnf["user"], cnf["password"], command)
        print(stderr)
        updated_output = "\n".join([output, stdout.strip()])
        for line in updated_output.strip().split("\n"):
            if line:
                warning_log_line = line.split(entry)[1].strip()
                if package in warning_log_line:
                    if mask not in list(updated_failed_messages.keys()):
                        updated_failed_messages[mask] = []
                    if warning_log_line not in updated_failed_messages[mask]:
                        updated_failed_messages[mask].append(warning_log_line)
        self.log_variables(self.get_asset_fail_reason, locals())
        return updated_output, updated_failed_messages

    @easy_debug
    def generate_path_to_logs_dir_to_analyze(self, package, date="today", directory=None):
        """Method to generate path to logs folders based on date, actual dag, and provided
        particular directory  what will be used for collect_log_files_masks method

        :param package: package name, string
        :param date: "today" or "yesterday", string
        :param directory: particular directory, string
        :return: path to logs directories to analyze
        """
        date_yesterday = (datetime.datetime.now() + datetime.timedelta(days=-1)).strftime('%Y-%m-%d')
        date_today = datetime.datetime.now().strftime('%Y-%m-%d')

        if self.packages[package]["actual_dag"]:
            actual_dag = self.packages[package]["actual_dag"]
        else:
            actual_dag = "*"

        if directory:
            log_dir = directory
        else:
            log_dir = "*"

        if date == "today":
            logs_dir = "/usr/local/airflow/logs/%s/%s/%s*" % (actual_dag, log_dir, date_today)
        elif date == "yesterday":
            logs_dir = "/usr/local/airflow/logs/%s/%s/%s*" % (actual_dag, log_dir, date_yesterday)
        else:
            raise Exception("Unexpected date %s")
        return logs_dir

    @easy_debug
    def check_ingestion_started(self, package):
        """ A method to check if ingestion is started for the package by greping the logs in lookup directory

        :param package: dict

        :return: True if the ingestion is started, False otherwise.
        """
        result = False  # Assume ingestion is not started

        logs_yesterday = self.generate_path_to_logs_dir_to_analyze(package, "yesterday", "lookup_dir")
        logs_today = self.generate_path_to_logs_dir_to_analyze(package, "today", "lookup_dir")
        self.collect_log_files_masks(package=package, path=logs_yesterday, host="AIRFLOW_WORKERS",
                                     debug_message="check_ingestion_started, lookup_dir, yesterday")
        if self.packages[package]["airflow_workers_logs_masks"]:
            self.log_variables(self.check_ingestion_started, locals())
            return True
        self.collect_log_files_masks(package=package, path=logs_today, host="AIRFLOW_WORKERS",
                                     debug_message="check_ingestion_started, lookup_dir, today")
        if self.packages[package]["airflow_workers_logs_masks"]:
            result = True
        self.log_variables(self.check_ingestion_started, locals())
        return result

    @easy_debug
    def get_log_data(self, logfile_path, split_lines=True, host="AIRFLOW_WORKERS"):
        """A method to get the log file data from the airflow workers

        :param logfile_path: absolute path to output file to get data
        :param split_lines: Bool type, default True
        :return: list/string type based on the split_lines flag
        """

        cmd = "cat %s" % logfile_path
        # DEBUG
        # cmd = "cat /usr/local/airflow/logs/csi_lab_create_obo_assets_workflow/generate_tva_file/2019-04-10T21:56:29/1.log"
        if split_lines:
            result = []
        else:
            result = ""

        for cnf in self.conf[host]:

            stdout = self.tools.run_ssh_cmd(cnf["host"], cnf["port"],
                                            cnf["user"], cnf["password"], cmd)[0]
            if stdout:
                if split_lines:
                    result = stdout.splitlines()
                else:
                    result = stdout
                return result
        self.log_variables(self.get_log_data, locals())
        raise Exception("Log file is *NOT* present on the '%s' servers for the path %s" % (host, logfile_path))

    @easy_debug
    def get_all_package_fafrix_external_asset_ids(self, package):
        """A method obtains all external asset identifier from store_package_data_in_db
        Airflow's task log file.
        List of ids are contain:
            - movie ott external id
            - movie stb external id
            - preview ott external id
            - preview stb external id
        In fact, a command like
        "cat /usr/local/airflow/logs/*/store_package_data_in_db/* |
        grep 'ts0000_20170815_115252pt' | grep -Po '[0-9a-z]{32}_[0-9a-z]{32}' | sort -u
        is executed through SSH on the Airflow worker host.

        :param package: a package name - a key in self.packages dictionary.
        :param tries: a number of attempts to get an internal id, set 0 for unlimited attempts.
        :param interval: a number of seconds between re-tries.

        :return: list of assets identifiers used by Fabrix.

        :Example:

        >>>e2e_obj.get_all_package_fafrix_external_asset_ids("ts0000_20170815_115252pt")
        ['80f3e0ddc1134c240e24f11bc762eda1_ec80816b362f47f54c637f2ad253deb4',
        '3764807c70a11ae7769e28797302f1e8_3db98b518644918080e48343bdb644a1',
        'ede7790ea280a2d6a58f88d243b80272_3db98b518644918080e48343bdb644a1',
        'ad889aba5fb90831b5629e7d7e9670d9_ec80816b362f47f54c637f2ad253deb4']
        """
        # pattern fot a string like ts0014_20190620_222659pt10
        package_pattern = "ts[0-9]{4}_[0-9]{8}_[0-9]{6}[0-9\-]{0,3}[p,t]t[0-9]{0,2}"
        if re.match(package_pattern, package):
            # to not to match package "ts0014_20190620_222659pt10" when looking for package ...
            # ...                     "ts0014_20190620_222659pt1" :
            grep_ignore_pattern = "%s[0-9]" % package
        else:
            grep_ignore_pattern = ""
        id_pattern = "[0-9a-f]{32}_[0-9a-f]{32}"
        result = []
        log_files_path = ""
        for log in self.packages[package]["airflow_workers_logs_masks"]:
            if "/check_assets/" in log:
                log_files_path = log
                break

        if log_files_path:
            for cnf in self.conf["AIRFLOW_WORKERS"]:
                if grep_ignore_pattern:
                    command = "grep -r '%s' %s | grep -Po '%s' | grep -vP %s | sort -u" % \
                              (package, log_files_path, id_pattern, grep_ignore_pattern)
                else:
                    command = "grep -r '%s' %s | grep -Po '%s' | sort -u" % \
                              (package, log_files_path, id_pattern)

                stdout, stderr = self.tools.run_ssh_cmd(
                    cnf["host"], cnf["port"], cnf["user"], cnf["password"], command)

                if stdout:
                    result = stdout.splitlines()
                    break
                if stderr:
                    BuiltIn().log_to_console(stderr)
        else:
            BuiltIn().log_to_console("We didn't detect 'check_assets' log file mask")
        self.packages[package]["all_fabrix_asset_ids"] = result

        BuiltIn().log_to_console("all_fabrix_asset_ids_of_single_package: %s" % result)
        self.log_variables(self.get_all_package_fafrix_external_asset_ids, locals())
        return result

    @easy_debug
    def get_particular_fabrix_asset_id_of_package(self, package, tries=100,
                                                  interval=60, movie_type=None, actual_dag=None):
        """A method obtains an particular type of asset identifier used by Fabrix
        and sets it as a "fabrix_asset_id" property for the given package.
        In fact, a command like

        :param package: a package name - a key in self.packages dictionary.
        :param tries: a number of attempts to get an internal id, set 0 for unlimited attempts.
        :param interval: a number of seconds between re-tries.

        :return: an asset identifier used by Fabrix.

        :Example:

        >>>e2e_obj.get_particular_fabrix_asset_id_of_package("ts0000_20170815_115252pt")
        >>>e2e_obj.packages["ts0000_20170815_115252pt"]["fabrix_asset_id"]
        '80f3e0ddc1134c240e24f11bc762eda1_ec80816b362f47f54c637f2ad253deb4'
        """

        BuiltIn().log_to_console("Trying to find asset_id for package %s in the logs" % package)
        particular_fabrix_asset_id = ""

        i = 0
        while i < tries:
            i += 1
            check_assets_returned_value = self.get_check_assets_returned_value(actual_dag, package)

            if check_assets_returned_value:
                self._define_fabrix_asset_ids_info(package, check_assets_returned_value, actual_dag)
                particular_fabrix_asset_id = self._define_particular_fabrix_asset_id(
                    actual_dag, check_assets_returned_value, movie_type, package)

            if particular_fabrix_asset_id:
                break
            # else:
            time.sleep(interval)

        if particular_fabrix_asset_id:
            BuiltIn().log_to_console("Done: package %s got fabrix_asset_id: %s\n" %
                                     (package, particular_fabrix_asset_id))
        else:
            BuiltIn().log_to_console(
                "We don't see fabrix_asset_id in the logs for package %s =(\n" % package)
        self.log_variables(self.get_particular_fabrix_asset_id_of_package, locals())
        return particular_fabrix_asset_id

    @easy_debug
    def _define_particular_fabrix_asset_id(self, actual_dag, check_assets_returned_value, movie_type, package):
        particular_fabrix_asset_id = ""
        if movie_type and movie_type != "None" and movie_type not in [
                "4k_stb", "4K_STB", "4k_ott", "4K_OTT"]:
            particular_movie_type = movie_type
        else:
            particular_movie_type = "ott"
        if actual_dag in self.create_obo_assets_workflows:
            # We expect to match output like:
            # {
            #     'movie': {
            #         'ott': {
            #             'asset_properties': None,
            #             'external_id':
            #                 'b52152766930caca0bd85db205234361_\
            #                                             3db98b518644918080e48343bdb644a1',
            #             'need_to_ingest': True,
            #             'preset_id': 'AVC-SD43-OTT',
            #             'resolution': '4:3',
            #             'resolution_cs': 'SD'
            #         },
            #         'stb': {
            #             'asset_properties': None,
            #             'external_id': '82292fac1ac3422fee807ec9e68e9dc3_\
            #                                             3db98b518644918080e48343bdb644a1',
            #             'need_to_ingest': True,
            #             'preset_id': 'HEVC-576p25-STB',
            #             'resolution': '4:3',
            #             'resolution_cs': 'SD'
            #         },
            #         'mediainfo': {
            #             'audio_tracks_cnt': 1,
            #             'duration': 82.0,
            #             'aspect_ratio': 1.333,
            #             'height': 576,
            #             'fps': 25,
            #             'resolution': '4:3'
            #         },
            #         'thumbnails': [
            #             {
            #                 'name': 'still05.jpg',
            #                 'type': 'movie',
            #                 'how_related': 'still-large'
            #             },
            #             {
            #                 'name': 'still04.jpg',
            #                 'type': 'movie',
            #                 'how_related': 'still-medium'
            #             },
            #             {
            #                 'name': 'still02.jpg',
            #                 'type': 'movie',
            #                 'how_related': 'still-small'
            #             },
            #             {
            #                 'name': 'still03.jpg',
            #                 'type': 'movie'
            #             },
            #             {
            #                 'name': 'still07.jpg',
            #                 'type': 'movie'
            #             },
            #             {
            #                 'name': 'still06.jpg',
            #                 'type': 'movie'
            #             }, {
            #                 'name': 'still01.jpg',
            #                 'type': 'movie'
            #             }
            #         ]
            #     },
            #     'preview': {
            #         'ott': {
            #             'asset_properties': None,
            #             'external_id': '12567449ab86459a32143c5d0631cb69_\
            #                                             ec80816b362f47f54c637f2ad253deb4',
            #             'need_to_ingest': True,
            #             'preset_id': 'AVC-SD169-OTT',
            #             'resolution': '16:9',
            #             'resolution_cs': 'SD'},
            #         'stb': {
            #             'asset_properties': None,
            #             'external_id': 'da4089e3f4593bcc49cf1343fd84520b_\
            #                                             ec80816b362f47f54c637f2ad253deb4',
            #             'need_to_ingest': True,
            #             'preset_id': 'HEVC-576p25-STB',
            #             'resolution': '16:9',
            #             'resolution_cs': 'SD'
            #         },
            #         'mediainfo': {
            #             'audio_tracks_cnt': 1,
            #             'duration': 30.0,
            #             'aspect_ratio': 1.778,
            #             'height': 576,
            #             'fps': 25,
            #             'resolution': '16:9'
            #         },
            #         'thumbnails': [
            #             {
            #                 'name': 'still03.jpg',
            #                 'type': 'preview',
            #                 'how_related': 'still-large'
            #             },
            #             {
            #                 'name': 'still02.jpg',
            #                 'type': 'preview',
            #                 'how_related': 'still-medium'
            #             },
            #             {
            #                 'name': 'still01.jpg',
            #                 'type': 'preview',
            #                 'how_related': 'still-small'
            #             }
            #         ]
            #     }
            # }

            particular_fabrix_asset_id = \
                check_assets_returned_value["movie"][particular_movie_type]["external_id"]

        elif actual_dag in self.create_obo_assets_transcoding_driven_workflows:
            # We expect to match output like:
            # Example 1 (OG ingestion, using mekeadi tool):
            # {
            #     'episodes': [
            #     ],
            #     'assets_to_ingest': [],
            #     'ingested_assets': [],
            #     'external_ids': [
            #         ('ffa1d1bdefae624a006472d529f95b66_3db98b518644918080e48343bdb644a1',
            #          'imi:1001_ts0000_20190305_151108pt1-AVC-SD43-OTT'),
            #         ('b6c4932d50f546375868fcf564077fe9_3db98b518644918080e48343bdb644a1',
            #          'imi:1001_ts0000_20190305_151108pt1-HEVC-576p25-STB'),
            #         ('5fb2a87a589cff3180305ca49f91bd57_3db98b518644918080e48343bdb644a1',
            #          'imi:1001_ts0000_20190305_151108pt1-AVC-576i25-STB'),
            #         ('c127dfa6fa9c6c5ef74b99bc22b7fc8b_ec80816b362f47f54c637f2ad253deb4',
            #          'imi:1001_ts0000_20190305_151108pt2-AVC-SD169-OTT'),
            #         ('255f1d032e1423272cbd217a1072c839_ec80816b362f47f54c637f2ad253deb4',
            #          'imi:1001_ts0000_20190305_151108pt2-HEVC-576p25-STB'),
            #         ('4f22bd22fcc04117390a78ace422dc8d_ec80816b362f47f54c637f2ad253deb4',
            #          'imi:1001_ts0000_20190305_151108pt2-AVC-576i25-STB')
            #     ],
            #     'thumbnails': [],
            #     'xml_to_process': 'TVA_100001_20190305162033-intermediate.xml'
            # }
            #
            # Example 2 (no OG ingestion):
            # {'thumbnails': [{'how_related': 'still-large',
            #                  'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                  'name': 'still04.jpg'}, {'how_related': 'still-medium',
            #                                           'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                                           'name': 'still10.jpg'},
            #                 {'how_related': 'still-small',
            #                  'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                  'name': 'still07.jpg'}, {
            #                     'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                     'name': 'still13.jpg'}, {
            #                     'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                     'name': 'still06.jpg'}, {
            #                     'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                     'name': 'still08.jpg'}, {
            #                     'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                     'name': 'still01.jpg'}, {
            #                     'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                     'name': 'still11.jpg'}, {
            #                     'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                     'name': 'still14.jpg'}, {
            #                     'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                     'name': 'still05.jpg'}, {
            #                     'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                     'name': 'still15.jpg'}, {
            #                     'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                     'name': 'still09.jpg'}, {
            #                     'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                     'name': 'still12.jpg'}, {
            #                     'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                     'name': 'still03.jpg'}, {
            #                     'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                     'name': 'still02.jpg'}, {'how_related': 'still-large',
            #                                              'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                                              'name': 'still04.jpg'},
            #                 {'how_related': 'still-medium',
            #                  'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                  'name': 'still10.jpg'}, {'how_related': 'still-small',
            #                                           'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                                           'name': 'still07.jpg'}, {
            #                     'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                     'name': 'still13.jpg'}, {
            #                     'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                     'name': 'still06.jpg'}, {
            #                     'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                     'name': 'still08.jpg'}, {
            #                     'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                     'name': 'still01.jpg'}, {
            #                     'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                     'name': 'still11.jpg'}, {
            #                     'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                     'name': 'still14.jpg'}, {
            #                     'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                     'name': 'still05.jpg'}, {
            #                     'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                     'name': 'still15.jpg'}, {
            #                     'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                     'name': 'still09.jpg'}, {
            #                     'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                     'name': 'still12.jpg'}, {
            #                     'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                     'name': 'still03.jpg'}, {
            #                     'group_id': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                     'name': 'still02.jpg'}],
            #  'xml_to_process': 'TVA_000001_20170802081133.xml', 'ingested_assets': [],
            #  'assets_to_ingest': [{'episode': None, 'title': 'De Dolle Tweeling',
            #                        'crid': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                        'video_file': 'GDAA5000000001828666.ts',
            #                        'mediainfo': {'height': 720, 'aspect_ratio': 1.778,
            #                                      'fps': 25, 'duration': 4939.44,
            #                                      'audio_tracks_cnt': 1,
            #                                      'resolution': '720p', 'subtitles': 0},
            #                        'preset_id': 'HEVC-720p50-STB', 'duration': 5100.0,
            #                        'metadata_id': 'imi:49707-hanni-nanni-stb_2019_03_06-14_43_53-039830',
            #                        'episode_number': None,
            #                        'external_id': 'b7289ac043a6668514433bc9d7220f3f_6d3dcc092abae47836160c6afee40891'},
            #                       {'episode': None, 'title': 'De Dolle Tweeling',
            #                        'crid': 'crid://e2e-si.lgi.com/49707-hanni-nanni_2019_03_06-14_43_53-039830',
            #                        'video_file': 'GDAA5000000001828666.ts',
            #                        'mediainfo': {'height': 720, 'aspect_ratio': 1.778,
            #                                      'fps': 25, 'duration': 4939.44,
            #                                      'audio_tracks_cnt': 1,
            #                                      'resolution': '720p', 'subtitles': 0},
            #                        'preset_id': 'AVC-720p-OTT', 'duration': 5100.0,
            #                        'metadata_id': 'imi:49707-hanni-nanni-ott_2019_03_06-14_43_53-039830',
            #                        'episode_number': None,
            #                        'external_id': 'd448aa282bb9c724b00ac9788e11d622_6d3dcc092abae47836160c6afee40891'}],
            #  'episodes': [], 'external_ids': [
            #     ('b7289ac043a6668514433bc9d7220f3f_6d3dcc092abae47836160c6afee40891', None),
            #     (
            #     'd448aa282bb9c724b00ac9788e11d622_6d3dcc092abae47836160c6afee40891', None)]}

            movie = "1"
            # preview = "2"
            movie_duration = movie
            external_ids_list = check_assets_returned_value["external_ids"]
            if external_ids_list:
                for info_tuple in external_ids_list:
                    # external_ids example:
                    # 4f22bd22fcc04117390a78ace422dc8d_ec80816b362f47f54c637f2ad253deb4
                    external_ids = info_tuple[0]
                    # imi examples:
                    # imi:1001_ts0000_20190305_151108pt2-AVC-SD169-OTT
                    # imi:1001_ts0000_20190305_151108pt2-HEVC-576p25-STB
                    imi = info_tuple[1]
                    if imi:
                        if particular_movie_type.upper() in imi:
                            if "pt" in package:
                                imi_movie_duration = imi.split(package)[1][0]
                            else:
                                imi_movie_duration = imi.split("pt")[1][0]
                            if imi_movie_duration == movie_duration:
                                particular_fabrix_asset_id = external_ids
                                BuiltIn().log_to_console(
                                    "particular_fabrix_asset_id: %s" %
                                    particular_fabrix_asset_id)
                                break
                    # imi could be None in case of No OG ingestion
                    else:
                        if check_assets_returned_value["assets_to_ingest"]:
                            BuiltIn().log_to_console("Expecting new ingestion")
                            with_assets = "assets_to_ingest"
                        elif check_assets_returned_value["ingested_assets"]:
                            BuiltIn().log_to_console("Assets was ingested before")
                            with_assets = "ingested_assets"
                        else:
                            raise Exception("There are no fabrix_asset_ids in "
                                            "check_assets_returned_value")

                        for asset in check_assets_returned_value[with_assets]:
                            if particular_movie_type.upper() in asset["preset_id"]:
                                particular_fabrix_asset_id = asset[
                                    "external_id"]
                                BuiltIn().log_to_console(
                                    "particular_fabrix_asset_id: %s" %
                                    particular_fabrix_asset_id)
                                break
            else:
                BuiltIn().log_to_console("External_ids_list is empty!!!")
        self.packages[package]["fabrix_asset_id"] = particular_fabrix_asset_id
        self.log_variables(self._define_particular_fabrix_asset_id,
                           locals())
        BuiltIn().log_to_console("particular_fabrix_asset_id: %s" % particular_fabrix_asset_id)
        return particular_fabrix_asset_id

    @easy_debug
    def get_check_assets_returned_value(self, actual_dag, package):
        """A method to get "returned_value" from check_assets job log when you have only
        package name

        :param actual_dag: name of the DAG, string
        :param package: name of the package, string
        :return: "returned_value", dictionary
        """
        check_assets_returned_value = {}
        all_ids_of_single_package = self.get_all_package_fafrix_external_asset_ids(package)
        if all_ids_of_single_package:
            log_files_path = self.get_log_path_of_a_job("check_assets", package)

            if log_files_path:
                check_assets_returned_value = self._define_check_assets_returned_value(
                    actual_dag, all_ids_of_single_package, log_files_path, package)
        self.log_variables(self.get_check_assets_returned_value, locals())
        return check_assets_returned_value

    @easy_debug
    def _define_check_assets_returned_value(self, actual_dag, all_ids_of_single_package,
                                            log_files_path, package):
        check_assets_returned_value = ""
        if actual_dag in self.create_obo_assets_workflows:
            pattern_beginning = "{'(movie|preview)': {'(ott|stb)': {.*("
            for asset_id in all_ids_of_single_package:
                if asset_id != all_ids_of_single_package[-1]:
                    pattern_beginning += "%s |" % asset_id
                else:
                    pattern_beginning += "%s" % asset_id
            pattern_end = ").*}}"
            pattern = pattern_beginning + pattern_end
            # Should be regex pattern like:
            # Returned value was: \K{'(movie|preview)': {'(ott|stb)': {.*(
            # 6f9d6e924308e20ddfcf7a98a0cd0264_ec80816b362f47f54c637f2ad253deb4|
            # ad889aba5fb90831b5629e7d7e9670d9_ec80816b362f47f54c637f2ad253deb4|
            # 3764807c70a11ae7769e28797302f1e8_3db98b518644918080e48343bdb644a1|
            # ede7790ea280a2d6a58f88d243b80272_3db98b518644918080e48343bdb644a1).*}}
        elif actual_dag in self.create_obo_assets_transcoding_driven_workflows:
            pattern_beginning = "\{'episodes'.*'external_ids': \[(\('("
            for asset_id in all_ids_of_single_package:
                if asset_id != all_ids_of_single_package[-1]:
                    pattern_beginning += "%s|" % asset_id
                else:
                    pattern_beginning += "%s" % asset_id
            pattern_end = ")'\,.*\)\,?)+.*'xml_to_process'.*.xml'\}"
            pattern = pattern_beginning + pattern_end
            # Should be regex pattern like:
            # \{'episodes'. * 'external_ids': \[(\('(
            # 255f1d032e1423272cbd217a1072c839_ec80816b362f47f54c637f2ad253deb4|
            # 4f22bd22fcc04117390a78ace422dc8d_ec80816b362f47f54c637f2ad253deb4|
            # 5fb2a87a589cff3180305ca49f91bd57_3db98b518644918080e48343bdb644a1|
            # b6c4932d50f546375868fcf564077fe9_3db98b518644918080e48343bdb644a1|
            # c127dfa6fa9c6c5ef74b99bc22b7fc8b_ec80816b362f47f54c637f2ad253deb4|
            # ffa1d1bdefae624a006472d529f95b66_3db98b518644918080e48343bdb644a1
            # )'\, .* \)\, ?)+.*'xml_to_process'.*.xml'\}
            # BuiltIn().log_to_console("pattern:\n%s\n" % pattern)
        else:
            self.log_variables(self._define_check_assets_returned_value,
                               locals())
            raise Exception("Unexpected DAG: %s" % actual_dag)
        for cnf in self.conf["AIRFLOW_WORKERS"]:
            command = "grep -r 'Returned value was:' %s | grep -Po \"%s\" | sort -u" % \
                      (log_files_path, pattern)
            stdout = self.tools.run_ssh_cmd(
                cnf["host"], cnf["port"], cnf["user"], cnf["password"], command)[0]
            if stdout:
                check_assets_returned_value = ast.literal_eval(str(stdout))
                self.packages[package]["check_assets_returned_value"] = \
                    check_assets_returned_value
                BuiltIn().log_to_console("\ncheck_assets_returned_value: \n%s\n\n" %
                                         check_assets_returned_value)
        self.log_variables(self._define_check_assets_returned_value, locals())

        return check_assets_returned_value

    @easy_debug
    def get_fabrix_asset_ids_info(self, actual_dag, package):
        """A method to get dictionary with fabrix_asset_id as key and details as value
        Detail will contain device_type, video_type, aspect_ratio

        :param actual_dag: name of the DAG, string
        :param package: name of the package, string
        :return: "fabrix_asset_ids_info", dictionary
        """
        fabrix_asset_ids_info = {}
        check_assets_returned_value = self.get_check_assets_returned_value(actual_dag, package)

        if check_assets_returned_value:
            fabrix_asset_ids_info = self._define_fabrix_asset_ids_info(
                package, check_assets_returned_value, actual_dag)
        self.log_variables(self.get_fabrix_asset_ids_info, locals())
        return fabrix_asset_ids_info

    @easy_debug
    def _define_fabrix_asset_ids_info(self, package_name, check_assets_returned_value, dag_name):
        """A method to define 'fabrix_asset_ids_info' package property. It's will be a dictionary
        what contain device_type, video_type and aspect_ratio of the asset"

        fabrix_asset_ids_info = {
            "eb8b3701673eb668569ef4f0d3648a50_3db98b518644918080e48343bdb644a1": {"device_type": "ott", "video_type": "movie", "aspect_ratio": "1.333"},
            "ebcd24bef37ef0d89c2a9fb0e7483e92_3db98b518644918080e48343bdb644a1": {"device_type": "stb", "video_type": "movie", "aspect_ratio": "1.333"},
            "9377980492f6df1d7427e3c376c7f81f_3db98b518644918080e48343bdb644a1": {"device_type": "stb", "video_type": "movie", "aspect_ratio": "1.333"},
            "2d7d1752cab5ceb1a0b4b3b4d242e158_ec80816b362f47f54c637f2ad253deb4": {"device_type": "ott", "video_type": "preview", "aspect_ratio": "1.778"},
            "4f105f47ae37f4f2e0ebb09dbe584c7b_ec80816b362f47f54c637f2ad253deb4": {"device_type": "stb", "video_type": "preview", "aspect_ratio": "1.778"},
            "05f90a6568c50ecef2624744496aab82_ec80816b362f47f54c637f2ad253deb4": {"device_type": "stb", "video_type": "preview", "aspect_ratio": "1.778"},
        }

        :param package_name: name of the package, string
        :param check_assets_returned_value: dictionary from 'check_assets'. Example is in the "get_all_package_fafrix_external_asset_ids" method as comment
        :param dag_name: name of the DAG, string
        """

        result_dict = {}

        if dag_name in self.create_obo_assets_workflows:
            stb_preview_id = check_assets_returned_value["preview"]["stb"]["external_id"]
            ott_preview_id = check_assets_returned_value["preview"]["ott"]["external_id"]
            stb_movie_id = check_assets_returned_value["movie"]["stb"]["external_id"]
            ott_movie_id = check_assets_returned_value["movie"]["ott"]["external_id"]
            result_dict[stb_preview_id] = {"device_type": "stb", "video_type": "preview",
                                           "aspect_ratio": "1.778"}
            result_dict[ott_preview_id] = {"device_type": "ott", "video_type": "preview",
                                           "aspect_ratio": "1.778"}
            result_dict[stb_movie_id] = {"device_type": "stb", "video_type": "movie",
                                         "aspect_ratio": "1.333"}
            result_dict[ott_movie_id] = {"device_type": "ott", "video_type": "movie",
                                         "aspect_ratio": "1.333"}
        elif dag_name in self.create_obo_assets_transcoding_driven_workflows:
            for asset in check_assets_returned_value["assets_to_ingest"]:
                aspect_ratio = asset["mediainfo"]["aspect_ratio"]
                preview = asset["preview"]
                if preview:
                    # preview
                    if "STB" in asset["preset_id"]:
                        stb_preview_id = asset["external_id"]
                        result_dict[stb_preview_id] = {"device_type": "stb",
                                                       "video_type": "preview",
                                                       "aspect_ratio": str(aspect_ratio)}
                    elif "OTT" in asset["preset_id"]:
                        ott_preview_id = asset["external_id"]
                        result_dict[ott_preview_id] = {"device_type": "ott",
                                                       "video_type": "preview",
                                                       "aspect_ratio": str(aspect_ratio)}
                elif not preview:
                    # movie
                    if "STB" in asset["preset_id"]:
                        stb_movie_id = asset["external_id"]
                        result_dict[stb_movie_id] = {"device_type": "stb", "video_type": "movie",
                                                     "aspect_ratio": str(aspect_ratio)}
                    elif "OTT" in asset["preset_id"]:
                        ott_movie_id = asset["external_id"]
                        result_dict[ott_movie_id] = {"device_type": "ott", "video_type": "movie",
                                                     "aspect_ratio": str(aspect_ratio)}
                else:
                    self.log_variables(
                        self._define_fabrix_asset_ids_info, locals())
                    raise Exception(
                        "Failed to detect 'preview' or 'movie'"
                    )
        else:
            self.log_variables(self._define_fabrix_asset_ids_info, locals())
            raise Exception(
                "Unexpected DAG (%s) for "
                "'_define_fabrix_asset_ids_info' method" % dag_name)
        self.packages[package_name]["fabrix_asset_ids_info"] = result_dict
        BuiltIn().log_to_console("fabrix_asset_ids_info: %s" % result_dict)
        self.log_variables(self._define_fabrix_asset_ids_info, locals())
        return result_dict

    @easy_debug
    def get_log_path_of_a_job(self, job_name, package_name):
        """A useful method to get path to particular log from airflow_workers_logs_masks
        based on log's job name

        :param job_name: name of the DAG job, like "check_assets"
        :param package_name: name of the package
        :return: absolete path to the log
        """
        log_path = ""
        for log in self.packages[package_name]["airflow_workers_logs_masks"]:
            if "/%s/" % job_name in log:
                log_path = log
        return log_path

    @easy_debug
    def get_actual_dag_name(self, airflow_workers_logs_masks, package):
        """A method to determinate DAG name from log masks. Example:
        Log mask: # '/usr/local/airflow/logs/csi_lab_create_obo_assets_workflow/check_assets/\
                # 2019-03-10T19:57:49/1.log'
        DAG: csi_lab_create_obo_assets_workflow

        :param airflow_workers_logs_masks: list of log masks.
        :param package: package name, string.

        :return: dag name as string.
        """

        check_assets_mask = None
        for mask in airflow_workers_logs_masks:
            if "/check_assets/" in mask:
                # '/usr/local/airflow/logs/csi_lab_create_obo_assets_workflow/check_assets/\
                # 2019-03-10T19:57:49/1.log'
                check_assets_mask = mask
                break
        if check_assets_mask:
            actual_dag = check_assets_mask.split("check_assets")[0].split("/")[-2]
            if actual_dag:
                BuiltIn().log_to_console(
                    "\n\n<<<<<<<<<<<<<<<< DAG: %s >>>>>>>>>>>>>>>>\n\n" % actual_dag)
                self.packages[package]["actual_dag"] = actual_dag
            else:
                self.log_variables(self.get_actual_dag_name, locals())
                raise Exception(
                    "DAG was not detected for package %s" % package)
        else:
            self.packages[package]["actual_dag"] = ""
        self.log_variables(self.get_actual_dag_name, locals())
        return self.packages[package]["actual_dag"]

    @easy_debug
    def get_asset_properties(self, package, tries=30, interval=20):
        """A method requests Fabrix for asset properties
        and sets them as into self.packages[package]["properties"] in the form of a dictionary.
        .. note:: if ingestion has failed, an empty dictionary is set.

        :param package: a package name - a key in self.packages dictionary.
        :param tries: a number of attempts to request Fabrix, set 0 for unlimited attempts.
        :param interval: a number of seconds between re-tries.

        :return: a dictionary of properties if successfully got, otherwise empty dictionary.
        """
        properties = {}
        if not self.packages[package]["fabrix_asset_id"]:
            self.log_variables(self.get_asset_properties, locals())
            return properties

        BuiltIn().log_to_console("Trying to find asset_properties for package %s "
                                 "by request to Fabrix" % package)
        missed_fabrix_connectivity_message = ""
        missed_fabrix_connectivity_hosts_list = []
        for vod_vspp_controller in self.conf["FABRIX"]:
            url = "http://%s:%s/v2/view_asset_properties?id=%s" % \
                  (vod_vspp_controller["host"], vod_vspp_controller["port"],
                   self.packages[package]["fabrix_asset_id"])
            found = False
            text = ""
            i = 0
            while not found:
                i += 1
                try:
                    response = requests.get(url)
                    if response.status_code == 200:
                        found = True
                        text = self.tools.filter_chars(response.text)
                        properties = xmltodict.parse(text)["view_asset_properties"]
                    else:
                        BuiltIn().log_to_console(
                            "To get_asset_properties we send get to %s\nStatus code is %s. "
                            "Tries left %s" % (url, response.status_code, tries - i))
                    if vod_vspp_controller["host"] in missed_fabrix_connectivity_hosts_list:
                        missed_fabrix_connectivity_hosts_list.remove(vod_vspp_controller["host"])

                # except requests.exceptions.RequestException as err:
                except requests.exceptions.ConnectionError as err:
                    BuiltIn().log_to_console("Connectivity exception on IP %s. Tries left %s" %
                                             (vod_vspp_controller["host"], tries - i))
                    if vod_vspp_controller["host"] not in missed_fabrix_connectivity_hosts_list:
                        missed_fabrix_connectivity_message += str(err)
                        missed_fabrix_connectivity_hosts_list.append(vod_vspp_controller["host"])
                        BuiltIn().log_to_console(
                            "missed_fabrix_connectivity_count: %s" %
                            missed_fabrix_connectivity_hosts_list)
                if found or i == tries:
                    self.log_variables(self.get_asset_properties, locals())
                    break
                # else:
                time.sleep(interval)

            self.packages[package]["properties"] = json.loads(json.dumps(properties))
            if len(self.packages[package]["properties"]) > 2:
                break

        if len(missed_fabrix_connectivity_hosts_list) == len(self.conf["FABRIX"]):
            raise requests.exceptions.ConnectionError(
                "We can't connect to Fabrix to get asset properties. Exception message is: "
                "%s" % missed_fabrix_connectivity_message)


        if len(self.packages[package]["properties"]) > 2:
            BuiltIn().log_to_console("\nPackage %s got properties:\n%s\n" % (package, properties))
        else:
            BuiltIn().log_to_console("We don't see properties for the package %s yet =(\n"
                                     % package)
            self_packages_package_properties = self.packages[package]["properties"]
            print(self_packages_package_properties)
        self.log_variables(self.get_asset_properties, locals())
        return self.packages[package]["properties"]

    @easy_debug
    def is_asset_present_in_watch_folder(self, watch_folder_path, package_name):  # pylint: disable=R1710
        """A keyword to check is folder with asset data present in watch folder or not.

        :param watch_folder_path: string, "/mnt/nfs_watch/Countries/CSI/ToAirflow_priority" or
                                  "/mnt/nfs_watch/Countries/CSI/ToAirflow".
        :param package_name: string

        :return: boolean, True or False.
        """
        for cnf in self.conf["AIRFLOW_WORKERS"]:
            command = "ls -l %s | grep %s" % (watch_folder_path, package_name)
            stdout, stderr = self.tools.run_ssh_cmd(cnf["host"], cnf["port"],
                                                    cnf["user"], cnf["password"],
                                                    command)
            stdout_to_log = stdout
            if stderr:
                self.log_variables(self.is_asset_present_in_watch_folder, locals())
                raise Exception("Got error when check asset:\n%s" % stderr)
            if stdout:
                BuiltIn().log_to_console("\nAsset present in watch folder. Output:\n%s\n\n" %
                                         stdout_to_log)
                result = True
            else:
                BuiltIn().log_to_console("Asset not present in watch folder. Output:\n%s" %
                                         stdout_to_log)
                result = False

            self.log_variables(self.is_asset_present_in_watch_folder, locals())
            return result

    @easy_debug
    def is_output_tva_file_ready(self, package):
        """A method to determinate is the output TVA file present in managed folder or not

        :param package: a package name.

        :return: boolean, true or False.

        """
        BuiltIn().log_to_console("Started to check is output TVA file present or not")
        result = False
        log_files_path = ""
        output_tva = ""
        for log in self.packages[package]["airflow_workers_logs_masks"]:
            if "/generate_tva_file/" in log:
                log_files_path = log

        if log_files_path:
            output_tva = self.get_output_tva_file_path(log_files_path)
            if output_tva:
                ssh = [self.conf["AIRFLOW_WORKERS"][0]["host"],
                       self.conf["AIRFLOW_WORKERS"][0]["port"],
                       self.conf["AIRFLOW_WORKERS"][0]["user"],
                       self.conf["AIRFLOW_WORKERS"][0]["password"]]
                cmd = "ls -l %s" % output_tva
                output, error = self.tools.run_ssh_cmd(*(ssh + [cmd]))

                output_to_log = output
                print(error)
                if output and "No such file or directory" not in output:  # pylint: disable=R1705
                    BuiltIn().log_to_console("Output TVA file is ready. Output: %s\nCommand: %s" %
                                             (output_to_log, cmd))
                    self.packages[package]["output_tva"] = output.split(" ")[-1]
                    result = True
                else:   # pylint: disable=R1705
                    BuiltIn().log_to_console("Output TVA file is NOT ready yet =(. "
                                             "Output: %s\nCommand: %s" % (output_to_log, cmd))

        else:
            BuiltIn().log_to_console("'generate_tva_file' log path was not found in "
                                     "'airflow_workers_logs_masks' list")
        self.log_variables(self.is_output_tva_file_ready, locals())
        return result

    @easy_debug
    def get_output_tva_file_path(self, log_files_path):
        """A method to get path to output TVA file from log file

        :param log_files_path: absolute path to log, where path to TVA file is mentioned
        :return: absolute path to output TVA file
        """
        output_tva = ""
        managed_folder = self.conf["AIRFLOW_WORKERS"][0]["managed_folder"]
        # watch_folder_screened example: "\/mnt\/nfs_managed\/Countries\/CSI\/FromAirflow
        watch_folder_screened = managed_folder.replace("/", "\/")
        # search_pattern example: "\/mnt\/nfs_managed\/Countries\/CSI\/FromAirflow\/crid.+\/output_TVA\/TVA_\d{6}_\d{14}.xml"
        search_pattern = "%s\/crid.+\/output_TVA\/TVA_\d{6}_\d{14}.xml" % watch_folder_screened
        command = "cat %s | grep -Po '%s' | sort -u" % (log_files_path, search_pattern)
        for worker in self.conf["AIRFLOW_WORKERS"]:
            ssh = [worker["host"], worker["port"], worker["user"], worker["password"]]
            output, error = self.tools.run_ssh_cmd(*(ssh + [command]))
            if re.match(search_pattern, output):
                output_tva = output
                break
            # else:
            BuiltIn().log_to_console("Output from '%s' command don't match our "
                                     "regex pattern '%s'. Output: %s" %
                                     (command, search_pattern, output))
            if error:
                print(error)
        self.log_variables(self.get_output_tva_file_path, locals())
        return output_tva

    @easy_debug
    def get_resolution_from_output_tva_file(self, path_to_output_tva, movie_type, definition_type):
        """ A method to get resolution of particular movie type and particular definition type

        :param path_to_output_tva: absolute path to output tva xml file to analyze
        :param movie_type: "OTT" or "STB"
        :param definition_type: "HD" or "SD"
        :return: HorizontalSize and VerticalSize
        """

        movie_type = movie_type.upper()

        #File sample present here robot/lib/IngestionE2E/samples/output_tva_ts1111.txt
        output_tva_folder = "/".join(path_to_output_tva.split("/")[:-1])
        xml_as_dict = self.read_tva(output_tva_folder)
        # DEBUG:
        # xml_as_dict = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_resolution_from_output_tva_file"]["ts1111"]["xml_as_dict"]

        horizontal_sizes = []
        vertical_sizes = []
        for movie in xml_as_dict["TVAMain"]["ProgramDescription"]["ProgramLocationTable"]["OnDemandProgram"]:
            correct_movie = False

            for genre in movie["InstanceDescription"]["Genre"]:
                if "Definition" in list(genre.keys()) and movie_type in genre["Definition"]["#text"]:
                    correct_movie = True
            if correct_movie:
                for genre in movie["InstanceDescription"]["Genre"]:
                    if "@href" in list(genre.keys()) and definition_type in genre["@href"]:
                        horizontal_sizes.append(movie["InstanceDescription"]["AVAttributes"]["VideoAttributes"]["HorizontalSize"])
                        vertical_sizes.append(movie["InstanceDescription"]["AVAttributes"]["VideoAttributes"]["VerticalSize"])

        # Check that size value only one
        if len(list(set(horizontal_sizes))) == 1:
            horizontal_size = horizontal_sizes[0]
        elif not list(horizontal_sizes):
            self.log_variables(self.get_resolution_from_output_tva_file,
                               locals())
            raise Exception(
                "Movie type %s doesn't have values of horizontal size for %s: %s. "
                "Output TVA: %s" % (
                    movie_type, definition_type, horizontal_sizes, path_to_output_tva)
            )
        else:
            self.log_variables(self.get_resolution_from_output_tva_file,
                               locals())
            raise Exception(
                "Movie type %s has more then one value of horizontal size for %s: %s. "
                "Output TVA: %s" % (
                    movie_type, definition_type, horizontal_sizes, path_to_output_tva)
            )
        if len(list(set(vertical_sizes))) == 1:
            vertical_size = vertical_sizes[0]
        else:
            raise Exception(
                "Movie type %s has more then one value of vertical size for %s: %s" % (movie_type, definition_type, vertical_sizes)
            )

        self.log_variables(self.get_resolution_from_output_tva_file, locals())
        return int(horizontal_size), int(vertical_size)

    @easy_debug
    def get_video_format_from_output_tva_file(self, path_to_output_tva, movie_type, definition_type):
        """ A method to get Video format of particular movie type and particular definition type

        :param path_to_output_tva: absolute path to output tva xml file to analyze
        :param movie_type: "OTT" or "STB"
        :param definition_type: "HD" or "SD"
        :return: string type, Video format of the movie
        """

        movie_type = movie_type.upper()

        #File sample present here robot/lib/IngestionE2E/samples/output_tva_ts1111.txt
        output_tva_folder = "/".join(path_to_output_tva.split("/")[:-1])
        xml_as_dict = self.read_tva(output_tva_folder)
        # DEBUG:
        # xml_as_dict = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_resolution_from_output_tva_file"]["ts1111"]["xml_as_dict"]

        video_formats = []
        for movie in xml_as_dict["TVAMain"]["ProgramDescription"]["ProgramLocationTable"]["OnDemandProgram"]:
            correct_movie = False

            for genre in movie["InstanceDescription"]["Genre"]:
                if "Definition" in list(genre.keys()) and movie_type in genre["Definition"]["#text"]:
                    correct_movie = True
            if correct_movie:
                for genre in movie["InstanceDescription"]["Genre"]:
                    if "@href" in list(genre.keys()) and definition_type in genre["@href"]:
                        video_formats.append(movie["InstanceDescription"]["AVAttributes"]["VideoAttributes"]["Coding"]["Definition"]["#text"])

        # Check that size value only one
        if len(list(set(video_formats))) == 1:
            video_format = video_formats[0]
        else:
            raise Exception(
                "Movie type %s has more then one video formats %s: %s" % (movie_type, definition_type, video_formats)
            )

        self.log_variables(self.get_video_format_from_output_tva_file, locals())
        return video_format

    @easy_debug
    def get_audio_coding_formats_from_output_tva_file(self, path_to_output_tva):
        """ A method to get AudioCodingFormat, like AudioCodingFormatCS:2001:3.1

        :param path_to_output_tva: absolute path to output tva xml file to analyze
        :return: dictionary of audio coding and audio coding formats
        """

        #File sample present here robot/lib/IngestionE2E/samples/output_tva_ts1111.txt
        dictionary_to_return = {}
        output_tva_folder = "/".join(path_to_output_tva.split("/")[:-1])
        xml_as_dict = self.read_tva(output_tva_folder)
        # DEBUG:
        # xml_as_dict = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_resolution_from_output_tva_file"]["ts1111"]["xml_as_dict"]
        # or
        # xml_as_dict = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_resolution_from_output_tva_file"]["ts0000"]["xml_as_dict"]
        on_demand_programs = xml_as_dict["TVAMain"]["ProgramDescription"]["ProgramLocationTable"]["OnDemandProgram"]
        for program in on_demand_programs:
            audio_attributes = program["InstanceDescription"]["AVAttributes"]["AudioAttributes"]
            if isinstance(audio_attributes, list):
                for audio_attribute in audio_attributes:
                    dictionary_to_return = self.update_audio_coding_dictionary(audio_attribute, dictionary_to_return)
            else:
                dictionary_to_return = self.update_audio_coding_dictionary(audio_attributes, dictionary_to_return)
        self.log_variables(self.get_audio_coding_formats_from_output_tva_file, locals())
        return dictionary_to_return

    @easy_debug
    def get_images_from_output_tva_file(self, path_to_output_tva):
        """Method to get images instances from output TVA.xml file
        Example of image instance:
        "http://staticqbr-nl-labe2esuperset.lab.cdn.dmdsdp.com/image-service/ImagesEPG/\
        OndemandImages/CSI/Thumbnails/crid~~3A~~2F~~2Fog.libertyglobal.com~~\
        2F1001~~2Fts0000_20190326_161630pt2/26d058203bc0b86a97c855271bbb0410.jpg"

        :param path_to_output_tva: absolute path to output TVA.xml file
        :return: list of images
        """
        images = []
        output_tva_folder = "/".join(path_to_output_tva.split("/")[:-1])
        output_tva_dic = self.read_tva(output_tva_folder)
        program_information = \
        output_tva_dic["TVAMain"]["ProgramDescription"]["ProgramInformationTable"]["ProgramInformation"]
        for information in program_information:
            related_materials = information["BasicDescription"]["RelatedMaterial"]
            for material in related_materials:
                media_uri = material["MediaLocator"]["MediaUri"]
                if "image" in media_uri["#text"]:
                    images.append(media_uri["#text"])

        self.log_variables(self.get_images_from_output_tva_file, locals())
        return images

    @easy_debug
    def get_host_from_url(self, url):
        """Sample method to get host (IP or FQDN) from URL"""
        host = url.split("//")[1].split("/")[0]
        if ":" in host:
            host = host.split(":")[0]
        self.log_variables(self.get_host_from_url, locals())
        return host

    @easy_debug
    def update_audio_coding_dictionary(self, audio_attribute, dictionary_to_return):
        """Sub method of self.get_audio_coding_formats_from_output_tva_file to prevent copy/paste"""
        audio_coding = str(audio_attribute["Coding"]["Name"]["#text"])
        if audio_coding not in list(dictionary_to_return.keys()):
            dictionary_to_return[audio_coding] = []
        audio_coding_format = str(audio_attribute["Coding"]["@href"].split(":")[-1])
        if audio_coding_format not in dictionary_to_return[audio_coding]:
            dictionary_to_return[audio_coding].append(audio_coding_format)

        self.log_variables(self.update_audio_coding_dictionary, locals())
        return dictionary_to_return

    @easy_debug
    def get_ingestion_start_time(self, package):
        """A method to determinate the ingestion start time by graping TVA file creation time
        from 'managed_folder" folder

        :param package: a package name.

        :return: int, start time in %Y%m%d%H%M%S format like 20181220105125.

        """
        check_assets_log = ""
        for log in self.packages[package]["airflow_workers_logs_masks"]:
            if "/check_assets/" in log:
                check_assets_log = log
        if check_assets_log:
            # check_assets_log example "/usr/local/airflow/logs/ecx_superset_create_obo_assets_transcoding_driven_trigger/check_assets/2019-06-28T09:45:00/1.log"
            ingestion_start_time = check_assets_log.split("check_assets/")[1].split("/")[0].replace("-", "").replace("T", "").replace(":", "")
        else:
            self.log_variables(self.get_ingestion_start_time, locals())
            raise Exception("\n\n\nCould not find 'check_assets' log mask in 'airflow_workers_logs_masks'")
        if not ingestion_start_time:
            self.log_variables(self.get_ingestion_start_time, locals())
            raise  Exception("\n\n\nCould not get ingestion_start_time\n\n\n")
        # else:
        BuiltIn().log_to_console("Ingestion start time is: %s" % ingestion_start_time)

        self.log_variables(self.get_ingestion_start_time, locals())
        return int(ingestion_start_time)

    @easy_debug
    def get_ingestion_end_time(self, package):
        """A method to determinate the ingestion end time by graping TVA file creation time
        from 'managed_folder/output_TVA" folder

        :param package: a package name.

        :return: int, end time in %Y%m%d%H%M%S format like 20181220105125.

        """
        ssh = [self.conf["AIRFLOW_WORKERS"][0]["host"], self.conf["AIRFLOW_WORKERS"][0]["port"],
               self.conf["AIRFLOW_WORKERS"][0]["user"], self.conf["AIRFLOW_WORKERS"][0]["password"]]
        # pkg_dir = "%s/*%s" % (self.conf["AIRFLOW_WORKERS"][0]["managed_folder"], package)
        cmd = "ls -ltr --time-style=+%Y%m%d%H%M%S " + self.packages[package]["output_tva"] + \
              " | head -n 1 | awk '{print $6}'"
        ingestion_end_time, error = self.tools.run_ssh_cmd(*(ssh + [cmd]))

        ingestion_end_time_to_log = ingestion_end_time
        if not ingestion_end_time:
            self.log_variables(self.get_ingestion_end_time, locals())
            raise  Exception("\n\n\nCould not get ingestion_end_time %s\n\n\n" % error)
        # else:
        BuiltIn().log_to_console("Ingestion end time is: %s" % ingestion_end_time_to_log)

        self.log_variables(self.get_ingestion_end_time, locals())
        return int(ingestion_end_time)

    @easy_debug
    def was_movie_type_ingested(
            self, package, movie_type,
            actual_dag="ecx_superset_create_obo_assets_transcoding_driven_workflow", platform=""):
        """A method to determinate was stb movie ingested or it has been skipped

        :param package: a package name.
        :param movie_type: ott or stb, string

        :return: True or False
        """
        result = False
        BuiltIn().log_to_console(
            "\nTrying to determinate was movie type %s ingested or not:" % movie_type)
        if actual_dag in self.create_obo_assets_workflows:
            if platform:
                log_specific = platform
            else:
                log_specific = movie_type
            main_logs_time = self.get_main_logs_time(package)
            cmd = "grep -r 'Skipping downstream tasks' %s/*/need_to_ingest_movie_%s/*/*.log | " \
                      "grep '%s'" % (self.conf["AIRFLOW_WORKERS"][0]["logs_folder"],
                                     log_specific, main_logs_time)
            skip_messages = []
            for cnf in self.conf["AIRFLOW_WORKERS"]:
                stdout = self.tools.run_ssh_cmd(cnf["host"], cnf["port"], cnf["user"], cnf["password"],
                                                cmd)[0]
                BuiltIn().log_to_console("Command: %s\nOutput: %s\n" % (cmd, stdout))
                if stdout:  # pylint: disable=R1705
                    skip_messages.append(stdout)
            if not skip_messages:
                result = True
        elif actual_dag in self.create_obo_assets_transcoding_driven_workflows:
            # mock = mock_data["robot"]["Keywords"]["ingestion.basic.robot"]["Run Ingestion Suite"]["results-2"]["HES-739_ott"]["packages"][package]["check_assets_returned_value"]["assets_to_ingest"]
            # for asset in mock:
            for asset in self.packages[package]["check_assets_returned_value"]["assets_to_ingest"]:
                print(asset)
                # asset["preset_id"] example: AVC-576i25-STB
                type_of_platform = asset["preset_id"].split("-")[0]
                type_of_device = asset["preset_id"].split("-")[-1]
                if platform:
                    if platform == "selene":
                        if type_of_platform == "AVC" and type_of_device == movie_type.upper():
                            result = True
                    elif platform == "eos":
                        if type_of_platform == "HEVC" and type_of_device == movie_type.upper():
                            result = True
                elif movie_type.upper() in asset["preset_id"]:
                    result = True
                if result:
                    break
        else:
            self.log_variables(self.was_movie_type_ingested, locals())
            raise Exception("Wrong actual_dag was given in 'was_movie_type_ingested' method")

        BuiltIn().log_to_console("Result: %s\n" % result)
        self.log_variables(self.was_movie_type_ingested, locals())
        return result

    @easy_debug
    def is_dag_started(self, package, package_dict):
        """A method to check was DAG workflow was started or not yet

        :param package: package name, string
        :param package_dict: package data, dictionary
        :return: boolean status
        """
        dag_started = False
        for mask in package_dict["airflow_workers_logs_masks"]:
            if "/check_assets/" in mask:
                dag_started = True
                BuiltIn().log_to_console("DAG was started for package %s" % package)
                break

        self.log_variables(self.is_dag_started, locals())
        return dag_started

    @easy_debug
    def get_movie_type(self, e2e_obj, package):
        """ A method to pass a movie type depends to provided exist data in package dictionary

        :param e2e_obj: current class object
        :param package: package name, str
        :return: None or movie type as a string
        """
        try:
            movie_type = e2e_obj.packages[package]["movie_type"]
        except KeyError:
            movie_type = None

        self.log_variables(self.get_movie_type, locals())
        BuiltIn().log_to_console("movie_type: %s" % movie_type)
        return movie_type

    @easy_debug
    def get_package_log_masks(self, package):
        """A method to return log masks of the package. Method is created to optimize unit tests to mock

        :param package: package name, str

        :return: list of log masks, [] otherwise.
        """
        return self.packages[package]["airflow_workers_logs_masks"]

    @easy_debug
    def get_all_thumbnails_aspect_ratio_from_output_tva(self, path_to_output_tva, airflow_workers_logs_masks):
        """A method to get list of aspect ratio of all thumbnails images from output TVA file

        :param path_to_output_tva: absolute path to output TVA file, string
        :return: list of float values
        """

        thumbnails_workflow_enabled = self.insure_thumbnails_workflow_enabled(airflow_workers_logs_masks)
        if thumbnails_workflow_enabled:
            all_aspect_ratio = []
            image_urls_list = self.get_all_thumbnails_urls_from_output_tva(path_to_output_tva)
            if image_urls_list:
                for image_url in image_urls_list:
                    media_info_json = self.get_mediainfo_by_url(image_url)
                    for track in media_info_json["tracks"]:
                        if track["track_type"] == "Image":
                            aspect_ratio = self.get_image_aspect_ratio(track["height"], track["width"])
                            all_aspect_ratio.append(aspect_ratio)
            else:
                self.log_variables(self.get_all_thumbnails_aspect_ratio_from_output_tva, locals())
                raise Exception("Empty image_urls_list =(")
            self.log_variables(self.get_all_thumbnails_aspect_ratio_from_output_tva, locals())
            all_aspect_ratio = list(set(all_aspect_ratio))
        else:
            all_aspect_ratio = "thumbnails_workflow is disabled"
        return all_aspect_ratio

    @easy_debug
    def get_mediainfo_by_url(self, image_url):
        """Method to get mediainfo json object by given URL of image

        :param image_url: URL to image, string
        :return: megiainfo, json
        """
        media_info_json = {}
        image_name = image_url.split("/")[-1]
        image_download_status_code = self.tools.run_local_command(
            "curl -s %s > %s" % (image_url, image_name))
        if image_download_status_code == 0:
            media_info_string = pymediainfo.MediaInfo.parse(image_name).to_json()
            media_info_json = json.loads(media_info_string)
            self.tools.run_local_command("rm -rf %s" % image_name)
        else:
            BuiltIn().log_to_console("Error when download image %s" % image_url)
        self.log_variables(self.get_mediainfo_by_url, locals())
        return media_info_json

    @easy_debug
    def get_all_thumbnails_urls_from_output_tva(self, path_to_output_tva):
        """A method to get list of URLs of all thumbnails images from output TVA file

        :param path_to_output_tva: absolute path to output TVA file, string
        :return: list of string values
        """
        image_urls_list = []
        path_to_output_tvalist = path_to_output_tva.rsplit('/', 1)
        output_tva_content = self.read_tva(path_to_output_tvalist[0], path_to_output_tvalist[1])
        # output_tva_content = mock_data["robot"]["Libraries"]["IngestionE2E"]["helpers.py"]["get_all_thumbnails_urls_from_output_tva"]["output_tva_content"]["ts0000"]
        program_information = output_tva_content["TVAMain"]["ProgramDescription"]["ProgramInformationTable"]["ProgramInformation"]
        for information in program_information:
            related_materials = information["BasicDescription"]["RelatedMaterial"]
            related_materials_list = isinstance(related_materials, list)
            if related_materials_list:
                for material in related_materials:
                    url = material["MediaLocator"]["MediaUri"]["#text"]
                    if "/Thumbnails/" in url:
                        image_urls_list.append(str(url))
            else:
                url = related_materials["MediaLocator"]["MediaUri"]["#text"]
                if "/Thumbnails/" in url:
                    image_urls_list.append(str(url))


        self.log_variables(self.get_all_thumbnails_urls_from_output_tva, locals())
        return image_urls_list

    @easy_debug
    def get_manifest_url_from_log(self, log_masks, actual_dag, device_type=""):
        """Method to get manifest url from log like:
        /usr/local/airflow/logs/csi_lab_create_obo_assets_workflow/perform_movie_selene_video_qc/2019-03-25T11:50:58/1.log
        /usr/local/airflow/logs/csi_lab_create_obo_assets_workflow/perform_movie_ott_video_qc/2019-03-25T11:50:58/1.log
        /usr/local/airflow/logs/csi_lab_create_obo_assets_workflow/perform_movie_stb_video_qc/2019-03-25T11:50:58/1.log

        :param log_masks: list of path to logs from ingestion RESULT object
        :param device_type: type of device, as "stb, "ott" or "selene"
        :param actual_dag: DAG type used for the ingestion
        :return: absolute path to Manifest url
        """
        particular_log_path = ""
        log_names = {
            "csi_lab_create_obo_assets_transcoding_driven_workflow": "perform_videos_qc",
            "ecx_superset_create_obo_assets_transcoding_driven_workflow": "perform_videos_qc",
            "csi_lab_create_obo_assets_workflow": "perform_movie_%s_video_qc" % device_type,
            "ecx_superset_create_obo_assets_workflow": "perform_movie_%s_video_qc" % device_type
        }
        for log in log_masks:
            if log_names[actual_dag] in log:
                particular_log_path = log
        if particular_log_path:
            # DEBUG:
            # log_data = "http://wp1-pod1-vod-nl-labe2esuperset.lab.cdn.dmdsdp.com/sdash/055315bd59fc4db9191542fab5b45d8b_ac61d6692d0ac554ff031e3fc2450771/index.mpd/Manifest?device=STB-AVC-DASH"
            log_data = self.get_log_data(particular_log_path)

            # pattern will match string like:
            # http://wp1-pod1-vod-nl-labe2esuperset.lab.cdn.dmdsdp.com/sdash/055315bd59fc4db9191542fab5b45d8b_ac61d6692d0ac554ff031e3fc2450771/index.mpd/Manifest?device=STB-AVC-DASH
            pattern = "http.+\/Manifest\?device\=[a-z,A-Z,0-9,-]+"
            urls = []
            for line in log_data:
                url = re.findall(pattern, line)
                if url:
                    urls.append(url[0])
        else:
            self.log_variables(self.get_manifest_url_from_log, locals())
            raise Exception("Path to '%s' log file was not found in log masks list" % log_names[actual_dag])

        self.log_variables(self.get_manifest_url_from_log, locals())
        transcoding_driven_workflows = \
            ["csi_lab_create_obo_assets_transcoding_driven_workflow",
             "ecx_superset_create_obo_assets_transcoding_driven_workflow"]
        if actual_dag in transcoding_driven_workflows:
            manifest_url = urls
            return manifest_url
        manifest_url = urls[0]
        return manifest_url

    @easy_debug
    def get_image_aspect_ratio(self, height, width):
        "Simple method to calculate aspect ration based on image size"
        BuiltIn().log_to_console("Started in method 'get_image_aspect_ratio'")
        result = round(float(width) / float(height), 2)
        BuiltIn().log_to_console("Done in method 'get_image_aspect_ratio'. Result: %s" %
                                 result)
        self.log_variables(self.get_image_aspect_ratio, locals())
        return result

    @easy_debug
    def get_image_size(self, path_to_file):
        """A method to get height, width of physical image

        :param path_to_file: absolute or relative path to image, string
        :return: height, width
        """
        path = os.path.join(FOLDER, path_to_file)
        self.log_variables(self.get_image_size, locals())
        with Image.open(path) as image:
            width, height = image.size
        return height, width

    @easy_debug
    def get_asset_thumbnails_count(self, package_name, fabrix_asset_id):
        """A method to get count of thumbnails of particular asset

        :param package_name: name of the package, string
        :param fabrix_asset_id: id of the asset, string
        :return: count of thumbnails, int
        """
        BuiltIn().log_to_console("Started in method 'get_asset_thumbnails_count'")
        cnf = self.conf["AIRFLOW_WORKERS"][0]
        command = "ls -l %s/*%s/thumbnails/%s | grep .jpg | wc -l" % (
            cnf["managed_folder"], package_name, fabrix_asset_id)
        stdout, stderr = self.tools.run_ssh_cmd(cnf["host"], cnf["port"],
                                                cnf["user"], cnf["password"],
                                                command)
        if stderr:
            self.log_variables(self.get_asset_thumbnails_count, locals())
            raise Exception("Error when trying to get_asset_thumbnails_count: %s" % stderr)

        if stdout:
            self.log_variables(self.get_asset_thumbnails_count, locals())
            BuiltIn().log_to_console(
                "Done in method 'get_asset_thumbnails_count'. Result: %s" % stdout)
            return int(stdout)
        # else:
        self.log_variables(self.get_asset_thumbnails_count, locals())
        raise Exception("No thumbnails was found for asset %s (package %s)" % (
            fabrix_asset_id, package_name
        ))

    @easy_debug
    def get_asset_general_duration_in_seconds(self, package_name, fabrix_asset_id):
        """A method to get duration from 'General' part of mediainfo of the asset

        ::param package_name: name of the package, string
        :param fabrix_asset_id: id of the asset, string
        :return: duration in seconds, int
        """
        BuiltIn().log_to_console("Started in method 'get_asset_general_duration_in_seconds'")
        cnf = self.conf["AIRFLOW_WORKERS"][0]
        command = "mediainfo %s/*%s/%s | grep -m 1 Duration | awk '{print substr($0, index($0,$3))}'" % (
            cnf["managed_folder"], package_name, fabrix_asset_id)
        stdout, stderr = self.tools.run_ssh_cmd(cnf["host"], cnf["port"],
                                                cnf["user"], cnf["password"],
                                                command)
        if stderr:
            self.log_variables(self.get_asset_general_duration_in_seconds, locals())
            raise Exception("Error when trying to get_asset_general_duration_in_seconds: %s" % stderr)
        if stdout:
            if "min" in stdout:
                # output = "1 min 26 s"
                duration_seconds = (int(stdout.split(" ")[0]) * 60) + int(stdout.split(" ")[-2])
            else:
                # output = "53 s"
                duration_seconds = int(stdout.split(" ")[0])
            BuiltIn().log_to_console(
                "Done in method 'get_asset_general_duration_in_seconds'. Result: %s" %
                duration_seconds)
            self.log_variables(self.get_asset_general_duration_in_seconds, locals())
            return duration_seconds
        # else:
        raise Exception("Duration string was not fount for %s fabrix_asset_id" % fabrix_asset_id)

    @easy_debug
    def get_all_thumbnails_urls(self, fabrix_asset_id, attempts=120):
        """A method to get all urls to download a thumbnails based on response of WEBVTT
        Call example:
        GET to https://staticqbr-nl-labe2esuperset.lab.cdn.dmdsdp.com/thumbnail-service/assets/51b8158b5d018542769ae4e7f457563f_3db98b518644918080e48343bdb644a1

        :param fabrix_asset_id: id of the asset, string
        :return: list of all urls
        """
        BuiltIn().log_to_console("Started in method 'get_all_thumbnails_urls'")
        url = "https://%s/thumbnail-service/assets/%s" % (
            self.conf["MICROSERVICES"]["STATICQBR"], fabrix_asset_id)
        all_thumbnails_urls = []
        resp = urllib.request.urlopen(url)
        status_code = resp.code
        if status_code in ["200", 200]:
            BuiltIn().log_to_console("We got valid response code when reached %s" % url)
            resp_list = resp.read().splitlines()
            for item in resp_list:
                item = general.insure_text(item)
                if "/thumbnail-service/" in item:
                    all_thumbnails_urls.append(item)
        elif status_code in ["404", 404, "400", 400] and attempts > 0:
            attempts -= 1
            BuiltIn().log_to_console("We got %s when tried to reach %s. Sleep for 30 sec and retry"
                                     % (status_code, url))
            time.sleep(30)
            BuiltIn().log_to_console("Attempts left %s" % attempts)
            self.log_variables(self.get_all_thumbnails_urls, locals())
            return self.get_all_thumbnails_urls(fabrix_asset_id, attempts)
        else:
            message = "Unexpected status code %s when trying to reach %s" % (status_code, url)
            BuiltIn().log_to_console(message)
            return message

        BuiltIn().log_to_console("Done in method 'get_all_thumbnails_urls'. Result: %s" %
                                 all_thumbnails_urls)
        self.log_variables(self.get_all_thumbnails_urls, locals())
        return all_thumbnails_urls

    @easy_debug
    def insure_thumbnails_workflow_enabled(self, airflow_workers_logs_masks):
        """A method to check was thumbnails_workflow switched ON or not

        :param airflow_workers_logs_masks: list of path to log from Airflow worker
        :return: True or False
        """
        BuiltIn().log_to_console("Started in method 'insure_thumbnails_workflow_enabled'")
        thumbnails_workflow_enabled = False
        for mask in airflow_workers_logs_masks:
            if "need_to_generate_thumbnails" in mask or \
                "submit_thumbnails_to_image_service" in mask or \
                "perform_thumbnails_qc_for_image_service" in mask:
                thumbnails_workflow_enabled = True
        self.log_variables(self.insure_thumbnails_workflow_enabled, locals())
        BuiltIn().log_to_console("Done in method 'insure_thumbnails_workflow_enabled'. Result: %s" %
                                 thumbnails_workflow_enabled)
        return thumbnails_workflow_enabled

    @easy_debug
    def get_thumbnails_size(self, thumbnail_url):
        """A method to get height, width of physical thumbnails

        :param thumbnail_url: url to download thumbnail
        :return: height, width
        """
        BuiltIn().log_to_console("Started in method 'get_thumbnails_size'")
        url = "https://%s%s" % (self.conf["MICROSERVICES"]["STATICQBR"], thumbnail_url)
        response = requests.get(url)
        temp_file = "thumbnails.png"
        path_to_temp_file = os.path.join(FOLDER, temp_file)
        with open(path_to_temp_file, 'wb') as f:
            content = general.insure_bytes(response.content)
            f.write(content)
        height, width = self.get_image_size(temp_file)
        os.remove(path_to_temp_file)
        self.log_variables(self.get_thumbnails_size, locals())
        BuiltIn().log_to_console("Done in method 'get_thumbnails_size'. Result: (%s, %s)" %
                                 (height, width))
        return height, width

    @easy_debug
    def get_assets_from_generate_tva_file(self, logfile_path, host="AIRFLOW_WORKERS"):
        """
        A method to get generate tva file assets
        :param logfile_path: file path on the airflow workers
        :param host: Airflow workers tag present in conf file
        :return: assets returned in dictionary format
        """
        # pattern for find the assets in generate tva file
        asset_pattern = "\{\'assets\'\: \[.*\}\]\}"
        command = 'grep -Po "%s" %s' % (asset_pattern, logfile_path)

        if logfile_path:
            for cnf in self.conf[host]:

                stdout = self.tools.run_ssh_cmd(cnf["host"], cnf["port"], cnf["user"], cnf["password"], command)[0]

                if stdout:
                    generate_tva_file_assets_dict = ast.literal_eval(str(stdout))
                    self.log_variables(self.get_assets_from_generate_tva_file, locals())
                    return generate_tva_file_assets_dict
            self.log_variables(self.get_assets_from_generate_tva_file, locals())
            raise Exception("Log file is *NOT* present on the '%s' servers for the path %s" % (host, logfile_path))

        self.log_variables(self.get_assets_from_generate_tva_file, locals())
        raise Exception("logfile_path parameter passed is *NOT* valid on the '%s' servers" % (host))

    @easy_debug
    def check_dag_workflow_steps_status(self, tvafile_path, service, dag):
        """A method to check the DAG workflow services

        :param tvafile_path: output TVA filename, string
        :param dag: Actual DAG used for ingestion, string
        :param service: DAG workflow service that need to be checked, string
        :return: failed reason, string
        """

        if not service:
            self.log_variables(self.check_dag_workflow_steps_status, locals())
            raise Exception("Service workflow check is invalid, check service string: %s" % service)
        tva_url = "http://%s/dag_runs?filename=%s"%(self.conf["AIRFLOW_API"]["host"], tvafile_path)
        tva_request = requests.get(tva_url)
        BuiltIn().log_to_console("TVA file AF api url : %s" % tva_request.url)
        BuiltIn().log_to_console("TVA file AF api response code :  %s" % tva_request.status_code)
        BuiltIn().log_to_console("TVA file AF api resason :  %s" % tva_request.reason)

        if tva_request.status_code == 200:
            tva_response = tva_request.json()["items"]
            # BuiltIn().log_to_console("TVA file ingested workflow details %s" % tva_response)
            if tva_request.json()["count"] != 1:
                self.log_variables(self.check_dag_workflow_steps_status, locals())
                raise Exception("%s file ingested workflow details is not valued %s" % (tvafile_path, tva_url))
        else:
            self.log_variables(self.check_dag_workflow_steps_status, locals())
            raise Exception("%s file url for ingested workflow details is not valued %s" % (tvafile_path, tva_url))

        tasks_url = "http://%s/dag_runs?execution_date__gt=%s&dag_id=%s&relations=tasks" % (self.conf["AIRFLOW_API"]["host"], tva_response[0]["execution_date"], dag)
        tasks_request = requests.get(tasks_url)
        BuiltIn().log_to_console("DAG execution AF api url : %s" % tva_request.url)
        BuiltIn().log_to_console("DAG execution AF api response code :  %s" % tva_request.status_code)
        BuiltIn().log_to_console("DAG execution AF api resason :  %s" % tva_request.reason)
        if tasks_request.status_code == 200:
            # BuiltIn().log_to_console("We got a valid response code when reached url %s" % tasks_url)
            dag_runs_response = tasks_request.json()["items"]
            if tasks_request.json()["count"] == 0:
                self.log_variables(self.check_dag_workflow_steps_status, locals())
                raise Exception("%s Workflow tasks list is not valued for url: %s" % (dag, tasks_url))
        else:
            self.log_variables(self.check_dag_workflow_steps_status, locals())
            raise Exception("%s ingested workflow url is not valued: %s" % (dag, tasks_url))
        for dag_run in dag_runs_response:
            if "filename" in list(dag_run.keys()):
                if tvafile_path in dag_run["filename"]:
                    dag_tasks = dag_run["tasks"]
                    # BuiltIn().log_to_console("Dag_tasks found for the tvafile %s is %s" % (tvafile_path, dag_tasks))
                    break
            else:
                self.log_variables(self.check_dag_workflow_steps_status,
                                   locals())
                raise Exception("'filename' key was not found in dag_run of the following "
                                "API response:\n\n%s\n\n" % dag_runs_response)
        failed_reason = ""
        if dag_tasks:
            for task in dag_tasks:
                if service in task["task_id"]:
                    if "success" in task["state"]:
                        # BuiltIn().log_to_console("Dag_tasks found for the tvafile %s is %s" % (tvafile_path, task))
                        continue
                    failed_reason = "Linear_cycle_validation failed for the service: %s" % service
                    self.log_variables(self.check_dag_workflow_steps_status, locals())
                    return failed_reason
        return failed_reason

    @easy_debug
    def make_package_copy(self, package, package_copy_name, environment="obocsi"):
        """A method to make a copy of the package

        :param package: package name, string.
        :package_copy_name: name of package copy
        :param environment: lab name, string
        """

        BuiltIn().log_to_console("\nI'm going to make copy of package %s" % package)
        offer_folder_name = self.get_offer_folder_name_from_asset_generator_host(package,
                                                                                 environment)
        package_folder_name = self.get_package_folder_name_from_asset_generator_host(package,
                                                                                     environment)
        package = package.replace("pt", "").replace("ot", "")
        package_copy_name = package_copy_name.replace("pt", "").replace("ot", "")
        host = self.conf["ASSET_GENERATOR"]["host"]
        port = self.conf["ASSET_GENERATOR"]["port"]
        user = self.conf["ASSET_GENERATOR"]["user"]
        password = self.conf["ASSET_GENERATOR"]["password"]
        offer_command = "cp -r %s/%s/%s  %s/%s/%s" % (
            self.conf["ASSET_GENERATOR"]["path"], environment, offer_folder_name,
            self.conf["ASSET_GENERATOR"]["path"], environment, offer_folder_name.replace(
                package, package_copy_name)
        )
        package_command = "cp -r %s/%s/%s  %s/%s/%s" % (
            self.conf["ASSET_GENERATOR"]["path"], environment, package_folder_name,
            self.conf["ASSET_GENERATOR"]["path"], environment, package_folder_name.replace(
                package, package_copy_name)
        )
        command = "%s && %s" % (offer_command, package_command)
        stdout, stderr = self.tools.run_ssh_cmd(host, port, user, password, command)
        stdout_to_log = stdout
        stderr_to_log = stderr
        BuiltIn().log_to_console(
            "\n copy_package_and_offer command: %s\nStdout: %s\nStderr: %s\n" % (
                command, stdout_to_log, stderr_to_log))
        self.log_variables(self.unhold_package_and_offer, locals())
        return stdout

    @easy_debug
    def check_modified_on_og_server_adi_file_was_processed(self, path_to_adi, delay=60):
        """Based on tests steps from HES-6241 we move xml file from
        /opt/og/Countries/CSI/export/adi/ to
        /opt/og/Countries/CSI/export/
        After some time xml file have to be proccessed and moved back by Airflow.
        By this method we check, was this file moved back or not

        :param path_to_adi: absolete path to .xml file
        :param delay: time to wait
        :return: True or Falce
        """
        processed = False
        ssh_creds = [self.conf["OG"][0]["host"], self.conf["OG"][0]["port"],
                     self.conf["OG"][0]["user"], self.conf["OG"][0]["password"]]

        command = "ls -l %s" % path_to_adi
        time_to_wait = datetime.datetime.now() + datetime.timedelta(minutes=delay)
        while datetime.datetime.now() < time_to_wait and not processed:
            stdout, stderr = self.tools.run_ssh_cmd(*(ssh_creds + [command]))
            # BuiltIn().log_to_console("stdout: %s" % stdout)
            # BuiltIn().log_to_console("stderr: %s\n" % stderr)
            if not stderr and "-rwxr-xr-x 1 og flowusers" in stdout and path_to_adi in stdout:
                processed = True
            else:
                BuiltIn().log_to_console("Adi file was not processed yet. I'll wait for 60 sec...")
                time.sleep(60)
        self.log_variables(
            self.check_modified_on_og_server_adi_file_was_processed, locals())
        return processed

    @easy_debug
    def get_package_name_from_log(self, path_to_log, pattern):
        """A method to package name from particular log based on regex pattern

        :param path_to_log: absolete path to log, string
        :param pattern: regex pattern, string
        :return: package_name, string
        """
        result = ""
        command = "cat %s | grep -Po '%s' | head -1" % (path_to_log, pattern)
        for airflow_node in self.conf["AIRFLOW_WORKERS"]:
            ssh = [airflow_node["host"], airflow_node["port"],
                   airflow_node["user"], airflow_node["password"]]
            stdout, stderr = self.tools.run_ssh_cmd(*(ssh + [command]))
            if stderr:
                # BuiltIn().log_to_console(stderr)
                continue
            if re.match(pattern, stdout):
                # BuiltIn().log_to_console(stdout)
                result = stdout
                break
        self.log_variables(self.get_package_name_from_log, locals())
        if not result:
            raise Exception("Package name was not detected in 'get_package_name_from_log' "
                            "helper method")
        return result

    @easy_debug
    def get_airflow_page_html(self, destination_page_url, login_creds, web_server):
        """Method to go through AirFlow web server authorization to any iner page and return html of
        target page as text
        :param destination_page_url: url of destination page
        :param login_creds: dictionary what contains two keys: username and password
        :param web_server: dictionary what contains "host" key as FQDN or IP of web server

        :return: html of target page as text
        """
        destination_page_text = ""
        with requests.Session() as session:
            login_url = "http://%s/login" % web_server["host"]
            # Don't verify https certificate and disable warning about this action
            # Have bug affected pylint https://github.com/requests/requests/issues/4104
            requests.packages.urllib3.disable_warnings(  # pylint: disable=E1101
                requests.packages.urllib3.exceptions.InsecureRequestWarning)  # pylint: disable=E1101
            get_response = session.get(login_url, verify=False)
            if get_response.status_code not in [200, 201]:
                BuiltIn().log_to_console("To login to AirFlow UI we sent GET to %s\n"
                                         "Status code: %s. Reason: %s" %
                                         (login_url, get_response.status_code, get_response.reason))
            parsed_login_page_html = BeautifulSoup(get_response.text, "lxml")
            html_input_tag = parsed_login_page_html.body.findAll(
                "input", attrs={"id": "csrf_token"})
            csrf_token = html_input_tag[0]["value"]
            login_creds["_csrf_token"] = csrf_token
            post_response = session.post(login_url, data=login_creds, verify=False)
            if post_response.status_code not in [200, 201]:
                BuiltIn().log_to_console("To login to AirFlow UI we sent POST to %s\n"
                                         "Data: %s\nStatus code: %s. Reason: %s" %
                                         (login_url, login_creds, post_response.status_code,
                                          post_response.reason))

            destination_page_response = session.get(destination_page_url,
                                                    cookies=session.cookies, verify=False)
            if destination_page_response.status_code not in [200, 201]:
                BuiltIn().log_to_console("To go to destination page we sent GET to %s\n"
                                         "Status code: %s. Reason: %s" %
                                         (destination_page_url,
                                          destination_page_response.status_code,
                                          destination_page_response.reason))
            else:
                destination_page_text = destination_page_response.text
        self.log_variables(self.get_airflow_page_html, locals())
        return destination_page_text

    @easy_debug
    def get_log_from_airflow_web(self, log_url, url_from_api_response=True, convert_to_utc=True):
        """A method to get airflow log data from AirFlow web ui server under the authorization
        URL to get log is builded based on sub-request structure what AirFlow do
        (check in network tab of HTML page inspector in your browser) to display log on the page

        :param log_url: direct url to log or log_url from AF API response
        :param url_from_api_response: if url was takken from API response
        (format "/log?dag_id=ecx_superset_create_obo_assets_transcoding_driven_workflow&task_id=trigger_dag&execution_date=2019-10-26T00:14:49")
        :param convert_to_utc: if url was takken from API response we need to convert time zone
        :return: log content as string
        """
        if url_from_api_response:
            dag_id = ""
            task_id = ""
            execution_date = ""
            params = log_url.split("?")[1].split("&")
            for param in params:
                papam_name, param_value = param.split("=")
                if papam_name == "dag_id":
                    dag_id = param_value
                if papam_name == "task_id":
                    task_id = param_value
                if papam_name == "execution_date":
                    execution_date = param_value

            if not dag_id and not task_id and not execution_date:
                self.log_variables(self.get_log_from_airflow_web, locals())
                raise Exception("Failed to parse log_url")

            if execution_date and convert_to_utc:
                execution_date = datetime.datetime.strptime(execution_date, "%Y-%m-%dT%H:%M:%S") - datetime.timedelta(hours=2)
                execution_date = datetime.datetime.strftime(execution_date, "%Y-%m-%dT%H:%M:%S")

        log_url = "http://%s/get_logs_with_metadata?dag_id=%s&task_id=%s&execution_date=%s&try_number=1&metadata=null" % (
            self.conf["AIRFLOW_WEB"]["host"], dag_id, task_id, execution_date)
        log_data = self.get_airflow_page_html(
            log_url, self.conf["AIRFLOW_WEB_CREDENTIALS"], self.conf["AIRFLOW_WEB"])
        self.log_variables(self.get_log_from_airflow_web, locals())
        return log_data
