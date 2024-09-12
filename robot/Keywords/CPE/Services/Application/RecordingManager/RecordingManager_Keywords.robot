*** Settings ***
Documentation     Recording Manager Application Services Keywords

*** Keywords ***
Create a future single Event Recording on channel '${channel}' via AS Recording Manager createEventRecording    #USED
    [Documentation]    This keyword creates a future event recording on channel ${channel} using the
    ...    Application service Recording Manager by making a call to createEventRecording and stores the
    ...    recording id in test variable LAST_REC_ID
    ${channel_id}    Get channel ID using channel number    ${channel}
    ${timestamp}    robot.libraries.DateTime.get current date    result_format=%Y-%m-%d %H:%M:%S
    ${timestamp}    Add Time To Date    ${timestamp}    10 minutes
    ${timestamp}    robot.libraries.DateTime.Convert Date    ${timestamp}    epoch
    ${timestamp}    Convert to integer    ${timestamp}
    @{events}    Get channel events via As    ${STB_IP}    ${CPE_ID}    ${channel_id}    ${timestamp}    events_before=1
    ...    events_after=3    xap=${XAP}
    Log     ${events}
    : FOR    ${event}    IN    @{events}
    \    Continue For Loop If   ${event} == None    #Sometimes None value is also found in the event list, this is added to skip the same.
    \    &{event_dict}    Convert To Dictionary    ${event}
    \    Log     ${event_dict}
    \    ${start_time}    Get From Dictionary    ${event_dict}    startTime
    \    ${is_future_event}    Evaluate    ${start_time} > ${timestamp}+${1000}
    \    ${future_event}    set variable if    ${is_future_event}    ${event_dict}
    \    exit for loop if    ${is_future_event}
    ${event_start_time}    Get From Dictionary    ${future_event}    startTime
    ${event_id}    Get From Dictionary    ${future_event}    eventId
    ${rec_title}    Get From Dictionary    ${future_event}    title
    ${rec_id}    create event record via as    ${STB_IP}    ${CPE_ID}    ${channel_id}    ${event_id}    ${event_start_time}
    ...    xap=${XAP}
    Set Suite Variable    ${LAST_REC_ID}    ${rec_id}
    Set Suite Variable    ${LAST_REC_TITLE}  ${rec_title}

Create a future single Event Recording via AS Recording Manager createEventRecording
    [Documentation]    This keyword creates a future event recording using the Application service Recording Manager
    ...    by making a call to createEventRecording
    Create a future single Event Recording on channel '${SINGLE_EVENT_CHANNEL}' via AS Recording Manager createEventRecording

Create Future single Event Recordings via AS Recording Manager createEventRecording
    [Documentation]    This keyword creates 2 future event recordings using the Application service Recording Manager
    ...    by making calls to createEventRecording
    Create a Future single Event Recording on channel '${SINGLE_EVENT_CHANNEL}' via AS Recording Manager createEventRecording
    Create a Future single Event Recording on channel '${SINGLE_EVENT_CHANNEL_FOR_CONTEXT_PLAY}' via AS Recording Manager createEventRecording

Create an ongoing single Event Recording on channel '${channel}' via AS Recording Manager createEventRecording
    [Documentation]    This keyword creates an ongoing event recording on channel ${channel} using the
    ...    Application service Recording Manager by making a call to createEventRecording and stores the
    ...    recording id in test variable LAST_REC_ID
    ${channel_id}    Get channel ID using channel number    ${channel}
    @{current_event}    Get current channel event via as    ${channel_id}
    ${rec_id}    create event record via as    ${STB_IP}    ${CPE_ID}    ${channel_id}    @{current_event}[0]    @{current_event}[1]
    ...    xap=${XAP}
    Set Test variable    ${LAST_REC_ID}    ${rec_id}

Create an ongoing single Event Recording via AS Recording Manager createEventRecording
    [Documentation]    This keyword creates an ongoing event recording using the Application service Recording Manager
    ...    by making a call to createEventRecording
    Create an ongoing single Event Recording on channel '${SINGLE_EVENT_CHANNEL}' via AS Recording Manager createEventRecording

Create ongoing single Event Recordings via AS Recording Manager createEventRecording
    [Documentation]    This keyword creates 2 ongoing event recording using the Application service Recording Manager
    ...    by making calls to createEventRecording
    Create an ongoing single Event Recording on channel '${SINGLE_EVENT_CHANNEL}' via AS Recording Manager createEventRecording
    Create an ongoing single Event Recording on channel '${SINGLE_EVENT_CHANNEL_FOR_CONTEXT_PLAY}' via AS Recording Manager createEventRecording

Verify the only '${event_type}' Event Recording has status '${status}' via AS Recording Manager getCollection
    [Documentation]    This keyword checks that the only recording we have is of status ${status} using
    ...    Application service Recording Manager by making a call to getCollection
    ${recording_collection}    get recording collection via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${event}    Set variable if    '${event_type}'=='Future'    @{recording_collection.bookings.bookingsData}[0]    @{recording_collection.recordings.recordingsData}[0]
    Should be true    '${status}' == '${event['status']}'    Status retrieved from AS is not:${status}

