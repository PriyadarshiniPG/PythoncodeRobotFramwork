*** Settings ***
Documentation     Multi-room keywords
Library           robot.libraries.DateTime
Resource          ../PA-31_Multi_Room/Multi_Room_Implementation.robot

*** Keywords ***
Multiroom Default Suite Setup with channel verification
    [Arguments]    @{channel_list}
    [Documentation]    This keyword contains the Multiroom default suite setup
    HDD Default Suite Setup with channel verification    @{channel_list}
    Create topic for localRecordings

Verify MQTT publish response message is successful
    [Arguments]    ${source}
    [Documentation]    This keyword verifies that the MQTT publish response message was successful and checks that
    ...    the argument 'source' matches the source of the result
    ...    Pre-reqs: A publish message has been sent and a response message is
    ...    available in test var LAST_PUBLISH_RESPONSE_MESSAGE
    Variable should exist    ${LAST_PUBLISH_RESPONSE_MESSAGE}    Test var LAST_PUBLISH_RESPONSE_MESSAGE has not been set
    ${response_dict}    evaluate    json.loads('''${LAST_PUBLISH_RESPONSE_MESSAGE}''')    json
    should be equal    ${response_dict['messageType']}    CPE.result    Did not find a CPE.result messageType in the publish response message
    should be equal    ${response_dict['data']['result']}    success    The result in the publish response message was not 'success'
    should be equal    ${response_dict['data']['source']}    ${source}    The source in the publish response message was not '${source}'

MQTT publish result loop
    [Arguments]    ${arg_stb_id}    ${timeout}
    [Documentation]    Waits for message received from MQTT broker for given STB
    ${time}    robot.libraries.DateTime.Get Current Date    result_format=epoch
    ${sleep_time}    set variable    ${0.01}
    ${range}    evaluate    (${timeout} - ${time}) / ${sleep_time}
    : FOR    ${_}    IN RANGE    ${range}
    \    ${msg_rec}    Get MQTT Received Message    ${arg_stb_id}
    \    Exit For Loop If    ${msg_rec}
    \    sleep    ${sleep_time}

Record current single event via MQTT publish message
    [Documentation]    This keyword publishes an event to MQTT broker to record a current, single event
    ...    after obtaining all required data for the MQTT publish message.
    ...    The MQTT client is connected before the publish event is sent.
    ...    The MQTT client subscribes to the localRecordings topic.
    ...    The publish result message is stored and the client is disconnected.
    ...    Pre-reqs: Test suite var TOPIC_LOCAL_RECORDINGS must be set
    Variable should exist    ${TOPIC_LOCAL_RECORDINGS}    The localRecordings topic has not been set. Test var TOPIC_LOCAL_RECORDINGS does not exist
    ${msg_id}    Get msg id
    ${channel_id}    ${event_id}    ${epoch_event_start_time}    Get current event data from channel number    ${SINGLE_EVENT_CHANNEL}
    Create MQTT Client    ${CPE_ID}
    Connect MQTT Client    ${CPE_ID}
    Subscribe MQTT Client To Topic    ${CPE_ID}    ${TOPIC_LOCAL_RECORDINGS}
    ${timeout}    Get MQTT Message Timeout
    Publish Single Event Rec MQTT New Remote Message    ${CPE_ID}    ${TOPIC_LOCAL_RECORDINGS}    ${msg_id}    ${event_id}    ${channel_id}    ${epoch_event_start_time}
    MQTT publish result loop    ${CPE_ID}    ${timeout}
    Stop MQTT Client Loop And Disconnect    ${CPE_ID}
    ${return_message}    Get MQTT Last Publish Message    ${CPE_ID}
    Set test variable    ${LAST_PUBLISH_RESPONSE_MESSAGE}    ${return_message}

Stop currently recording single event via MQTT publish message
    [Documentation]    This keyword publishes an event to MQTT broker to stop a currently recording single event
    ...    after obtaining all required data for the MQTT publish message
    ...    The MQTT client is connected and subscribes to the localRecordings topic.
    ...    The publish result message is sent, the return message is stored and the client is disconnected.
    ...    Pre-reqs: Test suite var TOPIC_LOCAL_RECORDINGS must be set.
    ...    One single event recording must be in progress
    Variable should exist    ${TOPIC_LOCAL_RECORDINGS}    The localRecordings topic has not been set. Test var TOPIC_LOCAL_RECORDINGS does not exist
    ${msg_id}    Get msg id
    ${recording_id}    Get recording id for the only ongoing recording
    Create MQTT Client    ${CPE_ID}
    Connect MQTT Client    ${CPE_ID}
    Subscribe MQTT Client To Topic    ${CPE_ID}    ${TOPIC_LOCAL_RECORDINGS}
    ${timeout}    Get MQTT Message Timeout
    Publish Cancel Single Event Rec MQTT Delete Message    ${CPE_ID}    ${TOPIC_LOCAL_RECORDINGS}    ${msg_id}    ${recording_id}
    MQTT publish result loop    ${CPE_ID}    ${timeout}
    Stop MQTT Client Loop And Disconnect    ${CPE_ID}
    ${return_message}    Get MQTT Last Publish Message    ${CPE_ID}
    Set test variable    ${LAST_PUBLISH_RESPONSE_MESSAGE}    ${return_message}

