*** Settings ***
Documentation     Modal & Interactive Modal component navigation keyword cf: https://wikiprojects.upc.biz/display/HZN4S5/Modal+OneMW
Resource          ../Common/Common.robot

*** Variables ***
${DEFAULT_MAX_MODAL_BUTTONS}    5

*** Keywords ***
Move Focus to Button in Modal
    [Arguments]    ${button}    ${direction}    ${max_number_of_moves}=${DEFAULT_MAX_MODAL_BUTTONS}
    [Documentation]    Navigate in a Modal (Settings Modal) to the button identified by ${button} through the direction specified by ${direction}
    ...    Accepts an optional ${max_number_of_moves} positional argument
    ${status}    Run keyword and return status    Move to element with text color    ${button}    ${HIGHLIGHTED_OPTION_COLOUR}    ${max_number_of_moves}    ${direction}
    Should be True    ${status}    Could not move ${direction} to button ${button}

Move Focus to Button in Interactive Modal
    [Arguments]    ${button}    ${direction}    ${max_number_of_moves}=${DEFAULT_MAX_MODAL_BUTTONS}
    [Documentation]    Navigate in a Interactive Modal to the button identified by ${button} through the direction specified by ${direction}
    ...    Accepts an optional ${max_number_of_moves} positional argument
    ${status}    Run keyword and return status    Move to element assert focused elements    ${button}    ${max_number_of_moves}    ${direction}
    Should be True    ${status}    Could not move ${direction} to button ${button}

Move Focus to Checkbox in Modal
    [Arguments]    ${checkbox}    ${direction}    ${max_number_of_moves}=${DEFAULT_MAX_MODAL_BUTTONS}
    [Documentation]    Navigate in a Modal to the checkbox identified by ${checkbox} through the direction specified by ${direction}
    ...    Accepts an optional ${max_number_of_moves} positional argument
    ${status}    Run keyword and return status    Move to element with text color    ${checkbox}    ${INTERACTION_COLOUR}    ${max_number_of_moves}    ${direction}
    Should be True    ${status}    Could not move ${direction} to checkbox ${checkbox}

Move Focus to Value Picker Option in Modal
    [Arguments]    ${option}    ${direction}    ${max_number_of_moves}=${DEFAULT_MAX_MODAL_BUTTONS}
    [Documentation]    Navigate in a Modal to the value picker option identified by ${option} through the direction specified by ${direction}
    ...    Accepts an optional ${max_number_of_moves} positional argument
    ${status}    Run keyword and return status    Move to element and assert    ${option}    color    ${HIGHLIGHTED_NAVIGATION_COLOUR}    ${max_number_of_moves}
    ...    ${direction}
    Should be True    ${status}    Could not move ${direction} to checkbox ${option}

Button is Focused in Modal
    [Arguments]    ${button}
    [Documentation]    Validates is button identified by ${button} is Focused in Modal
    wait until keyword succeeds    10s    1s    I expect page element '${button}' has text color '${HIGHLIGHTED_OPTION_COLOUR}'

Interactive modal is shown    #USED
    [Documentation]    This keyword verifies if an Interactive modal is shown
    Wait Until Keyword Succeeds    10 times    300 ms    I expect page contains 'id:[iI]nteractiveModalPopup' using regular expressions

Interactive modal is not shown    #USED
    [Documentation]    Assert with modal popup title if any Interactive modal window is shown
    ${modal_popup__not_present}    Run Keyword And Return Status    Wait Until Keyword Succeeds    10 times    300 ms    I do not expect page contains 'id:[iI]nteractiveModalPopup' using regular expressions
    ${modal_popup_title}    Run Keyword If    not ${modal_popup__not_present}    Extract Value For Key    ${LAST_FETCHED_JSON_OBJECT}    id:interactiveModalPopupTitle    textValue
    Should Be True    ${modal_popup__not_present}    An Interactive Model Popup with title ${modal_popup_title} is displayed

'Continue Watching' popup is shown    #USED
    [Documentation]    This keyword verifies if the 'Continue Watching' action is shown.
    ${popup_displayed}    Run Keyword And Return Status    Interactive modal is shown
    Should Be True    ${popup_displayed}    'No Iteractive Modal popup displayed. Expected - Continue Watching Popup is Shown'
    ${continue_watching_popup_displayed}    Run Keyword and Return Status    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_ACTIONS_(WATCH|REPLAY)' using regular expressions
    Should Be True    ${continue_watching_popup_displayed}    'Continue Watching Popup is Not Shown'

I focus 'Play from start'    #USED
    [Documentation]    This keyword focuses 'Play from start' On the pop up model
    ${status}    Run Keyword And Return Status    Interactive modal is shown
    Return From Keyword If    ${status} == ${False}
    ${status}    Run Keyword And Return Status    'Continue Watching' popup is shown
    Should Be True    ${status}    'Continue Watching' popup is not shown
    Wait Until Keyword Succeeds    3s    200 ms    I expect page contains 'textKey:DIC_ACTIONS_PLAY_FROM_START'
    Move Focus to Button in Interactive Modal    textKey:DIC_ACTIONS_PLAY_FROM_START    DOWN    3

Switch To Live From Toast Message    #USED
    [Documentation]    This keyword switches to Live from the Delayed stream toast message displayed in the screen.
    Delayed Stream Toast Message Is Present
    'Switch to live TV' Action Is Shown In Delayed Stream Toast Message
    'Switch to live TV' Action Is Focused In Delayed Stream Toast Message
    I Press    OK
    Wait Until Keyword Succeeds    10times    300ms    I do not expect page contains 'textKey:DIC_TOAST_DELAYED_STREAM'

I Switch To Live Tv From Delayed Stream Toast Message   #USED
    [Documentation]    This keyword Catch up the Live Tv from playback of  the replay event.
    I press FFWD to forward till the end
    Switch To Live From Toast Message
    Live stream is playing

Dismiss Delayed Toast Message    #USED
    [Documentation]    This keyword dismisses the delayed stream toast message
    Delayed Stream Toast Message Is Present
    'Dismiss' Action Is Shown In Delayed Stream Toast Message
    'Dismiss' Action Is Focused In Delayed Stream Toast Message
    I Press   OK
    Wait Until Keyword Succeeds    10times    300ms    I do not expect page contains 'textKey:DIC_TOAST_DELAYED_STREAM'

I Dismiss Delayed Stream Toast Message   #USED
    [Documentation]    This keyword Catch up the Live Tv from playback of  the replay event.
    I press FFWD to forward till the end
    Dismiss Delayed Toast Message
    Player is in PLAY mode

Dismiss Delayed Toast Message If Present And Exit Playback    #USED
    [Documentation]    This Keyword will ensure that delayed stream toast message
    ...    is dismissed if present and exits the playback
	${delayed_toast_message}    Run Keyword And Return Status    Delayed Stream Toast Message Is Present
    Run Keyword If    ${delayed_toast_message}    Run Keywords    Dismiss Delayed Toast Message    AND    I Exit Playback
