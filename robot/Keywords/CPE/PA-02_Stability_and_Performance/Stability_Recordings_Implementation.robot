*** Settings ***
Documentation     Stability Recordings keyword definitions

*** Keywords ***
Stability Record Single Events From Channel Bar
    [Arguments]    ${repeat_num}    ${channel_lcn}=${SINGLE_EVENT_CHANNEL}
    [Documentation]    Record/Stop/Delete ${repeat_num} single events from the channel bar.
    I tune to stability test channel    ${channel_lcn}
    : FOR    ${_}    IN RANGE    0    ${repeat_num}
    \    Log    Recording/Stopping/Deleting single event
    \    I press    REC
    \    I wait for 500 ms
    \    I press    UP
    \    I wait for 500 ms
    \    I press    OK
    \    I wait for 6 seconds
    \    I press    BACK
    \    I wait for 1 second
    # Bring up the channel bar again
    \    Log    Recording/Stopping/Deleting single event
    \    I press    OK
    \    I wait for 1 second
    \    I press    REC
    \    I wait for 500 ms
    \    I press    OK
    \    I wait for 6 seconds
    \    Log    Move right to the next event
    \    I press    RIGHT
    \    I wait for 500 ms

Stability Record Series Events From Channel Bar
    [Arguments]    ${repeat_num}    ${channel_lcn}=${SERIES_EVENT_CHANNEL}
    [Documentation]    Record/Stop/Delete ${repeat_num} series events from the channel bar.
    I tune to stability test channel    ${channel_lcn}
    : FOR    ${_}    IN RANGE    0    ${repeat_num}
    \    Log    Recording/Stopping/Deleting series episode
    \    I press    REC
    \    I wait for 500 ms
    \    I press    DOWN
    \    I wait for 500 ms
    \    I press    OK
    \    I wait for 6 seconds
    \    I press    BACK
    \    I wait for 1 second
    # Bring up the channel bar again
    \    Log    Recording/Stopping/Deleting series episode
    \    I press    OK
    \    I wait for 1 second
    \    I press    REC
    \    I wait for 500 ms
    \    I press    DOWN
    \    I wait for 500 ms
    \    I press    OK
    \    I wait for 6 seconds
    \    Log    Move right to the next event
    \    I press    RIGHT
    \    I wait for 500 ms

Stability Record Series Events From Guide
    [Arguments]    ${repeat_num}    ${channel_lcn}=${SERIES_EVENT_CHANNEL}
    [Documentation]    Record/Stop/Delete ${repeat_num} series events from the Guide.
    I tune to stability test channel    ${channel_lcn}
    I Press    GUIDE
    I wait for 8 seconds
    : FOR    ${_}    IN RANGE    0    ${repeat_num}
    \    Log    Recording/Stopping/Deleting series episode
    \    I press    REC
    \    I wait for 500 ms
    \    I press    DOWN
    \    I wait for 500 ms
    \    I press    OK
    \    I wait for 6 seconds
    \    Log    Recording/Stopping/Deleting series episode
    \    I press    REC
    \    I wait for 500 ms
    \    I press    DOWN
    \    I wait for 500 ms
    \    I press    OK
    \    I wait for 6 seconds
    \    Log    Move right to the next event
    \    I press    RIGHT
    \    I wait for 500 ms

Stability Record Single Events From Guide
    [Arguments]    ${repeat_num}    ${channel_lcn}=${SINGLE_EVENT_CHANNEL}
    [Documentation]    Record/Stop/Delete ${repeat_num} single events from the Guide.
    I tune to stability test channel    ${channel_lcn}
    I Press    GUIDE
    I wait for 8 seconds
    : FOR    ${_}    IN RANGE    0    ${repeat_num}
    \    Log    Recording/Stopping/Deleting single event
    \    I press    REC
    \    I wait for 500 ms
    \    I press    UP
    \    I wait for 500 ms
    \    I press    OK
    \    I wait for 6 seconds
    \    Log    Recording/Stopping/Deleting single event
    \    I press    REC
    \    I wait for 500 ms
    \    I press    UP
    \    I wait for 500 ms
    \    I press    OK
    \    I wait for 6 seconds
    \    Log    Move right to the next event
    \    I press    RIGHT
    \    I wait for 500 ms

