*** Settings ***
Documentation     Keywords for RecordignsServices
Resource          ./RecordingService_Implementation.robot
Resource          ../../api.basic.robot

*** Keywords ***
Get Customer Collections via RecordingService and Check Result Code
    [Arguments]    ${lab_conf}=${LAB_CONF}    ${customer_id}=${CUSTOMER_ID}
    [Documentation]    This keyword Get the Customer Collections via RecordingService and
    ...    [return]  response [response.status_code; response.reason; response.json()]
    ${response}    Get Customer Collections via RecordingService    ${lab_conf}    ${customer_id}
    Check Respond Status And failedReason    ${response}
    [Return]    ${response}

Get Customer Collections via RecordingService and Result Code and Data validation
    [Arguments]    ${lab_conf}=${LAB_CONF}    ${customer_id}=${CUSTOMER_ID}
    [Documentation]    This keyword Get the Customer Collections via RecordingService and
    ...    check the result code and the data returned
    ...    [return]  response [response.status_code; response.reason; response.json()]
    ${response}    Get Customer Collections via RecordingService and Check Result Code    ${lab_conf}    ${customer_id}
    Data Validation Get Customer Collections via RecordingService    ${response.json()}
    [Return]    ${response.json()}

Get '${key}' from Customer Collections via RecordingService    #NOT_USED   - Not posisble embedded + arguments
#    [Arguments]    ${lab_conf}=${LAB_CONF}    ${customer_id}=${CUSTOMER_ID}
    [Documentation]    This keyword Get the Customer Collections via RecordingService and
    ...    check the result code and the data returned and key from it Exmple: "recordings" 
    ...    [return]  data for the given key
    ${response}    Get Customer Collections via RecordingService and Result Code and Data validation     ${LAB_CONF}    ${CUSTOMER_ID}
    ${return}   Get '${key}' from '${response}'
    [return]    ${return}

Get Total Bookings from Customer Collections via RecordingService
    [Arguments]    ${lab_conf}=${LAB_CONF}    ${customer_id}=${CUSTOMER_ID}
    [Documentation]    This keyword Get Total Bookings from the Customer Collections via RecordingService and
    ...    check the result code and the data returned
    ...    [return]  total bookings
    ${response}    Get Customer Collections via RecordingService and Result Code and Data validation     ${lab_conf}    ${customer_id}
    ${bookings}   Get 'bookings' from '${response}'
    ${total_bookings}   Get 'total' from '${bookings}'
    [return]    ${total_bookings}

Get and Save Total Bookings from Customer Collections via RecordingService
    [Arguments]    ${lab_conf}=${LAB_CONF}    ${customer_id}=${CUSTOMER_ID}
    [Documentation]    This keyword Get Total Bookings from the Customer Collections via RecordingService and
    ...    check the result code and the data returned
    ...    [return]  total bookings
    ${total_bookings}    Get Total Bookings from Customer Collections via RecordingService     ${lab_conf}    ${customer_id}
    Set Suite Variable    ${PLANNED_RECORDING_COUNT}    ${total_bookings}    #SAVED AS SUITE VAR TO BE REUSE - to check increase or decrease
    [return]    ${total_bookings}

Check Total Bookings from Customer Collections via RecordingService diff In 
    [Arguments]    ${increase_count}=1    ${planned_recording_count}=${PLANNED_RECORDING_COUNT}  ${lab_conf}=${LAB_CONF}    ${customer_id}=${CUSTOMER_ID}
    [Documentation]    This keyword Get Total Bookings from the Customer Collections via RecordingService and
    ...    check the result code and the data returned + check with previous value how much varies
    ${planned_recording_count_plus}    Evaluate    ${planned_recording_count} + ${increase_count}
    ${planned_recording_count}    Get Total Bookings from Customer Collections via RecordingService     ${lab_conf}    ${customer_id}
    Should be true    ${planned_recording_count}==${planned_recording_count_plus}    The number of planned recordings is not ${planned_recording_count_plus}
	Set Suite Variable    ${planned_recording_count}    ${planned_recording_count}

