*** Settings ***
Documentation     Implementation Keywords for BookmarkService
Library           Libraries.MicroServices.BookmarkService.BookmarkService
Resource          ../../api.basic.robot

*** Keywords ***
Set Profile Bookmarks    #USED
    [Documentation]    Set bookmark for an asset based on current profile with given bookmark position
    ...    and given asset duration. if bookmark position is 0, duration should be passed as 0
    ...    content_id: crid for VOD and crid plus Imi for other content types
    ...    content_type: possible values are 'vod', 'replay','network-recording', 'local-recording'
    ...    crid: crid id of the asset for which bookmark is to be set
    ...    bookmark_position: the position in which bookmark needs to be set: will be in relation to duration
    ...    asset_duration: duration of the asset for which bookmarj is to be set
    ...    season_id: season id of recording or replay asset
    ...    show_id: show id of recording or replay asset
    ...    episode_number: episode number of recording or replay asset
    ...    season_number: season_number of recording or replay asset
    ...    is_adult: flag whether asset is adult or not
    ...    minimum_age: age rating of the asset
    ...    deletion_date: deletion date of the asset
    ...    channel_id: channel id for replay channel
    [Arguments]    ${content_type}    ${content_id}    ${bookmark_position}    ${asset_duration}    ${cpe_profile_id}
    ...    ${season_id}=${None}    ${show_id}=${None}    ${episode_number}=${0}    ${season_number}=${0}    ${is_adult}=${False}
    ...    ${minimum_age}=${0}    ${deletion_date}=${None}    ${channel_id}=${None}
    ${response}    set profile bookmarks via cs    ${cpe_profile_id}    ${content_id}    ${CUSTOMER_ID}    ${CPE_ID}    ${bookmark_position}
    ...    ${asset_duration}    ${content_type}    ${season_id}    ${show_id}    ${episode_number}    ${season_number}
    ...    ${is_adult}    ${minimum_age}    ${deletion_date}    ${channel_id}
    Check Respond Status And failedReason    ${response}    ${204}

Set Profile Bookmarks For A Given Asset Based On Percentage    #USED
    [Documentation]    Set bookmark for an asset based on current profile with bookmark position
    ...    being $percentage % of the asset duration
    [Arguments]    ${content_type}    ${content_id}    ${asset_duration}    ${percentage}    ${cpe_profile_id}
    ...    ${season_id}=${None}    ${show_id}=${None}    ${episode_number}=${0}    ${season_number}=${0}    ${is_adult}=${False}
    ...    ${minimum_age}=${0}    ${deletion_date}=${None}    ${channel_id}=${None}
    ${is_default}    Set Variable If    ${percentage} == ${0}    ${True}    ${percentage} == ${100}    ${True}    ${False}
    ${bookmark_position}    Run Keyword If    ${is_default} == ${False}
    ...    Calculate Bookmark Position For A Given Asset Based On Percentage    ${asset_duration}    ${percentage}
    ${calculated_bookmark_position}    Set Variable If    ${percentage} == ${100}    ${asset_duration}
    ...    ${percentage} == ${0}    ${0}    ${bookmark_position}
    ${calculated_duration}    Set Variable If    ${percentage} == ${0}    ${0}    ${asset_duration}
    Set Profile Bookmarks    ${content_type}    ${content_id}    ${calculated_bookmark_position}    ${calculated_duration}
    ...    ${cpe_profile_id}    ${season_id}    ${show_id}    ${episode_number}    ${season_number}    ${is_adult}
    ...    ${minimum_age}    ${deletion_date}    ${channel_id}

Calculate Bookmark Position For A Given Asset Based On Percentage    #USED
    [Documentation]    This keyword calculates $percentage % of $asset_duration and rounds off to nearest integer
    [Arguments]    ${asset_duration}    ${percentage}
    ${asset_duration_decimal}    Convert To Number    ${asset_duration}
    ${dividend}    Convert To Number    ${percentage}
    ${divisor}    Convert To Number    ${100}
    ${quotient}    Evaluate    ${dividend}/${divisor}
    ${bookmark_not_rounded}    Evaluate    ${quotient} * ${asset_duration_decimal}
    ${bookmark_rounded}    Convert To Number    ${bookmark_not_rounded}    ${0}
    ${bookmark_position}    Convert To Integer    ${bookmark_rounded}
    [Return]    ${bookmark_position}
