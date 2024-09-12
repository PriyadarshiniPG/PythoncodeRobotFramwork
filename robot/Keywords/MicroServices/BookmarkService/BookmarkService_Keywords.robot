*** Settings ***
Documentation    Keywords for BookmarkService
Resource         ./BookmarkService_Implementation.robot

*** Keywords ***
Set Profile Bookmark For An Asset Based On Percentage    #USED
    [Documentation]    Set bookmark for an asset based on its content type and current profile
    ...    Takes as parameters bookmark position, asset duration season_id, show_id, episode_number, season_number, age restriction,
    ...    deletion_date and channel_id  which are properties of the asset being set bookmarks for.
    [Arguments]    ${content_type}    ${content_id}    ${asset_duration}    ${percentage}    ${cpe_profile_id}
    ...    ${season_id}=${None}    ${show_id}=${None}    ${episode_number}=${None}    ${season_number}=${None}    ${is_adult}=${False}
    ...    ${minimum_age}=${0}    ${deletion_date}=${None}    ${channel_id}=${None}
    Set Profile Bookmarks For A Given Asset Based On Percentage    ${content_type}    ${content_id}    ${asset_duration}
    ...    ${percentage}    ${cpe_profile_id}    ${season_id}    ${show_id}    ${episode_number}    ${season_number}
    ...    ${is_adult}    ${minimum_age}    ${deletion_date}    ${channel_id}