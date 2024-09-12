import csv, os, sys
sys.path.append(os.path.relpath("../../robot/resources/stages"))
from conf_obolabecx import E2E_CONF as conf


e2esi_endpoints = sorted(conf["labe2esi"].keys())
superset_endpoints = sorted(conf["labe2esuperset"].keys())

combined_lists = sorted(set(e2esi_endpoints + superset_endpoints))

f = open('endpoints.csv', 'wb')
endpoint_writer = csv.writer(f)
endpoint_writer.writerow(['Endpoint', 'E2ESI', 'SuperSet'])
for i in combined_lists:
    tmp = [i, 'NONE', 'NONE']
    if i in e2esi_endpoints:
        tmp[1] = '*'
    if i in superset_endpoints:
        tmp[2] = '*'
    endpoint_writer.writerow(tmp)
