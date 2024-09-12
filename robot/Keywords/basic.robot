*** Settings ***
Library           SSHLibrary
Library           String
Library           Collections
Library           OperatingSystem

*** Variables ***

*** Keywords ***
Open Connection And Login
    [Arguments]    ${ip}=${HOST}    ${port}=${PORT_SSH}    ${user}=${HOST_USER}    ${password}=${HOST_PASSWORD}
    SSHLibrary.Open Connection    ${ip}    alias=${ip}    port=${port}
    SSHLibrary.Login    ${user}    ${password}

Make POST Request
    [Arguments]    ${host_ip}    ${port_num}    ${data}    ${request_path}=${EMPTY}    ${headers}=${None}    ${use_https}=${False}
    ...    ${user}=${None}    ${password}=${None}
    ${auth_str}    Set Variable If    '${user}'!='${None}'    ${user}:${password}@    ${EMPTY}
    ${prot}    Set Variable If    '${use_https}'=='${True}'    https    http
    ${response}    Evaluate    requests.post("${prot}://${auth_str}${host_ip}:${port_num}${request_path}",data="""${data}""", headers=${headers})    requests
    Log    ${response.text}    DEBUG
    [Return]    ${response}

Make GET Request
    [Arguments]    ${host_ip}    ${port_num}    ${request_path}=${EMPTY}    ${headers}=${None}    ${use_https}=${False}    ${user}=${None}
    ...    ${password}=${None}
    ${auth_str}    Set Variable If    '${user}'!='${None}'    ${user}:${password}@    ${EMPTY}
    ${prot}    Set Variable If    '${use_https}'=='${True}'    https    http
    ${response}    Evaluate    requests.get("${prot}://${auth_str}${host_ip}:${port_num}${request_path}", headers=${headers})    requests
    Log    ${response.text}    DEBUG
    [Return]    ${response}

Suite Setup LAB Variables
    ${LAB_NAME}    Get Environment Variable    LAB_NAME    ${LAB_NAME}    # This variable is expected to be defined in Jenkins
    Set Suite Variable    ${LAB_NAME}    ${LAB_NAME}    children=${True}
    Set Suite Variable    ${LAB_CONF}    ${E2E_CONF["${LAB_NAME}"]}
    Log Dictionary    ${LAB_CONF}
    ${CPE_ID}    Get Environment Variable    CPE_ID    ${LAB_CONF["CPE_ID"]}    # This variable is expected to be defined in Jenkins
    Set Suite Variable    ${CPE_ID}    ${CPE_ID}    children=${True} ${CPE_ID}
    Set Suite Variable    ${firstTestCaseFail}    ${EMPTY}
    # Set country and language
    ${COUNTRY}    Get Environment Variable    COUNTRY    ${LAB_CONF["country"]}    # This variable is expected to be defined in Jenkins
    ${LANGUAGE}    Get Environment Variable    LANGUAGE    ${LAB_CONF["default_language"]}    # This variable is expected to be defined in Jenkins
    Set Suite Variable    ${COUNTRY}    ${COUNTRY}    children=${True}
    Set Suite Variable    ${LANGUAGE}    ${LANGUAGE}    children=${True}

Clean Variables
    Set Suite Variable    ${resultLink}    ${EMPTY}
    Set Suite Variable    ${failedReason}    ${EMPTY}
    Set Suite Variable    ${firstTestCaseFail}    ${EMPTY}    children=true

Get Lab Name From Jenkins
    [Arguments]    ${var_name}=LAB_NAME    ${default}=${LAB_NAME}
    ${LAB_NAME}    Get Environment Variable    ${var_name}    ${default}    # This variable is expected to be defined in Jenkins
    Set Suite Variable    ${LAB_NAME}    ${LAB_NAME}    children=${True}
    [Return]    ${LAB_NAME}

Concatenate List Values
    [Arguments]    ${data_list}    ${separator}=${EMPTY}
    ${result_str}    Evaluate    "${separator}".join(${data_list})
    [Return]    ${result_str}

Skip If Last Fail       #USED
    Clean Variables
    Log    PREV_TC: ${PREV TEST NAME}:${PREV TEST STATUS}
    Run Keyword If    '${PREV TEST STATUS}'!='PASS' and '${firstTestCaseFail}'=='${EMPTY}'    Set Suite Variable    ${firstTestCaseFail}    ${PREV TEST NAME}
    Run Keyword If    '${PREV TEST STATUS}'!='PASS'    Run Keywords    Log    ${firstTestCaseFail}
    ...    AND    Set Suite Variable    ${failedReason}    skipped: The test case: ${firstTestCaseFail} FAIL so this one too
    ...    AND    Log    Skip failReason: ${failedReason}
    Should Be Equal    '${PREV TEST STATUS}'    'PASS'    msg=Skipping this test step as last test step => ${PREV TEST NAME}= ${PREV TEST STATUS}.

Log Response
    [Arguments]    ${http_response}    ${comment}=${EMPTY}
    ${request_body}    Set Variable If    """${http_response.request.body}""" != "${None}"    ${http_response.request.body}    ${EMPTY}
    ${request_details}    Catenate    ${http_response.request.method}    ${http_response.request.url}    ${request_body}
    ${response_details}    Run Keyword If    "${http_response.status_code}" == "${None}"    Set Variable    ${http_response.error}
    ...    ELSE    Catenate    ${http_response.status_code}    ${http_response.reason}    ${http_response.text}
    ${log_message}    Catenate    ${comment}    ${request_details}    returned    ${response_details}
    Log    ${log_message}
    [Return]    ${log_message}

