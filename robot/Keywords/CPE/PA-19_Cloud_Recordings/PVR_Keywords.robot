*** Settings ***
Documentation     Cloud Recording keywords
Resource          ../PA-19_Cloud_Recordings/PVR_Implementation.robot

*** Keywords ***
I tune to Series event channel
    [Documentation]    This keyword tunes to the recordable series event channel
    ...    Channel ${RECORDABLE_SERIES_EVENT_CHANNEL} is used as the tuning channel.
    I tune to channel    ${RECORDABLE_SERIES_EVENT_CHANNEL}

Currently recording icon is shown
    [Documentation]    This keyword asserts the currently recording icon is shown
    Wait Until Keyword Succeeds    20 times    300 ms    Currently recording icon is shown implementation

Recording icon is not shown on the collections page
    [Documentation]    This keyword asserts the recording icon is not shown within the Recordings Collection
    I do not expect page contains 'id:listItemIconPvr-ListItem'

I tune to Single event channel
    [Arguments]    ${channel_lcn}=${SINGLE_EVENT_CHANNEL}
    [Documentation]    This keyword tunes to a single event channel.
    ...    Channel ${single_event_channel} is used as the tuning channel.
    I open Channel Bar
    I tune to channel    ${single_event_channel}

There is no recording ongoing in the background
    [Documentation]    This keyword verifies no recording is ongoing in the background
    Reset All Recordings
    ${recording_count}    Get recording count
    should be equal    '${recording_count}'    '0'    One or more recording is present

I focus 'Record this episode'
    [Documentation]    This keyword focuses button 'Record this episode'
    Move to element assert focused elements    textKey:DIC_INTERACTIVE_MODAL_BUTTON_RECORD_EPISODE    5    DOWN

Pending recording icon is shown
    [Documentation]    This keyword asserts the pending recording icon is shown
    Wait Until Keyword Succeeds    20 times    300 ms    Pending recording icon is shown implementation

Currently recording icon is shown in Channel bar        #USED
    [Documentation]    This keyword checks if the currently recording icon is shown on the channel bar current event
    I open Channel Bar
    Wait Until Keyword Succeeds    10 times    300 ms    I expect page element 'id:nnHlist' contains 'iconKeys:RECORDING_CURRENT'

Currently recording icon is shown in Recordings Collection
    [Documentation]    This keyword checks if the currenty recording icon is shown on the current event in the
    ...    Recordings Section under Saved
    Wait Until Keyword Succeeds    20 times    300 ms    I expect page element 'id:^.*CollectionsBrowser' contains 'textKey:DIC_RECORDING_LABEL_RECORDED' using regular expressions

I focus 'Record complete series'
    [Documentation]    This keyword focuses the 'Record complete series' option in the modal window
    Wait Until Keyword Succeeds    10 times    200 ms    I expect page contains 'textKey:DIC_INTERACTIVE_MODAL_BUTTON_RECORD_SERIES'
    Move Focus to Button in Interactive Modal    textKey:DIC_INTERACTIVE_MODAL_BUTTON_RECORD_SERIES    DOWN    2

I Press REC On An Ongoing Series Episode And Focus On Record This Episode   #USED
    [Documentation]    This keyword presses the REC button expecting to be tuned to a series event.
    ...    It doesn't matter if the Channel Bar is up or not.
    ...    Pre-reqs: Already tuned to a series channel
    I press    REC
    Interactive modal with options 'Record complete series' and 'Record this Episode' is shown
    I press    DOWN

Recordings Specific Teardown    #NOT_USED
    [Documentation]    Contains teardown steps for Recordings related tests
    I press    BACK
    I wait for 5 seconds
    I press    STOP
    I wait for 5 seconds
    Reset All Recordings
    Reset All Continue Watching Events
    Default Suite Teardown

Age Locked Recordings Specific Teardown
    [Documentation]    Contains teardown steps for Recordings of Age Locked content related tests
    Reset All Recordings
    I Set Age Rating Of The STB To Off
    Default Suite Teardown

Reset UI and Recordings Specific Teardown
    [Documentation]    Contains teardown steps for Recordings related tests that need a UI restart
    Reset All Recordings
    Restart UI via command over SSH by invoking /sbin/reboot
    Default Suite Teardown

Interactive modal with options 'Record' and 'Close' is shown    #USED
    [Documentation]    This keyword asserts modal window with 'Record' and 'Close' textKey options is shown
    Interactive modal is shown
    I expect page element 'id:interactiveModalButton0' contains 'textKey:DIC_NPVR_RECORD_BUTTON_SINGLE'
    I expect page element 'id:interactiveModalButton1' contains 'textKey:DIC_INTERACTIVE_MODAL_BUTTON_CLOSE'

Interactive modal with options 'Record complete series' and 'Record this Episode' is shown    #USED
    [Documentation]    This keyword asserts modal window with 'Record Series' and 'Record Episode'
    ...    textKey options is shown
    Interactive modal is shown
    I expect page element 'id:interactiveModalButton0' contains 'textKey:DIC_INTERACTIVE_MODAL_BUTTON_RECORD_SERIES'
    I expect page element 'id:interactiveModalButton1' contains 'textKey:DIC_INTERACTIVE_MODAL_BUTTON_RECORD_EPISODE'

Interactive modal with options 'Stop recording this episode ' and 'Cancel Series Recording' is shown
    [Documentation]    This keyword asserts modal window with 'Stop recording this episode'
    ...    and 'Cancel series recording' textKey options is shown
    Interactive modal is shown
    I expect page element 'id:interactiveModalButton0' contains 'textKey:DIC_INTERACTIVE_MODAL_BUTTON_STOP_RECORDING_EPISODE'
    I expect page element 'id:interactiveModalButton1' contains 'textKey:DIC_INTERACTIVE_MODAL_BUTTON_CANCEL_RECORDING_SERIES'

Interactive modal with options 'Stop recording' and 'Stop & delete recording' is shown
    [Documentation]    This keyword asserts modal window with 'Stop recording'
    ...    and 'Stop & delete recording' textKey options is shown
    Interactive modal is shown
    I expect page contains 'textKey:DIC_INTERACTIVE_MODAL_BUTTON_STOP_RECORDING'
    I expect page contains 'textKey:DIC_INTERACTIVE_MODAL_BUTTON_STOP_DELETE_RECORDING'

Interactive modal with options 'Delete recording' and 'Close' is shown
    [Documentation]    This keyword asserts modal window with 'Delete recording' and 'Close' textKey options is shown
    Interactive modal is shown
    I expect page contains 'textKey:DIC_INTERACTIVE_MODAL_BUTTON_DELETE_RECORDING_YES'
    I expect page contains 'textKey:DIC_INTERACTIVE_MODAL_BUTTON_CLOSE'

Interactive modal with options 'Record complete series' and 'Delete recording' is shown
    [Documentation]    This keyword asserts modal window with 'Record Series'
    ...    and 'Delete recording' textKey options is shown
    Interactive modal is shown
    I expect page element 'id:interactiveModalButton0' contains 'textKey:DIC_INTERACTIVE_MODAL_BUTTON_RECORD_SERIES'
    I expect page element 'id:interactiveModalButton1' contains 'textKey:DIC_INTERACTIVE_MODAL_BUTTON_DELETE_EPISODE'

Interactive modal with options 'Delete recording' and 'Delete all & cancel future recordings' is shown
    [Documentation]    This keyword asserts modal window with 'Delete recording'
    ...    and 'Delete all & Cancel future recordings' textKey options is shown
    Interactive modal is shown
    I expect page element 'id:interactiveModalButton0' contains 'textKey:DIC_INTERACTIVE_MODAL_BUTTON_DELETE_EPISODE'
    I expect page element 'id:interactiveModalButton1' contains 'textKey:DIC_INTERACTIVE_MODAL_BUTTON_CANCEL_AND_DELETE_RECORDING_SERIES'

Interactive modal with options 'Record complete series' and 'Cancel Recording' is shown    #USED
    [Documentation]    This keyword asserts modal window with 'Record complete series'
    ...    and 'Cancel recording' textKey options is shown - EPISODE EVENT
    Interactive modal is shown
    I expect page element 'id:interactiveModalButton0' contains 'textKey:DIC_INTERACTIVE_MODAL_BUTTON_RECORD_SERIES'
    I expect page element 'id:interactiveModalButton1' contains 'textKey:DIC_INTERACTIVE_MODAL_BUTTON_CANCEL_SINGLE_REC'

Interactive modal with options 'Cancel Series Recording' and 'Close' is shown
    [Documentation]    This keyword asserts modal window with 'Cancel Series Recording'
    ...    and 'Close' textKey options is shown - FULLSERIE EVENT
    Interactive modal is shown
    I expect page element 'id:interactiveModalButton0' contains 'textKey:DIC_INTERACTIVE_MODAL_BUTTON_CANCEL_RECORDING_SERIES'
    I expect page element 'id:interactiveModalButton1' contains 'textKey:DIC_GENERIC_BTN_CLOSE'

Interactive modal with options 'Cancel recording' and 'Close' is shown    #USED
    [Documentation]    This keyword asserts modal window with 'Cancel recording'
    ...    and 'Close' textKey options is shown - SINGLE EVENT
    Interactive modal is shown
    I expect page element 'id:interactiveModalButton0' contains 'textKey:DIC_INTERACTIVE_MODAL_BUTTON_CANCEL_SINGLE_REC'
    I expect page element 'id:interactiveModalButton1' contains 'textKey:DIC_INTERACTIVE_MODAL_BUTTON_CLOSE'

I record one adult event
    [Documentation]    This keyword records the ongoing event from an adult channel
    I open Channel Bar
    I tune to Adult programme
    I unlock the channel
    Pin Entry popup is not shown
    Verify content unlocked
    I try to record an event
    Interactive modal with options 'Record' and 'Close' is shown
    I focus 'Record' option
    I press    OK
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    1 sec    I do not expect page element 'id:toast.message' contains 'textKey:DIC_SPINNER_SCHEDULING_REC'
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    300 ms    I expect page element 'id:toast.message' contains 'textKey:DIC_TOAST_NOW_RECORDING'
    Currently recording icon is shown

Recording List is empty
    [Documentation]    This keyword deletes all recordings via XAP (if set) then verifies there are no recordings
    Reset All Recordings
    I open Recordings through Saved
    Wait Until Keyword Succeeds    10 times    300 ms    I expect page contains 'textKey:DIC_RECORDINGS_EMPTY_TITLE'

I Verify Saved Recordings List is empty
    [Documentation]    This keyword verifies that the Saved Recordings list is empty
    Wait Until Keyword Succeeds    10 times    300 ms    I do not expect page contains 'id:recordingListItem-\\\\d+' using regular expressions

Planned Recordings List is empty
    [Documentation]    This keyword makes sure there are no planned recordings shown on the the recordings screen
    Recording List is empty
    Verify Planned Recordings List is empty

