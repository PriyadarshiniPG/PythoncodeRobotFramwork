*** Settings ***
Documentation     Multi-room Implementation keywords
Resource          ../Common/Common.robot

*** Keywords ***
Create topic for localRecordings
    [Documentation]    This keyword creates the topic for localRecordings and stores it in
    ...    suite var TOPIC_LOCAL_RECORDINGS
    ${topic}    Catenate    SEPARATOR=/    ${CUSTOMER_ID}    ${CPE_ID}    localRecordings
    Set suite variable    ${TOPIC_LOCAL_RECORDINGS}    ${topic}

Get msg id
    [Documentation]    This keyword fetches the cpe id, extracts the last 9 digits and returns them as
    ...    the msg_id which is required in MQTT publish messages
    ${_}    ${_}    ${msg_id}    Split String From Right    ${CPE_ID}    -
    ${msg_id}    Get Substring    ${msg_id}    3
    ${msg_id}    Convert to integer    ${msg_id}
    [Return]    ${msg_id}

Get recording id for the only ongoing recording
    [Documentation]    This keyword gets the recording id of the only ongoing recording
    ${status_list}    Create list    STARTED
    ${rec_records}    get recordings filter status via as    ${STB_IP}    ${CPE_ID}    ${status_list}    xap=${XAP}
    ${recording}    set variable    @{rec_records}[0]
    ${recording_id}    set variable    ${recording['recordingId']}
    [Return]    ${recording_id}

Get current event data from channel number
    [Arguments]    ${channel_number}
    [Documentation]    This keyword gets the current event data required for MQTT publish messages
    ...    using argument channel_id
    ...    Returns channel_id, event_id, epoch_event_start_time as an integer
    ${channel_id}    Get channel ID using channel number    ${channel_number}
    @{current_event}    Get current channel event via as    ${channel_id}
    ${event_id}    Set variable    @{current_event}[0]
    ${epoch_event_start_time}    convert date    @{current_event}[1]    epoch
    ${epoch_event_start_time}    robot.libraries.DateTime.Convert Date    @{current_event}[1]    epoch
    ${epoch_event_start_time}    Convert to Integer    ${epoch_event_start_time}
    [Return]    ${channel_id}    ${event_id}    ${epoch_event_start_time}

Get future event data from channel number
    [Arguments]    ${channel_id}
    [Documentation]    This keyword gets future event data required for MQTT publish messages
    ...    using argument channel_id
    ...    Returns channel_id, event_id, epoch_event_start_time as an integer
    ${channel_id}    Get channel ID using channel number    ${SINGLE_EVENT_CHANNEL}
    @{future_event}    get future event    ${channel_id}    ${CPE_ID}
    ${event_id}    Set variable    @{future_event}[0]
    ${epoch_event_start_time}    robot.libraries.DateTime.Convert Date    @{future_event}[1]    epoch
    ${epoch_event_start_time}    Convert to Integer    ${epoch_event_start_time}
    [Return]    ${channel_id}    ${event_id}    ${epoch_event_start_time}
