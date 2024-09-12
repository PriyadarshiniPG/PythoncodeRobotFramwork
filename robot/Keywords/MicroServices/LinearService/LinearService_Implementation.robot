*** Settings ***
Documentation     Implementation Keywords for LinearService
Resource          ../EpgService/EpgService_Keywords.robot
Library           Libraries.MicroServices.LinearService.LinearService
Resource           ../PurchaseService/PurchaseService_keywords.robot

*** Variables ***
@{mykeys}    replayProducts    isAdult   isRadio    boundApps
${app_bound_autostart}    autostart_virtualch

*** Keywords ***
Get All Channels Via LinearService   #USED
    [Documentation]    This keyword Get all the channels via LinearService and
    ...    [return]  response [response.status_code; response.reason; response.json()]
    ${response}    Get Current Channel Lineup Via Ls    ${CITY_ID}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    [Return]    ${response}

Return List Of IP Channels
    [Documentation]    This keyword returns list of all IP channels.
    [Arguments]    ${channel_lineup_response}
    ${ip_channel_list}  Get Ip Channel List    ${channel_lineup_response}
    [Return]  ${ip_channel_list}

Get List Of Linear Channel Key Via Linear Service With Filters    #USED
    [Documentation]    This keyword returns list of all channels filtered.
    ...    By default NO radio, 4k, app or adult channels will by returned
    ...    param : resolution : possible values : Any | HD | SD
    [Arguments]    ${type}='id'    ${radio}=False    ${4k}=False    ${adult}=False    ${app}=False    ${resolution}=Any
    ...    ${is_subscribed}=True    ${is_replay}=${False}
    ${response}    Get All Channels Via LinearService
    ${channel_lineup_ids}    Create List From Dict Array Key Elements    ${response}    'id'
    ${radio_channels}    Run Keyword If    not ${radio}    Get All Radio Channels From Linear Service    ${response}
    ${radio_channels}    Run Keyword If    not ${radio}    Get Dictionary Keys    ${radio_channels}
    Run Keyword If    ${radio_channels} != ${None}    Remove List Elements From Other List    ${channel_lineup_ids}    ${radio_channels}
    ${4k_channels}    Run Keyword If    not ${4k}    Get All 4K Channels From Linear Service    ${response}
    Run Keyword If    ${4k_channels} != ${None}    Remove List Elements From Other List    ${channel_lineup_ids}    ${4k_channels}
    ${adult_channels}    Run Keyword If    not ${adult}    Get All Adult Channels From Linear Service    ${response}   'id'
    Run Keyword If    ${adult_channels} != ${None}    Remove List Elements From Other List    ${channel_lineup_ids}    ${adult_channels}
    ${app_channels}    Run Keyword If    not ${app}    Get All C2A App Bound Channels From Linear Service    ${response}    'id'
    Run Keyword If    ${app_channels} != ${None}    Remove List Elements From Other List    ${channel_lineup_ids}    ${app_channels}
    ${hidden_channels}   Get All Hidden Channels    ${response}
    Run Keyword If    ${hidden_channels} != ${None}    Remove List Elements From Other List    ${channel_lineup_ids}    ${hidden_channels}
    Filter Channels Based On Subscription    ${channel_lineup_ids}    ${response}    ${is_subscribed}    ${is_replay}
    Run Keyword If    '${resolution}' != 'Any'    Eliminate Channels Based On Resolution    ${channel_lineup_ids}
    ...    ${response}    ${resolution}
    ${channel_lineup_key}    Run Keyword If    ${type} != 'id'    Get List Of Channels Key From Channel Ids List    ${response}    ${channel_lineup_ids}    ${type}
    ${channels_to_return}    Set Variable If    ${channel_lineup_key} != ${None}    ${channel_lineup_key}    ${channel_lineup_ids}
    [Return]   ${channels_to_return}