Delete currently recording single event via MQTT publish message
    [Documentation]    This keyword publishes an event to MQTT broker to delete a currently recording single event
    ...    after obtaining all required data for the MQTT publish message
    ...    The MQTT client is connected and subscribes to the localRecordings topic.
    ...    The publish message message is sent, the return message is stored and the client is disconnected.
    ...    Pre-reqs: Test suite var TOPIC_LOCAL_RECORDINGS must be set.
    ...    One single event recording must be in progress
    Variable should exist    ${TOPIC_LOCAL_RECORDINGS}    The localRecordings topic has not been set. Test var TOPIC_LOCAL_RECORDINGS does not exist
    ${msg_id}    Get msg id
    ${recording_id}    Get recording id for the only ongoing recording
    Create MQTT Client    ${CPE_ID}
    Connect MQTT Client    ${CPE_ID}
    Subscribe MQTT Client To Topic    ${CPE_ID}    ${TOPIC_LOCAL_RECORDINGS}
    ${timeout}    Get MQTT Message Timeout
    Publish Delete Single Event Rec MQTT Delete Message    ${CPE_ID}    ${TOPIC_LOCAL_RECORDINGS}    ${msg_id}    ${recording_id}
    MQTT publish result loop    ${CPE_ID}    ${timeout}
    Stop MQTT Client Loop And Disconnect    ${CPE_ID}
    ${return_message}    Get MQTT Last Publish Message    ${CPE_ID}
    Set test variable    ${LAST_PUBLISH_RESPONSE_MESSAGE}    ${return_message}

Switch to HDD STB
    [Documentation]    Keyword changes context by preparing all variables for HDD box
    Set Suite Variable    ${RACK_SLOT_ID}    ${MULTI_ROOM_ALLOCATION['HDD']['rack_slot_id']}
    Set Suite Variable    ${ADDRESS}    ${MULTI_ROOM_ALLOCATION['HDD']['address']}
    Set Suite Variable    ${PORT}    ${MULTI_ROOM_ALLOCATION['HDD']['port']}
    Set Suite Variable    ${TFTPSRV}    ${MULTI_ROOM_ALLOCATION['HDD']['tftpserver']}
    ${stb_details}    Acquire Multi-Room STB data    ${RACK_SLOT_ID}
    Load Multi-Room STB Variables    ${stb_details}

Switch to HDD-less '${stb_index}' STB
    [Documentation]    Keyword changes context by preparing all variables for HDD-less box with `stb_index`
    Set Suite Variable    ${RACK_SLOT_ID}    ${MULTI_ROOM_ALLOCATION['HDD-less']['${stb_index}']['rack_slot_id']}
    Set Suite Variable    ${ADDRESS}    ${MULTI_ROOM_ALLOCATION['HDD-less']['${stb_index}']['address']}
    Set Suite Variable    ${PORT}    ${MULTI_ROOM_ALLOCATION['HDD-less']['${stb_index}']['port']}
    Set Suite Variable    ${TFTPSRV}    ${MULTI_ROOM_ALLOCATION['HDD-less']['${stb_index}']['tftpserver']}
    ${stb_details}    Acquire Multi-Room STB data    ${RACK_SLOT_ID}
    Load Multi-Room STB Variables    ${stb_details}

HDD Box is in online mode
    [Documentation]    Keyword checks if live stream is playing on HDD mutliroom box
    Switch to HDD STB
    Verify that STB is not in standby mode

I switch to HDD-less Box
    [Documentation]    Keyword changes context to first HDD-less box
    Switch to HDD-less '0' STB

Multi-Room HDD Recordings Suite Teardown
    [Documentation]    Suite teardown for multiroom tests where recording cleaning is required
    Switch to HDD STB
    Clean Recordings on HDD box
    Multi-Room Default Suite Teardown

HDD Box is in hot standby mode
    [Documentation]    Keyword checks if live stream is playing on HDD mutliroom box
    Switch to HDD STB
    I set standby mode to    ActiveStandby
    I put stb in standby

HDD Box is in lukewarm standby mode
    [Documentation]    Keyword checks if live stream is playing on HDD mutliroom box
    Switch to HDD STB
    I set standby mode to    LukewarmStandby
    I put stb in standby

Multi-Room HDD Recordings and Standby Specific Suite Teardown
    [Documentation]    Suite teardown for multiroom tests where:
    ...    - recording cleaning is required
    ...    - restoring from standby is required
    Switch to HDD STB
    wait until keyword succeeds    4 times    10s    I put stb out of standby
    Clean Recordings on HDD box
    Multi-Room Default Suite Teardown

Disable Watershed on the box
    [Documentation]    Keyword responsible for disabling watershed on the box
    Wait Until Keyword Succeeds    3times    1 sec    set watershed periods via as    ${STB_IP}    ${CPE_ID}    ${None}
    ...    ${XAP}
    Restart UI via command over SSH
