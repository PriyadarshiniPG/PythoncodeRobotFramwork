"""Implementation of a Keyword class for general library keywords in Robot Framework."""
# pylint: disable=wrong-import-order
import __main__
import os
import sys
import psutil
import traceback
from functools import wraps
from robot.libraries.BuiltIn import BuiltIn
from datetime import datetime
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError

class Keywords(object):
    """A class for general keywords"""

    @staticmethod
    def easy_debug(method_to_decorate):
        """Decarator @easy_debug to print debug data in case of exeption"""
        @wraps(method_to_decorate)
        def the_wrapper_around_original_method(*args, **kwargs):
            try:
                return method_to_decorate(*args, **kwargs)
            except Exception:
                exc_type, exc_obj, exc_traceback = sys.exc_info()
                fname = traceback.extract_tb(exc_traceback)[-1][0]
                line_number = traceback.extract_tb(exc_traceback)[-1][1]
                method_name = method_to_decorate.__name__
                local_vars = {}
                local_vars_type = {}
                if exc_traceback is not None:
                    prev = exc_traceback
                    curr = exc_traceback.tb_next
                    while curr is not None:
                        prev = curr
                        curr = curr.tb_next
                    local_vars = prev.tb_frame.f_locals
                    if local_vars:
                        for var_name, var_value in list(local_vars.items()):
                            local_vars_type[var_name] = type(var_value)
                separator_line = "*" * 70
                BuiltIn().log_to_console(
                    "\n\n@easy_debug:\n%s\n"
                    "Exception=%s, Message=%s, File=%s, Method=%s, Line=%s\n\n"
                    "Variables=%s\n\n"
                    "Variables types=%s\n%s\n\n"
                    % (separator_line, exc_type, exc_obj, fname, method_name,
                       line_number, local_vars, local_vars_type, separator_line))
                raise exc_obj

        return the_wrapper_around_original_method

    @staticmethod
    def combine_dictionaries(dict1, dict2): # pylint: disable=R0201
        """ A function to merge two dictionaries in one single dictionary
        :param dict1:
        :param dict2:
        :return: merged dictionary
        """
        merged_dictionary = dict1.copy()
        merged_dictionary.update(dict2)
        return merged_dictionary

    @classmethod
    def get_variable_mame(cls, variable, namespace):
        """
        A keyword to return variable name as string
        :param variable: variable itself, instance
        :param namespace: locals() or globals()
        :return: variable name, string
        """
        return [key for key in namespace if namespace[key] is variable][0]

    def log_all_variables_name_and_value(self, vars_dictionary, file_name, method, namespace):
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
        :param vars_dictionary: dictionary of variables to analyze
        :param file_name: name of the file
        """
        dictionary_to_return = vars_dictionary
        if os.environ.get("LOG_VARS", "False") == "True":
            if bool(os.environ.get("TEST", False)):
                test_name = os.environ["TEST"]
            else:
                raise Exception("Please define TEST env. variable")

            if "MagicMock" in method.__class__.__name__:
                method_name = "mocked method"
            else:
                method_name = method.__name__

            for var_name, var_value in list(namespace.items()):

                var = var_value
                var_type = type(var).__name__

                if file_name not in list(dictionary_to_return.keys()):
                    dictionary_to_return[file_name] = {}
                if method_name not in list(dictionary_to_return[file_name].keys()):
                    dictionary_to_return[file_name][method_name] = {}
                if var_name not in list(dictionary_to_return[file_name][method_name].keys()):
                    dictionary_to_return[file_name][method_name][var_name] = {}
                if var_type not in list(dictionary_to_return[file_name][method_name][var_name].keys()):
                    dictionary_to_return[file_name][method_name][var_name][var_type] = None

                if var_value != dictionary_to_return[file_name][method_name][var_name][var_type]:
                    if "test_keywords.py" not in __main__.__file__:

                        build_number = os.environ.get("BUILD_NUMBER", "1")
                        cpu_percent, disk_usage, jenkins_location_disk_usage, \
                        jenkins_location_path, swap_memory, \
                        virtual_memory = self.get_reserces_usage()

                        test_step_name = BuiltIn().get_variable_value("${TEST NAME}")
                        tags = BuiltIn().get_variable_value("${TEST_TAGS}")
                        new_log_line = ""
                        test_name_separator = "\n\n\nTESTS STEP: %s ==============>\n\n\n" % \
                                              test_step_name
                        if "test_step_name" not in list(dictionary_to_return.keys()):
                            dictionary_to_return["test_step_name"] = test_step_name
                            new_log_line = "TEST SUITE: %s (tags: %s)" % (test_name, tags)
                            new_log_line += test_name_separator
                        if dictionary_to_return["test_step_name"] != test_step_name:
                            dictionary_to_return["test_step_name"] = test_step_name
                            new_log_line = test_name_separator

                        new_log_line += "\n(!)  File '%s' >>> " \
                                        "Method '%s' >>> " \
                                        "Variable name '%s'. " \
                                        "Type '%s'. " \
                                        "Value:\n%s\n" % (file_name, method_name,
                                                          var_name, var_type, var_value)
                        # if last variable in namesace
                        if list(namespace.items())\
                            .index((var_name, var_value)) == len(list(namespace.items())) - 1:
                            recerses_info = "\n\nResorces usage:\nCPU: %s\nVirtual Memory: %s\n" \
                                                "Swap Memory: %s\n" \
                                                "Jenkins location (%s) disk usage: %s\n" \
                                                "General Disk Usage: %s\n\n" % (
                                                    cpu_percent, virtual_memory, swap_memory,
                                                    jenkins_location_path,
                                                    jenkins_location_disk_usage, disk_usage)
                            new_log_line += recerses_info

                        test_name = test_name.split("/")[-1].\
                            replace(".robot", "").\
                            replace(".txt", "")
                        log_file_name = "var_values_%s_BUILD#_%s.log" % (test_name, build_number)

                        with open(log_file_name, "a+") as f:
                            try:
                                content = self.insure_text(new_log_line)
                                f.write(content)
                            except (UnicodeDecodeError, UnicodeEncodeError):
                                f.write(
                                    "\nNo 'ascii' characters was detected for var: %s\n" % var_name)

                        dictionary_to_return[file_name][method_name][var_name][var_type] = var_value

        return dictionary_to_return

    @staticmethod
    def get_reserces_usage():
        """A method to get a current system recorces usage"""
        cpu_percent = psutil.cpu_percent()
        i = 0
        while cpu_percent == 0.0 and i < 100:
            cpu_percent = psutil.cpu_percent()
        virtual_memory = psutil.virtual_memory()
        swap_memory = psutil.swap_memory()
        jenkins_location_path = "/app/robot/jenkins"
        jenkins_location_disk_usage = "Not a Jenkins host"
        if os.path.exists(jenkins_location_path):
            jenkins_location_disk_usage = psutil.disk_usage(jenkins_location_path)
        root_path = "/"
        disk_usage = psutil.disk_usage(root_path)
        return cpu_percent, disk_usage, jenkins_location_disk_usage, \
               jenkins_location_path, swap_memory, virtual_memory

    @staticmethod
    def insure_text(str_or_bytes):
        """The method to convert bytest to text if necessary"""
        content = str_or_bytes
        if isinstance(str_or_bytes, bytes):
            content = content.decode("UTF-8")
        return content

    @staticmethod
    def insure_bytes(str_or_bytes):
        """The method to convert text to bytes if necessary"""
        content = str_or_bytes
        if not isinstance(str_or_bytes, bytes):
            content = str.encode(str_or_bytes)
        return content

    @staticmethod
    def remove_non_ascii(string):
        """Method to remove non ASCII characters from a string"""
        return "".join(char for char in string if ord(char) < 128)

    @staticmethod
    def update_microservice_headers(headers=None):
        """
        Updates the header with useragent, x-req-id, x-cus
        :param headers: existing headers
        :return: headers appended with useragent, x-req-id, x-cus
        """
        if headers is None:
            headers = {}
        try:
            platform = BuiltIn().get_variable_value("${CPE_PRODUCT_CLASS}")
            customer_id = BuiltIn().get_variable_value("${CUSTOMER_ID}")
            platform = platform if platform is not None else "DEFAULT-STB"
            headers.update({"User-Agent": "HZN4-TDROBOT-" + platform, "x-request-id": "TDROBOT-" + datetime.now().strftime("%Y-%m-%d_%H%M%S"),
                            "Content-type": "application/json"})
            if customer_id is not None:
                headers.update({"x-cus": customer_id})
        except RobotNotRunningError:
            pass
        BuiltIn().log("Updated headers : " + str(headers))
        return headers