Get List Of Channels Key From Channel Ids List    #USED
    [Documentation]    This keyword returns logicalChannelNumber channels list
     ...    of all Linear Channel IDs on ${channel_lineup_ids}
    [Arguments]    ${response}    ${channel_lineup_ids}    ${key}='logicalChannelNumber'
    @{channel_lineup_key}    Create List
    ${length}    Get Length    ${response}
    :FOR    ${index}    IN RANGE    0    ${length}
    \    ${channel_key}    run keyword if    '${response[${index}]['id']}' in ${channel_lineup_ids}    convert to string    ${response[${index}][${key}]}
    \    run keyword if    '${channel_key}' != '${None}'    Append To List    ${channel_lineup_key}    ${channel_key}
    [Return]    ${channel_lineup_key}

Get List Of Linear Channel Numbers Via Linear Service   #USED
    [Documentation]    This keyword returns list of all Linear Channel Numbers
    @{linear_list}    Create List
    ${response}    Get All Channels Via LinearService
    ${length}    Get Length    ${response}
    :FOR    ${index}    IN RANGE    0    ${length}
    \    ${channel_number}    convert to string    ${response[${index}]['logicalChannelNumber']}
    \    Append To List    ${linear_list}    ${channel_number}
    [Return]    ${linear_list}

Get All Recording Blacklisted Channels Via Linear Service    #USED
    [Documentation]    This keyword returns list of all Recording Blacklisted channels
    ...    [Return]   Channel ID list of all Recording Blacklisted channels
    [Arguments]    ${channel_lineup_response}
    @{channel_list}    Create List
    :FOR    ${channel}    IN    @{channel_lineup_response}
    \    ${is_recording_blacklisted}    Extract Value For Key    ${channel}    ${EMPTY}    ndvrBlackout
    \    Continue For Loop If    '${is_recording_blacklisted}' == 'False' or '${is_recording_blacklisted}' == '${None}'
    \    Append To List    ${channel_list}    ${channel['id']}
    [Return]    ${channel_list}

Get All Replay Channels Via Linear Service    #USED
    [Documentation]    This keyword returns list of all replay enabled channels which aren't 4K, App bound, Adult or Radio.
    ...   This keywords also checks for the channels which has info available for them.
    [Arguments]    ${channel_lineup_response}    ${is_subscribed}=True    ${is_replay}=${True}    ${replay_source}=cloud
    @{channel_list}    Create List
    :FOR    ${channel}    IN    @{channel_lineup_response}
    \    ${is_4k}    Extract Value For Key    ${channel}    ${EMPTY}    resolution
    \    Continue For Loop If    "${is_4k}" == "4K"
    \    ${is_hidden}    Extract Value For Key    ${channel}    ${EMPTY}    isHidden
    \    Continue For Loop If    ${is_hidden}
    \    ${isAdult}    Extract Value For Key    ${channel}    ${EMPTY}    isAdult
    \    Continue For loop If    ${isAdult}
    \    ${isRadio}    Extract Value For Key    ${channel}    ${EMPTY}    isRadio
    \    Continue For loop If    ${isRadio}
    \    ${boundApps}    Extract Value For Key    ${channel}    ${EMPTY}    boundApps
    \    Continue For loop If    ${boundApps}
    \    ${replayProducts}    Extract Value For Key    ${channel}    ${EMPTY}    replayProducts
    \    Continue For loop If    "${replayProducts}" == "None"
    \    ${replaySources}    Extract Value For Key    ${channel}    ${EMPTY}    replaySources
    \    ${is_replay_source_available}    Run Keyword If     "${replay_source}" != "Any"    Run Keyword And Return Status    Should Contain    ${replaySources}    ${replay_source}    msg=Replay source:${replay_source} is not present in linear service response    ignore_case=True
    \    Run Keyword If    "${replay_source}" == "Any"    Continue For loop If    "${replaySources}" == "None"
    \    Run Keyword If    "${replay_source}" != "Any"    Continue For loop If    not ${is_replay_source_available}
    \    ${replay_source_length}    Run Keyword If     "${replay_source}" != "Any"   Get Length    ${replaySources}
    \    ${check1}    Run Keyword If     "${replay_source}" != "Any"    Run Keyword And Return Status    Should Be Equal     ${replay_source_length}    ${1}
    \    ${check2}    Run Keyword If     "${replay_source}" != "Any"    Run Keyword And Return Status    Should Be Equal    '${replaySources[0]}'    '${replay_source}'
    \    Run Keyword If     "${replay_source}" != "Any"    Continue For Loop If    not ${check1} or not ${check2}
    \    Append To List    ${channel_list}    ${channel['id']}
    Filter Replay Channels Based On Subscription    ${channel_list}    ${channel_lineup_response}    ${is_subscribed}    ${is_replay}
    ${epg_index}    Get Index Of Event Metadata Segments
    ${epg_data}    Set Variable    ${epg_index.json()}
    @{replay_channels}    Create List
    :FOR   ${entries}    IN    @{epg_data['entries']}
    \    Continue For Loop If    '${entries['channelIds'][0]}' not in ${channel_list}
    \    Append To List    ${replay_channels}    ${entries['channelIds'][0]}
    Should Be True    ${replay_channels}    Unable to find any replay channel which isn't 4K, App bound, Adult or Radio.
    [Return]    ${replay_channels}

