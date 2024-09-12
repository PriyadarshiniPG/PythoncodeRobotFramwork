# pylint: disable=C0301
# pylint: disable=C0330
# pylint: disable=W0221
# pylint: disable=unused-argument
# are implemented as protected methods, and we need to test them directly.
# Disabled pylint "unused-argument" since it's required,
# but internal in mocked functions.
"""Unit tests of Jira library's components.
"""

import os
import unittest
try:
    import mock
except ImportError:
    import unittest.mock as mock
from Libraries.Common.utils import CaptureResultJson
from .keywords import JiraGetter


JIRA_HOST = "https://jira.lgi.io"
ZEPHYR_API_ENDPOINT = "rest/zapi/latest"
JIRA_API_ENDPOINT = "rest/api/2"
ZEPHYR_API_HOST = "%s/%s" % (JIRA_HOST, ZEPHYR_API_ENDPOINT)
JIRA_API_HOST = "%s/%s" % (JIRA_HOST, JIRA_API_ENDPOINT)
# Authorization
USER_NAME = "techentautomatedtest"
API_TOKEN = "dd2gc2Uga25vdw"
DEFAULT_HEADERS = {
    "Authorization": "Basic %s" % API_TOKEN,
    "Content-Type": "application/json"}

FILTER_ID = "100944"

INIT = {
    "PROJECT_NAME": "HES",
    "BUILD": "AIRFLOW 2.03",
    "ENVIRONMENT": "Country Specific Integration (Superset)",
    "VERSION": "R4.21",
    "TEST_CYCLE_NAME": "AF Validation (auto created) from 2019-12-16 16:27",
    "USE_EXIST_TEST_CYCLE": "True"
}
## OS ENVs for INIT ##
os.environ["PROJECT_NAME"] = INIT["PROJECT_NAME"]
os.environ["BUILD"] = INIT["BUILD"]
os.environ["ENVIRONMENT"] = INIT["ENVIRONMENT"]
os.environ["VERSION"] = INIT["VERSION"]
os.environ["TEST_CYCLE_NAME"] = INIT["TEST_CYCLE_NAME"]
os.environ["USE_EXIST_TEST_CYCLE"] = INIT["USE_EXIST_TEST_CYCLE"]

EXECUTION_ID = "399450"

SAMPLE_JIRA_PROJECT = {
    "expand": "descriptionprojectKeys",
    "self": "https://jira.lgi.io/rest/api/2/project/17161",
    "id": "17161",
    "key": "HES"
}

SAMPLE_JIRA_FILTER_ID = {
    "self": "https://jira.lgi.io/rest/api/2/filter/100944",
    "id": "100944",
    "name": "Linked DEFECTS for Automated RF Regression Set",
    "description": "",
    "owner": {
        "self": "https://jira.lgi.io/rest/api/2/user?username=shthorat.contractor",
        "key": "shthorat.contractor",
        "name": "shthorat.contractor",
        "avatarUrls": {
            "48x48": "https://www.gravatar.com/avatar/15d6e6a28807d1862b0c6152fdf04b6b?d=mm&s=48",
            "24x24": "https://www.gravatar.com/avatar/15d6e6a28807d1862b0c6152fdf04b6b?d=mm&s=24",
            "16x16": "https://www.gravatar.com/avatar/15d6e6a28807d1862b0c6152fdf04b6b?d=mm&s=16",
            "32x32": "https://www.gravatar.com/avatar/15d6e6a28807d1862b0c6152fdf04b6b?d=mm&s=32"
        },
        "displayName": "Shilpa Thorat",
        "active": True
    },
    "jql": "issuefunction in linkedIssuesOf(\"filter = 'HZN4 Automated E2E Regression tests'\") AND issuetype in (Bug, Defect) AND status not in (Done, Closed, Deferred, Rejected)",
    "viewUrl": "https://jira.lgi.io/issues/?filter=100944",
    "searchUrl": "https://jira.lgi.io/rest/api/2/search?jql=issuefunction+in+linkedIssuesOf(%22filter+%3D+'HZN4+Automated+E2E+Regression+tests'%22)+AND+issuetype+in+(Bug,+Defect)+AND+status+not+in+(Done,+Closed,+Deferred,+Rejected)",
    "favourite": True,
    "sharePermissions": [{
            "id": 110221,
            "type": "group",
            "group": {
                "name": "jira-users",
                "self": "https://jira.lgi.io/rest/api/2/group?groupname=jira-users"
            },
            "view": True,
            "edit": False
        }, {
            "id": 110220,
            "type": "user",
            "user": {
                "self": "https://jira.lgi.io/rest/api/2/user?username=fecobos",
                "key": "fecobos.contractor",
                "name": "fecobos",
                "avatarUrls": {
                    "48x48": "https://jira.lgi.io/secure/useravatar?ownerId=fecobos.contractor&avatarId=17708",
                    "24x24": "https://jira.lgi.io/secure/useravatar?size=small&ownerId=fecobos.contractor&avatarId=17708",
                    "16x16": "https://jira.lgi.io/secure/useravatar?size=xsmall&ownerId=fecobos.contractor&avatarId=17708",
                    "32x32": "https://jira.lgi.io/secure/useravatar?size=medium&ownerId=fecobos.contractor&avatarId=17708"
                },
                "displayName": "Fernando Cobos",
                "active": True
            },
            "view": True,
            "edit": True
        }, {
            "id": 110219,
            "type": "project-unknown",
            "view": True,
            "edit": False
        }
    ],
    "editable": False,
    "sharedUsers": {
        "size": 0,
        "items": [],
        "max-results": 1000,
        "start-index": 0,
        "end-index": 0
    },
    "subscriptions": {
        "size": 0,
        "items": [],
        "max-results": 1000,
        "start-index": 0,
        "end-index": 0
    }
}

SAMPLE_JIRA_FILTER_ID_SEARCH_URL = """https://jira.lgi.io/rest/api/2/search?jql=issuefunction+in+\
linkedIssuesOf(%22filter+%3D+'HZN4+Automated+E2E+Regression+tests'%22)+AND+issuetype+in+(Bug,\
+Defect)+AND+status+not+in+(Done,+Closed,+Deferred,+Rejected)"""

JQL_SEARCH = """issuefunction+in+linkedIssuesOf(%22filter+%3D+'HZN4+Automated+E2E+Regression+\
tests'%22)+AND+issuetype+in+(Bug,+Defect)+AND+status+not+in+(Done,+Closed,+Deferred,+Rejected)"""

