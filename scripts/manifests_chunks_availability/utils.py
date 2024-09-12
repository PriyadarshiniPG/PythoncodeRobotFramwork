'''
Utilities
'''
import os
from datetime import datetime

from platform import system as system_name # Returns the system/OS name
import subprocess
import re

# def ping(host):
#     """
#     Returns True if host (str) responds to a ping request.
#     Remember that some hosts may not respond to a ping request even if the host name is valid.
#     """
#     # if True:
#     try:
#         # Ping parameters as function of OS
#         opts = "-n 1" if system_name().lower()=="windows" else "-c 1"
        

#         # Pinging
#         # return system_call("ping " + parameters + " " + host) == 0
        
#         # return subprocess.call("ping {} {}".format(parameters, host), stderr=subprocess.STDOUT, stdout=subprocess.STDOUT) == 0
#         # return subprocess.call("ping {} {}".format(parameters, host), stderr=subprocess..STDOUT) == 0

#         args = "ping {} {}".format(opts, host)
#         # return subprocess.call(args, stderr=subprocess.STDOUT) == 0


#         # args = ["ping", opts, host]

#         output = subprocess.check_output(args, stderr=sys.stdout).decode("utf-8")

#     except subprocess.CalledProcessError as e:
#         error = "CalledProcessError: %s" % str(e)
#         return 0
#     except:
#         error = "except: %s" % str("sasasa")
#         return 0
#     return 1        


COLOR_GREY = 30
COLOR_RED = 31
COLOR_GREEN = 32
COLOR_YELLOW = 33
COLOR_BLUE = 34
COLOR_PURPLE = 35
COLOR_TURQUOISE = 36
COLOR_WHITE = 37

def ping(host):
    """
    Returns True if host (str) responds to a ping request.
    Remember that some hosts may not respond to a ping request even if the host name is valid.
    """
    # Ping parameters as function of OS
    opts = "-n 1" if system_name().lower()=="windows" else "-c 1"
    

    # Pinging
    # return system_call("ping " + parameters + " " + host) == 0
    
    # return subprocess.call("ping {} {}".format(parameters, host), stderr=subprocess.STDOUT, stdout=subprocess.STDOUT) == 0
    # return subprocess.call("ping {} {}".format(parameters, host), stderr=subprocess..STDOUT) == 0

    args = "ping {} {}".format(opts, host)
    return subprocess.call(args, stderr=subprocess.STDOUT) == 0





def get_vssp_time_string(in_time=datetime.now()):
    '''
    Get the formatted string for the given time.
    If time not provided use current thime
    '''
    return in_time.strftime("%Y-%m-%dT%H:%M:%S.%fZ")


def get_time_string(in_time=datetime.now()):
    '''
    Get the formatted string for the given time.
    If time not provided use current thime
    '''
    return in_time.strftime("%Y%m%d%H%M%S%f")
 
def get_short_time_string(in_time=datetime.now()):
    '''
    Get the short formatted string for the given time
    '''
    return in_time.strftime("%Y%m%d%H%M")

def make_path_for_file(filename):
    '''
    >>> folder_name  = "/temp/PythonResults/make_path_for_file_test"
    >>> if os.path.exists(folder_name): os.removedirs(folder_name)
    >>> make_path_for_file(folder_name)
    >>> os.path.exists(folder_name)
    True
    '''
    directory = os.path.dirname(filename)
    if not os.path.exists(directory):
        os.makedirs(directory)

def write_to_text_file(file_name, string, newline='\n'):
    '''
    Writes string to file name.
    Creates a new destination folder if it does not exist.
    '''
    make_path_for_file(file_name)
    with open(file_name, "w", newline=newline) as text_file:
        text_file.write(string)

def colorize_string(status_str, color = COLOR_GREEN):
    '''
    Colorizes string for message output
    30 grey
    31 red
    32 green
    33 yellow
    34 blue
    35 purple
    36 turquoise
    37 white
    '''
    attr = ["1"]
    attr.append(str(color))
    return '\x1b[%sm%s\x1b[0m' % (';'.join(attr), status_str)

def test_colors():
    for a in range(0,40):
        attr = ["1"]
        val = a
        attr.append(str(val))
        print('\x1b[%sm%s\x1b[0m' % (';'.join(attr), "Test" + str(a)))


def color_of_success(success):
    if success:
        return COLOR_GREEN
    else:
        return COLOR_RED


def print_test_result_formatted(res, status):
    if status != 0:
        status_str = "Failed"
    else:
        status_str = "Ok"
    # print(res)
    # print(colorize_string(status_str, color_of_success(status == 0)))
    print(res, colorize_string(status_str, color_of_success(status == 0)))


iso8601Rex = re.compile('P((?:(\d*)Y)?(?:(\d*)M)?(?:(\d*)D)?)?(T(?:(\d*)H)?(?:(\d*)M)?(?:(\d*(?:\.\d*)?)S))?')

def ClearStr():
    # os.system('clear')
    os.system('cls')

def DecodeToSeconds(duration):
    if duration == '':
        return 0
    '''
    >>>DecodeToSeconds('PT13H58M100.6S') == 50380.6
    >>>True
    '''
    global iso8601Rex
    matches = iso8601Rex.match(duration) 
    # Ignore for now
    # years     = matches[2] or 0
    # months    = matches[3] or 0
    # days      = matches[4] or 0
    # Ignore for now
    groups    = matches.groups()
    hours     = int(groups[5] or 0)
    # print 'hours', hours
    seconds   = float(groups[7] or 0)
    # print 'seconds', seconds
    minutes   = int(groups[6] or 0)
    # print 'minutes', minutes
    # print(hours,minutes, seconds)
    minutes   += 60*hours
    seconds   += 60*minutes
    return seconds
