*** Settings ***
Documentation    Keywords for VodService
Resource         ./VodService_implementation.robot

*** Keywords ***
I Get Details Of A VOD Asset With Given Crid Id
    [Documentation]    This keyword fetches vod details of an asset with provided crid id using vod service api
    [Arguments]    ${crid}    ${cpe_profile_id}
    ${info}    Get Details Of A VOD Asset With Given Crid Id    ${crid}    ${cpe_profile_id}
    [Return]    ${info}

I Get Contents Of A VOD Section Based On Parameters    #USED
    [Documentation]    This keyword fetches content of a vod section based on asset type, screen type, sort_type,
    ...    provider and count required.
    [Arguments]    ${section_name}    ${cpe_profile_id}    ${count}=single    ${sort_type}=popularity    ${promotional_tile}=${False}
    ${content_type}    Set Variable If    "${section_name}"=="series"    SERIES    ASSET
    ${screen_type}    Set Variable If    "${section_name}"=="providers"    Tile    collection
    ${provider}    Set Variable If    "${section_name}"=="providers"    ${True}    ${False}
    ${movies_details}    Get Contents Of A VOD Section Based On Parameters    ${section_name}    ${cpe_profile_id}    ${content_type}    ${count}    ${screen_type}
    ...    ${provider}    ${sort_type}    ${promotional_tile}
    [Return]    ${movies_details}

I Purchase A Non-Adult TVOD Asset Through Backend    #USED
    [Documentation]    This keyword checks if there are any rented assets. If not, rents a non-adult TVOD Asset from Backend and verify That The VOD Asset has been Purchased from rental page
    I retrieve rentals from purchase service
    ${rented_count}    Get Length   ${RENTED_ASSETS}
    Return From Keyword If    ${rented_count}> 0
    ${asset_details}    Get Details Of A Non-Adult VOD Asset Through Backend
    Purchase A Non-Adult TVOD Asset Through Backend    ${asset_details}
    I Validate Purchase Of TVOD Asset With Crid '${LAST_FETCHED_VOD_ASSET}'

I Get Full VOD Structure    #USED
    [Documentation]    This keyword fetches details of all VOD Sections from backend
    ${vod_dictionary}    Get Full VOD Structure
    Set Suite Variable    ${VOD_SECTION_DETAILS_DICTIONARY}    ${vod_dictionary}

I Get Full VOD Structure For Providers Section    #USED
    [Documentation]    This keyword fetches details of all VOD sections inside Providers section
    ${vod_dictionary}    Get Full VOD Structure
    Get Full VOD Structure For Providers Section    ${vod_dictionary}
    Set Suite Variable    ${VOD_SECTION_DETAILS_DICTIONARY}    ${vod_dictionary}

I Get Contextual VOD Assets    #USED
    [Documentation]    This keyword fetches the list of VOD assets in contextual main menu of on demand
    ${contextual_menu_json}    Get Contextual VOD Assets
    [Return]    ${contextual_menu_json}

I Get Series VOD Details    #USED
    [Documentation]    This keyword retrieves details of a series VOD asset
    ...    ${crid_id} is the crid id of a series/episode
    [Arguments]    ${crid_id}
    ${series_details}    Get Series VOD Details    ${crid_id}
    [Return]    ${series_details}

I Get Root Id From Vod Structure    #USED
    [Documentation]    This keyword try to retrieve the rootid from the vodstructure with the help homescreen
    [Arguments]    ${homescreen_hint_rootid}
    ${structure_response}    Get Root Id From Vod Structure    ${homescreen_hint_rootid}
    ${root_id}    Set Variable    ${structure_response['rootId']}
    [Return]    ${root_id}

I Get Gridscreen Options For Crid    #USED
    [Documentation]    This keyword returns the genres and sort options for a griscreen whose crid is provided
    ...    genre_crid is True if given gridscreen crid is for genre page
    [Arguments]    ${crid}    ${opt_in}=${True}    ${genre_crid}=${True}
    ${grid_options}    Get Gridscreen Options For Crid    ${crid}
    [Return]    ${grid_options}