Stability Set Event Reminders from Channel Bar
    [Arguments]    ${repeat_num}    ${channel_lcn}=${SINGLE_EVENT_CHANNEL}
    [Documentation]    Add/remove ${repeat_num} event reminders from the Channel Bar.
    I tune to stability test channel    ${channel_lcn}
    I wait for 1 second
    : FOR    ${index}    IN RANGE    0    ${repeat_num}
    \    I press RIGHT ${index + 2} times
    \    # Ignoring next event because it can be too recent to set a reminder
    \    I wait for 1 second
    \    I press    OK
    \    I wait for 1 second
    \    I press    LEFT
    \    I wait for 1 second
    \    I press    OK
    \    #this should set/remove the reminder
    \    #\    Toast Message is shown containing 'Reminder is set'
    \    I wait for 1 second
    \    I Press    BACK
    \    I wait for 1 second

is the duration meeting the expected minimum
    [Arguments]    ${input_duration}    ${minimum_duration}
    [Documentation]    This keywords returns whether the ${input_duration} value is greater than or equal to
    ...    ${minimum_duration} in numeric terms.
    ${input_duration}    Convert to Number    ${input_duration}
    ${minimum_duration}    Convert to Number    ${minimum_duration}
    ${is_minimum_duration}    evaluate    ${input_duration} >= ${minimum_duration}
    [Return]    ${is_minimum_duration}

get list of recordings from as with minimum duration
    [Arguments]    ${min_duration}    ${recording_list}
    [Documentation]    Validate stability recordings ${recording_list} before commencing iteration tests on them, and return the validated list
    ...    The minimum record duration expected is ${min_duration}
    ${recording_collection_details}    get recording collection via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${min_duration_secs}    robot.libraries.DateTime.Convert time    ${min_duration}
    ${min_duration_secs}    Convert to Number    ${min_duration_secs}
    @{validated_list}    Create List
    : FOR    ${recording}    IN    @{recording_collection_details.recordings.recordingsData}
    \    ${is_technical_duration_ok}    is the duration meeting the expected minimum    ${recording.technicalDuration}    ${min_duration_secs}
    \    ${is_display_duration_ok}    is the duration meeting the expected minimum    ${recording.displayDuration}    ${min_duration_secs}
    \    ${is_recording_recorded}    evaluate    '${recording.status}'=='COMPLETE' or '${recording.status}'=='STARTED'
    \    run keyword if    ${is_technical_duration_ok} and ${is_display_duration_ok} and ${is_recording_recorded}    Append to List    ${validated_list}    ${recording.recordingId}
    ${recordings_count}    Get Length    ${validated_list}
    should be true    '${recordings_count}'!='0'    No validated recordings available to test
    [Return]    ${validated_list}

Record current event on the trickplay channels
    [Documentation]    Record the current event playing on the channels
    @{stability_recording_ids}    Record current event on stability channels    ${TRICKPLAY_CHANNELS}
    [Return]    @{stability_recording_ids}

Record current event on stability channels
    [Arguments]    ${channel_list}
    [Documentation]    Record the current event playing on the given channels in the channel list
    @{stability_recording_ids}    Create List
    : FOR    ${channel_number}    IN    @{channel_list}
    \    ${channel_id}    Get channel ID using channel number    ${channel_number}
    \    @{current_event}    Get current channel event via as    ${channel_id}
    \    ${epoch_event_start_time}    convert date    @{current_event}[1]    epoch
    \    ${recording_id}    Create event recording    ${channel_id}    @{current_event}[0]    ${epoch_event_start_time}
    \    Append to List    ${stability_recording_ids}    ${recording_id}
    [Return]    @{stability_recording_ids}

Get current channel event via as    #USED
    [Arguments]    ${channel_id}
    [Documentation]    Get the current event playing on the channel 'channel_id'. Returns the following :
    ...    element array with [eventid , start time , end time, event duration]
    ${timestamp}    robot.libraries.DateTime.get current date    result_format=%Y-%m-%d %H:%M:%S
    ${timestamp}    robot.libraries.DateTime.Convert Date    ${timestamp}    epoch
    ${timestamp}    Convert to integer    ${timestamp}
    ${current_event}    get current event via as    ${STB_IP}    ${CPE_ID}    ${channel_id}    ${timestamp}    xap=${XAP}
    [Return]    ${current_event}

Get recording ID list from STB via AS
    [Documentation]    Get recording ID list from STB vai application service
    ${recording_collection_details}    get recording collection via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    @{recording_id_list}    Create List
    : FOR    ${recording}    IN    @{recording_collection_details.recordings.recordingsData}
    \    Append to List    ${recording_id_list}    ${recording.originEventId}
    [Return]    @{recording_id_list}

