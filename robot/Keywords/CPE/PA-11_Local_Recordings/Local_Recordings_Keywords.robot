*** Settings ***
Documentation     Local Recordings keywords
Resource          ../PA-11_Local_Recordings/Local_Recordings_Implementation.robot

*** Keywords ***
HDD Default Suite Setup with channel verification
    [Arguments]    @{channel_list}
    [Documentation]    Calls keyword 'Default Suite Setup with channel verification' using @{channel_list}
    ...    then checks the number of partial, completed, planned or current recordings on the HDD is 0
    Default Suite Setup with channel verification    @{channel_list}
    There are no partial, completed, planned or current recordings on disk
    ${disk_free_space}    Get free disk space in Kb when Review Buffer occupies no space
    Set Suite variable    ${DISK_FREE_SPACE_NO_RB}    ${disk_free_space}

HDD Recordings Specific Teardown
    [Documentation]    Contains teardown steps for HDD Recordings related tests.
    ...    Triggers `Clean Recordings on HDD box` before calling the Default Suite Teardown.
    Clean Recordings on HDD box
    Default Suite Teardown

Clean Recordings on HDD box
    [Documentation]    If a menu or linear player bar is visible then it is hidden before stopping the recording. Recordings are deleted via AS and a check is made via recordings/getCount to ensure there are 0 recordings
    I press    BACK
    I wait for 5 seconds
    I press    STOP
    I wait for 5 seconds
    Reset All Recordings
    There are no partial, completed, planned or current recordings on disk

There are no partial, completed, planned or current recordings on disk
    [Documentation]    This keyword checks that the number of partial, completed, planned and currently recording
    ...    events is 0. A call to Application services is made to obtain this data.
    There are no partial, completed or current recordings on disk
    There are no planned recordings on disk

There are no partial, completed or current recordings on disk
    [Documentation]    This keyword checks that the number of partial, recorded and currently recording events is 0
    ...    A call to Application services is made using recordings/getCount
    ${recording_count}    Get recording count
    Should be true    ${recording_count}==0    The number of partial, completed and current recordings on the HDD is not 0

There are no planned recordings on disk
    [Documentation]    This keyword checks that the number of planned recordings is 0.
    ...    A call to Application services is made using recordings/getCollection
    ${planned_recording_count}    Get planned recording count
    Should be true    ${planned_recording_count}==0    The number of planned recordings on the HDD is not 0

The partial, completed and current recording count is
    [Arguments]    ${expected_count}
    [Documentation]    This keyword checks if the partial, completed and current recording count
    ...    is equal to argument ${expected_count} A call to Application services is made using recordings/getCount
    ${recording_count}    Get recording count
    Should be true    ${recording_count}==${expected_count}    The number of partial, completed and current recordings on the HDD is not ${expected_count}

The planned recording count
    [Documentation]    This keyword get the number of planned recordings
    ...    A call to Application services is made using recordings/getCollection
    ${planned_recording_count}    Get planned recording count
#    Set Suite Variable    ${planned_recording_count}    ${planned_recording_count}
    [Return]  ${planned_recording_count}
    
The planned recording count is
    [Arguments]    ${expected_count}
    [Documentation]    This keyword checks that the number of planned recordings is ${expected_count}
    ...    A call to Application services is made using recordings/getCollection
    ${planned_recording_count}    Get planned recording count
    Should be true    ${planned_recording_count}==${expected_count}    The number of planned recordings on the HDD is not ${expected_count}

The disk free space has decreased due to recordings
    [Documentation]    This keyword gets the disk free space via AS after clearing the review buffer then checks
    ...    if this value is less than the value stored in ${DISK_FREE_SPACE_NO_RB} which is set in keyword
    ...    'HDD Default Suite Setup with channel verification' which runs at the start of each HDD test case.
    ...    A useful keyword to use if checking that a recording has taken up disk space.
    ${current_disk_free_space_no_review_buffer}    Get free disk space in Kb when Review Buffer occupies no space
    Should be true    ${current_disk_free_space_no_review_buffer} < ${DISK_FREE_SPACE_NO_RB}    Current disk free space is not less than the initial disk free space - Review buffer cleared in both cases

The initial disk free space is unchanged
    [Documentation]    This keyword gets the disk free space via AS after clearing the review buffer then checks
    ...    if this value is the same as the value stored in ${DISK_FREE_SPACE_NO_RB} which is set in keyword
    ...    'HDD Default Suite Setup with channel verification' which runs at the start of each HDD test case.
    ...    There's a tolerance value in case a small amount of review buffer is created after the channel tune
    ${current_disk_free_space_no_review_buffer}    Get free disk space in Kb when Review Buffer occupies no space
    ${used_space_difference}    Evaluate    abs(${current_disk_free_space_no_review_buffer} - ${DISK_FREE_SPACE_NO_RB})
    Should be true    ${used_space_difference} < ${DISK_SPACE_UNCHANGED_TOLERANCE_VALUE}    Current disk free space is not equal to the initial disk free space - Review buffer cleared in both cases

