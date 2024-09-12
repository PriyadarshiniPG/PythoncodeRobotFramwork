*** Settings ***
Documentation     Parental control implementation keywords
Resource          ../Common/Stbinterface.robot
Resource          ../Common/Common.robot
Resource          ../PA-08_Settings/Settings_Keywords.robot
Resource          ../PA-09_Parental_Control/Locked_Keywords.robot

*** Variables ***
${lcn}            None
${LOCK_ICON}    LOCK
*** Keywords ***
Unlock Icon is shown implementation
    [Documentation]    This keyword checks that the unlock icon present in channel bar . Precondition: channel bar should be present
    ${json_object}    Get Ui Json
    ${ancestor}    Get Enclosing Json    ${json_object}    id:^(titleTextIcons|titleText)\\d    color:${HIGHLIGHTED_NAVIGATION_COLOUR}    ${3}    ${EMPTY}
    ...    ${True}
    ${is_unlocked}    Is In Json    ${ancestor}    ${EMPTY}    iconKeys:OPEN_LOCK
    Should Be True    ${is_unlocked}    Unlock icon is not present in the channel bar.

Verify content unlocked implementation
    [Documentation]    This keyword asserts that the content is unlocked
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'textKey:DIC_ADULT_CHANNEL'
    ${ancestor}    I retrieve json ancestor of level '2' in element 'id:titleText\\d+' for element 'color:${HIGHLIGHTED_NAVIGATION_COLOUR}' using regular expressions
    ${title_length}    Get Length    ${ancestor['textValue']}
    Should be true    ${title_length} > 0    Title is empty so content is not unlocked

Read Age Rating from Set Age Lock Menu
    [Documentation]    This keyword reads age rating from set age lock menu
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:settingFieldValueText_1' contains 'textValue:^.+$' using regular expressions
    ${current_age}    I retrieve value for key 'textKey' in element 'id:settingFieldValueText_1'
    @{current_age_list}    Split String    ${current_age}    separator=_
    ${current_age}    set variable    @{current_age_list}[-1]
    [Return]    ${current_age}

Get current age rating via AS
    [Documentation]    Read current age rating set in stb via Application services
    ${age}    get application service setting    profile.ageLock
    [Return]    ${age}

Get current age rating
    [Documentation]    Read current age rating set in stb
    I open Parental Control through Settings
    I focus Set Age Lock
    ${age}    Read Age Rating from Set Age Lock Menu
    [Return]    ${age}

I Set to ${age} in SetAgeLock window from ${current_age}
    [Documentation]    This keyword sets an age lock in SetAgeLock windows from current age
    ...    Precondition -> Age window inside Set age lock should be open
    ${AR_navigation_direction}    set variable    UP
    ${age}    run keyword if    "${age}" == "off"    set variable    0
    ...    ELSE    set variable    ${age}
    ${current_age}    run keyword if    "${current_age}" == "off"    set variable    0
    ...    ELSE    set variable    ${current_age}
    ${AR_navigation_direction}    run keyword if    ${age} > ${current_age} or ${current_age} == 0    set variable    DOWN
    ...    ELSE    set variable    ${AR_navigation_direction}
    Log    ${AR_navigation_direction}
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_AGE_${age}'
    Move Focus to Option in Value Picker    textKey:${age_navigation_id}    ${AR_navigation_direction}    20
    I Press    OK
    ${current_age_}    Read Age Rating from Set Age Lock Menu
    ${current_age_}    convert to string    ${age}
    should be equal as strings    ${current_age_}    ${age}

I select to enter a valid pin
    [Documentation]    This keyword selects the option for pin entry and enters a valid pin
    I press    OK
    I enter a valid pin

Get metadata from channel bar    #USED
    [Documentation]    Read json ui onetime , cehck channel bar is present , use same ui content for lockedicon,metadata check
    ${json_object}    Get Ui Json
    ${is_in}    Is In Json    ${json_object}    ${EMPTY}    id:NowAndNext.View
    run keyword if    '${is_in}' == '${False}'    fail test    Channel bar not present
    Set test Variable    ${current_json_object}    ${json_object}