Get All 4K Channels From Linear Service
    [Documentation]    This keyword returns list of all 4K channels.
    [Arguments]    ${channel_lineup_response}
    @{4K_channels}    Create List
    :FOR    ${channel}    IN    @{channel_lineup_response}
    \    ${resolution}    Evaluate    ${channel}.get("resolution", False)
    \    Run Keyword If    '${resolution}'=='4K'   Append To List    ${4K_channels}    ${channel['id']}
    [Return]    ${4K_channels}

Get All Adult Channels From Linear Service
    [Documentation]    This keyword returns list of all Adult channels.
    [Arguments]    ${channel_lineup_response}    ${key}='logicalChannelNumber'
    @{adult_channels}    Create List
    :FOR    ${channel}    IN    @{channel_lineup_response}
    \    ${isAdult}    Extract Value For Key    ${channel}    ${EMPTY}    isAdult
    \    Run Keyword If    "${isAdult}" != "None"   Append To List    ${adult_channels}    ${channel[${key}]}
    [Return]    ${adult_channels}

Get All Autostart App Bound Channels From Linear Service    #USED
    [Documentation]    This keyword returns list of all Autostart App Bound channels.
    [Arguments]    ${channel_lineup_response}    ${type}='id'
    @{app_bound_autostart_channels}    Create List
    :FOR    ${channel}    IN    @{channel_lineup_response}
    \    ${boundApps}    Evaluate    ${channel}.get("boundApps", False)
    \    Continue For Loop If    ${boundApps} == False
    \    ${autostart}    Run Keyword and Return Status    Should Contain     ${boundApps[0]['trigger']}    ${app_bound_autostart}
    \    Run Keyword If    ${boundApps}!=False and ${autostart}==${True}   Append To List    ${app_bound_autostart_channels}    ${channel[${type}]}
    [Return]    ${app_bound_autostart_channels}

Get All C2A App Bound Channels From Linear Service    #USED
    [Documentation]    This keyword returns list of all C2A App Bound channels.
    [Arguments]    ${channel_lineup_response}    ${type}='id'
    @{app_bound_c2a_channels}    Create List
    :FOR    ${channel}    IN    @{channel_lineup_response}
    \    ${is_boundApps}    Evaluate    ${channel}.get("boundApps", False)
    \    Run Keyword If    ${is_boundApps} != False    Append To List    ${app_bound_c2a_channels}    ${channel[${type}]}
    [Return]    ${app_bound_c2a_channels}

Get All Radio Channels From Linear Service    #USED
    [Documentation]    This keyword returns list of all Radio channels.
    [Arguments]    ${channel_lineup_response}
    &{radio_channels}    Create Dictionary
    :FOR    ${channel}    IN    @{channel_lineup_response}
    \    ${isRadio}    Evaluate    ${channel}.get("isRadio", False)
    \    Run Keyword If    ${isRadio}!=False    Set To Dictionary    ${radio_channels}    ${channel['id']}    ${channel['name']}
    [Return]    ${radio_channels}

Get Details Of An Event Based On Event ID    #USED
    [Documentation]    This keyword returns the details of a linear event based on the event ID
    [Arguments]    ${event_id}
    ${event_details}    get details of linear event    ${event_id}    ${OSD_LANGUAGE}
    Should Not Be Empty    ${event_details}    Could Not get Details For Event ID ${event_id}
    [Return]    ${event_details}

