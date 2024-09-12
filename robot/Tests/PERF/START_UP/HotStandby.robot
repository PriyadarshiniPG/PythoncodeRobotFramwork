*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_Hot_Standby    INTERIM   PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO    PROD-CH-EOS    PREPROD-CH-EOS    PROD-NL-SELENE    PROD-UK-EOS  PREPROD-UK-EOS  PROD-IE-EOS    PREPROD-IE-EOS    PROD-PL-APOLLO    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2     TV_APPS    PROD-UK-BENTO    PREPROD-UK-BENTO    PROD-BE-EOSV2    PREPROD-BE-APOLLO-V1-PLUS
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author              ShanmugaPriyan Mohan
#Last Modified By    Shanu Mopila
*** Test Cases ***

I Change the PowerConsumption To HotStandby
    [Documentation]     This step change the power consumption to HotStandby
    [Setup]    Default First TestCase Setup
    I Tune To Random Replay Channel
#    tune to channel for setup    101
#    set suite variable    ${TUNED_CHANNEL_NUMBER}    8
    I set standby mode to    ActiveStandby	

Makes STB To PowerOFF
    [Documentation]    This test makes the STB to PowerOFF
    [Setup]    Skip If Last Fail
    Run Keyword And Assert Failed Reason     I put stb in standby    'Tune cannot be done.'

Makes STB To PowerON
    [Documentation]    This test makes the STB to PowerONN
    [Setup]    Skip If Last Fail
    ${channel_id}    I Fetch All Channel ID for given Logical Channel Number    ${TUNED_CHANNEL_NUMBER}
    I wait for ${STARTUP_HOTSTANDBY_DELAY_SECONDS} seconds
    set context  STANDBY_TEST
    Run Keyword And Assert Failed Reason     I Put Stb Out Of Standby    'Failed to boot from HOT Standby'
    log action  HotStandby
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Channel Bar for live event is Shown    ${TUNED_CHANNEL_NUMBER}
    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Verify Linear TV is Tuned via VLDMS     ${channel_id}
    log action  HotStandby_Done