Verify there are no recordings via AS Recording Manager getCollection
    [Documentation]    This keyword checks that no recordings are reported of any type using the Application service
    ...    Recording Manager by making a call to getCollection and passing the CPE id
    ${recording_collection}    get recording collection via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    Should be true    ${recording_collection.recordings.totalRecordings} == 0    One or more recording found
    Should be true    ${recording_collection.bookings.totalBookings} == 0    One or more booking found

Delete a Recording using recordingId via AS Recording Manager deleteRecording
    [Documentation]    This keyword deletes a recording using the value stored in test variable LAST_REC_ID and calls
    ...    Application service Recording Manager deleteRecording
    ...    Pre-reqs: We have a recording and the recording id is stored in test variable LAST_REC_ID
    delete recording via as    ${STB_IP}    ${CPE_ID}    recording_id=${LAST_REC_ID}    xap=${XAP}

Delete all recordings of recording type '${type}' via AS Recording Manager deleteAllRecordings
    [Documentation]    This keyword deletes all recordings of type ${type} using the Application service,
    ...    Recording Manager deleteAllRecordings
    wait until keyword succeeds    3 times    1 sec    delete recordings of type via as    ${STB_IP}    ${CPE_ID}    recordings_type=${type}
    ...    xap=${XAP}

Cancel recording manualConflictResolution '${conflict}' using recordingId via AS Recording Manager cancelRecording
    [Documentation]    This keyword cancels a recording using the value stored in test variable LAST_REC_ID and calls
    ...    Application service Recording Manager cancelRecording. ${conflict} set to True or False. API default is False
    ...    Pre-reqs: We have a recording and the recording id is stored in test variable LAST_REC_ID
    ${conflict_param}    Convert To Boolean    ${conflict}
    cancel recording via as    ${STB_IP}    ${CPE_ID}    recording_id=${LAST_REC_ID}    manual_conflict_resolution=${conflict_param}    xap=${XAP}

Get Random Replay Channel And Schedule Single Event Recording Via AS Recording Manager  #USED
    [Documentation]    This keyword gets a random Replay Channel and schedules a future single event recording on it
    ${channel_number}    Get Random Replay Channel Number Without Planned Blacklisted Recording And Minimum Starting Time '15'
    Create a future single Event Recording on channel '${channel_number}' via AS Recording Manager createEventRecording

#**********************CPE PERFORMANCE***********************************************
Create Series Event Recording via AS
    [Documentation]   Create series recording on the box via AS
    [Arguments]   ${channel_id}   ${event_id}   ${series_id}    ${event_start_time}
    ${response}    create series record via as    ${STB_IP}    ${CPE_ID}   ${channel_id}
    ...   ${series_id}   ${event_id}   ${event_start_time}
    [Return]   ${response}
Create Single Event Recording via AS
    [Documentation]   Create series recording on the box via AS
    [Arguments]   ${channel_id}   ${event_id}   ${event_start_time}
     ${rec_id}    create event record via as    ${STB_IP}    ${CPE_ID}    ${channel_id}    ${event_id}    ${event_start_time}
    ...    xap=${XAP}
    [Return]   ${rec_id}


Get Series Info Recording via AS
    [Documentation]   Get series recording info from the box via AS
    [Arguments]   ${channel_id}   ${series_id}
    ${response}   get series recording info via as    ${STB_IP}    ${CPE_ID}   ${CUSTOMER_ID}    ${channel_id}
    ...   ${series_id}
    [Return]   ${response}

Get Single Info Recording via AS
    [Documentation]   Get single recording info from the box via AS
    [Arguments]   ${event_id}
    ${response}   get single recording info via as    ${STB_IP}    ${CPE_ID}   ${CUSTOMER_ID}    ${event_id}
    [Return]   ${response}

Check If Series Recording Exist
    [Documentation]    Checks if the recording exist for given event
    ...  event: dictionary containing parentSeriesId, seriesId
    [Arguments]   ${channel_id}   ${event}
    Log   ${channel_id}, &{event}[seriesId], &{event}[title]
    ${parent_series_present}  evaluate   'parentSeriesId' in ${event}
    ${series_id}    set variable if   ${parent_series_present}     &{event}[parentSeriesId]    &{event}[seriesId]
    Log   ${series_id}
    ${recording_status}   run keyword and return status    Get Series Info Recording via AS   ${channel_id}   ${series_id}
    [Return]   ${recording_status}

Check If Single Recording Exist
    [Documentation]    Checks if the single recording exist for given event
    ...  event: dictionary containing event id
    [Arguments]   ${event}
    ${recording_status}    run keyword and return status  Get Single Info Recording via AS    &{event}[id]
    [Return]   ${recording_status}