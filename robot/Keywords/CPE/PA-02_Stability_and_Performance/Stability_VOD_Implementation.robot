*** Settings ***
Documentation     Stability VOD keyword definitions

*** Keywords ***
Stability Open VOD
    [Arguments]    ${wait_time}=1
    [Documentation]    This keyword opens VOD/OnDemand menu.
    I Press    MENU
    I wait for ${wait_time} seconds
    I Press    RIGHT
    I wait for ${wait_time} seconds
    I Press    RIGHT
    I wait for ${wait_time} seconds
    I Press    OK
    I wait for 2 seconds
    I Press    DOWN
    I wait for ${wait_time} seconds
    I Press    DOWN
    I wait for ${wait_time} seconds
