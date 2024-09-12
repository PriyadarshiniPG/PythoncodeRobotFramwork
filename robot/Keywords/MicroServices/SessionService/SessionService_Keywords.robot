*** Settings ***
Documentation     Implementation Keywords for SessionService
Library           Libraries.MicroServices.SessionService.Keywords

*** Keywords ***
Get Hollow Data From Session Service    #USED
    [Documentation]    This keyword Get the data about channels from hollow via session service and
    ...    [return]  response [response.status_code; response.reason; response.content]
    ...    param: ${channel_id} : Id of the channel
    ...    param: ${data_type}: Channel, Content, Event, Product
    [Arguments]    ${channel_id}    ${data_type}=Channel
    ${response}    Get Hollow Data    ${LAB_CONF}    ${channel_id}    ${data_type}
    ${failedReason}    Set Variable If    ${response}    ${EMPTY}    Unable to get data from hollow
    Should Be Empty    ${failedReason}
    [Return]    ${response.content}