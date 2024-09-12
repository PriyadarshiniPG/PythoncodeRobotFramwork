*** Settings ***
Documentation     Bookmark Service - Cloud Services - Keywords
Resource          ./BookmarkService_Implementation.robot

*** Keywords ***
Bookmark of the asset has been created
    [Documentation]    This keyword checks that the data returned from the Bookmark Service contains a bookmark for the
    ...    asset with name ${TILE_CRID}.
    ...    Precondition: The ${TILE_CRID} variable must have been set before.
    Variable should exist    ${TILE_CRID}    The id of the partially watched asset was not saved.
    ${bookmark}    Verify bookmark has been created via CS BookmarkService bookmarks    ${TILE_CRID}
    Set test Variable    ${PREVIOUSLY_FETCHED_BOOKMARK}    ${bookmark}

Bookmark of the asset has been updated
    [Documentation]    This keyword checks that the data returned from the Bookmark Service contains a bookmark for the
    ...    asset with name ${TILE_CRID}, and that the bookmark position data is different from the data saved
    ...    in the ${PREVIOUSLY_FETCHED_BOOKMARK} variable.
    ...    Precondition: The ${TILE_CRID} variable must have been set before.
    ...    Precondition: The ${PREVIOUSLY_FETCHED_BOOKMARK} variable must have been set before.
    Variable should exist    ${TILE_CRID}    The id of the partially watched asset was not saved.
    Variable should exist    ${PREVIOUSLY_FETCHED_BOOKMARK}    The previous bookmark data of the partially watched asset was not saved.
    ${bookmark}    Verify bookmark has been created via CS BookmarkService bookmarks    ${TILE_CRID}
    Should not be equal    ${bookmark}    ${PREVIOUSLY_FETCHED_BOOKMARK}    Bookmark of the partially watched asset has not been updated.

Fetch All Bookmarks For The Profile    #USED
    [Arguments]    ${asset_type}
    [Documentation]    This keyword fetch bookmarks for the profile. It takes two argument i.e. profileId, asset_type.
    ...    Possible values of asset_type: vod, replay, network-recording, local-recording.
    ${profile}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${bookmarks}    Get Profile Bookmarks Via Cs    ${profile}    ${asset_type}
    [Return]    ${bookmarks}

Delete All Bookmarks For The Profile    #USED
    [Documentation]    This keyword deletes all bookmarks for the profile. It takes one argument i.e. profileId.
    ${profile}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${status}    Run Keyword And Return Status    Wait Until Keyword Succeeds    3 times    1 sec    Delete profile Bookmarks via CS    ${profile}
    ${failedReason}    Set Variable If    ${status}    ${EMPTY}    Bookmarks Can't be deleted.
    Should Be Empty        ${failedReason}