# pylint: disable=W0621
# pylint: disable=W0702
# pylint: disable=C0301
# pylint: disable=R0914
# pylint: disable=R0912
"""
Common utilities
"""
import os
import platform
import re
import subprocess
from datetime import datetime
from shutil import rmtree
import json
import time
import requests
import yaml
from robot.libraries.BuiltIn import BuiltIn
import plotly
import plotly.graph_objects as go

# from Utils.multi_room.multi_room_yml_parser import MultiRoomYmlParser

# pylint: disable=no-self-use

MEMORY_USAGE_PARSING_SCRIPT_PATH = \
    'Utils/stb_monitoring/memory_usage/mem_monitor_parser.py'
MEMORY_USAGE_GRAPH_PLOTTING_SCRIPT_PATH = \
    'Utils/stb_monitoring/memory_usage/csvgraph.py'
MEMORY_REGRESSION_PLOTTING_SCRIPT_PATH = \
    'Utils/stb_monitoring/memory_usage/regression_coefficient.py'
_LOG_RETRIEVAL_SCRIPT_NAMES = {'Windows': 'log_automation.exe',
                               'Linux': 'log_automation.elf'}
_LOG_ARCHIVE_NAME = 'log.zip'


class DefaultRequestFactory(object):
    """Default implementation of requests factory using requests module"""

    def get(self, url, params=None, **kwargs):
        """issue get request"""
        return requests.get(url, params, **kwargs)

    def post(self, url, data=None, json=None, **kwargs):
        """issue post request"""
        return requests.post(url, data, json, **kwargs)

    def put(self, url, data=None, **kwargs):
        """issue put request"""
        return requests.put(url, data, **kwargs)

    def delete(self, url, **kwargs):
        """issue delete request"""
        return requests.delete(url, **kwargs)


def get_pool_config_from_file(pool_orchestrator_hostname, remark,
                              rack_details_yml_file_path, is_remark=True):
    """
    Returns array of stb slot configurations from pool attached to given
    orchestrator.
    :param pool_orchestrator_hostname: orchestrator hostname
    :param remark: remark that stb slot configuration must match
    :param rack_details_yml_file_path: rack details file path
    :param is_remark: to include remark parameter or not
    :return: array of dicts containing stb slot configuration
    """
    with open(rack_details_yml_file_path) as yml_file:
        document = yaml.load(yml_file, Loader=yaml.FullLoader)

    if remark == '':
        remark = None

    result = []
    for entry in document:
        if pool_orchestrator_hostname in entry['RACK_SLOT_ID'] and \
                entry['TEST_STATUS'] == remark and is_remark is True:
            result.append(entry)
        elif pool_orchestrator_hostname in entry['RACK_SLOT_ID'] and \
                is_remark is False:
            result.append(entry)
    return result


def get_non_consistent_channel_numbers():
    """
    Get the non-consistent channel number list for 248 and 912 channels.
    :return: List of channel numbers which are not consistent.
    """
    non_consistent_channel_numbers = list()
    non_consistent_channel_numbers.append(248)  # Netflix channel

    return non_consistent_channel_numbers


class LogArtifactStore(object):
    """
    Store for log artifacts
    Creates directory ./var/log/onemt/<subdir> for storing log artifacts
    """

    @staticmethod
    def new_path(subdir, basename, extension, dry_run=False):
        """
        Returns unique path for log artifact. Name is composed as follows
        <store path>/<basename>-<timestamp>-<uuid>.<extension>
        :param subdir: the <subdir> component, "" means 'no subdir'
        :param basename: basename component of file name w/o extension
        :param extension: extension of file name
        :param dry_run: do not make any changes to filesystem
        :return: unique path
        """
        path = os.path.join(
            os.path.abspath(os.path.dirname(__file__)), '..', '..', subdir)
        if not os.path.exists(path) and not dry_run:
            os.makedirs(path)
        timestamp = datetime.now().strftime('%Y_%m_%d__%H_%M_%S_%f')
        filename = timestamp + '-' + basename + '.' + extension
        return os.path.join(path, filename)