SAMPLE_JIRA_SEARCH_JQL = {
    "issues": [
        {
            "key": "HES-106",
            "fields": {
                "environment": None,
                "timespent": None,
                "updated": "2019-12-10T08:46:35.000+0000",
                "lastViewed": None,
                "timeestimate": None,
                "reporter": {
                    "displayName": "Aiswariya Byju (infosys)",
                    "name": "aiswariya.b",
                    "self": "https://jira.lgi.io/rest/api/2/user?username=aiswariya.b",
                    "emailAddress": "abyju.contractor@libertyglobal.com",
                    "key": "aiswariya.b",
                    "active": True,
                    "timeZone": "Europe/Amsterdam"
                },
                "votes": {
                    "hasVoted": False,
                    "self": "https://jira.lgi.io/rest/api/2/issue/HES-106/votes",
                    "votes": 0
                },
                "description": "<div style=\"-webkit-text-stroke-width:0px; text-align:start; text-indent:0px\">\r\n<p><span style=\"color:#000000\"><span style=\"font-size:16px\"><span style=\"font-family:&quot;Times New Roman&quot;\"><span style=\"font-style:normal\"><span style=\"font-variant-ligatures:normal\"><span style=\"font-variant-caps:normal\"><span style=\"font-weight:400\"><span style=\"letter-spacing:normal\"><span style=\"orphans:2\"><span style=\"text-transform:none\"><span style=\"white-space:normal\"><span style=\"widows:2\"><span style=\"word-spacing:0px\"><span style=\"text-decoration-style:initial\"><span style=\"text-decoration-color:initial\"><span style=\"font-size:12pt\"><span style=\"font-family:&quot;Times New Roman&quot;,serif\"><span style=\"font-size:10pt\"><span style=\"font-family:Tahoma,sans-serif\"><u>Description</u> :<br>\r\nThe button \"Browse all available channels\" is not as per other tenants and it comes with a \".\"</span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span><br>\r\n<br>\r\n<u>Environment Details</u> :<br>\r\nCPE BUILD: EOS1008C-mon-ops-00.02-076-fi-AL-20191007101917-na001<br>\r\nCPE VERSION: 076-fi<br>\r\nReproducibility : Always<br>\r\nLAB : PROD</span><br>\r\n&nbsp;</p>\r\n</div>\r\n\r\n<div style=\"-webkit-text-stroke-width:0px; text-align:start; text-indent:0px\">\r\n<p><span style=\"color:#000000\"><span style=\"font-size:16px\"><span style=\"font-family:&quot;Times New Roman&quot;\"><span style=\"font-style:normal\"><span style=\"font-variant-ligatures:normal\"><span style=\"font-variant-caps:normal\"><span style=\"font-weight:400\"><span style=\"letter-spacing:normal\"><span style=\"orphans:2\"><span style=\"text-transform:none\"><span style=\"white-space:normal\"><span style=\"widows:2\"><span style=\"word-spacing:0px\"><span style=\"text-decoration-style:initial\"><span style=\"text-decoration-color:initial\"><span style=\"font-size:12pt\"><span style=\"font-family:&quot;Times New Roman&quot;,serif\"><span style=\"font-size:10pt\"><span style=\"font-family:Tahoma,sans-serif\"><u>Scenario to reproduce </u>:&nbsp;&nbsp;<br>\r\nPrecondition :&nbsp;</span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span>&nbsp;CPE should be up and running and box language should be English.&nbsp; Box should have a custom profile with few channels added to personal line up.</span></p>\r\n</div>\r\n\r\n<div style=\"-webkit-text-stroke-width:0px; text-align:start; text-indent:0px\">\r\n<ol start=\"1\" style=\"list-style-type:decimal\" type=\"1\">\r\n\t<li style=\"font-size:12pt; font-family:&quot;Times New Roman&quot;, serif; color:black; margin-bottom:0px\"><span style=\"color:#000000\"><span style=\"font-size:16px\"><span style=\"font-family:&quot;Times New Roman&quot;\"><span style=\"font-style:normal\"><span style=\"font-variant-ligatures:normal\"><span style=\"font-variant-caps:normal\"><span style=\"font-weight:400\"><span style=\"letter-spacing:normal\"><span style=\"orphans:2\"><span style=\"text-transform:none\"><span style=\"white-space:normal\"><span style=\"widows:2\"><span style=\"word-spacing:0px\"><span style=\"text-decoration-style:initial\"><span style=\"text-decoration-color:initial\"><span style=\"font-size:10pt\"><span style=\"font-family:Tahoma,sans-serif\">Launch TV Guide</span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></li>\r\n\t<li style=\"font-size:12pt; font-family:&quot;Times New Roman&quot;, serif; color:black; margin-bottom:0px\"><span style=\"color:#000000\"><span style=\"font-size:16px\"><span style=\"font-family:&quot;Times New Roman&quot;\"><span style=\"font-style:normal\"><span style=\"font-variant-ligatures:normal\"><span style=\"font-variant-caps:normal\"><span style=\"font-weight:400\"><span style=\"letter-spacing:normal\"><span style=\"orphans:2\"><span style=\"text-transform:none\"><span style=\"white-space:normal\"><span style=\"widows:2\"><span style=\"word-spacing:0px\"><span style=\"text-decoration-style:initial\"><span style=\"text-decoration-color:initial\"><span style=\"font-size:10pt\"><span style=\"font-family:Tahoma,sans-serif\">Press CONTEXT key.</span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></li>\r\n\t<li style=\"font-size:12pt; font-family:&quot;Times New Roman&quot;, serif; color:black; margin-bottom:0px\"><span style=\"color:#000000\"><span style=\"font-size:16px\"><span style=\"font-family:&quot;Times New Roman&quot;\"><span style=\"font-style:normal\"><span style=\"font-variant-ligatures:normal\"><span style=\"font-variant-caps:normal\"><span style=\"font-weight:400\"><span style=\"letter-spacing:normal\"><span style=\"orphans:2\"><span style=\"text-transform:none\"><span style=\"white-space:normal\"><span style=\"widows:2\"><span style=\"word-spacing:0px\"><span style=\"text-decoration-style:initial\"><span style=\"text-decoration-color:initial\"><span style=\"font-size:10pt\"><span style=\"font-family:Tahoma,sans-serif\">Validate the Pop up Button - Browse all available channels</span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></li>\r\n</ol>\r\n\r\n<p style=\"color:black; font-family:&quot;Times New Roman&quot;,serif; font-size:12pt; margin-bottom:0px\"><span style=\"color:#000000\"><span style=\"font-size:16px\"><span style=\"font-family:&quot;Times New Roman&quot;\"><span style=\"font-style:normal\"><span style=\"font-variant-ligatures:normal\"><span style=\"font-variant-caps:normal\"><span style=\"font-weight:400\"><span style=\"letter-spacing:normal\"><span style=\"orphans:2\"><span style=\"text-transform:none\"><span style=\"white-space:normal\"><span style=\"widows:2\"><span style=\"word-spacing:0px\"><span style=\"text-decoration-style:initial\"><span style=\"text-decoration-color:initial\"><span style=\"font-size:10pt\"><span style=\"font-family:Tahoma,sans-serif\"><u>Actual Result</u> :&nbsp;</span></span><span style=\"font-size:12pt\"><span style=\"font-family:&quot;Times New Roman&quot;,serif\"><span style=\"font-size:10pt\"><span style=\"font-family:Tahoma,sans-serif\">Browse all available channels option is having a '.' at the end</span></span></span></span><br>\r\n<span style=\"font-size:10pt\"><span style=\"font-family:Tahoma,sans-serif\"><u>Expected Result </u>:&nbsp;</span></span><span style=\"font-size:12pt\"><span style=\"font-family:&quot;Times New Roman&quot;,serif\"><span style=\"font-size:10pt\"><span style=\"font-family:Tahoma,sans-serif\">Browse all available channels should be unique across all tenants</span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span> <img alt=\"\" src=\"Browse available channels\"></span></p>\r\n</div>\r\n",
                "duedate": None,
                "created": "2019-11-19T13:02:05.000+0000",
                "creator": {
                    "displayName": "Aiswariya Byju (infosys)",
                    "name": "aiswariya.b",
                    "self": "https://jira.lgi.io/rest/api/2/user?username=aiswariya.b",
                    "emailAddress": "abyju.contractor@libertyglobal.com",
                    "key": "aiswariya.b",
                    "active": True,
                    "timeZone": "Europe/Amsterdam"
                },
                "priority": {
                    "iconUrl": "https://jira.lgi.io/images/icons/priorities/minor.svg",
                    "self": "https://jira.lgi.io/rest/api/2/priority/4",
                    "name": "Minor (P3)",
                    "id": "4"
                },
                "workratio": -1,
                "fixVersions": [],
                "labels": ["E2ESI_PROD", "R4.XX", "TESTAutomation"],
                "aggregatetimeoriginalestimate": None,
                "summary": "[AT PROD] 'Browse all available channels' option in TV Guide have an additional '.' at the end in AT tenant",
                "issuetype": {
                    "name": "Bug",
                    "self": "https://jira.lgi.io/rest/api/2/issuetype/1",
                    "iconUrl": "https://jira.lgi.io/secure/viewavatar?size=xsmall&avatarId=12093&avatarType=issuetype",
                    "subtask": False,
                    "avatarId": 12093,
                    "id": "1",
                    "description": "A problem which impairs or prevents the functions of the product."
                },
                "issuelinks": [{
                        "self": "https://jira.lgi.io/rest/api/2/issueLink/1729553",
                        "outwardIssue": {
                            "fields": {
                                "status": {
                                    "statusCategory": {
                                        "name": "Done",
                                        "self": "https://jira.lgi.io/rest/api/2/statuscategory/3",
                                        "id": 3,
                                        "key": "done",
                                        "colorName": "green"
                                    },
                                    "description": "",
                                    "self": "https://jira.lgi.io/rest/api/2/status/10048",
                                    "iconUrl": "https://jira.lgi.io/images/icons/statuses/generic.png",
                                    "id": "10048",
                                    "name": "Done"
                                },
                                "priority": {
                                    "iconUrl": "https://jira.lgi.io/images/icons/priorities/major.svg",
                                    "self": "https://jira.lgi.io/rest/api/2/priority/3",
                                    "name": "Major (P2)",
                                    "id": "3"
                                },
                                "issuetype": {
                                    "name": "Test",
                                    "self": "https://jira.lgi.io/rest/api/2/issuetype/10202",
                                    "iconUrl": "https://jira.lgi.io/secure/viewavatar?size=xsmall&avatarId=38810&avatarType=issuetype",
                                    "subtask": False,
                                    "avatarId": 38810,
                                    "id": "10202",
                                    "description": "This JIRA Issue Type is used to create Zephyr Tests."
                                },
                                "summary": "Profiles - Favorite channels - Temporary channels - Add to line-up"
                            },
                            "self": "https://jira.lgi.io/rest/api/2/issue/769272",
                            "id": "769272",
                            "key": "HES-2888"
                        },
                        "type": {
                            "outward": "blocks",
                            "inward": "is blocked by",
                            "self": "https://jira.lgi.io/rest/api/2/issueLinkType/10970",
                            "id": "10970",
                            "name": "Blocking"
                        },
                        "id": "1729553"
                    }
                ],
                "progress": {
                    "progress": 0,
                    "total": 0
                },
                "aggregateprogress": {
                    "progress": 0,
                    "total": 0
                },
                "aggregatetimespent": None,
                "aggregatetimeestimate": None,
                "project": {
                    "self": "https://jira.lgi.io/rest/api/2/project/17161",
                    "avatarUrls": {
                        "24x24": "https://jira.lgi.io/secure/projectavatar?size=small&pid=17161&avatarId=35797",
                        "32x32": "https://jira.lgi.io/secure/projectavatar?size=medium&pid=17161&avatarId=35797",
                        "48x48": "https://jira.lgi.io/secure/projectavatar?pid=17161&avatarId=35797",
                        "16x16": "https://jira.lgi.io/secure/projectavatar?size=xsmall&pid=17161&avatarId=35797"
                    },
                    "id": "1761",
                    "key": "HES",
                    "name": "HZN4 E2E SI"
                },
                "status": {
                    "statusCategory": {
                        "name": "To Do",
                        "self": "https://jira.lgi.io/rest/api/2/statuscategory/2",
                        "id": 2,
                        "key": "new",
                        "colorName": "blue-gray"
                    },
                    "description": "",
                    "self": "https://jira.lgi.io/rest/api/2/status/1183",
                    "iconUrl": "https://jira.lgi.io/images/icons/statuses/generic.png",
                    "id": "1183",
                    "name": "Draft"
                },
                "timeoriginalestimate": None,
                "components": [{
                        "self": "https://jira.lgi.io/rest/api/2/component/24680",
                        "id": "24680",
                        "name": "CPE"
                    }, {
                        "self": "https://jira.lgi.io/rest/api/2/component/46938",
                        "id": "46938",
                        "name": "Personalization Service"
                    }
                ],
                "assignee": {
                    "displayName": "Praveen Rao",
                    "name": "Praveen_S17",
                    "self": "https://jira.lgi.io/rest/api/2/user?username=Praveen_S17",
                    "avatarUrls": {
                        "24x24": "https://www.gravatar.com/avatar/52f8bc24b377cf27540cca8bf357c2a6?d=mm&s=24",
                        "32x32": "https://www.gravatar.com/avatar/52f8bc24b377cf27540cca8bf357c2a6?d=mm&s=32",
                        "48x48": "https://www.gravatar.com/avatar/52f8bc24b377cf27540cca8bf357c2a6?d=mm&s=48",
                        "16x16": "https://www.gravatar.com/avatar/52f8bc24b377cf27540cca8bf357c2a6?d=mm&s=16"
                    },
                    "emailAddress": "pasrao.contractor@libertyglobal.com",
                    "key": "praveen_s17",
                    "active": True,
                    "timeZone": "Europe/Amsterdam"
                },
                "subtasks": [],
                "versions": [{
                        "released": False,
                        "self": "https://jira.lgi.io/rest/api/2/version/71902",
                        "archived": False,
                        "id": "71902",
                        "name": "4.20"
                    }
                ],
                "resolutiondate": None,
                "watches": {
                    "self": "https://jira.lgi.io/rest/api/2/issue/HES-11266/watchers",
                    "watchCount": 2,
                    "isWatching": False
                },
                "resolution": None
            },
            "self": "https://jira.lgi.io/rest/api/2/issue/439282",
            "id": "439282",
            "expand": "operations,versionedRepresentations,editmeta,changelog,renderedFields"
        }, {
            "key": "HES-11448",
            "fields": {
                "environment": None,
                "timespent": None,
                "updated": "2019-12-10T08:40:28.000+0000",
                "lastViewed": None,
                "timeestimate": None,
                "reporter": {
                    "displayName": "Anuj Teotia",
                    "name": "Anuj.Teotia01",
                    "self": "https://jira.lgi.io/rest/api/2/user?username=Anuj.Teotia01",
                    "emailAddress": "akumarteotia.contractor@libertyglobal.com",
                    "key": "anuj.teotia01",
                    "active": True,
                    "timeZone": "Europe/Amsterdam"
                },
                "votes": {
                    "hasVoted": False,
                    "self": "https://jira.lgi.io/rest/api/2/issue/HES-11448/votes",
                    "votes": 0
                },
                "description": "<p>1. Summary:<br>\r\nJson for focused tile in 'more like this' is missing. The response is an empty dictionary&nbsp;<br>\r\n<br>\r\n2. Severity:<br>\r\nMedium<br>\r\n<br>\r\n3. Replication path/steps:</p>\r\n\r\n<ol>\r\n\t<li>Tune to any channel where 'more like this' is available.</li>\r\n\t<li>Open linear detail page (press 'OK')</li>\r\n\t<li>Press down and move focus on a tile in&nbsp;'more like this'</li>\r\n\t<li>Send get request:&nbsp;<a href=\"http://10.22.90.24:8125/v2/nodes/focused\" title=\"Follow link\">http://&lt;STB_IP&gt;:8125/v2/nodes/focused</a> where &lt;STB_IP&gt; is IP of you local STB</li>\r\n</ol>\r\n\r\n<p><br>\r\n4. Actual results:<br>\r\nThe response is an empty dictionary<br>\r\n<br>\r\n5. Expected results:<br>\r\nJson for focused tile should be available<br>\r\n<br>\r\n6. Frequency (percentage):<br>\r\n100%<br>\r\n<br>\r\n7. SW version&amp; HW Platform:</p>\r\n\r\n<pre data-copyable=\"true\">DCX960__-mon-ops-00.02-079-fm-AL-20191120070140-na004\r\n\r\n8. Test environment:\r\nProd NL, Prod CH, and Prod BE\r\n\r\n9. Additional Information:\r\nThis issue is fixed as part of&nbsp;<a href=\"https://jira.lgi.io/browse/ARRISEOS-30660\">https://jira.lgi.io/browse/ARRISEOS-30660</a>&nbsp; which is for R4.23 SR86. And we are running automated test cases on PROD and Preprod tenants with SR79&nbsp; build where all the test cases related to this are failing.\r\n\r\n</pre>\r\n",
                "duedate": None,
                "created": "2019-12-04T09:44:45.000+0000",
                "creator": {
                    "displayName": "Anuj Teotia",
                    "name": "Anuj.Teotia01",
                    "self": "https://jira.lgi.io/rest/api/2/user?username=Anuj.Teotia01",
                    "emailAddress": "akumarteotia.contractor@libertyglobal.com",
                    "key": "anuj.teotia01",
                    "active": True,
                    "timeZone": "Europe/Amsterdam"
                },
                "priority": {
                    "iconUrl": "https://jira.lgi.io/images/icons/priorities/major.svg",
                    "self": "https://jira.lgi.io/rest/api/2/priority/3",
                    "name": "Major (P2)",
                    "id": "3"
                },
                "workratio": -1,
                "fixVersions": [],
                "labels": ["E2ESI_QA_E2ESUPERSET_LAB", "E2ESI_QA_LAB", "E2ESI_QA_PREPROD", "E2ESI_QA_PROD", "E2ESI_QA_SUPERSET", "R4.21", "Sanity_Automation"],
                "aggregatetimeoriginalestimate": None,
                "summary": "Missing JSON for focused tile in 'more like this'",
                "issuetype": {
                    "name": "Bug",
                    "self": "https://jira.lgi.io/rest/api/2/issuetype/1",
                    "iconUrl": "https://jira.lgi.io/secure/viewavatar?size=xsmall&avatarId=12093&avatarType=issuetype",
                    "subtask": False,
                    "avatarId": 12093,
                    "id": "1",
                    "description": "A problem which impairs or prevents the functions of the product."
                },
                "issuelinks": [{
                        "self": "https://jira.lgi.io/rest/api/2/issueLink/1751391",
                        "outwardIssue": {
                            "fields": {
                                "status": {
                                    "statusCategory": {
                                        "name": "Done",
                                        "self": "https://jira.lgi.io/rest/api/2/statuscategory/3",
                                        "id": 3,
                                        "key": "done",
                                        "colorName": "green"
                                    },
                                    "description": "",
                                    "self": "https://jira.lgi.io/rest/api/2/status/10048",
                                    "iconUrl": "https://jira.lgi.io/images/icons/statuses/generic.png",
                                    "id": "10048",
                                    "name": "Done"
                                },
                                "priority": {
                                    "iconUrl": "https://jira.lgi.io/images/icons/priorities/major.svg",
                                    "self": "https://jira.lgi.io/rest/api/2/priority/3",
                                    "name": "Major (P2)",
                                    "id": "3"
                                },
                                "issuetype": {
                                    "name": "Test",
                                    "self": "https://jira.lgi.io/rest/api/2/issuetype/10202",
                                    "iconUrl": "https://jira.lgi.io/secure/viewavatar?size=xsmall&avatarId=38810&avatarType=issuetype",
                                    "subtask": False,
                                    "avatarId": 38810,
                                    "id": "10202",
                                    "description": "This JIRA Issue Type is used to create Zephyr Tests."
                                },
                                "summary": "VOD - Verify trailer"
                            },
                            "self": "https://jira.lgi.io/rest/api/2/issue/624790",
                            "id": "624790",
                            "key": "HES-1126"
                        },
                        "type": {
                            "outward": "blocks",
                            "inward": "is blocked by",
                            "self": "https://jira.lgi.io/rest/api/2/issueLinkType/10970",
                            "id": "10970",
                            "name": "Blocking"
                        },
                        "id": "1751391"
                    }, {
                        "self": "https://jira.lgi.io/rest/api/2/issueLink/1751368",
                        "outwardIssue": {
                            "fields": {
                                "status": {
                                    "statusCategory": {
                                        "name": "Done",
                                        "self": "https://jira.lgi.io/rest/api/2/statuscategory/3",
                                        "id": 3,
                                        "key": "done",
                                        "colorName": "green"
                                    },
                                    "description": "",
                                    "self": "https://jira.lgi.io/rest/api/2/status/10048",
                                    "iconUrl": "https://jira.lgi.io/images/icons/statuses/generic.png",
                                    "id": "10048",
                                    "name": "Done"
                                },
                                "priority": {
                                    "iconUrl": "https://jira.lgi.io/images/icons/priorities/minor.svg",
                                    "self": "https://jira.lgi.io/rest/api/2/priority/4",
                                    "name": "Minor (P3)",
                                    "id": "4"
                                },
                                "issuetype": {
                                    "name": "Test",
                                    "self": "https://jira.lgi.io/rest/api/2/issuetype/10202",
                                    "iconUrl": "https://jira.lgi.io/secure/viewavatar?size=xsmall&avatarId=38810&avatarType=issuetype",
                                    "subtask": False,
                                    "avatarId": 38810,
                                    "id": "10202",
                                    "description": "This JIRA Issue Type is used to create Zephyr Tests."
                                },
                                "summary": "LTV Recommendation"
                            },
                            "self": "https://jira.lgi.io/rest/api/2/issue/562257",
                            "id": "562257",
                            "key": "HES-477"
                        },
                        "type": {
                            "outward": "blocks",
                            "inward": "is blocked by",
                            "self": "https://jira.lgi.io/rest/api/2/issueLinkType/10970",
                            "id": "10970",
                            "name": "Blocking"
                        },
                        "id": "1751368"
                    }, {
                        "self": "https://jira.lgi.io/rest/api/2/issueLink/1751370",
                        "outwardIssue": {
                            "fields": {
                                "status": {
                                    "statusCategory": {
                                        "name": "Done",
                                        "self": "https://jira.lgi.io/rest/api/2/statuscategory/3",
                                        "id": 3,
                                        "key": "done",
                                        "colorName": "green"
                                    },
                                    "description": "",
                                    "self": "https://jira.lgi.io/rest/api/2/status/10048",
                                    "iconUrl": "https://jira.lgi.io/images/icons/statuses/generic.png",
                                    "id": "10048",
                                    "name": "Done"
                                },
                                "priority": {
                                    "iconUrl": "https://jira.lgi.io/images/icons/priorities/minor.svg",
                                    "self": "https://jira.lgi.io/rest/api/2/priority/4",
                                    "name": "Minor (P3)",
                                    "id": "4"
                                },
                                "issuetype": {
                                    "name": "Test",
                                    "self": "https://jira.lgi.io/rest/api/2/issuetype/10202",
                                    "iconUrl": "https://jira.lgi.io/secure/viewavatar?size=xsmall&avatarId=38810&avatarType=issuetype",
                                    "subtask": False,
                                    "avatarId": 38810,
                                    "id": "10202",
                                    "description": "This JIRA Issue Type is used to create Zephyr Tests."
                                },
                                "summary": "VOD Recommendation"
                            },
                            "self": "https://jira.lgi.io/rest/api/2/issue/562258",
                            "id": "562258",
                            "key": "HES-478"
                        },
                        "type": {
                            "outward": "blocks",
                            "inward": "is blocked by",
                            "self": "https://jira.lgi.io/rest/api/2/issueLinkType/10970",
                            "id": "10970",
                            "name": "Blocking"
                        },
                        "id": "1751370"
                    }, {
                        "self": "https://jira.lgi.io/rest/api/2/issueLink/1751369",
                        "outwardIssue": {
                            "fields": {
                                "status": {
                                    "statusCategory": {
                                        "name": "Done",
                                        "self": "https://jira.lgi.io/rest/api/2/statuscategory/3",
                                        "id": 3,
                                        "key": "done",
                                        "colorName": "green"
                                    },
                                    "description": "",
                                    "self": "https://jira.lgi.io/rest/api/2/status/10048",
                                    "iconUrl": "https://jira.lgi.io/images/icons/statuses/generic.png",
                                    "id": "10048",
                                    "name": "Done"
                                },
                                "priority": {
                                    "iconUrl": "https://jira.lgi.io/images/icons/priorities/minor.svg",
                                    "self": "https://jira.lgi.io/rest/api/2/priority/4",
                                    "name": "Minor (P3)",
                                    "id": "4"
                                },
                                "issuetype": {
                                    "name": "Test",
                                    "self": "https://jira.lgi.io/rest/api/2/issuetype/10202",
                                    "iconUrl": "https://jira.lgi.io/secure/viewavatar?size=xsmall&avatarId=38810&avatarType=issuetype",
                                    "subtask": False,
                                    "avatarId": 38810,
                                    "id": "10202",
                                    "description": "This JIRA Issue Type is used to create Zephyr Tests."
                                },
                                "summary": "REC Recommendation"
                            },
                            "self": "https://jira.lgi.io/rest/api/2/issue/562259",
                            "id": "562259",
                            "key": "HES-479"
                        },
                        "type": {
                            "outward": "blocks",
                            "inward": "is blocked by",
                            "self": "https://jira.lgi.io/rest/api/2/issueLinkType/10970",
                            "id": "10970",
                            "name": "Blocking"
                        },
                        "id": "1751369"
                    }
                ],
                "progress": {
                    "progress": 0,
                    "total": 0
                },
                "aggregateprogress": {
                    "progress": 0,
                    "total": 0
                },
                "aggregatetimespent": None,
                "aggregatetimeestimate": None,
                "project": {
                    "self": "https://jira.lgi.io/rest/api/2/project/17161",
                    "id": "17161",
                    "key": "HES",
                    "name": "HZN4 E2E SI"
                },
                "status": {
                    "statusCategory": {
                        "name": "To Do",
                        "self": "https://jira.lgi.io/rest/api/2/statuscategory/2",
                        "id": 2,
                        "key": "new",
                        "colorName": "blue-gray"
                    },
                    "description": "",
                    "self": "https://jira.lgi.io/rest/api/2/status/11083",
                    "iconUrl": "https://jira.lgi.io/images/icons/statuses/generic.png",
                    "id": "11083",
                    "name": "Draft"
                },
                "timeoriginalestimate": None,
                "components": [],
                "assignee": {
                    "displayName": "David Wright",
                    "name": "dwright",
                    "self": "https://jira.lgi.io/rest/api/2/user?username=dwright",
                    "emailAddress": "dwright@libertyglobal.com",
                    "key": "dwright",
                    "active": True,
                    "timeZone": "Europe/Amsterdam"
                },
                "subtasks": [],
                "versions": [{
                        "archived": False,
                        "name": "R4.21",
                        "self": "https://jira.lgi.io/rest/api/2/version/75098",
                        "released": False,
                        "id": "75098",
                        "description": ""
                    }
                ],
                "resolutiondate": None,
                "watches": {
                    "self": "https://jira.lgi.io/rest/api/2/issue/HES-11448/watchers",
                    "watchCount": 13,
                    "isWatching": False
                },
                "resolution": None
            },
            "self": "https://jira.lgi.io/rest/api/2/issue/1251084",
            "id": 1251084,
            "expand": "operations,versionedRepresentations,editmeta,changelog,renderedFields"
        }, {
            "key": "HES-11266",
            "fields": {
                "environment": None,
                "timespent": None,
                "updated": "2019-12-10T08:46:35.000+0000",
                "lastViewed": None,
                "timeestimate": None,
                "reporter": {
                    "displayName": "Aiswariya Byju (infosys)",
                    "name": "aiswariya.b",
                    "self": "https://jira.lgi.io/rest/api/2/user?username=aiswariya.b",
                    "emailAddress": "abyju.contractor@libertyglobal.com",
                    "key": "aiswariya.b",
                    "active": True,
                    "timeZone": "Europe/Amsterdam"
                },
                "votes": {
                    "hasVoted": False,
                    "self": "https://jira.lgi.io/rest/api/2/issue/HES-11266/votes",
                    "votes": 0
                },
                "description": "<div style=\"-webkit-text-stroke-width:0px; text-align:start; text-indent:0px\">\r\n<p><span style=\"color:#000000\"><span style=\"font-size:16px\"><span style=\"font-family:&quot;Times New Roman&quot;\"><span style=\"font-style:normal\"><span style=\"font-variant-ligatures:normal\"><span style=\"font-variant-caps:normal\"><span style=\"font-weight:400\"><span style=\"letter-spacing:normal\"><span style=\"orphans:2\"><span style=\"text-transform:none\"><span style=\"white-space:normal\"><span style=\"widows:2\"><span style=\"word-spacing:0px\"><span style=\"text-decoration-style:initial\"><span style=\"text-decoration-color:initial\"><span style=\"font-size:12pt\"><span style=\"font-family:&quot;Times New Roman&quot;,serif\"><span style=\"font-size:10pt\"><span style=\"font-family:Tahoma,sans-serif\"><u>Description</u> :<br>\r\nThe button \"Browse all available channels\" is not as per other tenants and it comes with a \".\"</span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span><br>\r\n<br>\r\n<u>Environment Details</u> :<br>\r\nCPE BUILD: EOS1008C-mon-ops-00.02-076-fi-AL-20191007101917-na001<br>\r\nCPE VERSION: 076-fi<br>\r\nReproducibility : Always<br>\r\nLAB : PROD</span><br>\r\n&nbsp;</p>\r\n</div>\r\n\r\n<div style=\"-webkit-text-stroke-width:0px; text-align:start; text-indent:0px\">\r\n<p><span style=\"color:#000000\"><span style=\"font-size:16px\"><span style=\"font-family:&quot;Times New Roman&quot;\"><span style=\"font-style:normal\"><span style=\"font-variant-ligatures:normal\"><span style=\"font-variant-caps:normal\"><span style=\"font-weight:400\"><span style=\"letter-spacing:normal\"><span style=\"orphans:2\"><span style=\"text-transform:none\"><span style=\"white-space:normal\"><span style=\"widows:2\"><span style=\"word-spacing:0px\"><span style=\"text-decoration-style:initial\"><span style=\"text-decoration-color:initial\"><span style=\"font-size:12pt\"><span style=\"font-family:&quot;Times New Roman&quot;,serif\"><span style=\"font-size:10pt\"><span style=\"font-family:Tahoma,sans-serif\"><u>Scenario to reproduce </u>:&nbsp;&nbsp;<br>\r\nPrecondition :&nbsp;</span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span>&nbsp;CPE should be up and running and box language should be English.&nbsp; Box should have a custom profile with few channels added to personal line up.</span></p>\r\n</div>\r\n\r\n<div style=\"-webkit-text-stroke-width:0px; text-align:start; text-indent:0px\">\r\n<ol start=\"1\" style=\"list-style-type:decimal\" type=\"1\">\r\n\t<li style=\"font-size:12pt; font-family:&quot;Times New Roman&quot;, serif; color:black; margin-bottom:0px\"><span style=\"color:#000000\"><span style=\"font-size:16px\"><span style=\"font-family:&quot;Times New Roman&quot;\"><span style=\"font-style:normal\"><span style=\"font-variant-ligatures:normal\"><span style=\"font-variant-caps:normal\"><span style=\"font-weight:400\"><span style=\"letter-spacing:normal\"><span style=\"orphans:2\"><span style=\"text-transform:none\"><span style=\"white-space:normal\"><span style=\"widows:2\"><span style=\"word-spacing:0px\"><span style=\"text-decoration-style:initial\"><span style=\"text-decoration-color:initial\"><span style=\"font-size:10pt\"><span style=\"font-family:Tahoma,sans-serif\">Launch TV Guide</span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></li>\r\n\t<li style=\"font-size:12pt; font-family:&quot;Times New Roman&quot;, serif; color:black; margin-bottom:0px\"><span style=\"color:#000000\"><span style=\"font-size:16px\"><span style=\"font-family:&quot;Times New Roman&quot;\"><span style=\"font-style:normal\"><span style=\"font-variant-ligatures:normal\"><span style=\"font-variant-caps:normal\"><span style=\"font-weight:400\"><span style=\"letter-spacing:normal\"><span style=\"orphans:2\"><span style=\"text-transform:none\"><span style=\"white-space:normal\"><span style=\"widows:2\"><span style=\"word-spacing:0px\"><span style=\"text-decoration-style:initial\"><span style=\"text-decoration-color:initial\"><span style=\"font-size:10pt\"><span style=\"font-family:Tahoma,sans-serif\">Press CONTEXT key.</span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></li>\r\n\t<li style=\"font-size:12pt; font-family:&quot;Times New Roman&quot;, serif; color:black; margin-bottom:0px\"><span style=\"color:#000000\"><span style=\"font-size:16px\"><span style=\"font-family:&quot;Times New Roman&quot;\"><span style=\"font-style:normal\"><span style=\"font-variant-ligatures:normal\"><span style=\"font-variant-caps:normal\"><span style=\"font-weight:400\"><span style=\"letter-spacing:normal\"><span style=\"orphans:2\"><span style=\"text-transform:none\"><span style=\"white-space:normal\"><span style=\"widows:2\"><span style=\"word-spacing:0px\"><span style=\"text-decoration-style:initial\"><span style=\"text-decoration-color:initial\"><span style=\"font-size:10pt\"><span style=\"font-family:Tahoma,sans-serif\">Validate the Pop up Button - Browse all available channels</span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></li>\r\n</ol>\r\n\r\n<p style=\"color:black; font-family:&quot;Times New Roman&quot;,serif; font-size:12pt; margin-bottom:0px\"><span style=\"color:#000000\"><span style=\"font-size:16px\"><span style=\"font-family:&quot;Times New Roman&quot;\"><span style=\"font-style:normal\"><span style=\"font-variant-ligatures:normal\"><span style=\"font-variant-caps:normal\"><span style=\"font-weight:400\"><span style=\"letter-spacing:normal\"><span style=\"orphans:2\"><span style=\"text-transform:none\"><span style=\"white-space:normal\"><span style=\"widows:2\"><span style=\"word-spacing:0px\"><span style=\"text-decoration-style:initial\"><span style=\"text-decoration-color:initial\"><span style=\"font-size:10pt\"><span style=\"font-family:Tahoma,sans-serif\"><u>Actual Result</u> :&nbsp;</span></span><span style=\"font-size:12pt\"><span style=\"font-family:&quot;Times New Roman&quot;,serif\"><span style=\"font-size:10pt\"><span style=\"font-family:Tahoma,sans-serif\">Browse all available channels option is having a '.' at the end</span></span></span></span><br>\r\n<span style=\"font-size:10pt\"><span style=\"font-family:Tahoma,sans-serif\"><u>Expected Result </u>:&nbsp;</span></span><span style=\"font-size:12pt\"><span style=\"font-family:&quot;Times New Roman&quot;,serif\"><span style=\"font-size:10pt\"><span style=\"font-family:Tahoma,sans-serif\">Browse all available channels should be unique across all tenants</span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span> <img alt=\"\" src=\"Browse available channels\"></span></p>\r\n</div>\r\n",
                "duedate": None,
                "created": "2019-11-19T13:02:05.000+0000",
                "creator": {
                    "displayName": "Aiswariya Byju (infosys)",
                    "name": "aiswariya.b",
                    "self": "https://jira.lgi.io/rest/api/2/user?username=aiswariya.b",
                    "emailAddress": "abyju.contractor@libertyglobal.com",
                    "key": "aiswariya.b",
                    "active": True,
                    "timeZone": "Europe/Amsterdam"
                },
                "priority": {
                    "iconUrl": "https://jira.lgi.io/images/icons/priorities/minor.svg",
                    "self": "https://jira.lgi.io/rest/api/2/priority/4",
                    "name": "Minor (P3)",
                    "id": "4"
                },
                "workratio": -1,
                "fixVersions": [],
                "labels": ["E2ESI_QA_AT_PROD", "R4.20", "Sanity_Automation"],
                "aggregatetimeoriginalestimate": None,
                "summary": "[AT PROD] 'Browse all available channels' option in TV Guide have an additional '.' at the end in AT tenant",
                "issuetype": {
                    "name": "Bug",
                    "self": "https://jira.lgi.io/rest/api/2/issuetype/1",
                    "iconUrl": "https://jira.lgi.io/secure/viewavatar?size=xsmall&avatarId=12093&avatarType=issuetype",
                    "subtask": False,
                    "avatarId": 12093,
                    "id": "1",
                    "description": "A problem which impairs or prevents the functions of the product."
                },
                "issuelinks": [{
                        "self": "https://jira.lgi.io/rest/api/2/issueLink/1729553",
                        "outwardIssue": {
                            "fields": {
                                "status": {
                                    "statusCategory": {
                                        "name": "Done",
                                        "self": "https://jira.lgi.io/rest/api/2/statuscategory/3",
                                        "id": 3,
                                        "key": "done",
                                        "colorName": "green"
                                    },
                                    "description": "",
                                    "self": "https://jira.lgi.io/rest/api/2/status/10048",
                                    "iconUrl": "https://jira.lgi.io/images/icons/statuses/generic.png",
                                    "id": "10048",
                                    "name": "Done"
                                },
                                "priority": {
                                    "iconUrl": "https://jira.lgi.io/images/icons/priorities/major.svg",
                                    "self": "https://jira.lgi.io/rest/api/2/priority/3",
                                    "name": "Major (P2)",
                                    "id": "3"
                                },
                                "issuetype": {
                                    "name": "Test",
                                    "self": "https://jira.lgi.io/rest/api/2/issuetype/10202",
                                    "iconUrl": "https://jira.lgi.io/secure/viewavatar?size=xsmall&avatarId=38810&avatarType=issuetype",
                                    "subtask": False,
                                    "avatarId": 38810,
                                    "id": "10202",
                                    "description": "This JIRA Issue Type is used to create Zephyr Tests."
                                },
                                "summary": "Profiles - Favorite channels - Temporary channels - Add to line-up"
                            },
                            "self": "https://jira.lgi.io/rest/api/2/issue/769272",
                            "id": "769272",
                            "key": "HES-2888"
                        },
                        "type": {
                            "outward": "blocks",
                            "inward": "is blocked by",
                            "self": "https://jira.lgi.io/rest/api/2/issueLinkType/10970",
                            "id": "10970",
                            "name": "Blocking"
                        },
                        "id": "1729553"
                    }
                ],
                "progress": {
                    "progress": 0,
                    "total": 0
                },
                "aggregateprogress": {
                    "progress": 0,
                    "total": 0
                },
                "aggregatetimespent": None,
                "aggregatetimeestimate": None,
                "project": {
                    "self": "https://jira.lgi.io/rest/api/2/project/17161",
                    "avatarUrls": {
                        "24x24": "https://jira.lgi.io/secure/projectavatar?size=small&pid=17161&avatarId=35797",
                        "32x32": "https://jira.lgi.io/secure/projectavatar?size=medium&pid=17161&avatarId=35797",
                        "48x48": "https://jira.lgi.io/secure/projectavatar?pid=17161&avatarId=35797",
                        "16x16": "https://jira.lgi.io/secure/projectavatar?size=xsmall&pid=17161&avatarId=35797"
                    },
                    "id": "17161",
                    "key": "HES",
                    "name": "HZN4 E2E SI"
                },
                "status": {
                    "statusCategory": {
                        "name": "To Do",
                        "self": "https://jira.lgi.io/rest/api/2/statuscategory/2",
                        "id": 2,
                        "key": "new",
                        "colorName": "blue-gray"
                    },
                    "description": "",
                    "self": "https://jira.lgi.io/rest/api/2/status/11083",
                    "iconUrl": "https://jira.lgi.io/images/icons/statuses/generic.png",
                    "id": "11083",
                    "name": "Draft"
                },
                "timeoriginalestimate": None,
                "components": [{
                        "self": "https://jira.lgi.io/rest/api/2/component/24680",
                        "id": "24680",
                        "name": "CPE"
                    }, {
                        "self": "https://jira.lgi.io/rest/api/2/component/46938",
                        "id": "46938",
                        "name": "Personalization Service"
                    }
                ],
                "assignee": {
                    "displayName": "Praveen Rao",
                    "name": "Praveen_S17",
                    "self": "https://jira.lgi.io/rest/api/2/user?username=Praveen_S17",
                    "avatarUrls": {
                        "24x24": "https://www.gravatar.com/avatar/52f8bc24b377cf27540cca8bf357c2a6?d=mm&s=24",
                        "32x32": "https://www.gravatar.com/avatar/52f8bc24b377cf27540cca8bf357c2a6?d=mm&s=32",
                        "48x48": "https://www.gravatar.com/avatar/52f8bc24b377cf27540cca8bf357c2a6?d=mm&s=48",
                        "16x16": "https://www.gravatar.com/avatar/52f8bc24b377cf27540cca8bf357c2a6?d=mm&s=16"
                    },
                    "emailAddress": "pasrao.contractor@libertyglobal.com",
                    "key": "praveen_s17",
                    "active": True,
                    "timeZone": "Europe/Amsterdam"
                },
                "subtasks": [],
                "versions": [{
                        "released": False,
                        "self": "https://jira.lgi.io/rest/api/2/version/71902",
                        "archived": False,
                        "id": "71902",
                        "name": "4.20"
                    }
                ],
                "resolutiondate": None,
                "watches": {
                    "self": "https://jira.lgi.io/rest/api/2/issue/HES-11266/watchers",
                    "watchCount": 2,
                    "isWatching": False
                },
                "resolution": None
            },
            "self": "https://jira.lgi.io/rest/api/2/issue/1239519",
            "id": "1239519",
            "expand": "operations,versionedRepresentations,editmeta,changelog,renderedFields"
        }
    ],
    "total": 12,
    "startAt": 0,
    "maxResults": 50,
    "expand": "schema,names"
}

