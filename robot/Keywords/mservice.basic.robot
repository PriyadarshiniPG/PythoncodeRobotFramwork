*** Settings ***
Library           SSHLibrary
Library           String
Library           Collections
Library           OperatingSystem
Library           ../Libraries/MicroServices/VodService/
Library           ../Libraries/MicroServices/RecordingService/
Library           ../Libraries/Backend/Traxis/
Resource          ../Keywords/cdn.basic.robot
#Resource          ../Keywords/MicroServices/PersonalizationService/PersonalizationService_Keywords.robot

*** Keywords ***
Set Suite Variables
    ${LAB_NAME}    Get Lab Name From Jenkins
    Set Suite Variable    ${LAB_CONF}    ${E2E_CONF["${LAB_NAME}"]}
    Log    ${LAB_CONF}
    ${COUNTRY}    Get Country From Jenkins
    ${CPE_ID}    Get Cpeid From Jenkins
    ${LANGUAGE}    Get Language From Jenkins
    ${ROOT_ID}    Get Root ID From Jenkins
    ${CUSTOMER_ID}    I Get Customer Id From Personalization Service
    ${CITY_ID}    Get cityID via personalization service if it is default    city_id=default
    Set Suite Variable    ${failedReason}    ${EMPTY}    children=true
    Set Suite Variable    ${firstTestCaseFail}    ${EMPTY}

Get Country From Jenkins
    [Arguments]    ${var_name}=COUNTRY    ${default}=${LAB_CONF["country"]}
    ${COUNTRY}    Get Environment Variable    ${var_name}    ${default}    # This variable is expected to be defined in Jenkins
    Set Suite Variable    ${COUNTRY}    ${COUNTRY}    children=true
    [Return]    ${COUNTRY}

Get Language From Jenkins
    [Arguments]    ${var_name}=LANGUAGE    ${default}=${LAB_CONF["default_language"]}
    ${LANGUAGE}    Get Environment Variable    ${var_name}    ${default}    # This variable is expected to be defined in Jenkins
    Set Suite Variable    ${LANGUAGE}    ${LANGUAGE}    children=true
    [Return]    ${LANGUAGE}

Get Cpeid From Jenkins
    [Arguments]    ${var_name}=CPE_ID    ${default}=${LAB_CONF["CPE_ID"]}
    ${CPE_ID}    Get Environment Variable    ${var_name}    ${default}    # This variable is expected to be defined in Jenkins
    Set Suite Variable    ${CPE_ID}    ${CPE_ID}    children=true
    [Return]    ${CPE_ID}

Get Searchterm From Jenkins
    [Arguments]    ${var_name}=SEARCH_TERM    ${default}=new
    ${SEARCH_TERM}    Get Environment Variable    ${var_name}    ${default}    # This variable is expected to be defined in Jenkins
    Set Suite Variable    ${SEARCH_TERM}    ${SEARCH_TERM}    children=true
    [Return]    ${SEARCH_TERM}

Get Root Id From Jenkins
    [Arguments]    ${var_name}=ROOT_ID    ${default}=${LAB_CONF["root_id"][0]}
    ${ROOT_ID}    Get Environment Variable    ${var_name}    ${default}    # This variable is expected to be defined in Jenkins
    Set Suite Variable    ${ROOT_ID}    ${ROOT_ID}    children=true
    [Return]    ${ROOT_ID}

Get City Id From Jenkins
    [Arguments]    ${var_name}=CITY_ID    ${default}=${LAB_CONF["city_id"][0]}
    ${CITY_ID}    Get Environment Variable    ${var_name}    ${default}    # This variable is expected to be defined in Jenkins
    Set Suite Variable    ${CITY_ID}    ${CITY_ID}    children=true
    [Return]    ${CITY_ID}

