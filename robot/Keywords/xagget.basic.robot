*** Settings ***
Library           Collections
Library           String
Library           OperatingSystem
Library           Libraries.Xagget
Library           Libraries.XAP

*** Variables ***
${xagget_web_user}    monitor
${xagget_web_password}    xaggetmonitor

*** Keywords ***
Create Artifacts
    Run Keyword And Continue On Failure    OperatingSystem.Create File    ${CURDIR}${/}OpenKibana_${RUN_ID}.html    <BODY onload=javascript:document.location.href="${TEST_RUN_RESULT['monitorUrl']}">${TEST_RUN_RESULT['monitorUrl']}</BODY>
    ${txt}    Evaluate    pprint.PrettyPrinter(indent=4).pformat(${TEST_RUN_RESULT})    pprint
    Run Keyword And Continue On Failure    OperatingSystem.Create File    ${CURDIR}${/}TestRunInfo_${RUN_ID}.txt    ${txt}
    ${txt}    Evaluate    pprint.PrettyPrinter(indent=4).pformat(${TESTS_RESULTS})    pprint
    Run Keyword And Continue On Failure    OperatingSystem.Create File    ${CURDIR}${/}TestResults_${RUN_ID}.txt    ${txt}
    Log    ${TEST_RUN_RESULT}

Suite Setup Xagget Variables
    ${LAB_NAME}    Get Environment Variable    LAB_NAME    ${LAB_NAME}    # This variable is expected to be defined in Jenkins
    ${INITIAL_TESTCASE}    Get Environment Variable    INITIAL_TESTCASE    ${INITIAL_TESTCASE}
    ${DESCRIPTION}    Get Environment Variable    DESCRIPTION    ${EMPTY}    # This variable is expected to be defined in Jenkins
    ${CPE_FW_VERSION}    Get Environment Variable    CPE_FW_VERSION    ${E2E_CONF["${LAB_NAME}"]["CPE_FW_VERSION"]}    # This variable is expected to be defined in Jenkins
    ${MAX_NUMBER_OF_SKIPPED_ALLOWED}    Get Environment Variable    MAX_NUMBER_OF_SKIPPED_ALLOWED    -1    # This variable is expected to be defined in Jenkins
    ${LOCATION}    Get Environment Variable    LOCATION    ${EMPTY}    # This variable is expected to be defined in Jenkins
    ${XAGGET_WEBUI_HOST}    Get Environment Variable    XAGGET_WEBUI_HOST    ${E2E_CONF["${LAB_NAME}"]["XAGGET"]["host"]}    # This variable is expected to be defined in Jenkins
    ${XAGGET_WEBUI_PORT}    Get Environment Variable    XAGGET_WEBUI_PORT    ${E2E_CONF["${LAB_NAME}"]["XAGGET"]["port"]}    # This variable is expected to be defined in Jenkins
    ${XAGGET_ELK_HOST}    Get Environment Variable    XAGGET_ELK_HOST    ${E2E_CONF["${LAB_NAME}"]["XAGGET"]["elastic"]}    # This variable is expected to be defined in Jenkins
    ${XAGGET_ELK_PORT}    Get Environment Variable    XAGGET_ELK_PORT    ${E2E_CONF["${LAB_NAME}"]["XAGGET"]["elastic_port"]}    # This variable is expected to be defined in Jenkins
    ${XAGGET_DURATION}    Get Environment Variable    XAGGET_DURATION    ${E2E_CONF["${LAB_NAME}"]["XAGGET"]["duration"]}    # This variable is expected to be defined in Jenkins
    ${XAGGET_REPO}    Get Environment Variable    XAGGET_REPO    ${E2E_CONF["${LAB_NAME}"]["XAGGET"]["repo"]}    # This variable is expected to be defined in Jenkins
    ${XAGGET_TEST_RESULT_ELK}    Get Environment Variable    TEST_RESULT_ELK    ${E2E_CONF["${LAB_NAME}"]["XAGGET"]["test_result"]}
    ${CPE_ID}    Get Environment Variable    CPE_ID    ${E2E_CONF["${LAB_NAME}"]["XAGGET"]["cpe"]}    # This variable is expected to be defined in Jenkins
    ${CONF}    Create Dictionary    XAGGET_ELK_HOST=${XAGGET_ELK_HOST}    XAGGET_ELK_PORT=${XAGGET_ELK_PORT}    XAGGET_REPO=${XAGGET_REPO}    XAGGET_WEBUI_HOST=${XAGGET_WEBUI_HOST}    XAGGET_WEBUI_PORT=${XAGGET_WEBUI_PORT}
    ...    XAGGET_WEBUI_USER=${xagget_web_user}    XAGGET_WEBUI_PASS=${xagget_web_password}    LAB_NAME=${LAB_NAME}    XAGGET_TEST_RESULT_ELK=${XAGGET_TEST_RESULT_ELK}
    Set Suite Variable    ${LAB_NAME}    ${LAB_NAME}    children=${True}
    Set Suite Variable    ${CPE_ID}    ${CPE_ID}    children=${True}
    Set Suite Variable    ${LAB_CONF}    ${E2E_CONF["${LAB_NAME}"]}    children=${True}
    Set Suite Variable    ${CONF}    ${CONF}    children=${True}
    Set Suite Variable    ${XAGGET_REPO}    ${XAGGET_REPO}
    Set Suite Variable    ${XAGGET_TEST_RESULT_ELK}    ${XAGGET_TEST_RESULT_ELK}
    Set Suite Variable    ${CPE_FW_VERSION}    ${CPE_FW_VERSION}    children=${True}
    Set Suite Variable    ${INITIAL_TESTCASE}    ${INITIAL_TESTCASE}    children=${True}
    Set Suite Variable    ${MAX_NUMBER_OF_SKIPPED_ALLOWED}    ${MAX_NUMBER_OF_SKIPPED_ALLOWED}    children=${True}
    Set Suite Variable    ${DESCRIPTION}    ${DESCRIPTION}    children=${True}
    Set Suite Variable    ${LOCATION}    ${LOCATION}    children=${True}

