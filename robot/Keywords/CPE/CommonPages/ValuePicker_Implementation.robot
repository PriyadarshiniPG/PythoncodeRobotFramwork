*** Settings ***
Documentation     Value Picker component navigation keyword cf: https://wikiprojects.upc.biz/display/HZN4S4/Value+picker+-+OneMW
Resource          ../Common/Common.robot

*** Variables ***
${DEFAULT_MAX_VALUE_PICKER_OPTIONS}    100

*** Keywords ***
Move Focus to Option in Value Picker    #USED
    [Arguments]    ${option}    ${direction}    ${max_number_of_moves}=${DEFAULT_MAX_VALUE_PICKER_OPTIONS}
    [Documentation]    Navigate in a Value Picker to the option identified by ${option} through the direction specified by ${direction}
    ...    Accepts an optional ${max_number_of_moves} positional argument
    ${status}    Run keyword and return status    Move to element with text color    ${option}    ${HIGHLIGHTED_OPTION_COLOUR}    ${max_number_of_moves}    ${direction}
    Should be True    ${status}    Could not move ${direction} to option ${option}

Option is Focused in Value Picker      #USED
    [Arguments]    ${option}    ${regular_expression}=${False}
    [Documentation]    Validates is option identified by ${option} is Focused in Value Picker
    ...    Accepts an ${regular_expression} flag argument (default to ${False}) to identify using regular expression
    Run keyword if    ${regular_expression}    wait until keyword succeeds    10s    1s    I expect page element '${option}' has text color '${HIGHLIGHTED_OPTION_COLOUR}' using regular expressions
    ...    ELSE    wait until keyword succeeds    10s    1s    I expect page element '${option}' has text color '${HIGHLIGHTED_OPTION_COLOUR}'

Move Focus to First Option in Value Picker
    [Arguments]    ${max_number_of_moves}=${DEFAULT_MAX_VALUE_PICKER_OPTIONS}
    [Documentation]    Navigate in a Value Picker to the first option, going UP
    ...    Accepts an optional ${max_number_of_moves} positional argument
    ${status}    Run keyword and return status    Move to element with text color    id:picker-item-text-0    ${HIGHLIGHTED_OPTION_COLOUR}    ${max_number_of_moves}    UP
    Should be True    ${status}    Could not move UP to the first option in the Value Picker

Verify Value Picker Is Present On Screen    #USED
    [Documentation]    This keyword verifies if value picker is present on screen
    Wait Until Keyword Succeeds And Verify Status    3x    100ms    Value Picker is not present on screen    I expect page contains 'id:Default.ValuePicker'

Verify Value Picker Is Not Present On Screen    #USED
    [Documentation]    This keyword verifies if value picker is not present on screen
     Wait Until Keyword Succeeds And Verify Status    3x    100ms    Value Picker is present on screen    I do not expect page contains 'id:Default.ValuePicker'