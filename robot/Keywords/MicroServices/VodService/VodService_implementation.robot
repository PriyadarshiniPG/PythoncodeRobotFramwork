*** Settings ***
Documentation     Implementation Keywords for VodService
Resource          ../../api.basic.robot

*** Keywords ***
Get Details Of A VOD Asset With Given Crid Id
    [Documentation]    This keyword fetches vod details of an asset with provided crid id using vod service api
    [Arguments]    ${crid}    ${cpe_profile_id}
    ${info}    get asset by crid    ${LAB_CONF}    ${crid}    ${COUNTRY}    ${OSD_LANGUAGE}    ${cpe_profile_id}
    ...    ${CUSTOMER_ID}
    Should Not Be Equal As Strings    ${info}    ${None}    Unable to fetch VOD Asset Details
    [Return]    ${info}

Get Contents Of A VOD Section Based On Parameters    #USED
    [Documentation]    This keyword fetches content of a vod section based on asset type, screen type, sort_type,
    ...    provider and count required.
    [Arguments]    ${section_name}    ${cpe_profile_id}    ${content_type}=ASSET    ${count}=single    ${screen_type}=collection
    ...    ${provider}=${None}    ${sort_type}=popularity    ${promotional_tile}=${False}
    ${movies_details}    Get Content    ${LAB_CONF}    ${section_name}    ${content_type}    ${COUNTRY}    ${OSD_LANGUAGE}
    ...    ${cpe_profile_id}    ${ROOT_ID}    ${CUSTOMER_ID}    ${count}    ${screen_type}    ${provider}    ${sort_type}
    ...    ${promotional_tile}
    Should Not Be Equal As Strings    ${movies_details}    ${None}    Unable to fetch VOD Section content
    [Return]    ${movies_details}

Get Details Of A Non-Adult VOD Asset Through Backend    #USED
    [Documentation]    This keyword fetches asset details of a non-adult VOD asset through backend
    Get Vod Full Vod Structure
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${asset_crid}    Get Vod Crid     ${LAB_CONF}    ${COUNTRY}    ${OSD_LANGUAGE}    ${CUSTOMER_ID}    ${cpe_profile_id}
    ...    ${structure_json}    ${ROOT_ID}    Collection    BasicCollection    ASSET    ${False}    ${False}
    ${asset_details}    Get Vod Details From Asset Crid    ${asset_crid}
    [Return]    ${asset_details}

Purchase A Non-Adult TVOD Asset Through Backend    #USED
    [Documentation]    This keyword purchases a non-adult TVOD asset whose asset details are known through backend.
    [Arguments]    ${details_json}
    ${asset_details_string}    Read Json As String    ${details_json}
    ${purchase_response}    Purchase Tvod    ${LAB_CONF}    ${customer_id}    ${asset_details_string}    ${CPE_ID}
    ${response_code}    Set Variable    ${purchase_response.status_code}
    ${failedReason}    Set Variable If    ${response_code} == 409    Conflict Error. Item already purchased.
    ...    ${response_code} != 200    Item could not be purchased.    ${EMPTY}
    Should Be Empty    ${failedReason}    ${failedReason}
    ${offers_list}    Extract Value For Key    ${details_json}    ${EMPTY}    offers    ${False}
    ${crid_id}    Set Variable    ${offers_list[${0}]['id']}
    Set Suite Variable    ${LAST_FETCHED_VOD_ASSET}    ${crid_id}

Get Full VOD Structure    #USED
    [Documentation]    This keyword fetches details of all VOD Sections from backend
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${vod_structure}    Get Vod Full Vod Structure
    ${vod_screens}    Set Variable     ${vod_structure['screens']}
    ${vod_dictionary}    Create Dictionary
    ${length}    Get Length    ${vod_screens}
    :FOR    ${i}    IN RANGE    0    ${length}
    \    ${section_name}    Set Variable    ${vod_screens[${i}]['title']}
    \    ${movies_details}    I Get Contents Of A VOD Section Based On Parameters    ${vod_screens[${i}]['title']}
    ...    ${cpe_profile_id}    all
    \    Set To Dictionary    ${vod_dictionary}    ${vod_screens[${i}]['title']}    ${movies_details}
    [Return]    ${vod_dictionary}

Get Full VOD Structure For Providers Section    #USED
    [Documentation]    This keyword fetches the full VOD Structure Of Providers Section From Backend
    ...    parameter vod_dictionary should contain basic voscreen details of provider section
    [Arguments]    ${vod_dictionary}
    ${length}    Get Length    ${vod_dictionary['Providers'][${0}]}
    ${provider_dictionary}    Create Dictionary
    :FOR    ${i}    IN RANGE    0    ${length}
    \    ${screen_layout}    Set Variable    ${vod_dictionary['Providers'][${0}][${i}]['screenLayout']}
    \    ${screen_title}    Set Variable    ${vod_dictionary['Providers'][${0}][${i}]['title']}
    \    ${gridlink_crid_id}    Set Variable    ${vod_dictionary['Providers'][${0}][${i}]['gridLink']['id']}
    \    ${is_grid}    Set Variable If    '${screen_layout}'=='Grid'    ${True}    ${False}
    \    ${provider_structure}    Run Keyword If    '${is_grid}'=='True'
    ...    Get Vod GridScreen From Screen Crid    ${gridlink_crid_id}
    ...    ELSE    Get Vod Structure Based On Screen Crid    ${gridlink_crid_id}
    \    Set To Dictionary    ${provider_dictionary}    ${screen_title}    ${provider_structure}
    Set To Dictionary    ${vod_dictionary}    Providers    ${provider_dictionary}
    ${provider_names}    Get Dictionary Keys    ${vod_dictionary['Providers']}
    ${length}    Get Length    ${provider_names}
    :FOR    ${i}    IN RANGE    0    ${length}
    \    ${provider_name}    Set Variable    ${provider_names[${i}]}
    \    ${provider_details}    Set Variable    ${vod_dictionary['Providers']['${provider_name}']}
    \    ${is_screens}    Run Keyword And Return Status    Dictionary Should Contain Key    ${provider_details}    screens
    \    ${assets}    Run Keyword If    ${is_screens}    Get Vod Screen From Crid    ${EMPTY}
    ...    ${provider_details['screens'][${0}]['id']}
    \    Run Keyword If    ${is_screens}    Set To Dictionary    ${vod_dictionary['Providers']}    ${provider_name}    ${assets}
    [Return]    ${vod_dictionary}

