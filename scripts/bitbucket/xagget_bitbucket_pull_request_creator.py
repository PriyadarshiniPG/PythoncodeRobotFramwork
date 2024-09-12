# Bitbucket API v2 documentation:
# https://developer.atlassian.com/bitbucket/api/2/reference/resource/

import os
import sys
import datetime
import argparse
import json
import requests
from import_file import import_file

percent_of_repo_to_check = 75  # Check last N% of repo

conf_file = None
xagget_source_branch = None
xagget_target_branch = None

reviewers = ["vishwa_upadhyay", "vivekmish", "sthorat01", "Fernando_Cobos"]
# reviewers = ["vishwa_upadhyay", "vivekmish", "sthorat01", "Fernando_Cobos", "ievgen_petrash"]

# # Get Bitbucket credentials from Jenkins
# credentials = "%s:%s" % (os.environ.get("BITBUCKET_USER_NAME"), os.environ.get("BITBUCKET_PASSWORD"))
# encoded_credentials = credentials.encode("BASE64").replace("\n", "")
encoded_credentials = "aXBldHJhc2guY29udHJhY3RvckBsaWJlcnR5Z2xvYmFsLmNvbTpZdGR0aGpkZjEh"
bitbucket_headers = {
    "Authorization": "Basic %s" % encoded_credentials,
    "X-Atlassian-Token": "no-check",
    "Content-Type": "application/json"
}

PULL_REQUEST_BODY = {
    "title": "%(title)s",
    "description": "%(description)s",
    "source": {
        "branch": {
            "name": "%(source_branch)s"
        }
    },
    "destination": {
        "branch": {
            "name": "%(target_branch)s"
        }
    }
}

dummy_commit_json = {
    "hash": "Commit didn't return JSON",
    "links": {
        "html": {
            "href": "No link"
        }
    },
    "author": {
        "raw": "No author"
    },
    "date": "2000-01-01T00:00:00+00:00",
    "message": "No message\n",
    "type": "commit"
}

pull_request_title = "Auto generated pull request"

valid_status_codes = [200, 201]


def percentage(percent, whole):
    return (percent * whole) / 100.0


def get_repo_json():
    url = "https://api.%s/2.0/repositories/%s/%s/" % \
          (conf_file.BITBUCKET_HOST, conf_file.BITBUCKET_XAGGET_PROJECT, conf_file.BITBUCKET_XAGGET_REPO)
    response = requests.get(url, headers=bitbucket_headers)
    return response.json()


def get_all_pull_requests_json():
    url = "https://api.%s/2.0/repositories/%s/%s/pullrequests" % \
          (conf_file.BITBUCKET_HOST, conf_file.BITBUCKET_XAGGET_PROJECT, conf_file.BITBUCKET_XAGGET_REPO)
    response = requests.get(url, headers=bitbucket_headers)
    # with open("a.json", "w") as f:
    #     f.write(json.dumps(response.json()))
    return response.json()


def get_all_branches_json():
    url = "https://api.%s/2.0/repositories/%s/%s/refs/branches" % \
          (conf_file.BITBUCKET_HOST, conf_file.BITBUCKET_XAGGET_PROJECT, conf_file.BITBUCKET_XAGGET_REPO)
    response = requests.get(url, headers=bitbucket_headers)
    return response.json()


def get_branch_json(branch_name):
    url = "https://api.%s/2.0/repositories/%s/%s/refs/branches/%s" % \
          (conf_file.BITBUCKET_HOST, conf_file.BITBUCKET_XAGGET_PROJECT,
           conf_file.BITBUCKET_XAGGET_REPO, branch_name)
    response = requests.get(url, headers=bitbucket_headers)
    return response.json()


def get_branch_commits_json(branch_name):
    url = "https://api.%s/2.0/repositories/%s/%s/commits/%s" % \
          (conf_file.BITBUCKET_HOST, conf_file.BITBUCKET_XAGGET_PROJECT, 
           conf_file.BITBUCKET_XAGGET_REPO, branch_name)
    response = requests.get(url, headers=bitbucket_headers)
    return response.json()


def get_branch_commit_hashes(branch_name):
    commit_hashes = []
    commits_json = get_branch_commits_json(branch_name)
    try:
        json_pages = commits_json["pagelen"]
    except KeyError:
        json_pages = 1
    if branch_name == xagget_source_branch:
        pages = int(percentage(percent_of_repo_to_check, json_pages))
    else:
        pages = json_pages
    for page in range(pages):
    # for page in range(1):  # for debug purpose
        page_url = "https://api.%s/2.0/repositories/%s/%s/commits/%s?page=%s" % \
                   (conf_file.BITBUCKET_HOST, conf_file.BITBUCKET_XAGGET_PROJECT,
                    conf_file.BITBUCKET_XAGGET_REPO, branch_name, page + 1)
        response = requests.get(page_url, headers=bitbucket_headers)
        page_json = response.json()
        for commit in page_json["values"]:
            commit_hashes.append(commit["hash"])
    return commit_hashes


def get_commit_json(commit_hash):
    url = "https://api.%s/2.0/repositories/%s/%s/commit/%s" % \
          (conf_file.BITBUCKET_HOST, conf_file.BITBUCKET_XAGGET_PROJECT,
           conf_file.BITBUCKET_XAGGET_REPO, commit_hash)
    response = requests.get(url, headers=bitbucket_headers)
    try:
        result = response.json()
    except ValueError:
        result = dummy_commit_json
    return result


