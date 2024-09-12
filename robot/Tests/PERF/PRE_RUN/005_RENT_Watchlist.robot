*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        SETUP_SAVED_RentAndWatchlist    SETUP
Resource          ./Settings.robot

#Author              Shanu Mopila
*** Test Cases ***
Purchase an Asset and Add to Watchlist
    [Documentation]    Open and verifies On demand page
    [Setup]    Default First TestCase Setup
    ${asset_details}    Get unentitled TVOD asset
    Purchase A Non-Adult TVOD Asset Through Backend    ${asset_details}
    I wait for 5 seconds
    I Validate Purchase Of TVOD Asset With Crid '${LAST_FETCHED_VOD_ASSET}'
    update test config     SAVED_RENTED_ASSET    &{asset_details}[title]
    log to console    SAVED_RENTED_ASSET: &{asset_details}[title]
    
    #Add the item to watchlist
    Add VOD Content To Watchlist    &{asset_details}[id]    &{asset_details}[title]
    Update Test Config    SAVED_WATCHLIST_ASSET    &{asset_details}[title]
    log to console    SAVED_WATCHLIST_ASSET: &{asset_details}[title]

*** Keywords ***
Get unentitled TVOD asset
    [Documentation]    This keyword return unentitle TVOD asset details that can be purchased
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${vod_structure}    Get Vod Full Vod Structure
    ${vod_screens}    Set Variable     ${vod_structure['screens']}
    # Handle all the generic sections
    :FOR    ${sceen_data}    IN     @{vod_screens}
    \     Log    ${sceen_data}
    \     ${section_title}   set variable  &{sceen_data}[title]
    \     ${generic_name}    Get Action For Section Navigation      VOD    ${section_title}
    \     Continue For Loop If    '${generic_name}' == 'SERIES' or '${generic_name}' == 'PROVIDERS' or '${generic_name}' == 'KIDS'
    \     ${movies_details}    Get Content    ${LAB_CONF}    ${section_title}    ASSET    ${COUNTRY}    ${OSD_LANGUAGE}    ${cpe_profile_id}    ${ROOT_ID}
    \     ...    ${CUSTOMER_ID}    all
    \     ${assets_dict}  Get TVOD non-entitled asset title    ${movies_details}   ${False}
    \     Exit For Loop If    ${assets_dict}
    Log    ${TVOD_UNENTITLED_ASSETS}
    [Return]    @{TVOD_UNENTITLED_ASSETS}[0]