Get Vod GridScreen From Screen Crid    #USED
    [Documentation]    This keyword gets the details of a vod grid screen based on crid id of the screen
    ...    specified by parameter screen_crid
    [Arguments]    ${screen_crid}
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${grid_response}    Get Vod Gridscreen    ${LAB_CONF}    ${COUNTRY}    ${OSD_LANGUAGE}    ${customerid}    ${cpe_profile_id}    ${ROOT_ID}
    ...    ${screen_crid}    False
    Log    ${grid_response}
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${grid_response.status_code}    200
    ${failedReason}    Set Variable If    ${grid_response.status_code} != 200 and ${grid_response.status_code} != ${None}    VOD ${screen_title} Screen request returns ${${grid_response.status_code}    ${failedReason}
    ${failedReason}    Set Variable If    ${grid_response.status_code} == ${None}    VOD ${screen_title} Screen request did not return a response    ${failedReason}
    ${grid_json}    Run Keyword If    ${grid_response.status_code} == 200    Set Variable    ${grid_response.json()}
    Set Suite Variable    ${grid_json}    ${grid_json}
    Log    ${grid_json}
    [Return]    ${grid_json}

Get Vod Structure Based On Screen Crid    #USED
    [Documentation]    This keyword gets the vod structure based on crid id of the screen
    ...    specified by parameter screen_crid
    [Arguments]    ${crid_id}
    Get Root Id From Purchase Service
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${structure_response}    Get Vod Structure By Crid    ${LAB_CONF}    ${COUNTRY}    ${OSD_LANGUAGE}    ${customerid}    ${cpe_profile_id}    ${ROOT_ID}
    ...    ${crid_id}
    Log    ${structure_response}
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${structure_response.status_code}    200
    ${failedReason}    Run Keyword If    ${structure_response.status_code} == None    Log Response    ${http_response}    ${failedReason} Could Not retrieve VOD Service url:
    ${failedReason}    Run Keyword If    ${structure_response.status_code} != ${None} and ${structure_response.status_code} \ != 200    Set Variable    VOD Structure call returns ${http_response.status_code}
    ...    ELSE    Set Variable    ${failedReason}
    ${structure_json}    Run Keyword If    ${structure_response.status_code} == 200    Set Variable    ${structure_response.json()}
    Set Suite Variable    ${structure_json}    ${structure_json}
    Log    ${structure_json}
    [Return]    ${structure_json}

Get Contextual VOD Assets    #USED
    [Documentation]    This keyword fetches the list of VOD assets in contextual main menu of on demand
    ...    argument opt_in: opt in status of the customer
    [Arguments]    ${opt_in}=${True}
    Get Root Id From Purchase Service
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${response}    Get Vod Context Menu    ${LAB_CONF}    ${COUNTRY}    ${OSD_LANGUAGE}    ${customerid}
    ...    ${cpe_profile_id}    ${ROOT_ID}    ${opt_in}
    Should Be True    ${response.status_code}==${200}    Unable to fetch data of vod contextual menu from backend. Status code returned is ${response.status_code}
    [Return]    ${response.json()}

Get Series VOD Details    #USED
    [Documentation]    This keyword retrieves details of a series VOD asset
    ...    ${crid_id} is the crid id of a series/season
    [Arguments]    ${crid_id}
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${response}    Get Vod Series Detail    ${LAB_CONF}    ${COUNTRY}    ${OSD_LANGUAGE}    ${customerid}    ${cpe_profile_id}
    ...    ${crid_id}
    Should Be True    ${response.status_code}==${200}    Unable to fetch data of series VOD asset from backend. Status code returned is ${response.status_code}
    [Return]    ${response.json()}

Get Root Id From Vod Structure    #USED
    [Documentation]    This keyword try to retrieve the rootid from the vodstructure
    [Arguments]    ${homescreen_hint_rootid}
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${response}    Get Vod Structure    ${LAB_CONF}    ${COUNTRY}    ${OSD_LANGUAGE}    ${customer_id}    ${cpe_profile_id}    ${homescreen_hint_rootid}
    Should Be True    ${response.status_code}==${200}    Unable to fetch data from vod structure. Status code returned is ${response.status_code}
    [Return]    ${response.json()}

Get Gridscreen Options For Crid    #USED
    [Documentation]    This keyword returns the genres and sort options for a griscreen whose crid is provided
    ...    genre_crid is True if given gridscreen crid is for genre page
    [Arguments]    ${crid}    ${opt_in}=${True}    ${genre_crid}=${True}
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${response}    Get Vod Gridoptions    ${LAB_CONF}    ${COUNTRY}    ${OSD_LANGUAGE}    ${customer_id}    ${cpe_profile_id}    ${crid}
    ...    ${opt_in}    ${genre_crid}
    Should Be True    ${response.status_code}==${200}    Unable to fetch gridscreen options for ${crid}. Status code returned is ${response.status_code}
    [Return]    ${response.json()}