Should Be Integer
    [Documentation]    Fails if the given item is not a integer and print error message
    [Arguments]    ${variable_to_check}    ${error_message}
    ${result}    Evaluate    type(${variable_to_check}).__name__
    ${status}    Run Keyword And Return Status    Should Be Equal    ${result}    int
    Should Be True     ${status}    ${error_message}

Should Be Boolean
    [Documentation]    Fails if the given item is not a boolean and print error message
    [Arguments]    ${variable_to_check}    ${error_message}
    ${result}    Evaluate    type(${variable_to_check}).__name__
    ${status}    Run Keyword And Return Status    Should Be Equal    ${result}    bool
    Should Be True     ${status}    ${error_message}

Should Be List
    [Documentation]    Fails if the given item is not a list and print error message
    [Arguments]    ${variable_to_check}    ${error_message}
    ${result}    Evaluate    type(${variable_to_check}).__name__
    ${status}    Run Keyword And Return Status    Should Be Equal    ${result}    list
    Should Be True     ${status}    ${error_message}

Should Be Dictionary
    [Documentation]    Fails if the given item is not a dictionary and print error message
    [Arguments]    ${variable_to_check}    ${error_message}
    ${result}    Evaluate    type(${variable_to_check}).__name__
    ${status}    Run Keyword And Return Status    Should Be Equal    ${result}    dict
    Should Be True     ${status}    ${error_message}

Create List From Dict Array Key Elements   #USED
    [Arguments]    ${data}    ${key}
    ${length}    Get Length    ${data}
    @{list_with_key}    Create List
    :FOR    ${index}    IN RANGE    0    ${length}
    \    Append To List    ${list_with_key}    ${data[${index}][${key}]}
    [Return]    ${list_with_key}

Remove List Elements From Other List   #USED
    [Arguments]    ${list}    ${list_to_delete}
    ${length}    Get Length    ${list_to_delete}
    :FOR    ${index}    IN RANGE    0    ${length}
    \        Remove Values From List      ${list}    ${list_to_delete[${index}]}

Find Next Element On List    #USED
    [Documentation]    Get the next element in the list giving one element of it,
    ...    It will fail if element not in list or if no more element on lists
    [Arguments]    ${list}    ${element}
    ${length}    Get Length    ${list}
    : FOR    ${index}    IN RANGE    0    ${length}
    \    exit for loop if  ${element} == ${list[${index}]}
    ${index_increased}    evaluate    ${index}+1
    ${return_element}    Set Variable if    '${index_increased}' != '${length}'    ${list[${index_increased}]}    0
    ${return_element}    Set Variable if    '${index_increased}' == '${length}' and ${element} == ${list[${index}]}    -1    ${return_element}
    ${return_element}    Set Variable if    '${index_increased}' == '${length}' and ${element} != ${list[${index}]}    -2    ${return_element}
    run keyword if    '${return_element}'== '-1'    Log    No more elements on the List - Element: ${element} is the last element of list: ${list}
    should not be equal    ${return_element}    -2    Element: ${element} it is not present on list: ${list}
    [Return]    ${return_element}

Get Current Time In Epoch    #USED
    [Documentation]    Yhis Keyword return the current time in epoch (integrer)
    ${timestamp}    robot.libraries.DateTime.get current date    result_format=%Y-%m-%d %H:%M:%S
    ${timestamp}    robot.libraries.DateTime.Convert Date    ${timestamp}    epoch
    ${timestamp}    Convert to integer    ${timestamp}
    [Return]    ${timestamp}

Check Element Present In List    #USED
    [Arguments]    ${element}    ${list}
    [Documentation]    This keyword checks if the Element exists in the list
    ...    Return True if element is present and False if not
    ${length}    Get Length    ${list}
    : FOR    ${index}    IN RANGE    0    ${length}
    \    exit for loop if  '${element}' == '${list[${index}]}'
    ${present}    Set Variable if    '${element}' == '${list[${index}]}'    ${True}    ${False}
    [Return]    ${present}

Convert String List To List    #USED
    [Documentation]    This keyword will convert a string list to a robotframework list return List
    [Arguments]    ${str_list}
    Log    Covert String List To List (str_list): ${str_list}
    ${type}    Evaluate     type($str_list).__name__
    Log    type - str_list: ${type}
    Return From Keyword If    '${type}'=='list'    ${str_list}
    ${str_list}    Remove String    ${str_list}   u' 
    ${str_list}    Remove String    ${str_list}   '
    ${str_list}    Remove String    ${str_list}   ]
    ${str_list}    Remove String    ${str_list}   [
    ${list}    split string    ${str_list}    ,
    Log    converted_list: ${list}
    ${type}    Evaluate     type($list).__name__
    Log    type - list: ${type}
    ${str_list}    set variable  ${list}
    [Return]    ${list}

Run List Of OperatingSystem Commands    #USED
    [Documentation]    This keyword will run a list of commands and check no errors
    [Arguments]    ${commands}    ${error_1}=fatal:    ${error_2}=error:
    :FOR    ${command}    IN    @{commands}
    \    Log    command: ${command}    DEBUG
    \    Log To Console    command: ${command}    DEBUG
    \    ${out}    OperatingSystem.Run    ${command}
#    \    ${out}    Set Variable    'OK - TESTS'    #FOR TESTS
    \    Log    command stdout:\n${out}    DEBUG
    \    Log To Console    stdout command:\n${out}    DEBUG
    \    Should Not Contain    ${out}    ${error_1}    Failed: Command: ${command} - stdout:\n${out}
    \    Should Not Contain    ${out}    ${error_2}    Failed: Command: ${command} - stdout:\n${out}

Copy File From '${file_src}' To '${file_dst}'    #USED
    ${commands}    Create List    cp ${file_src} ${file_dst}
    Run List Of OperatingSystem Commands    ${commands}    No such    error