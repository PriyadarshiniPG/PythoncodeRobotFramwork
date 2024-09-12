*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Library           Libraries.MicroServices.LinearService.LinearService
Force Tags        SETUP_CHANNEL_NUMBERS
Resource          ./Settings.robot


#Author              Shanu Mopila

*** Test Cases ***
Get All Channel Zapping Numbers
    [Documentation]    Update all channel zapping numbers
    [Setup]    Default First TestCase Setup

    #Update channel number for series and single events
    ${series_channel_number}    Get channel with 'series' event
    update test config     SAVED_SERIES_CHANNEL    ${series_channel_number}
    ${single_channel_number}    Get channel with 'single' event
    update test config     SAVED_SINGLE_EVENT_CHANNEL    ${single_channel_number}

    ${all_channels}    Get List Of Linear Channel Numbers Via Linear Service
    ${scrambled_channels}    Get Configured Scrambled Channels
    ${non_scrambled_channels}   Get Configured NonScrambled Channels
    # Filter out all app bound channels
    ${bound_channels}    I Fetch All App Bound Channels ID From Linear Service    logicalChannelNumber
    #Get all SD channels which doesn't have hd overrite
    ${filtered_channel_list_sd}    Get List Of Linear Channel Key Via Linear Service With Filters   'logicalChannelNumber'    radio=False    4k=False    adult=False    app=False
    ...    resolution=SD    is_subscribed=True
    ${filtered_channel_list_sd}    Evaluate    [channel for channel in ${filtered_channel_list_sd} if channel not in ${bound_channels}]
    ${scrambled_channel_list_sd}    Get Configured Scrambled SD Channels from list    ${all_channels}    ${filtered_channel_list_sd}
    ...    ${scrambled_channels}
    ${CHANNEL_ZAP_SD_CHANNEL}    set variable    @{scrambled_channel_list_sd}[0]

    #Get HD channels
    ${filtered_channel_list_hd}    Get List Of Linear Channel Key Via Linear Service With Filters   'logicalChannelNumber'    radio=False    4k=False    adult=False    app=False
    ...    resolution=HD    is_subscribed=True
    ${filtered_channel_list_hd}    Evaluate    [channel for channel in ${filtered_channel_list_hd} if channel not in ${bound_channels}]
    ${scrambled_channel_list_hd}    Get Configured HD Channels from list    ${all_channels}    ${filtered_channel_list_hd}
    ...    ${scrambled_channels}
    ${nonscrambled_channel_list_hd}    Get Configured HD Channels from list    ${all_channels}    ${filtered_channel_list_hd}
    ...    ${non_scrambled_channels}
    ${CHANNEL_ZAP_HD_CHANNEL}    set variable    @{scrambled_channel_list_hd}[0]

    #Get Scrambled and nonscrambled channels
    ${CHANNEL_ZAP_Scrambled_HD_CHANNEL}    set variable    @{scrambled_channel_list_hd}[0]
    ${CHANNEL_ZAP_Scrambled_HD_CHANNEL_2}    set variable  @{scrambled_channel_list_hd}[1]
    ${CHANNEL_ZAP_NonScrambled_HD_CHANNEL}    set variable    @{nonscrambled_channel_list_hd}[0]
    ${channels}    Combine Lists     ${filtered_channel_list_hd}     ${filtered_channel_list_sd}
    #Get QAM channels
    run keyword if   '${COUNTRY}' != 'pl'
    ...   Set QAM channels    ${filtered_channel_list_sd}    ${filtered_channel_list_hd}
    #Get all single digit channels
    ${one_digits}    Evaluate    [channel for channel in ${channels} if len(channel) == 1]
    ${one_digits_length}    get length    ${one_digits}
    ${two_digits}    Evaluate    [channel for channel in ${channels} if len(channel) == 2]
    ${two_digits_length}     get length    ${two_digits}
    ${three_digits}    Evaluate    [channel for channel in ${channels} if len(channel) == 3]
    ${three_digits_length}     get length    ${three_digits}
    ${CHANNEL_ZAP_SINGLE_DIGIT_INIT_CHANNEL}     set variable if   ${one_digits_length} > 0    @{one_digits}[0]    ${-1}
    ${CHANNEL_ZAP_SINGLE_DIGIT_FINAL_CHANNEL}    set variable if   ${one_digits_length} > 0    @{one_digits}[-1]    ${-1}
    ${CHANNEL_ZAP_TWO_DIGIT_INIT_CHANNEL}     set variable if   ${two_digits_length} > 0    @{two_digits}[0]    ${-1}
    ${CHANNEL_ZAP_TWO_DIGIT_FINAL_CHANNEL}    set variable if   ${two_digits_length} > 0    @{two_digits}[-1]    ${-1}
    ${CHANNEL_ZAP_THREE_DIGIT_INIT_CHANNEL}     set variable if   ${three_digits_length} > 0    @{three_digits}[0]    ${-1}
    ${CHANNEL_ZAP_THREE_DIGIT_FINAL_CHANNEL}    set variable if   ${three_digits_length} > 0    @{three_digits}[-1]    ${-1}
    #Write to file
    Update Test Config    CHANNEL_ZAP_SINGLE_DIGIT_INIT_CHANNEL    ${CHANNEL_ZAP_SINGLE_DIGIT_INIT_CHANNEL}
    Update Test Config    CHANNEL_ZAP_TWO_DIGIT_INIT_CHANNEL    ${CHANNEL_ZAP_TWO_DIGIT_INIT_CHANNEL}
    Update Test Config    CHANNEL_ZAP_THREE_DIGIT_INIT_CHANNEL    ${CHANNEL_ZAP_THREE_DIGIT_INIT_CHANNEL}
    Update Test Config    CHANNEL_ZAP_SINGLE_DIGIT_FINAL_CHANNEL    ${CHANNEL_ZAP_SINGLE_DIGIT_FINAL_CHANNEL}
    Update Test Config    CHANNEL_ZAP_TWO_DIGIT_FINAL_CHANNEL    ${CHANNEL_ZAP_TWO_DIGIT_FINAL_CHANNEL}
    Update Test Config    CHANNEL_ZAP_THREE_DIGIT_FINAL_CHANNEL    ${CHANNEL_ZAP_THREE_DIGIT_FINAL_CHANNEL}
    Update Test Config    CHANNEL_ZAP_SD_CHANNEL    ${CHANNEL_ZAP_SD_CHANNEL}
    Update Test Config    CHANNEL_ZAP_HD_CHANNEL    ${CHANNEL_ZAP_HD_CHANNEL}
    Update Test Config    CHANNEL_ZAP_Scrambled_HD_CHANNEL    ${CHANNEL_ZAP_Scrambled_HD_CHANNEL}
    Update Test Config    CHANNEL_ZAP_Scrambled_HD_CHANNEL_2    ${CHANNEL_ZAP_Scrambled_HD_CHANNEL_2}
    Update Test Config    CHANNEL_ZAP_NonScrambled_HD_CHANNEL    ${CHANNEL_ZAP_NonScrambled_HD_CHANNEL}