def get_commit_link(commit_hash):
    commit = get_commit_json(commit_hash)
    return commit["links"]["html"]["href"]


def get_commit_author(commit_hash):
    response_json = get_commit_json(commit_hash)
    try:
        author = response_json["author"]["user"]["display_name"]
    except KeyError:
        author = "Undefined user"
    return author


def get_commit_message(commit_hash):
    response_json = get_commit_json(commit_hash)
    return response_json["message"].replace("\n", "")


def get_commit_date(commit_hash):
    # Example of date in json : 2018-08-09T10:18:20+00:00
    response_json = get_commit_json(commit_hash)
    date_time = response_json["date"]
    date =  date_time.split("T")[0]
    year = date.split("-")[0]
    month_integer = int(date.split("-")[1])
    month = datetime.date(1900, month_integer, 1).strftime('%B')
    day = date.split("-")[2]
    return "%s %s %s" % (day, month, year)


def get_short_commit_hash(commit_hash):
    return commit_hash[:6]


def is_target_branch_up_to_date():
    print("Collecting commits from source branch...")
    source_commits = get_branch_commit_hashes(xagget_source_branch)
    print("Done")
    print("Collecting commits from target branch...")
    target_commits = get_branch_commit_hashes(xagget_target_branch)
    print("Done")
    new_source_commits = []
    for commit in source_commits:
        if commit not in target_commits:
            new_source_commits.append(commit)
    result = len(new_source_commits) is 0
    message = None
    if result:
        print("Target branch is up to day")
    else:
        print("Preparing message for pull request description...")
        message = "We have %s new commits in %s branch:" % (len(new_source_commits), xagget_source_branch)
        # for commit in new_source_commits:
        #     message += " ----- Commit %s: '%s' from %s. Date: %s . Link: %s" \
        #           % (get_short_commit_hash(commit),
        #             get_commit_message(commit),
        #             get_commit_author(commit),
        #             get_commit_date(commit),
        #             get_commit_link(commit))
    print("Done")
    return result, message


def is_pull_request_already_present():
    print("Checking is pull request already present...")
    pull_requests_json = get_all_pull_requests_json()
    for pull_request in pull_requests_json["values"]:
        if str(pull_request["title"]) == pull_request_title:
            print("Pull request already in place")
            return True
    print("Done")
    return False


def create_pull_request(source_branch, target_branch, description):
    # Documentation: https://developer.atlassian.com/bitbucket/api/2/reference/resource/repositories/%7Busername%7D/%7Brepo_slug%7D/pullrequests#post
    description = description
    if len(reviewers) > 0:
        PULL_REQUEST_BODY["reviewers"] = []
        for reviewer in reviewers:
            user_account = {
                "username": reviewer
            }
            PULL_REQUEST_BODY["reviewers"].append(user_account)

    url = "https://api.%s/2.0/repositories/%s/%s/pullrequests" % \
          (conf_file.BITBUCKET_HOST, conf_file.BITBUCKET_XAGGET_PROJECT,
           conf_file.BITBUCKET_XAGGET_REPO)
    data = json.dumps(PULL_REQUEST_BODY) % {
        "title": pull_request_title,
        "description": description,
        "source_branch": source_branch,
        "target_branch": target_branch
    }
    response = requests.post(url, data=data, headers=bitbucket_headers)
    if response.status_code in valid_status_codes:
        pull_request_url = response.json()["links"]["html"]["href"]
        print("Pull request was successfully created: %s" % pull_request_url)
    else:
        print("We got unexpected response when creating pull request. Status code %s, reason: %s"
              % (response.status_code, response.reason))


def main():
    global conf_file
    global xagget_source_branch
    global xagget_target_branch

    description = 'Script arguments parser'
    parser = argparse.ArgumentParser(add_help=True, description=description)
    parser.add_argument("--conf", default="conf_bitbucket.py", type=str,
                        help="Common configuration file, default is conf_debug.py",required=False)

    parser.add_argument('-sb', '--source_branch', default=None,
                        help="Name of source branch")
    parser.add_argument('-tb', '--target_branch', default=None,
                        help="Name of target branch")
    args = parser.parse_args()

    current_dir = os.path.dirname(os.path.realpath(__file__))
    sys.path.append("%s/../../robot/resources/stages/" % (
        current_dir))  # Add robot/resources/stages/ to PATH to resolve import issues
    conf_file = import_file('%s/../../robot/resources/stages/%s' % (current_dir, args.conf))

    # If argument was not passed use value from conf file. Else - use passed value
    if args.source_branch is None:
        xagget_source_branch = conf_file.XAGGET_SOURCE_BRANCH
    else:
        xagget_source_branch = args.source_branch
    if args.target_branch is None:
        xagget_target_branch = conf_file.XAGGET_TARGET_BRANCH
    else:
        xagget_target_branch = args.target_branch

    # Run check
    if not is_pull_request_already_present():
        result, message = is_target_branch_up_to_date()
        if not result:
            create_pull_request(xagget_source_branch, xagget_target_branch, message)


if __name__ == "__main__":
    main()