*** Settings ***
Documentation     Common keywords definition for stb interface - Remote Key send , webdriver support etc
Resource          ../Common/Common.robot
Library           String
Library           OperatingSystem
Library           Collections

*** Variables ***
${MOVE_ANIMATION_DELAY}    500
${MOVE_NO_ANIMATION_DELAY}    100
${UI_LOAD_DELAY}    1000

*** Keywords ***
Press Key
    [Arguments]    ${remotekey}
    [Documentation]    Key is sent to AS
    Send key    ${remotekey}

Send key
    [Arguments]    ${remotekey}
    [Documentation]    remotekey is sent to XAP.
    log    ${remotekey}
    # If remote pair popup screens appear, they block the key receive functionality on the CPE, so they need to be handled first
    run keyword if    ${CHECK_FOR_REMOTE_PAIRING_TIPS_SCREEN} or ${CHECK_FOR_REMOTE_PAIRING_REQ_POPUP}    Exit either of Pairing request tips screens
    ensure send key succeeds    ${remotekey}

Ensure send key succeeds
    [Arguments]    ${remotekey}    ${time_window}=1s
    [Documentation]    Make sure send remotekey to CPE succeeds within 'time_window' duration.
    send key via as    ${STB_IP}    ${CPE_ID}    ${remotekey}
    ...    xap=${XAP}

User press ${Key} for ${count} times with delay of ${delay} seconds
    [Documentation]    Performs key press for number of times with given delay
    : FOR    ${index}    IN RANGE    ${count}
    \    send key    ${Key}
    \    sleep    ${delay}

I Press    #USED
    [Arguments]    ${remotekey}
    [Documentation]    Key is pressed
    Press Key    ${remotekey}

I press navigation key
    [Arguments]    ${remotekey}
    [Documentation]    Key is pressed
    set test variable    ${key_pressed}    ${remotekey}
    Press Key    ${remotekey}

I press channel zap key    #USED
    [Arguments]    ${remotekey}
    [Documentation]    Zap Key is pressed
    I press navigation key    ${remotekey}

Move to element
    [Arguments]    ${elem}    ${property}    ${expected_value}    ${max_range}    ${arrow}
    [Documentation]    Moves focus to given element
    ${status}    set variable    PASS
    : FOR    ${INDEX}    IN RANGE    ${max_range}
    \    I wait for ${MOVE_ANIMATION_DELAY} ms
    \    @{values}    run keyword and ignore error    I retrieve value for key '${property}' in element '${elem}'
    \    ${status}    set variable    @{values}[0]
    \    Run Keyword If    '''@{values}[1]''' == '''${expected_value}'''    Exit For Loop
    \    I Press    ${arrow}
    should be equal    ${status}    PASS

Move to element and assert
    [Arguments]    ${elem}    ${property}    ${expected_value}    ${max_range}    ${arrow}
    [Documentation]    Moves focus to given element and asserts it is highlighted in the end
    Move to element    ${elem}    ${property}    ${expected_value}    ${max_range}    ${arrow}
    wait until keyword succeeds    20    ${JSON_RETRY_INTERVAL}    I expect page element '${elem}' contains '${property}:${expected_value}'

Move to element with text color
    [Arguments]    ${elem}    ${expected_text_color}    ${max_range}    ${arrow}
    [Documentation]    Moves focus to an element with a given color and asserts it is highlighted in the end
    ${status}    set variable    PASS
    : FOR    ${INDEX}    IN RANGE    ${max_range}
    \    I wait for ${MOVE_ANIMATION_DELAY} ms
    \    ${found}    run keyword and return status    I expect page element '${elem}' has text color '${expected_text_color}'
    \    Exit For Loop If    ${found}
    \    I Press    ${arrow}
    Should be True    ${found}    Could not move focus to ${elem} with text color ${expected_text_color}

Try to Move Focus to direction
    [Arguments]    ${arrow}
    [Documentation]    Try to move the focus to one direction, wait for the focus to change and fails if it didn't change
    ${focused_elements}    Get Ui Focused Elements
    I wait for ${MOVE_ANIMATION_DELAY} ms
    I Press    ${arrow}
    Wait until keyword succeeds    10 times    300 ms    Focus Changed    ${focused_elements}

