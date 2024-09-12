# Trigger for Jenkins job bitbucket-pull-request-trigger.
# Purpose: find not reviewed pull requests and trigger Pipeline_Python Jenkins pipeline (unit tests, pylint, etc)

import os
import sys
import base64
import argparse
import json
import requests
from import_file import import_file


PULL_REQUEST_GENERAL_MESSAGE = '{"text":"%(comment)s"}'

PULL_REQUEST_STATUS = """
{
    "user": {
        "name": "%(username)s"
    },
    "approved": true,
    "status": "%(resolution)s"
}
"""

conf_file = None

valid_status_codes = [200, 201]

# Get Bitbucket credentials from Jenkins
bitbucket_user = os.environ.get("BITBUCKET_USER_NAME")
credentials = "%s:%s" % (os.environ.get("BITBUCKET_USER_NAME"), os.environ.get("BITBUCKET_PASSWORD"))
# For python 2:
# encoded_credentials = credentials.encode("BASE64").replace("\n", "")
# For python 3:
encoded_credentials = base64.b64encode(bytes(credentials, "utf-8")).decode('ascii')

bitbucket_headers = {
    "Authorization": "Basic %s" % encoded_credentials,
    "X-Atlassian-Token": "no-check",
    "Content-Type": "application/json"
}

# # Get Jenkins credentials from Jenkins
jenkins_username = os.environ.get("JENKINS_USER_NAME")
jenkins_api_token = os.environ.get("JENKINS_API_TOKEN")

def trigger_jenkins_build():
    jenkins_url = os.environ.get("JENKINS_URL")
    if jenkins_url[-1] == "/":
        jenkins_url = jenkins_url[:-1]
    job_name = "Pipeline_Python"
    print("Collecting all pull requests...")
    all_pull_requests_json = get_all_pull_requests()
    print("Done\n")
    print("Trying to find not reviewed requests...")
    not_reviewed_pull_request_git_branches = get_not_reviewed_pull_request_git_branches(all_pull_requests_json)
    print("Done\n")
    triggered_builds = 0
    if not_reviewed_pull_request_git_branches:
        for git_branch in not_reviewed_pull_request_git_branches:
            pull_request_id = get_pull_request_id_from_git_branch(git_branch)
            if not is_pull_request_own(pull_request_id):
                # Trigger Jenkins job
                trigger_url = "%s/view/Pipelines/job/%s/buildWithParameters?" \
                              "token=start-build-token&GIT_BRANCH_FOR_CHECK=%s" % \
                              (jenkins_url, job_name, git_branch)
                response = requests.get(trigger_url, auth=(jenkins_username, jenkins_api_token))
                print()
                if response.status_code in valid_status_codes:
                    print("""Jog %s was triggered to run static code check on '%s' branch\n++++++++++++++++++++++++""" %
                          (job_name, git_branch))
                    triggered_builds += 1
                else:
                    raise Exception("\n\nWe got %s status code when tried to trigger_jenkins_build. "
                                    "URL: %s. User: %s. API_TOKEN: %s. Reason: %s. Text: %s" %
                                    (response.status_code, trigger_url,
                                     jenkins_username, jenkins_api_token,
                                     response.reason, response.text))
    if triggered_builds is 0:
        print("++++++++++++++++++++++++\nThere no pull requests to check\n++++++++++++++++++++++++")


def set_pull_request_general_comment(pull_request_id, comment):
    # Documentation https://docs.atlassian.com/bitbucket-server/rest/5.12.0/bitbucket-rest.html#idm45885145246352
    url = "https://%s/rest/api/1.0/projects/%s/repos/%s/pull-requests/%s/comments" % \
          (conf_file.BITBUCKET_UPC_HOST, conf_file.BITBUCKET_UPC_PROJECT, conf_file.BITBUCKET_UPC_REPO, pull_request_id)
    data = PULL_REQUEST_GENERAL_MESSAGE % {"comment": comment}
    response = requests.post(url, data=data, headers=bitbucket_headers)
    if response.status_code in valid_status_codes:
        print("General comment '%s' was written in pull request #%s" % (comment, pull_request_id))
    else:
        raise Exception("\n\nWe got %s status code when tried to set_pull_request_general_comment for pull request #%s" %
              (response.status_code, pull_request_id))


def set_pull_request_status(pull_request_id, resolution):
    # Documentation https://docs.atlassian.com/bitbucket-server/rest/5.12.0/bitbucket-rest.html#idm45885144810464
    url = "https://%s/rest/api/1.0/projects/%s/repos/%s/pull-requests/%s/participants/%s" % \
          (conf_file.BITBUCKET_UPC_HOST, conf_file.BITBUCKET_UPC_PROJECT, conf_file.BITBUCKET_UPC_REPO,
           pull_request_id, bitbucket_user)
    data = PULL_REQUEST_STATUS % {"username": bitbucket_user, "resolution": resolution}
    response = requests.put(url, data=data, headers=bitbucket_headers)
    if response.status_code in valid_status_codes:
        print("Status '%s' was set to pull request #%s" % (resolution, pull_request_id))
    else:
        raise Exception("\n\nWe got %s status code when tried to set_pull_request_status for pull request #%s" %
              (response.status_code, pull_request_id))


