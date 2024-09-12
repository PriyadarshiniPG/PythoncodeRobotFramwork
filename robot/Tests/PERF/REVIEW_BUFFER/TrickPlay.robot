*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_Trickplay  PROD-NL-SELENE    PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO    PROD-CH-EOS    PREPROD-CH-EOS    PROD-UK-EOS   PREPROD-UK-EOS    PROD-IE-EOS    PREPROD-IE-EOS    PROD-PL-APOLLO    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2    PROD-UK-BENTO    PREPROD-UK-BENTO    PREPROD-BE-APOLLO-V1-PLUS
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author               ShanmugaPriyan Mohan
#Last Modified By     Shanu Mopila

*** Test Cases ***
Tune To Trickplay enabled Channel
    [Documentation]    Review Buffer - Tune to trickplay enabled channel
    Run Keyword And Assert Failed Reason    I open Guide through Main Menu    'Unable to open Guide'
    Run Keyword And Assert Failed Reason    I tune to ${REVIEW_BUFFER_TRICKPLAY_CHANNEL} in the tv guide    'Unable to Tune to replay event'

Play Current Event From Beginning
    [Documentation]    This Keyword plays the content from Beginning.
    [Setup]    Skip If Last Fail
    Run Keyword And Assert Failed Reason    I Play from Start from Guide    'Unable to play the event from start'
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Verify IP is Played via VLDMS
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Video playout is started

Validate Transition from Play to Pause
    [Documentation]    Review Buffer - Validate Trickplay Transition Play to Pause
    [Setup]    Skip If Last Fail
    set context  TrickPlay
    ${ref_id}    get main session ref id via vldms    ${STB_IP}    ${CPE_ID}
    I Press    PLAY-PAUSE
    log action    PlaytoPause
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Verify Player 'PAUSE' mode for '${ref_id}'
    log action    PlaytoPause_Done

Validate Transition from Pause to Play
    [Documentation]    Review Buffer - Validate Trickplay Transition Play to Pause
    [Setup]    Skip If Last Fail
    ${ref_id}    get main session ref id via vldms    ${STB_IP}    ${CPE_ID}
    I Press    PLAY-PAUSE
    log action    PauseToPlay
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Verify Player 'PLAY' mode for '${ref_id}'
    log action    PauseToPlay_Done

Validate Transition from Play to Fast Forward
    [Documentation]    Review Buffer - Validate Trickplay Transition Play to Fast Forward.
    [Setup]    Skip If Last Fail
    ${ref_id}    get main session ref id via vldms    ${STB_IP}    ${CPE_ID}
    I Press    FFWD
    log action    PlayToFF
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Verify Player 'FFWD' mode for '${ref_id}'
    log action    PlayToFF_Done

Validate Transition from Fast Forward to Play
    [Documentation]    Review Buffer - Validate Trickplay Transition Fast Forward to Play.
    [Setup]    Skip If Last Fail
    Swith Player to '64' FF Mode
    I wait for 2 seconds
    ${ref_id}    get main session ref id via vldms    ${STB_IP}    ${CPE_ID}
    I Press    PLAY-PAUSE
    log action    FFtoPlay
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Verify Player 'PLAY' mode for '${ref_id}'
    log action    FFtoPlay_Done

Validate Transition from Play to Fast Rewind
    [Documentation]    Review Buffer - Validate Trickplay Transition Play to Fast Rewind.
    [Setup]    Skip If Last Fail
    ${ref_id}    get main session ref id via vldms    ${STB_IP}    ${CPE_ID}
    I Press    FRWD
    log action    PlayToFR
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Verify Player 'FRWD' mode for '${ref_id}'
    log action    PlayToFR_Done

Validate Transition from Fast Rewind to Play
    [Documentation]    Review Buffer - Validate Trickplay Transition Fast Rewind to Play.
    [Setup]    Skip If Last Fail
    Swith Player to '-64' FR Mode
    ${ref_id}    get main session ref id via vldms    ${STB_IP}    ${CPE_ID}
    I Press    PLAY-PAUSE
    log action    FRtoPlay
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Verify Player 'PLAY' mode for '${ref_id}'
    log action    FRtoPlay_Done
    I wait for 5 seconds
    I dismiss video player bar
    I Press    BACK
    I Press    MENU
