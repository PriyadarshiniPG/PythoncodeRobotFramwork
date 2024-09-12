*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_Reboot
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author           Rajaram Suyamboo


*** Test Cases ***

Invoke Main Menu
    [Documentation]    Invokes Main Menu.
    [Setup]    Default First TestCase Setup
    Run Keyword And Assert Failed Reason    I open Main Menu    'Unable to open main menu'
    wait until keyword succeeds    10 times    0    Main Menu is shown

Reboot STB
    [Documentation]    Reboots the STB.
    [Setup]    Skip If Last Fail
    set context    Reboot
    #log action    Reboot
    Run Keyword And Assert Failed Reason    Reboot CPE Perf   'Unable to Reboot CPE'
    #log action    Reboot_Done
    #wait until keyword succeeds    10 times    0    Main Menu is shown
    #wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Channel Bar for live event is Shown    ${TUNED_CHANNEL_NUMBER}
    #Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Verify Linear TV is Tuned via VLDMS     ${channel_id}
    #Wait Until Keyword Succeeds    300s   100ms    Box is bootup from standby
