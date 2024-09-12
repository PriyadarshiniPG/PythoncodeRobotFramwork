*** Settings ***
Documentation     Keywords concerning Parental Controls functions, exclusive of the behavior of locked channels
Resource          ../PA-09_Parental_Control/ParentalControl_Implementation.robot

*** Keywords ***
I unlock the channel
    [Documentation]    Unlock a channel - Performs Press ok, enter valid pin
    I Press    OK
    I enter a valid pin

I unlock the age rated channel
    [Documentation]    This keyword will unlock an age rated channel by entering valid pin after selecting
    ...    Watch Live TV in linear details page.
    ...    Precondition: An age rated channel should be tuned.
    I Press    OK
    I select 'Watch live TV'
    pin entry popup is shown
    I enter a valid pin

I set age rating of the STB to
    [Arguments]    ${age}
    [Documentation]    This keyword sets an age rating in stb
    ...    Gets and Sets the age of the box through UI
    ${age}    convert to lowercase    ${age}
    set suite variable    ${age_navigation_id}    DIC_GENERIC_TOGGLE_BTN_OFF
    ${tmp}    catenate    SEPARATOR=    DIC_AGE_    ${age}
    run keyword if    '${age}' != 'off'    set suite variable    ${age_navigation_id}    ${tmp}
    Log    ${age_navigation_id}
    ${current_age}    Get current age rating
    ${current_age}    convert to lowercase    ${current_age}
    Run keyword unless    '${age}' == '${current_age}'    run keywords    I select to enter a valid pin    I set to ${age} in SetAgeLock window from ${current_age}
    ${json_object}    Get Ui Json
    repeat keyword    3 times    Press Key    MENU
    wait until keyword succeeds    10 times    1s    Assert json changed    ${json_object}

Content unlocked
    [Documentation]    This keyword checks that the video/audio is playing
    content available

I verify that metadata is present on channel bar    #USED
    [Documentation]    Read json and check metadata is present on channel bar
    ...    Is checking that the channel bar does not contain "No info available" message
    ${json_object}    Get Ui Json
    ${is_in}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_DETAIL_EVENT_NO_INFO
    should not be true    ${is_in}    Meta data is not present on channel bar

channel is unlocked    #USED
    [Documentation]    This keyword checks whether the current channel is unlocked from a locked state
    content unlocked
    I open Channel Bar
    Get metadata from channel bar
    Unlock Icon is shown
    Metadata is unlocked

channel is ${locktype} locked
    [Documentation]    This keyword checks whether the channel is ault/user/operator/parental locked
    ${status}    Run Keyword And Return Status    content unavailable
    Run Keyword If    '${status}' == '${False}' and '${ignore_content_check_failures}' != '${True}'    Fail    Failed to check if the Content is locked
    Lock Icon present
    Get metadata from channel bar
    Run Keyword If    '${locktype}' == 'parental'    Metadata is parental locked
    Run Keyword If    '${locktype}' == 'operator'    Metadata is operator locked
    Run Keyword If    '${locktype}' == 'adult'    Metadata is adult locked
    Run Keyword If    '${locktype}' == 'user'    Metadata is user locked

I tune to channel with AR ${age}
    [Documentation]    This keyword tunes to channel with a specific age rating, Parameter : age
    ${channelnumber}    lookup channel for age ${age}
    log    ${channelnumber}
    tune to channel ${channelnumber}

I tune to channel with increasing AR events
    [Documentation]    This keyword tunes to channel with increasing age rating events
    tune to channel ${AR_UP_CHANNEL}

channel remains unlocked for ${time} minutes
    [Documentation]    This keyword checks that the channel is unlocked for a defined time
    channel is unlocked
    wait for ${time} minutes
    channel is unlocked

I tune to an adult channel
    [Documentation]    This keyword tunes to adult series channel defined in suite variable ${ADULT_CHANNEL}
    I open Channel Bar
    tune to channel ${ADULT_CHANNEL}

