#!/usr/bin/env python
from obelix.confObelix import obelix_racks

CPE_ID = "3C36E4-EOSSTB-003501794600"  # TODO: get rid of this CPE_ID, use E2E_CONF[lab]['CPE_ID']
INITIAL_TESTCASE = "EOS/EOS_NAV.json::TS902501007 RESET CPE UI WITHOUT CHECKS - BACK-BACK-BACK"
LAB_NAME = "labe2esuperset"
E2E_CONF = {
    "labe2esi": {
        "CPE_ID": "3C36E4-EOSSTB-003469693406",
        "country": "be",
        "language": ["nl"],
        "languages": ["nl", "en", "fr"],
        "root_id": ["omw_hzn4_vod"],
        "city_id": ["schiphol1"],
        "scr_title_nodes": {"en":
                                {"screen_title": ["DISCOVER", "Ontdek", "Movies", "Series", "Kids", "Rent", "Providers",
                                                  "Passion"],
                                 "series_node_name": ["Nieuw", "Populair", "Genre", "Studios", "Alle"],
                                 },
                            "nl":
                                {"screen_title": ["DISCOVER", "Ontdek", "Movies", "Series", "Kids", "Rent", "Providers",
                                                  "Passion"],
                                 "series_node_name": ["Nieuw", "Populair", "Genre", "Studios", "Alle"],
                                 }},
        "ACS": {"host": "172.30.98.143", "user": "admin", "password": "ax"},
        "ITFAKER": {"host": "172.30.182.30", "port": 8000, "env": "labe2esi"},
        "FABRIX": {"host": "172.30.107.84", "port": 5929},
        "STREAMER": {"host": "172.30.106.85", "port": 5554},
        # Currently only port 8092 is active for VRM, other ports mentioned in LLD file are not working
        "VRM": {"BS": {"host": "172.30.94.34", "ports": [8092]},#[8080, 8081, 8085, 8087, 8088, 8092]'''},
                "DS": {"host": "172.30.94.36", "ports": [8083]},#[8083, 8081, 8082, 8083, 8084]},
                "BS1": {"host": "172.23.69.86", "ports": [8092]},
                "BS2": {"host": "172.23.69.87", "ports": [8092]},
                },
        "MOUNTS": {"watch": {"host": "192.168.1.193", "folder": "/obo_watch", "type": "nfs"},
                   "manage": {"host": "192.168.1.194", "folder": "/obo_manage", "type": "nfs"}},
        "IRDETO": {"host": "lgiobo.stage.ott.irdeto.com", "port": 80},
        "OESP": {"username": "test0", "password": "password",
                 "country": "NL", "language": "nld", "device": "web"},
        "AIRFLOW_WORKERS": [{"host": "172.23.69.117", "port": 22,
                            "user": "airflowlogin", "password": "air@flow123",
                            "logs_folder": "/usr/local/airflow/logs",
                            "watch_folder": "/mnt/nfs_watch/Countries/E2ESI/ToAirflow",
                            "managed_folder": "/mnt/nfs_managed/Countries/E2ESI/FromAirflow"},
                           {"host": "172.23.69.118", "port": 22,
                            "user": "airflowlogin", "password": "air@flow123",
                            "logs_folder": "/usr/local/airflow/logs",
                            "watch_folder": "/mnt/nfs_watch/Countries/E2ESI/ToAirflow",
                            "managed_folder": "/mnt/nfs_managed/Countries/E2ESI/FromAirflow"},
                           ],
        "AIRFLOW_WEB": {"host": "webserver1.airflow-end2end.horizongo.eu", "port": 22,
                        "user": "ec2-user",
                        "key_path": "../../resources/stages/horizongodevepam.pem"},
        "AIRFLOW_WEB_CREDENTIALS": {"username": "airflow", "password": "airflow"},
        "ASSET_GENERATOR": {"host": "172.30.218.244", "port": 22,
                            "user": "og", "password": "cutv", "path": "/var/tmp/adi-auto-deploy"},
        "OG": [{"host": "172.30.108.16", "port": 22, "user": "og", "password": "cutv",
                "watch_folder": "/opt/og/Countries/E2ESI/ToAirflow",
                "logs_folder": "/opt/og/Countries/E2ESI/log"},
               {"host": "172.30.108.17", "port": 22, "user": "og", "password": "cutv",
                "watch_folder": "/opt/og/Countries/E2ESI/ToAirflow",
                "logs_folder": "/opt/og/Countries/E2ESI/log"},
              ],
        "ORIGINS": [{"host": "172.30.107.71", "port": 22, "user": "root", "password": "F@brix",
                     "managed_folder": "/obo_manage/Countries/E2ESI/FromAirflow"},
                    {"host": "172.30.107.72", "port": 22, "user": "root", "password": "F@brix",
                     "managed_folder": "/obo_manage/Countries/E2ESI/FromAirflow"}
                   ],
        "TRANSCODERS": [{"host": "172.30.108.10", "port": 22,
                         "user": "oboadm", "password": "oboadm1n",
                         "managed_folder": "/mnt/obo_manage/Countries/E2ESI/FromAirflow",
                         "sudo_prefix": "echo -e oboadm1n | sudo -S su - ericsson -c "},
                        {"host": "172.30.108.77", "port": 22,
                         "user": "oboadm", "password": "oboadm1n",
                         "managed_folder": "/mnt/obo_manage/Countries/E2ESI/FromAirflow",
                         "sudo_prefix": "echo -e oboadm1n | sudo -S su - ericsson -c "}
                       ],
        "SEACHANGE": {"TRAXIS_WEB": {"host": "obotraxis.labe2esi.nl.internal", "port": 80, "path": "traxis/web"}},
        "MICROSERVICES" : {
            "OBOQBR": "oboqbr.labe2esi.nl.internal",
            "EPG-SERVICE": "oboqbr.labe2esi.nl.internal/epg-service",
        },
        "CDN": {"epg": "oboqbr.labe2esi.nl.internal/epg-service", "poster": "oboposter.labe2esi.nl.dmdsdp.com",
                "omw": "omw.labe2esi.nl.dmdsdp.com", "omwssu": "omwssu.labe2esi.nl.dmdsdp.com",
                "speedtest": "speedtest.labe2esi.nl.dmdsdp.com",
                "vod": "labe2esi_cdn_vod.txt", "replay": "labe2esi_cdn_replay.txt",
                "dvrrb": "labe2esi_cdn_dvrrb.txt", "dvr": "labe2esi_cdn_dvr.txt",
                "review": "labe2esi_cdn_review.txt",
                "cache_vod": "wp1.pod1.vod.labe2esi.nl.dmdsdp.com",
                "cache_webproxy": "omw.labe2esi.nl.dmdsdp.com",
                "asset_vod": "/sdash/cd480b441d4b36a324f3b711c69b7bd5_9ac7345599d715d17f964fd566687642/index.mpd/Manifest?device=HEVC-STB",
                "asset_webproxy": "/configs/labe2esi/be/test4/DCX960__-mon-dbg-00.01-000-aa-AL-20170926210000-un000/config.json",
                "ASSETIZED_REC_CRID": {"3C36E4-EOSSTB-003501794600":
                                       "crid:~~2F~~2Fbds.tv~~2F291912972,imi:3836a143992d04e81e2b31000892b4f57a97b709"}
        },
        "XAP": {"host": "xap-obo.tools.appdev.io", "port": 80},
        "XAGGET": {"host": "172.30.108.11", "port": 1337, "repo": "cto_sr45", "duration": "",
            "elastic":"172.30.94.221","elastic_port": "9200","cpe": "3C36E4-EOSSTB-003356454409"
        },
        "RENG": {"Node1": {"host": "172.23.69.89", "port": [8080]},
                 "Node2": {"host": "172.23.69.92", "port": [8080]},
                 "Node3": {"host": "172.23.69.94", "port": [8080]}
                 },
        "OBELIX": obelix_racks,
    },
    # Superset ECX for Airflow
    "labobocsi": {
        # Airflow start:
        # VoD_VSPP_Controller
        "FABRIX": [
            # For Jenkins running:
            # {"host": "172.23.91.2", "port": 5929},
            # {"host": "172.23.91.3", "port": 5929},
            # {"host": "172.23.91.4", "port": 5929},
            # For local running
            {"host": "172.23.87.13", "port": 5929},
            {"host": "172.23.87.14", "port": 5929},
            {"host": "172.23.87.15", "port": 5929}
        ],
        # VOD_BO_shared_mount_-_watch  &&  VOD_BO_shared_mount_-_manage
        "MOUNTS": {"watch": {"host": "192.168.81.101", "folder": "/obo_watch", "type": "nfs"},
                   "manage": {"host": "192.168.81.102", "folder": "/obo_manage", "type": "nfs"}},
        "IRDETO": {"host": "lgiobo.stage.ott.irdeto.com", "port": 80},
        "AIRFLOW_WORKERS_JUMP_SERVER": {"host": "172.16.128.19", "port": 22,
                                         "user": "oboadm", "password": "oboadm1n"},
        "TRANSCODER_WORKERS_JUMP_SERVER": {"host": "172.16.128.17", "port": 22,
                                         "user": "oboadm", "password": "oboadm1n"},
        "AIRFLOW_WORKERS": [{"host": "172.23.66.137", "port": 22,
                             "user": "airflowlogin", "password": "air@flow123",
                             "logs_folder": "/usr/local/airflow/logs",
                             "watch_folder": "/mnt/nfs_watch/Countries/CSI/ToAirflow",
                             "watch_folder_priority": "/mnt/nfs_watch/Countries/CSI/ToAirflow_priority",
                             "managed_folder": "/mnt/nfs_managed/Countries/CSI/FromAirflow"},
                            {"host": "172.23.66.138", "port": 22,
                             "user": "airflowlogin", "password": "air@flow123",
                             "logs_folder": "/usr/local/airflow/logs",
                             "watch_folder": "/mnt/nfs_watch/Countries/CSI/ToAirflow",
                             "watch_folder_priority": "/mnt/nfs_watch/Countries/CSI/ToAirflow_priority",
                             "managed_folder": "/mnt/nfs_managed/Countries/CSI/FromAirflow"},
                            {"host": "172.23.66.139", "port": 22,
                             "user": "airflowlogin", "password": "air@flow123",
                             "logs_folder": "/usr/local/airflow/logs",
                             "watch_folder": "/mnt/nfs_watch/Countries/CSI/ToAirflow",
                             "watch_folder_priority": "/mnt/nfs_watch/Countries/CSI/ToAirflow_priority",
                             "managed_folder": "/mnt/nfs_managed/Countries/CSI/FromAirflow"},
                            {"host": "172.23.66.140", "port": 22,
                             "user": "airflowlogin", "password": "air@flow123",
                             "logs_folder": "/usr/local/airflow/logs",
                             "watch_folder": "/mnt/nfs_watch/Countries/CSI/ToAirflow",
                             "watch_folder_priority": "/mnt/nfs_watch/Countries/CSI/ToAirflow_priority",
                             "managed_folder": "/mnt/nfs_managed/Countries/CSI/FromAirflow"},
                           ],
        "TRANSCODER_WORKERS": [
            {
                "host": "172.23.66.141", "port": 22,
                "user": "oboadm", "password": "oboadm1n",
                "logs_folder": "/usr/local/airflow/logs"
            }
        ],
        "AIRFLOW_WEB": {"host": "webserver.airflow.ecx.appdev.io", "port": 22,
                        "user": "ec2-user",
                        "key_path": "../../resources/stages/horizongodevepam.pem"},
        "AIRFLOW_API": {"host": "api.airflow.ecx.appdev.io"},
        "AIRFLOW_WEB_CREDENTIALS": {"username": "airflow", "password": "End2***af"},
        "AIRFLOW_API": {
            "host": "api.airflow.ecx.appdev.io"
        },
        # Offerings_Generator
        "OG": [{"host": "172.23.87.168", "port": 22, "user": "og", "password": "cutv",
                "watch_folder": "/opt/og/Countries/CSI/ToAirflow",
                "logs_folder": "/opt/og/Countries/CSI/log",
                "export_adi": "/opt/og/Countries/CSI/export/adi"},
               {"host": "172.23.87.169", "port": 22, "user": "og", "password": "cutv",
                "watch_folder": "/opt/og/Countries/CSI/ToAirflow",
                "logs_folder": "/opt/og/Countries/CSI/log",
                "export_adi": "/opt/og/Countries/CSI/export/adi"},
              ],
        # VoD_Content_Provider
        "ASSET_GENERATOR": {"host": "172.30.218.244", "port": 22,
                            "user": "nvanmarle", "password": "L00p1nB@ck", "path": "/var/tmp/adi-auto-deploy"},
        # CDN_DAs_SIS  # for CDN urls
        "CDN": {"cache_url_part1": "http://wp1-pod1-vod-nl-labe2esuperset.lab.cdn.dmdsdp.com/sdash/",
                "cache_url_part2": "/index.mpd/Manifest?device=DASH",
                "cache_url_selene": "/index.mpd/Manifest?device=STB-AVC-DASH"},
        # VoD_Origin_node
        "ORIGINS": [{"host": "172.23.87.16", "port": 22, "user": "root", "password": "F@brix",
                     "managed_folder": "/obo_manage/Countries/CSI/FromAirflow"},
                    {"host": "172.23.87.17", "port": 22, "user": "root", "password": "F@brix",
                     "managed_folder": "/obo_manage/Countries/CSI/FromAirflow"},
                    {"host": "172.23.87.18", "port": 22, "user": "root", "password": "F@brix",
                     "managed_folder": "/obo_manage/Countries/CSI/FromAirflow"}
                   ],
        # VoD_Transcoders
        "TRANSCODERS": [{"host": "172.23.87.225", "port": 22,
                         "user": "oboadm", "password": "oboadm1n",
                         "managed_folder": "/mnt/obo_manage/Countries/CSI/FromAirflow",
                         "sudo_prefix": "echo -e oboadm1n | sudo -S su - ericsson -c "},
                        {"host": "172.23.87.226", "port": 22,
                         "user": "oboadm", "password": "oboadm1n",
                         "managed_folder": "/mnt/obo_manage/Countries/CSI/FromAirflow",
                         "sudo_prefix": "echo -e oboadm1n | sudo -S su - ericsson -c "}
                        ],
        "IMAGES_WATCH_FOLDER": {
            "host": "62.179.90.100",
            "port": 22,
            "user": "Obo19-temp",
            "password": "0b0labs18!",
            "path": "/BDS/NLD/Images"
        },
        # Airflow end
        "MICROSERVICES": {
            "OBOQBR": "oboqbr.labe2esuperset.nl.internal",
            "STATICQBR": "staticqbr-nl-labe2esuperset.lab.cdn.dmdsdp.com"  # it should use the HTTP Proxy(MT Internet Proxy and need to be whitelisted)
        }
    },
    "labe2esuperset": {
        "CPE_ID": "3C36E4-EOSSTB-003469707008",
        "country": "nl",
        "language": ["nl"],
        "languages": ["nl", "en"],
        "root_id": ["omw_hzn4_vod"],
        "city_id": ["schiphol1"],
        "scr_title_nodes": {"en":
                                {"screen_title": ["DISCOVER", "Ontdek", "Movies", "Series", "Kids", "Rent", "Providers",
                                                  "Passion"],
                                 "series_node_name": ["Nieuw", "Populair", "Genre", "Studios", "Alle"],
                                 },
                            "nl":
                                {"screen_title": ["DISCOVER", "Ontdek", "Movies", "Series", "Kids", "Rent", "Providers",
                                                  "Passion"],
                                 "series_node_name": ["Nieuw", "Populair", "Genre", "Studios", "Alle"],
                                 }},
        "ACS": {"host": "172.30.94.116", "user": "admin", "password": "ax"},
        "ITFAKER": {"host": "172.30.97.16", "port": 8000, "env": "labobocsi"},
        "VRM": {"BS": {"host": "172.30.94.132", "ports": [8092]},  # [8080, 8081, 8085, 8087, 8088, 8092]'''},
                "DS": {"host": "172.30.108.58", "ports": [8083]},  # [8083, 8081, 8082, 8083, 8084]},
                "BS1": {"host": "172.30.108.53", "ports": [8092]},
                "BS2": {"host": "172.30.108.54", "ports": [8092]},
                },
        "SEACHANGE": {"TRAXIS_WEB": {"host": "172.30.94.123", "port": 80, "path": "traxis/web"}},
        "MICROSERVICES" : {
            "OBOQBR": "oboqbr.labe2esuperset.nl.internal",
            "EPG-SERVICE": "oboqbr.labe2esuperset.nl.internal/epg-service",
        },
        "XAP": {"host": "172.30.94.140", "port": 80},
        "XAGGET": {"host": "172.30.108.11", "port": 1337, "repo": "cto_sr51ag", "duration": "",
                   "elastic": "172.30.94.221", "elastic_port": "9200", "cpe": "3C36E4-EOSSTB-003470339106"
        },
        "RENG": {"Node1": {"host": "172.30.108.59", "port": [8080]},
                 "Node2": {"host": "172.30.108.60", "port": [8080]},
                 "Node3": {"host": "172.30.108.61", "port": [8080]},
        },
    },
    "lab2": {
        "FABRIX": {"host": "172.30.100.113", "port": 5929},
        "STREAMER": {"host": "172.30.100.177", "port": 5554},
    },
    "lab3b": {
        "OESP": {"username": "wipronl01", "password": "wipro1234",
                 "country": "NL", "language": "nld", "device": "web"},
    },
    "lab5a": {
        "ACS": {"host": "172.30.183.25","user": "admin", "password": "ax"},
        "OESP": {"username": "test0", "password": "password",
                 "country": "NL", "language": "nld", "device": "web"},
        "XAP": {"host": "xap.tools.appdev.io", "port": 80},
        "XAGGET": {"host": "10.64.13.180", "port": 80, "repo": "cto_sr36", "duration": "",
            "elastic":"10.64.13.179","elastic_port": "9200","cpe": "3C36E4-EOSSTB-003356472104"
        },
    }
}

# ****** ELASTICSEARCH CONFIG  ******
ELK_HOST = "elastic.labe2esuperset.nl.internal"
ELK_PORT = "80"
ELK_EPG_INDEX = "e2erobot_epg"
ELK_EPG_TYPE_NAME = "event"
#--- ELK INDEX ---
ELK_INDEX_ROBOT = "e2erobot"
ELK_TYPE_TEST = "_doc"

# ******  KIBANA CONFIG  ******
KIBANA_TEST_STEP_DASHBOARD = "14a5ba50-6573-11e8-b117-895ab33416ff"
KIBANA_TEST_STEP_NO_INFO_DASHBOARD = "ff64a690-659c-11e8-959a-f3bd30534c55"
KIBANA_DASHBOARD_TIME = 86400000 # 86400000 (ms) = 1 day