Lock Icon present    #USED
    [Documentation]    This keyword checks that the lock icon is present. Precondition: channel bar should be present
    wait until keyword succeeds    10 times    300 ms    I expect page element 'id:RcuCue' contains 'textKey:^DIC_RC_CUE_UNLOCK_(PROGRAM|CHANNEL)$' using regular expressions
    ${textValue}    I retrieve value for key 'iconKeys' in element 'id:(channelBarLockIconTag|channelBarLockIcon)' using regular expressions
    Should Be Equal As Strings    '${textValue}'    '${LOCK_ICON}'    Current age rated event has no ${LOCK_ICON} icon

Unlock Icon is shown    #USED
    [Documentation]    This keyword checks that the unlock icon present in channel bar. Precondition: channel bar should be present
    Wait Until Keyword Succeeds    10 times    1 s    Unlock Icon is shown implementation

Metadata is adult locked
    [Documentation]    Check metadata is adult locked : metadata should show text Adult channel
    wait until keyword succeeds    5 times    400 ms    I expect page element 'id:titleText\\\\d+' contains 'textKey:DIC_ADULT_CHANNEL' using regular expressions

Metadata is user locked
    [Documentation]    Check metadata is user locked
    Wait Until Keyword Succeeds    10 times    1 s    I expect page element 'id:splashContainer' contains 'iconKeys:LOCK'
    Wait Until Keyword Succeeds    10 times    1 s    I expect page element 'id:RcuCue' contains 'textKey:DIC_RC_CUE_UNLOCK_(CHANNEL|PROGRAM)' using regular expressions

Metadata is operator locked
    [Documentation]    This keyword checks that the metadata is operator locked
    Run Keyword If    '${ignore_content_check_failures}' != '${True}'    FAIL    Not Implemented
    ...    ELSE    Assert channel is locked

Metadata is unlocked    #USED
    [Documentation]    This keyword checks that the metadata is unlocked
    ${ancestor}    Get Enclosing Json    ${current_json_object}    id:titleText\\d    color:${HIGHLIGHTED_NAVIGATION_COLOUR}    ${2}    ${EMPTY}
    ...    ${True}
    ${program_title}    Set Variable    ${ancestor['textValue']}
    run keyword if    "${program_title}" == '${DIC_ADULT_CHANNEL}' or "${program_title}" == '${DIC_LOCKED_CHANNEL}' or "${program_title}" == '${DIC_ADULT_PROGRAMME}'    fail test    Metadata is locked
    should not be empty    ${program_title}

Metadata is parental locked
    [Documentation]    This keyword checks that the metadata is parentel locked
    Wait Until Keyword Succeeds    10 times    1 s    I expect page element 'id:splashContainer' contains 'iconKeys:PARENTAL_RATING_\\\\d+' using regular expressions
    Wait Until Keyword Succeeds    10 times    1 s    I expect page element 'id:RcuCue' contains 'textKey:DIC_RC_CUE_UNLOCK_(CHANNEL|PROGRAM)' using regular expressions

lookup channel for age ${age}
    [Documentation]    Returns channel lcn for corresponding age. Parameter : Age
    log    ${age}
    ${channelnumber}    set variable if    ${age} == 3    789    ${age} == 4    790    ${age} == 5
    ...    791    ${age} == 6    792    ${age} == 7    793    ${age} == 8
    ...    794    ${age} == 9    795    ${age} == 10    796    ${age} == 11
    ...    797    ${age} == 12    798    ${age} == 13    799    ${age} == 14
    ...    800    ${age} == 15    801    ${age} == 16    802    ${age} == 17
    ...    803    ${age} == 18    533
    set suite variable    ${lcn}    ${channelnumber}
    [Return]    ${lcn}