I tune to series adult channel
    [Documentation]    This keyword tunes to adult series channel defined in suite variable ${ADULT_SERIES_CHANNEL}
    tune to channel ${ADULT_SERIES_CHANNEL}

I tune to alternative parental channel
    [Documentation]    This keyword tunes to alternative parental channel
    tune to channel ${PARENTAL_CHANNEL_ALTERNATIVE}

I tune to a free channel
    [Documentation]    Tune to free channel - LCN defined in variable ${FREE_CHANNEL}
    tune to channel ${FREE_CHANNEL}

I wait for event of age ${age} on ${channel_number}
    [Documentation]    This keyword waits for a particular age event in lcn
    # wait till the current event ends
    ${channel_id}    Get channel ID using channel number    ${channel_number}
    ${remaining_time}    get event remaining duration    ${channel_id}    ${CPE_ID}
    I wait for ${remaining_time + 5} seconds
    # check up to 3 future events for age rated event
    : FOR    ${_}    IN RANGE    ${3}
    \    ${event_age}    get agerating from traxis    ${channel_id}    ${CPE_ID}
    \    ${is_age_equal_to_expected}    evaluate    ${event_age} == ${age}
    \    Exit For Loop If    ${is_age_equal_to_expected} == ${True}
    \    ${remaining_time}    get event remaining duration    ${channel_id}    ${CPE_ID}
    \    I wait for ${remaining_time + 5} seconds
    Should Be True    ${is_age_equal_to_expected}    Failed to wait for event of age ${age} on channel ${channel_number}

I wait for non parental event in a channel with alternative parental events
    [Documentation]    This keyword waits for a free parental event on lcn 775
    # ParentalChannelAlternative is lcn 775 with alternative 0-16-0-0
    # wait till the current event ends
    ${channel_id}    Get channel ID using channel number    ${PARENTAL_CHANNEL_ALTERNATIVE}
    ${remaining_time}    get event remaining duration    ${channel_id}    ${CPE_ID}
    I wait for ${remaining_time + 5} seconds
    # check up to 3 future events for non parental event
    : FOR    ${_}    IN RANGE    ${3}
    \    ${is_age_rated}    is age rated event from traxis    ${channel_id}    ${CPE_ID}
    \    Exit For Loop If    ${is_age_rated} == ${False}
    \    ${remaining_time}    get event remaining duration    ${channel_id}    ${CPE_ID}
    \    I wait for ${remaining_time + 5} seconds
    Should Not Be True    ${is_age_rated}    Failed to wait for the next non parental event on channel ${PARENTAL_CHANNEL_ALTERNATIVE}

I wait for locked parental event in a channel with alternative parental events
    [Documentation]    This keyword waits for a locked parental event based on age of STB on Parental Alternative Channel
    ${age}    Get current age rating via AS
    ${max_age}    Get maximum age of the STB via AS
    # wait till the current event ends
    ${channel_id}    Get channel ID using channel number    ${PARENTAL_CHANNEL_ALTERNATIVE}
    ${remaining_time}    get event remaining duration    ${channel_id}    ${CPE_ID}
    I wait for ${remaining_time + 5} seconds
    # check up to 3 future events for locked parental event
    : FOR    ${_}    IN RANGE    ${3}
    \    ${is_age_rated}    is age rated event from traxis    ${channel_id}    ${CPE_ID}
    \    ${event_age}    get agerating from traxis    ${channel_id}    ${CPE_ID}
    \    ${lock_hint}    evaluate    ${event_age} >= ${age} and ${event_age} <= ${max_age}
    \    ${is_locked_age_rated}    evaluate    ${is_age_rated} and ${lock_hint}
    \    Exit For Loop If    ${is_locked_age_rated} == ${True}
    \    ${remaining_time}    get event remaining duration    ${channel_id}    ${CPE_ID}
    \    I wait for ${remaining_time + 5} seconds
    Should Be True    ${is_locked_age_rated}    Failed to wait for the next locked parental event on channel ${PARENTAL_CHANNEL_ALTERNATIVE}

