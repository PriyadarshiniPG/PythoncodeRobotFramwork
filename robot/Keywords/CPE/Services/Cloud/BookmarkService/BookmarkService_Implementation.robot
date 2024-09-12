*** Settings ***
Documentation     Bookmark Service - Cloud Services - Implementation
Library           Libraries.MicroServices.BookmarkService.BookmarkService

*** Keywords ***
Verify bookmark has been created via CS BookmarkService bookmarks
    [Arguments]    ${asset_id}
    [Documentation]    This keyword checks that a bookmark for the asset with id ${asset_id} is present in the
    ...    data returned using Cloud Services Bookmark Service by making a call to bookmarks.
    ...    Returns the bookmark of the asset if found.
    ${profile}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${bookmarks}    Get Profile Bookmarks Via Cs    ${profile}
    Should not be empty    ${bookmarks}    No bookmarks have been created
    : FOR    ${bookmark}    IN    @{bookmarks}
    \    ${asset_has_bookmark}    run keyword and return status    Should start with    ${bookmark['contentId']}    ${asset_id}
    \    Exit For Loop If    ${asset_has_bookmark}
    Should be true    ${asset_has_bookmark}    No bookmarks for the id '${asset_id}' found
    [Return]    ${bookmark}

I Set Bookmark On Recording '${recording_id}' at Percentage '${percentage}'     #USED
    [Documentation]    This keyword calculates the bookmark position using the 'percentage' and recording 'duration
     ...        and sets bookmark on the specified recording.
    ${selected_recording_details}    Get Details Of Single Recording     ${recording_id}
    Set Suite Variable      ${LAST_FETCHED_DETAILS_PAGE_DETAILS}     ${selected_recording_details}
    ${cpe_profile_id}    Get Current Profile Id
    ${season_id}    Evaluate    ${LAST_FETCHED_DETAILS_PAGE_DETAILS}.get("seasonId", ${None})
    ${show_id}    Evaluate    ${LAST_FETCHED_DETAILS_PAGE_DETAILS}.get("showId", ${None})
    ${status}    Run Keyword And Return Status    Should Be Equal As Strings    ${show_id}    ${None}
    ${show_id}    Set Variable If    ${status}    ${season_id}    ${show_id}
    ${season_id}    Set Variable If    ${status}    ${None}    ${season_id}
    ${episode_number}    Evaluate    ${LAST_FETCHED_DETAILS_PAGE_DETAILS}.get("episodeNumber", ${None})
    ${season_number}    Evaluate    ${LAST_FETCHED_DETAILS_PAGE_DETAILS}.get("seasonNumber", ${None})
    ${recording_type}    Run Keyword If    '${STB_TYPE}'=='HDD'    Set Variable    local-recording
    ...    ELSE    Set Variable    network-recording
    Log    Recording Type : ${recording_type}
    Set Profile Bookmark For An Asset Based On Percentage    ${recording_type}    ${selected_recording_details['id']}
    ...    ${selected_recording_details['duration']}    ${percentage}    ${cpe_profile_id}    ${season_id}    ${show_id}
    ...    ${episode_number}    ${season_number}