Get lDVR recording playback locator
    [Arguments]    ${customer_id}    ${recording_id}
    [Documentation]    Get lDVR recording playback locator via AS using arguments customer_id, recording_id and cpe_id
    ${playback_location}    get ldvr recording playback locator via as    ${STB_IP}    ${CPE_ID}    ${customer_id}    ${recording_id}    xap=${XAP}
    [Return]    ${playback_location}

Stability record play and delete recordings
    [Arguments]    ${min_duration}    ${channel_list}
    [Documentation]    Record events from ${channel_list} channels(with {min_duration} minimum duration), playback and delete them
    @{recordings_ids}    Record current event on stability channels    ${channel_list}
    I wait for ${min_duration} minutes
    ${validated_recording_ids}    get list of recordings from as with minimum duration    ${min_duration}    ${recordings_ids}
    : FOR    ${recording_id}    IN    @{validated_recording_ids}
    \    Stability play and delete individual recording    ${recording_id}    ${FREE_CHANNEL_1}    30

Stability play and delete individual recording
    [Arguments]    ${recording_id}    ${tune_to_lcn}=${FREE_CHANNEL_1}    ${play_duration}=30
    [Documentation]    Play the specified recording ${recording_id} and delete it after playout for specified duration ${play_duration}, and
    ...    tune away to ${tune_to_lcn} channel
    ${session_id}    Play saved recording using media streamer    ${recording_id}
    I wait for ${play_duration} seconds
    wait until keyword succeeds    3 times    100ms    Request to close player session in media streamer    ${session_id}    ${recording_id}
    I tune to stability test channel    ${tune_to_lcn}
    I wait for 5 seconds
    wait until keyword succeeds    3s    100ms    Delete recording via application service    ${recording_id}

Stability record play delete current event of channels
    [Arguments]    ${channel_list}
    [Documentation]    Record(with ${MIN_RECORD_DURATION} minimum duration), play and delete current event of the channels passed in argument '${channel_list}'
    ${status}    run keyword and return status    Stability record play and delete recordings    ${MIN_RECORD_DURATION}    ${channel_list}
    Stability update current iteration report    ${status}
    Run Keyword And Continue On Failure    should be true    ${status}    Iteration ${TEST_ITERATOR} failed and continuing the test
    return from keyword if    ${status}
    I Press    STOP
    I tune to stability test channel    ${FREE_CHANNEL_1}
    Make sure all recordings are eventually deleted

Stability get channel item for specific recording attempt
    [Arguments]    ${recording_index}    ${channel_count}
    [Documentation]    This keyword searches 'EVENTS_COLLECTION' list and returns the index(pool_id) of the relative
    ...    channel to use for recording next
    ${pool_id}    evaluate    ${recording_index}%${channel_count}
    ${channel_element}    Get From List    ${EVENTS_COLLECTION}    ${pool_id}
    [Return]    ${channel_element}

Stability schedule the next event recording for this channel
    [Arguments]    ${channel_element}
    [Documentation]    This keyword books sequential events from a pool(list) of channel IDs 'EVENTS_COLLECTION', indexed by 'pool_id' and reports pass rate suitably.
    ...    Input is the element from the pool mapping the specific channel, that needs to have next booking done on.
    ...    The dictionary element contains the following keys : 'id', 'events', 'recordings', 'last_position', 'failed_events'.
    ...    Successful recordingIDs are stored in the 'recordings' element, while those failed eventIds are stored in 'failed_events' element.
    ${events}    set variable    ${channel_element['events']}
    ${event_index}    run keyword if    '${channel_element['last_position']}'=='${EMPTY}'    set variable    ${1}
    ...    ELSE    evaluate    ${channel_element['last_position']} + ${1}
    ${event}    set variable    ${events[${event_index}]}
    ${create_recording_status}    ${recording_id}    Run Keyword And Ignore Error    Create event recording    ${channel_element['id']}    ${event['eventId']}    ${event['startTime']}
    Run Keyword And Continue On Failure    should match    ${create_recording_status}    PASS    Create recording failed for '${event['eventId']}' on channel '${channel_element['id']}'
    run keyword if    '${create_recording_status}'=='PASS'    Set To Dictionary    ${channel_element['recordings']}    ${event['startTime']}    ${recording_id}
    ...    ELSE    Append to List    ${channel_element['failed_events']}    ${event['eventId']}
    Set To Dictionary    ${channel_element}    last_position    ${event_index}