I wait for event of age ${age} in a channel with increasing AR events
    [Documentation]    This keyword waits for a specific age event in increasing AR channel
    I wait for event of age ${age} on ${AR_UP_CHANNEL}

Lock A Channel And Tune To It    #USED
    [Documentation]    This keyword gets a random linear channel and adds to the locked
    ...    channel list and tunes to that locked channel.
    ${filterd_linear_channels}    I Fetch Linear Channel List Filtered
    ${channel_id}    Get Random Element From Array    ${filterd_linear_channels}
    ${channel_number}    Get Channel Number By Id    ${CITY_ID}    ${channel_id}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    I set channel ${channel_number} as User Locked
    I tune to channel    ${channel_number}

Stream is unlocked
    [Documentation]    This keyword verifies that the content stream is unlocked after entering valid PIN.
    ...    Precondition is having suite variable ${ignore_content_unlocked_failure} defined.
    ${status}    Run Keyword And Return Status    Content unlocked
    Run Keyword If    '${status}' == '${False}' and '${ignore_content_check_failures}' != '${True}'    Fail    Failed to check if the content is unlocked
    Run Keyword If    '${ignore_content_check_failures}' == '${True}'    Verify content unlocked

Verify content unlocked
    [Documentation]    This keyword asserts that the content is unlocked
    I open Channel Bar
    Wait Until Keyword Succeeds    10 times    300 ms    Verify content unlocked implementation

Verify Content Locked    #USED
    [Documentation]    This keyword verifies that the channel content is locked
    I open Channel Bar
    Assert channel is locked

Age rated programme is Locked
    [Documentation]    This keyword asserts that the age rated programme is locked
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    200 ms    I expect page element 'id:splashContainer' contains 'textValue:^[abcdefghijklmnop]$' using regular expressions

Adult programme is Locked
    [Documentation]    This keyword asserts that the adult programme is locked
    Assert channel is locked

${channel_type} locked channel is unlocked
    [Documentation]    This keyword asserts locked channel is unlocked
    wait until keyword succeeds    10 times    300 ms    I do not expect page element 'id:RcuCue' contains 'textKey:^DIC_RC_CUE_UNLOCK_(PROGRAM|CHANNEL)$' using regular expressions

${type} programme is unlocked
    [Documentation]    This keyword checks that the channel is unlocked
    ${type} locked channel is unlocked

Reset UI Specific Teardown
    [Documentation]    Teardown steps for tests that need to reset the UI once they're done
    Run keyword If    ${LIGHT_RESTART}    Restart UI via command over SSH
    ...    ELSE    Restart UI via command over SSH by invoking /sbin/reboot
    Default Suite Teardown

AR Specific Parental Suite Setup
    [Arguments]    ${age_rating_list}
    [Documentation]    Parental Suite setup followed by Verify Age information for given ${age_rating_list}
    [Timeout]    ${DEFAULT_SUITE_SETUP_TIMEOUT}
    Parental Suite Setup
    Verify agelist service    ${age_rating_list}

I insert correct parental pin
    [Documentation]    This keyword enters the valid pin into modal popup window
    I enter a valid pin
    Pin Entry popup is not shown

Adults recordings list is shown
    [Documentation]    This keyword checks the Adults recordings list page is shown with the correct title and list of rented assets
    wait until keyword succeeds    10 times    6 sec    I expect page element 'id:mastheadSecondaryTitle' contains 'textKey:DIC_CRUMBTRAIL_ADULT_RECORDINGS'
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:recordingList'

