*** Settings ***
Documentation     Contains keywords implementation related to localization tests
Resource          ../Common/Common.robot
Resource          ../CommonPages/SectionNavigation_Keywords.robot

*** Variables ***
@{CHANNELS_WITH_DIFFERENT_EVENT_TYPES}    ${REPLAY_SERIES_CHANNEL}    ${OPERATOR_LOCKED_IP_CHANNEL}    ${NO_METADATA_CHANNEL}    ${ADULT_SERIES_CHANNEL}    ${ADULT_LOCKED_EVENT_CHANNEL}    ${OPERATOR_LOCKED_EVENT}

*** Keywords ***
Traverse the current Settings section saving translated texts
    [Documentation]    This keyword moves the focus down until it reaches the end of the current Settings section,
    ...    getting the list of translated texts for each option.
    ...    Precondition:  TRUNCATED_NODES and FULL_TEXT_NODES should be available in the current scope.
    ${json_object}    Get Ui Json
    ${submenu_containers}    Extract Value For Key    ${json_object}    id:Settings.View    children    ${True}
    ${containers_id}    get regexp matches    '${submenu_containers}'    settingsSubMenuContainer(\\d+)
    ${container_count}    get length    ${containers_id}
    : FOR    ${_}    IN RANGE    ${container_count}
    \    I press    DOWN
    \    I wait for ${MOVE_NO_ANIMATION_DELAY} ms
    \    ${state}    Get Ui Locale State
    \    ${TRUNCATED_NODES}    Combine Lists    ${TRUNCATED_NODES}    ${state['truncated']}
    \    ${FULL_TEXT_NODES}    Combine Lists    ${FULL_TEXT_NODES}    ${state['fulltext']}
    Set Test Variable    @{TRUNCATED_NODES}
    Set Test Variable    @{FULL_TEXT_NODES}

Save the translated texts of the current screen
    [Documentation]    This keyword gets the list of translated texts of the current screen and appends them to the
    ...    translated texts already saved.
    ...    Precondition:  TRUNCATED_NODES and FULL_TEXT_NODES should be available in the current scope.
    ${state}    Get Ui Locale State
    ${TRUNCATED_NODES}    Combine Lists    ${TRUNCATED_NODES}    ${state['truncated']}
    ${FULL_TEXT_NODES}    Combine Lists    ${FULL_TEXT_NODES}    ${state['fulltext']}
    Set Test Variable    @{TRUNCATED_NODES}
    Set Test Variable    @{FULL_TEXT_NODES}