Stability create list item for specified channel
    [Arguments]    ${channel_number}    ${recording_count}
    [Documentation]    This keyword creates an element for LCN 'channel_number' in a pool(list) of channel IDs 'EVENTS_COLLECTION', indexed by 'pool_id'.
    ...    The created element is returned to the invoker
    ${channel_id}    Get channel ID using channel number    ${channel_number}
    ${recordings_channel_dict}    Create Dictionary
    ${failed_event_ids_dict}    Create List
    ${timestamp}    robot.libraries.DateTime.get current date    result_format=%Y-%m-%d %H:%M:%S
    ${timestamp}    Convert date    ${timestamp}    epoch
    ${timestamp}    Convert to integer    ${timestamp}
    ${events}    Get channel events via As    ${STB_IP}    ${CPE_ID}    ${channel_id}    ${timestamp}    events_before=0
    ...    events_after=${recording_count}    xap=${XAP}
    ${channel_item}    Create Dictionary
    Set To Dictionary    ${channel_item}    id    ${channel_id}
    Set To Dictionary    ${channel_item}    events    ${events}
    Set To Dictionary    ${channel_item}    recordings    ${recordings_channel_dict}
    Set To Dictionary    ${channel_item}    last_position    ${EMPTY}
    Set To Dictionary    ${channel_item}    failed_events    ${failed_event_ids_dict}
    [Return]    ${channel_item}

Stability populate channel list for recording test
    [Arguments]    ${channel_list}    ${recording_count}
    [Documentation]    This keyword creates a pool(list) of channel IDs 'EVENTS_COLLECTION', indexed by 'pool_id' for the channels
    ...    identified by 'channel_list'. The total number of events in the specified channels is returned to the invoker
    ${total_event_count}    set variable    ${0}
    : FOR    ${channel_number}    IN    @{channel_list}
    \    ${channel_item}    Stability create list item for specified channel    ${channel_number}    ${recording_count}
    \    Append to List    ${EVENTS_COLLECTION}    ${channel_item}
    \    ${event_count_in_channel}    Get Length    ${channel_item['events']}
    \    #    Excluding the first event in the lineup, as it's recording attempt may not give a full recording
    \    ${total_event_count}    evaluate    ${event_count_in_channel} - ${1} + ${total_event_count}
    [Return]    ${total_event_count}

Stability iterate on channel list to perform scheduling test
    [Arguments]    ${recording_count}    ${channel_list}
    [Documentation]    This keyword iterates 'recording_count' over a pool(list) of channel IDs 'EVENTS_COLLECTION' to schedule
    ...    recordings, and to report on the pass rate
    ...    Pre-reqs: ${TEST_ITERATOR} variable should exist.
    Variable should exist    ${TEST_ITERATOR}    Variable TEST_ITERATOR does not exist.
    ${channel_count}    get length    ${channel_list}
    : FOR    ${recording_index}    IN RANGE    ${recording_count}
    \    ${channel_item}    Stability get channel item for specific recording attempt    ${recording_index}    ${channel_count}
    \    ${status}    run keyword and return status    Stability schedule the next event recording for this channel    ${channel_item}
    \    Stability update current iteration report    ${status}
    \    Run Keyword And Continue On Failure    should be true    ${status}    Iteration ${TEST_ITERATOR} failed and continuing the test

Get remaining duration of an ongoing event recording
    [Documentation]    This keyword returns the remaining duration of an ongoing event recording from API request recordingRecords.
    ${recording_collection_details}    get recording collection via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${current_date}    robot.libraries.DateTime.get current date    result_format=%Y-%m-%d %H:%M:%S
    ${current_date}    Convert date    ${current_date}    epoch
    ${current_date}    Convert to integer    ${current_date}
    @{recording_duration_list}    Create List
    : FOR    ${recording}    IN    @{recording_collection_details.recordings.recordingsData}
    \    ${recording_duration}    Evaluate    ${recording.displayEndTime} - ${current_date}
    \    Append to List    ${recording_duration_list}    ${recording_duration}
    Sort List    ${recording_duration_list}
    Reverse List    ${recording_duration_list}
    [Return]    ${recording_duration_list[0]}

Start recording the current entire event From Given Channel List
    [Arguments]    ${channel_list}
    [Documentation]    This keyword starts recording the current entire event on the given channels from list ${channel_list}.
    : FOR    ${channel_number}    IN    @{channel_list}
    \    ${channel_id}    Get channel ID using channel number    ${channel_number}
    \    @{current_event}    Get current channel event via as    ${channel_id}
    \    ${epoch_event_start_time}    convert date    @{current_event}[1]    epoch
    \    ${output}    Create event record via as    ${STB_IP}    ${CPE_ID}    ${channel_id}    @{current_event}[0]
    \    ...    ${epoch_event_start_time}    xap=${XAP}