Assert Elastic Results
    [Arguments]    ${test_steps}    ${testRunUUID}    ${scenario}
    [Documentation]    Get the result from elasticsearch , quering by the testRunUUID
    ...    + Check result of each step on the test_steps list variable is "passed"
    ...    TO BE REVIEW WHEN PATH WORKS TO CHECK HOW IS REPORTED TO ELASTIC SEARCH AND HOW TO IMPROVE THIS KEYWORD
    : FOR    ${test_step_name}    IN    @{test_steps}
    \    ${test_result}    Xagget.Get Test Result    ${CONF}    ${testRunUUID}    ${scenario}::${test_step_name}
    \    Log Dictionary    ${test_result}
    \    Run Keyword And Continue On Failure    Assert Test Result    ${test_result}    ${test_step_name}
    [Return]    ${test_result}

Assert Test Result
    [Arguments]    ${test_dict}    ${test_step_name}
    [Documentation]    Checking elasticsearch return doesn't contain any fail status on the test step name result. (result = 'passed')
    Run Keyword If    '${test_dict["result"]}' != 'passed'    Set Suite Variable    ${failedReason}    ${failedReason} * ${test_step_name}:${test_dict["result"]}
    Should Be Equal As Strings    ${test_dict["result"]}    passed    The test has been ${test_dict["result"]} due to ${test_dict["failedReason"]}