Get Screentitle From Jenkins
    [Arguments]    ${var_name}=SCREEN_TITLE    ${default}=${LAB_CONF["scr_title_nodes"]["nl"]["screen_title"][2]}
    ${SCREEN_TITLE}    Get Environment Variable    ${var_name}    ${default}    # This variable is expected to be defined in Jenkins
    Set Suite Variable    ${SCREEN_TITLE}    ${SCREEN_TITLE}    children=true
    [Return]    ${SCREEN_TITLE}

Get Seriesnodenamenl From Jenkins
    [Arguments]    ${var_name}=SERIES_NODE_NAME_NL    ${default}=${LAB_CONF["scr_title_nodes"]["nl"]["series_node_name"][0]}
    ${SERIES_NODE_NAME_NL}    Get Environment Variable    ${var_name}    ${default}    # This variable is expected to be defined in Jenkins
    Set Suite Variable    ${SERIES_NODE_NAME_NL}    ${SERIES_NODE_NAME_NL}    children=true
    [Return]    ${SERIES_NODE_NAME_NL}

Get Clienttype From Jenkins
    [Arguments]    ${var_name}=CLIENT_TYPE    ${default}=399
    ${CLIENT_TYPE}    Get Environment Variable    ${var_name}    ${default}    # This variable is expected to be defined in Jenkins
    Set Suite Variable    ${CLIENT_TYPE}    ${CLIENT_TYPE}    children=true
    [Return]    ${CLIENT_TYPE}

Get Maxresult From Jenkins
    [Arguments]    ${var_name}=MAX_RESULT    ${default}=10
    ${MAX_RESULT}    Get Environment Variable    ${var_name}    ${default}    # This variable is expected to be defined in Jenkins
    Set Suite Variable    ${MAX_RESULT}    ${MAX_RESULT}    children=true
    [Return]    ${MAX_RESULT}

Check Healthy Status
    [Arguments]    ${json_response}
    : FOR    ${server}    IN    @{json_response.items()}
    \    Run Keyword And Continue On Failure    Should Be Equal    '''${server[1]['healthy']}'''    '''True'''
    \    ${failedReason}    Set Variable If    ${server[1]['healthy']} == False    ${failedReason} ${server[0]} connection is not healthy

Check Epg Index
    [Arguments]    ${json_response}
    : FOR    ${entry}    IN    @{json_response['entries']}
    \    Log    ${entry['channelIds'][0]}
    \    ${segment_length}    Get Length    ${entry['segments']}
    \    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${segment_length}    21
    \    ${failedReason}    Set Variable If    ${segment_length} != 21    ${failedReason} Channel ${entry['channelIds'][0]} contains ${segment_length} segments

Check Element In Dictionary
    [Arguments]    ${dictionary}    ${element}
    ${keys}    Get Dictionary Keys    ${dictionary}
    Log    Keys: ${keys}
    Log    element to check if it presetn on Keys: ${element}
    ${is_element_present}    Run Keyword And Return Status    Should Contain    ${keys}    ${element}
    Log    is_key_present: ${is_element_present}
    ${failedReason}    Run Keyword If    ${is_element_present} == False    Set Variable    ${failedReason} - Element: ${element} not in Dictionary ${dictionary}
    Dictionary Should Contain Key    ${dictionary}    ${element}

Get Screen Crid From Screen Title
    [Arguments]    ${json_response}    ${screen_name}
    Log    ${screen_name}
    : FOR    ${screen}    IN    @{json_response['screens']}
    \    Log    ${screen}
    \    ${is_equal}    Run Keyword And Return Status    Should Be Equal As Strings    ${screen['title']}    ${screen_name}    ignore_case=${True}
    \    ${screen_crid}    Run Keyword And Continue On Failure    Set Variable If    ${is_equal}    ${screen['id']}
    \    Run Keyword If    '''${screen_crid}''' != '''${None}'''    Exit For Loop
    Log    ${screen_crid}
    [Return]    ${screen_crid}