Verify Planned Recordings List is empty
    [Documentation]    This keyword asserts there are no planned recordings shown on the recordings screen
    Wait Until Keyword Succeeds    10 times    300 ms    I do not expect page contains 'textKey:DIC_ENTRY_TILE_PLANNED_REC'

I open Planned Recordings List through Saved    #USED
    [Documentation]    This keyword opens the 'Scheduled recordings' list through Saved
    I open Recordings through Saved
    I focus Planned Recordings section
    I Press    OK
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_FILTER_PLANNED_RECORDINGS'

Planned Recordings List is not empty
    [Documentation]    This keyword asserts the 'Scheduled recordings' list is empty
    I expect page contains 'id:GRID_COUNTER@RECORDINGS_LIST'
    ${ancestor}    I retrieve json ancestor of level '1' for element 'id:GRID_COUNTER@RECORDINGS_LIST'
    should not match    ${ancestor['textValue']}    ${EMPTY}    Planned recordings are empty

I press OK on 'Record complete series' option
    [Documentation]    Focus and select 'Record complete series' on the Record interactive modal
    Interactive modal with options 'Record complete series' and 'Record this Episode' is shown
    I focus 'Record complete series'
    I press    OK
    Toast message 'Series recording scheduled' is shown

I press OK on 'Record complete series' option in the edit modal
    [Documentation]    This keyword focuses and selects option 'Record complete series' on the edit recording modal
    Interactive modal with options 'Record complete series' and 'Cancel Recording' is shown
    I focus 'Record complete series'
    I press    OK
    Toast message 'Series recording scheduled' is shown

I press OK on 'Record this episode' option    #USED
    [Documentation]    This keyword focuses and selects option 'Record this episode' on the Record interactive modal
    Interactive modal with options 'Record complete series' and 'Record this Episode' is shown
    I focus 'Record this episode'
    I press    OK
    Wait Until Keyword Succeeds And Verify Status    20 times    100 ms    Recording scheduled spinner is not shown    I expect page contains 'id:schedulingRecLoadingSpiner'

I press OK on 'Stop & Delete Recording' option
    [Documentation]    This keyword focuses and selects option 'Stop & delete recording'
    Interactive modal with options 'Stop recording' and 'Stop & delete recording' is shown
    I focus 'Stop & Delete Recording' option
    I press    OK
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SPINNER_DELETING_REC'
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_TOAST_RECORDING_DELETED'

I cancel scheduled recording from Details Page   #USED
    [Documentation]    This keyword Cancel a planned recording - booking from the details page
    ...    Precondition: Deatils page of event with planned recording is open
    I press    REC
    I cancel scheduled recording from modal popup

I cancel scheduled recording from modal popup    #USED
    [Documentation]    This keyword Cancel a planned recording - booking: single, episode or fullserie
    ...    Precondition: Modal Popup for cancelation is open
    ${SINGLE_OR_EPISODE_OR_FULLSERIE}    Determine already scheduled recording event type from modal popup
    Run Keyword If    '${SINGLE_OR_EPISODE_OR_FULLSERIE}'=='single'    I press OK on 'Cancel Recording' option for singel event in the edit modal
    Run Keyword If    '${SINGLE_OR_EPISODE_OR_FULLSERIE}'=='episode'    I press OK on 'Cancel Recording' option for episode event in the edit modal
    Run Keyword If    '${SINGLE_OR_EPISODE_OR_FULLSERIE}'=='fullserie'    I press OK on 'Cancel series recording' option for fullserie in the edit modal

I press OK on 'Cancel Recording' option for singel event in the edit modal    #USED
    [Documentation]    This keyword focuses and selects option 'Cancel recording' option in the edit recording modal
    I focus 'Cancel recording' option
    I press    OK
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SPINNER_CANCELLING_REC'
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_TOAST_RECORDING_SINGLE_CANCELLED'

I press OK on 'Cancel Recording' option for episode event in the edit modal    #USED
    [Documentation]    This keyword focuses and selects option 'Cancel recording' on the edit recording modal
    ...     Interactive modal with options 'Record complete series' and 'Cancel Recording' is shown
    I focus 'Cancel recording' option
    I press    OK
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SPINNER_CANCELLING_REC'
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_TOAST_RECORDING_SINGLE_CANCELLED'

I press OK on 'Cancel series recording' option for fullserie option in the edit modal    #USED
    [Documentation]    This keyword focuses and selects option 'Cancel series recording'
    ...    It then verifies that toast messages 'Cancelling series recording' followed by
    ...    'Series recording cancelled' appear on screen.
    I focus 'Cancel recording' option
    I press    OK
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:toast.message' contains 'textKey:DIC_SPINNER_CANCELLING_SERIES_REC'
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:toast.message' contains 'textKey:DIC_TOAST_RECORDING_SERIES_CANCELLED'

I press OK on 'Stop' option in the edit modal
    [Documentation]    This keyword focuses and selects option 'Stop recording' option in the modal
    Interactive modal with options 'Stop recording' and 'Stop & delete recording' is shown
    I focus 'Stop recording' option
    I press    OK
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SPINNER_STOPPING_REC'
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_TOAST_RECORDING_STOPPED'

Toast message 'Series recording scheduled' is shown
    [Documentation]    This keyword checks for the 'Series recording scheduled' toast message
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:toast.message' contains 'textKey:DIC_TOAST_RECORDING_SERIES_SCHEDULED'

'Now Recording' toast message is shown
    [Documentation]    This keyword checks for the 'Series now recording' toast message
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:toast.message' contains 'textKey:DIC_TOAST_NOW_RECORDING'

'This program will be saved in full in your recordings' toast message is shown    #USED
    [Documentation]    This keyword checks for the 'This program will be saved in full in your recordings' toast message
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:toast.message' contains 'textKey:DIC_TOAST_MESSAGE_STOP_NPVR'

'RECORD' option is not shown
    [Documentation]    This keyword checks the 'Record' option should not be available
    Wait Until Keyword Succeeds    10 times    200 ms    I do not expect page contains 'textKey:DIC_ACTIONS_RECORD'

'STOP RECORDING' option is shown
    [Documentation]    This keyword checks the 'Stop recording' option should be shown
    Wait Until Keyword Succeeds    10 times    200 ms    I expect page contains 'textKey:DIC_ACTIONS_STOP_RECORDING'

I press OK on 'Stop recording' action
    [Documentation]    This keyword focuses and selects the 'Stop recording' action
    I focus 'Stop recording' action
    I press    OK

I press OK on 'Stop recording' option
    [Documentation]    This keyword focuses and selects the 'Stop recording' option in the
    ...    'Stop recording' and 'Stop & delete recording' modal
    Interactive modal with options 'Stop recording' and 'Stop & delete recording' is shown
    Move Focus to Button in Interactive Modal    textKey:DIC_INTERACTIVE_MODAL_BUTTON_STOP_RECORDING    DOWN    2
    I press    OK

I press OK on 'Record' option
    [Documentation]    This keyword focuses and selects option 'Record'
    I focus 'Record' option
    I press    OK

I open the Linear Detail Page for the current event in a Single event channel
    [Documentation]    This keyword opens the LDP for current event on a single event channel
    I tune to Single event channel
    I open Linear Detail Page

Currently recording icon is shown in Guide
    [Documentation]    This keyword checks for the recording icon in guide
    Wait Until Keyword Succeeds    10 times    300 ms    I expect page contains 'textKey:DIC_RECORDING_LABEL_SINGLE_RECORDING_NOW'

I start recording an ongoing complete series from TV Guide
    [Documentation]    This keyword starts recording an ongoing complete series from TV Guide.
    ...    Pre-reqs: Already tuned to a series channel
    I open Guide through the remote button
    I press    REC
    Interactive modal with options 'Record complete series' and 'Record this Episode' is shown
    I press OK on 'Record complete series' option
    Toast message 'Series recording scheduled' is shown

Series recording icon is shown in Guide
    [Documentation]    This keyword checks for the series recording icon in guide.
    ...    Pre-reqs: Guide is shown
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:block_\\\\d+_event_\\\\d+_\\\\d+' contains 'iconKeys:RECORDING_(SCHEDULED|CURRENT)' using regular expressions

I open Recording list
    [Documentation]    This keyword opens the recordings list through Saved
    I open Recordings through Saved
    I focus recording collection
    I Press    OK
    ${action_found}    Run Keyword And Return Status   Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:RecordingList.View'
    Should Be True    ${action_found}    Unable to open Recording list

I open Saved Collection
    [Documentation]    Alternative keyword to reach the saved collection through the Main Menu
    I open Saved through Main Menu

Currently recording icon is shown in Recording list
    [Documentation]    This keyword checks for the currently recording icon in the Recording list
    Wait Until Keyword Succeeds    10 times    300 ms    I expect page element 'id:listItemIconPvr-ListItem' contains 'textValue:.*M' using regular expressions

Currently recording icon is shown in Saved collection
    [Documentation]    This keyword checks if currenty recording icon is shown on the current event in the
    ...    Recordings Section under Saved
    Currently recording icon is shown in Recordings Collection

Planned Recording is shown in Planned Recordings list
    [Documentation]    This keyword checks that we have item(s) in the Scheduled recording list
    I open Planned Recordings List through Saved

Pending recording icon is shown in Channel Bar
    [Documentation]    This keyword asserts pending recording icon is shown on the Channel Bar
    Pending recording icon is shown

I record an ongoing event    #NOT_USED
    [Documentation]    This keyword records an ongoing single event
    I tune to Single event channel
    Channel Bar is shown
    I press    OK
    Linear Details Page is shown
    I focus record button
    I press    OK
    Interactive modal is shown
    I expect page element 'id:interactiveModalButton0' contains 'textKey:DIC_NPVR_RECORD_BUTTON_SINGLE'
    I press    OK
    Interactive modal is not shown
    Wait Until Keyword Succeeds    20 times    500 ms    I expect page element 'id:recordingTextInfoprimaryMetadata' contains 'textKey:DIC_RECORDING_LABEL_SINGLE_RECORDING_NOW'

Recordings Details page is shown    #USED
    [Documentation]    This keyword verifies the Recordings Details page is shown
    Common Details Page elements are shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:recordingTextInfoprimaryMetadata' contains 'textKey:DIC_RECORDING_LABEL.*' using regular expressions

I schedule one recording
    [Documentation]    This keyword schedules one single event recording using the Channel Bar
    I tune to Single event channel
    I schedule recording next event through Channel Bar

I schedule '${recording_type}' recording using REC Button on Channel Bar    #USED
    [Documentation]    This keyword schedules event recording of a through the Channel Bar
    ...    (by default skipping 2)
    I verify that metadata is present on channel bar
    I schedule '${recording_type}' recording using REC Button
    Interactive modal is not shown

Fetch The Focused Event Title On Channel Bar    #USED
    [Documentation]    This keyword fetch a event tile of an ongoing programme through the Channel Bar
    I focus Ongoing event in Channel Bar
    Set Suite Variable    ${RECORDED_EVENT_TITLE}    ${CB_FOCUSED_EVENT_NAME}

