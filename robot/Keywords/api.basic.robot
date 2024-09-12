*** Settings ***
Library           ../Libraries/Backend/Traxis/
Library           ../Libraries/MicroServices/EpgService/
Library           ../Libraries/MicroServices/RecordingService/
Library           ../Libraries/MetaKeywords/
Resource          mservice.basic.robot
Resource          ./CPE/Common/Fixtures.robot

*** Variables ***
${channel_id_e2esi}    0001
${channel_id_superset}    NDR


*** Keywords ***
Set API Suite Variables
    Get Default Jenkins Environments Variables
    Set Suite Variables
    Set Suite Variable    ${MAX_RESPONSE_TIME}    80    children=true
    Set Suite Variable    ${AVG_RESPONSE_TIME}    80    children=true
    Set Suite Variable    ${REQUESTS_COUNT}    10    children=true

Empty failedReason
	Set Suite Variable    ${failedReason}    ${EMPTY}

Fill failedReason
    [Arguments]    ${failedReason_text}
    Set Suite Variable    ${failedReason}    ${failedReason_text}

Check Respond Status And failedReason       #USED
    [Arguments]    ${response}    ${status_code}=200
    ${failedReason}    Set Variable If    ${response.status_code} != ${status_code}    Getting ${response.reason} status with ${response.status_code} code    ${EMPTY}
    Should Be Empty     ${failedReason}     ${failedReason}

Get '${key}' from '${data}'
    [Documentation]    This keyword return the value of a key in a json
    ...    [return]  value of a key in a json
    [Return]    ${data['${key}']}

Run Library Keyword X Times
    [Arguments]    ${lab_cnf}    ${kwd_name}    ${kwd_args}=${None}    ${count}=10
    ${kwd_args}    Run Keyword If    not ${kwd_args}    Create Dictionary
    ...    ELSE    Set Variable    ${kwd_args}
    ${response_codes}    Create List
    ${response_times}    Create List
    : FOR    ${num}    IN RANGE    0    ${count}
    \    ${response}    Run Keyword    ${kwd_name}    ${lab_cnf}    &{kwd_args}
    \    Run Keyword And Ignore Error    Append To List    ${response_codes}    ${response.status_code}
    \    Run Keyword And Ignore Error    Append To List    ${response_times}    ${response.elapsed.total_seconds()}
    Set Suite Variable    ${response_codes}    ${response_codes}    children=true
    Set Suite Variable    ${response_times}    ${response_times}    children=true
    [Return]    ${response_codes}    ${response_times}

Validate Max Response Time
    [Arguments]    ${response_times}    ${expected_max}
    ${max_latency}    Evaluate    max(${response_times}) * 1000
    ${min_latency}    Evaluate    min(${response_times}) * 1000
    Set Suite Variable    ${max_latency}    ${max_latency}    children=true
    ${error_msg}    Set Variable If    ${max_latency} > ${expected_max}    Actual max response time ${max_latency} ms > expected ${expected_max} ms. Note min latency is ${min_latency} ms.    ${EMPTY}
    [Return]    ${error_msg}

Validate Avg Response Time
    [Arguments]    ${response_times}    ${expected_avg}
    ${avg_latency}    Evaluate    sum(${response_times}) / float(len(${response_times})) * 1000
    Set Suite Variable    ${avg_latency}    ${avg_latency}    children=true
    ${error_msg}    Set Variable If    ${avg_latency} > ${expected_avg}    Actual avg response time ${avg_latency} ms > expected ${expected_avg} ms.    ${EMPTY}
    [Return]    ${error_msg}

Validate Response Codes
    [Arguments]    ${response_codes}    ${validate_response}=${None}
    ${count_failed}    Set Variable    0
	${validate_response}    Run Keyword If    not ${validate_response}    Set Variable    200
    ...    ELSE    Set Variable    ${validate_response}
    : FOR    ${item}    IN    @{response_codes}
    \    ${count_failed}    Run Keyword If    ${item} != ${validate_response}    Evaluate    ${count_failed} + 1
    \    ...    ELSE    Set Variable    ${count_failed}
    ${error_msg}    Set Variable If    ${count_failed} > 0    ${count_failed} responses failed    ${EMPTY}
    [Return]    ${error_msg}

Run Library Keyword X Times With Dependency
    [Arguments]    ${lab_cnf}    ${kwd_name}    ${dep_kwd_name}    ${kwd_args}=${None}    ${dep_kwd_args}=${None}    ${count}=10
    ${kwd_args}    Run Keyword If    not ${kwd_args}    Create Dictionary
    ...    ELSE    Set Variable    ${kwd_args}
    ${response_codes}    Create List
    ${response_times}    Create List
    : FOR    ${num}    IN RANGE    0    ${count}
    \    ${response}    Run Keyword    ${kwd_name}    ${lab_cnf}    &{kwd_args}
    \    ${result}    Run Keyword    ${dep_kwd_name}    ${lab_cnf}    &{dep_kwd_args}
    \    Run Keyword And Ignore Error    Append To List    ${response_codes}    ${response.status_code}
    \    Run Keyword And Ignore Error    Append To List    ${response_times}    ${response.elapsed.total_seconds()}
    Set Suite Variable    ${response_codes}    ${response_codes}    children=true
    Set Suite Variable    ${response_times}    ${response_times}    children=true
    [Return]    ${response_codes}    ${response_times}

