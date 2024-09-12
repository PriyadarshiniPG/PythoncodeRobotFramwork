*** Settings ***
Documentation     Contains keywords related to localization tests
Resource          ../PA-01_HW_and_Platform_Support/I18n_Implementation.robot

*** Keywords ***
Get Ui Locale State
    [Documentation]    Keyword for getting the list of truncated & not truncated translated texts
    ${ret}    get locale state via tt    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    [Return]    ${ret}

I save the Translated texts
    [Documentation]    Keyword for getting the list of truncated & not truncated tranlated texts
    ${state}    Get Ui Locale State
    Set Test Variable    ${TRUNCATED_NODES}    ${state['truncated']}
    Set Test Variable    ${FULL_TEXT_NODES}    ${state['fulltext']}

No Translated Text is Truncated
    [Documentation]    Check if some translated texts are truncated
    Should be Empty    ${TRUNCATED_NODES}    Truncated nodes are not empty

No Translated Text is Wrongly Truncated in Channel Bar
    [Documentation]    Check if some translated texts are wrongly truncated for Settings
    : FOR    ${node}    IN    @{TRUNCATED_NODES}
    \    ${text_key}    Set Variable    ${node['textKey']}
    \    Should Start With    ${text_key}    DIC_GENERIC_EPISODE_FULL    Unexpected truncated Node: ${node}

I save the Translated texts of the complete Detail Page
    [Documentation]    This keyword performs regular navigation inside a Detail Page screen, moving down until
    ...    the focused element doesn't change, saving the truncated & not truncated translated texts at every step.
    @{TRUNCATED_NODES}    create list
    @{FULL_TEXT_NODES}    create list
    ${old_json}    set variable    ${EMPTY}
    : FOR    ${_}    IN RANGE    ${10}
    \    ${focus_changed}    run keyword and return status    Focus Changed    ${old_json}
    \    exit for loop if    not ${focus_changed}
    \    ${old_json}    set variable    ${LAST_FETCHED_FOCUSED_ELEMENTS}
    \    ${state}    Get Ui Locale State
    \    ${TRUNCATED_NODES}    Combine Lists    ${TRUNCATED_NODES}    ${state['truncated']}
    \    ${FULL_TEXT_NODES}    Combine Lists    ${FULL_TEXT_NODES}    ${state['fulltext']}
    \    I press    DOWN
    \    I wait for ${MOVE_ANIMATION_DELAY} ms
    Set Test Variable    ${TRUNCATED_NODES}
    Set Test Variable    ${FULL_TEXT_NODES}

I save the Translated texts of all event types in the Guide
    [Documentation]    This keyword changes to different channels in the Guide screen and saves the truncated
    ...    & not truncated translated texts for every type of event.
    Set Test Variable    @{TRUNCATED_NODES}    @{EMPTY}
    Set Test Variable    @{FULL_TEXT_NODES}    @{EMPTY}
    : FOR    ${channel}    IN    @{CHANNELS_WITH_DIFFERENT_EVENT_TYPES}
    \    I press    ${channel}
    \    I wait for ${UI_LOAD_DELAY} ms
    \    Save the translated texts of the current screen
    I press    ${SINGLE_EVENT_CHANNEL}
    I wait for ${UI_LOAD_DELAY} ms
    Record current event in channel    ${SINGLE_EVENT_CHANNEL}
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textValue:.*>M</font.*$' using regular expressions
    Save the translated texts of the current screen
    I press    REC
    I press OK on 'Stop recording' option
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textValue:.*>O</font.*$' using regular expressions
    Save the translated texts of the current screen

I save the Translated texts of all Settings sections
    [Documentation]    This keyword performs regular navigation inside the Settings screen and saves the truncated & not
    ...    truncated translated texts for each section
    Move Focus to the top level Section Navigation
    ${settings_sections}    ${section_count}    Get Current Sections
    Set Test Variable    @{TRUNCATED_NODES}    @{EMPTY}
    Set Test Variable    @{FULL_TEXT_NODES}    @{EMPTY}
    : FOR    ${section}    IN    @{settings_sections}
    \    Move Focus to Section    ${section['id']}
    \    Traverse the current Settings section saving translated texts
    \    Move Focus to the top level Section Navigation

I save the Translated texts of all Main Menu sections
    [Documentation]    This keyword performs regular navigation of the Main Menu and saves the truncated & not
    ...    truncated translated texts
    ${main_menu_sections}    ${section_count}    Get Current Sections
    Set Test Variable    @{TRUNCATED_NODES}    @{EMPTY}
    Set Test Variable    @{FULL_TEXT_NODES}    @{EMPTY}
    : FOR    ${section}    IN    @{main_menu_sections}
    \    Move Focus to Section    ${section['id']}
    \    Save the translated texts of the current screen

I save the Translated texts of all Apps sections
    [Documentation]    This keyword performs regular navigation of the Main Menu and saves the truncated & not
    ...    truncated translated texts
    ${apps_sections}    ${section_count}    Get Current Sections
    Set Test Variable    @{TRUNCATED_NODES}    @{EMPTY}
    Set Test Variable    @{FULL_TEXT_NODES}    @{EMPTY}
    : FOR    ${section}    IN    @{apps_sections}
    \    Move Focus to Section    ${section['id']}
    \    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:^.*CollectionsBrowser' using regular expressions
    \    Save the translated texts of the current screen
    \    run keyword if    '${section['id']}' == 'AppStore'    Run Keywords    Move to element assert focused elements    textKey:DIC_BACK_TO_TOP    20
    \    ...    DOWN    ${MOVE_NO_ANIMATION_DELAY}
    \    ...    AND    Save the translated texts of the current screen
    \    ...    AND    Move Focus to the top level Section Navigation

No Translated Text is Wrongly Truncated in Main Menu
    [Documentation]    Check if some translated texts are wrongly truncated for the 'Favourite settings' section in the
    ...    Main Menu
    : FOR    ${node}    IN    @{TRUNCATED_NODES}
    \    ${text_key}    Set Variable    ${node['textKey']}
    \    Should Start With    ${text_key}    DIC_SETTINGS    Unexpected truncated Node: ${node}