The number of recordings with status filter '${status_filter}' is '${expected_recording_record_count}'
    [Documentation]    This keyword obtains a list of all recording records where the recording status matches
    ...    the recording status provided in parameter ${status_filter}. It then verifies that the number of
    ...    recordings returned is equal to the value provided in parameter ${expected_recording_record_count}
    ${status_list}    Create list    ${status_filter}
    ${recording_records}    Get recording records using filter status and status list    ${status_list}
    ${actual_recording_record_count}    Get Length    ${recording_records}
    Should be equal as integers    ${expected_recording_record_count}    ${actual_recording_record_count}    The number of recording records returned with filter ${status_filter} was not equal to the expected amount

I press REC on the currently focused single event HDD
    [Documentation]    This keyword presses the REC button expecting to be tuned to a single event channel.
    ...    Pre-reqs: Already tuned to a single event channel
    ...    NOTE: Currently...this keyword will only work for a CPE with HDD and local recordings enabled,
    ...    as it checks padding options are present on the interactive modal.
    I press    REC
    Interactive modal with options 'Record' and 'Close' is shown
    Interactive modal contains pre padding and post padding settings

I start recording an ongoing single event from CB HDD
    [Documentation]    This keyword starts recording an ongoing single event from the Channel Bar.
    ...    Pre-reqs: Already tuned to a single event channel
    ...    NOTE: Currently...this keyword will only work for a CPE with HDD and local recordings enabled,
    ...    as it checks padding options are present on the interactive modal.
    I open Channel Bar
    I press REC on the currently focused single event HDD
    I press OK on 'Record' option
    'Now Recording' toast message is shown

I start recording an ongoing single event from Live HDD
    [Documentation]    This keyword starts recording an ongoing single event from Live (no CB).
    ...    Pre-reqs: Already tuned to a single event channel
    ...    NOTE: Currently...this keyword will only work for a CPE with HDD and local recordings enabled,
    ...    as it checks padding options are present on the interactive modal.
    I press    LIVETV
    Channel Bar is not shown
    I press REC on the currently focused single event HDD
    I press OK on 'Record' option
    'Now Recording' toast message is shown

I create a partial recording of an ongoing event HDD
    [Documentation]    This keyword creates a partial recording, on a single event from the channel bar.
    ...    Pre-reqs: Already tuned to a single event channel
    I open Channel Bar
    I verify that metadata is present on channel bar
    I press REC on the currently focused single event HDD
    I press OK on 'Record' option
    Currently recording icon is shown in Channel bar
    I wait for 15 seconds
    I stop the ongoing recording through Saved

I record an ongoing single event from Live to completion HDD
    [Documentation]    This keyword records an ongoing single event from Live (no CB) to completion
    ...    Pre-reqs: Already tuned to a single event channel
    ...    NOTE: Currently...this keyword will only work for a CPE with HDD and local recordings enabled,
    ...    as it checks padding options are present on the interactive modal.
    set test variable    ${SINGLE_OR_EPISODE}    single
    I start recording an ongoing single event from Live HDD
    I open Recordings through Saved
    Wait Until Keyword Succeeds    20 times    1 min    I check if recording finished

I record an ongoing single event from CB to completion HDD
    [Documentation]    This keyword records an ongoing single event from the Channel Bar, to completion
    ...    Pre-reqs: Already tuned to a single event channel.
    ...    NOTE: Currently...this keyword will only work for a CPE with HDD and local recordings enabled,
    ...    as it checks padding options are present on the interactive modal.
    set test variable    ${SINGLE_OR_EPISODE}    single
    I start recording an ongoing single event from CB HDD
    I open Recordings through Saved
    Wait Until Keyword Succeeds    25 times    1 min    I check if recording finished

I press REC on an ongoing series episode HDD
    [Documentation]    This keyword presses the REC button expecting to be tuned to a series event.
    ...    It doesn't matter if the Channel Bar is up or not.
    ...    Pre-reqs: Already tuned to a series channel
    ...    NOTE: Currently...this keyword will only work for a CPE with HDD and local recordings enabled,
    ...    as it checks padding options are present on the interactive modal.
    I press    REC
    Interactive modal with options 'Record complete series' and 'Record this Episode' is shown
    Interactive modal contains pre padding and post padding settings