Check ResultStateCount No Fails
    [Arguments]    ${resultStateCount}    ${scenario}    ${routers}
    [Documentation]    Checking Xagget ResultStateCount return doesn't contain any fail result
    ...    List of fails (err_key_name): error, actions-failed, pre-actions-failed, data-missing, data-failed, failed, state-error, state-missing,
    ...    state-timeout
    ...    NOTE: skipped is not on the list so it will not be consider
    : FOR    ${err_key_name}    IN    error    actions-failed   pre-actions-failed    data-missing    data-failed
    ...    failed    state-error    state-missing   state-timeout
    \    ${value}    Evaluate    ${resultStateCount}.get('${err_key_name}')
    \    Run Keyword If    ${value}!= None    Set Suite Variable    ${failedReason}    Errors running Xagget (${scenario} + routers: ${routers}): ${resultStateCount}
    \    Dictionary Should Not Contain Key    ${resultStateCount}    ${err_key_name}

Check CompletionState No Errors
    [Arguments]    ${completionState}    ${scenario}    ${routers}
    [Documentation]    Checking Xagget return completionState json section doesn't contain any error or errors
    ...    This mean that the tests wasn't run properly on Xagget some of the teststeps fails to be run on Xagget CPE
    : FOR    ${err_key_name}    IN    error    errors
    \    ${value}    Evaluate    ${completionState}.get('${err_key_name}')
    \    Run Keyword If    ${value}!= None    Set Suite Variable    ${failedReason}    Errors running Xagget (${scenario} + routers: ${routers}): ${value}
    \    Dictionary Should Not Contain Key    ${completionState}    ${err_key_name}

Check CompletionState No Specific Errors
    [Arguments]    ${completionState}    ${scenario}    ${routers}
    [Documentation]    Checking Xagget return completionState[errors] json section doesn't contain any expired,fatal
    ...    This mean that the tests wasn't run properly on Xagget some of the teststeps fails to be run on Xagget CPE
    : FOR    ${err_key_name}    IN    expired    fatal
    \    ${value}    Evaluate    ${completionState["errors"]}.get('${err_key_name}')
    \    Run Keyword If    ${value}!= None    Set Suite Variable    ${failedReason}    Errors running Xagget - expired or fatal (${scenario} + routers: ${routers}): ${value}
    \    Dictionary Should Not Contain Key    ${completionState}    ${err_key_name}

Check Skipped Percentage
    [Arguments]    ${TEST_RUN_RESULT}    ${allow_percentage}=20
    [Documentation]    Check the number for skipped Xagget tests are not more than the allow_percentage_skipped(%)
    Log    allow_percentage: ${allow_percentage}
    ${allow_percentage_skipped}    Evaluate    ${allow_percentage}*0.001
    Log    allow_percentage_skipped: ${allow_percentage_skipped}
    Set Suite Variable    ${err_key_name}    skipped
    Set Suite Variable    ${percentage}    ${EMPTY}
    Set Suite Variable    ${skipped_percentage_reached}    ${FALSE}
    ${number_of_steps_run}    Evaluate    ${TEST_RUN_RESULT["completionState"]}.get('firedCount')
    ${number_of_steps_run}    Run Keyword If    ${number_of_steps_run}!= None    Convert To Number    ${number_of_steps_run}
    ${number_of_skipped}    Evaluate    ${TEST_RUN_RESULT["completionState"]["resultStateCount"]}.get('${err_key_name}')
    ${number_of_skipped}    Run Keyword If    ${number_of_skipped}!= None and ${number_of_steps_run}!= None    Convert To Number    ${number_of_skipped}
    ${skipped_percentage}    Run Keyword If    ${number_of_skipped}!= None and ${number_of_steps_run}!= None    Evaluate    ${number_of_skipped}/${number_of_steps_run}
    Log    skipped_percentage: ${skipped_percentage}
    ${skipped_percentage_reached}    Run Keyword If    ${skipped_percentage}!= None    Evaluate    ${skipped_percentage} > ${allow_percentage_skipped}
    Log    skipped_percentage_reached: ${skipped_percentage_reached}
    ${skipped_percentage}    Run Keyword If    ${skipped_percentage}!= None    Evaluate    ${skipped_percentage}*100
    Run Keyword If    ${skipped_percentage_reached}    Set Suite Variable    ${failedReason}    Errors running Xagget: More than ${allow_percentage}% (actual:${skipped_percentage}%) of tests are Skipped: ${TEST_RUN_RESULT["completionState"]["resultStateCount"]}
    Should Not Be True    ${skipped_percentage_reached}

