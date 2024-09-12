*** Settings ***
Documentation     TeleText implementation keywords
Resource          ../Common/Common.robot

*** Keywords ***
I verify Teletext is displayed
    [Documentation]    This keyword verifies that the teletext is displayed or not
    wait until keyword succeeds    5sec    200ms    Teletext is seen

Teletext is seen
    [Documentation]    This keyword checks if teletext is seen on the screen.
    ${shown}    is teletext seen    ${STB_SLOT}
    Should Be True    ${shown}    Teletext is not displayed