I schedule recording next event through Channel Bar    #USED
    [Documentation]    This keyword schedules recording of the next programme through the Channel Bar
    I focus Future single event
    Set Suite Variable    ${RECORDED_EVENT_TITLE}    ${CB_FOCUSED_EVENT_NAME}
    I schedule 'future' recording using REC Button on Channel Bar

I schedule recording future event through Channel Bar    #USED
    [Documentation]    This keyword schedules recording of a future programme through the Channel Bar
    ...    (by default skipping 2)
    I focus Future Event on Channel Bar Skipping First
    Set Suite Variable    ${RECORDED_EVENT_TITLE}    ${CB_FOCUSED_EVENT_NAME}
    I schedule 'future' recording using REC Button on Channel Bar

I schedule recording ongoing event through Channel Bar    #USED
    [Documentation]    This keyword schedules recording of an ongoing programme through the Channel Bar
    I focus Ongoing event in Channel Bar
    Set Suite Variable    ${RECORDED_EVENT_TITLE}    ${CB_FOCUSED_EVENT_NAME}
    I schedule 'ongoing' recording using REC Button on Channel Bar

I open Planned Recording tile
    [Documentation]    This keyword opens a Planned Recording tile
    I focus Planned recording tile
    I press    OK

I have Recorded a single event recording
    [Documentation]    This keyword deletes all recordings, then tunes to
    ...    the single event channel and records a minute of the current event
    Reset All Recordings
    I tune to Single event channel
    Current Program title is displayed in channel bar
    ${time_to_next_event}    get time left until next event
    run keyword if    ${time_to_next_event} < ${2}    I wait for the next event
    I try to record an event
    I press OK on 'Record' option
    'Now Recording' toast message is shown
    Currently recording icon is shown
    I wait for 1 minute
    I press    REC
    Interactive modal with options 'Stop recording' and 'Stop & delete recording' is shown
    set test variable    ${SINGLE_OR_EPISODE_OR_FULLSERIE}    single
    I focus 'Stop recording' option
    I press    OK
    Toast message 'Recording Stopped' is shown

Delete recording is focused
    [Documentation]    This keyword focuses on the Delete recording button in the delete recording modal window
    ...    for a single event or an episode in a series
    variable should exist    ${SINGLE_OR_EPISODE_OR_FULLSERIE}    The type of recording has not been set. SINGLE_OR_EPISODE does not exist
    ${text_key_delete_recording}    Set Variable If    "${SINGLE_OR_EPISODE_OR_FULLSERIE}" == "episode"    DIC_INTERACTIVE_MODAL_BUTTON_DELETE_EPISODE    "${SINGLE_OR_EPISODE_OR_FULLSERIE}" == "single"    DIC_INTERACTIVE_MODAL_BUTTON_DELETE_RECORDING_YES
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:${text_key_delete_recording}'
    Move Focus to Button in Interactive Modal    textKey:${text_key_delete_recording}    UP    2

Toast message 'Recording deleted' is shown
    [Documentation]    This keyword checks for the 'Recording deleted' toast message
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:toast.message' contains 'textKey:DIC_TOAST_RECORDING_DELETED'

Toast message 'Recording Stopped' is shown
    [Documentation]    This keyword checks for the 'Recording stopped' toast message
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:toast.message' contains 'textKey:DIC_TOAST_RECORDING_STOPPED'

I focus Recorded single event recording
    [Documentation]    Press down and then check the focus underline is shown
    ...    in the recording list, the rendering of the list takes time
    ...    intitally so we wait until the item appears.
    Wait Until Keyword Succeeds    10 times    300 ms    I expect page contains 'id:recordingListItem-\\\\d' using regular expressions
    I press    DOWN
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:listItemFocusedUnderline-ListItem'

I try to record an event
    [Documentation]    This keyword verifies that metadata is present on the channel bar then presses the rec button
    I open Channel Bar
    I verify that metadata is present on channel bar
    I press    REC

I schedule one event recording    #NOT_USED
    [Arguments]    ${channel_number}=${SHORT_DURATION_EVENTS_CHANNEL}
    [Documentation]    This keyword schedules the recording of the next event on a channel with short events
    ...    By default, channel ${SHORT_DURATION_EVENTS_CHANNEL} is used as the ${channel_number} argument.
    I tune to channel '${channel_number}' using numeric keys
    I schedule recording next event through Channel Bar

I recorded/schedule an event from modal    #USED
    ${SINGLE_OR_EPISODE_OR_FULLSERIE}    Determine recording event type from modal popup
    Run Keyword If    '${SINGLE_OR_EPISODE_OR_FULLSERIE}' == 'episode'    I press OK on 'Record this episode' option
    Run Keyword If    '${SINGLE_OR_EPISODE_OR_FULLSERIE}' == 'single_ch'    I press OK on 'Record' option

I schedule '${recording_type}' recording using REC Button    #USED
    [Documentation]    This keyword records an ${recording_type} event - it can be a series episode or single event
    Run Keyword If    '${recording_type}' == 'ongoing'    I focus Ongoing event in Channel Bar
    ...    ELSE IF    '${recording_type}' == 'future'     I focus Next event in Channel Bar
    Set Suite Variable    ${RECORDED_EVENT_TITLE}    ${CB_FOCUSED_EVENT_NAME}
    Dismiss Channel Failed Error Pop Up
    I press    REC
    I recorded/schedule an event from modal
    Interactive modal is not shown
    Error popup is not shown
    Run Keyword If    '${recording_type}' == 'ongoing'    Wait Until Keyword Succeeds    16x    500ms    Currently recording icon is shown in Channel bar

I recorded an event
    [Documentation]    This keyword records a full replay event - it can be a series episode or single event
    Replay Icon Is Displayed At Right Hand Side Of The Title In Channel Bar
    I press    REC
    I recorded/schedule an event from modal
    'Now Recording' toast message is shown
    I open Recordings through Saved
    Wait Until Keyword Succeeds    20 times    1 min    I check if recording finished

I recorded an event and wait until finish
    [Documentation]    This keyword records a full replay event - it can be a series episode or single event
    Replay Icon Is Displayed At Right Hand Side Of The Title In Channel Bar
    I press    REC
    I recorded/schedule an event from modal
    'Now Recording' toast message is shown
    I open Recordings through Saved
    Wait Until Keyword Succeeds    20 times    1 min    I check if recording finished

I PLAY recording
    [Documentation]    This keyword plays a recorded event from Recordings screen
    Recordings collection screen is shown
    I focus recording collection
    Focus partially or fully recorded tile
    I press    PLAY-PAUSE

Recording starts playing    #USED
    [Documentation]    This keyword verifies if a recording starts playing
    I Prevent Recordings Player Progress Bar From Disappearing

I press REC on recording tile
    [Documentation]    This keyword presses REC on a recording tile and checks if the interactive modal appears
    Recordings collection screen is shown
    I focus recording collection
    Focus partially or fully recorded tile
    I press    REC
    Interactive modal is shown

I press OK on 'Delete recording' option
    [Documentation]    This keyword presses OK on the single event or episode Delete recording option
    ...    in the interactive modal
    variable should exist    ${SINGLE_OR_EPISODE_OR_FULLSERIE}    The type of recording has not been set. SINGLE_OR_EPISODE does not exist
    run keyword if    '${SINGLE_OR_EPISODE_OR_FULLSERIE}' == 'episode'    Interactive modal with options 'Record complete series' and 'Delete recording' is shown
    ...    ELSE IF    '${SINGLE_OR_EPISODE_OR_FULLSERIE}' == 'single'    Interactive modal with options 'Delete recording' and 'Close' is shown
    I focus 'Delete recording'
    I press    OK

'Recording deleted' toast message is shown
    [Documentation]    This keyword verifies if the 'Recording deleted' toast message is shown
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    30 ms    I expect page element 'id:toast.message' contains 'textKey:DIC_TOAST_RECORDING_.*_DELETED' using regular expressions

'Recording cancelled' toast message is shown
    [Documentation]    This keyword checks that the 'Recording Cancelled' toast message is shown
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    100ms    I expect page element 'id:toast.message' contains 'textKey:DIC_TOAST_RECORDING_.*_CANCELLED' using regular expressions

Recording tile is not shown
    [Documentation]    This keyword verifies a Recording tile is not shown
    Wait Until Keyword Succeeds    10 times    1 s    I do not expect page contains 'id:Tile_title_secondary_GridCollection_\\d+_tile_\\d+' using regular expressions

I delete recording
    [Documentation]    This keyword presses OK on the 'Delete recording' option
    I press OK on 'Delete recording' option

Recordings Collection empty screen is shown
    [Documentation]    This keyword verifies the Recordings Collection empty screen is shown
    Recordings Collection screen is shown
    Recordings Collection screen is empty

Ongoing recording tile is focused
    [Documentation]    This keyword verifies if an ongoing recording tile is focused
    Wait Until Keyword Succeeds    10 times    1 s    I expect page contains 'iconKeys:RECORDING_CURRENT' using regular expressions
    ${focused_element_id}    I retrieve value for key 'id' in focused element '${TILE_NODE_ID_PATTERN}' using regular expressions
    I expect page element 'id:${focused_element_id}' contains 'iconKeys:RECORDING_CURRENT'

Scheduled recording tile is shown
    [Documentation]    This keyword verifies if the scheduled recording tile is shown
    I press    DOWN
    Wait Until Keyword Succeeds    10 times    1 s    I expect page contains 'textValue:.*>L<.?font.*' using regular expressions

Recordings Grid entry tile is focused
    [Documentation]    This keyword verifies if the recordings grid entry tile is focused
    Wait Until Keyword Succeeds    10 times    1 s    I expect page contains 'id:grid_link_layer_2'
    ${background}    I retrieve value for key 'background' in element 'id:grid_link_layer_2'
    should be equal    ${background['color']}    ${INTERACTION_COLOUR}    Recordings Grid entry tile is not focused

I focus 'Stop recording this episode'
    [Documentation]    This keyword focuses the 'Stop recording this episode' option on the interactive modal
    Wait Until Keyword Succeeds    10 times    200 ms    I expect page contains 'textKey:DIC_INTERACTIVE_MODAL_BUTTON_STOP_RECORDING_EPISODE'
    Move Focus to Button in Interactive Modal    textKey:DIC_INTERACTIVE_MODAL_BUTTON_STOP_RECORDING_EPISODE    RIGHT    1

I press OK on 'Stop recording this episode' action
    [Documentation]    This keyword focuses and selects option 'Stop recording this episode'
    I focus 'Stop recording this episode'
    I press    OK

I have Series event recording with Ongoing and Future episodes
    [Documentation]    This keyword starts Recording a complete series and checks there are events on
    ...    the Recording collections screen
    I tune to Series event channel
    I press    REC
    I focus 'Record complete series'
    I press    OK
    set test variable    ${SINGLE_OR_EPISODE_OR_FULLSERIE}    episode
    I open Saved through Main Menu
    Recordings Collection screen is not empty

