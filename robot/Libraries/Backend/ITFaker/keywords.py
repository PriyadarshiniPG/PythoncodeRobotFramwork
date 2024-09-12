"""Implementation of ITFaker library's keywords for Robot Framework.
v0.0.1 - Fernando Cobos: Init - get customerID
v0.0.2 - Nidhi Tiwari: Created Keyword get_cpe, check_consisteny,
         get environment_city_id, get_environment_product,
         get_environment. ITFaker method for move_customer
         and refresh_customer were already created hence created
         Keyword class method for them.
"""
import os
import socket
import urllib.parse
import requests
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError


FAKER_TEMPLATE_BASIC = """
{
  "environment": "%(lab)s",
  "cpeId": "%(cpe)s"
}
"""

FAKER_TEMPLATE_ENV = """
{
  "environment": "%(lab)s"
}
"""

FAKER_TEMPLATE_NEW_CUSTOMER = """
{
    "environment":"%(lab)s",
    "cityId":"%(city)s",
    "cpes":
    {
        "%(cpe)s":
        {
            "smartcardId":"%(smartcard)s"
        }
    },
    "products":
    {
        "100000000":{},
        "400000000":{},
        "999999999":{}
    },
    "budgetDetails":
    {
        "budgetLimit":"1000",
        "budgetResetDayOfMonth":"1"
    } 
}
"""
FAKER_TEMPLATE_UPDATE_BUDGET = """{
  "environment": "%(lab)s",
  "cpeId": "%(cpe)s",
  "budgetDetails":{
        "budgetLimit": "1000",
        "budgetResetDayOfMonth": "1"
  } 
}"""
FAKER_TEMPLATE_MOVE_CUSTOMER = """
{
    "environment": "%(lab)s",
    "cpeId": "%(cpe)s",
    "cityId": "%(city)s"
}
"""

FAKER_TEMPLATE_ADD_CPE = """
{
    "environment": "%(lab)s",
    "customerId": "%(customer)s",
    "cpes":
     {
        "%(new_cpe)s":
        {
            "smartcardId": "%(new_smartcard)s"
        }
     }
}
"""

NO_NAGRA_HEADER = {"Content-type": "application/json",
                   "x-provision-nagra": "false"}

NO_CPS_HEADER = {"Content-type": "application/json",
                 "x-provision-cps": "false"}

NO_DOWNSTREAM_HEADER = {"Content-type": "application/json",
                        "x-provision-nagra": "false",
                        "x-provision-cps": "false"}

FULL_DOWNSTREAM_HEADER = {"Content-type": "application/json"}

FAKER_TEMPLATE_CPE = """
{
    "environment": "%(lab)s",
    "customerId": "%(customer)s"
}
"""
FAKER_TEMPLATE_ADD_PRODUCTS = """
{

"environment":"%(lab)s",
"cpeId":"%(cpe)s",
"products":{

"100000000": {
   "beginDate": "2016-12-01T10:00:00.000Z",
   "endDate": "2037-12-01T10:00:00.000Z"
  },
"400000000":{},
"999999999":{
"beginDate":"2016-12-01T10:00:00.000Z",
"endDate":"2037-12-01T10:00:00.000Z" 
}
}
}
"""

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


def http_send(method, url, data=None, headers=None):
    """Send HTTP GET/POST request and use try-except block for any error handling

    :param method: an HTTP method, e.g. "POST".
    :param url: a url used to send the request.
    :param data: a string of data sent (if any).
    :param headers: header to be sent with the request.

    :return: an HTTP response instance.
    """

    try:
        BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                    urllib.parse.urlparse(url).path)
    except RobotNotRunningError:
        pass

    try:
        if method == "GET":
            response = requests.get(url, headers=headers)
        elif method == "POST":
            response = requests.post(url, data=data, headers=headers)
    except (requests.exceptions.ConnectionError, socket.gaierror) as err:
        print(("Could not send %s %s due to %s" % (method, url, err)))
        response = failed_response_data("GET", url, None, err)
    return response


