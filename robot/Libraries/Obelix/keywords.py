# Disable pylint "Using the global statement", "Invalid name",
# "Catching an exception which doesn't inherit from Exception" check
# pylint: disable=W0603,C0103,E0712
"""Implementation of Obelix for HZN 4"""
import os
import json
import re
import time
import urllib.parse
from datetime import date, datetime
import shutil
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError
import paramiko
import requests

session_key = ""


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


class ObelixRequests(object):
    """Class handling all functions relating
    to making requests to obelix server
    """

    def __init__(self, obelix_ip, slot):
        """"Class initializer.
        :param conf: config file for labs
        """
        self.obelix_ip = str(obelix_ip)
        self.slot = str(slot)
        self.url = 'http://' + self.obelix_ip + '/TestSpace/' + self.slot
        self.char_id = {
            'A': (1, 'ok button'),
            'a': (1, 'ok button'),
            'B': (5, 'arrow down button'),
            'b': (5, 'arrow down button'),
            'C': (3, 'arrow down button'),
            'c': (3, 'arrow down button'),
            'D': (3, 'ok button'),
            'd': (3, 'ok button'),
            'E': (3, 'arrow up button'),
            'e': (3, 'arrow up button'),
            'F': (4, 'ok button'),
            'f': (4, 'ok button'),
            'G': (5, 'ok button'),
            'g': (5, 'ok button'),
            'H': (6, 'ok button'),
            'h': (6, 'ok button'),
            'I': (8, 'arrow up button'),
            'i': (8, 'arrow up button'),
            'J': (7, 'ok button'),
            'j': (7, 'ok button'),
            'K': (8, 'ok button'),
            'k': (8, 'ok button'),
            'L': (9, 'ok button'),
            'l': (9, 'ok button'),
            'M': (7, 'arrow down button'),
            'm': (7, 'arrow down button'),
            'N': (6, 'arrow down button'),
            'n': (6, 'arrow down button'),
            'O': (9, 'arrow up button'),
            'o': (9, 'arrow up button'),
            'P': (10, 'arrow up button'),
            'p': (10, 'arrow up button'),
            'Q': (1, 'arrow up button'),
            'q': (1, 'arrow up button'),
            'R': (4, 'arrow up button'),
            'r': (4, 'arrow up button'),
            'S': (2, 'ok button'),
            's': (2, 'ok button'),
            'T': (5, 'arrow up button'),
            't': (5, 'arrow up button'),
            'U': (7, 'arrow up button'),
            'u': (7, 'arrow up button'),
            'V': (4, 'arrow down button'),
            'v': (4, 'arrow down button'),
            'W': (2, 'arrow up button'),
            'w': (2, 'arrow up button'),
            'X': (2, 'arrow down button'),
            'x': (2, 'arrow down button'),
            'Y': (6, 'arrow up button'),
            'y': (6, 'arrow up button'),
            'Z': (1, 'arrow down button'),
            'z': (1, 'arrow down button'),
            ' ': (11, 'arrow down button'),
            '-': (10, 'ok button'),
            '_': (10, 'arrow down button'),
            ',': (9, 'arrow down button'),
            '.': (8, 'arrow down button'),
            '0': (-1, '0 button'),
            '1': (-1, '1 button'),
            '2': (-1, '2 button'),
            '3': (-1, '3 button'),
            '4': (-1, '4 button'),
            '5': (-1, '5 button'),
            '6': (-1, '6 button'),
            '7': (-1, '7 button'),
            '8': (-1, '8 button'),
            '9': (-1, '9 button'),
            '/': (11, 'ok button')}
        try:
            # Use folder name where this file is placed
            # (as Traxis, Fabrix, PurchaseMicroservice, etc) as a tag
            folder_name = os.path.basename(os.path.dirname(os.path.realpath(__file__)))
            BuiltIn().set_test_variable("${ENDPOINT_TAG}", "%s" % folder_name)
        except RobotNotRunningError:
            pass

    def connect(self, user, machine):
        """A method to connect to Obelix and check status"""
        global session_key
        url = self.url +'/Connect/?user=' + user + '&machine=' + machine + '&clienttype=4'
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url)
            if response.status_code == 200:
                session_key = json.loads(response.text).get('Session')
                print(session_key)
                BuiltIn().log_to_console("\nConnect Successful")
                return True
            if response.status_code == 409:
                BuiltIn().log_to_console("\nOBELIX: "
                                         "Connection failed because box is "
                                         "already reserved for another user")
            else:
                BuiltIn().log_to_console("\nTo connect with server, sent GET request to "
                                         "%s and response status code %s"
                                         % (url, response.status_code))
            return False
        except requests.exceptions as error:
            BuiltIn().log_to_console("Could not send GET %s due to %s" % (url, error))
        return False

    def disconnect(self, user):
        """A method to disconnect to Obelix and check status"""
        global session_key
        if session_key == "":
            session_key = "62187160 - fkc1 - 4d5e-8089 - 451bb12757ce"

        url = self.url + '/Disconnect/?user='+user + '&sessionKey=' + session_key

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url)
            if response.status_code == 200:
                BuiltIn().log_to_console("\nDisConnect Successful")
                return True
            BuiltIn().log_to_console("\nTo disconnect with server, sent GET request "
                                     "to %s and response status code %s"
                                     % (url, response.status_code))
        except (requests.exceptions) as error:
            BuiltIn().log_to_console("Could not send GET %s due to %s" % (url, error))
        return False

    def pass_command(self, command):
        """A method to pass command to Obelix and check status"""
        url = self.url + '/Handset/Send/?cmd=' + command + '&sessionKey=' + session_key
        print("Comlete URL")
        print(url)

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url)
            # Disable 'Unnecessary "else" after "return"' pylint check
            if response.status_code == 200:  # pylint: disable=R1705
                return True
            BuiltIn().log_to_console("\nTo pass remote command to server, sent GET request "
                                     "to %s and response status code %s"
                                     % (url, response.status_code))
        except requests.exceptions as error:
            BuiltIn().log_to_console("Could not send GET %s due to %s" % (url, error))
        return False

    def check_standby(self):
        """A method to check standby"""
        url = self.url + '/Scripter/Device/'
        data = '{ "command" : "standby"}'

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.post(url, data=data, headers={"Content-Type": "application/json"})
            status = json.loads(response.text).get('judgment')
            if response.status_code == 200:
                if status == "passed":
                    return True
            else:
                BuiltIn().log_to_console("\nTo check STB standby by server, sent POST request "
                                         "to %s and response status code %s"
                                         % (url, response.status_code))
                BuiltIn().log_to_console("Body: \n%s" % data)
        except requests.exceptions as error:
            BuiltIn().log_to_console("Could not send POST %s due to %s" % (url, error))
        return False

    def moving_video_detection(self, deviation, samplerate):
        """A method to moving video detection and check status"""
        url = self.url + '/Scripter/Testing/Video/'
        data = '{"command":"movingvideo","percentageDeviation":"' + str(deviation) + \
               '","sampleRate":"' + str(samplerate) + '"}'

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.post(url, data=data, headers={"Content-Type": "application/json"})
            status = json.loads(response.text).get('judgment')
            if response.status_code == 200:
                if status == "passed":
                    return True
            else:
                BuiltIn().log_to_console("\nfor moving video detection by server, sent POST "
                                         "request to %s and response status code %s"
                                         % (url, response.status_code))
                BuiltIn().log_to_console("Body: \n%s" % data)
        except (requests.exceptions) as error:
            BuiltIn().log_to_console("Could not send POST %s due to %s" % (url, error))
        return False

    def image_comparison(self, deviation, x_coordinate, y_coordinate, width, height, filename):
        """A method to compare images"""
        url = self.url + '/Scripter/SVC/'
        data = '{"command": "comparison","percentageDeviation": "' + str(deviation) \
               + '","mode":"FILE","file": "' + str(filename) + \
               '",	"comparisonType":"match","referenceImage":{"Width": "1920", "Height": "1080"},' \
               '"regions":' \
               '[{"deltax": "' \
               + str(x_coordinate) + '","deltay": "' + str(y_coordinate) + '", "width": "' \
               + str(width) \
               + '","height":"' + str(height) + '"}]}'

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.post(url, data=data, headers={"Content-Type": "application/json"})

            if response.status_code == 200:
                status = json.loads(response.text).get('judgment')
                if status == "passed":
                    return True
            else:
                BuiltIn().log_to_console("\nfor image comparison by server, sent POST request"
                                         " to %s and response status code %s"
                                         % (url, response.status_code))
                BuiltIn().log_to_console("Body: \n%s" % data)
        except requests.exceptions as error:
            BuiltIn().log_to_console("Could not send POST %s due to %s" % (url, error))
        return False

    def ocr_extract(self, x_coordinate, y_coordinate, widthx, heighty,
                    rescale, contrast, threshold, dilate):
        """A method to ocr_extract"""
        url = self.url + '/Scripter/SVC/'
        data = '{"command": "ocr","language":"eng","expressionType":"Task","expression": ' \
               '"Task","referenceImage":{"Width": "1920", "Height": "1080"},' \
               '"regions":[{"deltax": "' + \
               str(x_coordinate) + '","deltay": "' + str(y_coordinate) + '", "width": "' + \
               str(widthx) + '","height":"' + \
               str(heighty) + '"}],"filters":[{"Rescale": "' + rescale + '","Dilate":"' + \
               dilate + '","Threshold": "' + threshold + '","Contrast": "' + contrast + '"}]}'

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.post(url, data=data, headers={"Content-Type": "application/json"})
            if response.status_code == 200:
                extracted_string = json.loads(response.text).get('message')
            else:
                BuiltIn().log_to_console("\nTo get text from image we sent POST to %s "
                                         "\nResponse status code %s. Reason: %s"
                                         % (url, response.status_code, response.reason))
                BuiltIn().log_to_console("Body: \n%s" % data)
                extracted_string = ""
        except requests.exceptions as error:
            BuiltIn().log_to_console("Could not send POST %s due to %s" % (url, error))
            extracted_string = ""
        return extracted_string.encode("utf-8").strip()

    def get_image_text(self, rescale, contrast, threshold, dilate):
        """A method to get image text"""
        url = self.url + '/Scripter/SVC/'
        data = '{"command": "ocr","language":"eng","expressionType":"Task",' \
               '"expression": "Task",' \
               '"filters":[{"Rescale": "' + \
               rescale + '","Dilate":"' + \
               dilate + '","Threshold": "' + \
               threshold + '","Contrast": "' + \
               contrast + '"}]}'

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.post(url, data=data, headers={"Content-Type": "application/json"})
            if response.status_code == 200:
                extracted_string = json.loads(response.text).get('message')
            else:
                BuiltIn().log_to_console("\nTo get text from image we sent POST to %s "
                                         "\nResponse status code %s. Reason: %s"
                                         % (url, response.status_code, response.reason))
                BuiltIn().log_to_console("Body: \n%s" % data)
                extracted_string = ""
        except requests.exceptions as error:
            BuiltIn().log_to_console("Could not send POST %s due to %s" % (url, error))
            extracted_string = ""
        return extracted_string.strip().replace("'", "")

    def is_string_matched(self, x_coordinate, y_coordinate, widthx, heighty, string_to_match,
                          rescale, contrast, threshold, dilate):
        """A method to check is extracted string matched the given string"""
        try:
            string_to_match = str(string_to_match)
            extracted_string = self.ocr_extract(x_coordinate, y_coordinate, widthx, heighty,
                                                rescale, contrast, threshold, dilate)
            if string_to_match == "":
                if extracted_string == "":
                    return False    #"OCR Failed"
                return True
            if extracted_string.find(string_to_match) == -1:
                return False  # "OCR Failed"
            return True
        except UnicodeEncodeError:
            return False

    def write_text_on_screen(self, search_text):
        """A method to write text on screen"""
        current_col = 0
        search_text += '/'
        for _ in range(1, 6):
            self.pass_command('arrow left button')

        for char in search_text:
            shift_arrow = 'arrow right button'
            if char not in list(self.char_id.keys()):
                continue
            char_list = self.char_id[char]
            button_to_press = char_list[1]
            col_of_char = char_list[0]
            number_of_shifts = (col_of_char - current_col)
            current_col = col_of_char
            if number_of_shifts < 0:
                shift_arrow = 'arrow left button'
                number_of_shifts = number_of_shifts * -1
            self.write_each_char(number_of_shifts, shift_arrow, button_to_press)

    def write_each_char(self, number_of_shifts, direction, button_to_press):
        """A method to write text char by char"""
        for _ in range(number_of_shifts):
            self.pass_command(direction)
        self.pass_command(button_to_press)

    def take_screenshot(self, path):
        """A method to take screenshot"""
        url = self.url + '/ScreenShot/'

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.get(url, stream=True)
            if response.status_code == 200:
                with open(path, 'wb') as response_file:
                    response.raw.decode_content = True
                    shutil.copyfileobj(response.raw, response_file)
            else:
                BuiltIn().log_to_console("\nTo take screenshot from server, sent GET request "
                                         "to %s and response status code %s"
                                         % (url, response.status_code))
        except requests.exceptions as error:
            BuiltIn().log_to_console("Could not send GET %s due to %s" % (url, error))

    def black_screen_detection(self, deviation, deltax, deltay, width, height):
        """A method to detect black screen"""
        url = self.url + '/Scripter/SVC/'
        data = '{"command":"blackscreen","judgement": "or","percentageDeviation":"' +\
               str(deviation)+'","referenceImage": {"height": 1080, "width": 1920},' \
                              '"regions":[{"DeltaX":"' +\
               str(deltax)+'","DeltaY":"' +\
               str(deltay)+'","width":"' +\
               str(width)+'","height":"' +\
               str(height)+'" }]}'

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.post(url, data=data, headers={"Content-Type": "application/json"})
            status = json.loads(response.text).get('judgment')
            if response.status_code == 200:
                if status == "passed":
                    return True
            else:
                BuiltIn().log_to_console("\nFor Black Screen Detection by server, sent POST request"
                                         " to %s and response status code %s"
                                         % url % response.status_code)
                BuiltIn().log_to_console("Body: \n%s" % data)
        except requests.exceptions as error:
            BuiltIn().log_to_console("Could not send POST %s due to %s" % (url, error))
        return False