Check Skipped Number
    [Arguments]    ${TEST_RUN_RESULT}    ${max_number_of_skipped_allow}=1
    [Documentation]    Check the number for skipped Xagget tests are not more than the max_number_of_skipped_allow(by default 1)
    Log    max_number_of_skipped_allow: ${max_number_of_skipped_allow}
    Log To Console    max_number_of_skipped_allow: ${max_number_of_skipped_allow}
    Set Suite Variable    ${err_key_name}    skipped
    Set Suite Variable    ${number_of_maximum_skipped_reached}    ${FALSE}
    ${number_of_steps_run}    Evaluate    ${TEST_RUN_RESULT["completionState"]}.get('firedCount')
    ${number_of_steps_run}    Run Keyword If    ${number_of_steps_run}!= None    Convert To Number    ${number_of_steps_run}
    ${number_of_skipped}    Evaluate    ${TEST_RUN_RESULT["completionState"]["resultStateCount"]}.get('${err_key_name}')
    ${number_of_skipped}    Run Keyword If    ${number_of_skipped}!= None and ${number_of_steps_run}!= None    Convert To Number    ${number_of_skipped}
    ${number_of_maximum_skipped_reached}    Run Keyword If    ${number_of_skipped}!= None    Evaluate    ${number_of_skipped} > ${max_number_of_skipped_allow}
    Log    number_of_maximum_skipped_reached: ${number_of_maximum_skipped_reached}
    Run Keyword If    ${number_of_maximum_skipped_reached}    Set Suite Variable    ${failedReason}    Errors running Xagget: More than ${max_number_of_skipped_allow} (actual:${number_of_skipped}) of tests are Skipped: ${TEST_RUN_RESULT["completionState"]["resultStateCount"]}
    Should Not Be True    ${number_of_maximum_skipped_reached}

Check CPE VERSION XAGGET
    [Arguments]    ${test_result_dict}
    [Documentation]    BETA - Check CPE version (from Xagget testsresult) and compare it with the config file CPE_FW_VERSION variable,
    ...    be sure that the
    ${value}    Evaluate    ${test_result_dict}.get("cpe")
    Set Suite Variable    ${ACTUAL_CPE_BUILD_XAGGET}    ${EMPTY}
    Run Keyword If    ${value}.get("version")!= None    Set Suite Variable    ${ACTUAL_CPE_BUILD_XAGGET}    ${test_result_dict["cpe"]["version"]}
    Run Keyword If    ${value}.get("version")!= None    @{Split_items}    Split String    ${ACTUAL_CPE_BUILD_XAGGET}    -
    Run Keyword If    ${value}.get("version")!= None    Set Suite Variable    ${ACTUAL_CPE_BUILD_XAGGET}    ${Split_items[4]}-${Split_items[5]}
    Log    ${ACTUAL_CPE_BUILD_XAGGET}
    Log    ${CPE_FW_VERSION}
    Should Be Equal    ${ACTUAL_CPE_BUILD_XAGGET}    ${CPE_FW_VERSION}

Run XAGGET Sanity Scenario
    [Documentation]    Run Xagget Sanity Test - This should be call on the Suite Setup of each test Suite (txt file)
    ...    We will use XAP to enable the cpe.uiTestTools - No other actions
    ${enable_test_tools}    Enable Test Tools    ${E2E_CONF["${LAB_NAME}"]}    ${CPE_ID}
    Log    enable_test_tools: ${enable_test_tools}
    Log    enable_test_tools status_code: ${enable_test_tools[0]}
    Log    enable_test_tools payload: ${enable_test_tools[2]["payload"]}
    ${failedReason}    Set Variable If    ${enable_test_tools[0]} != 200 or ${enable_test_tools[2]["payload"]} != None    XAP enable tests tools NOT working - Sanity FAILs
    Should Be Equal As Integers    ${enable_test_tools[0]}    200
    Should Be Equal    "${enable_test_tools[2]["payload"]}"    "None"