Planned recording tile is shown
    [Documentation]    This keyword verifies if there are tiles under the planned recording section
    Planned recordings collection is shown
    Wait Until Keyword Succeeds    10 times    1 s    I expect page element 'id:GridCollection_\\\\d+_tile_\\\\d+' contains 'textValue:^.*[A-Za-z0-9 ]+.*$' using regular expressions

Recorded tile is not shown
    [Documentation]    This keyword verifies a recorded tile is not shown
    Wait Until Keyword Succeeds    10 times    1 s    I do not expect page contains 'textValue:.*>O|V<.?font.*' using regular expressions

Partial recording icon in Recordings is shown
    [Documentation]    This keyword verifies if a Partial recording icon in Recordings is shown
    Wait Until Keyword Succeeds    20 sec    100 ms    Partial recording icon in Recordings is shown implementation

I have scheduled a Future Single episode recording
    [Documentation]    This keyword schedules a future episode recording from the series event channel
    I tune to Series event channel
    I focus Future Event on Channel Bar Skipping First
    I Press    REC
    I press OK on 'Record this episode' option

I focus the planned recording in Saved
    [Documentation]    This keyword focuses the planned recording item in Saved
    I open Recordings through Saved
    I focus Planned recording tile

The planned recording list contains a series recording
    [Documentation]    This keyword checks there is a planned recording marked as a series recording
    ...    in the planned recording list
    I open Planned Recordings List through Saved
    Wait Until Keyword Succeeds    10 times    1 sec    I expect page contains 'textKey:DIC_PLANNED_LIST_SERIES_GROUP'

The planned recording list contains a single episode recording
    [Documentation]    This keyword checks there is a single episode recording in the planned recording list view
    I open Planned Recordings List through Saved
    Wait Until Keyword Succeeds    10 times    1 sec    I expect page contains 'textKey:DIC_GENERIC_EPISODE_FULL.*' using regular expressions

I focus the first scheduled recording in the scheduled recording list
    [Documentation]    This keyword focuses the first Scheduled recording item in the Saved scheduled recording list
    I open Planned Recordings List through Saved
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:listItemPrimaryInfo-ListItem'
    Move Focus to Reccording Row Position    0

I focus the scheduled recording in the scheduled recording list    #USED
    [Documentation]    This keyword focuses the Scheduled recording item in the Saved scheduled recording list
    I open Planned Recordings List through Saved
    Planned Recordings List is not empty
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:listItemPrimaryInfo-ListItem'
    Move Focus to Reccording Row Position    0

I check scheduled recording done is present in Planned recordings list    #USED
    [Arguments]    ${recorded_event_title}=${RECORDED_EVENT_TITLE}
    [Documentation]    This keyword check go to the Saved scheduled recording list and check
    ...    that the actual scheduled recording is present on the Saved scheduled recording list
    ...    ${RECORDED_EVENT_TITLE} is suite var set on the recording steps based on:
    ...      CB_FOCUSED_EVENT_NAME as we focus the event on the ChannelBar
    ...      Maybe We can also use:
    ...         ${next_event_title} of "Set current lineup variables of Channel Bar" but only for next future event not jump
    I focus the scheduled recording in the scheduled recording list
#    LOG TO CONSOLE   \nrecorded_event_title:${recorded_event_title}
    Log    recorded_event_title:${recorded_event_title}
    ${recording_list_asset_details_dict}    Get Assets Details from Recording List on Planned
    Log     ${recording_list_asset_details_dict}
    ${is_title_present}    Check If '${recorded_event_title}' Is In '${recording_list_asset_details_dict}' List Of Dicts For Assets Details
    should be true    ${is_title_present}    The Schedule Recorded event is not present on the Saved - Planned recording List

I Check Scheduled Recording With Title '${recorded_event_title}' Is Present In Planned Recordings List    #USED
    [Documentation]    This keyword go to the Saved scheduled recording list and check
    ...    that the ${recorded_event_title} scheduled recording is present on the Saved scheduled recording list
    I check scheduled recording done is present in Planned recordings list      ${recorded_event_title}

I check ongoing or done recording is present in Recorded list    #USED
    [Arguments]    ${recorded_event_title}=${RECORDED_EVENT_TITLE}
    [Documentation]    This keyword check go to the Saved scheduled recording list and check
    ...    that the actual ongoing or done recording is present on the Saved recording list
    ...    ${RECORDED_EVENT_TITLE} is suite var set on the recording steps based on:
    ...      CB_FOCUSED_EVENT_NAME as we focus the event on the ChannelBar
    ...      Maybe We can also use:
    ...         ${next_event_title} of "Set current lineup variables of Channel Bar" but only for next future event not jump
    I open Recordings through Saved
    I open the Saved Recordings list from Saved with filter 'Recorded'
    Check If '${recorded_event_title}' Is Listed In Recorded List

Check If '${recorded_event_title}' Is Listed In Recorded List       #USED
    [Documentation]    This keyword checks if '${recorded_event_title}' is listed in Recorded List
    ...    prerequisite:- Saved Recordings list from Saved with filter 'Recorded' should be open
    Log    recorded_event_title:${recorded_event_title}
    ${recording_list_asset_details_dict}    Get Assets Details from Recording List on Planned
    ${total_assets}     Get Length      ${recording_list_asset_details_dict}
    Set Suite Variable      ${MAX_ACTIONS}       ${total_assets}
    ${is_title_present}    Check If '${recorded_event_title}' Is In '${recording_list_asset_details_dict}' List Of Dicts For Assets Details
    should be true    ${is_title_present}    The Recorded event '${recorded_event_title}' is not present in the Saved - Recorded List

I uncheck the Retention period checkbox in the Series recording modal
    [Documentation]    This keyword focuses and selects the 'Keep longer than' rentention checkbox to uncheck it
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:interactiveModalPopupBoxMark'
    I focus the Retention period checkbox in the Series recording modal
    I press    OK

Retention period checkbox is unchecked
    [Documentation]    This keyword asserts the 'Keep longer than' retention checkbox is not checked in the modal
    Interactive modal is shown
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'id:interactiveModalPopupBoxMark'

Retention period checkbox is shown in the recording Modal
    [Documentation]    This keyword checks if the Rentention checkbox is shown and is checked in the modal
    Interactive modal is shown
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_DAYS_RETENTION_PERIOD.*' using regular expressions
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:interactiveModalPopupBoxMark'

I have scheduled a Future complete series recording
    [Documentation]    This keyword plans a future complete series recording from the recordable series event cahnnel
    I tune to Series event channel
    I focus Future Event on Channel Bar Skipping First
    I Press    REC
    I press OK on 'Record complete series' option

I initiate a single event recording
    [Documentation]    This keyword deletes all recordings and then tunes to
    ...    the single event channel and initiates a recording
    Reset All Recordings
    I tune to Single event channel
    I try to record an event
    I press OK on 'Record' option
    'Now Recording' toast message is shown
    Currently recording icon is shown

I select to Stop and delete recording
    [Documentation]    This keyword selects the 'Stop & delete recording' option on the ongoing recording in the modal
    interactive modal with options 'Stop recording' and 'Stop & delete recording' is shown
    I press OK on 'Stop & Delete Recording' option

Recording is not shown in Saved collection
    [Documentation]    This keyword checks that no recordings are shown in the Saved Collection
    I open Saved through Main Menu
    Recordings Collection screen is empty

I invoke the Stop Recording modal
    [Documentation]    This keyword presses REC to invoke the Stop recording modal from a channel where
    ...    one single recording is currently ongoing
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Currently recording icon is shown
    I press    REC
    Wait Until Keyword Succeeds    10 times    ${JSON_RETRY_INTERVAL}    interactive modal with options 'Stop recording' and 'Stop & delete recording' is shown

I delete the planned recording through Saved
    [Documentation]    This keyword navigates through Saved then focuses and deletes a planned recording item
    I open Saved through Main Menu
    I focus Planned recording tile
    I press    REC
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Interactive modal with options 'Record complete series' and 'Cancel Recording' is shown
    I press OK on 'Cancel' option in the edit modal

I stop the ongoing recording through Saved
    [Documentation]    This keyword navigates through Saved then focuses and Stops an ongoing recording item
    I open Saved through Main Menu
    Recordings collection screen is shown
    I press    DOWN
    Focus currently recording tile
    I press    REC
    I press OK on 'Stop' option in the edit modal

I cancel the scheduled series recording through Saved
    [Documentation]    This keyword navigates through Saved and focuses and cancels a scheduled series recording
    I open Saved through Main Menu
    Recordings collection screen is shown
    I focus Planned recording tile
    I press    REC
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Interactive modal with options 'Cancel Series Recording' and 'Close' is shown
    I press OK on 'Cancel series recording' for fullserie option in the edit modal

I have recorded an event with a Default poster tile
    [Documentation]    This keyword deletes all recordings and then tunes to
    ...    channel ${DEFAULT_POSTER_TILE_EVENT_CHANNEL} and records a minute of the current event
    Reset All Recordings
    I tune to channel    ${DEFAULT_POSTER_TILE_EVENT_CHANNEL}
    I try to record an event
    I press OK on 'Record' option
    'Now Recording' toast message is shown
    Currently recording icon is shown
    I wait for 1 minute
    I press    REC
    Interactive modal with options 'Stop recording' and 'Stop & delete recording' is shown
    set test variable    ${SINGLE_OR_EPISODE_OR_FULLSERIE}    single
    I focus 'Stop recording' option
    I press    OK
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    500 ms    I expect page element 'id:toast.message' contains 'textKey:DIC_TOAST_RECORDING_STOPPED'

I focus partially watched recording tile
    [Documentation]    This keyword focuses a partially watched tile
    ...    Pre-reqs: In Saved with 'Continue watching' highlighted
    I press    DOWN
    Focus partially watched tile

I have a partially watched recording
    [Arguments]    ${channel_number}=${SINGLE_EVENT_CHANNEL_FOR_CONTEXT_PLAY}
    [Documentation]    This keyword ensures there is a partially watched recording by starting a recording
    ...    and stopping it after 1 minute.
    ...    By default, channel ${SINGLE_EVENT_CHANNEL_FOR_CONTEXT_PLAY} is used as argument ${channel_number}
    I tune to channel '${channel_number}' using numeric keys
    I try to record an event
    I press OK on 'Record' option
    'Now Recording' toast message is shown
    I wait for 40 seconds
    I stop the ongoing recording through Channel Bar
    I open Recordings through Saved
    I PLAY recording
    I focus 'Play from start'
    I press    OK
    Wait until keyword succeeds    10s    300ms    I expect page contains 'id:Player.View'
    I wait for 30 seconds
    I press    STOP
    Wait until keyword succeeds    10s    300ms    I do not expect page contains 'id:Player.View'

