*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_Cold_Standby    PROD-NL-SELENE
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author              Shanu Mopila

*** variables ***
${CLEAR_CACHE}    false

*** Test Cases ***
I Change the PowerConsumption To ColdStandby
    [Documentation]     This step change the power consumption to ColdStandby
    [Setup]    Default First TestCase Setup
    run keyword if  '${CLEAR_CACHE}' == 'false'     fail  'Clear cache turned off, skiping script'
    I Tune To Random Replay Channel
    I set standby mode to    ColdStandby

Makes STB To PowerOFF
    [Documentation]    This test makes the STB to PowerOFF
    [Setup]    Skip If Last Fail
    Run Keyword And Assert Failed Reason     I put stb in standby via RedRat    'Tune cannot be done.'

Makes STB To PowerON
    [Documentation]    This test makes the STB to PowerONN
    [Setup]    Skip If Last Fail
    ${channel_id}    I Fetch All Channel ID for given Logical Channel Number    ${TUNED_CHANNEL_NUMBER}
    ${now}    Evaluate    '{dt.hour}:{dt.minute}:{dt.second}'.format(dt=datetime.datetime.now())    modules=datetime
    log to console  stb turn off, wait ${STARTUP_COLDSTANDBY_DELAY_SECONDS} seconds from now: ${now}
    I wait for ${STARTUP_COLDSTANDBY_DELAY_SECONDS} seconds
    set context  STANDBY_TEST
    Run Keyword And Assert Failed Reason     I put stb out of standby via RedRat    'Failed to boot from HOT Standby'
    log action  ColdStandby
    wait until keyword succeeds    300s   0ms    Check if box is connected
    Wait Until Keyword Succeeds    300s   0ms    Box is bootup from standby
    Wait Until Keyword Succeeds    30s    ${DEFAULT_RETRY_INTERVAL}    Verify Linear TV is Tuned via VLDMS     ${channel_id}
    log action  ColdStandby_Done
    After Box is bootup from standby