Get Logo File Name For Channel Number From Linear Service    #USED
    [Arguments]    ${channel_number}    ${4k_support}=False
    [Documentation]    This keyword gets logo file name for the provided channel
    ${file_basename}    get channel bar logo basename    ${CITY_ID}    ${channel_number}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}    ${4k_support}
    [Return]    ${file_basename}

Get Logo URL For Channel Number From Linear Service    #USED
    [Arguments]    ${channel_number}    ${4k_support}=False
    [Documentation]    This keyword gets logo URL for the provided channel
    ${logo_url}    get channel bar logo url    ${CITY_ID}    ${channel_number}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}    ${4k_support}
    [Return]    ${logo_url}

Check Is Logo For Channel Number From Linear Service    #USED
    [Arguments]    ${channel_number}    ${4k_support}=False
    [Documentation]    Returns true if logo present in linear service metadata else returns false
    ${is_logo_present}    is logo present in channel bar    ${CITY_ID}    ${channel_number}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}    ${4k_support}
    should be true    ${is_logo_present}    No Logo Present For channel: ${channel_number}
    [Return]    ${is_logo_present}

Eliminate Channels Based On Resolution
    [Documentation]    This keyword returns the channels with resolution not required
    [Arguments]    ${channel_lineup_ids}    ${response}    ${resolution}
    @{channels}    Create List
    :FOR    ${channel}    IN    @{response}
    \    ${channel_resolution}    Evaluate    ${channel}.get("resolution", False)
    \    Run Keyword If    '${channel_resolution}'!='${resolution}'   Append To List    ${channels}    ${channel['id']}
    Remove List Elements From Other List    ${channel_lineup_ids}    ${channels}

Filter Channels Based On Subscription    #USED
    [Documentation]    This keyword filters channels based on subscription
    [Arguments]    ${channel_lineup_ids}    ${response}    ${is_subscribed}    ${is_replay}
    ${entitlement_ids}    Get List Of Entitlement IDs For A Customer
    @{entitled_channels}    Create List
    @{unentitled_channels}    Create List
    :FOR    ${channel}    IN    @{response}
    \    ${channel_products}    Evaluate    ${channel}.get("linearProducts", False)
    \    Continue For Loop If    ${channel_products} == False
    \    ${are_products_entitled}    Are Products For The Channels Are In Entitlement List   ${channel_products}   ${entitlement_ids}    ${is_replay}
    \    Run Keyword If    ${are_products_entitled} == False   Append To List    ${unentitled_channels}    ${channel['id']}
    \    Run Keyword If    ${are_products_entitled} == True   Append To List    ${entitled_channels}    ${channel['id']}
    Run Keyword If    ${is_subscribed} == True    Remove List Elements From Other List    ${channel_lineup_ids}    ${unentitled_channels}
    Run Keyword If    ${is_subscribed} == False   Remove List Elements From Other List    ${channel_lineup_ids}    ${entitled_channels}
    [Return]      ${channel_lineup_ids}

Are Products For The Channels Are In Entitlement List    #USED
    [Documentation]    This keyword checks that a product is entitled for a product or not
    [Arguments]    ${channel_products}    ${entitlement_ids}    ${is_replay}
    :FOR    ${product}    IN    @{channel_products}
    \    ${linear_status}    Run Keyword And Return Status    List Should Contain Value    ${entitlement_ids}    ${product}
    \    ${entitlement_status}    Run Keyword And Return Status    List Should Contain Value    ${entitlement_ids}    ${product['entitlementId']}
    \    ${is_product_replay_enabled}    Run Keyword And Return Status    Dictionary Should Contain Key    ${product}    replayDuration
    \    ${replay_status}    Set Variable If    ${entitlement_status} and ${is_product_replay_enabled}    True    False
    \    ${are_products_entitled}    Set Variable If    ${is_replay}    ${replay_status}    ${linear_status}
    \    Exit For Loop If    ${are_products_entitled} == True
    [Return]    ${are_products_entitled}