I cancel the recording using the Delete Icon
    [Documentation]    This keyword moves right and focuses the delete icon then selects the icon to
    ...    cancel the scheduled recording. It then verifies that the planned recording list is empty.
    ...    Pre-reqs: In the Saved planned recording list with focus on a recording
    ${ancestor}    I retrieve json ancestor of level '2' in element 'id:listItemPrimaryInfo-ListItem' for element 'color:${INTERACTION_COLOUR}'
    ${event_title}    Extract Value For Key    ${ancestor}    id:listItemPrimaryInfo-ListItem    textValue
    set test variable    ${DELETED_EVENT}    ${event_title}
    I focus the delete icon for the recording
    I press    OK
    Verify Planned Recordings List is empty

Recordings Specific Suite Setup
    [Documentation]    This keyword contains the Recordings tests Specific Suite Setup steps
    ...    All recordings are removed via AS as part of this setup
    Default Suite Setup
    Reset All Recordings

There are '${total_record_count}' recordings of any type
    [Documentation]    This keyword verifies that there are ${total_record_count} recordings of any type available.
    ${recording_count}    Get recording count
    ${planned_recording_count}    Get planned recording count
    ${total_number_of_recordings}    evaluate    ${recording_count} + ${planned_recording_count}
    should be equal    '${total_number_of_recordings}'    '${total_record_count}'    The number of available recordings is not equal to ${total_record_count}

The planned recording is deleted
    [Documentation]    This keyword verifies the planned recording is deleted
    ...    Pre-reqs: In the Saved planned recording list
    Wait Until Keyword Succeeds    10 times    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'id:listItemPrimaryInfo-ListItem'
    Wait Until Keyword Succeeds    10 times    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'textValue:${DELETED_EVENT}'

I record current adult event
    [Documentation]    This keyword records the current adult event after tuning to an Adult Locked event channel
    I tune to an Adult Locked event
    I try to record an event
    Interactive modal with options 'Record' and 'Close' is shown
    I focus 'Record' option
    I press    OK
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    1 sec    I do not expect page element 'id:toast.message' contains 'textKey:DIC_SPINNER_SCHEDULING_REC'
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    300 ms    I expect page element 'id:toast.message' contains 'textKey:DIC_TOAST_NOW_RECORDING'

I record current age rated event
    [Documentation]    This keyword records the current age rated event
    I try to record an event
    Interactive modal with options 'Record' and 'Close' is shown
    I focus 'Record' option
    I Press    OK
    'Now Recording' toast message is shown

I PLAY the currently recording event
    [Documentation]    This keyword plays the currently recording event from the Recordings collection screen
    ...    Pre-reqs: Already on the recordings collection screen
    Recordings collection screen is shown
    I focus recording collection
    Focus currently recording tile
    I press    PLAY-PAUSE

I play the currently recording event through Saved
    [Documentation]    This keyword initiates a playback of the currently recording event through Saved
    ...    without verifying it actually starts
    I open Recordings through Saved
    I PLAY the currently recording event

Age Locked Recording Pin Entry popup is shown
    [Documentation]    This keyword checks if the Pin Entry popup has the correct text for an Age rated recording
    Pin Entry popup is shown
    Default popup title is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:pinEntryModalPopupBody' contains 'textKey:DIC_PIN_BODY_AGE_LOCK_RECORDING'

Age Locked Recording Pin Entry Customer popup is shown    #USED
    [Documentation]    This keyword checks if the Pin Entry Customer popup has the correct text for an Age rated recording
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:pinEntryModalPopupBody' contains 'textKey:DIC_PIN_BODY_CUSTOMER_LOCK'

I stop the ongoing recording through Channel Bar
    [Documentation]    This keyword stops an ongoing recording on the currently tuned channel after
    ...    opening the Channel Bar
    I open Channel Bar
    Currently recording icon is shown
    I press    REC
    Interactive modal with options 'Stop recording' and 'Stop & delete recording' is shown
    I focus 'Stop recording' option
    I press    OK
    Toast message 'Recording Stopped' is shown

I have recorded an event with Operator restrictions
    [Documentation]    This keyword tunes to channel ${UNLOCKED_CHANNEL_WITH_OPERATOR_RESTRICTIONS} and
    ...    records a minute of the current event
    I tune to channel    ${UNLOCKED_CHANNEL_WITH_OPERATOR_RESTRICTIONS}
    I try to record an event
    Interactive modal with options 'Record complete series' and 'Record this Episode' is shown
    I press OK on 'Record this episode' option
    'Now Recording' toast message is shown
    I wait for 1 minute
    I stop the ongoing recording through Channel Bar

I create a partial recording of a current series event
    [Documentation]    This keyword creates a 1 minute partial recording of the current series event
    I try to record an event
    Interactive modal with options 'Record complete series' and 'Record this Episode' is shown
    I focus 'Record this episode'
    I press    OK
    Currently recording icon is shown in Channel bar
    I wait for 1 minute
    I stop the ongoing recording through Saved

'Recording scheduled' toast message is shown    #USED
    [Documentation]    This keyword verifies the 'Recording scheduled' toast message is shown
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:toast.message' contains 'textKey:DIC_TOAST_RECORDING_SINGLE_SCHEDULED' using regular expressions

Partially recorded icon is shown in Saved Recordings list
    [Documentation]    This keyword checks for a partially recorded icon in the Recording list
    ...    Pre-reqs: Already on the Saved recordings list
    Wait Until Keyword Succeeds    10 times    300 ms    I expect page element 'id:listItemIconPvr-ListItem' contains 'iconKeys:RECORDING_PARTIAL'

Partially recorded icons are shown in primary metadata
    [Documentation]    This keyword checks for partially recorded icons in primary metadata
    Wait Until Keyword Succeeds    10 times    300 ms    I expect page element 'id:SectionNavigationTagIcondetailPageList' contains 'iconKeys:RECORDING_PARTIAL'
    Wait Until Keyword Succeeds    10 times    300 ms    I expect page element 'id:recordingIconprimaryMetadata' contains 'iconKeys:RECORDING_PARTIAL'

I focus the 'Play from start' action
    [Documentation]    This keyword verifies the 'Play from start' action is shown and focuses it in
    ...    the contextual menu popup.
    ...    Precondition: A Contextual Menu popup should be open.
    'Play from start' action is shown
    Move Focus to Option in Value Picker    textKey:DIC_ACTIONS_PLAY_FROM_START    DOWN    5
    'Play from start' action is focused

I focus the delete icon for the recording       #USED
    [Documentation]    Move right and focus delete icon in the opened recordings section in Saved
    ...    Pre-reqs: The saved recording list is open and there's a recording in the list
    Move to element and assert    iconKeys:TRASHBIN    color    ${HIGHLIGHTED_OPTION_COLOUR}    3    RIGHT

I record the currently ongoing event
    [Arguments]    ${channel_number}=${SINGLE_EVENT_CHANNEL_FOR_CONTEXT_PLAY}
    [Documentation]    This keyword tunes to the ${channel_number} channel and starts a recording of the
    ...    currently (single or episode) event.
    ...    By default, channel ${SINGLE_EVENT_CHANNEL_FOR_CONTEXT_PLAY} is used as argument ${channel_number}
    I tune to channel '${channel_number}' using numeric keys
    I try to record an event
    ${single_event_present}    run keyword and return status    Interactive modal with options 'Record' and 'Close' is shown
    ${episode_event_present}    run keyword and return status    Interactive modal with options 'Record complete series' and 'Record this Episode' is shown
    Run Keyword If    ${single_event_present}    I press OK on 'Record' option
    ...    ELSE IF    ${episode_event_present}    I press OK on 'Record this episode' option
    'Now Recording' toast message is shown

Scheduled recording list is shown
    [Documentation]    This keyword verifies that Scheduled recording list is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'id:recordingList'

Planned recording list item shows all the components correctly
    [Documentation]    This keyword verifies that planned recording list item shows all the components correctly
    ...    Precondition: Scheduled recording list is shown and the ${CB_FOCUSED_EVENT_NAME} variable
    ...    must have been set before
    variable should exist    ${CB_FOCUSED_EVENT_NAME}    ${CB_FOCUSED_EVENT_NAME} has not previously been set
    ${scheduled_recording}    I retrieve value for key 'textValue' in element 'id:listItemPrimaryInfo-ListItem'
    ${scheduled_recording}    Fetch From Right    ${scheduled_recording}    :
    ${scheduled_recording}    Strip String    ${scheduled_recording}
    should be equal    ${scheduled_recording}    ${CB_FOCUSED_EVENT_NAME}    ${CB_FOCUSED_EVENT_NAME} is not available in the planned recording list
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:listItemChannelLogo-ListItem'
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:listItemDuration-ListItem'
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:listItemDate-ListItem' contains 'textKey:DIC_GENERIC_AIRING_DATE.*' using regular expressions

I initiate recording for an episode
    [Documentation]    This keyword initiates recording of an episode of a series event
    ...    Precondition: A recordable series asset needs to be focused
    I Press    REC
    Interactive modal with options 'Record complete series' and 'Record this Episode' is shown
    I focus 'Record this episode'
    I Press    OK
    'Now Recording' toast message is shown

I open Linear Detail Page for recording
    [Documentation]    This keyword opens Linear Detail page of an asset from recording screen
    ...    Precondition: Recording screen in Saved should be open
    I focus the first asset in recorded collection
    I Press    OK
    Linear Details Page is shown

Partial recording icon is shown in episode picker
    [Documentation]    This keyword verifies that the partial recording icon is shown in episode picker
    Wait Until Keyword Succeeds    10 times    1 s    I expect page element 'id:recIconepisode.*' contains 'textValue:.*O.*' using regular expressions

I tune to a series event channel in the tv guide to focus a series asset
    [Documentation]    This keyword focus a series event in tv guide
    ...    Precondition: Tv Guide should be opened
    I tune to ${RECORDABLE_SERIES_EVENT_CHANNEL} in the tv guide
    I focus current event in the tv guide

I have an ongoing adult IP recording
    [Documentation]    This keyword tunes to the adult IP channel, unlock it and records the ongoing event.
    I open Channel Bar
    I tune to Adult programme    ${ADULT_IP_CHANNEL}
    I unlock the channel
    Pin Entry popup is not shown
    Verify content unlocked
    I try to record an event
    Interactive modal with options 'Record' and 'Close' is shown
    I press OK on 'Record' option
    'Now Recording' toast message is shown