I start recording an ongoing series episode from CB HDD
    [Documentation]    This keyword starts recording an ongoing series episode from the Channel Bar.
    ...    Pre-reqs: Already tuned to a series channel
    ...    NOTE: Currently...this keyword will only work for a CPE with HDD and local recordings enabled,
    ...    as it checks padding options are present on the interactive modal.
    I open Channel Bar
    I press REC on an ongoing series episode HDD
    I press OK on 'Record this episode' option
    'Now Recording' toast message is shown

I start recording an ongoing series episode from Live HDD
    [Documentation]    This keyword starts recording an ongoing series episode from Live (no CB).
    ...    Pre-reqs: Already tuned to a series channel
    ...    NOTE: Currently...this keyword will only work for a CPE with HDD and local recordings enabled,
    ...    as it checks padding options are present on the interactive modal.
    I press    LIVETV
    Channel Bar is not shown
    I press REC on an ongoing series episode HDD
    I press OK on 'Record this episode' option
    'Now Recording' toast message is shown

I create a partial recording of an ongoing series episode HDD
    [Documentation]    This keyword creates a partial recording, on a series episode from the channel bar.
    ...    Pre-reqs: Already tuned to a series event channel
    I start recording an ongoing series episode from CB HDD
    Currently recording icon is shown in Channel bar
    I wait for 15 seconds
    I stop the ongoing recording through Saved

I record an ongoing series episode from Live to completion HDD
    [Documentation]    This keyword records an ongoing series episode from Live (no CB) to completion
    ...    Pre-reqs: Already tuned to a series channel
    ...    NOTE: Currently...this keyword will only work for a CPE with HDD and local recordings enabled,
    ...    as it checks padding options are present on the interactive modal.
    set test variable    ${SINGLE_OR_EPISODE}    episode
    I start recording an ongoing series episode from Live HDD
    I open Recordings through Saved
    Wait Until Keyword Succeeds    20 times    1 min    I check if recording finished

I start recording a complete series from the ongoing series episode interactive modal from CB HDD
    [Documentation]    This keyword starts recording an ongoing series from the Channel Bar.
    ...    Pre-reqs: Already tuned to a series channel
    ...    NOTE: Currently...this keyword will only work for a CPE with HDD and local recordings enabled,
    ...    as it checks padding options are present on the interactive modal.
    I open Channel Bar
    I press REC on an ongoing series episode HDD
    I press OK on 'Record complete series' option
    Toast message 'Series recording scheduled' is shown

I schedule a future single event recording from the Channel Bar HDD
    [Documentation]    This keyword schedules a future single event recording.
    ...    Pre-reqs: Already tuned to a single event channel.
    ...    NOTE: Currently...this keyword will only work for a CPE with HDD and local recordings enabled,
    ...    as it checks padding options are present on the interactive modal.
    I focus Next event in Channel Bar
    Future event is focused
    I verify that metadata is present on channel bar
    I press    REC
    Interactive modal with options 'Record' and 'Close' is shown
    Interactive modal contains pre padding and post padding settings
    I press OK on 'Record' option

I press REC on a future series episode from the Channel Bar HDD
    [Documentation]    This keyword focuses the next event in the channel bar; verifies the Channel Bar has metadata;
    ...    presses REC then checks the interactive modal contains the options 'Record complete series' and
    ...    'Record this episode' and finally checks that the modal has pre and post padding settings.
    ...    Pre-reqs: Already tuned to a series channel
    I focus Next event in Channel Bar
    Future event is focused
    I verify that metadata is present on channel bar
    I press    REC
    Interactive modal with options 'Record complete series' and 'Record this Episode' is shown
    Interactive modal contains pre padding and post padding settings

I schedule a future series episode recording from the Channel Bar HDD
    [Documentation]    This keyword schedules a future single episode recording from the Channel Bar.
    ...    Pre-reqs: Already tuned to a series channel.
    ...    NOTE: Currently...this keyword will only work for a CPE with HDD and local recordings enabled,
    ...    as it checks padding options are present on the interactive modal.
    I press REC on a future series episode from the Channel Bar HDD
    I press OK on 'Record this episode' option

I schedule a future series recording from the Channel Bar HDD
    [Documentation]    This keyword schedules a future series recording.
    ...    Pre-reqs: Already tuned to a series channel.
    ...    NOTE: Currently...this keyword will only work for a CPE with HDD and local recordings enabled,
    ...    as it checks padding options are present on the interactive modal.
    I press REC on a future series episode from the Channel Bar HDD
    I press OK on 'Record complete series' option

