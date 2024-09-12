*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_Providers    PROD-UK-EOS   PREPROD-UK-EOS    PROD-PL-APOLLO    VIDEO_PLAYOUT    PROD-IE-EOS    PROD-UK-BENTO    PREPROD-UK-BENTO    PROD-BE-EOSV2    PREPROD-BE-APOLLO-V1-PLUS
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author             ShanmugaPriyan Mohan
#Last Modified  By  Shanu Mopila

*** Test Cases ***
Open OnDemand From MainMenu
    [Documentation]    Open and verifies On demand page
    [Setup]    Default First TestCase Setup
    set context     ProvidersVOD
    Run Keyword And Assert Failed Reason    I open On Demand through Main Menu    'Unable to open ondemand from main menu'

Navigate to predefined VOD asset
    [Documentation]    Navigate to the predefined VOD asset
    [Setup]    Skip If Last Fail
    Move Focus to Section    ${VOD_PROVIDERS_LABEL}    textValue
    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}
    ...    VOD Grid Screen for given section is shown    ${VOD_PROVIDERS_LABEL}
    I wait for 3 seconds
#    I press    OK
    I press    DOWN
    I press    DOWN
    I wait for 3 seconds
    Run keyword if    "${VOD_PROVIDERS_PROVIDER_COLLECTION}" != "${EMPTY}"
    ...    Moved to Named VOD Collection     ${VOD_PROVIDERS_PROVIDER_COLLECTION}
    Run keyword if    "${VOD_PROVIDERS_PROVIDER}" != "${EMPTY}"
    ...    run keywords    Move to Provider    ${VOD_PROVIDERS_PROVIDER}
    ...    AND  I press    OK
#    ...    AND  Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Is Provider Collection Screen Shown    ${VOD_PROVIDERS_PROVIDER}
    I wait for 5 seconds
    Run keyword if  "${VOD_PROVIDERS_COLLECTION}" == "${EMPTY}"
    ...    Moved to Named Tile in Collection    ${VOD_PROVIDERS_ASSET}    ${False}
    ...    ELSE    run keywords
    ...    Run keyword if    "${VOD_PROVIDERS_PROVIDER_SECTION}" != "${EMPTY}"    Move Focus to Section    ${VOD_PROVIDERS_PROVIDER_SECTION}    textValue
    ...    AND  Moved to Named VOD Collection     ${VOD_PROVIDERS_COLLECTION}
    ...    AND  I wait for 2 seconds
    ...    AND  Moved to Named Tile in Collection    ${VOD_PROVIDERS_ASSET}

Invoke and Validate the Details Page
    [Documentation]    Navigate to the details page of VOD asset and verify the contents
    [Setup]    Skip If Last Fail
    I press    OK
    log action    OpeningInfoPage
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Details Page is Shown for channels
    log action  OpeningInfoPage_Done
    Invoke the Episode Picker

Rent and validate the playback of selected TVOD asset
    [Documentation]    Start Playback of TVOD Asset
    [Tags]    VOD_RENT
#    [Setup]    Skip If Last Fail
#    I press    OK
    Handle Popup And Play from Details Page
    log action    PlayerValidation
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Video playout is started
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Verify IP is Played via VLDMS
    log action    PlayerValidation_Done
    I wait for 5 seconds
    I dismiss video player bar
    I Press    BACK
    I Press    MENU


*** Keywords ***
Details Page is Shown for channels
    [Documentation]    Checks if Details Page is Shown
    [Arguments]     ${skip_metadata_check}=False
    ${json_object}    Get Ui Json
    #Verify if the screen is DetailPage.View
    ${detailpage_view_result}    Is In Json    ${json_object}    ${EMPTY}    id:DetailPage.View
    Should be true    ${detailpage_view_result}    Details Page View not shown
    #Verify More like this
#    ${more_like_this_result}    Is In Json    ${json_object}    ${EMPTY}    id:MoreLikeThis_tile_[\\d]+_poster
#    ...    ${EMPTY}    ${True}
#    Should be true    ${more_like_this_result}    More Like this is not shown
    #Verify if asset title is displayed
    ${title_img_result}    Is In Json    ${json_object}    id:title    image:^.+$    ${EMPTY}    ${True}
    ${title_text_result}    Is In Json    ${json_object}    id:title    textValue:^.+$    ${EMPTY}    ${True}
    Should be true    ${title_img_result} or ${title_text_result}   Title is not shown
    ${poster_result}    Is In Json    ${json_object}    id:DetailPagePosterBackground::NodePosterBackgroundImage
    ...    image:^.+$    ${EMPTY}    ${True}
    Should be true    ${poster_result}    Poster is not shown
    return from keyword if    ${skip_metadata_check}
    #Verify if asset synopsis is displayed
    #${synopsis_result}    Is In Json    ${json_object}    id:description    textValue:^.+$    ${EMPTY}    ${True}
    #Should be true    ${synopsis_result}   Synopsis not present
    #Verify if asset primary metadata is displayed. Checks run time and year of release
    ${primary_metadata}    Extract Value For Key    ${json_object}    id:detailPage_duration    textValue
    ${clean_primary_metadata}    remove html tag from string    ${primary_metadata}
    ${text_key}    Extract value for key    ${json_object}    id:detailPage_primaryMetadata    textKey
    ${tag_to_use}    Set Variable If    "${text_key}" == "DIC_GENERIC_DURATION_HRS_MIN"     DIC_GENERIC_DURATION_HRS_MIN    "${text_key}" == "DIC_GENERIC_DURATION_MIN"    DIC_GENERIC_DURATION_MIN
    Run Keyword If  "${tag_to_use}" == "DIC_GENERIC_DURATION_HRS_MIN"    Should Match Regexp    ${clean_primary_metadata}
    ...    [\\d]+ h [\\d]+ min.*    Primay Metadata not present
    Run Keyword If  "${tag_to_use}" == "DIC_GENERIC_DURATION_MIN"    Should Match Regexp    ${clean_primary_metadata}
    ...    [\\d]+ min.*    Primay Metadata not present
    #Verify if poster is displayed