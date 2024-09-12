*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        SETUP_AddRecordings    SETUP    SETUP_UK
Resource          ./Settings.robot


#Author              Shanu Mopila
*** variables ***
${CLEAR_CACHE}    false

*** Test Cases ***
Copy original config
    [Documentation]    Copy the original config file from the resource folder
    [Setup]    Default First TestCase Setup
    ${filename}    set variable    ${LAB_NAME}_${PRODUCT}_config.yaml
    ${filename}    convert to lowercase    ${filename}
    copy file  resources/config/${filename}    temp/${filename}

Delete All Planned Recordings
    [Documentation]    Delete all the planned recordings
    Delete all events of SETUP_SAVED_SERIES_CHANNEL
    Delete all recordings of recording type 'PLANNED_ONLY' via AS Recording Manager deleteAllRecordings
    run keyword if  '${CLEAR_CACHE}' == 'true'    Delete ongoing recordings

Reduce Recordings to required percentage
    [Documentation]    Reduce recordings to the required level
    [Setup]    Default First TestCase Setup
    I open Recordings through Saved
    I Press    OK
    ${action_found}    Run Keyword And Return Status   Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:RecordingList.View'
    Should Be True    ${action_found}    Unable to open Recording list
    I wait for 5 seconds
    ${SETUP_MIN_RECORDING_LEVEL}    get environment variable    RECORDING_LEVEL
    :FOR    ${index}    in RANGE    1    9999
    \    ${quota_usage}    Get quota usage
    \    Log to console    Current Quota: ${quota_usage}% Target: ${SETUP_MIN_RECORDING_LEVEL}%
    \    exit for loop if    ${quota_usage} <= ${SETUP_MIN_RECORDING_LEVEL}
    \    ${focused_elements}    Get Ui Focused Elements
    \    ${recordings}    Extract Value For Key    ${focused_elements}    id:EzyListrecordingList    data
    \    ${recording_info}    set variable   @{recordings}[0]
    \    ${REC_ID}    Extract Value For Key    ${recording_info}    ${EMPTY}    id
    \    Log to console     RecordingId ${REC_ID}
    \    Set Suite Variable    ${LAST_REC_ID}    ${REC_ID}
    \    Delete a Recording using recordingId via AS Recording Manager deleteRecording
    \     Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}
    \     ...    I do not expect focused elements contain 'id:${REC_ID}' using regular expressions

From Channel Bar Schedule Ongoing Series Recording
    [Documentation]    Go to Current event on Channel Bar push REC button and record the event
    ${channel_id}   set variable    ${SETUP_SAVED_SERIES_CHANNEL}
    ${SETUP_SAVED_SERIES_CHANNEL}    get channel lcn for channel id   ${SETUP_SAVED_SERIES_CHANNEL}
    I tune to channel    ${SETUP_SAVED_SERIES_CHANNEL}
    Prevent Channel Bar from disappearing
#    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Channel Bar for live event is Shown    ${SETUP_SAVED_SERIES_CHANNEL}
    ${live_event_id}    I retrieve value for key 'id' in element 'textKey:DIC_GENERIC_AIRING_TIME_NOW'
    ${index}    Get Regexp Matches    ${live_event_id}    ([\\d]+)$    0
    ${index}    set variable    @{index}[0]
    ${title_text_id}    set variable    id:titleText${index}
    ${program_name}    I retrieve value for key 'textValue' in element '${title_text_id}'
    Delete Series Recording for ongoing event    ${channel_id}
    I wait for 5 seconds
    Create an ongoing single Event Recording on channel '${SETUP_SAVED_SERIES_CHANNEL}' via AS Recording Manager createEventRecording
    I wait for 5 seconds
    set suite variable     ${RECORDED_EVENT_CRID}   ${LAST_REC_ID}
    ${response}    Get Details Of Single Recording    ${LAST_REC_ID}
    log to console    program_name: ${program_name}
    Update Test Config    SAVED_RECORDINGS_SERIES_ASSET    ${program_name}
    Update Test Config    SAVED_CONTINUE_WATCHING_RECORDING_ASSET    &{response}[title]

Add the recording to continue watching
    [Documentation]     Add the recorded content to continue watching
    [Setup]    Skip If Last Fail
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${response}    Get Details Of Single Recording    ${RECORDED_EVENT_CRID}
    ${rec_type}    set variable if   ${LDVR_ENABLED}=='True'   local-recording    network-recording
    Set Profile Bookmark For An Asset Based On Percentage    ${rec_type}    ${RECORDED_EVENT_CRID}    &{response}[duration]    10    ${cpe_profile_id}
    ...    &{response}[seasonId]    &{response}[showId]    channel_id=&{response}[channelId]

