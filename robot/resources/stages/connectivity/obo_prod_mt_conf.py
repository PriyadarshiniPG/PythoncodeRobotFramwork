# OBO PROD (multi_tenant) LLD: https://wikiprojects.upc.biz/display/CTOOBO/LLDs+NL
# Please fill in missing data marked as TODO


CONF_LLD = {
    "ACS_Southbound": {"prod_tenant": ["172.18.250.140", "172.18.250.141"], "ports": [80]},
    "ACS_Northbound": {"prod_tenant": ["172.18.250.138", "172.18.250.139"], "ports": [80]},
    "IT_Faker": {"prod_tenant": ["172.18.250.145"], "ports": [8000]},
    "Kubernetes_cluster": {"prod_lg": ["172.23.41.70", "172.23.41.80", "172.23.41.79",
                                       "172.23.41.81", "172.23.41.82", "172.23.41.83",
                                       "172.23.41.84", "172.23.41.85", "172.23.41.86",
                                       "172.23.41.88", "172.23.41.87", "172.23.41.50",
                                       "172.23.41.89", "172.23.41.71", "172.23.41.74",
                                       "172.23.41.73", "172.23.41.76", "172.23.41.75",
                                       "172.23.41.78", "172.23.41.77"],
                           "ports": [80, 30000]},
    "OESP": {"prod_tenant": ["83.98.5.80"], "ports": [443]},
    "Traxis_Web": {"prod_tenant": ["172.18.250.161", "172.18.250.162"], "ports": [80]},
    "LTV_Ingest_Server": {"prod_tenant": ["212.142.49.6"], "ports": [21, 22]},
    "AirFlow_Manager_-_Web_Server": {"prod_lg": ["172.16.145.0/25"], "ports": [22]},  # TODO
    "AirFlow_Workers": {"prod_lg": ["172.23.41.140", "172.23.41.173"], "ports": [22]},
    "VoD_Content_Provider": {"prod_lg": ["172.18.0.140"], "ports": [22]},
    "Liberty_Global_Bitbucket": {"mgmt": ["172.28.201.8"], "ports": [7999]},
    "CDN_DAs": {"prod_lg": ["212.54.62.132", "212.54.62.148", "212.54.62.134", "212.54.62.150",
                            "212.54.62.136", "212.54.62.152", "212.54.62.130", "212.54.62.146",
                            "212.54.62.138", "212.54.62.154", "212.54.62.140", "212.54.62.156",
                            "212.54.62.210", "212.54.62.194", "212.54.62.196", "212.54.62.212",
                            "212.54.62.198", "212.54.62.214", "212.54.62.200", "212.54.62.216",
                            "212.142.30.138", "212.142.30.170", "212.142.30.140", "212.142.30.172",
                            "212.142.30.142", "212.142.30.174", "212.142.30.144", "212.142.30.176",
                            "212.142.30.146", "212.142.30.178", "212.142.30.148", "212.142.30.180",
                            "212.142.30.150", "212.142.30.182", "212.142.30.132", "212.142.30.164",
                            "212.142.30.134", "212.142.30.166", "212.142.30.136", "212.142.30.168"],
                "ports": [80, 443]},
    "VoD_VSPP_Controller": {"prod_lg": ["172.23.41.23", "172.23.41.24"], "ports": [5929]},
    "Central_RRM": {"prod_lg": ["lgiobo.live.ott.irdeto.com"], "ports": [443]},
    "ODH_cluster": {"mgmt": ["172.16.100.220", "172.16.100.221", "172.16.100.222", "172.16.100.223",
                             "172.16.100.224", "172.16.100.225", "172.16.100.226", "172.16.100.227",
                             "172.16.100.228", "172.16.100.229", "172.16.100.230", "172.16.100.231",
                             "172.16.100.232", "172.16.100.233", "172.16.100.234", "172.16.100.217",
                             "172.16.100.218", "172.16.100.219"],
                    "ports": [9200]},
    "Offerings_Generator": {"prod_lg": ["172.23.41.51"], "ports": [22]},
    "VoD_Origin_node": {"prod_lg": ["172.23.41.15", "172.23.41.16"], "ports": [22]},
    "VoD_Transcoders": {"prod_lg": ["172.23.41.56", "172.23.41.55", "172.23.41.90", "172.23.41.91",
                                    "172.23.41.92", "172.23.41.93", "172.23.41.95", "172.23.41.96",
                                    "172.23.41.63", "172.23.41.64", "172.23.41.65", "172.23.41.66",
                                    "172.23.41.67", "172.23.41.68", "172.23.41.69", "172.23.41.72",
                                    "172.23.41.131", "172.23.41.135", "172.23.41.136",
                                    "172.23.41.139", "172.23.41.141", "172.23.41.142",
                                    "172.23.41.143", "172.23.41.144", "172.23.41.130",
                                    "172.23.41.132", "172.23.41.146", "172.23.41.137",
                                    "172.23.41.148", "172.23.41.149", "172.23.41.150",
                                    "172.23.41.151"],
                        "ports": [22]},
    "Xagget_components": {"mgmt": ["172.16.100.90"], "ports": [1337]},
    "JIRA": {"external": ["jira.lgi.io"], "ports": [443]},
    "Connectra": {"mgmt": ["172.31.135.0/24", "172.31.139.0/24"], "ports": [80]},  # TODO
    "Robot_Framework": {"prod_lg": [], "mgmt": [], "ports": []},  # TODO

    "Robot_Tenant_Proxy": {"prod_lg": [], "prod_tenant": [], "ports": [],
                           "ssh": {"host": "172.30.135.24", "port": 22,
                                   "user": "superset", "password": "supersetqa"}}  # TODO
}