class AnalyzeMemoryUsage(object):
    """
    Analyze memory usage of the STB
    """

    def parse_memory_usage_from_logs(self, log_file):
        """
        Parse memory usage from the log file
        :param log_file: Output log file name of mem_monitor.sh
        :return: Parsed csv file name
        """
        if os.path.isfile(log_file):
            file_name = os.path.splitext(log_file)[0]
            parsed_csv_file = file_name + '.csv'
            os.system('python ' + MEMORY_USAGE_PARSING_SCRIPT_PATH + ' -i ' +
                      log_file + ' -o ' + parsed_csv_file)
            if not os.path.exists(parsed_csv_file):
                raise RuntimeError("Unable to parse the memory usage log file")
        else:
            raise ValueError("Input file is not available")

        return parsed_csv_file

    def plot_memory_usage_graph(self, csv_file, stackplot_type='s'):
        """
        Plot graph from the memory usage csv file
        :param csv_file: Memory usage csv file
        :param stackplot_type: stack plot type 's' if not type 'n'
        :return: Plotted graph name
        """
        if os.path.isfile(csv_file):
            file_name = os.path.splitext(csv_file)[0]
            line_graph_path = file_name + '.png'
            stacked_graph_path = file_name + '_stack.png'
            os.system('python ' + MEMORY_USAGE_GRAPH_PLOTTING_SCRIPT_PATH +
                      ' ' + csv_file + ' ' + stackplot_type)
            if not (os.path.exists(line_graph_path) and
                    os.path.exists(stacked_graph_path)):
                raise RuntimeError(
                    "Failed to generate the memory usage graphs")
        else:
            raise ValueError("Input file is not available")

        return line_graph_path, stacked_graph_path

    def plot_memory_regression(self, csv_file):
        """
        Plot regression graph from the memory usage csv file
        :param csv_file: Memory usage csv file
        :return: Plotted regression graph path
        """
        if os.path.isfile(csv_file):
            file_name = os.path.splitext(csv_file)[0]
            regression_graph_path = file_name + '_reg_coefficient.png'
            os.system('python ' + MEMORY_REGRESSION_PLOTTING_SCRIPT_PATH +
                      ' ' + csv_file)
            if not os.path.exists(regression_graph_path):
                raise RuntimeError(
                    "Failed to generate the memory regression graph")
        else:
            raise ValueError("Input file is not available")

        return regression_graph_path

    @staticmethod
    def create_dir_if_not_exists_in_rl(dir_path):
        """
        Create directory recursively in remote library running PC if not exists
        :param dir_path:
        :return: Requested path
        """
        if os.path.exists(dir_path):
            if not os.path.isdir(dir_path):
                os.remove(dir_path)
                os.makedirs(dir_path)
        else:
            os.makedirs(dir_path)

        return dir_path

    @staticmethod
    def create_file_if_not_exists_in_rl(file_path):
        """
        Create file in remote library running PC if not exists
        :param file_path: the file path to create
        :return: Requested path
        """
        if os.path.exists(file_path):
            if not os.path.isfile(file_path):
                os.remove(file_path)
        with open(file_path, "w") as rl_file:
            rl_file.write("")

        return file_path