*** Keywords ***
Set QAM channels
    [Documentation]    Retrieve qam channels and set the config variables
    [Arguments]    ${filtered_channel_list_sd}    ${filtered_channel_list_hd}
    ${qam_channels}    Return List Of QAM Channels
    ${qam_channels}    Resolve Logical Channel Numbers for Channel ID List    ${qam_channels}
    ${filtered_qamchannel_list}    Evaluate    [channel for channel in ${qam_channels} if channel in ${filtered_channel_list_sd} or channel in ${filtered_channel_list_hd}]
    ${CHANNEL_ZAP_QAM_INIT_CHANNEL}    set variable    @{filtered_qamchannel_list}[0]
    ${CHANNEL_ZAP_QAM_FINAL_CHANNEL}   set variable    @{filtered_qamchannel_list}[-1]
    Update Test Config    CHANNEL_ZAP_QAM_INIT_CHANNEL    ${CHANNEL_ZAP_QAM_INIT_CHANNEL}
    Update Test Config    CHANNEL_ZAP_QAM_FINAL_CHANNEL    ${CHANNEL_ZAP_QAM_FINAL_CHANNEL}

Get Configured Scrambled Channels
    [Documentation]    Retrieve channel numbers for all configured scrambled channels
    ${SCRAMBLED_LOGICAL_NUMBERS}    create list
    ${channel_lineup_response}    Get All Channels Via LinearService
    ${channel_map}   evaluate  {str(channel['id']): str(channel['logicalChannelNumber']) for channel in ${channel_lineup_response}}
    :FOR    ${index}    ${channel_id}    in ENUMERATE     @{SETUP_LTV_ZAP_SCRAMBLED_CHANNELS}
    \    ${logicalChannelNumber}    set variable  &{channel_map}[${channel_id}]
    \    Append to list     ${SCRAMBLED_LOGICAL_NUMBERS}    ${logicalChannelNumber}
    [Return]     ${SCRAMBLED_LOGICAL_NUMBERS}