I Select A Non-Adult Recording Of Type '${recording_type}', State '${recording_state}' And Has Duration Between '${minimum_asset_duration}' and '${maximum_asset_duration}' Minutes And Recommendations '${recommendations}'    #USED
    [Documentation]    This keyword selects a recorded asset with recommendations of given type, state and duration from backend by iterating recording asset list
    ...    param : recording_type - 3 possible values : 'single'|'show'|'season'|Default value is 'Any'
    ...    param : recording_state - possible values : 'recorded'|'planned'|'failed'|'partiallyRecorded'|'ongoing'
     ${recording_asset_list}    ${number_of_actions}    Get All Relevant Recorded Asset Details Based On Filters    type=${recording_type}
    ...    recording_state=${recording_state}    minimum_asset_duration=${minimum_asset_duration}    maximum_asset_duration=${maximum_asset_duration}    isAdult=False    is_assetized=Any    recommendations=${recommendations}
    ${recording_asset_list_length}    Get Length    ${recording_asset_list}
    Should Be True      ${recording_asset_list_length}>${0}    No recording with type '${recording_type}' and state '${recording_state}' and duration '${minimum_asset_duration}' or more and Recommendations ${recommendations} Found
    ${selected_recording_asset}    Evaluate  random.choice(${recording_asset_list})  random
    Set Recording Suite Variables    ${selected_recording_asset}    ${number_of_actions}
    Should Not Be Empty    ${SELECTED_ASSET_TITLE}    Not able to retrieve the title of selected asset '${selected_recording_asset}'

Get Selected Recording Details From BO And Generate Asset Title    #USED
    [Documentation]    This Keyword gets the details of the recording asset from backend and then generates the recording title
    ...  The recording title generated is valid for Saved Recordings List
    I Get The Details Of Selected Recording
    ${asset_type}    Extract Value For Key    ${LAST_FETCHED_DETAILS_PAGE_DETAILS}    ${EMPTY}    type
    Run Keyword If    '${asset_type}' == 'single'   Generate Asset Title For Single Recording Using Recording Asset Details From BO    ${LAST_FETCHED_DETAILS_PAGE_DETAILS}

Generate Asset Title For Single Recording Using Recording Asset Details From BO   #USED
    [Documentation]    This Keyword Creates Title of the Recording asset based on the details received From the backend
    ...     the logic is in accordance with the UI logic to display recording title in Saved Recordings List.
    [Arguments]    ${recording_asset}    ${episode_title_key}=episodeTitle    ${is_recording}=True
    ${episode_title_available}    Run Keyword And Return Status    Set Variable    ${recording_asset['${episode_title_key}']}
    ${series_title_available}    Run Keyword And Return Status    Set Variable    ${recording_asset['title']}
    ${season_number_available}    Run Keyword And Return Status    Set Variable    ${recording_asset['seasonNumber']}
    ${episode_number_available}    Run Keyword And Return Status    Set Variable    ${recording_asset['episodeNumber']}
    ${show_id_available}    Run Keyword And Return Status    Set Variable    ${recording_asset['showId']}
    ${episode_title}    Extract Value For Key    ${recording_asset}    ${EMPTY}    ${episode_title_key}
    ${series_title}     Extract Value For Key    ${recording_asset}    ${EMPTY}    title
    ${season_number}    Extract Value For Key    ${recording_asset}    ${EMPTY}    seasonNumber
    ${episode_number}    Extract Value For Key    ${recording_asset}    ${EMPTY}    episodeNumber
    ${season_number_available}    Set Variable If    '${season_number}' != 'None' and ${season_number}>0 and ${season_number}<=99999    True     False
	${episode_number_available}    Set Variable If    '${episode_number}' != 'None' and ${episode_number}>0 and ${episode_number}<=99999    True     False
    ${episode_and_series_title_are_equal}    Run Keyword And Return Status    Should Be Equal As Strings    ${episode_title}    ${series_title}
    ${recording_title}     Run Keyword If       ${season_number_available} and ${series_title_available} and ${episode_number_available} and ${episode_title_available} and ${episode_and_series_title_are_equal}       Set Variable       ${series_title}${SPACE}S${season_number},${SPACE}Ep${episode_number}${SPACE}
    ...    ELSE IF   ${season_number_available} and ${series_title_available} and ${episode_number_available} and ${episode_title_available}       Set Variable       ${series_title}${SPACE}S${season_number},${SPACE}Ep${episode_number}${SPACE}-${SPACE}${episode_title}
    ...    ELSE IF   ${season_number_available} and ${series_title_available} and ${episode_number_available}    Set Variable      ${series_title}${SPACE}S${season_number},${SPACE}Ep${episode_number}
    ...    ELSE IF   ${season_number_available} and ${series_title_available} and ${episode_title_available}    Set Variable       ${series_title}${SPACE}S${season_number},${SPACE}${episode_title}
    ...    ELSE IF   ${season_number_available} and ${episode_number_available} and ${episode_title_available}    Set Variable      S${season_number},${SPACE}Ep${episode_number}${SPACE}-${SPACE}${episode_title}
    ...    ELSE IF   ${season_number_available} and ${series_title_available}   Set Variable      ${series_title}${SPACE}-${SPACE}season${SPACE}${season_number}
    ...    ELSE IF   ${season_number_available} and ${episode_number_available}   Set Variable      S${season_number},${SPACE}Ep${episode_number}
    ...    ELSE IF   ${season_number_available} and ${episode_title_available}   Set Variable      Season${SPACE}${season_number},${SPACE}${episode_title}
    ...    ELSE IF   ${season_number_available}   Set Variable      Season${SPACE}${season_number}
    ...    ELSE IF   ${episode_number_available} and ${series_title_available} and ${episode_title_available}    Set Variable      ${series_title},${SPACE}Ep${episode_number}${SPACE}-${SPACE}${episode_title}
    ...    ELSE IF   ${episode_number_available} and ${series_title_available}    Set Variable      ${series_title},${SPACE}Ep${episode_number}${SPACE}
    ...    ELSE IF   ${episode_number_available} and ${episode_title_available}    Set Variable      Ep${episode_number}${SPACE}-${SPACE}${episode_title}
    ...    ELSE IF   ${episode_number_available}    Set Variable      Ep${episode_number}
    ...    ELSE IF   ${series_title_available} and ${episode_title_available} and ${is_recording} and ${show_id_available}    Set Variable    ${series_title}
    ...    ELSE IF   ${series_title_available} and ${episode_title_available}    Set Variable      ${series_title},${SPACE}${episode_title}
    ...    ELSE IF   ${episode_title_available}    Set Variable      ${episode_title}
    ...    ELSE      Set Variable      ${series_title}
    Log     ${recording_title}
    Set Suite Variable    ${SELECTED_ASSET_TITLE}    ${recording_title}

Set Recording Suite Variables       #USED
    [Arguments]    ${selected_recording_asset}    ${number_of_actions}
    [Documentation]    This Keyword sets suite variables for the recording ID, title and maximum navigation
    ...   Keyword "Get Random Recorded Asset Details Based On Filters" should be called to select a random recording
    ...   asset and also total number of recording assets
    ${number_of_actions}    Evaluate    ${number_of_actions} + 10
    Set Suite Variable    ${MAX_ACTIONS}    ${number_of_actions}
    Run Keyword If    '${selected_recording_asset['type']}' != 'single'    Set Suite Variable    ${SELECTED_SERIES_ID}    ${selected_recording_asset['id']}
    ${selected_recording_asset_id}    Set Variable If    '${selected_recording_asset['type']}' == 'single'    ${selected_recording_asset['id']}    ${selected_recording_asset['mostRelevantEpisode']['episodeId']}
    Set Suite Variable    ${SELECTED_ASSET_ID}    ${selected_recording_asset_id}
    Set Suite Variable    ${SELECTED_ASSET_DETAILS}    ${selected_recording_asset}
    ${selected_recording_asset_state}    Set Variable If    '${selected_recording_asset['type']}' == 'single'    ${selected_recording_asset['recordingState']}    ${selected_recording_asset['mostRelevantEpisode']['recordingState']}
    Set Suite Variable    ${SELECTED_ASSET_RECORDING_STATE}    ${selected_recording_asset_state}
    Run Keyword If    '${selected_recording_asset['type']}' == 'single'    Generate Asset Title For Single Recording Using Recording Asset Details From BO    ${SELECTED_ASSET_DETAILS}
    ...    ELSE    Set Suite Variable    ${SELECTED_ASSET_TITLE}    ${selected_recording_asset['title']}

I Pick A Non-Adult Recorded DVRAS Asset Of Duration '${minimum_asset_duration}' Minutes OR More From BO    #USED
    [Documentation]    This Keyword selects a  Non Adult  DVRAS asset with a minimum duration
    ${selected_recording_asset}    ${number_of_actions}    Get Random Recorded Asset Details Based On Filters    type=Any
    ...    recording_state=recorded    minimum_asset_duration=${minimum_asset_duration}    isAdult=False    is_assetized=True
    Set Recording Suite Variables    ${selected_recording_asset}    ${number_of_actions}
    Should Not Be Empty    ${SELECTED_ASSET_TITLE}    No Relevent Non-Adult Single Recorded DVRAS Asset Of Duration '${minimum_asset_duration}' Minutes OR More Found

I Pick A Non-Adult Recorded DVRRB Asset Of Duration '${minimum_asset_duration}' Minutes OR More From BO    #USED
    [Documentation]    This Keyword selects a Non Adult DVRRB asset with a minimum duration
    ${selected_recording_asset}    ${number_of_actions}    Get Random Recorded Asset Details Based On Filters    type=Any
    ...    recording_state=recorded    minimum_asset_duration=${minimum_asset_duration}    isAdult=False    is_assetized=False
    Set Recording Suite Variables    ${selected_recording_asset}    ${number_of_actions}
    Should Not Be Empty    ${SELECTED_ASSET_TITLE}    No Relevent Non-Adult Single Recorded DVRRB Asset Of Duration '${minimum_asset_duration}' Minutes OR More Found

I Navigate '${MAX_ACTIONS}' To A Single Recorded Asset With '${asset_title}' Title And Open Detail Page    #USED
    [Documentation]    This Keword is Used for navigation on the single recorded asset and open the
    ...    detail page
    Navigate To Row In Specific Section Of Recordings With Given Title    'Recorded'    ${asset_title}    ${MAX_ACTIONS}
    I Open Detail Page

I PLAY Recording From Detail Page    #USED
    [Documentation]    This Keyword Starts And Validates Recordings playout from detail page
    Details Page Header is shown
    Play Any Asset From Detail Page
    Recording starts playing