class Keywords(object):
    """"Keywords visible in Robot Framework"""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @staticmethod
    def connect(obelix_ip, slot, user, machine):
        """A keyword to connected to Obelix
        :param conf: config file for labs
        :param user: User name  to be connected to Obelix
        :param machine: Machine name  to be connected to Obelix
        """
        response = ObelixRequests(obelix_ip, slot).connect(user, machine)
        return response

    @staticmethod
    def disconnect(obelix_ip, slot, user):
        """A keyword to disconnect from Obelix
        :param conf: config file for labs
        :param user: User to be disconnected from Obelix
        """
        response = ObelixRequests(obelix_ip, slot).disconnect(user)
        return response

    @staticmethod
    def pass_command(obelix_ip, slot, command):
        """A keyword to pass command to Obelix
        :param conf: config file for labs
        :param command: command to be send to Obelix
        """
        response = ObelixRequests(obelix_ip, slot).pass_command(command)
        return response

    @staticmethod
    def check_standby(obelix_ip, slot):
        """A keyword to check_standby from Obelix
        :param conf: config file for labs
        """
        response = ObelixRequests(obelix_ip, slot).check_standby()
        return response

    @staticmethod
    def moving_video_detection(obelix_ip, slot, deviation=10, samplerate=500):
        """A keyword to moving video from Obelix
        :param conf: config file for labs
        :param deviation: deviation to be given for detection
        :param samplerate: samplerate to be given for detection
                """
        response = ObelixRequests(obelix_ip, slot).moving_video_detection(deviation, samplerate)
        return response

    @staticmethod
    def ocr_extract(obelix_ip, slot, x_coordinate, y_coordinate, widthx, heighty, rescale="2,2",
                    contrast="0,30", threshold="50", dilate=""):
        """A keyword to extract ocr text from Obelix
        :param conf: config file for labs
        :param x_coordinate: x coordinate - start of area for text extraction
        :param y_coordinate: y coordinate - start of area for text extraction
        :param widthx: width of area for text extraction
        :param heighty: height of area for text extraction
        """
        response = ObelixRequests(obelix_ip, slot).ocr_extract(
            x_coordinate, y_coordinate, widthx, heighty, rescale, contrast, threshold, dilate)
        return response

    @staticmethod
    def get_image_text(obelix_ip, slot, rescale="2,2", contrast="0,30", threshold="50", dilate=""):
        """A keyword to extract ocr text from Obelix
        :param conf: config file for labs
        """
        response = ObelixRequests(obelix_ip, slot).get_image_text(
            rescale, contrast, threshold, dilate)
        return response

    @staticmethod
    def image_comparison(obelix_ip, slot, deviation, x_coordinate,
                         y_coordinate, width, height, filename):
        """A keyword to extract ocr text from Obelix
        :param conf: config file for labs
        :param deviation: deviation for image comparison
        :param x_coordinate: x coordinate - start of area for text extraction
        :param y_coordinate: y coordinate - start of area for text extraction
        :param width: width of area for text extraction
        :param height: height of area for text extraction
        :param filename: filename of the reference image to be matched with
        """
        response = ObelixRequests(obelix_ip, slot).image_comparison(
            deviation, x_coordinate, y_coordinate, width, height, filename)
        return response

    @staticmethod
    def is_string_matched(obelix_ip, slot, x_coordinate, y_coordinate,
                          widthx, heighty, string_to_match,
                          rescale="2,2", contrast="", threshold="", dilate=""):
        """A keyword to match string with ocr text from Obelix
        :param conf: config file for labs
        :param x_coordinate: x coordinate - start of area for text extraction
        :param y_coordinate: y coordinate - start of area for text extraction
        :param widthx: width of area for text extraction
        :param heighty: height of area for text extraction
        :param string_to_match: string to be matched
        """
        response = ObelixRequests(obelix_ip, slot).is_string_matched(
            x_coordinate, y_coordinate, widthx, heighty,
            string_to_match, rescale, contrast, threshold, dilate)
        return response

    @staticmethod
    def write_text_on_screen(obelix_ip, slot, search_text):
        """A keyword to match string with ocr text from Obelix
        :param conf: config file for labs
        :param search_text: text to be searched
        """
        ObelixRequests(obelix_ip, slot).write_text_on_screen(search_text)

    @staticmethod
    def get_cust_id(resp):
        """A keyword to match string with ocr text from Obelix
        :param conf: config file for labs
        """
        customer_id = resp.json()['description']['customerId']
        return customer_id

    @staticmethod
    def get_reng_logs(obelix_ip, slot, pattern1, pattern2):
        """A keyword to get logs from RENG
        :param customerId: Id of customer who performed action on CPE
        """
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        username = ""
        password = ""
        resp = ''
        for index in range(1, 4):
            ssh.connect(obelix_ip, slot["RENG"]["Node" + str(index)]["host"],
                        username=username, password=password)
            chan = ssh.invoke_shell()
            chan.send('grep -E "'+pattern1+'" /app/log/TA/node01/jboss/localhost_access_log.'
                      + date.today().isoformat() + '.log'+ ' | grep -c "'+ pattern2 +'"')
            #chan.send('tail -f /app/log/TA/node01/jboss/localhost_access_log.'
            # + date.today().isoformat() + '.log')
            chan.send('\n')
            time.sleep(1)
            resp += chan.recv(99999)
            ssh.close()
        return resp

    @staticmethod
    def get_vrm_logs():
        """A keyword to get logs from VRM
        """
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect('172.23.69.86', username='', password='')
        chan = ssh.invoke_shell()
        # chan.send('grep -E "4275ba00-170f-11e8-ae89-c3c0e0a1f31d"
        # /opt/vrm/jetty-scheduler-BS/logs/scheduler_bs_dev.log')
        chan.send('tail -f /opt/vrm/jetty-scheduler-BS/logs/scheduler_bs_dev.log')
        chan.send('\n')
        time.sleep(1)
        resp = chan.recv(9999999)
        output = resp.decode('utf-8').split(',')
        list_out = (''.join(output))
        ssh.close()
        return list_out

    @staticmethod
    def verify_asset_expire_time(expire_time):
        """A keyword to check whether asset is expired or not
        :param expire_time: expiration time of an asset
        """
        expire_time_in_format = re.sub(r'\.\d\d\dZ', '', expire_time)
        return datetime.now() < datetime.strptime(expire_time_in_format, '%Y-%m-%dT%H:%M:%S')

    @staticmethod
    def take_screenshot(obelix_ip, slot, path):
        """A keyword to take screenshot from Obelix
        :param conf: config file for labs
        :param path: path where screenshot will be saved
                """
        ObelixRequests(obelix_ip, slot).take_screenshot(path)

    @staticmethod
    def black_screen_detection(obelix_ip, slot, deviation=3, deltax="0",
                               deltay="0", width="1920", height="1080"):
        """A keyword to detect black screen"""
        response = ObelixRequests(obelix_ip, slot).black_screen_detection(
            deviation, deltax, deltay, width, height)
        return response