I schedule a future event recording from TV Guide    #USED
    [Documentation]    This keyword schedules a future event recording.
    ...    Pre-reqs: Already tuned to a channels with recordings enable (Replay Channel).
    I open Guide through the remote button
    I focus Next event
    I press    OK
    Linear Details Page is shown
    I schedule 'future' recording using REC Button

I open the Saved Recordings list from Saved with filter 'Recorded'    #USED
    [Documentation]    This keyword opens the Saved Recordings list by selecting the 'Show all' tile under
    ...    Saved, 'Recorded'.
    ...    Pre-reqs: We're inside Saved, with highlight on RECORDINGS
    I focus recording collection
    I press    OK
    Wait Until Keyword Succeeds    10 times    500ms    I expect page contains 'textKey:DIC_DISK_SPACE_NR'
    Wait Until Keyword Succeeds    10 times    500ms    I expect page contains 'textKey:DIC_FILTER_RECORDED'

I open the Saved Recordings list from Saved with filter 'Scheduled'
    [Documentation]    This keyword opens the Saved Recordings list by selecting the 'Show all' tile under
    ...    Saved, 'Scheduled recordings'.
    ...    Pre-reqs: We're inside Saved, with highlight on RECORDINGS
    I focus planned recording collection
    I press    OK
    Wait Until Keyword Succeeds    10 times    500ms    I expect page contains 'textKey:DIC_DISK_SPACE_NR'
    Wait Until Keyword Succeeds    10 times    500ms    I expect page contains 'textKey:DIC_FILTER_PLANNED_RECORDINGS'

Interactive modal contains pre padding and post padding settings
    [Documentation]    HDD interactive modals contain pre and post padding settings. Verify that they are present and
    ...    that we have the id for each of the setting fields value text. We're not trying to verify specific keys or
    ...    values for the padding values.
    Interactive modal is shown
    ${json_object}    Get Ui Json
    ${pre_padding_title_text}    Is In Json    ${json_object}    id:titleText_prePadding    textKey:DIC_EXTRA_BEFORE    ${EMPTY}
    ${post_padding_title_text}    Is In Json    ${json_object}    id:titleText_postPadding    textKey:DIC_EXTRA_AFTER    ${EMPTY}
    ${pre_padding_setting_field}    Is In Json    ${json_object}    ${EMPTY}    id:settingFieldValueText_prePadding    ${EMPTY}
    ${post_padding_setting_field}    Is In Json    ${json_object}    ${EMPTY}    id:settingFieldValueText_postPadding    ${EMPTY}
    should be true    ${pre_padding_title_text}    pre padding titleText is not present on screen
    should be true    ${post_padding_title_text}    post padding titleText is not present on screen
    should be true    ${pre_padding_setting_field}    pre padding setting field is not present on screen
    should be true    ${post_padding_setting_field}    post padding setting field is not present on screen

I set 'Extra time before' and 'Extra time after' on the interactive modal to
    [Arguments]    ${pre_padding_val}    ${post_padding_val}
    [Documentation]    This keyword opens the 'Extra time before' and 'Extra time after' pickers on the interactive
    ...    modal and sets the values to those passed in arguments ${pre_padding_val} and ${post_padding_val},
    ...    then checks that the chosen settings are set correctly on the modal
    ...    NOTE: Values in pre_padding_val and post_padding_val must match those on screen for navigation to work
    I set 'Extra time before' on the interactive modal to    ${pre_padding_val}
    I set 'Extra time after' on the interactive modal to    ${post_padding_val}

I set 'Extra time before' on the interactive modal to
    [Arguments]    ${pre_padding_val}
    [Documentation]    This keyword focuses and opens the 'Extra time before' picker on the interactive modal
    ...    then it navigates inside the picker to the value in argument ${pre_padding_val} and selects it,
    ...    checking that the setting is reflected on the interactive modal
    ...    Pre-reqs: An interactive modal with pre and post padding options is displayed on screen
    ...    NOTE: Values in pre_padding_val must match those on screen for navigation to work
    I open 'Extra time before' picker on the interactive modal
    I set 'Extra time before' picker value to    ${pre_padding_val}

I set 'Extra time after' on the interactive modal to
    [Arguments]    ${post_padding_val}
    [Documentation]    This keyword focuses and opens the 'Extra time after' picker on the interactive modal
    ...    then it navigates inside the picker to the value in argument ${post_padding_val} and selects it,
    ...    checking that the setting is reflected on the interactive modal
    ...    Pre-reqs: An interactive modal with pre and post padding options is displayed on screen
    ...    NOTE: Values in post_padding_val must match those on screen for navigation to work
    I open 'Extra time after' picker on the interactive modal
    I set 'Extra time after' picker value to    ${post_padding_val}