TICKET_TO_SEARCH = "HES-478"

LINKED_TICKETS_DICT = {
    'Bug': {
        'HES-106': {
            'jira': 'HES-106',
            'status': 'Draft',
            'project': 'HES',
            'reporter': 'Aiswariya Byju (infosys)',
            'url': 'https://jira.lgi.io/browse/HES-106',
            'labels': ['E2ESI_PROD', 'R4.XX', 'TESTAutomation'],
            'summary': '[AT PROD] Browse all available channels option in TV Guide have an additional . at the end in AT tenant',
            'priority': 'Minor (P3)',
            'assignee': 'Praveen Rao',
            'type': 'Bug',
            'linked': {
                'blocking': {
                    'HES-2888': {
                        'status': 'Done',
                        'priority': 'Major (P2)',
                        'summary': 'Profiles - Favorite channels - Temporary channels - Add to line-up'
                    }
                }
            }
        },
        'HES-11448': {
            'jira': 'HES-11448',
            'status': 'Draft',
            'project': 'HES',
            'reporter': 'Anuj Teotia',
            'url': 'https://jira.lgi.io/browse/HES-11448',
            'labels': ['E2ESI_QA_E2ESUPERSET_LAB', 'E2ESI_QA_LAB', 'E2ESI_QA_PREPROD', 'E2ESI_QA_PROD', 'E2ESI_QA_SUPERSET', 'R4.21', 'Sanity_Automation'],
            'summary': 'Missing JSON for focused tile in more like this',
            'priority': 'Major (P2)',
            'assignee': 'David Wright',
            'type': 'Bug',
            'linked': {
                'blocking': {
                    'HES-479': {
                        'status': 'Done',
                        'priority': 'Minor (P3)',
                        'summary': 'REC Recommendation'
                    },
                    'HES-478': {
                        'status': 'Done',
                        'priority': 'Minor (P3)',
                        'summary': 'VOD Recommendation'
                    },
                    'HES-1126': {
                        'status': 'Done',
                        'priority': 'Major (P2)',
                        'summary': 'VOD - Verify trailer'
                    },
                    'HES-477': {
                        'status': 'Done',
                        'priority': 'Minor (P3)',
                        'summary': 'LTV Recommendation'
                    }
                }
            }
        },
        'HES-11266': {
            'jira': 'HES-11266',
            'status': 'Draft',
            'project': 'HES',
            'reporter': 'Aiswariya Byju (infosys)',
            'url': 'https://jira.lgi.io/browse/HES-11266',
            'labels': ['E2ESI_QA_AT_PROD', 'R4.20', 'Sanity_Automation'],
            'summary': '[AT PROD] Browse all available channels option in TV Guide have an additional . at the end in AT tenant',
            'priority': 'Minor (P3)',
            'assignee': 'Praveen Rao',
            'type': 'Bug',
            'linked': {
                'blocking': {
                    'HES-2888': {
                        'status': 'Done',
                        'priority': 'Major (P2)',
                        'summary': 'Profiles - Favorite channels - Temporary channels - Add to line-up'
                    }
                }
            }
        }
    }
}