ADD Required number of planned recordings
    [Documentation]    Add the required number of planned recordings
    ${SETUP_MIN_BOOKINGS_SINGLE}    set variable if  '${CLEAR_CACHE}' == 'true'    0    ${SETUP_MIN_BOOKINGS_SINGLE}
    :FOR    ${index}    in RANGE    0    ${SETUP_MIN_BOOKINGS_SINGLE}
    \   ${event_data}   ${channel_id}    ${max_actions}    I Select A Next Day 'single' Event From BO
    \   Create Single Event Recording via AS    ${channel_id}   &{event_data}[id]   &{event_data}[startTime]
    \   log to console     book single event:${index}

    ${SETUP_MIN_BOOKINGS_SERIES}    set variable if  '${CLEAR_CACHE}' == 'true'    0    ${SETUP_MIN_BOOKINGS_SERIES}
    ${BOOKINGS_SERIES_COUNT}    set variable   0
    :FOR    ${index}    in RANGE    0    ${SETUP_MIN_BOOKINGS_SERIES}
    \   ${event_data}   ${channel_id}    ${max_actions}    I Select A Next Day 'series' Event From BO
    \   Log    ${event_data}
    \   ${status}    run keyword and return status     Create Series Event Recording via AS    ${channel_id}   &{event_data}[id]   &{event_data}[seriesId]
    \   ...   &{event_data}[startTime]
    \   ${BOOKINGS_SERIES_COUNT}    set variable if  ${status}    ${BOOKINGS_SERIES_COUNT}+1    ${BOOKINGS_SERIES_COUNT}
    \   log to console     book series event:${index}
    \   exit for loop if    ${BOOKINGS_SERIES_COUNT} == ${SETUP_MIN_BOOKINGS_SERIES}

*** Keywords ***
Delete ongoing recordings
    [Documentation]  Delete all ongoing recordings for the customer
    ${recording_response_data}    Get Recording State Of All Recordings From BO
    @{Keys}    Get Dictionary Keys    ${recording_response_data}
	Check Key In List    data    ${Keys}
	${length}    Get Length    ${recording_response_data["data"]}
	: FOR    ${index}    IN RANGE    ${length}
	\    ${data}    Set Variable    ${recording_response_data["data"][${index}]}
	\    Check Key In List    recordingState    ${data}
	\    ${is_ongoing}    Set Variable If    '''${data["recordingState"]}''' == '''ongoing'''    True    False
	\    run keyword if  ${is_ongoing}    Set Suite Variable    ${LAST_REC_ID}    ${data["eventId"]}
	\    run keyword if  ${is_ongoing}    log to console  Delete ${data["recordingState"]} recording: ${data["eventId"]}
	\    run keyword if  ${is_ongoing}    log  Delete ${data["recordingState"]} recording: ${data["eventId"]}
    \    run keyword if  ${is_ongoing}    Delete a Recording using recordingId via AS Recording Manager deleteRecording

Delete Series Recording for ongoing event
    [Documentation]    Deletes recording and cancels the booking
    [Arguments]    ${channel_id}
    ${current_event}    Get current channel event via as    ${channel_id}
    ${current_event}   set variable    @{current_event}[0]
    run keyword and ignore error     cancel series recording via as    ${STB_IP}    ${CPE_ID}    ${CURRENT_SERIES_ID}    ${channel_id}    xap=${XAP}
    run keyword and ignore error     delete series recording via as    ${STB_IP}    ${CPE_ID}    ${CURRENT_SERIES_ID}    ${channel_id}    xap=${XAP}
    Set Suite Variable    ${LAST_REC_ID}    ${current_event}
    run keyword and ignore error     Delete a Recording using recordingId via AS Recording Manager deleteRecording

Delete all events of SETUP_SAVED_SERIES_CHANNEL
    [Documentation]  Delete all events for SETUP_SAVED_SERIES_CHANNEL
    ${recording_response_data}    Get Recording State Of All Recordings From BO
    @{Keys}    Get Dictionary Keys    ${recording_response_data}
	Check Key In List    data    ${Keys}
	${length}    Get Length    ${recording_response_data["data"]}
	: FOR    ${index}    IN RANGE    ${length}
	\    ${data}    Set Variable    ${recording_response_data["data"][${index}]}
	\    Check Key In List    channelId    ${data}
    \    ${channel_id}    set variable    ${data["channelId"]}
	\    ${status}    Set Variable If    '''${channel_id}''' == '''${SETUP_SAVED_SERIES_CHANNEL}'''    True    False
	\    run keyword if  ${status}    Set Suite Variable    ${LAST_REC_ID}    ${data["eventId"]}
	\    run keyword if  ${status}    log to console  Delete setup channel number ${channel_id} ${data["recordingState"]} event: ${data["eventId"]}
	\    run keyword if  ${status}    log  Delete setup channel number ${channel_id} ${data["recordingState"]} event: ${data["eventId"]}
    \    run keyword if  ${status}    Delete a Recording using recordingId via AS Recording Manager deleteRecording