Filter Replay Channels Based On Subscription    #USED
    [Documentation]    This keyword filters channels based on subscription
    [Arguments]    ${channel_lineup_ids}    ${response}    ${is_subscribed}    ${is_replay}
    ${entitlement_ids}    Get List Of Entitlement IDs For A Customer
    @{entitled_channels}    Create List
    @{unentitled_channels}    Create List
    :FOR    ${channel}    IN    @{response}
    \    ${channel_products}    Evaluate    ${channel}.get("replayProducts", False)
    \    Continue For Loop If    ${channel_products} == False
    \    ${replay_entitlements_length}    Get Length    ${channel_products}
    \    Continue For Loop If    ${replay_entitlements_length}==0
    \    ${are_products_entitled}    Are Products For The Channels Are In Entitlement List   ${channel_products}   ${entitlement_ids}    ${is_replay}
    \    Run Keyword If    ${are_products_entitled} == False   Append To List    ${unentitled_channels}    ${channel['id']}
    \    Run Keyword If    ${are_products_entitled} == True   Append To List    ${entitled_channels}    ${channel['id']}
    Run Keyword If    ${is_subscribed} == True    Remove List Elements From Other List    ${channel_lineup_ids}    ${unentitled_channels}
    Run Keyword If    ${is_subscribed} == False   Remove List Elements From Other List    ${channel_lineup_ids}    ${entitled_channels}

Get All Channels With Genre    #USED
    [Documentation]    This Keyword returns a list of channels with given genre
    ${linear_channels}    Get All Channels Via LinearService
    ${channels_with_genre}    Create List
    :FOR    ${channel}   IN    @{linear_channels}
    \    ${is_hidden}    Extract Value For Key    ${channel}    ${EMPTY}    isHidden
    \    Continue For Loop If    ${is_hidden}
    \    ${is_radio}    Extract Value For Key    ${channel}    ${EMPTY}    isRadio
    \    Continue For Loop If    ${is_radio}
    \    ${genre_list}    Extract Value For Key    ${channel}    ${EMPTY}    genre
    \    Continue For Loop If    ${genre_list} == None
    \    Append To List    ${channels_with_genre}    ${channel}
    [Return]    ${channels_with_genre}

Get All Genres And Their Corresponding Channels    #USED
    [Documentation]    This Keyword returns a dictionary with genre as key and list of its corresponding channels
    ...    as value from the list of channels with genre
    [Arguments]    ${channels_with_genre}
    ${genres_and_their_corresponding_channels}    Create Dictionary
    :FOR    ${channel}   IN    @{channels_with_genre}
    \    ${genres_and_their_corresponding_channels}    Add Channels To Corresponding Genres    ${channel}    ${genres_and_their_corresponding_channels}
    [Return]    ${genres_and_their_corresponding_channels}

