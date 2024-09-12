*** Settings ***
Documentation     Customer Care & Diagnostics keywords
Resource          ./Customer_Care_&_Diagnostics_Implementation.robot

*** Keywords ***
I extract line matching string '${value}' from journal log with verification
    [Documentation]    This keyword extracts line matching string ${value} from journal log with verification.
    ...    Then sets extracted string to test variable ${FILTERED_JOURNAL_LOG_OUTPUT}
    ${value_logs}    I connect to STB via ssh to run    journalctl -a | grep ${value}
    should not be empty    ${value_logs}    Logs for ${value} are empty
    should contain    ${value_logs}    ${value}    Logs ${value_logs} does not contain ${value}
    set test variable    ${FILTERED_JOURNAL_LOG_OUTPUT}    ${value_logs}

I verify that title crid is reported in journal log extract
    [Documentation]    This keyword verifies that title crid is reported in journal logs extract
    Variable should exist    ${TILE_CRID}    Variable ${TILE_CRID} is not set
    I verify that '${TILE_CRID}' is reported in journal log extract

I extract audio language '${lang}' line matching string from journal log using screenloadreport
    [Documentation]    This keyword sets audio language to ${lang} then extracts line matching string
    ...    for audio language ${lang} from journal log using screenloadreport service
    ...    Then sets extracted string to suite variable ${FILTERED_JOURNAL_LOG_OUTPUT}
    I set audio language to    ${lang}
    ${lang_logs}    I connect to STB via ssh to run    journalctl -a | grep -i screenloadreport | grep '"setting_value":"${lang}"'
    set suite variable    ${FILTERED_JOURNAL_LOG_OUTPUT}    ${lang_logs}

I verify that journal log extract contains audio language '${lang}' settings
    [Documentation]    This keyword verifies that received journal log extract contains all audio language ${lang} information
    I verify that 'profile.audioLang' is reported in journal log extract
    I verify that '"setting_value":"${lang}"' is reported in journal log extract
    I verify that 'Settings.View' is reported in journal log extract
    I verify that '"key":133' is reported in journal log extract

I get video output formats from STB
    [Documentation]    This keyword will get the video output formats from STB
    I get output of commands '${TR069_GET_VIDEO_OUTPUT_FORMATS}' executed on the STB

I verify that video output formats are reported in STB response
    [Documentation]    This keyword will check that the video output formats are reported in STB response
    I verify that '${VIDEO_OUTPUT_FORMATS}' is reported in STB command output list