def get_pull_request(pull_request_id):
    # Documentation https://docs.atlassian.com/bitbucket-server/rest/5.12.0/bitbucket-rest.html#idm45885145020688
    url = "https://%s/rest/api/1.0/projects/%s/repos/%s/pull-requests/%s" % \
          (conf_file.BITBUCKET_UPC_HOST, conf_file.BITBUCKET_UPC_PROJECT, conf_file.BITBUCKET_UPC_REPO, pull_request_id)
    response = requests.get(url, headers=bitbucket_headers)
    if response.status_code not in valid_status_codes:
        raise Exception("\n\nWe got %s status code when tried to get_pull_request" % response.status_code)
    else:
        pull_request_json = response.json()
        return pull_request_json


def get_all_pull_requests():
    # Documentation https://docs.atlassian.com/bitbucket-server/rest/5.12.0/bitbucket-rest.html#idm45885145141328
    url = "https://%s/rest/api/1.0/projects/%s/repos/%s/pull-requests/" % \
    (conf_file.BITBUCKET_UPC_HOST, conf_file.BITBUCKET_UPC_PROJECT, conf_file.BITBUCKET_UPC_REPO)
    response = requests.get(url, headers=bitbucket_headers)
    if response.status_code not in valid_status_codes:
        raise Exception("\n\nWe got %s status code when tried to get_all_pull_requests" % response.status_code)
    else:
        all_pull_requests_json = response.json()
        return all_pull_requests_json


def get_not_reviewed_pull_request_git_branches(all_pull_requests_json):
    pull_requests = all_pull_requests_json["values"]
    not_reviewed_pull_request_git_branches = []
    for pull_request in pull_requests:
        if not is_pull_request_reviewed(pull_request["id"]):
            not_reviewed_pull_request_git_branches.append(pull_request["fromRef"]["displayId"])
    not_reviewed_pull_request_git_branches = list(set(not_reviewed_pull_request_git_branches))
    if len(not_reviewed_pull_request_git_branches) > 0:
        return not_reviewed_pull_request_git_branches
    else:
        return None


def is_pull_request_reviewed(pull_request_id):
    result = False
    pull_request = get_pull_request(pull_request_id)
    for reviewer in pull_request["reviewers"]:
        if reviewer["user"]["name"] == bitbucket_user:
            if reviewer["status"] == "APPROVED" or reviewer["status"] == "NEEDS_WORK":
                print("Pull request %s is reviewed" % pull_request_id)
                result = True
            else:
                print("Pull request %s is NOT reviewed yet" % pull_request_id)
                result = False
    return result


def is_pull_request_own(pull_request_id):
    pull_request = get_pull_request(pull_request_id)
    if pull_request["author"]["user"]["name"] == bitbucket_user:
        return True
    else:
        return False


def get_pull_request_id_from_git_branch(git_branch):
    all_pull_requests_json = get_all_pull_requests()
    pull_requests = all_pull_requests_json["values"]
    for pull_request in pull_requests:
        if pull_request["fromRef"]["displayId"] == git_branch:
            return pull_request["id"]


def main():
    description = 'Script arguments parser'
    parser = argparse.ArgumentParser(add_help=True, description=description)
    parser.add_argument('-t', '--trigger', action='store_true',
                        help="Trigger Jenkins build if not reviewed pull requests are present")
    parser.add_argument('-apr', '--approve_pull_request', action='store_const',
                        const='APPROVED', help="Approve Bitbucket pull request. Provide here git branch name")
    parser.add_argument('-nwpr', '--needs_work_pull_request', action='store_const',
                        const='NEEDS_WORK', help="Approve Bitbucket pull request. Provide here git branch name")
    parser.add_argument('-gc', '--set_pull_request_general_comment',
                        help="Set general comment to Bitbucket pull request. Provide here comment as string")
    parser.add_argument("--conf", default="conf_bitbucket.py", type=str,
                        help="Common configuration file, default is conf_debug.py",required=False)
    args = parser.parse_args()

    current_dir = os.path.dirname(os.path.realpath(__file__))
    sys.path.append("%s/../../robot/resources/stages/" % (
        current_dir))  # Add robot/resources/stages/ to PATH to resolve import issues
    global conf_file
    conf_file = import_file('%s/../../robot/resources/stages/%s' % (current_dir, args.conf))
    # Will be defined only when "trigger_jenkins_build" will call  Pipeline_Python
    git_branch = os.environ.get("GIT_BRANCH_FOR_CHECK")
    pull_request_id = get_pull_request_id_from_git_branch(git_branch)

    if args.trigger:
        trigger_jenkins_build()
    if git_branch is not None:
        if args.approve_pull_request:
            set_pull_request_status(pull_request_id, args.approve_pull_request)
        elif args.needs_work_pull_request:
            set_pull_request_status(pull_request_id, args.needs_work_pull_request)
        elif args.set_pull_request_general_comment:
            set_pull_request_general_comment(pull_request_id, args.set_pull_request_general_comment)


if __name__ == "__main__":
    main()