Validate EPG Segment
    [Arguments]    ${lab_name}    ${lab_cnf}    ${country}    ${language}    ${segment_hash_list}
    Log    ${segment_hash_list}
    : FOR    ${segment_hash}    IN    @{segment_hash_list}
    \    ${response}    Run Keyword    EpgService.Get Epg Segment    ${lab_cnf}    ${country}    ${language}    ${segment_hash}
    \    ${response_code}    Set Variable    ${response.status_code}
    \    ${failedReason}    Set Variable If    ${response_code} != 200    Getting ${response.reason} status with ${response.status_code} code when send ${response.request.method} to ${response.url}    ${EMPTY}
    \    Should Be Empty    ${failedReason}
    ${error_msg}    Set Variable If    '''${failedReason}''' != ""    data for each segment not available    ${EMPTY}
    [Return]    ${error_msg}
	
Check For Recorded Ongoing Recordings
	[Arguments]    ${recording_response_data}
	[Documentation]    This keyword checks if any recorded/ongoing recordings are available
	@{Keys}    Get Dictionary Keys    ${recording_response_data}
	Check Key In List    data    ${Keys}
	${length}    Get Length    ${recording_response_data["data"]}
	: FOR    ${index}    IN RANGE    ${length}
	\    ${data}    Set Variable    ${recording_response_data["data"][${index}]}
	\    Check Key In List    recordingState    ${data}
	\    ${is_available}    Set Variable If    '''${data["recordingState"]}''' == '''recorded''' or '''${data["recordingState"]}''' == '''ongoing'''    True    False
	\    Exit For Loop If    ${is_available} == True
	[Return]    ${is_available}
	
Check For Planned Recordings
	[Arguments]    ${recording_response_data}
	[Documentation]    This keyword checks if any planned recordings are available
	@{Keys}    Get Dictionary Keys    ${recording_response_data}
	Check Key In List    data    ${Keys}
	${length}    Get Length    ${recording_response_data["data"]}
	: FOR    ${index}    IN RANGE    ${length}
	\    ${data}    Set Variable    ${recording_response_data["data"][${index}]}
	\    Check Key In List    recordingState    ${data}
	\    ${is_available}    Set Variable If    '''${data["recordingState"]}''' == '''planned'''    True    False
	\    Exit For Loop If    ${is_available} == True
	[Return]    ${is_available}
	
Plan Recording
	[Arguments]    ${LAB_CONF}    ${channel_id_superset}    ${crid_type}    ${is_recordable}    ${is_future}
	[Documentation]    This keyword schedules a planned recording
	${replay_channel}    ${crid}    Run Keyword    MetaKeywords.Get Crid Id    ${LAB_CONF}    ${channel_id_superset}    ${crid_type}    ${is_recordable}    ${is_future}
    ${failedReason}    Set Variable If    '''${crid}'''=='' or '''${crid}''' == 'None'    crid id is not available for channel    ${EMPTY}
    Should Be Empty    ${failedReason}
	${response}    RecordingService.Schedule Recording    ${LAB_CONF}    ${customer_id}    ${crid}
    ${failedReason}    Set Variable If    ${response.status_code} != 409 and ${response.status_code} != 201    Not able to schedule a recording for a single event    ${EMPTY}
    Should Be Empty    ${failedReason}
    [Return]    ${crid}
	
Schedule Ongoing Recording
	[Arguments]    ${LAB_CONF}    ${channel_id_superset}    ${crid_type}    ${is_recordable}
	[Documentation]    This keyword schedules recording for an ongoing event
	${crid}    Run Keyword    MetaKeywords.Get Crid Ongoing Event    ${LAB_CONF}    ${channel_id_superset}    ${crid_type}    ${is_recordable}
    ${failedReason}    Set Variable If    '${crid}'=='' or '''${crid}''' == 'None'    crid id is not available for channel    ${EMPTY}
    Should Be Empty    ${failedReason}
	${response}    RecordingService.Schedule Recording    ${LAB_CONF}    ${customer_id}    ${crid}
    ${failedReason}    Set Variable If    ${response.status_code} != 409 and ${response.status_code} != 201    Not able to schedule a recording for a single event    ${EMPTY}
    Should Be Empty    ${failedReason}
    [Return]    ${crid}