Run XAGGET CPE Sanity Only JSON Scenario
    [Arguments]    ${sanity_scenario}=sanity_xap/sanity_xap_${LAB_NAME}.json
    [Documentation]    Run Xagget Sanity Test - This should be call on the Suite Setup of each test Suite (txt file)
    ...    Run sanity scenario: sanity_xap/sanity_xap_{LAB_NAME}.json (dafult value) to be sure that the CPE is ready
    ...    NOTE: test_steps is not an argument because by default we can not create the list - So manuall vars (Actual value list: ["PREPARE STB"])
    Log    sanity_scenario: ${sanity_scenario}
    ${test_steps}    Create List    PREPARE STB
    Log    Run XAGGET CPE Sanity - test_steps(To be check on Elasticsearch): ${test_steps}
    ${test_result_dict}    Run XAGGET Scenario And Assert Results    ${sanity_scenario}    ${test_steps}
    Log    ${test_result_dict}
    Set Suite Variable    ${failedReason}    Sanity of CPE Fail
    Check CPE VERSION XAGGET    ${test_result_dict}

Run XAGGET CPE Sanity
    [Arguments]    ${sanity_scenario}=sanity_xap/sanity_xap_${LAB_NAME}.json
    [Documentation]    Run Xagget Sanity Test - This should be call on the Suite Setup of each test Suite (txt file)
    ...    We will use XAP to enable the cpe.uiTestTools
    ...    + Run sanity scenario: sanity_xap/sanity_xap_{LAB_NAME}.json (dafult value) to be sure that the CPE is ready
    ...    NOTE: test_steps is not an argument because by default we can not create the list - So manuall vars (Actual value list: ["PREPARE STB"])
    Log    sanity_scenario: ${sanity_scenario}
    ${test_steps}    Create List    PREPARE STB
    Log    Run XAGGET CPE Sanity - test_steps(To be check on Elasticsearch): ${test_steps}
    ${enable_test_tools}    Enable Test Tools    ${E2E_CONF["${LAB_NAME}"]}    ${CPE_ID}
    Log    enable_test_tools: ${enable_test_tools}
    ${failedReason}    Set Variable If    ${enable_test_tools[0]} != 200 or ${enable_test_tools[2]["payload"]} != None    XAP enable tests tools NOT working - Sanity FAILs
    Log    enable_test_tools status_code: ${enable_test_tools[0]}
    Log    enable_test_tools payload: ${enable_test_tools[2]["payload"]}
    Should Be Equal As Integers    ${enable_test_tools[0]}    200
    Should Be Equal    "${enable_test_tools[2]["payload"]}"    "None"
    ${test_result_dict}    Run XAGGET Scenario And Assert Results    ${sanity_scenario}    ${test_steps}
    Log    ${test_result_dict}
    Set Suite Variable    ${failedReason}    Sanity of CPE Fail
    Check CPE VERSION XAGGET    ${test_result_dict}

Run XAGGET Without Checks
    [Arguments]    ${scenario}    ${routers}=${None}    ${function_name}=filterOnScenarios    ${duration}=${None}    ${mode}=sequential    # test_steps is a list of a scenario's test steps and may not contain all steps of the scenario
    [Documentation]    Run Xagget testRun but Only check if mayor errors on testsRun, not check tests Steps results.
    ...    It will fail if the [completionState] contains a section: error or errors , so we have an error on the Mint(PI) level
    ${TEST_RUN_RESULT}    Xagget.Run Xagget Scenario    ${CONF}    ${XAGGET_REPO}    ${scenario}    ${CPE_ID}    ${duration}
    ...    ${routers}    ${function_name}    ${mode}
    Log Dictionary    ${TEST_RUN_RESULT}
    Set Suite Variable    ${resultLink}    ${TEST_RUN_RESULT["monitorUrl"]}
    Set Suite Variable    ${failedReason}    ${TEST_RUN_RESULT["completionState"]["resultStateCount"]}
    Log    testRunUUID: ${TEST_RUN_RESULT["testRunUUID"]}
    Log Dictionary    ${TEST_RUN_RESULT["completionState"]}
    ${value}    Evaluate    ${TEST_RUN_RESULT["completionState"]}.get("errors")
    Run Keyword If    ${value}!= None    Check CompletionState No Specific Errors    ${TEST_RUN_RESULT["completionState"]}    ${scenario}    ${routers}
    [Return]    ${TEST_RUN_RESULT}