I open 'Extra time before' picker on the interactive modal
    [Documentation]    This keyword focuses and opens the 'Extra time before' picker on the interactive modal
    ...    Pre-reqs: An interactive modal with pre and post padding options is displayed on screen
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:titleText_prePadding'
    I focus 'Extra time before' on the interactive modal
    I Press    OK
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:value-picker-selection'

I open 'Extra time after' picker on the interactive modal
    [Documentation]    This keyword focuses and opens the 'Extra time after' episode picker on the interactive modal
    ...    Pre-reqs: An interactive modal with pre and post padding options is displayed on screen
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:titleText_postPadding'
    I focus 'Extra time after' on the interactive modal
    I Press    OK
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:value-picker-selection'

I focus 'Extra time before' on the interactive modal
    [Documentation]    This keyword focuses the 'Extra time before' option on the interactive modal
    ...    Pre-reqs: An interactive modal with pre and post padding options is present on screen
    Move Focus to Value Picker Option in Modal    textKey:DIC_EXTRA_BEFORE    DOWN    5

I focus 'Extra time after' on the interactive modal
    [Documentation]    This keyword focuses the 'Extra time after' option on the interactive modal
    ...    Pre-reqs: An interactive modal with pre and post padding options is present on screen
    Move Focus to Value Picker Option in Modal    textKey:DIC_EXTRA_AFTER    DOWN    5

I set 'Extra time before' picker value to
    [Arguments]    ${pre_padding_val}
    [Documentation]    This keyword sets the 'Extra time before' picker value to ${pre_padding_val}
    ...    Pre-reqs: The 'Extra time before' picker is open
    ...    NOTE: Values in pre_padding_val must match those on screen for navigation to work
    I focus '${pre_padding_val}' on the extra time picker
    I press    OK
    'Extra time before' value on the interactive modal is set to    ${pre_padding_val}

I set 'Extra time after' picker value to
    [Arguments]    ${post_padding_val}
    [Documentation]    This keyword sets the 'Extra time after' picker value to ${post_padding_val}
    ...    Pre-reqs: The 'Extra time after' picker is open
    ...    NOTE: Values in post_padding_val must match those on screen for navigation to work
    I focus '${post_padding_val}' on the extra time picker
    I press    OK
    'Extra time after' value on the interactive modal is set to    ${post_padding_val}

'Extra time before' value on the interactive modal is set to
    [Arguments]    ${pre_padding_val}
    [Documentation]    This keyword checks that the 'Extra time before' value is set to ${pre_padding_val}
    ...    Pre-reqs: An interactive modal with pre and post padding options is present on screen
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:settingFieldValueText_prePadding' contains 'textValue:${pre_padding_val} .*' using regular expressions

'Extra time after' value on the interactive modal is set to
    [Arguments]    ${post_padding_val}
    [Documentation]    This keyword checks that the 'Extra time after' value is set to ${post_padding_val}
    ...    Pre-reqs: An interactive modal with pre and post padding options is present on screen
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:settingFieldValueText_postPadding' contains 'textValue:${post_padding_val} .*' using regular expressions

I focus '${padding_text_value}' on the extra time picker
    [Documentation]    This keyword focuses on the value set in ${padding_text_value}
    ...    NOTE: Values in padding_value must match those on screen for navigation to work
    ...    Pre-reqs: A padding picker is open
    ${picker_indicies}    Get padding picker current and desired positions as index values    ${padding_text_value}
    ${current_picker_highlight_position}    set variable    ${picker_indicies[0]}
    ${desired_picker_highight_position}    set variable    ${picker_indicies[1]}
    return from keyword if    ${current_picker_highlight_position} == ${desired_picker_highight_position}
    ${directon_key}    Set Variable if    ${current_picker_highlight_position} < ${desired_picker_highight_position}    DOWN    UP
    Move Focus to Option in Value Picker    textValue:${padding_text_value}    ${directon_key}    15

I press OK on 'Continue recording' option
    [Documentation]    Focus and select 'Continue recording' on the interactive modal
    Interactive modal with options 'Continue recording' and 'Delete recording' is shown
    I focus 'Continue recording' option
    I press    OK