class ITFaker_Requests(object):
    """A class to handle requests to ITFaker."""

    def __init__(self, lab_conf, cpe_id=None):
        """The class initializer.

        :param lab_conf: the conf dictionary, containig ITFaker settings.
        :param cpe_id: the id of CPE EOS, e.g. "3C36E4-EOSSTB-003356472104".
        """
        self.conf = lab_conf
        self.cpe = cpe_id
        if "itfaker" in self.conf["ITFAKER"]["host"]:
            self.main_url = "http://%s" % (self.conf["ITFAKER"]["host"])
        else:
            self.main_url = "http://%s:%s" % \
                (self.conf["ITFAKER"]["host"], self.conf["ITFAKER"]["port"])
        try:
            # Use folder name where this file is placed
            # (as Traxis, Fabrix, PurchaseMicroservice, etc) as a tag
            folder_name = os.path.basename(os.path.dirname(os.path.realpath(__file__)))
            BuiltIn().set_test_variable("${ENDPOINT_TAG}", "%s" % folder_name)
        except RobotNotRunningError:
            pass

    def create_new_customer(self, city_id, smartcard_id, nagra=True, cps=True):
        """A method to send a POST request to IT Faker to create a new customer
        :param city_id: The city ID for the user
        :param smartcard_id: Customer SC ID, choose this to match the CPE ID,
            note that the SC ID has the last two digits removed and so they are
            not used in deciding if a SCID is unique (all must be unique):
                400000000111 == 400000000199
                400000000100 != 400000000200
        :param nagra: Boolean, provisioning in Nagra. Default TRUE
        :param cps: Boolean, provisioning in CPS. Default TRUE

        :return response: full response from IT faker
        """

        if nagra and cps:
            headers = FULL_DOWNSTREAM_HEADER
        elif cps and not nagra:
            headers = NO_NAGRA_HEADER
        elif nagra and not cps:
            headers = NO_CPS_HEADER
        else:
            headers = NO_DOWNSTREAM_HEADER

        url = "%s/newCustomer" % self.main_url
        data = FAKER_TEMPLATE_NEW_CUSTOMER % {"cpe": self.cpe,
                                              "lab": self.conf["ITFAKER"]["env"],
                                              "smartcard": smartcard_id,
                                              "city": city_id}
        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.post(url, data=data, headers=headers)
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send POST %s due to %s" % (url, err)))
            response = failed_response_data("POST", url, data, err)
        return response

    def delete_customer(self, nagra=True, cps=True):
        """A method to send a POST request to IT Faker to delete new customer
        :param nagra: Boolean, provisioning in Nagra. Default TRUE
        :param cps: Boolean, provisioning in CPS. Default TRUE

        :return response: full response from IT faker
        """

        if nagra and cps:
            headers = FULL_DOWNSTREAM_HEADER
        elif cps and not nagra:
            headers = NO_NAGRA_HEADER
        elif nagra and not cps:
            headers = NO_CPS_HEADER
        else:
            headers = NO_DOWNSTREAM_HEADER

        url = "%s/deleteCustomer" % self.main_url
        data = FAKER_TEMPLATE_BASIC % {"cpe": self.cpe, "lab": self.conf["ITFAKER"]["env"]}

        try:
            BuiltIn().set_test_variable("${URL_PATH}", "%s" %
                                        urllib.parse.urlparse(url).path)
        except RobotNotRunningError:
            pass

        try:
            response = requests.post(url, data=data, headers=headers)
        except (requests.exceptions.ConnectionError, socket.gaierror) as err:
            print(("Could not send POST %s due to %s" % (url, err)))
            response = failed_response_data("POST", url, data, err)
        return response

    def move_customer(self, newcity):
        """A method to send a POST request to IT Faker to delete new customer
        :param newcity: The city ID that the user is to be moved to.

        :return response: full response from IT faker
        """
        url = "%s/moveCustomer" % self.main_url
        headers = FULL_DOWNSTREAM_HEADER
        data = FAKER_TEMPLATE_MOVE_CUSTOMER % {"lab": self.conf["ITFAKER"]["env"],
                                               "cpe": self.cpe,
                                               "city": newcity}
        response = http_send("POST", url, data, headers)
        if response.status_code != 200:
            BuiltIn().log_to_console("To move_customer we send POST to %s . "
                                     "\nData:\n%s\nHeaders:%s . Status code: %s, Reason: %s"
                                     % (url, data, headers, response.status_code, response.reason))
        return response

    def suspend_customer(self):
        """A method to perform a Suspend Customer request to IT Faker
        :return response: full response from IT faker
        """

        headers = FULL_DOWNSTREAM_HEADER
        url = "%s/suspendCustomer" % self.main_url
        data = FAKER_TEMPLATE_BASIC % {"cpe": self.cpe, "lab": self.conf["ITFAKER"]["env"]}
        response = http_send("POST", url, data, headers)
        if response.status_code != 200:
            BuiltIn().log_to_console("To suspend_customer we send POST to %s . "
                                     "\nData:\n%s\nHeaders:%s . Status code: %s, Reason: %s"
                                     % (url, data, headers, response.status_code, response.reason))
        return response

    def activate_customer(self):
        """A method to perform an Activate Customer request to IT Faker
        :return response: full response from IT faker
        """
        headers = FULL_DOWNSTREAM_HEADER
        url = "%s/activateCustomer" % self.main_url
        data = FAKER_TEMPLATE_BASIC % {"cpe": self.cpe, "lab": self.conf["ITFAKER"]["env"]}
        response = http_send("POST", url, data, headers)
        if response.status_code != 200:
            BuiltIn().log_to_console("To activate_customer we send POST to %s . "
                                     "\nData:\n%s\nHeaders:%s . Status code: %s, Reason: %s"
                                     % (url, data, headers, response.status_code, response.reason))
        return response

    def refresh_customer(self):
        """A method sends GET request to ITFaker to refresh customer.
        :return: a full response from the ITFaker.
        """
        headers = FULL_DOWNSTREAM_HEADER
        url = "%s/refreshCustomer" % self.main_url
        data = FAKER_TEMPLATE_BASIC % {"cpe": self.cpe, "lab": self.conf["ITFAKER"]["env"]}
        response = http_send("POST", url, data, headers)
        if response.status_code != 200:
            BuiltIn().log_to_console("To refresh_customer we send POST to %s . "
                                     "\nData:\n%s\nHeaders:%s . Status code: %s, Reason: %s"
                                     % (url, data, headers, response.status_code, response.reason))
        return response

    def get_customer(self):
        """A method sends GET request to ITFaker to obtain data about customer.
        :return: a full response from the ITFaker.
        """
        headers = FULL_DOWNSTREAM_HEADER
        url = "%s/getCustomer" % self.main_url
        data = FAKER_TEMPLATE_BASIC % {"cpe": self.cpe, "lab": self.conf["ITFAKER"]["env"]}
        response = http_send("POST", url, data, headers)
        if response.status_code != 200:
            BuiltIn().log_to_console("To get_customer from ITfaker we send POST to %s\nData:\n%s"
                                     "\nHeaders:\n%s\nStatus_code:%s. Reason: %s"
                                     % (url, data, headers, response.status_code, response.reason))
        return response

    def add_cpes(self, new_cpe, new_smartcard):
        """A method sends POST request to ITFaker to add a cpe to
         an existing customer.
        :return: a full response from the ITFaker.
        """
        customer = self.get_customer().json()['description']['customerId']
        headers = FULL_DOWNSTREAM_HEADER
        url = "%s/addCpes" % self.main_url
        data = FAKER_TEMPLATE_ADD_CPE % {"lab": self.conf["ITFAKER"]["env"],
                                         "customer": customer,
                                         "new_cpe": new_cpe,
                                         "new_smartcard": new_smartcard}
        response = http_send("POST", url, data, headers)
        if response.status_code != 200:
            BuiltIn().log_to_console("To add_cpes we send POST to %s . "
                                     "\nData:\n%s\nHeaders:%s . Status code: %s, Reason: %s"
                                     % (url, data, headers, response.status_code, response.reason))
        return response

    def get_cpe(self):
        """A method to send a POST request to IT Faker to get cpe details

        :return response: full response from IT faker
        """
        url = "%s/getCpe" % self.main_url
        headers = FULL_DOWNSTREAM_HEADER
        data = FAKER_TEMPLATE_BASIC % {"lab": self.conf["ITFAKER"]["env"], "cpe": self.cpe}
        response = http_send("POST", url, data, headers)
        if response.status_code != 200:
            BuiltIn().log_to_console("To get_cpe we send POST to %s . "
                                     "\nData:\n%s\nHeaders:%s . Status code: %s, Reason: %s"
                                     % (url, data, headers, response.status_code, response.reason))
        return response

    def check_consistency(self):
        """A method to send a POST request to IT Faker to do Consistency check towards CPS

        :return response: full response from IT faker
        """
        url = "%s/checkConsistency" % self.main_url
        headers = FULL_DOWNSTREAM_HEADER
        data = FAKER_TEMPLATE_BASIC % {"lab": self.conf["ITFAKER"]["env"], "cpe": self.cpe}
        response = http_send("POST", url, data, headers)
        if response.status_code != 200:
            BuiltIn().log_to_console("To check_consistency we send POST to %s . "
                                     "\nData:\n%s\nHeaders:%s . Status code: %s, Reason: %s\n"
                                     "Message is: %s\n"
                                     % (url, data, headers, response.status_code, response.reason,
                                        response.text))
        return response

    def get_environment_city_id(self):
        """A method to send a POST request to IT Faker to get city ids for given environment

        :return response: full response from IT faker
        """
        url = "%s/getEnvironmentCityIds" % self.main_url
        headers = FULL_DOWNSTREAM_HEADER
        data = FAKER_TEMPLATE_ENV % {"lab": self.conf["ITFAKER"]["env"]}
        response = http_send("POST", url, data, headers)
        if response.status_code != 200:
            BuiltIn().log_to_console("To get_environment_city_id we send POST to %s . "
                                     "\nData:\n%s\nHeaders:%s . Status code: %s, Reason: %s"
                                     % (url, data, headers, response.status_code, response.reason))
        return response

    def get_environment_products(self):
        """A method to send a POST request to get available products for given environment

        :return response: full response from IT faker
        """
        url = "%s/getEnvironmentProducts" % self.main_url
        headers = FULL_DOWNSTREAM_HEADER
        data = FAKER_TEMPLATE_ENV % {"lab": self.conf["ITFAKER"]["env"]}
        response = http_send("POST", url, data, headers)
        if response.status_code != 200:
            BuiltIn().log_to_console("To get_environment_products we send POST to %s . "
                                     "\nData:\n%s\nHeaders:%s . Status code: %s, Reason: %s"
                                     % (url, data, headers, response.status_code, response.reason))
        return response

    def get_environment(self):
        """A method to send a POST request to get details of given environment

        :return response: full response from IT faker
        """
        url = "%s/getEnvironment" % self.main_url
        headers = FULL_DOWNSTREAM_HEADER
        data = FAKER_TEMPLATE_ENV % {"lab": self.conf["ITFAKER"]["env"]}
        response = http_send("POST", url, data, headers)
        if response.status_code != 200:
            BuiltIn().log_to_console("To get_environment we send POST to %s . "
                                     "\nData:\n%s\nHeaders:%s . Status code: %s, Reason: %s"
                                     % (url, data, headers, response.status_code, response.reason))
        return response

    def pin_reset(self):
        """A method to send a POST request to IT Faker to reset pin for given cpe

        :return response: full response from IT faker
        """
        url = "%s/pinReset" % self.main_url
        headers = FULL_DOWNSTREAM_HEADER
        data = FAKER_TEMPLATE_BASIC % {"lab": self.conf["ITFAKER"]["env"], "cpe": self.cpe}
        response = http_send("POST", url, data, headers)
        if response.status_code != 200:
            BuiltIn().log_to_console("To pin_reset we send POST to %s . "
                                     "\nData:\n%s\nHeaders:%s . Status code: %s, Reason: %s"
                                     % (url, data, headers, response.status_code, response.reason))
        return response

    def get_products(self):
        """A method to send a POST request to IT Faker to get cpe details

        :return response: full response from IT faker
        """
        url = "%s/getProducts" % self.main_url
        headers = FULL_DOWNSTREAM_HEADER
        data = FAKER_TEMPLATE_BASIC % {"lab": self.conf["ITFAKER"]["env"], "cpe": self.cpe}
        response = http_send("POST", url, data, headers)
        if response.status_code != 200:
            BuiltIn().log_to_console("To get_products we send POST to %s . "
                                     "\nData:\n%s\nHeaders:%s . Status code: %s, Reason: %s"
                                     % (url, data, headers, response.status_code, response.reason))
        return response

    def activate_cpe(self, customer_id):
        """A method to send a POST request to IT Faker to activate a cpe
        :param customer_id: customer Id like 'ecfe90d0-e575-11e7-a6bf-755914bd09e0_nl'.
        :return response: full response from IT faker
        """
        if "_" in customer_id:
            customer_id = customer_id[:-3]
        url = "%s/activateCpes" % self.main_url
        headers = FULL_DOWNSTREAM_HEADER
        data = FAKER_TEMPLATE_CPE % {"lab": self.conf["ITFAKER"]["env"], "customer": customer_id}
        response = http_send("POST", url, data, headers)
        if response.status_code != 200:
            BuiltIn().log_to_console("To activate_cpe we send POST to %s . "
                                     "\nData:\n%s\nHeaders:%s . Status code: %s, Reason: %s"
                                     % (url, data, headers, response.status_code, response.reason))
        return response

    def deactivate_cpe(self, customer_id):
        """A method to send a POST request to IT Faker to deactivate a cpe
        :param customer_id: customer Id like 'ecfe90d0-e575-11e7-a6bf-755914bd09e0_nl'.
        :return response: full response from IT faker
        """
        if "_" in customer_id:
            customer_id = customer_id[:-3]
        url = "%s/deactivateCpes" % self.main_url
        headers = FULL_DOWNSTREAM_HEADER
        data = FAKER_TEMPLATE_CPE % {"lab": self.conf["ITFAKER"]["env"], "customer": customer_id}
        response = http_send("POST", url, data, headers)
        if response.status_code != 200:
            BuiltIn().log_to_console("To deactivate_cpe we send POST to %s . "
                                     "\nData:\n%s\nHeaders:%s . Status code: %s, Reason: %s"
                                     % (url, data, headers, response.status_code, response.reason))
        return response

    def delete_budget(self):
        """A method to send a POST request to IT Faker to delete budget details for customer

        :return response: full response from IT faker
        """
        url = "%s/deleteBudgetDetails" % self.main_url
        headers = FULL_DOWNSTREAM_HEADER
        data = FAKER_TEMPLATE_BASIC % {"lab": self.conf["ITFAKER"]["env"], "cpe": self.cpe}
        response = http_send("POST", url, data, headers)
        if response.status_code != 200:
            BuiltIn().log_to_console("To delete_budget we send POST to %s . "
                                     "\nData:\n%s\nHeaders:%s . Status code: %s, Reason: %s"
                                     % (url, data, headers, response.status_code, response.reason))
        return response

    def update_budget(self):
        """A method to send a POST request to IT Faker to update budget details for customer

        :return response: full response from IT faker
        """
        url = "%s/updateBudgetDetails" % self.main_url
        headers = FULL_DOWNSTREAM_HEADER
        data = FAKER_TEMPLATE_UPDATE_BUDGET % {"lab": self.conf["ITFAKER"]["env"], "cpe": self.cpe}
        response = http_send("POST", url, data, headers)
        if response.status_code != 200:
            BuiltIn().log_to_console("To update_budget we send POST to %s . "
                                     "\nData:\n%s\nHeaders:%s . Status code: %s, Reason: %s"
                                     % (url, data, headers, response.status_code, response.reason))
        return response

    def add_products(self):
        """A method to send a POST request to IT Faker to get cpe details

        :return response: full response from IT faker
        """
        url = "%s/addProducts" % self.main_url
        headers = FULL_DOWNSTREAM_HEADER
        data = FAKER_TEMPLATE_ADD_PRODUCTS % {"lab": self.conf["ITFAKER"]["env"], "cpe": self.cpe}
        response = http_send("POST", url, data, headers)
        if response.status_code != 200:
            BuiltIn().log_to_console("To add_products we send POST to %s . "
                                     "\nData:\n%s\nHeaders:%s . Status code: %s, Reason: %s"
                                     % (url, data, headers, response.status_code, response.reason))
        return response


