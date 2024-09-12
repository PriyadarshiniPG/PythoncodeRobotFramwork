*** Settings ***
Library           Libraries.Jira.keywords.JiraGetter

*** Keywords ***
Get Default Jira Defects Jenkins Environments Variables    #USED
    [Documentation]    This keyword will get all the useful environments variables that Jenkins Created for the Jira Defects Report
    Set Suite Variable    ${project}   HES
    ${JIRA_PROJECT}    Get Environment Variable    JIRA_PROJECT    ${project}  # This variable is expected to be defined by Jenkins Itself
    Set Suite Variable    ${JIRA_PROJECT}   ${JIRA_PROJECT}
    Log To Console    \nJIRA_PROJECT: ${JIRA_PROJECT}
    #${jira_filter_id}    10094
    Set Suite Variable    ${repository}    e2e_si_automation
    ${GIT_REPOSITORY}    Get Environment Variable    GIT_REPOSITORY    ${repository}
    Set Suite Variable    ${GIT_REPOSITORY}   ${GIT_REPOSITORY}
    Set Suite Variable    ${file_modif_h}   24     #By Default File of Jira defect will not change in less than 24h
    ${FILE_MODIF_HOURS}    Get Environment Variable    FILE_MODIF_HOURS    ${file_modif_h}  # This variable is expected to be defined by Jenkins Itself
    Set Suite Variable    ${FILE_MODIF_HOURS}   ${FILE_MODIF_HOURS}
    Log To Console    GIT_REPOSITORY: ${GIT_REPOSITORY}
    Set Suite Variable    ${branch}    origin/HES-11034-Jira-Getter-fcobos   ## VALUE BY DEFAULT CHANGE IT TO master - After Test It
    ${GIT_BRANCH}    Get Environment Variable    GIT_BRANCH    ${branch}  # This variable is expected to be defined by Jenkins Itself
    ${GIT_BRANCH}    Remove String    ${GIT_BRANCH}    origin/    #To remove origin/ it because Jenkins add it
    Set Suite Variable    ${GIT_BRANCH}   ${GIT_BRANCH}
    Log To Console    GIT_BRANCH: ${GIT_BRANCH}
    ${default_git_branches}    Set Variable    ${GIT_BRANCH}
#    ${default_git_branches}    Set Variable    HES-11034-Jira-Getter-fcobos,master    #FOR DEBUG
    ${GIT_BRANCHES}    Get Environment Variable    GIT_BRANCHES    ${default_git_branches}  # This variable is expected to be defined by Jenkins Itself
    ${GIT_BRANCHES_LIST}    split string    ${GIT_BRANCHES}    ,
    Set Suite Variable    ${GIT_BRANCHES_LIST}   ${GIT_BRANCHES_LIST}
    Log To Console    GIT_BRANCHES_LIST: ${GIT_BRANCHES_LIST}
    Set Suite Variable    ${FILE_TO_PUSH}        ./resources/jira/${JIRA_PROJECT}_linked_defects.json
    Log To Console    FILE_TO_PUSH: ${FILE_TO_PUSH}\n
    ${SUITE_ID}    Get Environment Variable    SUITE_ID    ${EMPTY}  # This variable is expected to be defined in Jenkins
    ${PIPELINE_ID}    Get Environment Variable    PIPELINE_ID    ${EMPTY}  # This variable is expected to be defined in Jenkins
    ${JOB_NAME}    Get Environment Variable    JOB_NAME    ${EMPTY}  # This variable is expected to be defined by Jenkins Itself [JOB NAME]
    ${USER_ID}    Get Environment Variable    USER    ${EMPTY}  # This variable is expected to be defined by Jenkins Itself
    ${BUILD_NUMBER}    Get Environment Variable    BUILD_NUMBER    ${EMPTY}  # This variable is expected to be defined by Jenkins Itself
    ${BUILD_URL}    Get Environment Variable    BUILD_URL    ${EMPTY}  # This variable is expected to be defined by Jenkins Itself
    ${BUILD_TAG}    Get Environment Variable    BUILD_TAG    ${EMPTY}  # This variable is expected to be defined by Jenkins Itself
    ${GIT_COMMIT}    Get Environment Variable    GIT_COMMIT    ${EMPTY}  # This variable is expected to be defined by Jenkins Itself

Get And Save Jira Defects For '${project}' Project
    [Documentation]    This keyword will get from JIRA all the Jira defects linked to the Project By Default 24h
    ...    and save it into a file in robot/resources/jira/${project}_linked_defects.json
    ${jira_data_file_saved}    get and save data file with all linked tickets from project    ${project}
    Should Be True    ${jira_data_file_saved}

Get And Save Jira Defects for '${project}' Project File Older Than '${file_modif_hours}' Hours    #USED
    [Documentation]    This keyword will get from JIRA all the Jira defects linked to the Project - File Older Than ${file_modif_hours} Hours
    ...    and save it into a file in robot/resources/jira/${project}_linked_defects.json
    ${jira_data_file_saved}    get and save data file with all linked tickets from project    ${project}    ${file_modif_hours}
    Should Be True    ${jira_data_file_saved}

Get And Save Jira Defects For '${project}' Project And Filter '${jira_filter_id}' File Older Than '${file_modif_hours}' Hours
    [Documentation]    This keyword will get from JIRA all the Jira defects linked from the Jira filter:${jira_filter_id}
    ...    related with the Project:${project} and save it into a file in robot/resources/jira/${project}_linked_defects.json
    ${jira_data_file_saved}    get and save data file with all linked tickets from project and filter id    ${project}    ${jira_filter_id}
    Should Be True    ${jira_data_file_saved}