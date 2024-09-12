*** Settings ***
Documentation     Customer Care & Diagnostics Implementation keywords
Resource          ../Common/Common.robot
Resource          ../PA-07_Connectivity/Connectivity_Implementation.robot

*** Variables ***
@{TR069_GET_VIDEO_OUTPUT_FORMATS}    dmtest gv Device.Services.STBService.1.Capabilities.VideoOutput.VideoFormats
${VIDEO_OUTPUT_FORMATS}    CVBS,S-Video,YPrPb,RGsB,RGB,HDMI,DVI,RF

*** Keywords ***
I verify that '${value}' is reported in journal log extract
    [Documentation]    This keyword verifies that received journal log extract ${FILTERED_JOURNAL_LOG_OUTPUT} contains ${value}
    ...    Pre-reqs: Test var ${FILTERED_JOURNAL_LOG_OUTPUT} has been set
    Variable should exist    ${FILTERED_JOURNAL_LOG_OUTPUT}    Variable ${FILTERED_JOURNAL_LOG_OUTPUT} is not set
    should contain    ${FILTERED_JOURNAL_LOG_OUTPUT}    ${value}    Logs ${FILTERED_JOURNAL_LOG_OUTPUT} does not contain ${value}
