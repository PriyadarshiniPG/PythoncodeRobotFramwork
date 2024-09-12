# pylint: disable=unused-argument
# Disabled pylint "unused-argument" complaining on the mock patches

"""Unit tests of ITFaker library's keywords for Robot Framework.

Tests use mock module and do not send real requests to real ITFaker.
The global function debug() can be used for testing requests to real ITFaker.

v0.0.1 - Fernando Cobos: init &  get_ITFaker_customer to unittest
"""
import unittest
try:
    import mock
except ImportError:
    import unittest.mock as mock
import socket
import requests
from .keywords import Keywords


LAB_CONF = {
    "MOCK": {"ITFAKER": {"host": "127.0.0.1", "port": 80, "env": "lab5a"}},
    "REAL": {"ITFAKER": {"host": "172.30.182.30", "port": 8000, "env": "lab5a"}}
}

SAMPLE_RESPONSE = """{"status":200,"message":"OK","description":{"cityId":"schiphol1",
"suspended":false,"budgetDetails":{"budgetLimit":"10000","budgetResetDayOfMonth":"1"},
"cpes":{"3C36E4-EOSSTB-003356472104":{"smartcardId":"286152333144","disabled":false}},
"products":{"11":{"beginDate":"2017-07-19T00:00:00.555Z","endDate":"2018-07-19T00:00:00.555Z",
"name":"Play Sports","linkedIds":["crid://nagra.elk/00000000-0000-0000-0000-000000000011"],
"description":"Play Sports Pack. (Subscription for Mechelen region) - (Nagra ID: 11)",
"location":"Mechelen"},"142":{"beginDate":"2017-07-19T00:00:00.555Z",
"endDate":"2018-07-19T00:00:00.555Z","name":"Play",
"linkedIds":["crid://nagra.elk/00000000-0000-0000-0000-000000000142"],
"description":"Play Pack. (Subscription for Mechelen region) - (Nagra ID: 142)",
"location":"Mechelen"},"143":{"beginDate":"2017-07-19T00:00:00.555Z",
"endDate":"2018-07-19T00:00:00.555Z","name":"Play More",
"linkedIds":["crid://nagra.elk/00000000-0000-0000-0000-000000000143"],
"description":"Play More Pack. (Subscription for Mechelen region) - (Nagra ID: 143)",
"location":"Mechelen"},"1003":{"beginDate":"2017-07-19T00:00:00.555Z",
"endDate":"2018-07-19T00:00:00.555Z","name":"Replay-3",
"linkedIds":["crid://schange.com/d4afe49e-f6f7-4c0f-a721-d5bbb9a485b1"],
"description":"Replay-3 Pack. (Subscription for All region) - (Product ID: 1003)",
"location":"All",
"tstvProps":"{ 'replayDuration': 259200, 'allowReplayTV': true, 'allowStartOver': true, 'isVosdal': false }",
"traxisOnly":true},"1007":{"beginDate":"2017-07-19T00:00:00.555Z",
"endDate":"2018-07-19T00:00:00.555Z","name":"Replay-7-Vosdal",
"linkedIds":["crid://schange.com/92536e39-f300-436b-ad16-07bc8d5e9459"],
"description":"Replay-7-Vosdal Pack. (Subscription for All region) - (Product ID: 1007)","location":"All",
"tstvProps":"{ 'replayDuration': 604800, 'allowReplayTV': true, 'allowStartOver': true, 'isVosdal': true }",
"traxisOnly":true},"100000000":{"beginDate":"2017-07-19T00:00:00.555Z","endDate":"2018-07-19T00:00:00.555Z",
"name":"SD All","linkedIds":["crid://eventis.nl/00000000-0000-1000-0008-000100000000"],
"description":"SD All Pack. (Subscription for Schiphol region) - (Nagra ID: 100000000)",
"location":"Schiphol"},"400000000":{"beginDate":"2017-05-31T08:37:25.583Z",
"endDate":"2037-12-01T10:00:00.000Z","name":"","linkedIds":[]},
"999999999":{"beginDate":"2017-05-31T08:37:25.583Z","endDate":"2037-12-01T10:00:00.000Z",
"name":"VIP","linkedIds":["crid://eventis.nl/00000000-0000-1000-0008-000999999999"],
"description":"VIP Pack. (Subscription for Schiphol region) - (Nagra ID: 999999999)",
"location":"Schiphol"}},"downstreamError":true,"customerId":"3256f840-4d12-11e7-85f5-e5a72ae6734d"
}}"""

