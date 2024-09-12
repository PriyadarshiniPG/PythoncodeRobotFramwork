from elasticsearch import Elasticsearch
from elasticsearch_dsl import Search
from elasticsearch_dsl.query import MultiMatch, Match
from bs4 import BeautifulSoup
from datetime import date, timedelta
from sortedcontainers import SortedDict
import argparse, pygal

class AutoDict(dict):
    def __missing__(self, key):
        value = self[key] = type(self)()
        return value

def grab_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('lab')
    args = parser.parse_args()
    return args.lab


def count_results(d, key, p, f):
    if key in features:
        d[key]['total'] += 1
        d[key]['pass'] += res_pass
        d[key]['fail'] += res_fail
    else:
        d[key]['total'] = 1
        d[key]['pass'] = res_pass
        d[key]['fail'] = res_fail


def create_feature_rows(i, sf):
    new_total_row = email_html_soup.new_tag("div", **{'class':'section_row'})
    new_row.append(new_total_row)
    new_item_name = email_html_soup.new_tag("div", **{'class':'section_item_name'})
    new_data = email_html_soup.new_tag("div", **{'class':'section_data'})
    new_total_row.append(new_item_name)
    new_total_row.append(new_data)
    new_item_name.string = i
    new_data.string = str(sf[i])


def add_fail_url(name, url, jira, failedReason):
    new_row = email_html_soup.new_tag("div", **{'class':'fail_row'})
    fail_link = email_html_soup.new_tag("a", **{'href':url})
    line_break = email_html_soup.new_tag("br")
    failed_div.append(new_row)
    new_row.append(fail_link)
    fail_link.string = name
    new_row.append("\nJira TestCase: " + jira)
    new_row.append("\nFailed Reason: " + failedReason)


def binary_pie(numbers, title):
    pie_chart = pygal.Pie()
    for n in numbers:
        pie_chart.add(n, [{'value': numbers[n]['value'], 'label': numbers[n]['label'], 'color': numbers[n]['color']}])
    pie_chart.title = title
    # pie_chart.render_to_png("out.png")
    return pie_chart.render_data_uri()


index_name = 'http://10.64.13.179:9200/testrobot-' + (date.today() - timedelta(days=1)).strftime('%Y.%m.%d') + '/'
lab = grab_args()
test_run_date = (date.today() - timedelta(days=1)).strftime('%A %d %B %Y')
client = Elasticsearch([index_name])
with open("e2erobot-reporter.html") as f:
    email_html_soup = BeautifulSoup(f, "html.parser")

s = Search(using=client)
s.update_from_dict({ \
                       "query": { \
                           "bool": { \
                               "should": [ \
                                   {"match": {"_type": "testcase"}}, \
                                   {"match": {"lab": lab}} \
                                ] \
                            } \
                        }, \
                        "size": 1000 \
                    })
response = s.execute()

total_test_count = response.hits.total
total_pass_count = 0
total_fail_count = 0
features = AutoDict()

failed_div = email_html_soup.find("div", id="failed_cases")

for h in response:
    res_pass = 0
    res_fail = 0
    if h.result == "PASS":
        total_pass_count = total_pass_count + 1
        res_pass = 1
    elif h.result == "FAIL":
        total_fail_count = total_fail_count + 1
        res_fail = 1
        add_fail_url(h.testCase, h.resultLink, h.jira, h.failedReason)
    else:
        print("no result in testcase")
    count_results(features, h.feature, res_pass, res_fail)

if total_test_count > 0:
    pass_rate = round((total_pass_count / total_test_count) * 100, 2)
else:
    pass_rate = 100

lab_div = email_html_soup.find("div", id="lab")
lab_div.append(lab)

date_div = email_html_soup.find("div", id="date")
date_div.append(test_run_date)

num_run = email_html_soup.find("div", id="num_run")
num_run.append(str(total_test_count))

num_passed_div = email_html_soup.find("div", id="num_passed")
num_passed_div.append(str(total_pass_count))

num_failed_div = email_html_soup.find("div", id="num_failed")
num_failed_div.append(str(total_fail_count))

pass_rate_div = email_html_soup.find("div", id="pass_rate")
if pass_rate < 90:
    pass_rate_div['style'] = 'background-color:red'
elif pass_rate < 80:
    pass_rate_div['style'] = 'background-color:orange'
else:
    pass

chart_data = {'pass':{'value':total_pass_count,'label':'pass','color':'green'}, \
        'fail':{'value':total_fail_count,'label':'fail','color':'red'}}

pie = binary_pie(chart_data, 'test')
pass_rate_div.append(str(pass_rate) + "%")

features_div = email_html_soup.find("div", id="features_list")

overview_div = email_html_soup.find("div", id="overview_block")
pie_image = email_html_soup.new_tag("img", **{'src':pie,'width':400,'height':300})
overview_div.append(pie_image)

sorted_features = SortedDict(features)
for f in sorted_features:
    new_row = email_html_soup.new_tag("div", **{'class':'section_row_title'}, \
            **{'id':'section_row_feature'})
    features_div.append(new_row)
    new_row.string = f
    for i in ["pass", "fail", "total"]:
        create_feature_rows(i, sorted_features[f])
    chart_data = {'pass':{'value': sorted_features[f]['pass'],'label':'pass','color':'green'}, \
        'fail':{'value':sorted_features[f]['fail'],'label':'fail','color':'red'}}
    feature_pie_chart = binary_pie(chart_data, f)
    feature_pie_chart_img = email_html_soup.new_tag("img", \
            **{'src':feature_pie_chart,'width':300,'height':200})
    new_row.append(feature_pie_chart_img)

# output_html = open("e2erobot-report-" + test_run_date + ".html", "w")
output_html = open("out.html", "w")
output_html.write(email_html_soup.prettify())



"""
A simple query to get testcases in an index

GET /testrobot-2017.11.27/_search
{
  "query": {
      "match": {
            "_type": "testcase"
      }
  },
  "size": 1000
}

"""
# print(json.dumps(response.to_dict(), indent=4))