Interactive modal with options 'Continue recording' and 'Delete recording' is shown
    [Documentation]    This keyword asserts the Edit Recording modal window with 'Continue recording'
    ...    and 'Delete recording' testKey options is shown.
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_INTERACTIVE_MODAL_HEADER_EDIT_RECORDING'
    ${edit_rec_header}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    textKey:DIC_INTERACTIVE_MODAL_HEADER_EDIT_RECORDING    ${EMPTY}
    ${edit_rec_continue_recording_option}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    textKey:DIC_INTERACTIVE_MODAL_BUTTON_RESUME_RECORDING    ${EMPTY}
    ${edit_rec_delete_recording_option}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    textKey:DIC_INTERACTIVE_MODAL_BUTTON_DELETE_RECORDING_YES    ${EMPTY}
    should be true    ${edit_rec_header}    Edit recording header is not present on screen
    should be true    ${edit_rec_continue_recording_option}    Edit recording Continue option is not present on screen
    should be true    ${edit_rec_delete_recording_option}    Edit recording Delete recording option is not present on screen
    Interactive modal contains pre padding and post padding settings

I focus 'Continue recording' option
    [Documentation]    This keyword puts focus on the 'Continue recording' option in the modal popup window
    Move Focus to Button in Interactive Modal    textKey:DIC_INTERACTIVE_MODAL_BUTTON_RESUME_RECORDING    UP    8

I focus 'Record' option after setting padding values
    [Documentation]    After setting a pre or post padding value, the highlight will be below the 'Record' option
    ...    so this keyword moves up to it, rather than the existing focus 'Record' keyword, which moves down
    Move Focus to Button in Interactive Modal    textKey:DIC_NPVR_RECORD_BUTTON_SINGLE    UP    8

The CB booked event name matches the name fetched from the recording collection bookingsData at index
    [Arguments]    ${index}
    [Documentation]    The name of the booked event is stored in a test variable, ${CB_FOCUSED_EVENT_NAME}, when
    ...    the event is highlighted in the channel bar. This keyword compares this name to the fetched bookingsData
    ...    in the recording collection, which has been placed in a list of all bookings, and expects a match
    ...    with the item stored in index ${index}
    Variable should exist    ${CB_FOCUSED_EVENT_NAME}    A channel bar focused event name has not been set in CB_FOCUSED_EVENT_NAME
    ${booking_data}    Get item at index '${index}' in the list of all bookings
    should be equal as strings    ${CB_FOCUSED_EVENT_NAME}    ${booking_data['displayTitle']}    Focused CB event name is not equal to the fetched booking name for index ${index}

I wait until event end time
    [Documentation]    This keyword waits until the event ends by waiting for the number of minutes contained in
    ...    test variable TIME_TO_WAIT_UNTIL_EVENT_END_MINS
    ...    Pre-reqs: Test variable TIME_TO_WAIT_UNTIL_EVENT_END_MINS is set
    I wait for ${TIME_TO_WAIT_UNTIL_EVENT_END_MINS} minutes

I calculate time to wait until event end time
    [Documentation]    This keyword gets the current STB time from the guide masthead and calculates the difference
    ...    between this time and the end time saved in test variable ${LAST_EVENT_END_TIME}. It then adds 2 minutes
    ...    to this time as a safety buffer and sets this value in test variable TIME_TO_WAIT_UNTIL_EVENT_END_MINS
    ...    Pre-reqs: Test var ${LAST_EVENT_END_TIME} has been set
    Variable should exist    ${LAST_EVENT_END_TIME}    Test var LAST_EVENT_END_TIME has not been set in PA-06_TV_Guide
    ${masthead_time}    Get STB time from channel bar masthead
    ${time_interval}    get time interval    ${masthead_time}    ${LAST_EVENT_END_TIME}
    ${split_time}    split string    ${time_interval}    :
    ${wait_time}    evaluate    ${split_time[1]}+2
    Set test variable    ${TIME_TO_WAIT_UNTIL_EVENT_END_MINS}    ${wait_time}

I start recording '${count}' ongoing concurrent '${event_type}' recordings from the Guide
    [Documentation]    This keyword creates ${count} ongoing event concurrent recordings of event type ${event_type}
    ...    from the guide, after working out whether there's enough time left in the events to set all of them recording
    ...    before they become past events. If there's not enough time, we wait for the next event to become a current event
    ...    and then start recording
    ...    Valid values for ${event_type} are 'single' and 'episode'
    ${channels}    Set Variable if    '${event_type}' == 'single'    ${SINGLE_EVENT_CHANNEL_LIST}    ${SERIES_EVENT_CHANNEL_LIST}
    I open Guide through the remote button
    : FOR    ${chan_index}    IN RANGE    ${count}
    \    ${channel}    set variable    ${channels[${chan_index}]}
    \    I press    ${channel}
    \    wait until keyword succeeds    5 times    1s    Channel Is Focused In Guide    ${channel}
    \    ${channel_id}    Get channel ID using channel number    ${channel}
    \    ${remaining_duration}    get event remaining duration    ${channel_id}    ${CPE_ID}
    \    run keyword if    ${channel} == ${channels[0]} and ${remaining_duration} < ${TIME_NEEDED_FOR_MAX_RECS_IN_SECONDS}    run keywords    I focus Next event
    \    ...    AND    I wait for ${TIME_NEEDED_FOR_MAX_RECS_IN_SECONDS} seconds
    \    Set '${event_type}' event to record
    \    Run keyword if    ${chan_index} == ${CONFLICT_RECORDING_INDEX}    The 'Recording conflict' Interactive modal is shown
    \    ...    ELSE    'Now recording' toast message is shown

