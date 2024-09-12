*** Settings ***
Resource          ./basic.robot

*** Keywords ***
Git Configure Global Settings    #USED
    [Documentation]    This keyword will Configure Git Global Setting 
    ${GIT_CONFIG_SET}    Get Variable Value    ${GIT_CONFIG_SET}    ${False}
    Return From Keyword If    ${GIT_CONFIG_SET}
    Log To Console    Setting GIT CONFIG (Only one time)
    ${commands}    Create List   git config --global user.name "jenkins" && git config --global user.email "jenkins@2a-jenkins01" && git config --global push.default simple
    Run List Of OperatingSystem Commands    ${commands}    fatal:    error:
    Set Suite Variable    ${GIT_CONFIG_SET}    ${True}

Git Checkout To '${branch}' Branch    #USED
    [Documentation]    This keyword will checkout To ${branch} Branch
    ${commands}    Create List    git checkout ${branch}    git status
    Run List Of OperatingSystem Commands    ${commands}    fatal:    error:

Git Push '${file_to_push}' File To '${branch}' Branch '${repository}' Repository    #USED
    [Documentation]    This keyword will push a file: ${file_to_push} To ${branch} Branch ${repository} Git Repository
    Git Configure Global Settings
    Git Checkout To '${branch}' Branch
    ${commands}    Create List    git add ${file_to_push}    git commit -m Jenkins-Auto-Update:${file_to_push}
    Append To List    ${commands}    git fetch origin ${branch}
    Append To List    ${commands}    git push origin ${branch}
    Run List Of OperatingSystem Commands    ${commands}    fatal:    error:

Git Push '${file_to_push}' File To Multiple '${branches_list}' Branches '${repository}' Repository    #USED
    [Documentation]    This keyword will push a file: ${file_to_push} To Multiple ${branches_list} Branches ${repository} Git Repository
    ${tmp_git_file}    Set Variable    /tmp/git_file_to_push.tmp
    Copy File From '${file_to_push}' To '${tmp_git_file}'
    Git Configure Global Settings
    Log To Console    \nbranch on git multi:${branches_list}
    ${branches_list}    Convert String List To List    ${branches_list}
     Log To Console    \nbranch modif:${branches_list}
    :FOR    ${branch}    IN    @{branches_list}
    \    Log To Console    one branch from list:${branch}
    \    Git Checkout To '${branch}' Branch
    \    Copy File From '${tmp_git_file}' To '${file_to_push}'
    \    Git Push '${file_to_push}' File To '${branch}' Branch '${repository}' Repository