#OBO LAB (multi_tenant) LLD: https://wikiprojects.upc.biz/display/CTOOBO/E2ESI+%28Lab+only%29+LLDs
# Please fill in missing data marked as TODO


CONF_LLD = {
    "ACS_Southbound": {"prod_tenant": ["172.30.92.13", "172.30.92.15"], "ports": [80]},
    "ACS_Northbound": {"prod_tenant": ["172.30.92.10", "172.30.92.12"], "ports": [80]},
    "IT_Faker": {"prod_tenant": ["172.23.67.58"], "ports": [8000]},
    "Kubernetes_cluster": {"prod_lg": ["172.23.67.180", "172.23.67.181",
                                       "172.23.67.182", "172.23.67.183",
                                       "172.23.67.158", "172.23.67.121",
                                       "172.23.67.122", "172.23.67.144",
                                       "172.23.67.165", "172.23.67.166",
                                       "172.23.67.168", "172.23.67.180"],
                           "ports": [80, 30000]},
    "OESP": {"prod_tenant": ["oesp.labe2esi.orion.upclabs.com", "83.98.5.71"], "ports": [443]},
    "Traxis_Web": {"prod_tenant": ["172.23.67.167", "172.23.67.78"], "ports": [80]},
    "LTV_Ingest_Server": {"prod_tenant": ["62.179.124.4"], "ports": [21, 22]},
    "AirFlow_Manager_-_Web_Server": {"prod_lg": ["172.30.6.128"], "ports": [22]},
    "AirFlow_Workers": {"prod_lg": ["172.30.93.103", "172.30.93.121"], "ports": [22]},
    "VoD_Content_Provider": {"prod_lg": ["172.30.218.244"], "ports": [22]},
    "Liberty_Global_Bitbucket": {"mgmt": ["bitbucket.upc.biz"], "ports": [7999]},
    "CDN_DAs": {"prod_lg": ["172.30.127.116", "172.30.127.50", "172.30.127.117", "212.142.30.250"],
                "ports": [80, 443]},
    "VoD_VSPP_Controller": {"prod_lg": ["172.30.107.37", "172.30.107.38"], "ports": [5929]},
    "Central_RRM": {"prod_lg": ["lgiobo.stage.ott.irdeto.com"], "ports": [443]},
    "ODH_cluster": {"mgmt": ["172.30.108.79", "172.30.108.80", "172.30.108.81", "172.30.108.82",
                             "172.30.108.83", "172.30.108.84", "172.30.108.85"],
                    "ports": [9200]},
    "Offerings_Generator": {"prod_lg": ["172.30.93.81"], "ports": [22]},
    "VoD_Origin_node": {"prod_lg": ["172.30.107.39", "172.30.107.40"], "ports": [22]},
    "VoD_Transcoders": {"prod_lg": ["172.30.93.74", "172.30.93.106"], "ports": [22]},
    "Xagget_components": {"mgmt": ["172.30.108.11"], "ports": [1337]},
    "JIRA": {"external": ["jira.lgi.io"], "ports": [443]},
    "Connectra": {"mgmt": ["172.31.135.0/24", "172.31.139.0/24"], "ports": [80]},
    "Robot_Framework": {"prod_lg": "172.30.93.201", "mgmt": ["172.30.108.114"], "ports": [],
                        "ssh": {"host": "172.30.108.114", "port": 22,
                                "user": "vd_robot", "password": "ffH4M1@184ZU"}
                        },

    "Robot_Tenant_Proxy": {"prod_lg": ["172.30.92.25", "172.30.92.36"], "prod_tenant": [], "ports": [80],
                           "ssh": {"host": "172.30.108.110", "port": 22,
                                   "user": "vd_robot", "password": "ffH4M1@184ZU"}}
}