TICKET_LINKED_DICT = {
    'HES-478': {
        'status': 'Done',
        'priority': 'Minor (P3)',
        'linked': {
            'HES-11448': {
                'jira': 'HES-11448',
                'status': 'Draft',
                'project': 'HES',
                'reporter': 'Anuj Teotia',
                'url': 'https://jira.lgi.io/browse/HES-11448',
                'labels': ['E2ESI_QA_E2ESUPERSET_LAB', 'E2ESI_QA_LAB', 'E2ESI_QA_PREPROD', 'E2ESI_QA_PROD', 'E2ESI_QA_SUPERSET', 'R4.21', 'Sanity_Automation'],
                'summary': 'Missing JSON for focused tile in more like this',
                'priority': 'Major (P2)',
                'assignee': 'David Wright',
                'type': 'Bug'
            }
        }
    }
}

########## MORE ####################################
JIRA_DATA = {
    'HES-121': {
        'status': 'Done',
        'priority': 'Minor (P3)',
        'linked': {
            'HES-11120': {
                'jira': 'HES-11120',
                'status': 'Draft',
                'reporter': 'Vivek Mishra',
                'url': 'https://jira.lgi.io/browse/HES-11120',
                'labels': ['R4.20', 'Sanity_Automation', "E2ESI_QA_SUPERSET", "E2ESI_QA_LAB"],
                'summary': '[CH PROD]Because you have watched recommendation '
                           'is missing for watched VOD assets ',
                'project': 'HES',
                'assignee': 'Praveen Rao',
                'type': 'Bug',
                'priority': 'Minor (P3)'
            }
        }
    }
}