class Keywords(object):
    """Keywords visible in Robot Framework."""
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @staticmethod
    def create_itfaker_customer(lab_conf, cpe_id, city_id, smartcard_id, nagra, cps):
        """A keyword to create a new customer using IT Faker.

        :param lab_conf: the conf dictionary, containig ITFaker settings.\n
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".\n
        :param city_id: The city ID for the user\n
        :param smartcard_id: Customer SC ID, choose this to match the CPE ID,
            note that the SC ID has the last two digits removed and so they are
            not used in deciding if a SCID is unique (all must be unique):
                400000000111 == 400000000199
                400000000100 != 400000000200\n
        :param nagra: Boolean, skip provisioning in Nagra. Default FALSE\n
        :param cps: Boolean, skip provisioning in CPS. Default FALSE\n

        :return response: full response from IT faker
        """
        itf_obj = ITFaker_Requests(lab_conf, cpe_id)
        response = itf_obj.create_new_customer(city_id, smartcard_id, nagra, cps)
        return response

    @staticmethod
    def delete_itfaker_customer(lab_conf, cpe_id, nagra, cps):
        """A keyword to create a new customer using IT Faker.

        :param lab_conf: the conf dictionary, containig ITFaker settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".
        :param nagra: Boolean, skip provisioning in Nagra. Default FALSE
        :param cps: Boolean, skip provisioning in CPS. Default FALSE

        :return response: full response from IT faker
        """
        itf_obj = ITFaker_Requests(lab_conf, cpe_id)
        response = itf_obj.delete_customer(nagra, cps)
        return response

    @staticmethod
    def get_itfaker_customer(lab_conf, cpe_id):
        """A keyword to obtain recordings from ITFaker for the given CPE.

        :param lab_conf: the conf dictionary, containig ITFaker settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: a python non-altered text of ITFaker response - a json string.
        """
        return ITFaker_Requests(lab_conf, cpe_id).get_customer()

    @staticmethod
    def suspend_customer(lab_conf, cpe_id):
        """A keyword to obtain recordings from ITFaker for the given CPE.

        :param lab_conf: the conf dictionary, containig ITFaker settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: Full response from IT Faker
        """
        itf_obj = ITFaker_Requests(lab_conf, cpe_id)
        response = itf_obj.suspend_customer()
        return response

    @staticmethod
    def activate_customer(lab_conf, cpe_id):
        """A keyword to obtain recordings from ITFaker for the given CPE.

        :param lab_conf: the conf dictionary, containig ITFaker settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: Full response from IT Faker
        """
        itf_obj = ITFaker_Requests(lab_conf, cpe_id)
        response = itf_obj.activate_customer()
        return response

    @staticmethod
    def move_customer(lab_conf, cpe_id, newcity):
        """A keyword to move cutomer to given city.

        :param lab_conf: the conf dictionary, containig ITFaker settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".
        :param city_id: The city ID for the user\n

        :return: Full response from IT Faker
        """
        itf_obj = ITFaker_Requests(lab_conf, cpe_id)
        response = itf_obj.move_customer(newcity)
        return response

    @staticmethod
    def refresh_customer(lab_conf, cpe_id):
        """A keyword to refresh cutomer.

        :param lab_conf: the conf dictionary, containig ITFaker settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".
        :param city_id: The city ID for the user\n

        :return: Full response from IT Faker
        """
        itf_obj = ITFaker_Requests(lab_conf, cpe_id)
        response = itf_obj.refresh_customer()
        return response

    @staticmethod
    def get_cpe(lab_conf, cpe_id):
        """A keyword to get cpe details.

        :param lab_conf: the conf dictionary, containig ITFaker settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: Full response from IT Faker
        """
        itf_obj = ITFaker_Requests(lab_conf, cpe_id)
        response = itf_obj.get_cpe()
        return response

    @staticmethod
    def check_consistency(lab_conf, cpe_id):
        """A keyword to check cpe consistency.

        :param lab_conf: the conf dictionary, containig ITFaker settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: Full response from IT Faker
        """
        itf_obj = ITFaker_Requests(lab_conf, cpe_id)
        response = itf_obj.check_consistency()
        return response

    @staticmethod
    def get_environment_city_id(lab_conf, cpe_id):
        """A keyword to get city ids for given environment.

        :param lab_conf: the conf dictionary, containig ITFaker settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: Full response from IT Faker
        """
        itf_obj = ITFaker_Requests(lab_conf, cpe_id)
        response = itf_obj.get_environment_city_id()
        return response

    @staticmethod
    def get_environment_products(lab_conf, cpe_id):
        """A keyword to get available products for given environment.

        :param lab_conf: the conf dictionary, containig ITFaker settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: Full response from IT Faker
        """
        itf_obj = ITFaker_Requests(lab_conf, cpe_id)
        response = itf_obj.get_environment_products()
        return response

    @staticmethod
    def get_environment(lab_conf, cpe_id):
        """A keyword to get environment details.

        :param lab_conf: the conf dictionary, containig ITFaker settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: Full response from IT Faker
        """

        itf_obj = ITFaker_Requests(lab_conf, cpe_id)
        response = itf_obj.get_environment()

        return response

    @staticmethod
    def pin_reset(lab_conf, cpe_id):
        """A keyword to reset pin for given cpe.

        :param lab_conf: the conf dictionary, containig ITFaker settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: Full response from IT Faker
        """
        itf_obj = ITFaker_Requests(lab_conf, cpe_id)
        response = itf_obj.pin_reset()
        return response

    @staticmethod
    def get_products(lab_conf, cpe_id):
        """A keyword to get cpe details.

        :param lab_conf: the conf dictionary, containig ITFaker settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: Full response from IT Faker
        """
        itf_obj = ITFaker_Requests(lab_conf, cpe_id)
        response = itf_obj.get_products()
        return response

    @staticmethod
    def activate_cpe(lab_conf, cpe_id, customer_id):
        """A keyword to activate cpe.

        :param lab_conf: the conf dictionary, containig ITFaker settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".
        :param customer_id: customer Id like 'ecfe90d0-e575-11e7-a6bf-755914bd09e0_nl'.

        :return: Full response from IT Faker
        """

        itf_obj = ITFaker_Requests(lab_conf, cpe_id)
        response = itf_obj.activate_cpe(customer_id)
        return response

    @staticmethod
    def deactivate_cpe(lab_conf, cpe_id, customer_id):
        """A keyword to deactivate cpe.

        :param lab_conf: the conf dictionary, containig ITFaker settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".
        :param customer_id: customer Id like 'ecfe90d0-e575-11e7-a6bf-755914bd09e0_nl'.

        :return: Full response from IT Faker
        """
        itf_obj = ITFaker_Requests(lab_conf, cpe_id)
        response = itf_obj.deactivate_cpe(customer_id)
        return response

    @staticmethod
    def delete_budget(lab_conf, cpe_id):
        """A keyword to delete customer budget information.

        :param lab_conf: the conf dictionary, containig ITFaker settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: Full response from IT Faker
        """
        itf_obj = ITFaker_Requests(lab_conf, cpe_id)
        response = itf_obj.delete_budget()
        return response


    @staticmethod
    def update_budget(lab_conf, cpe_id):
        """A keyword to delete customer budget information.

        :param lab_conf: the conf dictionary, containig ITFaker settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: Full response from IT Faker
        """
        itf_obj = ITFaker_Requests(lab_conf, cpe_id)
        response = itf_obj.update_budget()
        return response

    @staticmethod
    def add_products(lab_conf, cpe_id):
        """A keyword to get cpe details.

        :param lab_conf: the conf dictionary, containig ITFaker settings.
        :param cpe_id: the id of CPE (EOS), e.g. "3C36E4-EOSSTB-003356472104".

        :return: Full response from IT Faker
        """
        itf_obj = ITFaker_Requests(lab_conf, cpe_id)
        response = itf_obj.add_products()
        return response