Add Channels To Corresponding Genres    #USED
    [Documentation]    This keyword gets genre list of a channel and add the channel number to genre in the dictionary
    ...    and return it
    [Arguments]    ${channel}    ${genres_and_their_corresponding_channels}
    ${genres}    Set Variable    ${channel['genre']}
    ${channel_list}    Create List
    :FOR    ${genre}    IN    @{genres}
    \    ${status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${genres_and_their_corresponding_channels}    ${genre}
    \    Run Keyword If    ${status}    Append To List    ${genres_and_their_corresponding_channels['${genre}']}    ${channel['logicalChannelNumber']}
    \    ...    ELSE    Run Keywords    Append To List    ${channel_list}    ${channel['logicalChannelNumber']}    AND    Set To Dictionary    ${genres_and_their_corresponding_channels}    ${genre}    ${channel_list}
    [Return]    ${genres_and_their_corresponding_channels}

Get All Hidden Channels    #USED
    [Documentation]  This keyowrd returns the list of hidden channels
    [Arguments]    ${channel_lineup_response}
    @{hidden_channels}    Create List
    :FOR    ${channel}    IN    @{channel_lineup_response}
    \    ${is_hidden}    Extract Value For Key    ${channel}    ${EMPTY}    isHidden
    \    Run Keyword If    "${is_hidden}" != "None"   Append To List    ${hidden_channels}    ${channel['id']}
    [Return]    ${hidden_channels}

Get All Watershed Compliant Channels From Linear Service    #USED
    [Documentation]    This keyword returns list of all watershed compliant channels.
    [Arguments]    ${channel_lineup_response}    ${key}='logicalChannelNumber'
    @{watershed_compliant_channels}    Create List
    :FOR    ${channel}    IN    @{channel_lineup_response}
    \    ${isWatershed}    Extract Value For Key    ${channel}    ${EMPTY}    isWatershed
    \    Run Keyword If    "${isWatershed}" != "None"   Append To List    ${watershed_compliant_channels}    ${channel[${key}]}
    [Return]    ${watershed_compliant_channels}

Check If Channel Is Watershed Compliant    #USED
    [Documentation]  This keyword checks if the given channel is watershed compliant or not
    [Arguments]    ${channel_id}
    ${current_country_code}    Get Country Code from Stb
    ${current_country_code}     Convert To Uppercase    ${current_country_code}
    Return From Keyword If    '${current_country_code}' != 'GB'    ${None}
    ${channel_number}    Get Channel Number By Id    ${CITY_ID}    ${channel_id}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    ${channel_number}    Convert To Integer    ${channel_number}
    ${status}    ${watershed_compliant_channels}    Run Keyword And Ignore Error    I Fetch All Watershed Compliant Channels From Linear Service
    Log    ${watershed_compliant_channels}
    Return From Keyword If   '${status}'=='FAIL'    ${False}
    ${is_watershed_compliant}    Run Keyword And Return Status    List Should Contain Value    ${watershed_compliant_channels}    ${channel_number}
    [Return]    ${is_watershed_compliant}

Assess Appearance Of Age Lock And Pin Entry Popup According To Watershed Implementation    #USED
    [Documentation]    This keyword checks whether pin entry popup and age lock will be shown for events with a channel ID
    ...    For watershed compliant channels, linear events never require PIN or show age lock. For other features except replay over VOD
    ...    event broadcast time (here given by event_start_time in HH:MM format) watershed lane is compared to current (UK) time watershed lane.
    ...    Pin entry and age lock are shown only when current watershade lane is less than broadcast time watershed lane.
    ...    For watershed non-compliant channels, current watershed age rating is compared with asset age rating.
    ...    If current watershed lane is BTS4 (22.00-5.29), no assets will show age rating. Applies for all features
    ...    For tenants other than GB, this keyword will have no effect.
    [Arguments]    ${asset_type}    ${channel_id}    ${event_start_time}    ${event_age_rating}
    ${is_watershed_compliant}    I Check If Channel Is Watershed Compliant    ${channel_id}
    ${watershed_condition}    Run Keyword If    '${is_watershed_compliant}'=='${False}'    Get Maximum Allowed Age Rating For Watershed Lane
    ...    ELSE IF    '${is_watershed_compliant}'=='${True}' and ('${asset_type}'=='Linear')    Set Variable    ${False}
    ...    ELSE IF    '${is_watershed_compliant}'=='${True}' and ('${asset_type}'=='Replay Over VOD')    Get Maximum Allowed Age Rating For Watershed Lane
    ...    ELSE IF    '${is_watershed_compliant}'=='${True}'    Get Maximum Allowed Age Rating For Watershed Lane
    ...    ${event_start_time}    ${is_watershed_compliant}
    ${type_string}    Evaluate     type($watershed_condition).__name__
    ${is_lock_and_pin_entry}    Run Keyword If    '${type_string}'=='int' and (${watershed_condition}<=${event_age_rating})    Set Variable    ${True}
    ...    ELSE IF    '${type_string}'=='int' and ${watershed_condition}==${-1}    Set Variable    ${False}
    ...    ELSE IF    '${type_string}'=='int' and (${watershed_condition}>${event_age_rating})    Set Variable    ${False}
    ...    ELSE IF    '${type_string}'=='bool'    Set Variable    ${watershed_condition}
    Run Keyword If    '${is_lock_and_pin_entry}'!='${None}'    Set Suite Variable    ${IS_LOCK_AND_PIN_ENTRY}    ${is_lock_and_pin_entry}
    Run Keyword If    '${is_watershed_compliant}'=='${True}'    Set Suite Variable    ${IS_WATERSHED_COMPLIANT}    ${is_watershed_compliant}