Adult recording is unlocked
    [Documentation]    This keyword checks the titles of Adult recordings are being shown
    ${recording_list_element}    I retrieve json ancestor of level '1' for element 'id:recordingList'
    ${recording_list_count}    Get Length    ${recording_list_element['children']}
    : FOR    ${index}    IN RANGE    ${1}    ${recording_list_count}
    \    ${children_id}    set variable    ${recording_list_element['children'][${index}]['id']}
    \    ${children_node}    Get Enclosing Json    ${recording_list_element}    id:${children_id}    id:listItemPrimaryInfo-ListItem    ${1}
    \    ${asset_title}    set variable    ${children_node['textValue']}
    \    run keyword if    "${asset_title}" == '${DIC_ADULT_CHANNEL}' or "${asset_title}" == '${DIC_ADULT_PROGRAMME}'    fail test    Title Adult is locked

I insert wrong parental pin
    [Documentation]    This keyword enters the invalid pin into modal popup window
    I enter a wrong pin

Incorrect pin entry modal is shown
    [Documentation]    This keyword checks the incorrect pin entry modal is shown after introducing a wrong PIN
    Pin Entry popup is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:pinEntryModalPopupTitle' contains 'textKey:DIC_ADULT_SECTION'
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:pinEntryModalPopupErrorMessage' contains 'textKey:DIC_PIN_ENTRY_MESSAGE_ATTEMPTS_LEFT'

Adults recordings list is not shown
    [Documentation]    This keyword checks that the Adults recordings list page is not being shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:mastheadScreenTitle' contains 'textKey:DIC_SECTION_NAV_RECORDINGS'

I add Channel '${channel_number}' to the Locked channels list through parental control
    [Documentation]    Adds the channel number to locked channel list through parental control
    I open Lock channels with valid pin
    I open 'Add channels' for Locked
    I add Channel ${channel_number} to the Locked channels list

I soft zap to operator locked channel
    [Documentation]    This keyword zaps to operator locked channel from referenced channel
    I tune to a free channel
    ${channel_number}    get from referenced channel via ls    ${CITY_ID}    ${OPERATOR_LOCKED_CHANNEL}    ${CPE_ID}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    ...    -3
    I tune to channel    ${channel_number}
    I press DOWN 3 times
    assert channel is locked

Lock icon is visible on recording
    [Documentation]    This keyword verifies that the lock icon is present on an AR recording in Saved
    I focus locked by age rating recording
    I Press    OK
    Wait Until Keyword Succeeds    10 times    300 ms    I expect page contains 'id:lockIconprimaryMetadata'

Recording with age rating ${age} is available
    [Documentation]    This keyword creates and verifies that an AR recording is in Saved
    Reset All Recordings
    I set age rating of the STB to    ${age}
    There is no unlock history
    I tune to channel with AR ${age}
    I try to record an event
    Interactive modal with options 'Record' and 'Close' is shown
    I press OK on 'Record' option
    'Now Recording' toast message is shown

Clear Recording in Saved
    [Documentation]    This keyword clears out the recording after the test run
    Reset All Recordings

I open recording details page of the AR recording via Saved
    [Documentation]    This Keyword focuses and opens recording details page of an AR recording in Saved
    I open Saved through Main Menu
    I focus locked by age rating recording
    I Press    OK
    Recordings Details page is shown

I choose watch pin entry popup is shown
    [Documentation]    This keyword verifies that PIN Entry popup shows when WATCH is selected on the recording in Saved
    I select the 'WATCH' action
    pin entry popup is shown

I try to watch the locked event
    [Documentation]    Goes through the steps needed for the user to watch an AR locked event up until the PIN popup
    I Press    OK

Locked icon is shown for events AR ${age} and above in guide
    [Documentation]    This keyword verifies that the locked icon is shown for AR events
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:block_\\\\d+_event_\\\\d+_\\\\d' contains 'textValue:.*J.*age: ([${age}-9]|[1-9]\d+)' using regular expressions

I tune to a age rating lock channel
    [Documentation]    This keyword tunes to channel with AR locked replay events
    I tune to channel    ${AR6_LOCKED_CHANNEL_WITH_LOCK_REPLAY}

