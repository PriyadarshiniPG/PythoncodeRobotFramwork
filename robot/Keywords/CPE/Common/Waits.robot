*** Settings ***
Documentation     Waits related keywords

*** Keywords ***
I wait for ${wait_time} minutes   #USED
    [Documentation]    Keyword for sleeping in minutes
    Sleep    ${wait_time} minutes

I wait for ${wait_time} ms    #USED
    [Documentation]    Keyword for sleeping in milliseconds
    Sleep    ${wait_time} ms

I wait for ${wait_time} minute          #USED
    [Documentation]    Waits for given number of minutes
    I wait for ${wait_time} minutes

I wait for ${wait_time} seconds       #USED
    [Documentation]    Keyword for sleeping in seconds
    Sleep    ${wait_time} seconds

I wait for ${wait_time} second
    [Documentation]    Keyword for sleeping in seconds
    I wait for ${wait_time} seconds
