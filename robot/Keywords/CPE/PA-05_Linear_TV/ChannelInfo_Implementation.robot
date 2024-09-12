*** Settings ***
Documentation     Keywords implementations specific to an individual channel
Resource          ../Common/Common.robot
Resource          ../PA-05_Linear_TV/LinearDetailsPage_Keywords.robot

*** Keywords ***
get channel name with underscore for
    [Arguments]    ${channel_number}
    [Documentation]    This keyword gets the channel name and replaces all the spaces in the name with underscore
    ${ch_name}    lookup channelname for    ${channel_number}
    ${ch_name}    convert to lowercase    ${ch_name}
    ${ch_name}    Replace String Using Regexp    ${ch_name}    \\s    _
    [Return]    ${ch_name}