Move Focus to direction and assert    #USED
    [Arguments]    ${arrow}    ${number_of_retry_times}=1
    [Documentation]    Move the focus to one direction, wait for the focus to change and fails if it didn't change.
    ...    Allows to retry multiple times to handle ignored key press.
    : FOR    ${_}    IN RANGE    ${number_of_retry_times}
    \    ${success}    run keyword and return status    Try to Move Focus to direction    ${arrow}
    \    Exit For Loop If    ${success}
    Should be True    ${success}    Could not move the focus to this direction: ${arrow}

I Long Press ${remotekey} for ${press_duration} seconds
    [Documentation]    Performs a long press of given key for given number of seconds
    send long key press    ${remotekey}    ${press_duration}

send long key press
    [Arguments]    ${remotekey}    ${press_duration}
    [Documentation]    Keyword for sending long press key
    send long key press via as    ${STB_IP}    ${CPE_ID}    ${remotekey}    ${press_duration}    xap=${XAP}

I press ${remotekey} ${count} times
    [Documentation]    Presses key given number of times
    : FOR    ${index}    IN RANGE    ${count}
    \    send key    ${remotekey}
    \    ${json_object}    run keyword and return status    Get Ui json
    \    Run keyword if    ${json_object} =='True'    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Assert json changed
    \    ...    ${json_object}

I send IR key
    [Arguments]    ${ir_key}
    [Documentation]    This keywords used to send key via IR
    send key ir    ${STB_SLOT}    ${ir_key}

Move to element assert focused elements
    [Arguments]    ${elem}    ${max_range}    ${arrow}    ${delay}=${MOVE_ANIMATION_DELAY}
    [Documentation]    This keyword checks if the given element is part of the focused elements, and tries to navigate
    ...    to it pressing the ${arrow} key a max of ${max_range} times waiting ${delay}ms between key presses.
    ${elem_is_focused}    set variable    ${False}
    : FOR    ${_}    IN RANGE    ${max_range}
    \    I wait for ${delay} ms
    \    ${elem_is_focused}    run keyword and return status    I expect focused elements contains '${elem}'
    \    exit for loop if    ${elem_is_focused}
    \    I Press    ${arrow}
    should be true    ${elem_is_focused}    Given element '${elem}' is not in focused elements

Move to element assert focused elements using regular expression
    [Arguments]    ${elem}    ${max_range}    ${arrow}    ${delay}=${MOVE_ANIMATION_DELAY}
    [Documentation]    This keyword checks if the given element is part of the focused elements, and tries to navigate
    ...    to it pressing the ${arrow} key a max of ${max_range} times waiting ${delay}ms between key presses using regex.
    ${elem_is_focused}    set variable    ${False}
    : FOR    ${_}    IN RANGE    ${max_range}
    \    I wait for ${delay} ms
    \    ${elem_is_focused}    run keyword and return status    I expect focused elements contains '${elem}' using regular expressions
    \    exit for loop if    ${elem_is_focused}
    \    I Press    ${arrow}
    should be true    ${elem_is_focused}    Given element '${elem}' is not in focused elements using regex

Check if thread finished
    [Arguments]    ${port}
    [Documentation]    Check if thread for serial port has finished
    ${result}    get port thread status    ${port}
    Should be true    ${result}    Thread has not finished yet

Verify Serial response
    [Arguments]    ${timeout}=180
    [Documentation]    Check if no exceptions caught in the thread
    wait until keyword succeeds    ${timeout} sec    2 sec    Check if thread finished    ${SERIAL_PORT}
    ${thread_response}    ${thread_exception}    get serial response    ${SERIAL_PORT}
    Check Serial exception    ${thread_exception}    ${thread_response}
    [Return]    ${thread_response}

Check Serial exception
    [Arguments]    ${thread_exception}    ${thread_response}
    [Documentation]    This keyword fails if exception was thrown.
    ${status}    Run Keyword and Return Status    Should Be Empty    ${thread_exception}
    Run Keyword Unless    ${status}    Log    Serial lib thread response:${\n}${thread_response}
    Should Be True    ${status}    Exception was thrown in the serial lib thread: ${thread_exception}