SAMPLE_CLONE_LATEST_TEST_CYCLE = "54646"

SAMPLE_SET_TEST_CASE_EXECUTION_STATUS = {
    'comment': '',
    'createdBy': 'techentautomatedtest',
    'cycleName': 'AF Validation (auto created) from 2019-12-16 16:14',
    'isExecutionWorkflowEnabled': True,
    'executedOnVal': 1576509324554,
    'totalDefectCount': 0,
    'createdByUserName': 'techentautomatedtest',
    'id': 3994348,
    'issueId': 439282,
    'executionDefectCount': 0,
    'projectId': 17161,
    'label': 'Listings, TVA',
    'assignedTo': 'techentautomatedtest',
    'createdOnVal': 1576509318416,
    'executionStatus': '1',
    'modifiedBy': 'techentautomatedtest',
    'executedByDisplay': 'techentautomatedtest',
    'assigneeType': 'currentUser',
    'issueKey': 'HES-106',
    'orderId': 3327154,
    'htmlComment': '',
    'assignedToDisplay': 'techentautomatedtest',
    'issueDescription': '<p><font color="#ff0000"><b>WORK IN PROGRESS</b></font><br/>\nThe focus of this test, contrary to the standard EPG listings ingest, is on the smaller deltas (the smaller periodic schedule updates)</p>\n\n<p>This is an asynchronous process, defined in more detail in <a href="https://wikiprojects.upc.biz/display/HZN4/EPG+Schedule+TVA+Ingest" class="external-link" rel="nofollow">https://wikiprojects.upc.biz/display/HZN4/EPG+Schedule+TVA+Ingest</a>. It could take minutes or hours</p>\n\n<p>For ReplayTV, ProdIS sends schedule by means of the SeaChange 3D interface to the VSPP</p>\n\n<p>TODO: Focus on Black Scar episode: The STA (StagIS Transfer Agent) has had problems in the past when it was failing quietly due to overload. This led to no EPG for 2 weeks (Black Scar)</p>\n\n<p>In the staging server, the source configuration consists of two (S)FTP/Samba connections for EPG TVA xml <b>metadata</b> and EPG images</p>\n\n<p><a href="https://wikiprojects.upc.biz/display/HZN4/Tech-Note%3A+Ingesting+of+LTV+Metadata+in+legacy+and+OBO+platform" class="external-link" rel="nofollow">https://wikiprojects.upc.biz/display/HZN4/Tech-Note%3A+Ingesting+of+LTV+Metadata+in+legacy+and+OBO+platform</a></p>\n',
    'component': 'MAG, PPR, Prodis, RedBee, STA, StagingServer, Stagis',
    'isTimeTrackingEnabled': True,
    'createdByDisplay': 'techentautomatedtest',
    'versionId': 75098,
    'versionName': 'R4.21',
    'executedBy': 'techentautomatedtest',
    'totalExecutions': 3,
    'executionWorkflowStatus': None,
    'assignedToUserName': 'techentautomatedtest',
    'stepDefectCount': 0,
    'createdOn': '16/Dec/19 15:15',
    'executedOn': '16/Dec/19 15:15',
    'summary': 'EPG Listings ingest - Delta',
    'totalExecuted': 1,
    'isIssueEstimateNil': True,
    'executionSummaries': '{"executionSummary":[{"count":2,"statusKey":-1,"statusName":"SCHEDULED","statusColor":"#A0A0A0"},{"count":1,"statusKey":1,"statusName":"PASSED","statusColor":"#75B000"},{"count":0,"statusKey":2,"statusName":"FAILED","statusColor":"#CC3300"},{"count":0,"statusKey":3,"statusName":"WORK IN PROGRESS","statusColor":"#0000ff"},{"count":0,"statusKey":4,"statusName":"TEST SUSPENDED","statusColor":"#6693B0"},{"count":0,"statusKey":5,"statusName":"ACCEPTED FAILED","statusColor":"#ff9900"},{"count":0,"statusKey":6,"statusName":"NOT TESTED","statusColor":"#ffd700"},{"count":0,"statusKey":7,"statusName":"BLOCKED","statusColor":"#ff6600"},{"count":0,"statusKey":8,"statusName":"N/A","statusColor":"#eeeeee"},{"count":0,"statusKey":9,"statusName":"DEPRECATED","statusColor":"#000000"},{"count":0,"statusKey":10,"statusName":"PASSED WITH REMARKS","statusColor":"#ccff00"},{"count":0,"statusKey":11,"statusName":"RESULT NEEDS DISCUSSION","statusColor":"#cc0099"},{"count":0,"statusKey":12,"statusName":"TEST NEEDS REWORK","statusColor":"#ffff33"},{"count":0,"statusKey":13,"statusName":"AUTOMATION FAILED","statusColor":"#ff3333"},{"count":0,"statusKey":14,"statusName":"MOCK DATA PASSED","statusColor":"#00cc00"},{"count":0,"statusKey":15,"statusName":"MOCK DATA FAILED","statusColor":"#ff3333"}]}',
    'projectKey': 'HES',
    'cycleId': 54643,
    'canViewIssue': True
}

