*** Settings ***
Documentation     System implementation keywords
Resource          ../Common/Common.robot

*** Keywords ***
Read Standby Mode from Standby Power Consumption Menu
    [Documentation]    Internal keywords to read power mode from Standby power consumption menu
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SETTINGS_STANDBY_POWER_LABEL'
    ${title_id}    Extract Value For Key    ${LAST_FETCHED_JSON_OBJECT}    textKey:DIC_SETTINGS_STANDBY_POWER_LABEL    id
    ${title_id}    Replace String    ${title_id}    titleText_    ${EMPTY}
    ${current_standbymode}    Extract Value For Key    ${LAST_FETCHED_JSON_OBJECT}    id:settingFieldValueText_${title_id}    textValue
    ${current_standbymode}    split string    ${current_standbymode}    <
    ${current_standbymode}    Set Variable    ${current_standbymode[0]}
    LOG    ${current_standbymode}
    [Return]    ${current_standbymode}

Read Standby Power Consumption Element from System Page
    [Arguments]    ${standbymode}
    [Documentation]    Returns id of new standby mode to be set from Settings Page
    LOG    ${standbymode}
    ${json_object}    Get Ui Json
    : FOR    ${index}    IN RANGE    4
    \    ${mode}    Extract Value For Key    ${json_object}    id:picker-item-text-${index}    textValue
    \    LOG    ${mode}
    \    return from keyword If    '${mode}' == '${standbymode}'    ${index}

Read Current Standby Timer from Current Standby Menu
    [Documentation]    Internal keywords to read Standby Timer value from Current Standby timer Menu
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:settingFieldValueText_0' contains 'textValue:^.+$' using regular expressions
    ${current_standby_timer}    I retrieve value for key 'textValue' in element 'id:settingFieldValueText_0'
    ${current_standby_timer}    Remove String    ${current_standby_timer}    >
    ${current_standby_timer}    Strip String    ${current_standby_timer}
    LOG    ${current_standby_timer}
    [Return]    ${current_standby_timer}