Move to collection with element assert focused elements    #USED
    [Arguments]    ${key}    ${tile}    ${max_range}    ${arrow}    ${is_age_rated_vod}=${False}    ${delay}=${MOVE_ANIMATION_DELAY}
    [Documentation]    This keyword checks if the given ${key} with value ${tile} is part of the focused elements, and tries to navigate
    ...    to it pressing the ${arrow} key a max of ${max_range} times waiting ${delay}ms between key presses.
    ${escaped_tile}    Regexp Escape    ${tile}
    : FOR    ${_}    IN RANGE    ${max_range}
    \    I wait for ${delay} ms
    \    Run Keyword If    ${is_age_rated_vod}    Skip Promotional And Editorial Tiles
    \    ${focused_collection}    I retrieve value for key 'id' in focused element '${COLLECTION_NODE_ID_LOW_PATTERN}' using regular expressions
    \    ${focused_collection_items}    Extract Value For Key    ${LAST_FETCHED_FOCUSED_ELEMENTS}    id:${focused_collection}    items
    \    ${is_elem_focused}    Is In Json    ${focused_collection_items}    ${EMPTY}    ${key}:^${escaped_tile}$    ${EMPTY}
    \    ...    ${True}
    \    Exit For Loop If    ${is_elem_focused}
    \    I Press    ${arrow}
    Should Be True    ${is_elem_focused}    No collection was found containing the given element

#Move To Element Assert Provided Element Is Highlighted    #USED
#    [Arguments]    ${elem}    ${max_range}    ${arrow}    ${delay}=${MOVE_ANIMATION_DELAY}
#    [Documentation]    This keyword checks if the given element is focused elements using highlighted color, and tries to navigate
#    ...    to it pressing the ${arrow} key a max of ${max_range} times waiting ${delay}ms between key presses.
#    ${status}    set variable    PASS
#    : FOR    ${INDEX}    IN RANGE    ${max_range}
#    \    I wait for ${delay} ms
#    \    ${ancestor}    I retrieve json ancestor of level '1' for element '${elem}' using regular expressions
#    \    ${len}    Get Length    ${ancestor}
#    \    ${is_focused}     Run Keyword If    ${len} != 0    Evaluate    '${ancestor['textStyle']['color']}' == '${HIGHLIGHTED_NAVIGATION_COLOUR}'
#    \    ...   ELSE   Set Variable    False
#    \    Exit For Loop If    ${is_focused}
#    \    I Press    ${arrow}
#    Should be True    ${is_focused}    Could not highlight '${elem}' element

Move To Element Assert Provided Element Is Highlighted    #USED
    [Arguments]    ${title}    ${MAX_ACTIONS}
    [Documentation]    This keyword checks if the given element is focused elements using highlighted color, and tries to navigate
    ...    to it pressing the down key a max of ${MAX_ACTIONS} times
    ${is_correct_event_highlighted}   Set Variable    False
    log to console  Title to focus: ${title}
    :FOR    ${INDEX}    IN RANGE    ${MAX_ACTIONS}
    \    I Wait For ${MOVE_ANIMATION_DELAY} ms
    \    ${ancestor}    I Retrieve Json Ancestor Of Level '3' In Element 'id:listItemFocusedUnderlineShifted-ListItem|listItemFocusedUnderline-ListItem|bottomLineActive-ListItem' For Element 'color:${INTERACTION_COLOUR}' Using Regular Expressions
    \    ${len}    Get Length   ${ancestor}
    \    ${current_title}    extract value for key    ${ancestor}    id:title-ListItem    textValue
    \    log to console    ${current_title}
    \    ${is_focused}     Run Keyword If    ${len} != 0    Run Keyword And Return Status    Should Contain    ${current_title}    ${title}    ignore_case=True
    \    ${is_focused_2}     Run Keyword If    ${len} != 0    Run Keyword And Return Status    Should Contain    ${title}    ${current_title}    ignore_case=True
    \    Exit For Loop If    ${is_focused} or ${is_focused_2}
    \    I Press    DOWN
    Should Be True     ${is_focused} or ${is_focused_2}    Couldn't highlight '${title}' in recordings list page