Run XAGGET Scenario And Assert Results
    [Arguments]    ${scenario}    ${test_steps}    ${routers}=${None}    ${function_name}=filterOnScenarios    ${duration}=${None}    # test_steps is a list of a scenario's test steps and may not contain all steps of the scenario
    [Documentation]    Run Xagget testRun but Only check if mayor errors on testsRun, not check tests Steps results
    ...    but then we will check each test step of the variable {test_steps} on Elasticsearch to be sure
    ...    that the result of this steps are "passed" if NOT this keyword will fail. (NOTE: "skipped" will also made it fail)
    ...    NOTE: The test_steps variable right now is manually provide on the testcase level and it
    ...    should contain the steps names which result need to be checked
    ${TEST_RUN_RESULT}    Run XAGGET Without Checks    ${scenario}    ${routers}    ${function_name}
    ${test_result}    Assert Elastic Results    ${test_steps}    ${TEST_RUN_RESULT["testRunUUID"]}    ${scenario}
    [Return]    ${test_result}

Run XAGGET
    [Arguments]    ${scenario}    ${routers}=${None}    ${function_name}=filterOnScenarios    ${duration}=${None}    ${mode}=sequential    # test_steps is a list of a scenario's test steps and may not contain all steps of the scenario
    [Documentation]    Run Xagget testRun checking tests Steps results
    ...    Tests case will fail if the [resultStateCount] contains actions-failed, error, data-missing, failed
    ...    data-failed, state-error, pre-actions-failed [Check ResultStateCount No Fails]
    ...    + Check number of skipped tests is less than 2(default value) [Check Skipped Number]
    ${TEST_RUN_RESULT}    Run XAGGET Without Checks    ${scenario}    ${routers}    ${function_name}    ${duration}    ${mode}
    Check ResultStateCount No Fails    ${TEST_RUN_RESULT["completionState"]["resultStateCount"]}    ${scenario}    ${routers}
    Log   MAX_NUMBER_OF_SKIPPED_ALLOWED(If -1 is NOT used): ${MAX_NUMBER_OF_SKIPPED_ALLOWED}
    Run Keyword If    ${MAX_NUMBER_OF_SKIPPED_ALLOWED} != -1    Check Skipped Number    ${TEST_RUN_RESULT}    ${MAX_NUMBER_OF_SKIPPED_ALLOWED}
    ${number_of_steps_run}    Evaluate    ${TEST_RUN_RESULT["completionState"]}.get('firedCount')
    ${number_of_steps_run}    Run Keyword If    ${number_of_steps_run}!= None    Convert To Number    ${number_of_steps_run}
    Log    ${number_of_steps_run}
    Run Keyword If    0 < ${number_of_steps_run} < 3    Check Skipped Number    ${TEST_RUN_RESULT}    0
    ...    ELSE    Check Skipped Number    ${TEST_RUN_RESULT}

Run XAGGET with skipped percentage
    [Arguments]    ${scenario}    ${routers}=${None}    ${function_name}=filterOnScenarios    ${duration}=${None}    # test_steps is a list of a scenario's test steps and may not contain all steps of the scenario
    [Documentation]    Run Xagget testRun checking tests Steps results
    ...    Tests case will fail if the [resultStateCount] contains actions-failed, error, data-missing, failed
    ...    data-failed, state-error, pre-actions-failed [Check ResultStateCount No Fails]
    ...    + Check percentage of skipped tests is less than 20%(default value) [Check Skipped Percentage]
    ${TEST_RUN_RESULT}    Run XAGGET Without Checks    ${scenario}    ${routers}    ${function_name}
    Check ResultStateCount No Fails    ${TEST_RUN_RESULT["completionState"]["resultStateCount"]}    ${scenario}    ${routers}
    Check Skipped Percentage    ${TEST_RUN_RESULT}