Check Total Bookings from Customer Collections via RecordingService Increase one
    [Arguments]    ${planned_recording_count}=${PLANNED_RECORDING_COUNT}  ${lab_conf}=${LAB_CONF}    ${customer_id}=${CUSTOMER_ID}
    [Documentation]    This keyword Get Total Bookings from the Customer Collections via RecordingService and
    ...    check the result code and the data returned + check with previous value of total to check increase in one
    Check Total Bookings from Customer Collections via RecordingService diff In    1    ${planned_recording_count}     ${lab_conf}    ${customer_id}

Check Total Bookings from Customer Collections via RecordingService Decrease one
    [Arguments]    ${planned_recording_count}=${PLANNED_RECORDING_COUNT}  ${lab_conf}=${LAB_CONF}    ${customer_id}=${CUSTOMER_ID}
    [Documentation]    This keyword Get Total Bookings from the Customer Collections via RecordingService and
    ...    check the result code and the data returned + check with previous value of total to check decrease in one
    Check Total Bookings from Customer Collections via RecordingService diff In    -1    ${planned_recording_count}     ${lab_conf}    ${customer_id}

Get List Of Channel ID With Ongoing Recording From BO    #USED
    [Documentation]  The keyword returns the channel ids having ongoing recordings.
    ...   It gets the recording state of all the recordings and filter the ongoing recording state
    ${recording_state}    Get Recording State Of All Recordings From BO
    @{recording_channel_details}   Set Variable   ${recording_state['data']}
    @{channel_id_list}    Create List
    :FOR  ${channel}  IN  @{recording_channel_details}
    \   ${is_ongoing}  Run Keyword And Return Status   Dictionary Should Contain Item    ${channel}   recordingState    ongoing
    \   Continue For Loop If  ${is_ongoing} == False
    \   ${channel_id}    Extract Value For Key    ${channel}    ${EMPTY}    channelId
    \   Append To List     ${channel_id_list}       ${channel_id}
    [Return]   ${channel_id_list}

Get List of Event Ids Of All Recordings From BO    #USED
    [Documentation]  This keyword returns all the recording event ids from backend
    ${recording_state}    Get Recording State Of All Recordings From BO
    @{recording_channel_details}   Set Variable   ${recording_state['data']}
    @{recording_id_list}    Create List
    :FOR  ${recording}  IN  @{recording_channel_details}
    \   ${recording_id}    Extract Value For Key    ${recording}    ${EMPTY}    eventId
    \   Append To List     ${recording_id_list}       ${recording_id}
    [Return]   ${recording_id_list}

I Get All Planned Recording Assets From BO    #USED
    [Documentation]  This keyword gets all planned recordings from backend
    ${response}    Get All Planned Recordings From BO
    Log    ${response.json()}
    Check Respond Status And failedReason    ${response}
    [Return]    ${response.json()}

I Schedule Recording For The Given Asset    #USED
    [Documentation]    This keyword schedule recording for the given asset
    [Arguments]    ${event_id}    ${channel_id}
    ${response}    Schedule Recording For The Given Event    ${event_id}    ${channel_id}
    Check Respond Status And failedReason    ${response}    201

Get List Of Channel ID With Planned Recording From BO    #USED
    [Documentation]  The keyword returns the channel ids having planned recordings.
    ...   It gets the recording state of all the recordings and filter the planned recording state
    ${recording_state}    Get Recording State Of All Recordings From BO
    @{recording_channel_details}   Set Variable   ${recording_state['data']}
    @{channel_id_list}    Create List
    :FOR  ${channel}  IN  @{recording_channel_details}
    \   ${is_planned}  Run Keyword And Return Status   Dictionary Should Contain Item    ${channel}   recordingState    planned
    \   Continue For Loop If  ${is_planned} == False
    \   ${channel_id}    Extract Value For Key    ${channel}    ${EMPTY}    channelId
    \   Append To List     ${channel_id_list}       ${channel_id}
    [Return]   ${channel_id_list}