Get Configured NonScrambled Channels
    [Documentation]    Retrieve channel numbers for all configured nonscrambled channels
    ${NONSCRAMBLED_LOGICAL_NUMBERS}    create list
    ${channel_lineup_response}    Get All Channels Via LinearService
    ${channel_map}   evaluate  {str(channel['id']): str(channel['logicalChannelNumber']) for channel in ${channel_lineup_response}}
    :FOR    ${index}    ${channel_id}    in ENUMERATE     @{SETUP_LTV_ZAP_NONSCRAMBLED_CHANNELS}
    \    ${logicalChannelNumber}    set variable  &{channel_map}[${channel_id}]
    \    Append to list     ${NONSCRAMBLED_LOGICAL_NUMBERS}    ${logicalChannelNumber}
    [Return]     ${NONSCRAMBLED_LOGICAL_NUMBERS}

Get Configured Scrambled SD Channels from list
    [Documentation]    Retrieve channel numbers for all configured scrambled channels
    [Arguments]      ${all_channels}    ${filtered_channel_list_sd}    ${scrambled_channels}
    ${SCRAMBLED_SD_LOGICAL_NUMBERS}    create list
    :FOR    ${index}    ${logical_channel}    in ENUMERATE     @{filtered_channel_list_sd}
    \    continue for loop if    ${index} < 2
    \     ${channel_id_length}    Evaluate    len([channel for channel in ${all_channels} if '${logical_channel}' == str(channel)])
    \     continue for loop if     ${channel_id_length} != 1
    \     ${is_scrambled}    run keyword and return status      List Should Contain Value    ${scrambled_channels}    ${logical_channel}
    \     Run keyword if    ${is_scrambled}    Append to list     ${SCRAMBLED_SD_LOGICAL_NUMBERS}    ${logical_channel}
    [Return]     ${SCRAMBLED_SD_LOGICAL_NUMBERS}

Get Configured HD Channels from list
    [Documentation]    Retrieve channel numbers for all configured scrambled channels
    [Arguments]      ${all_channels}    ${filtered_channel_list_hd}    ${scrambled_nonscrambledchannels}
    ${SCRAMBLED_HD_LOGICAL_NUMBERS}    create list
    :FOR    ${index}    ${logical_channel}    in ENUMERATE     @{filtered_channel_list_hd}
    \    continue for loop if    ${index} < 2
    \     ${is_scrambled}    run keyword and return status      List Should Contain Value    ${scrambled_nonscrambledchannels}    ${logical_channel}
    \     Run keyword if    ${is_scrambled}    Append to list     ${SCRAMBLED_HD_LOGICAL_NUMBERS}    ${logical_channel}
    [Return]     ${SCRAMBLED_HD_LOGICAL_NUMBERS}

Resolve Logical Channel Numbers for Channel ID List
    [Documentation]    Resolve Logical Channel Numbers for Channel ID List
    [Arguments]      ${all_channels}
    ${CONVERTED_LIST}    create list
    ${channel_lineup_response}    Get All Channels Via LinearService
    ${channel_map}   evaluate  {str(channel['id']): str(channel['logicalChannelNumber']) for channel in ${channel_lineup_response}}
    :FOR    ${index}    ${channel_id}    in ENUMERATE     @{all_channels}
    \    ${logicalChannelNumber}    set variable  &{channel_map}[${channel_id}]
    \    Append to list     ${CONVERTED_LIST}    ${logicalChannelNumber}
    [Return]     ${CONVERTED_LIST}