Recording Label Is Shown In Recording Details Page    #USED
    [Documentation]    This keyword checks if the Recording Label is shown on the Recording Details Page
    ${action_found}    Run Keyword If    '${SELECTED_ASSET_DETAILS['type']}' != 'single'    Run Keyword And Return Status   Wait Until Keyword Succeeds    20 times    300 ms    I expect page element 'id:recordingTextInfoprimaryMetadata' contains 'textKey:DIC_RECORDING_LABEL_SERIES_RECORDING' using regular expressions
    ...    ELSE IF    '${SELECTED_ASSET_RECORDING_STATE}' == 'recorded'    Run Keyword And Return Status   Wait Until Keyword Succeeds    20 times    300 ms    I expect page element 'id:recordingTextInfoprimaryMetadata' contains 'textKey:DIC_RECORDING_LABEL_RECORDED' using regular expressions
    ...    ELSE IF    '${SELECTED_ASSET_RECORDING_STATE}' == 'ongoing'    Run Keyword And Return Status   Wait Until Keyword Succeeds    20 times    300 ms    I expect page element 'id:recordingTextInfoprimaryMetadata' contains 'textKey:DIC_RECORDING_LABEL_SINGLE_RECORDING_NOW' using regular expressions
    ...    ELSE IF    '${SELECTED_ASSET_RECORDING_STATE}' == 'partiallyRecorded'    Run Keyword And Return Status   Wait Until Keyword Succeeds    20 times    300 ms    I expect page element 'id:recordingTextInfoprimaryMetadata' contains 'textKey:DIC_RECORDING_LABEL_PARTIAL_RECORDED' using regular expressions
    ...    ELSE IF    '${SELECTED_ASSET_RECORDING_STATE}' == 'failed'    Run Keyword And Return Status   Wait Until Keyword Succeeds    20 times    300 ms    I expect page element 'id:recordingTextInfoprimaryMetadata' contains 'textKey:DIC_RECORDING_LABEL_FAILED_RECORDING' using regular expressions
    Should Be True    ${action_found}    "${SELECTED_ASSET_RECORDING_STATE}" label is not shown for the recording "${SELECTED_ASSET_TITLE}"

Recorded Icon Is Shown In Recording Details Page    #USED
    [Documentation]    This keyword checks if the Recorded/Partially Recorded Icon is shown on the Recording Details Page
    Wait Until Keyword Succeeds And Verify Status    5 times    300ms    Recorded Icon is not displayed in Details Page    I expect page contains 'id:recordingIconprimaryMetadata'

I Get The Details Of Selected Recording     #USED
    [Documentation]    This keyword gets the details of the selected recording
    ${selected_recording_details}    Get Details Of Single Recording     ${SELECTED_ASSET_ID}
    Set Suite Variable      ${LAST_FETCHED_DETAILS_PAGE_DETAILS}     ${selected_recording_details}
    Log     ${LAST_FETCHED_DETAILS_PAGE_DETAILS}
    ${channel_number}    get channel lcn for channel id    ${LAST_FETCHED_DETAILS_PAGE_DETAILS["channelId"]}
    Set Suite Variable    ${CHANNEL_NUMBER}    ${channel_number}

Validate Recording Details Page    #USED
    [Documentation]    This keyword verifies the Details Page of Recordings.
    Linear Details Page is shown
    I Validate Title Shown In Details Page
    Genre and Subgenre are shown in Primary metadata
    I Validate Synopsis Shown In 'Recording' Details Page
    Duration is shown in Primary metadata
    I Validate Year Of Production Shown In Details Page
    Poster Is Shown In DetailPage
    Recorded Icon Is Shown In Recording Details Page

I Prevent Recordings Player Progress Bar From Disappearing    #USED
    [Documentation]    This keyword prevents the progress bar to disappear in a VOD player
    ${json_object}    Get Ui Json
    ${is_player_present}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_HEADER_SOURCE_RECORDINGS
    Run Keyword If    '${is_player_present}' != 'True'    I Press    OK
    ...    ELSE    LOG    "Recordings player progress bar is shown"

I Play Recording From Detail Page For '${interval}' Seconds    #USED
    [Documentation]    This Keyword Starts And Validates Recordings playout from detail page for a fixed duration
    ...    embedded param : interval : Duration given for recording playout
    Details Page Header is shown
    Play Any Asset From Detail Page
    Recording starts playing
    I wait for ${interval} seconds
    Error popup is not shown

Validate And Play Locked Recording From DetailPage    #USED
    [Documentation]    This Keyword Validates Locked Recording Detailpage and playback of a locked channel recording
    ...    Precondition : Detailpae should be opened.
    Linear Details Page is shown
    I expect page contains 'iconKeys:LOCK'
    I Press    OK
    ${action_found}    Run Keyword And Return Status   Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:pinEntryModalPopupBody' contains 'textKey:DIC_PIN_BODY_CUSTOMER_LOCK'
    Run Keyword If    ${action_found}    I Enter A Valid Pin
    ${continue_watching_present}    Run Keyword And Return Status    'Continue Watching' popup is shown
    ${is_play_from_start_shown}    Run Keyword And Return Status    'PLAY FROM START' action is shown
    Run Keyword If    ${continue_watching_present} and ${is_play_from_start_shown}    I select the 'PLAY FROM START' action
    ${pin_popup_found}    Run Keyword If     not ${action_found}    Run Keyword And Return Status   Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:pinEntryModalPopupBody' contains 'textKey:DIC_PIN_BODY_CUSTOMER_LOCK'
    Run Keyword If    ${pin_popup_found}    I Enter A Valid Pin
    Should Be True    ${action_found} or ${pin_popup_found}    Pin Popup is not displayed
    Recording starts playing
    I wait for 30 seconds
    Error popup is not shown
    I Exit Playback And Return To Detail Page

I Navigate '${MAX_ACTIONS}' To A Single Recorded Asset With '${SELECTED_ASSET_TITLE}' Title    #USED
    [Documentation]    This Keyword navigates to a recording with given title in given max_actions attempts
    Navigate To Row In Specific Section Of Recordings With Given Title    'Recorded'    ${SELECTED_ASSET_TITLE}    ${MAX_ACTIONS}

I Select Age Rated Recording With Age Rating '${Age_Rating}' Or Less '${Less}'    #USED
    [Documentation]    This Keyword selects a Single and Non Adult  asset with a minimum duration
    ${current_country_code}     Convert To Uppercase    ${COUNTRY}
    ${Age_Rating}    Set Variable If    '${current_country_code}'=='GB'    ${18}    ${Age_Rating}
    ${Less}    Set Variable If    '${current_country_code}'=='GB'    ${True}    ${Less}
    ${selected_recording_asset}    ${number_of_actions}    Get Random Recording With Age Rating '${Age_Rating}' And '${Less}'
    @{date_and_time}    Split String    ${selected_recording_asset['startTime']}    T
    @{time_and_timezone}    Split String    ${date_and_time[1]}    .
    Run Keyword If    '${current_country_code}'=='GB'    Assess Appearance Of Age Lock And Pin Entry Popup According To Watershed Implementation    Recording    ${selected_recording_asset['channelId']}
    ...    ${time_and_timezone[0]}    ${selected_recording_asset['minimumAge']}
    Log    ${selected_recording_asset}
    Set Recording Suite Variables    ${selected_recording_asset}    ${number_of_actions}
    ${status}    Run Keyword And Return Status    Set Suite Variable    ${SELECTED_ASSET_TITLE}    ${selected_recording_asset['episodeTitle']}
    ${SELECTED_ASSET_TITLE}    Set Variable If    ${status} == False    ${selected_recording_asset['title']}    ${SELECTED_ASSET_TITLE}
    Set Suite Variable    ${SELECTED_ASSET_TITLE}    ${SELECTED_ASSET_TITLE}
    Should Not Be Empty    ${SELECTED_ASSET_TITLE}    No Age Rated Recording Found
    ${number_of_actions}    Evaluate    ${number_of_actions} + 10
    Set Suite Variable    ${MAX_ACTIONS}    ${number_of_actions}
    Set Suite Variable    ${SELECTED_ASSET_ID}    ${selected_recording_asset['id']}
    Set Suite Variable    ${SELECTED_ASSET_RECORDING_STATE}    ${selected_recording_asset['recordingState']}

Validate Age Rating On Recording DetailPage    #USED
    [Documentation]    This Keyword Validates Age Rating On Recording Detailpage
    ${no_age_rating_displayed}    Run Keyword And Return Status    Variable Should Exist    ${IS_WATERSHED_COMPLIANT}
    ${asset_age_rating}    Extract value for key    ${LAST_FETCHED_DETAILS_PAGE_DETAILS}    ${EMPTY}    minimumAge
    Set Suite Variable    ${ASSET_AGE_RATING}    ${asset_age_rating}    
    Run Keyword If    not ${no_age_rating_displayed}    I expect page element 'id:ageRatingIconprimaryMetadata' contains 'iconKeys:PARENTAL_RATING_${asset_age_rating}'
    ...    ELSE    I do not expect page element 'id:ageRatingIconprimaryMetadata' contains 'iconKeys:PARENTAL_RATING_${asset_age_rating}'

I Set Bookmark On A Random Recording      #USED
    [Documentation]    This keyword selects a random recording and sets a bookmark on it at half of is duration.
    I Select A Non-Adult Recording Of Type 'Any', State 'Any' And Has Duration Between 'Any' and 'Any' Minutes And Recommendations 'Any'
    I Set Bookmark On Recording '${SELECTED_ASSET_ID}' at Percentage '50'

Filter Channels Based On Remaining Time Of The Program    #USED
    [Documentation]  The keyword filter channels based on remaining time and return a channel number
    [Arguments]    ${replay_channels}    ${remaining_time_limit}=Any
    ${filtered_channel_ids}    I Filter All Channels Based On Remaining Time Of Current Event    ${replay_channels}    ${remaining_time_limit}
    Should Not Be Empty    ${filtered_channel_ids}    Unable to get a channel with an ongoing event that has remaining time greater than ${remaining_time_limit} minutes
    ${filtered_channel_numbers}    Get channel numbers list from Linear Service    ${filtered_channel_ids}
    ${replay_channel_number}    Get Random Element From Array    ${filtered_channel_numbers}
    [Return]    ${replay_channel_number}

I Filter All Channels Based On Remaining Time Of Current Event    #USED
    [Documentation]  This keyword filters all channel based on remaining time and return the channel id list
    [Arguments]    ${channels}    ${remaining_time_limit}=Any
    ${current_epoch_time}    Get Current Epoch Time
    ${filtered_channel_ids}    Create List
    :FOR  ${channel_id}  IN    @{channels}
    \    @{current_event}    Get current channel event via as    ${channel_id}
    \    Continue For Loop If    len(${current_event}) == 0
    \    ${epoch_event_end_time}    robot.libraries.DateTime.Convert Date    @{current_event}[2]    epoch
    \    ${time_remaining}    Evaluate    ${epoch_event_end_time} - ${current_epoch_time}
    \    ${time_remaining_in_mins}    Evaluate    ${time_remaining} / 60
    \    Run Keyword If    ${time_remaining_in_mins} > ${remaining_time_limit}    Append To List     ${filtered_channel_ids}       ${channel_id}
    [Return]     ${filtered_channel_ids}

