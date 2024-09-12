*** Settings ***
Documentation     Player Implementation Keywords
Resource          ../Common/Stbinterface.robot
Resource          ../Json/Json_handler.robot
Resource          ../PA-04_User_Interface/ChannelBar_Keywords.robot

*** Variables ***
${CONTINUE_WATCHING_TOLERANCE_VALUE_SECONDS}    5
${PLAY_TIME_SECS_TO_ALLOW_TRICKPLAY}    180
${BUFFER_TYPE_RAM}    "playbacksource":"RAM"

*** Keywords ***
Get player visibility    #USED
    [Documentation]    This keyword returns a boolean value stating if player is shown without any error popup
    Error popup is not shown
    ${json_object}    Get Ui Json
    ${player_visible}    Is In Json    ${json_object}    ${EMPTY}    id:playerUIContainer-Player
    [Return]    ${player_visible}

Player bar is not showing    #USED
    [Documentation]    This keyword verifies that the player bar is not showing
    ${player_visible}    Get player visibility
    should not be true    ${player_visible}    Player bar is visible

Hide Video Player bar
    [Documentation]    This keyword hides video player bar
    ${player_visible}    run keyword and return status    wait until keyword succeeds    8x    500ms    Player bar is not showing
    Run Keyword If    '${player_visible}' == '${False}'    I press    DOWN
    Wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'id:playerUIContainer-Player'

Get viewing progress indicator data         #USED
    [Documentation]    Get the viewing progress indicator data. The time string and x position are fetched.
    ${json_object}    Get Ui Json
    ${is_in}    Is In Json    ${json_object}    ${EMPTY}    id:currentPosition-NonLinearInfoPanel
    Should Be True    ${is_in}    Could not find currentPosition-NonLinearInfoPanel in the JSON for this screen
    ${current_position_time}    Extract Value For Key    ${json_object}    id:currentPosition-NonLinearInfoPanel    textValue
    ${current_position_value}    Extract Value For Key    ${json_object}    id:currentPosition-NonLinearInfoPanel    position
    [Return]    ${current_position_time}    ${current_position_value}

Get time as integer
    [Arguments]    ${time_as_string}
    [Documentation]    Convert time as a string to an integer
    ${time_as_string}    Remove String    ${time_as_string}    :
    ${time_as_int}    Convert To Integer    ${time_as_string}
    [Return]    ${time_as_int}

Get progress indicator x position as int from position
    [Arguments]    ${position}
    [Documentation]    Gets the x position from the position data and converts it to an integer
    ${x_pos_int}    set variable    &{position}[x]
    ${x_pos_int}    Convert To Integer    ${x_pos_int}
    [Return]    ${x_pos_int}

Get asset title from Player info panel    #USED
    [Documentation]    This keyword gets the asset title that appears when the player bar is active
    ...    and returns it
    ...    Pre-reqs: Player bar should be visible
    ${player_event_title}    I retrieve value for key 'textValue' in element 'id:assetTitle-.*LinearInfoPanel' using regular expressions
    [Return]    ${player_event_title}

Asset title from Player info panel has not changed
    [Documentation]    This keyword checks the Player info panel title has not changed. This can be used to verify that
    ...    an event is still playing as expected, after other actions have been carried out.
    ...    Pre-reqs: test var ${LAST_PLAYER_ASSET_TITLE} has been set. Currently playing back an asset
    Variable should exist    ${LAST_PLAYER_ASSET_TITLE}    Test variable LAST_PLAYER_ASSET_TITLE has not been set
    Show Video Player bar
    ${player_asset_title}    Get asset title from Player info panel
    should be equal as strings    ${player_asset_title}    ${LAST_PLAYER_ASSET_TITLE}    Player info panel title has changed during playout

Get linear player viewing progress indicator time
    [Documentation]    Get the viewing progress indicator data from the linear player and return it.
    ${json_object}    Get Ui Json
    ${player_is_shown}    Is In Json    ${json_object}    ${EMPTY}    id:playerUIContainer-Player
    run keyword unless    ${player_is_shown}    Show Video Player bar
    ${progress_is_shown}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    id:timeProgress-LinearInfoPanel
    Should Be True    ${progress_is_shown}    Could not find the progress time of the Linear Player
    ${time_symbols}    Extract Value For Key    ${LAST_FETCHED_JSON_OBJECT}    id:timeProgress-LinearInfoPanel    children
    ${progress_time}    set variable    ${EMPTY}
    : FOR    ${symbol}    IN    @{time_symbols}
    \    ${progress_time}    Catenate    SEPARATOR=    ${progress_time}    ${symbol['textValue']}
    Hide Video Player bar
    [Return]    ${progress_time}

Get video playout position on the timeline
    [Documentation]    This keyword retrieves and then returns current video playout position.
    ...    Pre-reqs: Player has to be present.
    ${ref_id}    Get current channel
    I open Review Buffer Player
    ${property_list}    Create list    position
    ${position}    get player session property via vldms    ${STB_IP}    ${CPE_ID}    ${ref_id}    ${property_list}
    ${position}    Extract Value For Key    ${position}    ${EMPTY}    ${property_list[0]}
    [Return]    ${position}
