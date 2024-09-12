# pylint: disable=import-error
# Disabled pylint "import-error" message because robot.libraries.* unreachable.
"""Module contains common functions and wrappers for some Robot Framework's keywords."""

import datetime
import random
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem


def time_ms(time_str, pattern):
    """Convert time string to millseconds elapsed from Epoch (1970-01-01).

    :Example:

    >>>time_ms("20170803 17:12:17.829", "%Y%m%d %H:%M:%S.%f")
    1501773137829
    """
    time_struct = datetime.datetime.strptime(time_str, pattern)
    epoch_struct = datetime.datetime(1970, 1, 1)
    utc_now = datetime.datetime.utcnow()
    local_now = datetime.datetime.now()
    offset = (utc_now.hour - local_now.hour) * 3600 # zone offset in seconds
    seconds = int((time_struct - epoch_struct).total_seconds() + offset)
    milliseconds = int(seconds * 1000 + time_struct.microsecond / 1000)
    return milliseconds


def time_now_str(pattern):
    """Return current time as a string of a given format (pattern).

    :Example:

    >>>time_now_str("%Y.%m.%d")
    '2017.08.03'
    """
    now_time_struct = datetime.datetime.now()
    time_str = datetime.datetime.strftime(now_time_struct, pattern)
    return time_str


def epoch_ms_to_z_time(epoch_ms):
    """Function parses a string of UTC time into Python time structure.

    :param epoch_ms: number of milliseconds elapsed from Epoch.

    :return: a string representing time in the UTC format.

    :Example:

    >>> epoch_ms_to_z_time(1501673269802)
    '2017-08-02T13:27:49.802Z'
    """
    time_struct = datetime.datetime.fromtimestamp(epoch_ms/1000.0)
    time_str = "%sZ" % time_struct.strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3]
    return time_str


def parse_from_string(str_val):
    """Method obtains the value from its string reresentation.

    .. note:: this method is an alternative to eval().
    """
    try:
        value = int(str_val) if int(str_val) == float(str_val) else float(str_val)
    except ValueError:
        try:
            value = bool(str_val)
        except ValueError:
            value = str_val
    return value


def search_equals_in_array(arr_1, arr_2):
    """Method collects elements of array arr_1 if they belong to arr_2.

    :return: first collected element if found, empty string otherwise.
    """
    word = [elem for elem in arr_1 if elem in arr_2]
    result = word[0].upper() if word else ""
    return result


def generate_id(mask="8-4-4-4-12", chars="abcdef0123456789"):
    """Method generates a random string from a given charset using a template.

    :param mask: a string pattern of numbers separated by dashes.
    :param chars: a string containg only allowed charaters.

    :return: a string of a given pattern with chars from the given charset.

    :Example:

    >>>generate_id()
    447b3547-4a7f-c8e7-a5c2-20170803113219
    """
    res = ""
    for size in mask.split("-"):
        res += "-%s" % "".join(random.choice(chars) for i in range(int(size)))
    return res[1:]


# All functions below are wrappers for some common Robot Framework's keywords
# and cannot be used outside Robot Framework context.

def get_conf():
    """A function collects all variables loaded by Robot Framework into dictionary."""
    variables_dict = BuiltIn().get_variables()
    conf = {}
    for ugly_robot_key in list(variables_dict.keys()):
        nice_python_key = ugly_robot_key.replace("$", "").replace("@", "")[1:-1]
        conf[nice_python_key] = variables_dict[ugly_robot_key]
    return conf


def get_lab_name():
    """A function adds 'lab' prefix if needed to the lab name obtained by
    Robot Framework's keyword 'Get Variable Value'.
    """
    lab = get_var_value("LAB_NAME")
    if (not lab.startswith("lab")) & (not lab.startswith("pr")):
        lab = "lab%s" % lab
    return lab


def os_get_env_var(var_name):
    """A wrapper to Robot Framework's keyword 'Get Environment Variable'."""
    lib = OperatingSystem()
    str_val = lib.get_environment_variable(var_name, var_name)
    value = parse_from_string(str_val)
    return value


def get_var_value(var_name):
    """A wrapper to Robot Framework's keyword 'Get Variable Value'."""
    var_value = BuiltIn().get_variable_value("${%s}" % var_name)
    return var_value


def set_suite_var(var_name, var_value):
    """A wrapper to Robot Framework's keyword 'Set Suite Variable'."""
    BuiltIn().set_suite_variable("${%s}" % var_name, var_value)


# Below are not used now, but left just for case in future.
def set_global_var(var_name, var_value):
    """A wrapper to Robot Framework's keyword 'Set Global Variable'."""
    BuiltIn().set_global_variable("${%s}" % var_name, var_value)


def set_test_var(var_name, var_value):
    """A wrapper to Robot Framework's keyword 'Set Test Variable'."""
    BuiltIn().set_test_variable("${%s}" % var_name, var_value)