SAMPLE_GET_TEST_CYCLES = {
    '54646': {
        'startDate': '16/Dec/19',
        'endDate': '17/Dec/19',
        'versionName': 'R4.21',
        'ended': 'false',
        'totalDefects': 0,
        'projectId': 17161,
        'isExecutionWorkflowEnabledForProject': True,
        'environment': 'Country Specific Integration (Superset)',
        'modifiedBy': 'techentautomatedtest',
        'build': 'AIRFLOW 2.03',
        'totalExecutions': 0,
        'executionSummaries': {
            'executionSummary': []
        },
        'projectKey': 'HES',
        'description': '',
        'started': 'false',
        'isTimeTrackingEnabled': True,
        'createdByDisplay': 'techentautomatedtest',
        'versionId': 75098,
        'createdBy': 'techentautomatedtest',
        'createdDate': '2019-12-16 15:28:14.72',
        'expand': 'executionSummaries',
        'name': 'AF Validation (auto created) from 2019-12-16 16:27',
        'totalFolders': 0,
        'totalExecuted': 0,
        'totalCycleExecutions': 0
    },
    '53835': {
        'startDate': '',
        'endDate': '',
        'versionName': 'R4.21',
        'ended': '',
        'totalDefects': 0,
        'projectId': 17161,
        'isExecutionWorkflowEnabledForProject': True,
        'environment': 'CH Prod',
        'modifiedBy': 'nkumar',
        'build': 'R4.21',
        'totalExecutions': 0,
        'executionSummaries': {
            'executionSummary': []
        },
        'projectKey': 'HES',
        'description': 'Test Cycle for R4.21 ACS validation in CH Prod',
        'started': '',
        'isTimeTrackingEnabled': True,
        'createdByDisplay': 'Nitesh Kumar',
        'versionId': 75098,
        'createdBy': 'nkumar',
        'createdDate': '2019-11-28 02:35:50.565',
        'expand': 'executionSummaries',
        'name': 'CH Prod R4.21 ACS Validation',
        'totalFolders': 0,
        'totalExecuted': 0,
        'totalCycleExecutions': 17
    }
}

