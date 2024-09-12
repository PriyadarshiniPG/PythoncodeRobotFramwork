#!/usr/bin/env python
# -----------------------------------------------------------------------------
# ---------------------------- PROD CONFIF FILE -------------------------------
# ------------------------- prod_{TENANT} sections ----------------------------
# -----------------------------------------------------------------------------

#from obelix.confObelix import obelix_racks

INITIAL_TESTCASE = "STEP_HES/NAV/HES_NAV.json::HES_RESET CPE UI WITHOUT CHECKS - BACK-BACK-BACK"
LAB_NAME = "prod_nl"
E2E_CONF = {
    "prod_be": {
        "CPE_FW_VERSION": "060-ap",
        "CPE_ID": "3C36E4-EOSSTB-003696159601",
        "country": "be",
        "default_language": "en",
        "root_id": ["omw_playmore_en"],
        "fallback_root_id": ["omw_hzn4_vod"],
        "VRM": {"BS": {"host": "vrm_bs_8092.prod.be.internal", "ports": [80]},
                "DS": {"host": "vrm_ds_8083.prod.be.internal", "ports": [80]},
                # "BS1": {"host": "172.30.108.53", "ports": [8092]},
                # "BS2": {"host": "172.30.108.54", "ports": [8092]},
        },
        "SEACHANGE": {"TRAXIS_WEB": {"host": "obotraxis.prod.be.internal", "port": 80, "path": "traxis/web"}},
        "MICROSERVICES" : {
            "OBOQBR": "oboqbr.prod.be.internal",
            "EPG-SERVICE": "epg.prod.be.dmdsdp.com",
        },
        "XAP": {"host": "oboqbr.prod.be.internal/xap", "port": 80},
        "XAGGET": {"host": "172.16.100.90", "port": 1337, "repo": "eos_srxx", "duration": "",
                   "elastic": "172.23.124.1", "elastic_port": "9200", "cpe": "3C36E4-EOSSTB-003637806807",
                   "test_result": "172.16.100.98"
        }
    },
    "prod_nl": {
        "CPE_FW_VERSION": "060-ap",
        "CPE_ID": "3C36E4-EOSSTB-003469707008",
        "country": "nl",
        "default_language": "en",
        "root_id": ["omw_playmore_en"],
        "fallback_root_id": ["omw_hzn4_vod"],
        "VRM": {"BS": {"host": "vrm_bs_8092.prod.nl.internal", "ports": [80]},
                "DS": {"host": "vrm_ds_8083.prod.nl.internal", "ports": [80]},
                # "BS1": {"host": "172.30.108.53", "ports": [8092]},
                # "BS2": {"host": "172.30.108.54", "ports": [8092]},
        },
        "SEACHANGE": {"TRAXIS_WEB": {"host": "obotraxis.prod.nl.internal", "port": 80, "path": "traxis/web"}},
        "MICROSERVICES" : {
            "OBOQBR": "oboqbr.prod.nl.internal",
            "EPG-SERVICE": "epg.prod.nl.dmdsdp.com",
        },
        "XAP": {"host": "oboqbr.prod.nl.internal/xap", "port": 80},
        "XAGGET": {"host": "172.16.100.90", "port": 1337, "repo": "eos_srxx", "duration": "",
                   "elastic": "172.23.124.1", "elastic_port": "9200", "cpe": "3C36E4-EOSSTB-003637806807",
                   "test_result": "172.16.100.98"
        }
    },
    "prod_ch": {
        "CPE_FW_VERSION": "060-ap",
        "CPE_ID": "3C36E4-EOSSTB-003469707008",
        "country": "ch",
        "default_language": "en",
        "root_id": ["omw_basic_en"],
        "fallback_root_id": ["omw_hzn4_vod"],
        "VRM": {"BS": {"host": "vrm_bs_8092.prod.ch.internal", "ports": [80]},
                "DS": {"host": "vrm_ds_8083.prod.ch.internal", "ports": [80]},
                # "BS1": {"host": "172.30.108.53", "ports": [8092]},
                # "BS2": {"host": "172.30.108.54", "ports": [8092]},
                },
        "SEACHANGE": {"TRAXIS_WEB": {"host": "obotraxis.prod.ch.internal", "port": 80, "path": "traxis/web"}},
        "MICROSERVICES": {
            "OBOQBR": "oboqbr.prod.ch.internal",
            "EPG-SERVICE": "epg.prod.ch.dmdsdp.com",
        },
        "XAP": {"host": "oboqbr.prod.ch.internal/xap", "port": 80},
        "XAGGET": {"host": "172.16.100.90", "port": 1337, "repo": "eos_srxx", "duration": "",
                   "elastic": "172.23.124.1", "elastic_port": "9200", "cpe": "3C36E4-EOSSTB-003637806807",
                   "test_result": "172.16.100.98"
        }
    },
    "prod_cl": {
        "CPE_FW_VERSION": "060-ap",
        "CPE_ID": "3C36E4-EOSSTB-003469707008",
        "country": "cl",
        "default_language": "en",
        "root_id": ["omw_hzn4_vod"],
        "fallback_root_id": ["omw_hzn4_vod"],
        "VRM": {"BS": {"host": "vrm_bs_8092.prod.cl.internal", "ports": [80]},
                "DS": {"host": "vrm_ds_8083.prod.cl.internal", "ports": [80]},
                # "BS1": {"host": "172.30.108.53", "ports": [8092]},
                # "BS2": {"host": "172.30.108.54", "ports": [8092]},
                },
        "SEACHANGE": {"TRAXIS_WEB": {"host": "obotraxis.prod.cl.internal", "port": 80, "path": "traxis/web"}},
        "MICROSERVICES": {
            "OBOQBR": "oboqbr.prod.cl.internal",
            "EPG-SERVICE": "epg.prod.cl.dmdsdp.com",
        },
        "XAP": {"host": "oboqbr.prod.cl.internal/xap", "port": 80},
        "XAGGET": {"host": "172.16.100.90", "port": 1337, "repo": "eos_srxx", "duration": "",
                   "elastic": "172.23.124.1", "elastic_port": "9200", "cpe": "3C36E4-EOSSTB-003637806807",
                   "test_result": "172.16.100.98"
        }
    },
    "prod_uk": {
        "CPE_FW_VERSION": "060-ap",
        "CPE_ID": "3C36E4-EOSSTB-003469707008",
        "country": "gb",
        "default_language": "en",
        "root_id": ["omw_hzn4_vod"],
        "fallback_root_id": ["omw_hzn4_vod"],
        "VRM": {"BS": {"host": "vrm_bs_8092.prod.gb.internal", "ports": [80]},
                "DS": {"host": "vrm_ds_8083.prod.gb.internal", "ports": [80]},
                # "BS1": {"host": "172.30.108.53", "ports": [8092]},
                # "BS2": {"host": "172.30.108.54", "ports": [8092]},
                },
        "SEACHANGE": {"TRAXIS_WEB": {"host": "obotraxis.prod.gb.internal", "port": 80, "path": "traxis/web"}},
        "MICROSERVICES": {
            "OBOQBR": "oboqbr.prod.gb.internal",
            "EPG-SERVICE": "epg.prod.gb.dmdsdp.com",
        },
        "XAP": {"host": "oboqbr.prod.gb.internal/xap", "port": 80},
        "XAGGET": {"host": "172.16.100.90", "port": 1337, "repo": "eos_srxx", "duration": "",
                   "elastic": "172.23.124.1", "elastic_port": "9200", "cpe": "3C36E4-EOSSTB-003637806807",
                   "test_result": "172.16.100.98"
        }
    },
    "prod_at": {
        "CPE_FW_VERSION": "070-xj",
        "CPE_ID": "000378-EOSSTB-003770994105",
        "country": "at",
        "default_language": "de",
        # RE-CHECK AT root_id
        "root_id": ["omw_hzn4_vod"],
        "fallback_root_id": ["omw_hzn4_vod"],
        "VRM": {"BS": {"host": "vrm_bs_8092.prod.at.internal", "ports": [80]},
                "DS": {"host": "vrm_ds_8083.prod.at.internal", "ports": [80]},
                # "BS1": {"host": "172.30.108.53", "ports": [8092]},
                # "BS2": {"host": "172.30.108.54", "ports": [8092]},
                },
        "SEACHANGE": {"TRAXIS_WEB": {"host": "obotraxis.prod.at.internal", "port": 80, "path": "traxis/web"}},
        "MICROSERVICES": {
            "OBOQBR": "oboqbr.prod.at.internal",
            "EPG-SERVICE": "epg.prod.at.dmdsdp.com",
        },
        "XAP": {"host": "oboqbr.prod.at.internal/xap", "port": 80},
        "XAGGET": {"host": "172.16.100.90", "port": 1337, "repo": "eos_srxx", "duration": "",
                   "elastic": "172.23.124.1", "elastic_port": "9200", "cpe": "3C36E4-EOSSTB-003637806807",
                   "test_result": "172.16.100.98"
        }
    },
    "prod_ie": {
        "CPE_FW_VERSION": "070-xj",
        "CPE_ID": "000378-EOSSTB-003780411009",
        "country": "ie",
        "default_language": "en",
        # RE-CHECK AT root_id
        "root_id": ["omw_hzn4_vod"],
        "fallback_root_id": ["omw_hzn4_vod"],
        "VRM": {"BS": {"host": "vrm_bs_8092.prod.ie.internal", "ports": [80]},
                "DS": {"host": "vrm_ds_8083.prod.ie.internal", "ports": [80]}
                # "BS1": {"host": "172.30.108.53", "ports": [8092]},
                # "BS2": {"host": "172.30.108.54", "ports": [8092]},
                },
        "SEACHANGE": {"TRAXIS_WEB": {"host": "obotraxis.prod.ie.internal", "port": 80, "path": "traxis/web"}},
        "MICROSERVICES": {
            "OBOQBR": "oboqbr.prod.ie.internal",
            "EPG-SERVICE": "epg.prod.ie.dmdsdp.com",
        },
        "XAP": {"host": "oboqbr.prod.ie.internal/xap", "port": 80},
        "XAGGET": {"host": "172.16.100.90", "port": 1337, "repo": "eos_srxx", "duration": "",
                   "elastic": "172.23.124.1", "elastic_port": "9200", "cpe": "000378-EOSSTB-003780411009",
                   "test_result": "172.16.100.98"
                   }
    },
    "prod_pl": {
        "CPE_FW_VERSION": "070-xj",
        # RE-CHECK PL CPE_ID - PENDING
        "CPE_ID": "000378-EOSSTB-XXXX",
        "country": "pl",
        "default_language": "en",
        # RE-CHECK PL root_id
        "root_id": ["omw_hzn4_vod"],
        "fallback_root_id": ["omw_hzn4_vod"],
        "VRM": {"BS": {"host": "vrm_bs_8092.prod.pl.internal", "ports": [80]},
                "DS": {"host": "vrm_ds_8083.prod.pl.internal", "ports": [80]}
                },
        "SEACHANGE": {"TRAXIS_WEB": {"host": "obotraxis.prod.pl.internal", "port": 80, "path": "traxis/web"}},
        "MICROSERVICES": {
            "OBOQBR": "oboqbr.prod.pl.internal",
            "EPG-SERVICE": "epg.prod.pl.dmdsdp.com",
        },
        "XAP": {"host": "oboqbr.prod.pl.internal/xap", "port": 80}
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
