import plotly.graph_objs as go
import plotly.offline as loc
from datetime import datetime, timedelta
from elasticsearch import Elasticsearch
from elasticsearch_dsl import Search, connections
import elasticsearch_dsl
import sys, os, pickle
sys.path.append(os.path.abspath("../../robot/resources/stages/"))
import conf_obolabecx


def get_last_week_dates():
    today = datetime.today()
    days = []
    for d in range(8):
        days.append(str(today - timedelta(days=d+1))[0:10].replace('-', '.'))
    return days[::-1]


def get_today_str():
    return str(datetime.today())[0:10]


def search_results():
    elastic_host = conf_obolabecx.ELK_HOST
    elastic_port = conf_obolabecx.ELK_PORT
    print("Elastic host: {}, Elastic port: {}".format(elastic_host, elastic_port))
    connections.create_connection(hosts=[elastic_host], timeout=20)
    colors = [
        'rgb(50, 245, 11)',
        'rgb(255, 5, 5)',
        'rgb(22, 137, 252)',
        'rgb(252, 168, 22)',
        'rgb(150, 222, 11)',
        'rgb(25, 45, 210)',
        'rgb(200, 50, 140)',
        'rgb(195, 135, 75)',
        'rgb(185, 130, 90)',
        'rgb(175, 125, 110)',
        'rgb(165, 120, 120)',
        'rgb(155, 115, 130)',
        'rgb(145, 110, 140)'
    ]
    print(colors)
    result_types = ['passed', 'failed', 'skipped', 'actions-failed', 'data-failed', 'error', 'state-missing',
                    'data-missing', 'state-timeout', 'state-error', 'pre-actions-failed', 'pre-requirements-failed',
                    'state-not-in-mapping']
    results = []
    last_week_dates = get_last_week_dates()
    for r in result_types:
        trace_dict = dict(
            x=last_week_dates,
            y=[0]*8,
            mode='lines',
            line=dict(
                width=0.5,
                color=colors[result_types.index(r)]
            ),
            stackgroup='one',
            name=r
        )
        results.append(trace_dict)
        # if len(results) == 1:
        #     trace_dict['groupnorm'] = 'percent'

    for d in range(8):
        idx = "xagget_testresults-obolab-" + last_week_dates[d]
        s = Search() \
            .query('term', dependencies__laboEnvironment="labe2esuperset") \
            .query('term', _index=idx)
        s.execute()
        numbers = [0] * 13      # len(result_types) ?
        response = s.scan()
        for h in response:
            if h.result in result_types:
                numbers[result_types.index(h.result)] += 1
            else:
                print("error - result not known: result " + h.result)
        for t in range(len(results)):
            results[t]['y'][d] += numbers[t]
    with open('results-'+get_today_str()+'.pickle', 'wb') as f:
        pickle.dump(results, f, pickle.HIGHEST_PROTOCOL)
    return results


def main():
    today = get_today_str()
    if os.path.isfile('results-'+today+'.pickle'):
        with open('results-'+today+'.pickle', 'rb') as f:
            results = pickle.load(f)
    else:
        results = search_results()
    fig = dict(data=results)
    filename = "report/xagget_healthcheck_stacked_area.html"
    loc.plot(fig, filename=filename, auto_open=False)
    results[0]["groupnorm"] = 'percent'
    layout = go.Layout(showlegend=True,
                       xaxis=dict(type='category'),
                       yaxis=dict(type='linear',
                                  range=[1, 100],
                                  dtick=20,
                                  ticksuffix='%'))
    fig = dict(data=results, layout=layout)
    filename = "report/xagget_healthcheck_norm.html"
    loc.plot(fig, filename=filename, auto_open=False)


if __name__ == "__main__":
    main()


"""
    # s = s.from_dict({
    #     "_source" : ["result", "Timing.startTime", "dependencies.laboEnvironment"],
    #     "query" : {
    #       "bool" : {
    #         "must" : [
    #           {"term" : {"dependencies.laboEnvironment": "labe2esuperset"}}
    #         ],
    #         "filter" : {
    #           "range" : {
    #             "Timing.startTime" : {
    #               "gte" : "2019-01-19T00:00:00.000Z",
    #               "lte" : "2019-01-19T23:59:59.000Z"
    #             }
    #           }
    #         }
    #       }
    #     },
    #     "size" : 1000
    #   })
    
{'actions-failed', 'state-missing', 'passed', 'data-failed', 'error', 'skipped', 'failed', 'data-missing', 'state-timeout', 'state-error'}
    
Per day in last 7 days (not including today)
Fetch all xagget test results
Use set of possible results

Each Dict -> Test Result

Create Dict
    x-axis: array of result types
    y-axix: array # each result type
    mode="lines"
    line = dict
    stackgroup="one"
    groupnorm="percent"
If result not in result type - error to sdtout
Append Dict to array

Generate chart

"""
