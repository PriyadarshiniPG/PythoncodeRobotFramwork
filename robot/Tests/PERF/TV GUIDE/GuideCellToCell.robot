*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch
Force Tags        JIRA_GuideCellToCell    PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO    PROD-CH-EOS    PREPROD-CH-EOS    PROD-NL-SELENE    PROD-UK-EOS  PREPROD-UK-EOS  PROD-IE-EOS    PREPROD-IE-EOS    PROD-PL-APOLLO    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2    PROD-UK-BENTO    PREPROD-UK-BENTO    PROD-BE-EOSV2    PREPROD-BE-APOLLO-V1-PLUS

#Author    ShanmugaPriyan Mohan
#Modified  Khushal M Jain

*** Test Cases ***
Tune to cartoon channel
    [Documentation]    Tune to cartoon channel
    [Setup]    Default First TestCase Setup
    Run Keyword And Assert Failed Reason     I tune to cartoon channel    'Unable to Tune to cartoon channel'

Open EPG From LiveTV
    [Documentation]    This Keyword opens the EPG
    [Setup]    Skip If Last Fail
    I open Main Menu
    I focus TV Guide
    I Press    OK

Validates Whether TVGuide is Opened Successfully
    [Documentation]    Validates Whether TVGuide is Opened Successfully.
    [Setup]    Skip If Last Fail
    wait until keyword succeeds    20 times    0 s    Validate TVGuide Is loaded

Moves The Current Focus To Next Event
    [Documentation]    Moves the focus to next event
    [Setup]   Skip If Last Fail
    set context     GuideCellToCell
    &{highlighted_event}    Get Focused Guide Programme Cell Details
    @{regexp_match}    Get Regexp Matches    &{highlighted_event}[event_id]    (block_\\d+_event_\\d+_)(\\d+)    1    2
    @{match_list}    Set Variable    @{regexp_match}[0]
    ${id_prefix}    Set Variable    @{match_list}[0]
    ${id_suffix}    Set Variable    @{match_list}[1]
    ${id_suffix}    Convert To Integer    ${id_suffix}
    ${future_event_id}    Catenate    SEPARATOR=    ${id_prefix}    ${id_suffix + 1}
    set test variable    ${FUTURE_EVENT_ID}    ${future_event_id}
    I press    RIGHT
    log action   StartRight
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    I verify future event in tv guide is focused    ${future_event_id}
    log action   StartRight_Done