Get Vod Full Vod Structure
    Get Root Id From Purchase Service
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${structure_response}    Get Vod Structure    ${LAB_CONF}    ${COUNTRY}    ${OSD_LANGUAGE}    ${customerid}    ${cpe_profile_id}    ${ROOT_ID}
    Log    ${structure_response}
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${structure_response.status_code}    200
    ${failedReason}    Run Keyword If    ${structure_response.status_code} == None    Log Response    ${http_response}    ${failedReason} Could Not retrieve VOD Service url:
    ${failedReason}    Run Keyword If    ${structure_response.status_code} != ${None} and ${structure_response.status_code} \ != 200    Set Variable    VOD Structure call returns ${http_response.status_code}
    ...    ELSE    Set Variable    ${failedReason}
    ${structure_json}    Run Keyword If    ${structure_response.status_code} == 200    Set Variable    ${structure_response.json()}
    Set Suite Variable    ${structure_json}    ${structure_json}
    Log    ${structure_json}
    [Return]    ${structure_json}

Get Vod GridScreen From Screen Title
    [Arguments]    ${structure_json}    ${screen_title}
    ${screen_crid}    Get Screen Crid From Screen Title    ${structure_json}    ${screen_title}
    Log    ${screen_crid}
    ${grid_response}    Get Vod Gridscreen    ${LAB_CONF}    ${COUNTRY}    ${LANGUAGE}    ${customerid}    ${ROOT_ID}
    ...    ${screen_crid}    False
    Log    ${grid_response}
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${grid_response.status_code}    200
    ${failedReason}    Set Variable If    ${grid_response.status_code} != 200 and ${grid_response.status_code} != ${None}    VOD ${screen_title} Screen request returns ${${grid_response.status_code}    ${failedReason}
    ${failedReason}    Set Variable If    ${grid_response.status_code} == ${None}    VOD ${screen_title} Screen request did not return a response    ${failedReason}
    ${grid_json}    Run Keyword If    ${grid_response.status_code} == 200    Set Variable    ${grid_response.json()}
    Set Suite Variable    ${grid_json}    ${grid_json}
    Log    ${grid_json}
    [Return]    ${grid_json}

Get Vod Screen From Screen Title    #USED
    [Arguments]    ${structure_json}    ${screen_title}    ${opt_in}=${False}
    Get Root Id From Purchase Service
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${screen_crid}    Get Screen Crid From Screen Title    ${structure_json}    ${screen_title}
    Log    ${screen_crid}
    ${screen_response}    Get Vod Screen    ${LAB_CONF}    ${COUNTRY}    ${OSD_LANGUAGE}    ${customerid}    ${cpe_profile_id}    ${ROOT_ID}
    ...    ${screen_crid}    ${opt_in}
    Log    ${screen_response}
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${screen_response.status_code}    200
    ${failedReason}    Set Variable If    ${screen_response.status_code} != 200 and ${screen_response.status_code} != ${None}    VOD ${screen_title} Screen request returns ${screen_response.status_code}    ${failedReason}
    ${failedReason}    Set Variable If    ${screen_response.status_code} == ${None}    VOD ${screen_title} Screen request did not return a response    ${failedReason}
    ${screen_json}    Run Keyword If    ${screen_response.status_code} == 200    Set Variable    ${screen_response.json()}
    Set Suite Variable    ${screen_json}    ${screen_json}
    Log    ${screen_json}
    Return From Keyword If    ${screen_json} == ${None}    "None"
    [Return]    ${screen_json}

Get Vod Screen From Crid
    [Arguments]    ${structure_json}    ${screen_crid}
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${screen_response}    Get Vod Screen    ${LAB_CONF}    ${COUNTRY}    ${OSD_LANGUAGE}    ${customerid}    ${cpe_profile_id}    ${ROOT_ID}
    ...    ${screen_crid}    False
    Log    ${screen_response}
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${screen_response.status_code}    200
    ${failedReason}    Set Variable If    ${screen_response.status_code} != 200 and ${screen_response.status_code} != ${None}    VOD ${screen_crid} Screen request returns ${screen_response.status_code}    ${failedReason}
    ${failedReason}    Set Variable If    ${screen_response.status_code} == ${None}    VOD ${screen_crid} Screen request did not return a response    ${failedReason}
    ${screen_json}    Run Keyword If    ${screen_response.status_code} == 200    Set Variable    ${screen_response.json()}
    Set Suite Variable    ${screen_json}    ${screen_json}
    Log    ${screen_json}
    [Return]    ${screen_json}

Get Vod Details From Asset Crid
    [Arguments]    ${asset_crid}    ${asset_type}=vod
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${details_response}    Get Vod Detailscreen    ${LAB_CONF}    ${COUNTRY}    ${OSD_LANGUAGE}    ${customerid}    ${cpe_profile_id}    ${asset_crid}
    Log    ${details_response}
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${details_response.status_code}    200
    ${failedReason}    Set Variable If    ${details_response.status_code} != 200 and ${details_response.status_code} != ${None}    Asset: ${asset_crid} - Type: ${asset_type} request returns ${details_response.status_code}    ${failedReason}
    ${failedReason}    Set Variable If    ${details_response.status_code} == ${None}    Asset: ${asset_crid} - Type: ${asset_type} request did not return a response    ${failedReason}
    ${details_json}    Run Keyword If    ${details_response.status_code} == 200    Set Variable    ${details_response.json()}
    Set Suite Variable    ${details_json}    ${details_json}
    Log    ${details_json}
    [Return]    ${details_json}

Get Vod Most Relevant Episode From Crid
    [Arguments]    ${crid}    ${type}
    ${mostrelevant_response}    Get Vod Mostrelevantepisode    ${LAB_CONF}    ${COUNTRY}    ${LANGUAGE}    ${customerid}    ${crid}
    ...    ${type}
    Log    ${mostrelevant_response}
    Log    STATUS: ${mostrelevant_response.status_code}
    Log    JSON: ${mostrelevant_response.json()}
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${mostrelevant_response.status_code}    200
    ${failedReason}    Set Variable If    ${mostrelevant_response.status_code} != 200 and ${mostrelevant_response.status_code} != ${None}    Asset: ${crid} request returns ${mostrelevant_response.status_code}    ${failedReason}
    ${failedReason}    Set Variable If    ${mostrelevant_response.status_code} == ${None}    Asset: ${crid} request did not return a response    ${failedReason}
    ${mostrelevant_json}    Run Keyword If    ${mostrelevant_response.status_code} == 200    Set Variable    ${mostrelevant_response.json()}
    Set Suite Variable    ${mostrelevant_json}    ${mostrelevant_json}
    Log    ${mostrelevant_json}
    [Return]    ${mostrelevant_json}

Get Random Element From Array    #USED
    [Arguments]    ${json}    ${key}=${EMPTY}
    ${length}    Get Length    ${json}
    ${random int}    Evaluate    random.randint(0,$length-1)    modules=random
    Log    Element selected randomly: ${json[${random int}]${key}}
    [Return]    ${json[${random int}]${key}}

Get Random Element From Array With Exception
    [Arguments]    ${json}    ${key}=${EMPTY}    ${exception}=${EMPTY}    ${exception_key}=${key}
    : FOR    ${i}    IN RANGE    99
    \    ${random int}    Evaluate    random.randint(0,len(${json})-1)    modules=random
    \    Log    ${json[${random int}]${key}}
    \    ${result_exception}    Run Keyword And Return Status    Should Not Contain    ${exception}    ${json[${random int}]${exception_key}}
    \    Log    ${result_exception}
    \    Exit For Loop If    ${result_exception}
    Log    Exited
    Log    Element selected randomly: ${json[${random int}]${key}}
    [Return]    ${json[${random int}]${key}}    ${i}

Get Structure Vod
    [Arguments]    ${cust_id}    ${profile_id}
    ${structure_response}    VodService.Get Vod Structure    ${LAB_CONF}    ${COUNTRY}    ${LANGUAGE}    ${cust_id}    ${profile_id}    ${ROOT_ID}
    Log    ${structure_response.json()}
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${structure_response.status_code}    200
    ${failedReason}    Run Keyword If    ${structure_response.status_code} == None    Log Response    ${http_response}    ${failedReason} Could Not retrieve VOD Service url:
    ${failedReason}    Run Keyword If    ${structure_response.status_code} != ${None} and ${structure_response.status_code} \ != 200    Set Variable    VOD Structure call returns ${http_response.status_code}
    ...    ELSE    Set Variable    ${failedReason}
    ${structure_json}    Run Keyword If    ${structure_response.status_code} == 200    Set Variable    ${structure_response.json()}
    Set Suite Variable    ${structure_json}    ${structure_json}
    Log    ${structure_json}
    [Return]    ${structure_json}    ${structure_response}

Reng Search
    [Arguments]    ${LAB_CONF}    ${customer_id}    ${node}
    ${SEARCH_TERM}    Get Searchterm From Jenkins    SEARCH_TERM    Ant
    ${CLIENT_TYPE}    Get Clienttype From Jenkins    CLIENT_TYPE    399
    ${MAX_RESULT}    Get Maxresult From Jenkins    MAX_RESULT    20
    ${dict}    Create Dictionary    customer_id=${customer_id}    client_type=${CLIENT_TYPE}    search_term=${SEARCH_TERM}    max_results=${MAX_RESULT}    node_name=${node}
    ${response_codes}    ${response_times}    Run Library Keyword X Times    ${LAB_CONF}    RENG.Reng Search    ${dict}    count=${REQUESTS_COUNT}
    ${failedReason}    Set Variable If    len(${response_codes})==0    No requests (out of ${REQUESTS_COUNT}) to ${url} returned response    ${EMPTY}

Reng Search Vip
    [Arguments]    ${LAB_CONF}    ${customer_id}    ${node}
    ${SEARCH_TERM}    Get Searchterm From Jenkins    SEARCH_TERM    Gu
    ${CLIENT_TYPE}    Get Clienttype From Jenkins    CLIENT_TYPE    399
    ${MAX_RESULT}    Get Maxresult From Jenkins    MAX_RESULT    20
    ${dict}    Create Dictionary    customer_id=${customer_id}    client_type=${CLIENT_TYPE}    search_term=${SEARCH_TERM}    max_results=${MAX_RESULT}    node_name=${node}
    ${response_codes}    ${response_times}    Run Library Keyword X Times    ${LAB_CONF}    RENG.Reng Search Vip    ${dict}    count=${REQUESTS_COUNT}
    ${failedReason}    Set Variable If    len(${response_codes})==0    No requests (out of ${REQUESTS_COUNT}) to ${url} returned response    ${EMPTY}

Get epg segment hash for today
    [Documentation]    Keyword to get segment hash of NDR chanel for today
    Get Index From EPG
    ${segment_hash}    Set Variable    ${EMPTY}
    : FOR    ${entry}    IN    @{epg_index["entries"]}
    \    ${segment_hash}    Set Variable If    "NDR" in ${entry["channelIds"]}    ${entry["segments"][7]}    ${segment_hash}    # Take today's hash: [7]
    \    Run Keyword If    len("${segment_hash}")>0    Exit For Loop
    Run Keyword If    len("${segment_hash}")==0    Set Suite Variable    ${failedReason}    Error to get EPG segment hash for replay channel "Travel" (day offset -6)
    Should Not Be Empty    ${segment_hash}
    Log    ${segment_hash}
    Set Suite Variable    ${segment_hash}    ${segment_hash}

Get ongoing chanel episode
    [Documentation]    Keyword to get crid of ongoing episode of NDR chanel
    Get epg segment hash for today  # Will create ${segment_hash} suite variable
    Get Segment From EPG  # Will create ${epg_segment} suite variable
    Log    ${epg_segment}
    ${epoch_time_now}    Evaluate    int(time.time())    time
    : FOR    ${program}    IN    @{epg_segment["entries"][0]["events"]}
    \    ${start_time}    Set Variable    ${program["startTime"]}
    \    ${end_time}    Set Variable    ${program["endTime"]}
    \    ${crid}    Set Variable    ${program["id"]}
    \    ${result}    Set Variable If    ${epoch_time_now} > ${start_time} and ${epoch_time_now} < ${end_time}    ${True}    ${False}
    \    Run Keyword If    '${result}' == '${True}'    Exit For Loop
    ${crid}    Set Variable If    '${result}' == '${True}'    ${crid}    ${None}
    Log    ${crid}
    [Return]    ${crid}

Record N seconds of ongoing episode
    [Arguments]    ${LAB_CONF}    ${customer_id}    ${crid}=${crid}    ${duration}=5
    ${valid_response_codes}    Create List    200    201
    # Start recording
    ${start_response}    Run Keyword    RecordingService.Schedule Recording    ${LAB_CONF}    ${customer_id}    ${crid}
    ${failedReason}    Set Variable If    "${start_response.status_code}" not in "${valid_response_codes}"
    ...    Getting ${start_response.reason} status with ${start_response.status_code} code when send ${start_response.request.method} to ${start_response.url}    ${EMPTY}
    # Wait for duration
    Sleep    ${duration}
    # Stop recordind
    ${stop_response}    Run Keyword    RecordingService.Cancel Recording    ${LAB_CONF}    ${customer_id}    ${crid}
    ${failedReason}    Set Variable If    "${stop_response.status_code}" != "204"
    ...    ${failedReason}. Getting ${stop_response.reason} status with ${stop_response.status_code} code when send ${stop_response.request.method} to ${stop_response.url}    ${EMPTY}
    Set Suite Variable    ${failedReason}    ${failedReason}
    [Return]    ${start_response}    ${stop_response}


Get Screen Crids For All Collections
    [Arguments]    ${json_response}    ${screen_Layout}
    Log    ${screen_Layout}
    @{crid_list}    Create List
    : FOR    ${screen}    IN    @{json_response['screens']}
    \    Log    ${screen}
    \    ${screen_crid}    Run Keyword And Continue On Failure    Set Variable If    '''${screen['screenLayout']}''' == '''${screen_Layout}'''    ${screen['id']}
    \    Log    ${screen_crid}
    \    Append To List    ${crid_list}    ${screen_crid}
    \    Run Keyword If    '''${screen_crid}''' == '''${None}'''    Remove Values From List    ${crid_list}    ${screen_crid}
    Log List    ${crid_list}
    [Return]    ${crid_list}


Get Screen Titles For All Collections
    Setup Traxis Customer
    Should Be Empty    ${failedReason}
    ${vod_response}    Get Vod Full Vod Structure
    @{title_list}    Create List
    ${length}    Get Length    ${vod_response['screens'][0]}
    : FOR    ${screen}    IN RANGE    0    ${length}
    \    Log    ${vod_response['screens'][${screen}]}
    \    ${screen_title}    Set Variable If    ${vod_response['screens'][${screen}]}    ${vod_response['screens'][${screen}]['title']}    Vod screen title is not present
    \    Log    ${screen_title}
    \    Append To List    ${title_list}    ${screen_title}
    ${title_length}    Get Length    ${title_list}
    Run Keyword If    ${title_length}< ${length}    FAIL    msg=Unable to fetch all the titles
    [Return]    ${title_list} 

Fetch Replay Channel Id
    [Arguments]    ${isAdult}=${None}
    [Documentation]    This keyword will return the list of all replay channel for the CPE.
    ${channels}    Get Replay Channel Map    ${LAB_CONF}    ${CPE_ID}    ${isAdult}
    ${response_channels}    evaluate    json.loads('''${channels.text}''')    json
    @{replay_channels}    Create List
    : FOR    ${index}    IN RANGE    ${response_channels['Channels']['resultCount']}
    \    ${channel}    Set Variable    ${response_channels['Channels']['Channel'][${index}]['id']}
    \    Append To List    ${replay_channels}    ${channel}
    [Return]    ${replay_channels}