SUSPEND_SUCCESS = """{"status":200,"message":"OK","description":\
{"customerId":"CUSTOMERIDSUSPEND"}}"""

ACTIVATE_SUCCESS = """{"status":200,"message":"OK","description":\
{"customerId":"CUSTOMERIDACTIVATE"}}"""


REFRESH_SUCCESS = """{"status": 200,"message": "OK","description":\
{"customerId": "CUSTOMERIDREFRESH"}}"""

GET_CPE_SUCCESS = """MOCK_GET_CPE_SUCCESS"""

GET_PRODUCTS_SUCCESS = """MOCK_GET_PRODUCTS_SUCCESS"""

CHECK_CONSISTENCY_SUCCESS = """MOCK_CHECK_CONSISTENCY_SUCCESS"""

PIN_RESET_SUCCESS = """MOCK_PIN_RESET_SUCCESS"""

MOVE_SUCCESS = """MOCK_MOVE_SUCCESS"""

ACTIVATE_CPE_SUCCESS = """ACTIVATE_CPE_SUCCESS"""

DEACTIVATE_CPE_SUCCESS = """DEACTIVATE_CPE_SUCCESS"""

DELETE_BUDGET_SUCCESS = """DELETE_BUDGET_SUCCESS"""

UPDATE_BUDGET_SUCCESS = """UPDATE_BUDGET_SUCCESS"""

ADD_PRODUCT_SUCCESS = """MOCK_ADD_PRODUCT_SUCCESS"""

SUSPEND_FAILURE = """{
  "status": 500,
  "message": "Internal Server Error",
  "description": [
    {
      "type": "transaction",
      "error": {
        "status": 502,
        "message": "Bad Gateway",
        "description": "[{\"system\":\"TRAXIS\",\"status\":\"success\",\"responseCode\":200,\"message\":\"\"},{\"system\":\"VRM\",\"status\":\"success\",\"responseCode\":200,\"message\":\"{}\"},{\"system\":\"PURCHASE_SERVICE\",\"status\":\"failure\",\"responseCode\":409,\"message\":\"{\\\"error\\\":{\\\"httpStatusCode\\\":409,\\\"statusCode\\\":100411,\\\"message\\\":\\\"Customer already deactivated\\\",\\\"details\\\":\\\"Customer status is already set to: INACTIVE\\\",\\\"correlationId\\\":\\\"5797f07f17e0d9ca2cf26d87f007414b,5797f07f17e0d9ca2cf26d87f007414b,5797f07f17e0d9ca2cf26d87f007414b,5797f07f17e0d9ca2cf26d87f007414b\\\"}}\"}]"
      }
    }
  ]
}"""

ACTIVATE_FAILURE = """{
  "status": 500,
  "message": "Internal Server Error",
  "description": [
    {
      "type": "transaction",
      "error": {
        "status": 502,
        "message": "Bad Gateway",
        "description": "[{\"system\":\"VRM\",\"status\":\"success\",\"responseCode\":200,\"message\":\"{}\"},{\"system\":\"PURCHASE_SERVICE\",\"status\":\"failure\",\"responseCode\":409,\"message\":\"{\\\"error\\\":{\\\"httpStatusCode\\\":409,\\\"statusCode\\\":100410,\\\"message\\\":\\\"Customer already activated\\\",\\\"details\\\":\\\"Customer status is already set to: ACTIVE\\\",\\\"correlationId\\\":\\\"c4033d646415ee2c17b8bda58830bcfa,c4033d646415ee2c17b8bda58830bcfa,c4033d646415ee2c17b8bda58830bcfa,c4033d646415ee2c17b8bda58830bcfa\\\"}}\"},{\"system\":\"TRAXIS\",\"status\":\"success\",\"responseCode\":200,\"message\":\"\"}]"
      }
    }
  ]
}"""