I create a recording conflict by recording an ongoing '${event_type}' recording from the Guide
    [Documentation]    This keyword creates a recording of event type ${event_type} which will cause a conflict
    ...    Valid values for ${event_type} are 'single' and 'episode'
    ...    Pre-reqs: There are already the maximum number of allowed ongoing recordings e.g. 6 for lDVR
    ${channels}    Set Variable if    '${event_type}' == 'single'    ${SINGLE_EVENT_CHANNEL_LIST}    ${SERIES_EVENT_CHANNEL_LIST}
    ${number_of_channels}    Get Length    ${channels}
    ${channel}    set variable    ${channels[${number_of_channels - 1}]}
    I open Guide through the remote button
    I press    ${channel}
    wait until keyword succeeds    5 times    1s    Channel Is Focused In Guide    ${channel}
    Set '${event_type}' event to record
    The 'Recording conflict' Interactive modal is shown

The 'Recording conflict' Interactive modal is shown
    [Documentation]    This keyword asserts the 'Recording conflict' interactive modal is shown
    Interactive modal is shown
    ${rec_conflict_header}    run keyword and return status    Wait Until Keyword Succeeds    10 times    1s    Is In Json    ${LAST_FETCHED_JSON_OBJECT}
    ...    ${EMPTY}    textKey:DIC_INTERACTIVE_MODAL_HEADER_REC_CONFLICT    ${EMPTY}
    should be true    ${rec_conflict_header}    Recording conflict header is not present on screen

I cancel the recording from the 'Recording conflict' Interactive modal at index
    [Arguments]    ${rec_index}
    [Documentation]    This keyword cancels the recording at position ${rec_index} from the 'Recording conflict'
    ...    Interactive modal. The indicies start at 0.
    ...    Pre-reqs: The 'recording conflict' modal is on-screen
    Move to element assert focused elements    id:bodyMessage-button-node-1-${rec_index}    15    DOWN
    I press    OK
    Interactive modal is not shown

The current guide '${event_type}' event at index '${chan_list_index}' has a partial recording icon
    [Documentation]    This keyword enters the guide, tunes to the correct channel using the event
    ...    of type ${event_type} at index ${chan_list_index} in the list of recordings, then checks if
    ...    this event has a partial recording icon. If we've taken too much time and the event is no longer the
    ...    current event, we move left and check again.
    ...    Pre-reqs: The recording can be found on one of the channels in either the
    ...    ${SINGLE_EVENT_CHANNEL_LIST} or ${SERIES_EVENT_CHANNEL_LIST}
    ...    We only have one partial icon present on the tuned channel on the current or previous event.
    ${channels}    Set Variable if    '${event_type}' == 'single'    ${SINGLE_EVENT_CHANNEL_LIST}    ${SERIES_EVENT_CHANNEL_LIST}
    ${channel}    set variable    ${channels[${chan_list_index}]}
    I open Guide through the remote button
    I press    ${channel}
    Wait Until Keyword Succeeds    5 times    1s    Channel Is Focused In Guide    ${channel}
    Move to element assert focused elements using regular expression    iconKeys:.*RECORDING_PARTIAL.*    2    LEFT