SAMPLE_CREATE_TEST_CYCLE = {'jobProgressToken': '0001576510337249-200d5251828-0001'}

SAMPLE_GET_ALL_PROJECTS = {
    "options": [{
            "label": "CONNCH_TEST",
            "type": "business",
            "hasAccessToSoftware": "true",
            "value": "30650"
        }, {
            "label": "Efficiency Taskforce",
            "type": "software",
            "hasAccessToSoftware": "true",
            "value": "23850"
        }, {
            "label": "Horizon 4 UK E2ESI",
            "type": "software",
            "hasAccessToSoftware": "true",
            "value": "22153"
        }, {
            "label": "HZN4 E2E SI",
            "type": "software",
            "hasAccessToSoftware": "true",
            "value": "17161"
        }, {
            "label": "HZN4: Platform Delivery",
            "type": "software",
            "hasAccessToSoftware": "true",
            "value": "14954"
        }, {
            "label": "HZN4: SI",
            "type": "software",
            "hasAccessToSoftware": "true",
            "value": "15758"
        }, {
            "label": "ITC Service Desk",
            "type": "service_desk",
            "hasAccessToSoftware": "true",
            "value": "27251"
        }, {
            "label": "Jira Basics Sandbox",
            "type": "software",
            "hasAccessToSoftware": "true",
            "value": "19251"
        }, {
            "label": "Jira Wiki Requests",
            "type": "software",
            "hasAccessToSoftware": "true",
            "value": "11056"
        }, {
            "label": "LGI T&I Atlassian Tools Support",
            "type": "software",
            "hasAccessToSoftware": "true",
            "value": "28451"
        }, {
            "label": "LGOP ARCHIVE",
            "type": "software",
            "hasAccessToSoftware": "true",
            "value": "27676"
        }, {
            "label": "Mobile Demand and Change Management",
            "type": "software",
            "hasAccessToSoftware": "true",
            "value": "13856"
        }, {
            "label": "OMNI Babylon RCU",
            "type": "software",
            "hasAccessToSoftware": "true",
            "value": "29651"
        }, {
            "label": "One Middleware Humax EOS-V2 Internal",
            "type": "software",
            "hasAccessToSoftware": "true",
            "value": "30852"
        }, {
            "label": "One Middleware Humax EOS-V2 platform defects",
            "type": "software",
            "hasAccessToSoftware": "true",
            "value": "30751"
        }, {
            "label": "Operational Data Hub Platform",
            "type": "software",
            "hasAccessToSoftware": "true",
            "value": "17952"
        }, {
            "label": "Operations Dashboard",
            "type": "software",
            "hasAccessToSoftware": "true",
            "value": "12262"
        }, {
            "label": "Service Delivery Monitoring Architecture",
            "type": "software",
            "hasAccessToSoftware": "true",
            "value": "20652"
        }, {
            "label": "SNDBXCAP",
            "type": "software",
            "hasAccessToSoftware": "true",
            "value": "31055"
        }, {
            "label": "SPARK Project",
            "type": "software",
            "hasAccessToSoftware": "true",
            "value": "15755"
        }, {
            "label": "TEDH Support",
            "type": "software",
            "hasAccessToSoftware": "true",
            "value": "30851"
        }, {
            "label": "TT_34_TEST",
            "type": "software",
            "hasAccessToSoftware": "true",
            "value": "24850"
        }
    ]
}


SAMPLE_GET_ISSUE_KEY_BY_ID = "HES-106"

SAMPLE_GET_ISSUE_ID_BY_KEY = "439282"

SET_TEST_CASE_EXECUTION_ISSUE_KEY = SAMPLE_GET_ISSUE_ID_BY_KEY

SAMPLE_GET_ISSUE_EXECUTION_QUERY = {'executions': [{'id': '399450'}]}

SAMPLE_GET_ISSUE_EXECUTION_ID = "399450"

SAMPLE_GET_ALL_VERSIONS = {
    'hasAccessToSoftware': 'true',
    'type': 'software',
    'releasedVersions': [{
            'archived': False,
            'value': '59280',
            'label': 'R4.14'
        }, {
            'archived': False,
            'value': '52584',
            'label': 'XG-4.13'
        }
    ],
    'unreleasedVersions': [{
            'archived': False,
            'value': '71902',
            'label': '4.20'
        }, {
            'archived': False,
            'value': '75098',
            'label': 'R4.21'
        }, {
            'archived': False,
            'value': '75099',
            'label': 'R4.22'
        }, {
            'archived': False,
            'value': '75100',
            'label': 'R4.23'
        }
    ]
}


SAMPLE_VERSION_ID = "75098"  #4.21 - {'archived': False,'value': '75098','label': 'R4.21'}

SAMPLE_EXECUTION_DATA_FROM_ID = {}

SAMPLE_GET_TEST_CYCLE_INFO = {
    'startDate': '16/Dec/19',
    'endDate': '17/Dec/19',
    'description': '',
    'projectId': 17161,
    'environment': 'Country Specific Integration (Superset)',
    'versionId': 75098,
    'createdBy': 'techentautomatedtest',
    'build': 'AIRFLOW 2.03',
    'versionName': 'R4.21',
    'createdDate': 1576509589655,
    'modifiedBy': 'techentautomatedtest',
    'sprintId': None,
    'id': 54644,
    'name': 'AF Validation (auto created) from 2019-12-16 16:19'
}

SAMPLE_GET_TEST_CYCLE_IDS = ['54646', '53835']


class TestCaseNameAsDescription(unittest.TestCase):
    """Class to display test name instead of docstrings when running tests."""

    def shortDescription(self):
        """Prevent replacing test names with docstrings."""
        return None


def mock_requests_get(*args, **kwargs):
    """A method imitates sending GET requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    url = args[0]
    # print("### DEBUG: MOCKA GET URL: %s ###" % url)
    if "%s/project/" % JIRA_API_HOST in url:
        response_text = SAMPLE_JIRA_PROJECT
        data = dict(json=mock.Mock(return_value=response_text), status_code=200, reason="OK")
    elif "%s/filter/%s" % (JIRA_API_HOST, FILTER_ID) in url:
        response_text = SAMPLE_JIRA_FILTER_ID
        data = dict(json=mock.Mock(return_value=response_text), status_code=200, reason="OK")
    elif "%s/search?jql=" % JIRA_API_HOST in url:
        response_text = SAMPLE_JIRA_SEARCH_JQL
        data = dict(json=mock.Mock(return_value=response_text), status_code=200, reason="OK")
    elif "%s/cycle/%s" % (ZEPHYR_API_HOST, SAMPLE_CLONE_LATEST_TEST_CYCLE) in url:
        response_text = SAMPLE_GET_TEST_CYCLE_INFO
        data = dict(json=mock.Mock(return_value=response_text), text=response_text,
                    status_code=200, reason="OK")
    elif "%s/cycle/%s" % (ZEPHYR_API_HOST, "None") in url:
        response_text = SAMPLE_GET_TEST_CYCLE_INFO
        data = dict(json=mock.Mock(return_value=response_text), text=response_text,
                    status_code=200, reason="OK")
    elif "%s/cycle?projectId=" % ZEPHYR_API_HOST in url:
        response_text = SAMPLE_GET_TEST_CYCLES
        data = dict(json=mock.Mock(return_value=response_text), text=response_text,
                    status_code=200, reason="OK")
    elif "%s/util/project-list" % ZEPHYR_API_HOST in url:
        response_text = SAMPLE_GET_ALL_PROJECTS
        data = dict(json=mock.Mock(return_value=response_text), text=response_text,
                    status_code=200, reason="OK")
    elif "%s/execution?issueId=" % ZEPHYR_API_HOST in url:
        response_text = SAMPLE_GET_ISSUE_EXECUTION_QUERY
        data = dict(json=mock.Mock(return_value=response_text), text=response_text,
                    status_code=200, reason="OK")
    elif "%s/util/versionBoard-list?projectId=" % ZEPHYR_API_HOST in url:
        response_text = SAMPLE_GET_ALL_VERSIONS
        data = dict(json=mock.Mock(return_value=response_text), text=response_text,
                    status_code=200, reason="OK")
    else:
        data = dict(json={}, text="", status_code=404, reason="Not Found")
    return type("", (), data)()


def mock_requests_post(*args, **kwargs):
    """A method imitates sending POST requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    url = args[0]
    data = kwargs["data"] if "data" in kwargs else None
    if url == "%s/execution/addTestsToCycle" % ZEPHYR_API_HOST and data:
        response_text = {}
        data = dict(json=mock.Mock(return_value=response_text), text=response_text,
                    status_code=200, reason="OK")
    elif "%s/cycle" % ZEPHYR_API_HOST in url:
        response_text = SAMPLE_CREATE_TEST_CYCLE
        data = dict(json=mock.Mock(return_value=response_text), text=response_text,
                    status_code=200, reason="OK")
    else:
        data = dict(json={}, text="", status_code=404, reason="Not Found")
    return type("", (), data)()