def mock_requests_post(*args, **kwargs):
    """A method imitates sending requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    req_data = kwargs["data"]

    if "test1" in req_data:
        response_data = dict(text=SAMPLE_RESPONSE, status_code=200, reason="OK")
    elif "test2" in req_data:
        response_data = dict(text=ACTIVATE_SUCCESS, status_code=200, reason="OK")
    elif "test3" in req_data:
        response_data = dict(text=SUSPEND_SUCCESS, status_code=200, reason="OK")
    elif "test4" in req_data:
        response_data = dict(text=REFRESH_SUCCESS, status_code=200, reason="OK")
    elif "test5" in req_data:
        response_data = dict(text=GET_CPE_SUCCESS, status_code=200, reason="OK")
    elif "test6" in req_data:
        response_data = dict(text=CHECK_CONSISTENCY_SUCCESS, status_code=200, reason="OK")
    elif "test7" in req_data:
        response_data = dict(text=PIN_RESET_SUCCESS, status_code=200, reason="OK")
    elif "test8" in req_data:
        response_data = dict(text=MOVE_SUCCESS, status_code=200, reason="OK")
    elif "test9" in req_data:
        response_data = dict(text=GET_PRODUCTS_SUCCESS, status_code=200, reason="OK")
    elif "testTen" in req_data:
        response_data = dict(text=ACTIVATE_CPE_SUCCESS, status_code=200, reason="OK")
    elif "testEleven" in req_data:
        response_data = dict(text=DEACTIVATE_CPE_SUCCESS, status_code=200, reason="OK")
    elif "testTwelve" in req_data:
        response_data = dict(text=DELETE_BUDGET_SUCCESS, status_code=200, reason="OK")
    elif "testThirteen" in req_data:
        response_data = dict(text=UPDATE_BUDGET_SUCCESS, status_code=200, reason="OK")
    elif "testFourteen" in req_data:
        response_data = dict(text=ADD_PRODUCT_SUCCESS, status_code=200, reason="OK")
    elif "refused" in req_data:
        raise requests.exceptions.ConnectionError("[WinError 10061] No connection could be made " +
                                                  "because the target machine actively refused it")
    elif "failed" in req_data:
        raise socket.gaierror("[Errno 11001] getaddrinfo failed")
    return type("", (), response_data)()


@mock.patch("requests.post", side_effect=mock_requests_post)
def get_itfaker_customer(*args):
    """Function to call the /info section of the service
    and validate a 200/OK response
    """

    conf, cpeid = args[:-1]
    return Keywords().get_itfaker_customer(conf, cpeid)


@mock.patch("requests.post", side_effect=mock_requests_post)
def suspend_customer(*args):
    """Function to call the /info section of the service
    and validate a 200/OK response
    """

    conf, cpeid = args[:-1]
    return Keywords().suspend_customer(conf, cpeid)


@mock.patch("requests.post", side_effect=mock_requests_post)
def activate_customer(*args):
    """Function to call the /info section of the service
    and validate a 200/OK response
    """

    conf, cpeid = args[:-1]
    return Keywords().activate_customer(conf, cpeid)


@mock.patch("requests.post", side_effect=mock_requests_post)
def refresh_customer(*args):
    """Function to call the /info section of the service
    and validate a 200/OK response
    """

    conf, cpeid = args[:-1]
    return Keywords().refresh_customer(conf, cpeid)


@mock.patch("requests.post", side_effect=mock_requests_post)
def get_cpe(*args):
    """Function to call the /info section of the service
    and validate a 200/OK response
    """

    conf, cpeid = args[:-1]
    return Keywords().get_cpe(conf, cpeid)


@mock.patch("requests.post", side_effect=mock_requests_post)
def check_consistency(*args):
    """Function to call the /info section of the service
    and validate a 200/OK response
    """

    conf, cpeid = args[:-1]
    return Keywords().check_consistency(conf, cpeid)


@mock.patch("requests.post", side_effect=mock_requests_post)
def pin_reset(*args):
    """Function to call the /info section of the service
    and validate a 200/OK response
    """

    conf, cpeid = args[:-1]
    return Keywords().pin_reset(conf, cpeid)


@mock.patch("requests.post", side_effect=mock_requests_post)
def move_customer(*args):
    """Function to call the /info section of the service
    and validate a 200/OK response
    """

    conf, cpeid, cityid = args[:-1]
    return Keywords().move_customer(conf, cpeid, cityid)


@mock.patch("requests.post", side_effect=mock_requests_post)
def get_products(*args):
    """Function to call the /info section of the service
    and validate a 200/OK response
    """

    conf, cpeid = args[:-1]

    return Keywords().get_products(conf, cpeid)


@mock.patch("requests.post", side_effect=mock_requests_post)
def activate_cpe(*args):
    """Function to call the /info section of the service
    and validate a 200/OK response
    """

    conf, cpeid, customerid = args[:-1]
    return Keywords().activate_cpe(conf, cpeid, customerid)


@mock.patch("requests.post", side_effect=mock_requests_post)
def deactivate_cpe(*args):
    """Function to call the /info section of the service
    and validate a 200/OK response
    """

    conf, cpeid, customerid = args[:-1]
    return Keywords().deactivate_cpe(conf, cpeid, customerid)


@mock.patch("requests.post", side_effect=mock_requests_post)
def delete_budget(*args):
    """Function to call the /info section of the service
    and validate a 200/OK response
    """

    conf, cpeid = args[:-1]
    return Keywords().delete_budget(conf, cpeid)


@mock.patch("requests.post", side_effect=mock_requests_post)
def update_budget(*args):
    """Function to call the /info section of the service
    and validate a 200/OK response
    """

    conf, cpeid = args[:-1]
    return Keywords().update_budget(conf, cpeid)


@mock.patch("requests.post", side_effect=mock_requests_post)
def add_product(*args):
    """Function to call the /info section of the service
    and validate a 200/OK response
    """

    conf, cpeid = args[:-1]
    return Keywords().add_products(conf, cpeid)

class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


class TestKeyword_ITFaker(TestCaseNameAsDescription):
    """Class contains unit tests of get_ITFaker_customer() keyword."""

    def test_it_faker_get_customer(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = get_itfaker_customer(LAB_CONF["MOCK"], "test1").text
        self.assertEqual(response, SAMPLE_RESPONSE)

    def test_it_faker_get_customer_r(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(get_itfaker_customer(LAB_CONF["MOCK"], "refused").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_it_faker_get_customer_f(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(get_itfaker_customer(LAB_CONF["MOCK"], "failed").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

    def test_it_faker_activate(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = activate_customer(LAB_CONF["MOCK"], "test2").text
        self.assertEqual(response, ACTIVATE_SUCCESS)

    def test_it_faker_activate_refused(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(activate_customer(LAB_CONF["MOCK"], "refused").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_it_faker_activate_failed(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(activate_customer(LAB_CONF["MOCK"], "failed").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

    def test_it_faker_suspend(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = suspend_customer(LAB_CONF["MOCK"], "test3").text
        self.assertEqual(response, SUSPEND_SUCCESS)

    def test_it_faker_suspend_refused(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(suspend_customer(LAB_CONF["MOCK"], "refused").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_it_faker_suspend_failed(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(suspend_customer(LAB_CONF["MOCK"], "failed").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

    def test_it_faker_refresh(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = refresh_customer(LAB_CONF["MOCK"], "test4").text
        self.assertEqual(response, REFRESH_SUCCESS)

    def test_it_faker_refresh_refused(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(refresh_customer(LAB_CONF["MOCK"], "refused").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_it_faker_refresh_failed(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(refresh_customer(LAB_CONF["MOCK"], "failed").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

    def test_it_faker_get_cpe(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = get_cpe(LAB_CONF["MOCK"], "test5").text
        self.assertEqual(response, GET_CPE_SUCCESS)

    def test_it_faker_get_cpe_refused(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(get_cpe(LAB_CONF["MOCK"], "refused").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_it_faker_get_cpe_failed(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(get_cpe(LAB_CONF["MOCK"], "failed").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

    def test_it_faker_check_consistency(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = check_consistency(LAB_CONF["MOCK"], "test6").text
        self.assertEqual(response, CHECK_CONSISTENCY_SUCCESS)

    def test_it_faker_check_consistency_refused(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(check_consistency(LAB_CONF["MOCK"], "refused").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_it_faker_check_consistency_failed(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(check_consistency(LAB_CONF["MOCK"], "failed").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

    def test_it_faker_pin_reset(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = pin_reset(LAB_CONF["MOCK"], "test7").text
        self.assertEqual(response, PIN_RESET_SUCCESS)

    def test_it_faker_pin_reset_refused(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(pin_reset(LAB_CONF["MOCK"], "refused").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_it_faker_pin_reset_failed(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(pin_reset(LAB_CONF["MOCK"], "failed").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

    def test_it_faker_move_customer(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = move_customer(LAB_CONF["MOCK"], "test8", "Schiphol1").text
        self.assertEqual(response, MOVE_SUCCESS)

    def test_it_faker_move_customer_refused(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(move_customer(LAB_CONF["MOCK"], "refused", "Schiphol1").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_it_faker_move_customer_failed(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(move_customer(LAB_CONF["MOCK"], "failed", "Schiphol1").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

    def test_it_faker_get_products(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = get_products(LAB_CONF["MOCK"], "test9").text
        self.assertEqual(response, GET_PRODUCTS_SUCCESS)

    def test_it_faker_get_products_refused(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(get_products(LAB_CONF["MOCK"], "refused").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_it_faker_get_products_failed(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(get_products(LAB_CONF["MOCK"], "failed").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

    def test_it_faker_activate_cpe(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = activate_cpe(LAB_CONF["MOCK"], "testTen", "testTen   ").text
        print(response)
        self.assertEqual(response, ACTIVATE_CPE_SUCCESS)

    def test_it_faker_activate_cpe_refused(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(activate_cpe(LAB_CONF["MOCK"], "refused", "refused   ").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_it_faker_activate_cpe_failed(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(activate_cpe(LAB_CONF["MOCK"], "failed", "failed   ").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

    def test_it_faker_deactivate_cpe(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = deactivate_cpe(LAB_CONF["MOCK"], "testEleven", "testEleven   ").text
        self.assertEqual(response, DEACTIVATE_CPE_SUCCESS)

    def test_it_faker_deactivate_cpe_refused(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(deactivate_cpe(LAB_CONF["MOCK"], "refused", "refused   ").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_it_faker_deactivate_cpe_failed(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(deactivate_cpe(LAB_CONF["MOCK"], "failed", "failed   ").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

    def test_it_faker_delete_budget(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = delete_budget(LAB_CONF["MOCK"], "testTwelve").text
        self.assertEqual(response, DELETE_BUDGET_SUCCESS)

    def test_it_faker_delete_budget_refused(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(delete_budget(LAB_CONF["MOCK"], "refused").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_it_faker_delete_budget_failed(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(delete_budget(LAB_CONF["MOCK"], "failed").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

    def test_it_faker_update_budget(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = update_budget(LAB_CONF["MOCK"], "testThirteen").text
        self.assertEqual(response, UPDATE_BUDGET_SUCCESS)

    def test_it_faker_update_budget_refused(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(update_budget(LAB_CONF["MOCK"], "refused").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_it_faker_update_budget_failed(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(update_budget(LAB_CONF["MOCK"], "failed").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

    def test_it_faker_add_product(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = add_product(LAB_CONF["MOCK"], "testFourteen").text
        self.assertEqual(response, ADD_PRODUCT_SUCCESS)

    def test_it_faker_add_product_refused(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(add_product(LAB_CONF["MOCK"], "refused").error)
        expected = '[WinError 10061] No connection could be' \
                   ' made because the target machine actively refused it'
        self.assertEqual(response, expected)

    def test_it_faker_add_product_failed(self,):
        """Test to validate passing response for a successful IT Faker request"""
        response = str(add_product(LAB_CONF["MOCK"], "failed").error)
        expected = '[Errno 11001] getaddrinfo failed'
        self.assertEqual(response, expected)

def suite_itfaker_requests():
    """A function builds a test suite for ITFaker_Requests() class methods."""
    return unittest.makeSuite(TestKeyword_ITFaker, "test")


def run_tests():
    """A function to run unit tests (real OBOQBR will not be used)."""

    suite = suite_itfaker_requests()
    unittest.TextTestRunner(verbosity=2).run(suite)


if __name__ == "__main__":
    run_tests()