The currently tuned channel is locked after power cycle
    [Documentation]    This keyword performs a power cycle then verifies that the last tuned channel is locked
    Power cycle and make sure that STB is active
    STB is tuned to last tuned channel
    channel is locked

I Set Age Rating Of The STB To Minimum    #USED
    [Documentation]    This keyword is used to set the Agelock via AS to minimum
    ${current_country_code}     Convert To Uppercase    ${COUNTRY}
    Run Keyword If    '${current_country_code}' == 'GB'    Run Keywords    Set Suite Variable    ${AGE_RATING}    ${None}
    ...    AND    Return From Keyword
    ${age_list}    Get List Of Age Ratings Of The STB Via AS
    Make sure that age rating is set to    ${age_list[1]}
    Set Suite Variable    ${AGE_RATING}    ${age_list[1]}


I Set Age Rating Of The STB To Maximum
    [Documentation]    This keyword is used to set the Agelock via AS to maximum
    ${age_list}    Get List Of Age Ratings Of The STB Via AS
    Make sure that age rating is set to    ${age_list[-1]}

I Set Age Rating Of The STB To Off    #USED
    [Documentation]    This keyword is used to set the Agelock via AS to maximum
    ${age_list}    Get List Of Age Ratings Of The STB Via AS
    Make sure that age rating is set to    ${age_list[0]}

Validate '${type}' Icon For Current Age Rated Event In Channel Bar    #USED
    [Documentation]    Keyword verifies that $type (Accepts only 'LOCK' and 'OPEN_LOCK' values) icon is shown in the channel bar for a current event which is age rated.
    Prevent Channel Bar from disappearing
    ${index_id_now}    ${index_id_next}    Get id for the current and next events
    ${current_event}    I retrieve json ancestor of level '1' for element 'id:titleText${index_id_now}'
    ${is_it_locked}    Extract Value For Key    ${current_event}    ${EMPTY}    iconKeys
    Should Be Equal As Strings    '${is_it_locked}'    '${type}'    Current age rated event has no ${type} icon

Validate Age Rating Indicator For Current Age Rated Event In Channel Bar    #USED
    [Documentation]    Keyword verifies that age rating indication/value is shown in the channel bar for a current event which is age rated.
    ${index_id_now}    ${index_id_next}    Get id for the current and next events
    ${ancestor}    I retrieve json ancestor of level '1' for element 'id:titleText${index_id_now}'
    ${tags}    Extract Value For Key    ${ancestor}    id:titleText${index_id_now}    tags
    ${extracted_lock_indicator}    Extract Value For Key    ${tags}    id:ageRatingIcon    iconKeys
    ${lock_indicator}    Fetch From Right    ${extracted_lock_indicator}    ,
    Should Match Regexp    ${lock_indicator}    PARENTAL\_RATING\_\\d+    Current age rated event has missing age indicator
    [Return]     ${lock_indicator}

Validate Age Rating Background Image For Current Age Rated Event In Channel Bar    #USED
    [Documentation]    Keyword verifies that age rating background image is shown in the channel bar for a current event which is age rated.
    ${lock_indicator}    Validate Age Rating Indicator For Current Age Rated Event In Channel Bar
    ${ancestor}    I retrieve json ancestor of level '1' for element 'id:splashContainer'
    ${background_image}    Extract Value For Key    ${ancestor}    ${EMPTY}    iconKeys
    Should Be Equal As Strings    ${background_image}    ${lock_indicator}    Current age rated event's background image and actual age rating indicator values does not match

Unlock Focused Age Rated Event On Channel Bar    #USED
    [Documentation]    User tuned to any age rated event and channel bar is open.
    I Press    OK
    ${continue_watching_present}    Run Keyword And Return Status    'Continue Watching' popup is shown
    Run Keyword If    ${continue_watching_present}    Run Keywords    Move Focus to Button in Interactive Modal    textKey:DIC_ACTIONS_SWITCH_TO_LIVE    DOWN    1
    ...    AND    I press    OK
    I Enter A Valid PIN On Age Rated Pin Entry Popup