Run XAGGET And Assert Results
    [Arguments]    ${scenario}    ${test_steps}    ${routers}=${None}    ${function_name}=filterOnScenarios    ${duration}=${None}    # test_steps is a list of a scenario's test steps and may not contain all steps of the scenario
    [Documentation]    Run Xagget testRun checking tests Steps results
    ...    Tests case will fail if the [resultStateCount] contains actions-failed, error, data-missing, failed
    ...    data-failed, state-error, pre-actions-failed [Check ResultStateCount No Fails] (NOTE: On this case "skipped" is not consider fail)
    ...    + Check percentage of skipped tests is less than 20%(default value) [Check Skipped Percentage]
    ...    + Check the test_steps (var - list of steps to check in elastic) elastic result is "passed" (NOTE: On this case "skipped" will also made it fail)
    ${TEST_RUN_RESULT}    Run XAGGET Without Checks    ${scenario}    ${routers}    ${function_name}
    Check ResultStateCount No Fails    ${TEST_RUN_RESULT["completionState"]["resultStateCount"]}    ${scenario}    ${routers}
    Check Skipped Percentage    ${TEST_RUN_RESULT}
    ${test_result}    Assert Elastic Results    ${test_steps}    ${TEST_RUN_RESULT["testRunUUID"]}    ${scenario}
    Log    failedReason: ${failedReason}
    [Return]    ${test_result}

Run XAGGET Without Checks And Return TestRunID
    [Arguments]    ${scenario}    ${routers}=${None}    ${function_name}=filterOnScenarios    ${duration}=${None}    # test_steps is a list of a scenario's test steps and may not contain all steps of the scenario
    [Documentation]    Run Xagget testRun but Only check if major errors on testsRun, not check tests Steps results.
    ...    It will fail if the [completionState] contains a section: error or errors , so we have an error on the Mint(PI) level. Also returns the Test Run ID
    ${TEST_RUN_RESULT}    Xagget.Run Xagget Scenario    ${CONF}    ${XAGGET_REPO}    ${scenario}    ${CPE_ID}    ${duration}
    ...    ${routers}    ${function_name}
    Log Dictionary    ${TEST_RUN_RESULT}
    Set Suite Variable    ${resultLink}    ${TEST_RUN_RESULT["monitorUrl"]}
    Set Suite Variable    ${failedReason}    ${TEST_RUN_RESULT["completionState"]["resultStateCount"]}
    Log    testRunUUID: ${TEST_RUN_RESULT["testRunUUID"]}
    Log Dictionary    ${TEST_RUN_RESULT["completionState"]}
    Check CompletionState No Errors    ${TEST_RUN_RESULT["completionState"]}    ${scenario}    ${routers}
    [Return]    ${TEST_RUN_RESULT}    ${TEST_RUN_RESULT["testRunUUID"]}

Get Result Document URL
    [Arguments]    ${CONF}    ${TEST_RUN_ID}    ${TEST_STEP_NAME}
    [Documentation]    A keyword to get Test Result URL for a specific Test Run ID and test step name
    ${URL}    GET TEST RESULT URL FROM ELASTIC    ${CONF}    ${TEST_RUN_ID}    ${TEST_STEP_NAME}
    [Return]    ${URL}

Get Result Details From Kibana Document Based On Key
    [Arguments]    ${CONF}    ${URL}
    [Documentation]    A keyword to get details from test result based on the key.
    ${UI_DATA}    Get Result Detail Based On Key    ${CONF}    ${URL}
    [Return]    ${UI_DATA}