lookup channelname for
    [Arguments]    ${channel_number}
    [Documentation]    Returns channel name for a lcn
    ${channel_name}    get channel name via ls    ${CITY_ID}    ${channel_number}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    ${channel_name}    Strip String    ${channel_name}
    [Return]    ${channel_name}

verify age rating on ${channel_name} is ${channel_age_rating}
    [Documentation]    This keyword verifies that ${channel_age_rating} for ${channel_name} is correct via as
    ${channel_id}    get channel id by name via ls    ${CITY_ID}    ${channel_name}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    ${timestamp}    robot.libraries.DateTime.get current date    result_format=%Y-%m-%d %H:%M:%S
    ${timestamp}    Convert date    ${timestamp}    epoch
    ${timestamp}    Convert to integer    ${timestamp}
    &{event_dict}    get current event details via as    ${STB_IP}    ${CPE_ID}    ${channel_id}    ${timestamp}    xap=${XAP}
    ${channel_age_rating_via_as}    Get From Dictionary    ${event_dict}    minimumAge
    should be equal as strings    ${channel_age_rating_via_as}    ${channel_age_rating}    Age rating for ${channel_name} channel is incorrect. Expected age ${channel_age_rating} GOT ${channel_age_rating_via_as}

I wait till the next event starts in ${channelnumber}
    [Documentation]    This keyword waits till next event starts in specific lcn
    ${channel_id}    Get channel ID using channel number    ${channelnumber}
    ${event_remaining_duration}    get event remaining duration    ${channel_id}    ${CPE_ID}
    I wait for ${event_remaining_duration} seconds

Get maximum age of the STB via AS
    [Documentation]    Returns the maximum age supported by the STB via appService
    ${settings}    get application service configuration    settings
    [Return]    ${settings['profile.ageLock']['enum'][-1]}

Get List Of Age Ratings Of The STB Via AS    #USED
    [Documentation]    Returns the list of all ages supported by the STB via appService
    ${settings}    get application service configuration    settings
    [Return]    ${settings['profile.ageLock']['enum']}

Assert channel is locked    #USED
    [Documentation]    This keyword asserts channel is locked
    wait until keyword succeeds    10 times    300 ms    I expect page element 'id:RcuCue' contains 'textKey:^DIC_RC_CUE_UNLOCK_(PROGRAM|CHANNEL)$' using regular expressions

Check the age rating for
    [Arguments]    ${channel_number}    ${channel_age_rating}
    [Documentation]    This keyword verifies that ${channel_number} age rating is ${channel_age_rating}
    ${channel_name}    lookup channelname for    ${channel_number}
    verify age rating on ${channel_name} is ${channel_age_rating}

Verify agelist service
    [Arguments]    ${age_rating_list}
    [Documentation]    This keyword verifies that the age rating information from ${age_rating_list} is available on channels.
    @{age_rating_list}    Split String    ${age_rating_list}    separator=,
    : FOR    ${channel_age_rating}    IN    @{age_rating_list}
    \    ${channel_number}    lookup channel for age ${channel_age_rating}
    \    Check the age rating for    ${channel_number}    ${channel_age_rating}

I Set to age lock via AS to     #USED
    [Arguments]    ${age}
    [Documentation]    This keyword is used to set the Agelock via AS
    log    ${age}
    Set Application Services Setting    profile.ageLock    ${age}
    ${get_age}    Get application service setting    profile.ageLock
    should be equal as strings    '${get_age}'    '${age}'    Failed to set to age lock via AS

I focus locked by age rating recording
    [Documentation]    This keyword focuses on AR recording in Saved
    Move Focus to Collection named    DIC_RECORDING_LABEL_RECORDED
    I Press    RIGHT
    Ongoing recording tile is focused

I select the 'WATCH' action
    [Documentation]    This keyword selects WATCH action on the Linear details page of an ongoing recording present in Saved
    Move Focus to Section    DIC_ACTIONS_WATCH    textKey
    I Press    OK