I Tune To A Random Replay Channel Without Ongoing Recording And Minimum Remaining Time '${remaining_time_limit}'     #USED
    [Documentation]  The keyword tune to a random replay channel without ongoing recording and minimum remaining time.
    ${replay_channels}    I Fetch All Replay Channels From Linear Service
    ${recording_event_ids}    Get List of Event Ids Of All Recordings From BO
    ${filtered_channel_ids}    I Filter All Channels Based On Remaining Time Of Current Event    ${replay_channels}    ${remaining_time_limit}
    Should Not Be Empty    ${filtered_channel_ids}    Unable to get a channel with an ongoing event that has remaining time greater than ${remaining_time_limit} minutes
    ${channel_list}    Create List
    : FOR    ${channel_id}    IN     @{filtered_channel_ids}
    \    ${timestamp}    Get Current Time In Epoch
    \    @{event_info}    Get Current Event Via As    ${STB_IP}    ${CPE_ID}    ${channel_id}    ${timestamp}    xap=${XAP}
    \    ${status}     Run Keyword And Return status    List Should Not Contain Value    ${recording_event_ids}    ${event_info[0]}
    \    Continue For Loop If    not ${status}
    \    Append To List    ${channel_list}    ${channel_id}
    Should Not Be Empty    ${channel_list}     No channels with current event not as recording present
    ${channel_id}    Get Random Element From Array    ${channel_list}
    ${channel_number}    Get Channel Number By Id    ${CITY_ID}    ${channel_id}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    I tune to channel    ${channel_number}

PVR Specific Suite Setup        #USED
    [Documentation]  The keyword is for PVR suite setup. To manage the recording quota availability before starting tests
    Default Suite Setup
    Run Keyword And Ignore Error    Delete Oldest Recordings If The Quota Exceeds '70' Percentage And Set Quota To '50' Percentage

I Open Details Page Of Selected Recording       #USED
    [Documentation]  The keyword checks if selected recording is series or single. If single it will navigate to its details page.
    ...    If series, it will navigate to the details page of the most relevant episode
    ...    Prerequisite :-  Suite Variables ${MAX_ACTIONS}, ${SELECTED_ASSET_DETAILS} and ${SELECTED_ASSET_TITLE} should be set.
    Run Keyword If    '${SELECTED_ASSET_DETAILS['type']}' == 'single'    I Navigate '${MAX_ACTIONS}' To A Single Recorded Asset With '${SELECTED_ASSET_TITLE}' Title And Open Detail Page
    ...    ELSE    I Navigate '${MAX_ACTIONS}' To A Series Recorded Asset With '${SELECTED_ASSET_TITLE}' Title And Open Detail Page Of Most Relevant Episode

I Navigate '${MAX_ACTIONS}' To A Series Recorded Asset With '${SELECTED_ASSET_TITLE}' Title And Open Detail Page Of Most Relevant Episode       #USED
    [Documentation]  The keyword navigates to the specified series recording and Opens the details Page Of the selected recording
    I Navigate '${MAX_ACTIONS}' To A Single Recorded Asset With '${SELECTED_ASSET_TITLE}' Title
    I Press    OK
    ${episode_picker_displayed}    Run Keyword And Return Status    Wait Until Keyword Succeeds    20 times    300 ms    Episode picker is shown
    Should Be True    ${episode_picker_displayed}    'Episode Picker is not displayed on 'OK' press on series recording with title '${SELECTED_ASSET_TITLE}'
    I Open Detail Page

I Focus 'Delete all & cancel future recordings' Option      #USED
    [Documentation]    This keyword puts focus on the 'Delete all & cancel future recordings' button in the modal popup window
    ...    Prerequisite:- Interactive modal with option 'Delete all & cancel future recordings' should be displayed
    Interactive modal is shown
    Wait Until Keyword Succeeds And Verify Status     ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}   The Interactive Modal Popup Displayed Doesnot Have Action 'Delete all & cancel future recordings'   I expect page contains 'textKey:DIC_INTERACTIVE_MODAL_BUTTON_DELETE_CANCEL_RECORDING_SERIES'
    Move Focus to Button in Interactive Modal    textKey:DIC_INTERACTIVE_MODAL_BUTTON_DELETE_CANCEL_RECORDING_SERIES    DOWN    4

I Press OK On 'Delete all & cancel future recordings' Option      #USED
    [Documentation]    This keyword focuses and selects option 'Delete all & cancel future recordings' from interactive model popup
    ...    Prerequisite:- Interactive modal with option 'Delete all & cancel future recordings' should be displayed
    I Focus 'Delete all & cancel future recordings' Option
    I press    OK
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:toast.message' contains 'textKey:DIC_TOAST_RECORDING_SERIES_CANCEL_AND_DELETED'
    Wait Until Keyword Succeeds And Verify Status     ${TOAST_MSG_MAX_WAIT_TIME}    ${JSON_RETRY_INTERVAL}   Unable to identify toast message 'Series Recording deleted'     I expect page element 'id:toast.message' contains 'textKey:DIC_TOAST_RECORDING_SERIES_CANCEL_AND_DELETED'

Delete Selected Series Recordings Including Planned From Recordings List Page      #USED
    [Documentation]  The keyword deletes the full series recording including future planned episodes of the series
    ...    Prerequisite:- Required Series should be selected in Recordings List.
    Wait Until Keyword Succeeds And Verify Status     ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}   Recordings List Page is not displayed after deleting series recording    I expect page contains 'textKey:DIC_HEADER_TITLE_RECORDINGS'
    I focus the delete icon for the recording
    I press    OK
    I Press OK On 'Delete all & cancel future recordings' Option
    Interactive modal is not shown
    Wait Until Keyword Succeeds And Verify Status     ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}   Recordings List Page is not displayed after deleting series recording    I expect page contains 'textKey:DIC_HEADER_TITLE_RECORDINGS'

Check '${selected_title}' Is Not Displayed In Recordings List Page      #USED
    [Documentation]  The keyword checks that the Given recording is not displayed in Recordings List Page
    ...    Prerequisite:- Recordings List should be open.
    ${recording_found}   Run Keyword And Return Status    Check If '${selected_title}' Is Listed In Recorded List
    Should Be True    not ${recording_found}    The Recording '${selected_title}' is Still Displayed in Recordings List Page

I Select An Adult Recording Asset    #USED
    [Documentation]    This Keyword Gets An Adult Reccording Asset From BO 
    ...    And Sets Suite Variable '${SELECTED_ASSET_TITLE}'
    ${selected_recording_asset}    ${number_of_actions}    Get Random Recorded Asset Details Based On Filters    type=Any
    ...    recording_state=recorded    minimum_asset_duration=${minimum_asset_duration}    isAdult=True    is_assetized=Any
    Set Recording Suite Variables    ${selected_recording_asset}    ${number_of_actions}
    Should Not Be Empty    ${SELECTED_ASSET_TITLE}    No Relevent Non-Adult Single Recorded DVRRB Asset Of Duration '${minimum_asset_duration}' Minutes OR More Found

Navigate To A Planned '${event_type}' Recording From Main Menu    #USED
    [Documentation]    This keywords selects a '${event_type}' planned recording and navigate to that event in recordings page
    ${recording_details}    ${MAX_ACTIONS}    I Select A Planned '${event_type}' Recording From BO
    Set Suite Variable     ${PLANNED_RECORDING_DETAILS}    ${recording_details}
    Navigate To Row In Specific Section Of Recordings With Given Title    'planned'    ${PLANNED_RECORDING_DETAILS['title']}    ${MAX_ACTIONS}

Delete The Focused Series Recording From Planned Recording List    #USED
    [Documentation]    This keyword deletes the entire series from planned recordings list
    ...    Precondition: Required Series should be selected in Recordings List.
    I focus the delete icon for the recording
    I Press    OK
    Interactive modal is shown
    I focus 'Cancel series recording'
    I Press    OK
    Interactive modal is not shown
    Wait Until Keyword Succeeds And Verify Status     ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}   Recordings List Page is not displayed after deleting series recording    I expect page contains 'textKey:DIC_HEADER_TITLE_RECORDINGS'

Get Most Relevant Episode Of Series    #USED
    [Arguments]    ${show_crid}    ${channelId}    ${source}=recording
    [Documentation]    This Keyword returns the most relevant episode of specified series with respect to source(planned/recording).
    ...   param source:   can take values Recording/Booking
    ...   param show_crid:   recording show/season crid
    ${episode_list}    Get All Episodes Of Show    ${show_crid}    ${channelId}    ${source}
    ${total_episodes}    Get Length     ${episode_list}
    ${mre_found}    Set Variable    False
    :FOR    ${INDEX}    IN RANGE    ${episode_list['total']}
    \    ${asset}    Set Variable    ${episode_list['data'][${INDEX}]}
    \    ${mre_found}     Set Variable    ${asset['mostRelevant']}
    \    Exit For Loop If    ${mre_found}
    Should Be True    ${mre_found}    'Unable to find the Most Relevant Episode Of series with crid '${show_crid}''
    [Return]    ${asset}

I Reboot Stb And Check If Recording Is Still Ongoing    #USED
    [Documentation]     This reboots the STB and checks if the recording is still ongoing
    Reboot CPE
    Get Power State of CPE
    Should Be Equal    ${power_state}    Operational    Unable to reboot the CPE
    Channel Bar Zapping Channel Down
    I open Recordings through Saved
    I open the Saved Recordings list from Saved with filter 'Recorded'
    I Navigate '5' To A Single Recorded Asset With '${RECORDED_EVENT_TITLE}' Title And Open Detail Page
    ${is_ongoing}    Run Keyword And Return Status   Wait Until Keyword Succeeds    10 times    300 ms    I expect page element 'id:recordingTextInfoprimaryMetadata' contains 'textKey:DIC_RECORDING_LABEL_SINGLE_RECORDING_NOW' using regular expressions
    Should Be True    ${is_ongoing}    CPE failed to start the recording of the ongoing event
#******************************CPE PERFORMANCE*********************************************
Recording Scheduled toast message is shown(LDVR)
    [Documentation]    This keyword checks for the 'This program will be saved in full in your recordings' toast message
    ${json_object}    Get Ui Json
    ${result}    Is In Json    ${json_object}    id:toast.message    textKey:DIC_TOAST_NOW_RECORDING
    should be true    ${result}

Recording Scheduled toast message is shown(NDVR)
    [Documentation]    This keyword checks for the 'This program will be saved in full in your recordings' toast message
    ${json_object}    Get Ui Json
    ${result}    Is In Json    ${json_object}    id:toast.message    textKey:DIC_TOAST_MESSAGE_STOP_NPVR|DIC_TOAST_RECORDING_RECORDED    ${EMPTY}    ${TRUE}
    should be true    ${result}

Recording Deleted toast message is shown
    [Documentation]    This keyword checks for the 'Recording Deleted' toast message for single event
    ${json_object}    Get Ui Json
    ${result}    Is In Json    ${json_object}    id:toast.message    textKey:DIC_TOAST_RECORDING_DELETED
    should be true    ${result}

Episode Recording Deleted toast message is shown
    [Documentation]    This keyword checks for the 'Recording Deleted' toast message for episode
    ${json_object}    Get Ui Json
    ${result}    Is In Json    ${json_object}    id:toast.message    textKey:DIC_TOAST_RECORDING_EPISODE_DELETED
    should be true    ${result}

Recording List screen is Displayed
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    I expect page contains 'id:RecordingList.View'