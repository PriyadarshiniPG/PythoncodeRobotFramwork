"""Implementation of a Keyword class for general library keywords in Robot Framework."""
from robot.libraries.BuiltIn import BuiltIn

class Keywords(object):
    """A class for general keywords"""

    def combine_dictionaries(self, dict1, dict2): # pylint: disable=R0201
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


    @staticmethod
    def log_all_variables_name_and_value(vars_dictionary, file_name, method, namespace):
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
        :param variable: variable to analyze
        """
        dictionary_to_return = vars_dictionary

        if "MagicMock" in method.__class__.__name__:
            method_name = "mocked method"
        else:
            method_name = method.__name__

        for var_name, var_value in namespace.items():
            # var_name = self.get_variable_mame(variable, namespace)

            # Define variable to get their type
            # exec (var + " = " + None

            var = var_value
            var_type = type(var).__name__


            if file_name not in dictionary_to_return.keys():
                dictionary_to_return[file_name] = {}
            if method_name not in dictionary_to_return[file_name].keys():
                dictionary_to_return[file_name][method_name] = {}
            if var_name not in dictionary_to_return[file_name][method_name].keys():
                dictionary_to_return[file_name][method_name][var_name] = {}
            if var_type not in dictionary_to_return[file_name][method_name][var_name].keys():
                dictionary_to_return[file_name][method_name][var_name][var_type] = None

            if var_value != dictionary_to_return[file_name][method_name][var_name][var_type]:

                if not "MagicMock" in method.__class__.__name__:

                    BuiltIn().log(
                        "\n(!)  File '%s' >>> Method '%s' >>> Variable name '%s'. Type '%s'. "
                        "Value:\n%s\n"
                        % (file_name, method_name, var_name, var_type, var_value))

                    dictionary_to_return[file_name][method_name][var_name][var_type] = var_value

        return dictionary_to_return
