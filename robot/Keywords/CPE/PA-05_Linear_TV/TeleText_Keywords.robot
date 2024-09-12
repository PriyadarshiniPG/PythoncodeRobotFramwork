*** Settings ***
Documentation     TeleText keywords
Resource          ../PA-05_Linear_TV/TeleText_Implementation.robot

*** Keywords ***
Teletext is not shown
    [Documentation]    This keyword asserts that the Teletext is not shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'id:Teletext.View'
