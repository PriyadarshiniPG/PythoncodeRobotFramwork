#!/usr/bin/env python
# -----------------------------------------------------------------------------
# ---------------------------- PREPROD CONFIF FILE ----------------------------
# ------------- It will be need it soon with: preprod_{TENANT} sections -------
# -----------------------------------------------------------------------------

#from obelix.confObelix import obelix_racks

INITIAL_TESTCASE = "STEP_HES/NAV/HES_NAV.json::HES_RESET CPE UI WITHOUT CHECKS - BACK-BACK-BACK"
LAB_NAME = "preprod_nl"
E2E_CONF = {
    "preprod_nl": {
        "CPE_FW_VERSION": "060-ap",
        "CPE_ID": "3C36E4-EOSSTB-003356424204",
        "country": "nl",
        "default_language": "en",
        "root_id": ["omw_playmore_en"],
        "fallback_root_id": ["omw_hzn4_vod"],
        "ITFAKER": {"host": "itfaker.preprod.nl.internal", "port": 80, "env": "vodziggopreprod"},
        "VRM": {"BS": {"host": "vrm_bs_8092.preprod.nl.internal", "ports": [80]},
                "DS": {"host": "vrm_ds_8083.preprod.nl.internal", "ports": [80]},
                "BS1": {"host": "vrm_bs_8092.preprod.nl.internal", "ports": [80]},
                "BS2": {"host": "vrm_bs_8092.preprod.nl.internal", "ports": [80]}
        },
        "SEACHANGE": {"TRAXIS_WEB": {"host": "obotraxis.preprod.nl.internal", "port": 80, "path": "traxis/web"}},
        "MICROSERVICES" : {
            "OBOQBR": "oboqbr.preprod.nl.internal"
        },
        "XAP": {"host": "oboqbr.preprod.nl.internal/xap", "port": 80},
        "XAGGET": {"host": "172.16.100.90", "port": 1337, "repo": "eos_srxx", "duration": "",
                   "elastic": "172.23.124.1", "elastic_port": "9200", "cpe": "3C36E4-EOSSTB-003356424204",
                   "test_result": "172.16.100.98"
        }
    },
    "preprod_ch": {
        "CPE_FW_VERSION": "060-ap",
        "CPE_ID": "3C36E4-EOSSTB-003468638402",
        "country": "ch",
        "default_language": "en",
        "root_id": ["omw_basic_en"],
        "fallback_root_id": ["omw_hzn4_vod"],
        "ITFAKER": {"host": "itfaker.preprod.ch.internal", "port": 80, "env": "upcchpreprod"},
        "VRM": {"BS": {"host": "vrm_bs_8092.preprod.ch.internal", "ports": [80]},
                "DS": {"host": "vrm_ds_8083.preprod.ch.internal", "ports": [80]},
                "BS1": {"host": "vrm_bs_8092.preprod.ch.internal", "ports": [80]},
                "BS2": {"host": "vrm_bs_8092.preprod.ch.internal", "ports": [80]}
        },
        "SEACHANGE": {"TRAXIS_WEB": {"host": "obotraxis.preprod.ch.internal", "port": 80, "path": "traxis/web"}},
        "MICROSERVICES" : {
            "OBOQBR": "oboqbr.preprod.ch.internal"
        },
        "XAP": {"host": "oboqbr.preprod.ch.internal/xap", "port": 80},
        "XAGGET": {"host": "172.16.100.90", "port": 1337, "repo": "eos_srxx", "duration": "",
                   "elastic": "172.23.124.1", "elastic_port": "9200", "cpe": "3C36E4-EOSSTB-003468638402",
                   "test_result": "172.16.100.98"
        }
    },
    "preprod_cl": {
        "CPE_FW_VERSION": "060-ap",
        "CPE_ID": "000378-EOSSTB-103357375900",
        "country": "cl",
        "default_language": "en",
        "root_id": ["omw_hzn4_vod"],
        "fallback_root_id": ["omw_hzn4_vod"],
        "ITFAKER": {"host": "itfaker.preprod.cl.internal", "port": 80, "env": "vtrclpreprod"},
        "VRM": {"BS": {"host": "vrm_bs_8092.preprod.cl.internal", "ports": [80]},
                "DS": {"host": "vrm_ds_8083.preprod.cl.internal", "ports": [80]},
                "BS1": {"host": "vrm_bs_8092.preprod.cl.internal", "ports": [80]},
                "BS2": {"host": "vrm_bs_8092.preprod.cl.internal", "ports": [80]}
        },
        "SEACHANGE": {"TRAXIS_WEB": {"host": "obotraxis.preprod.cl.internal", "port": 80, "path": "traxis/web"}},
        "MICROSERVICES" : {
            "OBOQBR": "oboqbr.preprod.cl.internal"
        },
        "XAP": {"host": "oboqbr.preprod.cl.internal/xap", "port": 80},
        "XAGGET": {"host": "172.16.100.90", "port": 1337, "repo": "eos_srxx", "duration": "",
                   "elastic": "172.23.124.1", "elastic_port": "9200", "cpe": "3C36E4-EOSSTB-003356424204",
                   "test_result": "172.16.100.98"
        }
    },
    "preprod_uk": {
        "CPE_FW_VERSION": "060-ap",
        "CPE_ID": "3C36E4-EOSSTB-003356177000",
        "country": "gb",
        "default_language": "en",
        "root_id": ["omw_hzn4_vod"],
        "fallback_root_id": ["omw_hzn4_vod"],
        "ITFAKER": {"host": "itfaker.preprod.gb.internal", "port": 80, "env": "ukpreprod"},
        "VRM": {"BS": {"host": "vrm_bs_8092.preprod.gb.internal", "ports": [80]},
                "DS": {"host": "vrm_ds_8083.preprod.gb.internal", "ports": [80]},
                "BS1": {"host": "vrm_bs_8092.preprod.gb.internal", "ports": [80]},
                "BS2": {"host": "vrm_bs_8092.preprod.gb.internal", "ports": [80]}
        },
        "SEACHANGE": {"TRAXIS_WEB": {"host": "obotraxis.preprod.gb.internal", "port": 80, "path": "traxis/web"}},
        "MICROSERVICES" : {
            "OBOQBR": "oboqbr.preprod.gb.internal"
        },
        "XAP": {"host": "oboqbr.preprod.gb.internal/xap", "port": 80},
        "XAGGET": {"host": "172.16.100.90", "port": 1337, "repo": "eos_srxx", "duration": "",
                   "elastic": "172.23.124.1", "elastic_port": "9200", "cpe": "3C36E4-EOSSTB-003356177000",
                   "test_result": "172.16.100.98"
        }
    },
    "preprod_at": {
        "CPE_FW_VERSION": "070-xj",
        "CPE_ID": "000378-EOSSTB-003771000704",
        "country": "at",
        "default_language": "de",
        # RE-CHECK AT root_id
        "root_id": ["omw_hzn4_vod"],
        "fallback_root_id": ["omw_hzn4_vod"],
        "ITFAKER": {"host": "itfaker.preprod.at.internal", "port": 80, "env": "magentaatpreprod"},
        "VRM": {"BS": {"host": "vrm_bs_8092.preprod.at.internal", "ports": [80]},
                "DS": {"host": "vrm_ds_8083.preprod.at.internal", "ports": [80]},
                "BS1": {"host": "vrm_bs_8092.preprod.at.internal", "ports": [80]},
                "BS2": {"host": "vrm_bs_8092.preprod.at.internal", "ports": [80]}
                },
        "SEACHANGE": {"TRAXIS_WEB": {"host": "obotraxis.preprod.at.internal", "port": 80, "path": "traxis/web"}},
        "MICROSERVICES": {
            "OBOQBR": "oboqbr.preprod.at.internal"
        },
        "XAP": {"host": "oboqbr.preprod.at.internal/xap", "port": 80},
        "XAGGET": {"host": "172.16.100.90", "port": 1337, "repo": "eos_srxx", "duration": "",
                   "elastic": "172.23.124.1", "elastic_port": "9200", "cpe": "3C36E4-EOSSTB-003356177000",
                   "test_result": "172.16.100.98"
        }
    },
    "preprod_be": {
        "CPE_FW_VERSION": "073-at",
        "CPE_ID": "3C36E4-EOSSTB-003468638402",
        "country": "be",
        "default_language": "en",
        "root_id": ["omw_basic"],
        "fallback_root_id": ["omw_hzn4_vod"],
        "ITFAKER": {"host": "itfaker.preprod.be.internal", "port": 80, "env": "upcbepreprod"},
        "VRM": {"BS": {"host": "vrm_bs_8092.preprod.be.internal", "ports": [80]},
                "DS": {"host": "vrm_ds_8083.preprod.be.internal", "ports": [80]},
                "BS1": {"host": "vrm_bs_8092.preprod.be.internal", "ports": [80]},
                "BS2": {"host": "vrm_bs_8092.preprod.be.internal", "ports": [80]}
        },
        "SEACHANGE": {"TRAXIS_WEB": {"host": "obotraxis.preprod.be.internal", "port": 80, "path": "traxis/web"}},
        "MICROSERVICES" : {
            "OBOQBR": "oboqbr.preprod.be.internal"
        },
        "XAP": {"host": "oboqbr.preprod.be.internal/xap", "port": 80},
        "XAGGET": {"host": "172.16.100.90", "port": 1337, "repo": "eos_srxx", "duration": "",
                   "elastic": "172.23.124.1", "elastic_port": "9200", "cpe": "3C36E4-EOSSTB-003468638402",
                   "test_result": "172.16.100.98"
        }
    },
    "preprod_ie": {
        "CPE_FW_VERSION": "070-xj",
        "CPE_ID": "000378-EOSSTB-003780343301",
        "country": "ie",
        "default_language": "en",
        # RE-CHECK AT root_id
        "root_id": ["omw_hzn4_vod"],
        "fallback_root_id": ["omw_hzn4_vod"],
        "ITFAKER": {"host": "itfaker.preprod.ie.internal", "port": 80, "env": "virginiepreprod"},
        "VRM": {"BS": {"host": "vrm_bs_8092.preprod.ie.internal", "ports": [80]},
                "DS": {"host": "vrm_ds_8083.preprod.ie.internal", "ports": [80]},
                "BS1": {"host": "vrm_bs_8092.preprod.ie.internal", "ports": [80]},
                "BS2": {"host": "vrm_bs_8092.preprod.ie.internal", "ports": [80]}
                },
        "SEACHANGE": {"TRAXIS_WEB": {"host": "obotraxis.preprod.ie.internal", "port": 80, "path": "traxis/web"}},
        "MICROSERVICES": {
            "OBOQBR": "oboqbr.preprod.ie.internal"
        },
        "XAP": {"host": "oboqbr.preprod.ie.internal/xap", "port": 80},
        "XAGGET": {"host": "172.16.100.90", "port": 1337, "repo": "eos_srxx", "duration": "",
                   "elastic": "172.23.124.1", "elastic_port": "9200", "cpe": "000378-EOSSTB-003780343301",
                   "test_result": "172.16.100.98"
        }
    },
    "preprod_pl": {
        "CPE_FW_VERSION": "070-xj",
        # RE-CHECK PL CPE_ID - PENDING
        "CPE_ID": "000378-EOSSTB-XXXX",
        "country": "pl",
        "default_language": "en",
        # RE-CHECK PL root_id
        "root_id": ["omw_hzn4_vod"],
        "fallback_root_id": ["omw_hzn4_vod"],
        # RE-CHECK PL - itFaker env
        #"ITFAKER": {"host": "itfaker.preprod.pl.internal", "port": 80, "env": "virginiepreprod"},
        "VRM": {"BS": {"host": "vrm_bs_8092.preprod.pl.internal", "ports": [80]},
                "DS": {"host": "vrm_ds_8083.preprod.pl.internal", "ports": [80]},
                "BS1": {"host": "vrm_bs_8092.preprod.pl.internal", "ports": [80]},
                "BS2": {"host": "vrm_bs_8092.preprod.pl.internal", "ports": [80]}
                },
        "SEACHANGE": {"TRAXIS_WEB": {"host": "obotraxis.preprod.pl.internal", "port": 80, "path": "traxis/web"}},
        "MICROSERVICES": {
            "OBOQBR": "oboqbr.preprod.pl.internal"
        },
        "XAP": {"host": "oboqbr.preprod.pl.internal/xap", "port": 80}
    }
}

# ****** ELASTICSEARCH CONFIG  ******
ELK_HOST = "172.23.124.1" #OBO_ODH_INT_9200
ELK_PORT = "9200"
ELK_EPG_INDEX = "e2erobot_epg"
ELK_EPG_TYPE_NAME = "event"
#--- ELK INDEX ---
ELK_INDEX_ROBOT = "e2erobot"
ELK_TYPE_TEST = "_doc"
ELK_AUTH = "c3Bhcms6c3BhcmtAb2Ro"

# ******  KIBANA CONFIG  ******
KIBANA_TEST_STEP_DASHBOARD = "14a5ba50-6573-11e8-b117-895ab33416ff" #e2erobot_Teststep_Monitor
KIBANA_TEST_STEP_NO_INFO_DASHBOARD = "ff64a690-659c-11e8-959a-f3bd30534c55" #e2erobot_No_More_Info
KIBANA_DASHBOARD_TIME = 86400000 # 86400000 (ms) = 1 day