I start recording '${count}' future concurrent '${event_type}' recordings from the Guide
    [Documentation]    This keyword creates ${count} future event concurrent recordings of event type ${event_type}
    ...    from the guide, after working out whether there's enough time to create all recordings before they become
    ...    current events. If there's not enough time, we move two events into the future from the current event
    ...    instead of one.
    ...    The title of each event is saved to test variable SAVED_EVENT_TITLES
    ...    Valid values for ${event_type} are 'single' and 'episode'
    @{event_title_list}    Create List
    ${channels}    Set Variable if    '${event_type}' == 'single'    ${SINGLE_EVENT_CHANNEL_LIST}    ${SERIES_EVENT_CHANNEL_LIST}
    I open Guide through the remote button
    : FOR    ${chan_index}    IN RANGE    ${count}
    \    ${channel}    set variable    ${channels[${chan_index}]}
    \    I press    ${channel}
    \    wait until keyword succeeds    5 times    1s    Channel Is Focused In Guide    ${channel}
    \    ${channel_id}    Get channel ID using channel number    ${channel}
    \    ${remaining_duration}    get event remaining duration    ${channel_id}    ${CPE_ID}
    \    run keyword if    ${channel} == ${channels[0]} and ${remaining_duration} < ${TIME_NEEDED_FOR_MAX_RECS_IN_SECONDS}    I focus Next event
    \    run keyword if    ${channel} == ${channels[0]}    I focus Next event
    \    ${final_date_timestamp_epoch}    Get highlighted future event date and time as an epoch time
    \    ${event_info}    Get channel events via As    ${STB_IP}    ${CPE_ID}    ${channel_id}    ${final_date_timestamp_epoch}
    \    ...    events_before=0    events_after=0    xap=${XAP}
    \    Append To List    ${event_title_list}    ${event_info[0]['title']}
    \    Set '${event_type}' event to record
    \    Run keyword if    ${chan_index} == ${CONFLICT_RECORDING_INDEX}    The 'Recording conflict' Interactive modal is shown
    \    ...    ELSE    'Recording scheduled' toast message is shown
    Set test variable    ${SAVED_EVENT_TITLES}    ${event_title_list}

All '${count}' recordings in Saved have the recorded icon
    [Documentation]    This keyword checks that all ${count} recordings in Saved have the recorded icon
    ...    next to each event.
    ...    Pre-Reqs: On the Saved screen
    ${json_object}    Get Ui Json
    ${json_string}    Read Json As String    ${json_object}
    @{collection}    get regexp matches    ${json_string}    d0021bff>V</font>
    ${count_check}    Get Length    ${collection}
    Should be true    ${count_check} == ${count}    Did not find ${count} recorded icons in the Saved Recordings list. Found ${count_check}

I have a Failed playable Single event recording
    [Documentation]    Create a failed, playable single event recording by creating a partial recording
    I tune to Single event channel
    I create a partial recording of an ongoing event HDD

I have a Failed playable Single episode recording
    [Documentation]    Create a failed, playable single episode recording by creating a partial recording
    I tune to channel    ${REPLAY_SERIES_CHANNEL}
    I create a partial recording of an ongoing series episode HDD

Failure text is displayed on the recording detail page
    [Documentation]    This keyword checks that we have a textKey starting with DIC_RECORDING_FAILED on the
    ...    details page of a recording
    ...    Pre-reqs: Currently on the details page of a recording
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_RECORDING_FAILED.*' using regular expressions

The conflict resolution dialogue contains all events
    [Documentation]    This keyword verifies that all events saved in test var SAVED_EVENT_TITLES, appear in the
    ...    correct positions in the conflict resolution dialogue that appears on screen.
    ...    Pre-reqs: A conflict dialogue has been created and the highlight is on the first event in the dialogue
    Variable should exist    ${SAVED_EVENT_TITLES}    Event titles have not been saved in test variable SAVED_EVENT_TITLES prior to calling this keyword
    ${max_index}    evaluate    ${CONFLICT_RECORDING_INDEX} + 1
    : FOR    ${index}    IN RANGE    ${max_index}
    \    Get Ui Json
    \    ${highlighted_event_title}    Extract Value For Key    ${LAST_FETCHED_JSON_OBJECT}    id:bodyMessage-button-node-1-${index}    textValue
    \    Should be equal as strings    @{SAVED_EVENT_TITLES}[${index}]    ${highlighted_event_title}    Title fetched from EPG AS:@{SAVED_EVENT_TITLES}[${index}] is not equal to the title shown on the conflict resolution dialogue: ${highlighted_event_title} for index:${index}
    \    I press    DOWN

I start recording an ongoing single event from TV Guide
    [Documentation]    This keyword starts recording an ongoing single event from the TV Guide.
    ...    Pre-reqs: Already tuned to a single event channel
    I open Guide through the remote button
    I press    REC
    Interactive modal with options 'Record' and 'Close' is shown
    I press OK on 'Record' option
    'Now Recording' toast message is shown

I create a partial recording of ongoing event       #USED
    [Documentation]    This keyword creates a partial recording, on a single event from the channel bar.
    ...    Pre-reqs: Already tuned to a single event channel
    I Ensure Channel Is Unlocked From Channel Bar
    I open Channel Bar
    I verify that metadata is present on channel bar
    I schedule 'ongoing' recording using REC Button
    I wait for 5 seconds
    Wait Until Keyword Succeeds    15 times    500ms    Currently recording icon is shown in Channel bar
    I wait for 30 seconds
    I press    REC
    I press OK on 'Stop recording' option