class StbCollectibles(object):
    """
    Class to help retrieve data/collectibles(logs/state-information, etc)
    from the STB
    """

    @staticmethod
    def _get_script_name():
        """
        Get the log retrieval script name for the native OS
        """
        native_os_type = platform.system()
        if native_os_type == 'Windows':
            script_name = _LOG_RETRIEVAL_SCRIPT_NAMES['Windows']
        else:
            script_name = _LOG_RETRIEVAL_SCRIPT_NAMES['Linux']
        return script_name

    @staticmethod
    def _prepare_directory(dir_name):
        """
        Prepare a temporary directory to execute the log retrieval script
        :param dir_name: Directory name to create in remote library location
        :return: Previous working directory path
        """
        if dir_name is None or '':
            raise \
                ValueError('Invalid directory argument provided')
        if os.path.exists(dir_name):
            rmtree(dir_name)
        os.makedirs(dir_name)
        current_path = os.getcwd()
        os.chdir(os.path.realpath(dir_name))
        return current_path

    @staticmethod
    def _prepare_script(current_path, script_name, stb_ip):
        """
        Prepare script parameters for execution
        :param current_path: Default working directory of the Remote library
        :param script_name: Script name
        :return: <script_path>, <script_command>
        """
        script_path = os.path.join(current_path, 'Utils',
                                   'log_retrieval', script_name)
        script_command = script_path + ' ' + stb_ip
        return script_path, script_command

    @staticmethod
    def _execute_script(script_command):
        """
        Spawn thread to execute the script and wait for script to execute
        and finish.
        :param script_command: Command to execute the script
        :return: <std-output>, <std-error>
        """
        spawned_process = subprocess.Popen(script_command,
                                           stderr=subprocess.STDOUT,
                                           stdout=subprocess.PIPE,
                                           shell=True)
        stdout_data, stderr_data = spawned_process.communicate()
        return stdout_data, stderr_data

    @staticmethod
    def _validate_execution(stdout_data, script_path):
        """
        Validate artifacts from the script execution
        :param stdout_data: Std out from script execution
        :param script_path: script path
        :return: <updated-log-name>
        """
        log_name_search = re.search(
            '.*#\\s+(?P<log_name>logs_.*.zip)\\s+#.*', stdout_data)
        if log_name_search is None:
            raise \
                ValueError('Output log archive not reported by ' + script_path)
        log_name = log_name_search.group('log_name')
        renamed_log_name = _LOG_ARCHIVE_NAME
        os.rename(log_name, renamed_log_name)
        return renamed_log_name

    def _prepare_environment(self, value_set_name, stb_ip):
        """
        Get script details, prepare directory to execute the script in,
        and prepare the script command
        :param value_set_name: name of the pabot pool valueset acquired
        for test execution, same as rack_slot_id from rack_details.yml
        :param stb_ip: STB IP address
        :return: paths
        """
        script_name = self._get_script_name()
        current_path = self._prepare_directory(value_set_name)
        if current_path is None:
            return None, None, None
        script_path, script_command = self._prepare_script(
            current_path, script_name, stb_ip)
        return current_path, script_path, script_command

    @staticmethod
    def _cleanup_environment(original_path):
        """
        Change directory back to previous one. Dont delete the directory
        in which the script was executed
        """
        os.chdir(os.path.realpath(original_path))

    def extract_logs_from_stb_to_remote_library_location(
            self, value_set_name, stb_ip):
        """
        Runs the log_automation.exe/elf executable on Remote Library location,
        retrieves the logs/state-information from STB in <value_set_name>/
        folder, archives them and returns the stdout / stderror /
        log-archive-file-name. The final log archive name is 'log.zip'
        :param value_set_name: name of the pabot pool valueset acquired
        for test execution, same as rack_slot_id from rack_details.yml
        :param stb_ip: STB IP address
        :return: Std output, std error, and archived log zip name
        """
        current_path, script_path, script_command = self._prepare_environment(
            value_set_name, stb_ip)
        if (current_path or script_path or script_command) is None:
            raise ValueError('Environment not prepared')
        try:
            stdout_data, stderr_data = self._execute_script(script_command)
            renamed_log_name = self._validate_execution(stdout_data,
                                                        script_path)
        finally:
            self._cleanup_environment(current_path)
        return stdout_data, stderr_data, renamed_log_name

    @staticmethod
    def move_file_in_rl(old_path, new_path):
        """
        Moves file to new path.
        Is used instead to move
        files on rack machines when test executed on Jenkins.
        :param old_path: old file path
        :param new_path: new file path
        """
        os.rename(old_path, new_path)

    @staticmethod
    def create_file_in_rl(path, content):
        """
        Creates file with the given content.
        Is used instead to create files on rack machines
        with content when test executed on Jenkins.
        :param path: where to save
        :param content: Content to save
        """
        with open(path, 'w') as source:
            source.write(content.encode('UTF-8'))


class RackDetailsReader(object):
    """ Utility class for parsing rack_details.yml file """

    def __init__(self, rack_details_path):
        self._rack_details_path = rack_details_path

    def _read_rack_details_yml(self):
        with open(self._rack_details_path, 'r') as yaml_file:
            document = yaml.load(yaml_file, Loader=yaml.FullLoader)
        if not document:
            raise ValueError(
                'Invalid or empty .yml file ' + self._rack_details_path)
        return document

    def get_slot_config(self, slot):
        """
        get_slot_config returns specified row of rack details
        as a dictionary
        :param slot: stb slot for which config will be loaded
        :return: dictionary with STB data from rack details
        """
        rack_details_content = self._read_rack_details_yml()
        found_entry = None
        for entry in rack_details_content:
            if slot == entry['RACK_SLOT_ID']:
                found_entry = entry
                break
        if not found_entry:
            raise ValueError(
                "Entry for '" + slot + "' not found in '" +
                self._rack_details_path + "'")
        return found_entry

    @staticmethod
    def _entries_consistent(entries):
        keys_to_check = (
            'PDU_IP', 'RACK_PC_IP', 'RED_RAT_IR_IP',
            'TEST_STATUS', 'LAB_NAME', 'OBELIX_SUPPORT', 'PANORAMIX_SUPPORT',
            'PDU_TYPE', 'RACK_TYPE', 'REVERSE_PDU_SCHEMA', 'BROKER_URL',
            'DEGRADED_MODE_BROKER', 'XAP_URL', 'XAP_PORT')
        are_consistent = True
        first_entry = entries[0]
        for entry in entries:
            for key in keys_to_check:
                if first_entry.get(key) != entry.get(key):
                    are_consistent = False
                    break
        return are_consistent

    def get_rack_config(self, rack_id):
        """
        Gets general rack configuration based on the data of the first STB
        for given rack ID
        :param rack_id: rack prefix in RACK_SLOT_ID,
        i.e. ECX-DH5-C3-SVR2 in ECX-DH5-C3-SVR2-9
        :return: dictionary with rack configuration details
        """
        rack_details_content = self._read_rack_details_yml()
        entries = []
        for entry in rack_details_content:
            if entry['RACK_SLOT_ID'].startswith(rack_id):
                entries.append(entry)
        if not self._entries_consistent(entries):
            raise ValueError(
                'Rack entries for rack ID [{}] are not consistent'.format(
                    rack_id))
        entry = entries[0]
        return {
            'PDU_IP': entry['PDU_IP'],
            'RACK_PC_IP': entry['RACK_PC_IP'],
            'PLATFORM': entry['PLATFORM'],
            'RED_RAT_IR_IP': entry['RED_RAT_IR_IP'],
            'TEST_STATUS': entry['TEST_STATUS'],
            'LAB_NAME': entry['LAB_NAME'],
            'OBELIX_SUPPORT': entry['OBELIX_SUPPORT'],
            'PANORAMIX_SUPPORT': entry['PANORAMIX_SUPPORT'],
            'PDU_TYPE': entry['PDU_TYPE'],
            'RACK_TYPE': entry['RACK_TYPE'],
            'REVERSE_PDU_SCHEMA': entry.get('REVERSE_PDU_SCHEMA'),
            'BROKER_URL': entry['BROKER_URL'],
            'DEGRADED_MODE_BROKER': entry['DEGRADED_MODE_BROKER'],
            'XAP_URL': entry['XAP_URL'],
            'XAP_PORT': entry['XAP_PORT']
        }


