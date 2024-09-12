import datetime
import json
import requests
import socket
import argparse
from import_file import import_file
import os
import sys

TEMPLATE = """{
    "template" : "*%(template)s*",
    "settings" : {
        "number_of_shards" : 2
    },
    "mappings" : {
        "%(type)s" : {
            "properties": {
                "uuid": {
                    "type": "keyword",
                    "index": "true"
                },
                "channel": {
                    "type": "keyword",
                    "index": "true"
                },
                "country": {
                    "type": "keyword",
                    "index": "true"
                },
                "poster": {
                    "properties": {
                        "status": {
                            "type": "keyword",
                            "index": "true"
                        },
                        "value": {
                            "type": "keyword",
                            "index": "true"
                        }
                    }
                },
                "wall": {
                    "properties": {
                        "status": {
                            "type": "keyword",
                            "index": "true"
                        },
                        "value": {
                            "type": "keyword",
                            "index": "true"
                        }
                    }
                },
                "title": {
                    "properties": {
                        "status": {
                            "type": "keyword",
                            "index": "true"
                        },
                        "value": {
                            "type": "keyword",
                            "index": "true"
                        }
                    }
                },
                "id": {
                    "properties": {
                        "status": {
                            "type": "keyword",
                            "index": "true"
                        },
                        "value": {
                            "type": "keyword",
                            "index": "true"
                        }
                    }
                },
                "start": {
                    "properties": {
                        "status": {
                            "type": "keyword",
                            "index": "true"
                        },
                        "value": {
                            "type": "date"
                        }
                    }
                },
                "end": {
                    "properties": {
                        "status": {
                            "type": "keyword",
                            "index": "true"
                        },
                        "value": {
                            "type": "date"
                        }
                    }
                },
                "timing": {
                    "properties": {
                        "startTime": {
                            "type": "date"
                        },
                        "endTime": {
                            "type": "date"
                        }
                    }
                }
            }
        }
    }
}"""


RESULT = """{
    "uuid": "%(uuid)s",
    "channel": "%(channel)s",
    "country": "%(country)s",
    "timing": {
        "startTime": "%(start)s",
        "endTime": "%(end)s"
    },
    "poster": {
        "status": "%(poster_status)s",
        "value": "%(poster_value)s"
    },
    "wall": {
        "status": "%(wall_status)s",
        "value": "%(wall_value)s"
    },
    "id": {
        "status": "%(id_status)s",
        "value": "%(id_value)s"
    },
    "title": {
        "status": "%(title_status)s",
        "value": "%(title_value)s"
    },
    "start": {
        "status": "%(start_status)s",
        "value": "%(start_value)s"
    },
    "end": {
        "status": "%(end_status)s",
        "value": "%(end_value)s"
    }
}"""


class ElasticSearch(object):
    def __init__(self, host, port, template_name, type_name):
        self.host = host
        self.port = port
        self.template = template_name
        self.type = type_name
        self.session = requests.Session()

    def template_exists(self):
        url = 'http://%s:%s/_template/%s' % (self.host, self.port, self.template)
        try:
            response = self.session.get(url)
        except (requests.exceptions.RequestException, requests.exceptions.ConnectionError,
                requests.exceptions.Timeout, TimeoutError, socket.error) as error:
            print("ERROR when trying sent GET to %s\n\nError:\n%s" % (url, error))
            return False
        return response.status_code == 200

    def create_template(self):
        url = 'http://%s:%s/_template/%s' % (self.host, self.port, self.template)
        headers = {"Content-type": "application/json"}
        data = TEMPLATE % {"template": self.template, "type": self.type}
        try:
            response = self.session.put(url, data=data, headers=headers)
        except (requests.exceptions.RequestException, requests.exceptions.ConnectionError,
                requests.exceptions.Timeout, TimeoutError, socket.error) as error:
            print("ERROR when trying sent PUT to %s with \n headers:\n%s\ndata:%s\n\nError:\n%s" % (url, headers, data, error))
            return False
        return response.status_code == 200

    def send_data(self, kwargs):
        today = datetime.date.today().strftime("%Y-%m-%d")
        url = "http://%s:%s/%s-%s/%s/%s" % (self.host, self.port, self.template, today,
                                            self.type, kwargs["uuid"])
        headers = {"Content-type": "application/json"}
        data = RESULT % kwargs
        try:
            response = self.session.post(url, data=data, headers=headers)
        except (requests.exceptions.RequestException, requests.exceptions.ConnectionError,
                requests.exceptions.Timeout, TimeoutError, socket.error) as error:
            print("ERROR when trying sent POST to %s with \n headers:\n%s\ndata:%s\n\nError:\n%s" % (url, headers, data, error))
            return False
        return response.status_code == 200

    def update_data(self, item_id, kwargs):
        today = datetime.date.today().strftime("%Y-%m-%d")
        url = "http://%s:%s/%s-%s/%s/%s/_update" % \
              (self.host, self.port, self.template, today, self.type, item_id)
        headers = {"Content-type": "application/json"}
        data = json.dumps({"doc": kwargs})
        try:
            response = self.session.post(url, data=data, headers=headers)
        except (requests.exceptions.RequestException, requests.exceptions.ConnectionError,
                requests.exceptions.Timeout, TimeoutError, socket.error) as error:
            print("ERROR when trying sent POST to %s with \n headers:\n%s\ndata:%s\n\nError:\n%s" % (url, headers, data, error))
            return False
        return response.status_code == 200


if __name__ == "__main__":
    HLP = """Collect Images URLs from EPG micro-service and fetch all the URLs.
    Examples:
1. python elastic.py -p=9200 -i=e2erobot_epg -t=event
1. python elastic.py --host=172.30.94.221 --port=9200 --index=e2erobot_epg -type=event
2. python elastic.py
"""

    parser = argparse.ArgumentParser(description=HLP, formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument("--conf", default="conf_debug.py", type=str,
                        help="Common configuration file, default is conf_debug.py",
                        required=False)
    args = vars(parser.parse_args())

    current_dir = os.path.dirname(os.path.realpath(__file__))
    sys.path.append("%s/../../robot/resources/stages/" % (current_dir)) # Add robot/resources/stages/ to PATH to resolve import issues
    conf_file = import_file('../../robot/resources/stages/%s' % args["conf"])
    es_obj = ElasticSearch(conf_file.ELK_HOST, conf_file.ELK_PORT, conf_file.ELK_EPG_INDEX, conf_file.ELK_EPG_TYPE_NAME)
    if not es_obj.template_exists():
        es_obj.create_template()
    kwargs = {"uuid": "12345", "channel": "mtv", "country": "DE",
              "start": "2018-03-01T00:12:00.000Z", "end": "2018-03-01T00:12:30.000Z",
              "poster_status": "OK", "poster_value": "http://oboposter.labe2esi.nl.dmdsdp.com/ImagesEPG/EventImages/a810527dbb346d34c583ea2ac4d31a1bd1ce179e.jpg",
              "wall_status": "OK", "wall_value": "http://oboposter.labe2esi.nl.dmdsdp.com/ImagesEPG/EventImages/370b57a3648c28dbbcde3654437796ce2fabfd4c.jpg",
              "id_status": "OK", "id_value": "crid:~~2F~~2Fbds.tv~~2F25188755,imi:00100000002602D0",
              "title_status": "OK", "title_value": "Robocop",
              "start_status": "OK", "start_value": "1520406000",
              "end_status": "OK", "end_value": "1520406050"}
    es_obj.send_data(kwargs)