def mock_requests_put(*args, **kwargs):
    """A method imitates sending PUT requests to a server - it analyzes url,
    and returns predefined data (response text and status code).

    :return: an instance of the anonymous class representing response data.
    """
    url = args[0]
    data = kwargs["data"] if "data" in kwargs else None
    # https://jira.lgi.io/rest/zapi/latest/execution?issueId=629950
    if url == "%s/execution/%s/execute" % (ZEPHYR_API_HOST, EXECUTION_ID) and data:
        response_text = SAMPLE_SET_TEST_CASE_EXECUTION_STATUS
        data = dict(json=mock.Mock(return_value=response_text), text=response_text,
                    status_code=200, reason="OK")
    else:
        data = dict(json={}, text="", status_code=404, reason="Not Found")
    return type("", (), data)()


@mock.patch("requests.post", side_effect=mock_requests_post)
@mock.patch("requests.get", side_effect=mock_requests_get)
@mock.patch("requests.put", side_effect=mock_requests_put)
@mock.patch("os.path.exists", return_value=True)
@mock.patch.object(CaptureResultJson, "is_file_older_than_x_hours", return_value=True)
@mock.patch.object(CaptureResultJson, "save_json_to_file", return_value=True)
@mock.patch.object(CaptureResultJson, "read_json_from_file", return_value=SAMPLE_JIRA_SEARCH_JQL)
class TestKeyword_JiraGetter(TestCaseNameAsDescription):
    """Class contains unit tests of JiraGetter Class Keywords."""

    @classmethod
    @mock.patch("requests.get", side_effect=mock_requests_get)
    def setUpClass(cls, *args):
        cls.jiragetter = JiraGetter()
        cls.result = ""

    @classmethod
    def tearDownClass(cls):
        pass

    def test_get_project_info(self, *args):
        """ Check get_project_info() keyword works """
        self.result = self.jiragetter.get_project_info()
        self.assertEqual(self.result, SAMPLE_JIRA_PROJECT)

    def test_get_all_versions(self, *args):
        """ Check get_all_versions() keyword works """
        self.result = self.jiragetter.get_all_versions()
        self.assertEqual(self.result, SAMPLE_GET_ALL_VERSIONS)

    def test_get_version_id(self, *args):
        """ Check get_version_id() keyword works """
        self.result = self.jiragetter.get_version_id()
        self.assertEqual(self.result, SAMPLE_VERSION_ID)

    def test_get_filter_info(self, *args):
        """Check get_filter_info() keyword works: test run id is returned."""
        self.result = self.jiragetter.get_filter_info(FILTER_ID)
        self.assertEqual(self.result, SAMPLE_JIRA_FILTER_ID)

    def test_get_filter_search_url(self, *args):
        """Check get_filter_search_url() keyword works: test run id is returned."""
        self.result = self.jiragetter.get_filter_search_url(FILTER_ID)
        self.assertEqual(self.result, SAMPLE_JIRA_FILTER_ID_SEARCH_URL)

    def test_get_query_info_from_filter_id(self, *args):
        """Check get_query_info_from_filter_id() keyword works: JIRA_SEARCH_JQL is returned."""
        self.result = self.jiragetter.get_query_info_from_filter_id(FILTER_ID)
        self.assertEqual(self.result, SAMPLE_JIRA_SEARCH_JQL)

    def test_get_info_from_jql(self, *args):
        """Check get_info_from_jql() keyword works: JIRA_SEARCH_JQL is returned."""
        self.result = self.jiragetter.get_info_from_jql(JQL_SEARCH)
        self.assertEqual(self.result, SAMPLE_JIRA_SEARCH_JQL)

    def test_get_linked_tickets_dict_from_query_info(self, *args):
        """ Check get_linked_tickets_dict_from_query_info()
            keyword works: LINKED_TICKETS_DICT is returned.
        """
        self.result = self.jiragetter.get_linked_tickets_dict_from_query_info(
            SAMPLE_JIRA_SEARCH_JQL)
        self.assertEqual(self.result, LINKED_TICKETS_DICT)

    def test_get_linked_tickets_dict_from_filter_id(self, *args):
        """ Check get_linked_tickets_dict_from_filter_id() keyword works:
            LINKED_TICKETS_DICT is returned.
        """
        self.result = self.jiragetter.get_linked_tickets_dict_from_filter_id(FILTER_ID)
        self.assertEqual(self.result, LINKED_TICKETS_DICT)

    def test_get_linked_tickets_dict_for_one_from_all_tickets_info(self, *args):
        """ Check get_linked_tickets_dict_for_one_from_all_tickets_info() keyword works:
            TICKET_LINKED_DICT is returned.
        """
        self.result = self.jiragetter.get_linked_tickets_dict_for_one_from_all_tickets_info(
            LINKED_TICKETS_DICT, TICKET_TO_SEARCH)
        self.assertEqual(self.result, TICKET_LINKED_DICT)

    def test_get_and_save_data_file_with_all_linked_tickets_from_project_and_filter_id(self, *args):
        """ Check get_and_save_data_file_with_all_linked_tickets_from_project_and_filter_id()
            keyword works: True is returned.
        """
        self.result = \
            self.jiragetter.get_and_save_data_file_with_all_linked_tickets_from_project_and_filter_id(
                INIT["PROJECT_NAME"], FILTER_ID, 24)
        self.assertEqual(self.result, True)

    def test_get_and_save_data_file_with_all_linked_tickets_from_project(self, *args):
        """ Check get_and_save_data_file_with_all_linked_tickets_from_project() keyword works:
            True is returned.
        """
        self.result = \
            self.jiragetter.get_and_save_data_file_with_all_linked_tickets_from_project(
                INIT["PROJECT_NAME"], 24)
        self.assertEqual(self.result, True)

    def test_get_all_linked_tickets_from_data_file(self, *args):
        """ Check get_all_linked_tickets_from_data_file() keyword works:
            True is returned.
        """
        self.result = \
            self.jiragetter.get_all_linked_tickets_from_data_file(INIT["PROJECT_NAME"])
        self.assertEqual(self.result, LINKED_TICKETS_DICT)

    def test_get_test_cycles(self, *args):
        """ Check get_test_cycles() keyword works """
        self.result = self.jiragetter.get_test_cycles()
        self.assertEqual(self.result, SAMPLE_GET_TEST_CYCLES)

    def test_get_test_cycle_ids(self, *args):
        """ Check get_test_cycle_ids() keyword works """
        self.result = self.jiragetter.get_test_cycle_ids()
        self.assertEqual(self.result, SAMPLE_GET_TEST_CYCLE_IDS)

    def test_get_test_cycle_id(self, *args):
        """ Check get_test_cycle_id() keyword works """
        self.result = self.jiragetter.get_test_cycle_id()
        self.assertEqual(self.result, SAMPLE_CLONE_LATEST_TEST_CYCLE)

    def test_get_latest_test_cycle(self, *args):
        """ Check get_latest_test_cycle() keyword works """
        self.result = self.jiragetter.get_latest_test_cycle()
        self.assertEqual(self.result, SAMPLE_CLONE_LATEST_TEST_CYCLE)

    def test_get_test_cycle_info(self, *args):
        """ Check get_test_cycle_info() keyword works """
        self.result = self.jiragetter.get_test_cycle_info()
        self.assertEqual(self.result, SAMPLE_GET_TEST_CYCLE_INFO)

    def test_clone_latest_test_cycle(self, *args):
        """ Check clone_latest_test_cycle() keyword works """
        self.result = self.jiragetter.clone_latest_test_cycle()
        # print("\n\nresult\n%s\n" % self.result)
        self.assertEqual(self.result, SAMPLE_CLONE_LATEST_TEST_CYCLE)

    def test_create_test_cycle(self, *args):
        """ Check create_test_cycle() keyword works """
        self.result = self.jiragetter.create_test_cycle(INIT["TEST_CYCLE_NAME"])
        self.assertEqual(self.result, SAMPLE_CREATE_TEST_CYCLE)

    def test_get_all_projects(self, *args):
        """ Check get_all_projects() keyword works """
        self.result = self.jiragetter.get_all_projects()
        self.assertEqual(self.result, SAMPLE_GET_ALL_PROJECTS)

    def test_get_issue_key_by_id(self, *args):
        """ Check get_issue_key_by_id() keyword works """
        self.result = self.jiragetter.get_issue_key_by_id(SAMPLE_GET_ISSUE_KEY_BY_ID)
        self.assertEqual(self.result, SAMPLE_GET_ISSUE_KEY_BY_ID)

    def test_get_issue_id_by_key(self, *args):
        """ Check get_issue_id_by_key() keyword works """
        self.result = self.jiragetter.get_issue_id_by_key(SAMPLE_GET_ISSUE_ID_BY_KEY)
        self.assertEqual(self.result, SAMPLE_GET_ISSUE_ID_BY_KEY)

    def test_get_issue_execution_id(self, *args):
        """ Check get_issue_execution_id() keyword works """
        self.result = self.jiragetter.get_issue_execution_id(SAMPLE_GET_ISSUE_ID_BY_KEY)
        self.assertEqual(self.result, SAMPLE_GET_ISSUE_EXECUTION_ID)

    def test_add_issue_to_test_cycle(self, *args):
        """ Check add_issue_to_test_cycle() keyword works """
        self.result = self.jiragetter.add_issue_to_test_cycle(SAMPLE_GET_ISSUE_KEY_BY_ID)
        self.assertEqual(self.result, True)

    def test_set_test_case_execution_status(self, *args):
        """ Check set_test_case_execution_status() keyword works """
        self.result = \
            self.jiragetter.set_test_case_execution_status(SET_TEST_CASE_EXECUTION_ISSUE_KEY)
        # PENDING TO HAVE THE EXPECTED RESULT FOR set_test_case_execution_status
        self.assertEqual(self.result, SAMPLE_SET_TEST_CASE_EXECUTION_STATUS)


def make_suite(class_name):
    """A function builds a test suite for a given class."""
    return unittest.makeSuite(class_name, "test")


def run_tests():
    """A function runs unit tests; HTTP requests will not go to real servers."""
    suites = [
        make_suite(TestKeyword_JiraGetter)
    ]
    for suite in suites:
        unittest.TextTestRunner(verbosity=2).run(suite)


if __name__ == "__main__":
    run_tests()