class CaptureResultJson(object):
    """ Utility Class to Persist the result json variable into the file
    """

    @staticmethod
    def is_file_older_than_x_hours(full_path, hours=24):
        """
        :param full_path: Path of the file to check last modified
        :param hours: Time in hours We want to check
        :return: True or False if the File has been modified on hours time
        """
        file_modify = False
        try:
            file_time = os.path.getmtime(full_path)
            BuiltIn().log_to_console("*** DEBUG: Modif Time of %s File: %s ***"
                                     % (full_path, time.strftime('%Y-%m-%d %H:%M:%S',
                                                                 time.localtime(file_time))))
            if (time.time() - file_time) / 3600 > int(hours):
                file_modify = True
        except:
            BuiltIn().log_to_console("ERROR: Getting Modif Time of File: %s\n" % full_path)
        BuiltIn().log_to_console("INFO: File: %s Modify In last %s"
                                 " hours?: %s\n" % (full_path, hours, file_modify))
        return file_modify

    def create_result_json_and_html_report_from_results_files(
            self, path="execution_artifacts/results/", extension=".json"):
        """
        :param path: Path of the result files for the Suite and TestCases
        :param extension: extension of the result files for the Suite and TestCases
        :return:
        """
        ### START: ONLY FOR DEBUG
        # try:
        #     self.create_html_report()
        # except ValueError:
        #     BuiltIn().log_to_console("*** ERROR: While Generating HTML Report:\n"
        #                              "%s\n" % ValueError)
        # return True
        ### END: ONLY FOR DEBUG
        all_data = dict()
        filelist = [f for f in os.listdir(str(path)) if f.endswith(extension)]
        for filename in filelist:
            try:
                full_file_path = os.path.join(path, filename)
                # BuiltIn().log_to_console("\n*** DEBUG: Reading File: %s\n*** " % full_file_path)
                with open(full_file_path, 'r') as json_file:
                    data = json.load(json_file)
                    # BuiltIn().log_to_console("\n*** DEBUG: data: %s" % data)
                    # HARDOCODE Suite name file Suite.json
                    if "Suite" in filename:
                        all_data.update(data)
                    else:
                        if "allTestData" not in all_data:
                            all_data["allTestData"] = dict()
                        all_data["allTestData"][filename.replace(extension, "")] = data
                    # BuiltIn().log_to_console("*** DEBUG: all_data UPDATED: %s" % all_data)
                    json_file.close()
            except ValueError:
                BuiltIn().log_to_console("ERROR: While read data from: %s%s\n"
                                         "ValueError: %s\n" % (path, filename, ValueError))
        ## COUNT totalFailedTests so we can know total_tests and totalPassedTests
        all_data["totalFailedTests"] = 0
        all_data["stb_pool_used"] = list()
        all_data["cpes_used"] = list()
        for jira in list(all_data["allTestData"].keys()):
            # BuiltIn().log_to_console("\n\n*** DEBUG: While read data from key: %s ***\n" % jira)
            if all_data["allTestData"][jira]["status"] == "FAIL":
                all_data["totalFailedTests"] = all_data["totalFailedTests"] + 1
            if "rackSlotId" in all_data["allTestData"][jira] and\
                    all_data["allTestData"][jira]["rackSlotId"] not in all_data["stb_pool_used"]:
                all_data["stb_pool_used"].append(all_data["allTestData"][jira]["rackSlotId"])
            if "cpeId" in all_data["allTestData"][jira] and \
                    all_data["allTestData"][jira]["cpeId"] not in all_data["cpes_used"]:
                all_data["cpes_used"].append(all_data["allTestData"][jira]["cpeId"])

        all_data["totalTests"] = len(all_data["allTestData"])
        all_data["totalPassedTests"] = all_data["totalTests"] - all_data["totalFailedTests"]
        # BuiltIn().log_to_console("*** DEBUG: totalFailedTests %s" % all_data["totalPassedTests"])
        # BuiltIn().log_to_console("*** DEBUG: totalFailedTests %s" % all_data["totalFailedTests"])
        # BuiltIn().log_to_console("*** DEBUG: len(all_data[allTestData]) %s" % all_data["totalTests"])

        ### If the stb_pool is empty because we run it localy or with robot - not Pabot
        ### stb_pool will be equal to the stb_pool_used
        if "stb_pool" in all_data and "" in all_data["stb_pool"]:
            all_data["stb_pool"] = all_data["stb_pool_used"]

        ### Creating result.json file with all tests cases results ###
        self.persist_result_json(all_data)
        ### Creating HTML Quickreport.html ###
        try:
            self.create_html_report(all_data)
        except ValueError:
            BuiltIn().log_to_console("*** ERROR: While Generating HTML Report:\n"
                                     "%s\n" % ValueError)

    @staticmethod
    def read_json_from_file(full_path):
        """
        :param full_path: json file path to be read
        :return: json_data: json data read
        """
        BuiltIn().log_to_console("*** INFO: Started Reading %s File ***" % full_path)
        try:
            with open(full_path, 'r+') as json_file:
                json_data = json.load(json_file)
                json_file.close()
                BuiltIn().log_to_console("*** INFO: Completed: Reading Json from "
                                         "%s File ***" % full_path)
                return json_data
        except:
            BuiltIn().log_to_console("*** ERROR: Opening or Reading Json from"
                                     " %s File ***" % full_path)
            return dict()

    @staticmethod
    def save_json_to_file(full_path, dict_data):
        """
        :param full_path: json file path to be saved
        :param dict_data: dict data to be saved as json
        :return: True or False is file is saved or not
        """
        try:
            BuiltIn().log_to_console("*** INFO: Started Writing %s File ***" % full_path)
            with open(full_path, 'w') as json_file:
                json.dump(dict_data, json_file)
                json_file.close()
                BuiltIn().log_to_console("*** INFO: Completed: Writing To %s File ***" % full_path)
                return True
        except:
            BuiltIn().log_to_console("*** ERROR: Opening or Writing To %s File ***" % full_path)
            return False

    def persist_result_json(self, result_json_var):
        """
        :param result_json_var: Global variable which has all the json data
        :return:
        """
        self.save_json_to_file("execution_artifacts/result.json", result_json_var)

    def dict_key_unicode_to_str(self, data_dict, key):
        """
        Gets dict key value and convert it to string

        :data_dict dictionary to get the key to convert to string
        :key key of dict
        :return: string to be returned
        """
        try:
            string = str(data_dict[key])
        except UnicodeEncodeError:
            BuiltIn().log_to_console("\n*** ERROR: %s Unicode: %s ***\ndata_dict:\n%s\n"
                                     % (key, UnicodeEncodeError, data_dict))
            try:
                BuiltIn().log_to_console("*** TRYING: %s encode UTF-8 ***" % key)
                string = data_dict[key].encode('utf-8')
                string = str(string.replace('\xfc', ''))
            except:
                BuiltIn().log_to_console("\n *** ERROR: %s encode *** \n" % key)
        return string

    def create_html_report(self, complete_test_results="read_file"):
        """
        :param complete_test_results: If it is provide it will be all the data on result.json
        Method to create html data for report
        :return:
        """
        ## I Only read data from file if the complete_test_results is not provided
        if complete_test_results == "read_file":
            BuiltIn().log_to_console("****** Started Generation Of "
                                     "Report HTML from results.json File ******")
            complete_test_results = self.read_json_from_file('execution_artifacts/result.json')
        else:
            BuiltIn().log_to_console("****** Started Generation Of Report"
                                     " HTML from Provided Data ******")
        # BuiltIn().log_to_console("*** DEBUG: complete_test_results:\n"
        #                          "%s\n" % complete_test_results)
        total_pass = "NA"
        total_fail = "NA"
        total_result = "NA"
        if "totalPassedTests" in complete_test_results:
            total_pass = int(complete_test_results['totalPassedTests'])
            if "totalFailedTests" in complete_test_results:
                total_fail = int(complete_test_results['totalFailedTests'])
                total_result = total_pass + total_fail
        # BuiltIn().log_to_console("*** DEBUG: total_result:\n"
        #                          "%s\n" % total_result)

        all_test_cases = complete_test_results['allTestData']
        all_test_case_status = """ \
        <div align="center" style="vertical-align:bottom">
            <div align="left" style="vertical-align:bottom">
                <table class="table table-bordered">
                    <thead class="thead-light"><tr align="center">
                        <th>Total Test Cases</th>
                        <th>Passed</th>
                        <th>Failed</th></tr>
                    </thead>
                    <tr align="center">
                        <td> {} </td>
                        <td> {} </td>
                        <td> {} </td>
                    </tr>
                </table>
            </div>
            </div>""".format(str(total_result), str(total_pass), str(total_fail))

        if "pabot" in complete_test_results:
            pabot = complete_test_results["pabot"]
        else:
            pabot = "NA"

        if "labName" in complete_test_results:
            tenant = complete_test_results["labName"].upper()
        else:
            tenant = "NA"

    ### START: Getting All Data for each CPE
        if "cpeId" in complete_test_results and not pabot:
            cpes_used_list = list()
            cpes_used_list.append(complete_test_results["cpeId"].upper())
        if "cpes_used" in complete_test_results:
            cpes_used_list = complete_test_results["cpes_used"]
        cpes_used = dict()
        for cpe_id in cpes_used_list:
            cpes_used[cpe_id] = {"cpeId": cpe_id, "tenant": tenant, "buildName": "NA",
                                 "rackSlotId": "NA", "totalExecutionTime": 0,
                                 "ListTestsExecuted": list()}
            for test_case in list(all_test_cases.values()):
                # BuiltIn().log_to_console("*** DEBUG: test_case: %s\n" % test_case)
                # BuiltIn().log_to_console("*** DEBUG: cpe_id: %s\n" % cpe_id)
                if "cpeId" in test_case and cpe_id in test_case["cpeId"]:
                    # BuiltIn().log_to_console("*** DEBUG: test_case[jira]: %s\n" % test_case["jira"])
                    # BuiltIn().log_to_console("*** DEBUG: cpe_id: %s\n" % cpe_id)
                    if "buildName" in test_case and \
                            "NA" in cpes_used[cpe_id]["buildName"]:
                        if test_case["buildName"]:
                            cpes_used[cpe_id]["buildName"] = test_case["buildName"]
                    if "rackSlotId" in test_case and \
                            "NA" in cpes_used[cpe_id]["rackSlotId"]:
                        cpes_used[cpe_id]["rackSlotId"] = test_case["rackSlotId"]
                    if "jira" in test_case:
                        cpes_used[cpe_id]["ListTestsExecuted"].append(test_case["jira"])
                    if "execution_time" in test_case:
                        cpes_used[cpe_id]["totalExecutionTime"] = \
                            int(cpes_used[cpe_id]["totalExecutionTime"]) \
                            + int(test_case["execution_time"])
        BuiltIn().log_to_console("*** INFO: cpes_ids: %s\n" % cpes_used)
        # BuiltIn().log_to_console("*** DEBUG: len(cpes_used): %s\n" % len(cpes_used))
    ### END: Getting All Data for each CPE

        data_to_go = ''
        serial_number = 0

        for jira in list(all_test_cases.keys()):
            test = all_test_cases[jira]
            serial_number = serial_number + 1
            try:
                if test["status"] == 'FAIL':
                    status_class = 'table-danger'
                else:
                    status_class = 'table-success'
            except:
                BuiltIn().log_to_console("ERROR: test dict do not contain status,"
                                         " using failed color by default")
                status_class = 'table-danger'

            name1 = test["name"].split('_', 1)
            name = name1[1].replace("_", " ")

            meta_data = ""

            test_status = test["status"]
            row_id = test_status + '_' + jira

            elapsed_time = test["execution_time"]
            seconds = (elapsed_time / 1000) % 60
            seconds = int(seconds)
            minutes = (elapsed_time / (1000 * 60)) % 60
            minutes = int(minutes)
            hours = (elapsed_time / (1000 * 60 * 60)) % 24

            time_to_display = ("%dH:%dM:%dS" % (hours, minutes, seconds))
            exapnd_icon = ''
            if test_status == "FAIL":
                exapnd_icon = '<span id=span*' + row_id + ' style=\"float:right;font-size:10px;\">&#43;</span>'
                test_steps = test["testStepsList"]
                for test_step in test_steps:
                    if test_step["status"] == "FAIL":
                        screenshot_link = str(test_step["screenshot_url"])
                        testStepName = str(test_step["name"])
                        links_urls_defects_str = ""
                        jiraData_linkedList = []
                        if "jiraData" in test:
                            if "linkedList" in test["jiraData"]:
                                jiraData_linkedList = test["jiraData"]["linkedList"]
                            if "None" not in jiraData_linkedList and "linked" in test["jiraData"]:
                                jiraData_linked = test["jiraData"]["linked"]
                                # BuiltIn().log_to_console("jiraData_linked: %s" % jiraData_linked)
                                for ticket in jiraData_linkedList:
                                    # BuiltIn().log_to_console("ticket: %s" % ticket)
                                    for linked in jiraData_linked:
                                        # BuiltIn().log_to_console("linked: %s" % linked)
                                        if "jira" in linked and ticket in linked["jira"] and "status" in linked:
                                            links_urls_defects_str = links_urls_defects_str + '<a href=https://jira.lgi.io/browse/'+ticket+' target="_blank">'+ticket+'</a><a> : '+linked["status"]+'</a><a>  </a>'
                                        elif "jira" in linked and ticket in linked["jira"]:
                                            links_urls_defects_str = links_urls_defects_str + '<a href=https://jira.lgi.io/browse/'+ticket+' target="_blank">'+ticket+'</a><a>  </a>'
                        if links_urls_defects_str == "":
                            links_urls_defects_str = "None"
                        robotError = self.dict_key_unicode_to_str(test_step, "robotError")
                        failedReason = self.dict_key_unicode_to_str(test_step, "failedReason")
                        if pabot:
                            if "url" in test and "log" in test["url"]:
                                log_testcase = str(test["url"]["log"])
                            else:
                                log_testcase = "NA"
                            meta_data = '<div id=meta_'+str(row_id)+' style="background-color:lightblue; display:none"><b>Test Step: </b>'+testStepName+'<br><a href='+log_testcase+' target="_blank">Link To Log</a><br><a href='+screenshot_link+' target="_blank">Link To Screen Shot</a><br><b>Robot Error: </b>'+robotError+'<br><b>Failed reason: </b>'+failedReason+'<br><b>Linked Defects: </b>'+links_urls_defects_str+'<br></div>'
                        else:
                            meta_data = '<div id=meta_'+str(row_id)+' style="background-color:lightblue; display:none"><b>Test Step: </b>'+testStepName+'<br><a href='+screenshot_link+' target="_blank">Link To Screen Shot</a><br><b>Robot Error: </b>'+robotError+'<br><b>Failed reason: </b>'+failedReason+'<br><b>Linked Defects: </b>'+links_urls_defects_str+'<br></div>'

            data_to_go = data_to_go + """\
                <tr class="{}">
                    <td>{}</td>
                    <td>{}</td>
                    <td>{}</td>
                    <td id="{}">{} {} {}</td>
                    <td>{}</td>
                    <td>{}</td>
                    <td>{}</td>
                </tr>""".format(
                    status_class, str(serial_number), test["feature"], jira, row_id, name,
                    exapnd_icon, meta_data, test["cpeId"], test_status, str(time_to_display))
        all_test_case_data = """\
            <table id="testTable" class="table table-bordered sortable">
                <thead class="thead-light">
                    <tr align="center">
                        <th>S/N</th>
                        <th>FEATURE</th>
                        <th>JIRA</th>
                        <th>Test Case</th>
                        <th>CPE</th>
                        <th>Status</th>
                        <th>Elapse Time</th>
                    </tr>
                </thead>
                {}
            </table>""".format(data_to_go)

        all_cpes_data = ""
        for cpe_id in cpes_used:
            total_execution_time = cpes_used[cpe_id]["totalExecutionTime"]
            seconds = (total_execution_time / 1000) % 60
            seconds = int(seconds)
            minutes = (total_execution_time / (1000 * 60)) % 60
            minutes = int(minutes)
            hours = (total_execution_time / (1000 * 60 * 60)) % 24
            total_time_to_display = ("%dH:%dM:%dS" % (hours, minutes, seconds))
            # BuiltIn().log_to_console("*** DEBUG: len(cpes_used): %s\n" % len(cpes_used))
            # IF there is only one CPE that will run all the Testcases
            if len(cpes_used) > 1:
                list_tests_executed = ','.join(map(str, cpes_used[cpe_id]["ListTestsExecuted"]))
            else:
                list_tests_executed = "All Listed"
            new_cpe_info_line = """\
                               <tr align="center">
                                   <td>{}</td>
                                   <td>{}</td>
                                   <td>{}</td>
                                   <td>{}</td>
                                   <td>{}</td>
                               </tr>""".format(str(cpes_used[cpe_id]["buildName"]),
                                               str(cpes_used[cpe_id]["tenant"]),
                                               str(cpe_id),
                                               str(list_tests_executed),
                                               str(total_time_to_display))
            all_cpes_data = all_cpes_data + new_cpe_info_line

        all_test_case_metadata = """\
                <table class="table">
                    <tr align="center">
                        <th>Build</th>
                        <th>Tenant</th>
                        <th>CPE</th>
                        <th>Tests Executed</th>
                        <th>Total Execution Time</th>
                    </tr>
                    {}
                </table>""".format(str(all_cpes_data))

        html_data = self.create_chart(complete_test_results)
        barchart_by_features = self.get_barchart_by_feature(complete_test_results)

        html = """<html>
                    <head>
                        <meta charset="utf-8"/>
                        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">"
                    </head>
                    <body>
                        <div class="container">
                            <div class="jumbotron">
                                <h1 align="center"> Automation Execution Summary</h1><br>&nbsp;<br>
                                <div align="left">{}<br></div>
                            </div>
                            <div class="card">
                                <div class="card-header">Overall Results</div>
                                <div class="card-body">{}</div>
                            </div>
                            <div class="card">
                                <div class="card-header">Results by Feature</div>
                                <div class="card-body">{}</div>
                            </div>
                            <div align ="left">{}<br></div>
                            <div align="left">{}</div>
                        </div>
                        <script type="text/javascript" src="reportjs.js"></script>
                        <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
                        <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
                        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
                    </body>
               </html>""".format(all_test_case_metadata, html_data, barchart_by_features, all_test_case_status, all_test_case_data)
        f = open("execution_artifacts/quickreport.html", 'w+')
        f.write(html)
        f.close()
        BuiltIn().log_to_console("****** END Generation Of HTML Report ******")

    def create_chart(self, overall_result):
        """
        :param overall_result: This is the overall results stats
        :param tag_results:  These are tags in the output.xml
        :return: html widget
        """
        html_data = ''
        overall_list = []
        if overall_result != '':
            overall_list.append(int(overall_result['totalPassedTests']))
            overall_list.append(int(overall_result['totalFailedTests']))
            fig = {
                "data": [
                    {
                        "values": overall_list,
                        "labels": ["Pass", "Fail"],
                        'marker': {'colors': ['rgb(0, 128, 0)',
                                              'rgb(255, 94, 51)']},
                        # "domain": {"x": [0, .9], "y": [0, .9]},
                        "name": "Total Test Case ",
                        "hoverinfo": "label+percent",
                        # "hole": .4,
                        "type": "pie"
                    }
                ],
                "layout": {
                    "title": "",
                    "annotations": [
                        {
                            "font": {
                                "size": 10
                            },
                            "showarrow": False,
                            "text": "",
                            # "x": 0.5,
                            # "y": 0.5
                        }
                    ],
                }
            }

            total_percentage = plotly.offline.plot(fig, output_type='div')
            html_data += total_percentage
        return html_data

    @staticmethod
    def get_barchart_by_feature(results, percent=True):
        """
        :param results: This is the overall results stats
        :param percent:  Whether the returned chart should display percent or absolute numbers
        :return: html widget
        """
        features = []
        passes, passes_tmp = [], []
        fails, fails_tmp = [], []
        for r in results['allTestData']:
            if results['allTestData'][r]['feature'] not in features:
                features.append(results['allTestData'][r]['feature'])
                if results['allTestData'][r]['status'] == 'PASS':
                    passes.append(1.0)
                    fails.append(0.0)
                else:
                    passes.append(0.0)
                    fails.append(1.0)
            else:
                pos = features.index(results['allTestData'][r]['feature'])
                if results['allTestData'][r]['status'] == 'PASS':
                    passes[pos] = passes[pos] + 1
                else:
                    fails[pos] = fails[pos] + 1
        passes_txt = [str(int(x)) for x in passes]
        fails_text = [str(int(x)) for x in fails]
        if percent:
            for idx, val in enumerate(passes):
                if val > 0:
                    passes_tmp.append((val/(val + fails[idx]))*100)
                else:
                    passes_tmp.append(0)
            for idx, val in enumerate(fails):
                if val > 0:
                    fails_tmp.append((val/(val + passes[idx]))*100)
                else:
                    fails_tmp.append(0)
            passes, fails = passes_tmp, fails_tmp
        html_data = ''
        fig = go.Figure(data=[
            go.Bar(name='Pass', x=features, y=passes, text=passes_txt, textposition='auto',
                   marker_color='rgb(0, 128, 0)'),
            go.Bar(name='Fail', x=features, y=fails, text=fails_text, textposition='auto',
                   marker_color='rgb(255, 94, 51)')
        ])
        fig.update_layout(barmode='stack')
        if percent:
            fig.update_layout(yaxis=dict(type='linear', range=[1, 100], dtick=20, ticksuffix='%'))
        bar_chart = plotly.offline.plot(fig, output_type='div')
        html_data += bar_chart
        return html_data
